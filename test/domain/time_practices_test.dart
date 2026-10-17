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
      expect(
        [
          for (final row in timeHomeRows)
            ActivityCatalog.forHomeTrace(row.storageKey).first.label,
        ],
        [
          'Began an activity with a clear beneficial intention',
          'Prioritised an important responsibility or beneficial activity',
          'Gave meaningful attention to a task, person or act of worship',
          'Put away or silenced a digital device when attention was needed',
          'Completed a responsibility or task I had been unnecessarily delaying',
          'Used time meaningfully for worship, responsibility, learning or useful work',
          'Gave appropriate attention to someone who needed it',
          'Took appropriate rest or recovery when needed',
        ],
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
        primaryId: TimeObservationIds.acted,
        contextId: 'time.context.work',
        challengeId: 'time.challenge.phoneSocial',
        helpId: 'time.help.putDeviceAside',
        outcomeId: 'time.outcome.distractionReduced',
        quantityId: 'time.quantity.focusedMinutes',
        quantityText: '20',
        note: 'Put the phone down',
      ),
    );
    expect(record.homeTrace('time.t04'), TernaryOutcome.positive);
    expect(record.activityFor('time.t04').id, TimeObservationIds.acted);
    final stored = readTimePractice(record, 'time.t04');
    expect(stored.contextId, 'time.context.work');
    expect(stored.challengeId, 'time.challenge.phoneSocial');
    expect(stored.helpId, 'time.help.putDeviceAside');
    expect(stored.outcomeId, 'time.outcome.distractionReduced');
    expect(stored.quantityText, '20');
    expect(stored.note, 'Put the phone down');
    expect(
      timeEvidenceNote(record, 'time.t04'),
      contains('Work or professional responsibility'),
    );

    record = writeTimePractice(
      record,
      'time.t04',
      const TimePracticeCapture(primaryId: TimeObservationIds.noSituation),
    );
    expect(record.activityFor('time.t04').id, TimeObservationIds.noSituation);
    expect(record.homeTrace('time.t04').isRecorded, isTrue);
    expect(readTimePractice(record, 'time.t04').contextId, kFactorNotRecorded);

    record = writeTimePractice(record, 'time.t04', const TimePracticeCapture());
    expect(record.homeTrace('time.t04'), TernaryOutcome.unanswered);
    expect(record.activityFor('time.t04').id, ActivityIds.unanswered);
    expect(readTimePractice(record, 'time.t04').note, isEmpty);
  });

  test('Time primary catalog does not require secondary fields', () {
    expect(ActivityCatalog.forHomeTrace('time.t01').map((item) => item.id), [
      TimeObservationIds.acted,
      TimeObservationIds.partialEffort,
      TimeObservationIds.lapseRecognised,
      TimeObservationIds.corrected,
      TimeObservationIds.noSituation,
      ActivityIds.unanswered,
    ]);
    final record = writeTimePractice(
      DailyCheckIn.empty('2026-10-10'),
      'time.t01',
      const TimePracticeCapture(primaryId: TimeObservationIds.acted),
    );
    expect(record.homeTraceFactors['time.t01'], isNull);
  });

  test('legacy Time codes canonicalise without rewriting until edit', () {
    expect(
      canonicalizeTimeActivityId(ActivityIds.noticedNotActed),
      TimeObservationIds.lapseRecognised,
    );
    expect(
      canonicalizeTimeActivityId(ActivityIds.noSituation),
      TimeObservationIds.noSituation,
    );
    final record = DailyCheckIn.empty('2026-10-10').withActivity(
      'time.t03',
      const RecordedActivity(id: ActivityIds.noticedNotActed),
    );
    expect(
      record.activityFor('time.t03').id,
      TimeObservationIds.lapseRecognised,
    );
  });
}
