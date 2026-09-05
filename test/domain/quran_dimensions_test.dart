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

  test('recitation with meaning engagement records recitation engagement', () {
    final record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.meaning, TernaryOutcome.positive);
    expect(
      record.quranOutcome(QuranDimension.meaning),
      TernaryOutcome.positive,
    );
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.positive,
    );
    expect(
      record.quranOutcome(QuranDimension.memorisation),
      TernaryOutcome.unanswered,
    );
  });

  test('recitation cannot be cleared while meaning is engagement', () {
    var record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.meaning, TernaryOutcome.positive);
    record = record.withQuran(QuranDimension.reading, TernaryOutcome.negative);
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.positive,
    );
    record = record.withQuran(
      QuranDimension.reading,
      TernaryOutcome.unanswered,
    );
    expect(
      record.quranOutcome(QuranDimension.reading),
      TernaryOutcome.positive,
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
      expect(QuranDimension.reading.label, 'Recitation');
      expect(QuranDimension.meaning.label, 'Recitation with Meaning');
      expect(
        QuranDimension.consciousApplication.label,
        'Conscious Application',
      );
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
    expect(kRecordableFieldCount, 10);
  });
}
