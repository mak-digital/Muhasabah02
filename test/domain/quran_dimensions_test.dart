import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/recorded_context.dart';

void main() {
  test('seven quran dimensions stay independent', () {
    var record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.reading, TernaryOutcome.positive);
    for (final dimension in QuranDimension.values.where(
      (d) => d != QuranDimension.reading,
    )) {
      expect(record.quranOutcome(dimension), TernaryOutcome.unanswered);
    }
  });

  test('selecting a quran activity does not default to positive', () {
    final record = DailyCheckIn.empty('2026-09-03');
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.unanswered,
    );
  });

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

  test('application reflection is not a response completion flag', () {
    final record = DailyCheckIn.empty(
      '2026-09-03',
    ).withQuran(QuranDimension.applicationReflection, TernaryOutcome.positive);
    expect(record.answeredRecordableCount, 0);
    expect(kRecordableFieldCount, 10);
  });
}
