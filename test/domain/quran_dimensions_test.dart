import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/recorded_context.dart';

void main() {
  test('quran dimensions stay independent except approved meaning fill', () {
    var record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.reading, TernaryOutcome.positive);
    for (final dimension in QuranDimension.values.where(
      (d) => d != QuranDimension.reading,
    )) {
      expect(record.quranOutcome(dimension), TernaryOutcome.unanswered);
    }
  });

  test('understanding does not fill engagement', () {
    final record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.meaning, TernaryOutcome.positive);
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.positive,
    );
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.unanswered,
    );
  });

  test('engagement can be cleared while understanding is recorded', () {
    var record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.meaning, TernaryOutcome.positive);
    record = record.withQuran(QuranDimension.reading, TernaryOutcome.negative);
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.negative,
    );
  });

  test('recitation engagement does not fill meaning', () {
    final record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.reading, TernaryOutcome.positive);
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.unanswered,
    );
  });

  test('selecting a quran activity does not default to positive', () {
    final record = DailyCheckIn.empty('2026-09-03');
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.unanswered,
    );
  });

  test(
    'ui labels distinguish quranic, application, and personal reflection',
    () {
      expect(QuranDimension.reflection.label, 'Qur’anic Reflection');
      expect(
        QuranDimension.applicationReflection.label,
        'Application Reflection',
      );
      expect(QuranDimension.reading.label, 'Engagement');
      expect(QuranDimension.meaning.label, 'Understanding & reflection');
      expect(QuranDimension.consciousApplication.label, 'Practical relevance');
    },
  );

  test('application reflection never stores context', () {
    final allowed = contextAllowed(
      QuranDimension.applicationReflection,
      TernaryOutcome.positive,
    );
    expect(allowed, isFalse);
    var record = DailyCheckIn.empty(
      '2026-09-03',
    ).withQuran(QuranDimension.applicationReflection, TernaryOutcome.positive);
    record = record.withContext(
      const RecordedContext(
        subject: QuranDimension.applicationReflection,
        polarity: 'positive',
        factorIds: ['routine'],
      ),
    );
    expect(record.contexts, isEmpty);
  });

  test('application reflection and conscious application are not recordable fields', () {
    final record = DailyCheckIn.empty('2026-09-03')
        .withQuran(
          QuranDimension.applicationReflection,
          TernaryOutcome.positive,
        )
        .withQuran(
          QuranDimension.consciousApplication,
          TernaryOutcome.positive,
        );
    expect(record.answeredRecordableCount, 0);
    expect(quranDailyDimensions, [
      QuranDimension.reading,
      QuranDimension.meaning,
      QuranDimension.consciousApplication,
    ]);
    expect(kRecordableFieldCount, 10);
  });

  test('Home bands keep check-in groups and mix-filter rows', () {
    final bands = quranHomeBandsFor([
      QuranDimension.meaning,
      QuranDimension.consciousApplication,
    ]);
    expect(bands.map((band) => band.$1).toList(), [
      kQuranUnderstandingBand,
      kQuranApplicationBand,
    ]);
    expect(bands.first.$2, [QuranDimension.meaning]);
    expect(bands.last.$2, [QuranDimension.consciousApplication]);
  });
}
