import 'context_catalog.dart';
import 'daily_check_in.dart';
import 'date_key.dart';
import 'ontology.dart';
import 'quran.dart';
import 'review_period.dart';

/// Read-only Recognition identity. Computed, not persisted, not a DailyCheckIn
/// field. Independent of English question copy.
///
/// [stableId] names a factor-pattern definition, not an evaluation run:
/// `recognition:<domain>:<subject>:<outcome>:<factorStableId>`.
/// [window] is the evaluation period for this computed pattern and is not
/// part of [stableId]. Counts and supporting dates are occurrence evidence
/// on [RecognitionPattern], not definition identity.
class RecognitionDefinition {
  const RecognitionDefinition({
    required this.stableId,
    required this.domain,
    required this.subjectNamespace,
    required this.subjectPersistedId,
    required this.conceptualDomain,
    required this.subjectKind,
    required this.questionKey,
    required this.window,
    required this.factorCatalog,
    required this.factorPersistedId,
    required this.factorStableId,
    required this.factorStatus,
    required this.factorKind,
  });

  final String stableId;
  final String domain;
  final String subjectNamespace;
  final String subjectPersistedId;
  final ConceptualDomainId conceptualDomain;
  final OntologyConstructKind subjectKind;
  final String questionKey;
  final ReviewPeriod window;
  final OntologyFactorCatalog factorCatalog;
  final String factorPersistedId;
  final String factorStableId;
  final OntologyNodeStatus factorStatus;
  final OntologyConstructKind factorKind;

  factory RecognitionDefinition.fromPattern(RecognitionPattern pattern) {
    final quran = OntologyRegistry.forQuranDimension(pattern.subject);
    final polarity = pattern.outcome == TernaryOutcome.positive
        ? 'positive'
        : 'negative';
    const catalog = OntologyFactorCatalog.quranContext;
    final factor =
        OntologyRegistry.forFactor(
          catalog: catalog,
          persistedId: pattern.factorId,
          polarity: polarity,
        ) ??
        OntologyRegistry.forFactor(
          catalog: catalog,
          persistedId: pattern.factorId,
        );
    final factorStableId =
        factor?.stableId ?? '${catalog.name}:$polarity:${pattern.factorId}';
    return RecognitionDefinition(
      stableId:
          'recognition:${pattern.domain}:${pattern.subject.name}:'
          '${pattern.outcome.name}:$factorStableId',
      domain: pattern.domain,
      subjectNamespace: 'quranDimension',
      subjectPersistedId: pattern.subject.name,
      conceptualDomain: quran.conceptualDomain,
      subjectKind: OntologyConstructKind.practiceObservation,
      questionKey: 'quranDimension.${pattern.subject.name}',
      window: pattern.period,
      factorCatalog: catalog,
      factorPersistedId: pattern.factorId,
      factorStableId: factorStableId,
      factorStatus: factor?.status ?? OntologyNodeStatus.retired,
      factorKind: OntologyConstructKind.contextProvenance,
    );
  }
}

class RecognitionPattern {
  const RecognitionPattern({
    required this.domain,
    required this.subject,
    required this.outcome,
    required this.question,
    required this.factorId,
    required this.factorLabel,
    required this.contextualCount,
    required this.factorCount,
    required this.outcomeCount,
    required this.distinctDates,
    required this.dateSpanDays,
    required this.period,
    required this.supportingDates,
  });

  final String domain;
  final QuranDimension subject;
  final TernaryOutcome outcome;
  final String question;
  final String factorId;
  final String factorLabel;
  final int contextualCount;
  final int factorCount;
  final int outcomeCount;
  final int distinctDates;
  final int dateSpanDays;
  final ReviewPeriod period;
  final List<String> supportingDates;

  /// Legacy evidence snapshot for Personal Response provenance.
  /// Includes current English [question] text; prefer [definition] for
  /// copy-independent identity. Do not change this string format in R7.
  String get identity =>
      '$domain+${subject.name}+${outcome.name}+$question+$factorId';

  RecognitionDefinition get definition =>
      RecognitionDefinition.fromPattern(this);

  String get coverageLine =>
      'Context was recorded for $contextualCount of $outcomeCount observations where you recorded ${outcome == TernaryOutcome.positive ? subject.positiveLabel.toLowerCase() : subject.negativeLabel.toLowerCase()}.';

  String get factorLine =>
      'Among those $contextualCount observations, “$factorLabel” appeared on $factorCount.';
}

class RecognitionWindowCoverage {
  const RecognitionWindowCoverage({
    required this.windowDays,
    required this.savedDays,
  });

  final int windowDays;
  final int savedDays;
}

class RecognitionEngine {
  const RecognitionEngine();

  RecognitionWindowCoverage coverage({
    required List<DailyCheckIn> records,
    required ReviewPeriod period,
    required DateTime now,
  }) {
    final keys = periodDateKeys(period.days, now: now);
    final saved = {
      for (final record in records)
        if (keys.contains(record.dateKey)) record.dateKey,
    };
    return RecognitionWindowCoverage(
      windowDays: keys.length,
      savedDays: saved.length,
    );
  }

  List<RecognitionPattern> detect({
    required List<DailyCheckIn> records,
    required ReviewPeriod period,
    required DateTime now,
    Iterable<QuranDimension>? subjects,
  }) {
    if (period == ReviewPeriod.days7) return const [];
    final keys = periodDateKeys(period.days, now: now).toSet();
    final inPeriod = [
      for (final record in records)
        if (keys.contains(record.dateKey)) record,
    ];
    final eligible = [
      for (final subject in subjects ?? QuranDimension.values)
        if (subject.isNeutralPeerDimension) subject,
    ];
    final patterns = <RecognitionPattern>[];
    const domain = 'quran';
    for (final subject in eligible) {
      for (final outcome in [
        TernaryOutcome.positive,
        TernaryOutcome.negative,
      ]) {
        if (!contextAllowed(subject, outcome)) continue;
        final polarity = outcome == TernaryOutcome.positive
            ? 'positive'
            : 'negative';
        final matching = <DailyCheckIn>[];
        for (final record in inPeriod) {
          if (record.quranOutcome(subject) == outcome) matching.add(record);
        }
        final t = matching.length;
        if (t == 0) continue;
        final contextual = <DailyCheckIn>[];
        for (final record in matching) {
          final ctx = record.contextFor(subject, polarity);
          if (ctx != null &&
              (ctx.factorIds.isNotEmpty ||
                  (ctx.freeText != null && ctx.freeText!.trim().isNotEmpty))) {
            contextual.add(record);
          }
        }
        final c = contextual.length;
        if (c < 5) continue;
        if (c / t < 0.40) continue;

        final factorDates = <String, List<String>>{};
        for (final record in contextual) {
          final ctx = record.contextFor(subject, polarity)!;
          for (final id in ctx.factorIds) {
            factorDates.putIfAbsent(id, () => []).add(record.dateKey);
          }
        }
        for (final entry in factorDates.entries) {
          final dates = [...entry.value]..sort();
          final unique = dates.toSet().toList()..sort();
          final f = unique.length;
          if (f < 3) continue;
          if (f / c < 0.40) continue;
          if (unique.length < 3) continue;
          final span = daysInclusiveSpan(unique.first, unique.last);
          if (span < 7) continue;
          patterns.add(
            RecognitionPattern(
              domain: domain,
              subject: subject,
              outcome: outcome,
              question: subject.question,
              factorId: entry.key,
              factorLabel: ContextCatalog.labelFor(entry.key, polarity),
              contextualCount: c,
              factorCount: f,
              outcomeCount: t,
              distinctDates: unique.length,
              dateSpanDays: span,
              period: period,
              supportingDates: unique,
            ),
          );
        }
      }
    }
    patterns.sort((a, b) => b.factorCount.compareTo(a.factorCount));
    return patterns;
  }
}
