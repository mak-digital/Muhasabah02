import 'context_catalog.dart';
import 'daily_check_in.dart';
import 'date_key.dart';
import 'quran.dart';
import 'recorded_context.dart';
import 'review_period.dart';

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

  String get identity =>
      '$domain+${subject.name}+${outcome.name}+$question+$factorId';

  String get coverageLine =>
      'Context was recorded for $contextualCount of $outcomeCount observations where you recorded ${outcome == TernaryOutcome.positive ? subject.positiveLabel.toLowerCase() : subject.negativeLabel.toLowerCase()}.';

  String get factorLine =>
      'Among those $contextualCount observations, “$factorLabel” appeared on $factorCount.';
}

class RecognitionEngine {
  const RecognitionEngine();

  List<RecognitionPattern> detect({
    required List<DailyCheckIn> records,
    required ReviewPeriod period,
  }) {
    if (period == ReviewPeriod.days7) return const [];
    final patterns = <RecognitionPattern>[];
    const domain = 'quran';
    for (final subject in QuranDimension.values) {
      if (!subject.isNeutralPeerDimension) continue;
      for (final outcome in [
        TernaryOutcome.positive,
        TernaryOutcome.negative,
      ]) {
        if (!contextAllowed(subject, outcome)) continue;
        final polarity = outcome == TernaryOutcome.positive
            ? 'positive'
            : 'negative';
        final matching = <DailyCheckIn>[];
        for (final record in records) {
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
