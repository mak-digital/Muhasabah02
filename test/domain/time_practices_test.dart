import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/factor_groups.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/time_practices.dart';

void main() {
  test(
    'Time V1 catalogue is eight independent practices in daily-life order',
    () {
      expect(timePractices.length, 8);
      expect(timePractices.map((item) => item.practiceId).toList(), [
        'time_t01',
        'time_t02',
        'time_t03',
        'time_t04',
        'time_t05',
        'time_t06',
        'time_t07',
        'time_t08',
      ]);
      expect(timePractices.map((item) => item.sectionId).toSet(), {
        kTimeIntentionSectionId,
        kTimeAttentionSectionId,
        kTimeActionSectionId,
        kTimeBalanceSectionId,
      });
      expect(
        timeHomeRows.map((row) => row.storageKey),
        timePractices.map((item) => item.storageKey),
      );
    },
  );

  test('unanswered stays distinct from an explicit Time observation', () {
    const empty = TimePracticeCapture();
    expect(empty.isPrimaryRecorded, isFalse);

    var record = DailyCheckIn.empty('2026-10-10');
    expect(record.homeTrace('time.t04'), TernaryOutcome.unanswered);
    expect(readTimePractice(record, 'time.t04').isPrimaryRecorded, isFalse);

    record = writeTimePractice(
      record,
      'time.t04',
      const TimePracticeCapture(
        primaryId: ActivityIds.acted,
        contextId: 'notifications',
        outcomeId: 'avoided',
        note: 'Put the phone down',
      ),
    );
    expect(record.homeTrace('time.t04'), TernaryOutcome.positive);
    expect(record.activityFor('time.t04').id, ActivityIds.acted);
    final stored = readTimePractice(record, 'time.t04');
    expect(stored.contextId, 'notifications');
    expect(stored.outcomeId, 'avoided');
    expect(stored.note, 'Put the phone down');

    record = writeTimePractice(
      record,
      'time.t04',
      const TimePracticeCapture(primaryId: ActivityIds.noSituation),
    );
    expect(record.activityFor('time.t04').id, ActivityIds.noSituation);
    expect(record.homeTrace('time.t04').isRecorded, isTrue);
    expect(readTimePractice(record, 'time.t04').contextId, kFactorNotRecorded);

    record = writeTimePractice(record, 'time.t04', const TimePracticeCapture());
    expect(record.homeTrace('time.t04'), TernaryOutcome.unanswered);
    expect(record.activityFor('time.t04').id, ActivityIds.unanswered);
    expect(readTimePractice(record, 'time.t04').note, isEmpty);
  });

  test('Time primary catalog does not require secondary fields', () {
    expect(ActivityCatalog.forHomeTrace('time.t01').map((item) => item.id), [
      ActivityIds.acted,
      ActivityIds.noticedNotActed,
      ActivityIds.noSituation,
      ActivityIds.unanswered,
    ]);
    final record = writeTimePractice(
      DailyCheckIn.empty('2026-10-10'),
      'time.t01',
      const TimePracticeCapture(primaryId: ActivityIds.acted),
    );
    expect(record.homeTraceFactors['time.t01'], isNull);
  });
}
