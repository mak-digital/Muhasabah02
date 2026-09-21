import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/ontology.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/recognition.dart';
import 'package:muhasabah02/domain/recorded_context.dart';
import 'package:muhasabah02/domain/review_period.dart';

DailyCheckIn day({
  required String date,
  required TernaryOutcome outcome,
  String? factor,
}) {
  var record = DailyCheckIn.empty(date)
      .withQuran(QuranDimension.meaning, outcome);
  if (factor != null) {
    record = record.withContext(
      RecordedContext(
        subject: QuranDimension.meaning,
        polarity: outcome == TernaryOutcome.positive ? 'positive' : 'negative',
        factorIds: [factor],
      ),
    );
  }
  return record;
}

void main() {
  test('recognition is disabled for 7 days', () {
    final patterns = const RecognitionEngine().detect(
      records: const [],
      period: ReviewPeriod.days7,
    );
    expect(patterns, isEmpty);
  });

  test('recognition requires thresholds including contextual coverage', () {
    final records = <DailyCheckIn>[];
    for (var i = 1; i <= 10; i++) {
      final dd = i.toString().padLeft(2, '0');
      records.add(
        day(
          date: '2026-08-$dd',
          outcome: TernaryOutcome.positive,
          factor: i <= 5 ? 'routine' : null,
        ),
      );
    }
    final none = const RecognitionEngine().detect(
      records: records,
      period: ReviewPeriod.days30,
    );
    expect(none, isEmpty);

    final enough = <DailyCheckIn>[];
    for (var i = 1; i <= 12; i++) {
      final dd = i.toString().padLeft(2, '0');
      enough.add(
        day(
          date: '2026-07-$dd',
          outcome: TernaryOutcome.positive,
          factor: 'routine',
        ),
      );
    }
    final patterns = const RecognitionEngine().detect(
      records: enough,
      period: ReviewPeriod.days30,
    );
    expect(patterns, isNotEmpty);
    expect(patterns.first.coverageLine, contains('Context was recorded for'));
    expect(patterns.first.factorLine, contains('appeared on'));
    expect(patterns.first.factorLine.toLowerCase(), isNot(contains('caused')));
    expect(patterns.first.factorLine.toLowerCase(), isNot(contains('because')));
  });

  test('unanswered quran outcomes are not Recognition evidence', () {
    final unanswered = <DailyCheckIn>[];
    final negatives = <DailyCheckIn>[];
    for (var i = 1; i <= 12; i++) {
      final dd = i.toString().padLeft(2, '0');
      unanswered.add(DailyCheckIn.empty('2026-07-$dd'));
      negatives.add(
        day(
          date: '2026-07-$dd',
          outcome: TernaryOutcome.negative,
          factor: 'fatigue',
        ),
      );
    }
    expect(
      const RecognitionEngine().detect(
        records: unanswered,
        period: ReviewPeriod.days30,
      ),
      isEmpty,
    );
    final negativePatterns = const RecognitionEngine().detect(
      records: negatives,
      period: ReviewPeriod.days30,
    );
    expect(negativePatterns, isNotEmpty);
    expect(negativePatterns.first.outcome, TernaryOutcome.negative);
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

  test('90-day Recognition uses the same engine and explicit window', () {
    final records = <DailyCheckIn>[];
    for (var i = 1; i <= 12; i++) {
      final dd = i.toString().padLeft(2, '0');
      records.add(
        day(
          date: '2026-07-$dd',
          outcome: TernaryOutcome.positive,
          factor: 'routine',
        ),
      );
    }
    final patterns = const RecognitionEngine().detect(
      records: records,
      period: ReviewPeriod.days90,
    );
    final patterns30 = const RecognitionEngine().detect(
      records: records,
      period: ReviewPeriod.days30,
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
    expect(
      DailyCheckIn.empty('2026-07-01')
          .withQuran(QuranDimension.meaning, TernaryOutcome.positive)
          .toJson(),
      before,
    );
    expect(kDailyCheckInSchemaVersion, 6);
    expect(kOntologyRegistryVersion, 2);
  });
}
