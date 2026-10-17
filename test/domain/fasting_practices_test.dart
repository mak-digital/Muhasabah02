import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/display_calendar.dart';
import 'package:muhasabah02/domain/fasting_practices.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/quran.dart';

DateTime _firstRamadan() {
  for (var i = 0; i < 400; i++) {
    final date = DateTime(2026, 1, 1).add(Duration(days: i));
    if (isCivilRamadan(date)) return date;
  }
  throw StateError('no civil Ramadan in sample window');
}

void main() {
  test('Fasting sits immediately after Dhikr', () {
    expect(
      MonitorDomain.values.indexOf(MonitorDomain.fasting),
      MonitorDomain.values.indexOf(MonitorDomain.dhikr) + 1,
    );
    expect(
      MonitorDomain.values.indexOf(MonitorDomain.akhlaq),
      MonitorDomain.values.indexOf(MonitorDomain.fasting) + 1,
    );
  });

  test(
    'Fasting V1 keeps voluntary ids and adds Ramadan and post-Ramadan rows',
    () {
      expect(fastingHomeRows.map((row) => row.storageKey), [
        kFastingRamadanObservedKey,
        kFastingRamadanConductKey,
        kFastingRamadanAttentionKey,
        kFastingRamadanQuranKey,
        kFastingRamadanSalahKey,
        kFastingRamadanExtraWorshipKey,
        kFastingRamadanHabitsKey,
        kFastingRamadanPracticeKey,
        kFastingWeeklySunnahKey,
        kFastingMonthlyKey,
        kFastingMakeupKey,
        kFastingRamadanPrepKey,
        kFastingPostRamadanKey,
      ]);
      expect(ActivityCatalog.forHomeTrace(kFastingWeeklySunnahKey), isEmpty);
      expect(ActivityCatalog.forHomeTrace(kFastingMonthlyKey), isEmpty);
      expect(ActivityCatalog.forHomeTrace(kFastingMakeupKey), isEmpty);
      expect(
        ActivityCatalog.forHomeTrace(kFastingRamadanObservedKey)
            .map((item) => item.label),
        [
          'Not recorded',
          "Completed today's fast",
          'Fasting today; not yet completed',
          'Did not fast due to a recognised exemption or genuine inability',
          'Fast was interrupted or ended early',
          'Did not fast for another reason',
          'Prefer not to record',
        ],
      );
      expect(
        ActivityCatalog.forHomeTrace(kFastingPostRamadanKey).first.label,
        'Not recorded',
      );
    },
  );

  test('not recorded stays distinct from prefer not and exemption', () {
    var record = writeFastingPractice(
      DailyCheckIn.empty('2026-02-20'),
      kFastingRamadanObservedKey,
      const FastingPracticeCapture(primaryId: FastingObservationIds.preferNot),
    );
    expect(record.homeTrace(kFastingRamadanObservedKey).isRecorded, isTrue);
    expect(
      record.activityFor(kFastingRamadanObservedKey).id,
      FastingObservationIds.preferNot,
    );

    record = writeFastingPractice(
      record,
      kFastingRamadanObservedKey,
      const FastingPracticeCapture(
        primaryId: 'fasting.ramadanObserved.exemption',
      ),
    );
    expect(
      fastingKindFor('fasting.ramadanObserved.exemption'),
      FastingResponseKind.constrained,
    );
    expect(record.homeTrace(kFastingRamadanObservedKey).isRecorded, isTrue);

    record = writeFastingPractice(
      record,
      kFastingRamadanObservedKey,
      const FastingPracticeCapture(),
    );
    expect(
      record.homeTrace(kFastingRamadanObservedKey),
      TernaryOutcome.unanswered,
    );
  });

  test('legacy noticed without an activity id is not remapped', () {
    final legacy = DailyCheckIn.empty('2026-02-20')
        .withHomeTrace(kFastingRamadanPrepKey, TernaryOutcome.positive);
    expect(
      legacy.activityFor(kFastingRamadanPrepKey).id,
      ActivityIds.unanswered,
    );
  });

  test(
    'Ramadan rows stay off outside Ramadan unless history or a leftover mark',
    () {
      final ramadan = _firstRamadan();
      final later = ramadan.add(const Duration(days: 40));
      expect(isCivilRamadan(ramadan), isTrue);
      expect(isCivilRamadan(later), isFalse);
      expect(showsFastingRamadanRows(date: ramadan), isTrue);
      expect(showsFastingRamadanRows(date: later), isFalse);
      expect(showsFastingRamadanRows(date: later, showHistory: true), isTrue);
      final leftover = writeFastingPractice(
        DailyCheckIn.empty('2026-09-03'),
        kFastingRamadanObservedKey,
        const FastingPracticeCapture(
          primaryId: 'fasting.ramadanObserved.completed',
        ),
      );
      expect(
        showsFastingRamadanRows(
          date: DateTime(2026, 9, 3),
          records: [leftover],
        ),
        isTrue,
      );
      expect(
        gateFastingHomeRows(
          fastingHomeRows,
          showRamadan: false,
        ).map((row) => row.storageKey),
        [
          kFastingWeeklySunnahKey,
          kFastingMonthlyKey,
          kFastingMakeupKey,
          kFastingRamadanPrepKey,
          kFastingPostRamadanKey,
        ],
      );
    },
  );
}
