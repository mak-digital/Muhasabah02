import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/ontology.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/personalisation_resolver.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/recognition.dart';
import 'package:muhasabah02/domain/recorded_context.dart';
import 'package:muhasabah02/domain/review_period.dart';

const engine = RecognitionEngine();
final nowJuly = DateTime(2026, 7, 12);

DailyCheckIn day({
  required String date,
  required TernaryOutcome outcome,
  String? factor,
  QuranDimension subject = QuranDimension.meaning,
  String? freeText,
}) {
  var record = DailyCheckIn.empty(date).withQuran(subject, outcome);
  if (factor != null || (freeText != null && freeText.trim().isNotEmpty)) {
    record = record.withContext(
      RecordedContext(
        subject: subject,
        polarity: outcome == TernaryOutcome.positive ? 'positive' : 'negative',
        factorIds: [?factor],
        freeText: freeText,
      ),
    );
  }
  return record;
}

List<DailyCheckIn> consecutive({
  required String prefix,
  required int count,
  required TernaryOutcome outcome,
  String? factor,
  QuranDimension subject = QuranDimension.meaning,
}) {
  return [
    for (var i = 1; i <= count; i++)
      day(
        date: '$prefix${i.toString().padLeft(2, '0')}',
        outcome: outcome,
        factor: factor,
        subject: subject,
      ),
  ];
}

void main() {
  test('recognition is disabled for 7 days', () {
    final patterns = engine.detect(
      records: consecutive(
        prefix: '2026-07-',
        count: 12,
        outcome: TernaryOutcome.positive,
        factor: 'routine',
      ),
      period: ReviewPeriod.days7,
      now: nowJuly,
    );
    expect(patterns, isEmpty);
  });

  test('recognition requires thresholds including contextual coverage', () {
    final records = consecutive(
      prefix: '2026-08-',
      count: 10,
      outcome: TernaryOutcome.positive,
      factor: null,
    );
    for (var i = 0; i < 5; i++) {
      records[i] = day(
        date: records[i].dateKey,
        outcome: TernaryOutcome.positive,
        factor: 'routine',
      );
    }
    final none = engine.detect(
      records: records,
      period: ReviewPeriod.days30,
      now: DateTime(2026, 8, 10),
    );
    expect(none, isEmpty);

    final enough = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.positive,
      factor: 'routine',
    );
    final patterns = engine.detect(
      records: enough,
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    expect(patterns, isNotEmpty);
    expect(patterns.first.coverageLine, contains('Context was recorded for'));
    expect(patterns.first.factorLine, contains('appeared on'));
    expect(patterns.first.factorLine.toLowerCase(), isNot(contains('caused')));
    expect(patterns.first.factorLine.toLowerCase(), isNot(contains('because')));
  });

  test('unanswered quran outcomes are not Recognition evidence', () {
    final unanswered = [
      for (var i = 1; i <= 12; i++)
        DailyCheckIn.empty('2026-07-${i.toString().padLeft(2, '0')}'),
    ];
    final negatives = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.negative,
      factor: 'fatigue',
    );
    expect(
      engine.detect(
        records: unanswered,
        period: ReviewPeriod.days30,
        now: nowJuly,
      ),
      isEmpty,
    );
    final negativePatterns = engine.detect(
      records: negatives,
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    expect(negativePatterns, isNotEmpty);
    expect(negativePatterns.first.outcome, TernaryOutcome.negative);
  });

  test('empty and all-unanswered windows report zero saved vs calendar days', () {
    final empty = engine.coverage(
      records: const [],
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    expect(empty.windowDays, 30);
    expect(empty.savedDays, 0);

    final unanswered = [
      DailyCheckIn.empty('2026-07-12'),
      DailyCheckIn.empty('2026-07-10'),
    ];
    final sparse = engine.coverage(
      records: unanswered,
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    expect(sparse.windowDays, 30);
    expect(sparse.savedDays, 2);
    expect(
      engine.detect(
        records: unanswered,
        period: ReviewPeriod.days30,
        now: nowJuly,
      ),
      isEmpty,
    );
  });

  test('partial coverage counts only in-window saved check-ins', () {
    final now = DateTime(2026, 9, 30);
    final records = [
      DailyCheckIn.empty('2026-08-31'),
      DailyCheckIn.empty('2026-09-01'),
      DailyCheckIn.empty('2026-09-15'),
      DailyCheckIn.empty('2026-09-30'),
      DailyCheckIn.empty('2026-10-01'),
    ];
    final coverage = engine.coverage(
      records: records,
      period: ReviewPeriod.days30,
      now: now,
    );
    expect(coverage.windowDays, 30);
    expect(coverage.savedDays, 3);
    expect(periodDateKeys(30, now: now).first, '2026-09-01');
    expect(periodDateKeys(30, now: now).last, '2026-09-30');
  });

  test('engine ignores out-of-window records even when they would pass thresholds', () {
    final now = DateTime(2026, 9, 30);
    final inWindow = [
      for (var i = 1; i <= 12; i++)
        day(
          date: '2026-09-${i.toString().padLeft(2, '0')}',
          outcome: TernaryOutcome.positive,
          factor: 'routine',
        ),
    ];
    final outside = [
      for (var i = 1; i <= 12; i++)
        day(
          date: '2026-08-${i.toString().padLeft(2, '0')}',
          outcome: TernaryOutcome.negative,
          factor: 'fatigue',
          subject: QuranDimension.revision,
        ),
    ];
    final patterns = engine.detect(
      records: [...outside, ...inWindow],
      period: ReviewPeriod.days30,
      now: now,
    );
    expect(patterns, isNotEmpty);
    expect(
      patterns.every((pattern) => pattern.subject == QuranDimension.meaning),
      isTrue,
    );
    expect(
      patterns.every(
        (pattern) =>
            pattern.supportingDates.every((date) => date.startsWith('2026-09-')),
      ),
      isTrue,
    );
  });

  test('90-day window includes an earlier month that 30-day excludes', () {
    final now = DateTime(2026, 9, 30);
    final july = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.positive,
      factor: 'routine',
    );
    final patterns30 = engine.detect(
      records: july,
      period: ReviewPeriod.days30,
      now: now,
    );
    final patterns90 = engine.detect(
      records: july,
      period: ReviewPeriod.days90,
      now: now,
    );
    expect(patterns30, isEmpty);
    expect(patterns90, isNotEmpty);
    expect(periodDateKeys(90, now: now).first, '2026-07-03');
    expect(july.first.dateKey, '2026-07-01');
  });

  test('Qur’an Recognition eligibility stays on stored peer dimensions', () {
    expect(QuranDimension.reading.isNeutralPeerDimension, isFalse);
    expect(
      QuranDimension.applicationReflection.isNeutralPeerDimension,
      isFalse,
    );
    for (final subject in [
      QuranDimension.meaning,
      QuranDimension.memorisation,
      QuranDimension.revision,
      QuranDimension.tafsir,
      QuranDimension.reflection,
      QuranDimension.consciousApplication,
    ]) {
      expect(subject.isNeutralPeerDimension, isTrue);
    }
  });

  test('Recitation and Application Reflection never become Recognition subjects', () {
    final now = DateTime(2026, 7, 12);
    final reading = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.positive,
      factor: 'routine',
      subject: QuranDimension.reading,
    );
    final application = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.positive,
      factor: 'routine',
      subject: QuranDimension.applicationReflection,
    );
    expect(
      engine.detect(
        records: [...reading, ...application],
        period: ReviewPeriod.days30,
        now: now,
        subjects: QuranDimension.values,
      ),
      isEmpty,
    );
  });

  test('independent Qur’an dimensions do not share evidence', () {
    final meaning = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.positive,
      factor: 'routine',
    );
    final revision = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.negative,
      factor: 'fatigue',
      subject: QuranDimension.revision,
    );
    final merged = <String, DailyCheckIn>{};
    for (final record in [...meaning, ...revision]) {
      final existing = merged[record.dateKey];
      merged[record.dateKey] = existing == null
          ? record
          : existing
                .withQuran(QuranDimension.revision, TernaryOutcome.negative)
                .withContext(
                  RecordedContext(
                    subject: QuranDimension.revision,
                    polarity: 'negative',
                    factorIds: const ['fatigue'],
                  ),
                );
    }
    final patterns = engine.detect(
      records: merged.values.toList(),
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    expect(
      patterns.any((pattern) => pattern.subject == QuranDimension.meaning),
      isTrue,
    );
    expect(
      patterns.any((pattern) => pattern.subject == QuranDimension.revision),
      isTrue,
    );
    final meaningPattern = patterns.firstWhere(
      (pattern) => pattern.subject == QuranDimension.meaning,
    );
    expect(meaningPattern.factorId, 'routine');
    expect(meaningPattern.outcome, TernaryOutcome.positive);
  });

  test('mix exclusions omit peer dimensions that still have stored evidence', () {
    final meaning = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.positive,
      factor: 'routine',
    );
    final revision = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.negative,
      factor: 'fatigue',
      subject: QuranDimension.revision,
    );
    final all = engine.detect(
      records: [...meaning, ...revision],
      period: ReviewPeriod.days30,
      now: nowJuly,
      subjects: const [QuranDimension.meaning, QuranDimension.revision],
    );
    expect(all.map((pattern) => pattern.subject).toSet(), {
      QuranDimension.meaning,
      QuranDimension.revision,
    });
    final meaningOnly = engine.detect(
      records: [...meaning, ...revision],
      period: ReviewPeriod.days30,
      now: nowJuly,
      subjects: const [QuranDimension.meaning],
    );
    expect(
      meaningOnly.every((pattern) => pattern.subject == QuranDimension.meaning),
      isTrue,
    );
    final none = engine.detect(
      records: [...meaning, ...revision],
      period: ReviewPeriod.days30,
      now: nowJuly,
      subjects: const [],
    );
    expect(none, isEmpty);
  });

  test('PersonalisationResolver supplies mix-filtered peer subjects', () {
    final hidden = PersonalisationResolver(
      visibleDomains: {MonitorDomain.salah, MonitorDomain.akhlaq},
      mix: PersonalMix.sameAsDomains,
    );
    expect(hidden.eligibleRecognitionSubjects, isEmpty);

    final readingOnly = PersonalisationResolver(
      visibleDomains: {MonitorDomain.quran, MonitorDomain.salah},
      mix: mixForKind(
        PersonalMixKind.custom,
        customKeys: {'quran.reading', 'salah.fajr'},
      ),
    );
    expect(readingOnly.eligibleRecognitionSubjects, isEmpty);
    expect(readingOnly.includedQuranDimensions, [QuranDimension.reading]);

    final worship = PersonalisationResolver(
      visibleDomains: Set<MonitorDomain>.from(MonitorDomain.values),
      mix: mixForKind(PersonalMixKind.worship),
    );
    expect(
      worship.eligibleRecognitionSubjects,
      containsAll([QuranDimension.meaning, QuranDimension.reflection]),
    );
    expect(
      worship.eligibleRecognitionSubjects,
      isNot(contains(QuranDimension.reading)),
    );
    expect(
      worship.eligibleRecognitionSubjects,
      isNot(contains(QuranDimension.revision)),
    );

    final sameAsDomains = PersonalisationResolver(
      visibleDomains: {MonitorDomain.quran, MonitorDomain.salah},
      mix: PersonalMix.sameAsDomains,
    );
    expect(
      sameAsDomains.eligibleRecognitionSubjects.toSet(),
      {
        QuranDimension.meaning,
        QuranDimension.memorisation,
        QuranDimension.revision,
        QuranDimension.tafsir,
        QuranDimension.reflection,
        QuranDimension.consciousApplication,
      },
    );
    expect(
      sameAsDomains.eligibleRecognitionSubjects,
      isNot(contains(QuranDimension.reading)),
    );
    expect(
      sameAsDomains.eligibleRecognitionSubjects,
      isNot(contains(QuranDimension.applicationReflection)),
    );
  });

  test('future-dated records sit outside the inclusive window', () {
    final now = DateTime(2026, 9, 30);
    final records = [
      DailyCheckIn.empty('2026-09-30'),
      DailyCheckIn.empty('2026-10-01'),
      ...consecutive(
        prefix: '2026-10-',
        count: 12,
        outcome: TernaryOutcome.positive,
        factor: 'routine',
      ),
    ];
    final coverage = engine.coverage(
      records: records,
      period: ReviewPeriod.days30,
      now: now,
    );
    expect(coverage.windowDays, 30);
    expect(coverage.savedDays, 1);
    expect(periodDateKeys(30, now: now).last, '2026-09-30');
    expect(
      engine.detect(
        records: records,
        period: ReviewPeriod.days30,
        now: now,
      ),
      isEmpty,
    );
  });

  test('duplicate date keys do not inflate saved-day coverage', () {
    final now = DateTime(2026, 9, 30);
    final records = [
      DailyCheckIn.empty('2026-09-15'),
      DailyCheckIn.empty('2026-09-15'),
      DailyCheckIn.empty('2026-09-30'),
      DailyCheckIn.empty('2026-09-30'),
    ];
    final coverage = engine.coverage(
      records: records,
      period: ReviewPeriod.days30,
      now: now,
    );
    expect(coverage.savedDays, 2);
    expect(coverage.windowDays, 30);
  });

  test('90-day Recognition uses the same engine and explicit window', () {
    final records = consecutive(
      prefix: '2026-07-',
      count: 12,
      outcome: TernaryOutcome.positive,
      factor: 'routine',
    );
    final patterns = engine.detect(
      records: records,
      period: ReviewPeriod.days90,
      now: nowJuly,
    );
    final patterns30 = engine.detect(
      records: records,
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    expect(patterns, isNotEmpty);
    expect(patterns.first.period, ReviewPeriod.days90);
    expect(patterns.first.definition.window, ReviewPeriod.days90);
    expect(patterns30.first.definition.window, ReviewPeriod.days30);
    expect(
      patterns.first.definition.stableId,
      patterns30.first.definition.stableId,
    );
    expect(patterns.first.definition.stableId, isNot(contains(':90:')));
    expect(patterns.first.definition.stableId, isNot(contains(':30:')));
  });

  test('Recognition definition is copy-independent and namespaced', () {
    final pattern = RecognitionPattern(
      domain: 'quran',
      subject: QuranDimension.meaning,
      outcome: TernaryOutcome.positive,
      question: QuranDimension.meaning.question,
      factorId: 'routine',
      factorLabel: 'Existing routine',
      contextualCount: 12,
      factorCount: 12,
      outcomeCount: 12,
      distinctDates: 12,
      dateSpanDays: 12,
      period: ReviewPeriod.days30,
      supportingDates: const ['2026-07-01'],
    );
    final definition = pattern.definition;
    expect(definition.subjectNamespace, 'quranDimension');
    expect(definition.subjectPersistedId, 'meaning');
    expect(
      definition.conceptualDomain,
      ConceptualDomainId.quranRevelationEngagement,
    );
    expect(definition.questionKey, 'quranDimension.meaning');
    expect(definition.questionKey, isNot(contains('Did you')));
    expect(definition.stableId, isNot(contains(pattern.question)));
    expect(
      definition.stableId,
      'recognition:quran:meaning:positive:quranContext:positive:routine',
    );
    expect(definition.factorKind, OntologyConstructKind.contextProvenance);
    expect(definition.factorStatus, OntologyNodeStatus.active);
    expect(pattern.identity, contains(pattern.question));
  });

  test('raw factor other does not collide across polarity', () {
    RecognitionPattern make(TernaryOutcome outcome) {
      return RecognitionPattern(
        domain: 'quran',
        subject: QuranDimension.tafsir,
        outcome: outcome,
        question: QuranDimension.tafsir.question,
        factorId: 'other',
        factorLabel: 'Other',
        contextualCount: 12,
        factorCount: 12,
        outcomeCount: 12,
        distinctDates: 12,
        dateSpanDays: 12,
        period: ReviewPeriod.days30,
        supportingDates: const ['2026-07-01'],
      );
    }

    final positive = make(TernaryOutcome.positive).definition;
    final negative = make(TernaryOutcome.negative).definition;
    expect(positive.factorPersistedId, negative.factorPersistedId);
    expect(positive.factorStableId, isNot(negative.factorStableId));
    expect(positive.stableId, isNot(negative.stableId));
  });

  test('retired context aliases stay retired in Recognition metadata', () {
    final definition = RecognitionPattern(
      domain: 'quran',
      subject: QuranDimension.revision,
      outcome: TernaryOutcome.negative,
      question: QuranDimension.revision.question,
      factorId: 'fatigue',
      factorLabel: 'Fatigue',
      contextualCount: 12,
      factorCount: 12,
      outcomeCount: 12,
      distinctDates: 12,
      dateSpanDays: 12,
      period: ReviewPeriod.days30,
      supportingDates: const ['2026-07-01'],
    ).definition;
    expect(definition.factorStatus, OntologyNodeStatus.active);

    final retired = RecognitionPattern(
      domain: 'quran',
      subject: QuranDimension.revision,
      outcome: TernaryOutcome.negative,
      question: QuranDimension.revision.question,
      factorId: 'energy',
      factorLabel: 'Energy felt sufficient',
      contextualCount: 12,
      factorCount: 12,
      outcomeCount: 12,
      distinctDates: 12,
      dateSpanDays: 12,
      period: ReviewPeriod.days30,
      supportingDates: const ['2026-07-01'],
    ).definition;
    expect(retired.factorStatus, OntologyNodeStatus.retired);
    expect(retired.factorStableId, 'quranContext:energy');
    expect(retired.stableId, contains('quranContext:energy'));
  });

  test('ontology lookup for Recognition does not mutate stored check-ins', () {
    final before = DailyCheckIn.empty('2026-07-01')
        .withQuran(QuranDimension.meaning, TernaryOutcome.positive)
        .toJson();
    final pattern = RecognitionPattern(
      domain: 'quran',
      subject: QuranDimension.meaning,
      outcome: TernaryOutcome.positive,
      question: QuranDimension.meaning.question,
      factorId: 'routine',
      factorLabel: 'Existing routine',
      contextualCount: 12,
      factorCount: 12,
      outcomeCount: 12,
      distinctDates: 12,
      dateSpanDays: 12,
      period: ReviewPeriod.days30,
      supportingDates: const ['2026-07-01'],
    );
    expect(pattern.definition.stableId, isNotEmpty);
    engine.detect(
      records: consecutive(
        prefix: '2026-07-',
        count: 12,
        outcome: TernaryOutcome.positive,
        factor: 'routine',
      ),
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    expect(
      DailyCheckIn.empty('2026-07-01')
          .withQuran(QuranDimension.meaning, TernaryOutcome.positive)
          .toJson(),
      before,
    );
    expect(kDailyCheckInSchemaVersion, 6);
    expect(kOntologyRegistryVersion, 2);
  });

  test('free-text presence still counts toward context without being read', () {
    final records = [
      for (var i = 1; i <= 12; i++)
        day(
          date: '2026-07-${i.toString().padLeft(2, '0')}',
          outcome: TernaryOutcome.positive,
          freeText: 'private note that must not appear',
        ),
    ];
    final patterns = engine.detect(
      records: records,
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    expect(patterns, isEmpty);
    for (final record in records) {
      expect(record.contexts.first.freeText, contains('private'));
    }
  });

  test('coverage and pattern copy stay non-causal', () {
    final patterns = engine.detect(
      records: consecutive(
        prefix: '2026-07-',
        count: 12,
        outcome: TernaryOutcome.positive,
        factor: 'routine',
      ),
      period: ReviewPeriod.days30,
      now: nowJuly,
    );
    final blob =
        '${patterns.first.coverageLine} ${patterns.first.factorLine}';
    for (final word in [
      'caused',
      'because',
      'you should',
      'linked',
      'associated',
      'iman',
      'taqwa',
    ]) {
      expect(blob.toLowerCase(), isNot(contains(word)));
    }
  });
}
