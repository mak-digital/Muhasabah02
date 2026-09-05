import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/recorded_context.dart';

void main() {
  test('context eligibility matches approved quran dimensions', () {
    expect(
      contextAllowed(QuranDimension.meaning, TernaryOutcome.positive),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.meaning, TernaryOutcome.negative),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.memorisation, TernaryOutcome.positive),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.memorisation, TernaryOutcome.negative),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.revision, TernaryOutcome.positive),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.revision, TernaryOutcome.negative),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.tafsir, TernaryOutcome.positive),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.tafsir, TernaryOutcome.negative),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.reflection, TernaryOutcome.positive),
      isTrue,
    );
    expect(
      contextAllowed(QuranDimension.reflection, TernaryOutcome.negative),
      isTrue,
    );
    expect(
      contextAllowed(
        QuranDimension.applicationReflection,
        TernaryOutcome.positive,
      ),
      isFalse,
    );
    expect(
      contextAllowed(QuranDimension.reading, TernaryOutcome.positive),
      isTrue,
    );
    expect(
      contextAllowed(
        QuranDimension.consciousApplication,
        TernaryOutcome.positive,
      ),
      isTrue,
    );
  });

  test('context does not change recordable completion', () {
    var record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.meaning, TernaryOutcome.positive);
    final before = record.answeredRecordableCount;
    record = record.withContext(
      const RecordedContext(
        subject: QuranDimension.meaning,
        polarity: 'positive',
        factorIds: ['routine'],
        freeText: 'optional note',
      ),
    );
    expect(record.answeredRecordableCount, before);
    expect(record.contextFor(QuranDimension.meaning, 'positive')!.factorIds, [
      'routine',
    ]);
  });

  test('changing outcome drops ineligible context', () {
    var record = DailyCheckIn.empty('2026-09-03')
        .withQuran(QuranDimension.meaning, TernaryOutcome.positive)
        .withContext(
          const RecordedContext(
            subject: QuranDimension.meaning,
            polarity: 'positive',
            factorIds: ['energy'],
          ),
        );
    record = record.withQuran(QuranDimension.meaning, TernaryOutcome.negative);
    expect(record.contextFor(QuranDimension.meaning, 'positive'), isNull);
  });
}
