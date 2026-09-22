import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

import '../support/check_in_select.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpClock(
    WidgetTester tester,
    DateTime Function() clock, {
    MemoryCheckInRepository? checkIns,
    PersonalMix? personalMix,
  }) async {
    tester.view.physicalSize = const Size(400, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        clock: clock,
        checkIns: checkIns,
        personalMix: personalMix,
        visibleDomains: allVisibleDomains(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openHomeSalahCell(WidgetTester tester, String dateKey) async {
    final ink = tester.widget<InkWell>(
      find
          .ancestor(
            of: find.byKey(Key('salah-home-fajr-$dateKey')),
            matching: find.byType(InkWell),
          )
          .first,
    );
    ink.onTap!.call();
    await tester.pumpAndSettle();
  }

  Future<void> openProgressFajrCell(WidgetTester tester, String dateKey) async {
    final cell = tester.widget<ProgressDayCell>(
      find.byKey(Key('progress-cell-salah-fajr-$dateKey')).first,
    );
    cell.onTap!.call();
    await tester.pumpAndSettle();
  }

  testWidgets('Home foreground timer rollover enables the new-day week cell', (
    tester,
  ) async {
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpClock(tester, () => clock);
    expect(find.textContaining('22 Sep 2026'), findsWidgets);

    await openHomeSalahCell(tester, '2026-09-23');
    expect(find.byType(CheckInScreen), findsNothing);

    clock = DateTime(2026, 9, 23, 0, 3);
    await tester.pump(
      delayUntilNextLocalMidnight(DateTime(2026, 9, 22, 23, 58)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('23 Sep 2026'), findsWidgets);
    expect(find.textContaining('Wednesday'), findsWidgets);

    await openHomeSalahCell(tester, '2026-09-23');
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.textContaining('23 Sep 2026'), findsWidgets);
  });

  testWidgets('late Home tap recovers when the midnight timer did not run', (
    tester,
  ) async {
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpClock(tester, () => clock);

    clock = DateTime(2026, 9, 23, 0, 3);
    await tester.pump();
    expect(find.textContaining('22 Sep 2026'), findsWidgets);

    await openHomeSalahCell(tester, '2026-09-23');
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.textContaining('23 Sep 2026'), findsWidgets);
  });

  testWidgets('historical Home cell keeps its date after rollover', (
    tester,
  ) async {
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpClock(tester, () => clock);

    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    await openHomeSalahCell(tester, '2026-09-21');
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.textContaining('21 Sep 2026'), findsWidgets);
  });

  testWidgets('future Home cell stays non-navigable before its date', (
    tester,
  ) async {
    await pumpClock(tester, () => DateTime(2026, 9, 22, 12));
    await openHomeSalahCell(tester, '2026-09-24');
    expect(find.byType(CheckInScreen), findsNothing);
  });

  testWidgets('Today Domain grouping resets for the new local day', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty(
        '2026-09-22',
      ).withSalahActivity(PrayerId.fajr, const RecordedActivity(id: 'missed')),
    );
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpClock(tester, () => clock, checkIns: checkIns);
    await tester.tap(find.byKey(const Key('today-domain-salah')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-recorded-section')), findsOneWidget);

    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.textContaining('Wednesday'), findsWidgets);
    expect(find.byKey(const Key('today-recorded-section')), findsNothing);
    expect(await checkIns.getByDate('2026-09-22'), isNotNull);
    expect(await checkIns.getByDate('2026-09-23'), isNull);
  });

  testWidgets('7D/30D/90D windows and taps follow the new local day', (
    tester,
  ) async {
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpClock(tester, () => clock);

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-domain-salah')));
    await tester.pumpAndSettle();

    await openProgressFajrCell(tester, '2026-09-23');
    expect(find.byType(CheckInScreen), findsNothing);

    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    await openProgressFajrCell(tester, '2026-09-23');
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.textContaining('23 Sep 2026'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('30 days'));
    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-today-2026-09-23')), findsWidgets);
    expect(find.byKey(const Key('calendar-today-2026-09-22')), findsNothing);

    await openProgressFajrCell(tester, '2026-09-22');
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.textContaining('22 Sep 2026'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('90 days'));
    await tester.tap(find.text('90 days'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-today-2026-09-23')), findsWidgets);
  });

  testWidgets('multi-day clock jump uses the current local date', (
    tester,
  ) async {
    var clock = DateTime(2026, 9, 20, 9);
    await pumpClock(tester, () => clock);
    expect(find.textContaining('20 Sep 2026'), findsWidgets);

    clock = DateTime(2026, 9, 23, 11);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.textContaining('23 Sep 2026'), findsWidgets);
  });

  testWidgets('date jump that stands in for a timezone transition refreshes', (
    tester,
  ) async {
    var clock = DateTime(2026, 9, 22, 21);
    await pumpClock(tester, () => clock);
    clock = DateTime(2026, 9, 23, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.textContaining('23 Sep 2026'), findsWidgets);
  });

  testWidgets('Quick Tap new session saves the refreshed date', (tester) async {
    final checkIns = MemoryCheckInRepository();
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpClock(
      tester,
      () => clock,
      checkIns: checkIns,
      personalMix: mixForKind(PersonalMixKind.firstLook),
    );

    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    await tester.tap(find.text(Copy.quickTap));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick-tap-salah.fajr')));
    await tester.pumpAndSettle();
    expect(await checkIns.getByDate('2026-09-23'), isNotNull);
    expect(await checkIns.getByDate('2026-09-22'), isNull);
  });

  testWidgets('open Quick Tap sheet keeps its captured date after midnight', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpClock(
      tester,
      () => clock,
      checkIns: checkIns,
      personalMix: mixForKind(PersonalMixKind.firstLook),
    );
    await tester.tap(find.text(Copy.quickTap));
    await tester.pumpAndSettle();

    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quick-tap-salah.fajr')));
    await tester.pumpAndSettle();
    expect(await checkIns.getByDate('2026-09-22'), isNotNull);
    expect(await checkIns.getByDate('2026-09-23'), isNull);
  });

  testWidgets('full check-in keeps one captured dateKey across rollover', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpClock(tester, () => clock, checkIns: checkIns);

    await tester.tap(find.text(Copy.homeCheckIn));
    await tester.pumpAndSettle();
    expect(find.textContaining('Check-in · 22 Sep 2026'), findsOneWidget);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Prayed alone on time',
    );

    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.textContaining('Check-in · 22 Sep 2026'), findsOneWidget);
    expect(find.textContaining('Check-in · 23 Sep 2026'), findsNothing);

    await tester.ensureVisible(find.text('Save check-in'));
    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();

    final stored = await checkIns.allHealthy();
    expect(stored.single.dateKey, '2026-09-22');
    expect(stored.single.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(await checkIns.getByDate('2026-09-23'), isNull);
  });
}
