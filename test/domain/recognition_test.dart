import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
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
}
