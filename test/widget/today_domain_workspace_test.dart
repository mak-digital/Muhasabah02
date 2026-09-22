import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/today_workspace.dart';
import 'package:muhasabah02/presentation/shared/domain_visual.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';
import 'package:muhasabah02/presentation/shared/system_insets.dart';

import '../support/check_in_select.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    DateTime? now,
    Set<MonitorDomain>? visibleDomains,
    PersonalMix? personalMix,
    MemoryCheckInRepository? checkIns,
  }) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: now ?? DateTime(2026, 9, 22),
        visibleDomains: visibleDomains,
        personalMix: personalMix,
        checkIns: checkIns,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openDomain(WidgetTester tester, String id) async {
    await tester.ensureVisible(find.byKey(Key('today-domain-$id')));
    await tester.tap(find.byKey(Key('today-domain-$id')));
    await tester.pumpAndSettle();
  }

  test('Today child labels are explicit, not stripped parent names', () {
    expect(
      todayRowLabel(
        const TodayRow(
          mixId: 'dhikr.morningAdhkar',
          domain: MonitorDomain.dhikr,
          kind: TodayRowKind.homeTrace,
          recordedState: TodayRecordedState.noResponse,
        ),
      ),
      'Morning',
    );
    expect(
      todayRowLabel(
        const TodayRow(
          mixId: 'dhikr.postFardFajr',
          domain: MonitorDomain.dhikr,
          kind: TodayRowKind.homeTrace,
          recordedState: TodayRecordedState.noResponse,
        ),
      ),
      'Fajr',
    );
    expect(
      todayRowLabel(
        const TodayRow(
          mixId: 'salah.fajr',
          domain: MonitorDomain.salah,
          kind: TodayRowKind.salah,
          recordedState: TodayRecordedState.noResponse,
        ),
      ),
      'Fajr',
    );
    expect(
      todayRowLabel(
        const TodayRow(
          mixId: 'zakat',
          domain: MonitorDomain.charity,
          kind: TodayRowKind.zakatStatus,
          recordedState: TodayRecordedState.noResponse,
        ),
      ),
      'Zakat',
    );
  });

  testWidgets('tapping Salah opens the Salah Today workspace', (tester) async {
    await pumpHome(tester);
    await openDomain(tester, 'salah');
    expect(find.byKey(const Key('today-workspace-salah')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('today-workspace-salah')),
        matching: find.text('Salah'),
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppBar, 'Salah'), findsNothing);
    expect(find.textContaining('Tuesday'), findsWidgets);
    expect(find.byKey(const Key('today-row-salah.fajr')), findsOneWidget);
    expect(find.byKey(const Key('today-row-salah.dhuhr')), findsOneWidget);
    expect(find.byKey(const Key('today-row-salah.jumuah')), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('complete'), findsNothing);
  });

  testWidgets('tapping Qur’an opens selected dimensions only', (tester) async {
    await pumpHome(tester);
    await openDomain(tester, 'quran');
    expect(find.byKey(const Key('today-workspace-quran')), findsOneWidget);
    expect(find.text('Qur’an'), findsWidgets);
    expect(find.byKey(const Key('today-row-quran.reading')), findsOneWidget);
    expect(find.byKey(const Key('today-row-quran.meaning')), findsOneWidget);
    expect(find.text('Application Reflection'), findsNothing);
  });

  testWidgets('tapping Akhlaq and Huquq keeps Today identities', (
    tester,
  ) async {
    await pumpHome(tester);
    await openDomain(tester, 'akhlaq');
    expect(find.byKey(const Key('today-workspace-akhlaq')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('today-workspace-akhlaq')),
        matching: find.text('Akhlaq'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('today-row-akhlaq.patience')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await openDomain(tester, 'huquq');
    expect(find.byKey(const Key('today-workspace-huquq')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('today-workspace-huquq')),
        matching: find.text('Huquq'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('today-row-huquq.parents')), findsOneWidget);
  });

  testWidgets('back from a domain workspace returns to Home', (tester) async {
    await pumpHome(tester);
    await openDomain(tester, 'salah');
    expect(find.byKey(const Key('today-workspace-salah')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-workspace-salah')), findsNothing);
    expect(find.byKey(const Key('today-overview')), findsOneWidget);
    expect(find.text(Copy.homeCheckIn), findsOneWidget);
  });

  testWidgets('hidden domains remain unavailable from Today', (tester) async {
    await pumpHome(tester);
    expect(find.byKey(const Key('today-domain-dhikr')), findsNothing);
    expect(find.byKey(const Key('today-domain-hajj')), findsNothing);
  });

  testWidgets('Dhikr workspace uses contextual child labels', (tester) async {
    await pumpHome(tester, visibleDomains: allVisibleDomains());
    await openDomain(tester, 'dhikr');
    expect(find.byKey(const Key('today-workspace-dhikr')), findsOneWidget);
    expect(
      find.byKey(const Key('today-row-dhikr.postFardFajr')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today-row-dhikr.morningAdhkar')),
      findsOneWidget,
    );
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Evening'), findsOneWidget);
    expect(find.text('Dhikr (Fajr)'), findsNothing);
    expect(find.text('General Dhikr'), findsNothing);
  });

  testWidgets('Hajj standing status is not a daily row', (tester) async {
    await pumpHome(tester, visibleDomains: allVisibleDomains());
    await openDomain(tester, 'hajj');
    expect(find.byKey(const Key('today-workspace-hajj')), findsOneWidget);
    expect(find.byKey(const Key('today-row-hajj')), findsNothing);
    expect(find.byKey(const Key('today-row-hajj.preparation')), findsNothing);
  });

  testWidgets('Jumu‘ah appears on Friday Salah workspace only', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 9, 18));
    await openDomain(tester, 'salah');
    expect(find.byKey(const Key('today-row-salah.jumuah')), findsOneWidget);
  });

  testWidgets('Charity presents Zakat as status, not a daily task', (
    tester,
  ) async {
    await pumpHome(tester);
    await openDomain(tester, 'charity');
    expect(find.byKey(const Key('today-row-zakat')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('today-row-zakat')),
        matching: find.text(Copy.todayNoResponseYet),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('incomplete'), findsNothing);
  });

  testWidgets('opening a domain workspace does not create a check-in', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    expect(find.byKey(const Key('today-workspace-salah')), findsOneWidget);
    expect(await checkIns.allHealthy(), isEmpty);
  });

  testWidgets('missed Salah saves and can be edited without reopening', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    await tester.tap(find.byKey(const Key('today-row-salah.fajr')));
    await tester.pumpAndSettle();
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-salah-fajr'),
      optionLabel: 'Missed',
    );
    expect(
      (await checkIns.getByDate('2026-09-22'))?.prayer(PrayerId.fajr),
      PrayerStatus.missed,
    );
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-salah-fajr'),
      optionLabel: 'Prayed alone on time',
    );
    await tester.pumpAndSettle();
    expect(
      (await checkIns.getByDate('2026-09-22'))?.prayer(PrayerId.fajr),
      PrayerStatus.onTime,
    );
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('today-row-salah.fajr')),
        matching: find.text(Copy.todayRecorded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Qur’an positive and negative save through existing path', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'quran');
    await tester.tap(find.byKey(const Key('today-row-quran.reading')));
    await tester.pumpAndSettle();
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-quran-reading'),
      optionLabel: 'Listening',
    );
    await tester.pumpAndSettle();
    expect(
      (await checkIns.getByDate('2026-09-22'))
          ?.quranOutcome(QuranDimension.reading),
      TernaryOutcome.positive,
    );
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-quran-reading'),
      optionLabel: 'No activity',
    );
    await tester.pumpAndSettle();
    expect(
      (await checkIns.getByDate('2026-09-22'))
          ?.quranOutcome(QuranDimension.reading),
      TernaryOutcome.negative,
    );
  });

  testWidgets('Akhlaq negative observation is recorded and editable', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'akhlaq');
    await tester.tap(find.byKey(const Key('today-row-akhlaq.patience')));
    await tester.pumpAndSettle();
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-trace-akhlaq.patience'),
      optionLabel: 'I did not notice this today — Patience',
    );
    expect(
      (await checkIns.getByDate('2026-09-22'))?.homeTrace('akhlaq.patience'),
      TernaryOutcome.negative,
    );
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-trace-akhlaq.patience'),
      optionLabel: 'I noticed this in myself — Patience',
    );
    expect(
      (await checkIns.getByDate('2026-09-22'))?.homeTrace('akhlaq.patience'),
      TernaryOutcome.positive,
    );
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('today-row-akhlaq.patience')),
        matching: find.text(Copy.todayRecorded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('no-response rows use hollow markers and No response yet', (
    tester,
  ) async {
    await pumpHome(tester);
    await openDomain(tester, 'salah');
    expect(
      find.descendant(
        of: find.byKey(const Key('today-row-salah.fajr')),
        matching: find.text(Copy.todayNoResponseYet),
      ),
      findsOneWidget,
    );
    final marker = tester.widget<RecordedStateMarker>(
      find.byKey(const Key('today-row-marker-salah.fajr')),
    );
    expect(marker.kind, MarkerKind.outlined);
    expect(
      tester.getSemantics(find.byKey(const Key('today-row-salah.fajr'))).label,
      'Fajr, no response yet',
    );
    expect(find.textContaining('incomplete'), findsNothing);
    expect(find.textContaining('successful'), findsNothing);
  });

  testWidgets(
    'recorded positive and missed share the same response-present state',
    (tester) async {
      final checkIns = MemoryCheckInRepository();
      await checkIns.save(
        DailyCheckIn.empty('2026-09-22')
            .withSalahActivity(
              PrayerId.fajr,
              const RecordedActivity(id: 'aloneOnTime'),
            )
            .withSalahActivity(
              PrayerId.dhuhr,
              const RecordedActivity(id: 'missed'),
            ),
      );
      await pumpHome(tester, checkIns: checkIns);
      await openDomain(tester, 'salah');
      expect(
        find.descendant(
          of: find.byKey(const Key('today-row-salah.fajr')),
          matching: find.text(Copy.todayRecorded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('today-row-salah.dhuhr')),
          matching: find.text(Copy.todayRecorded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('today-row-salah.asr')),
          matching: find.text(Copy.todayNoResponseYet),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<RecordedStateMarker>(
              find.byKey(const Key('today-row-marker-salah.fajr')),
            )
            .kind,
        MarkerKind.filled,
      );
      expect(
        tester
            .widget<RecordedStateMarker>(
              find.byKey(const Key('today-row-marker-salah.dhuhr')),
            )
            .kind,
        MarkerKind.filled,
      );
      expect(
        tester
            .widget<RecordedStateMarker>(
              find.byKey(const Key('today-row-marker-salah.asr')),
            )
            .kind,
        MarkerKind.outlined,
      );
      expect(
        tester
            .getSemantics(find.byKey(const Key('today-row-salah.fajr')))
            .label,
        'Fajr, response recorded',
      );
      expect(
        tester
            .getSemantics(find.byKey(const Key('today-row-salah.dhuhr')))
            .label,
        'Dhuhr, response recorded',
      );
    },
  );

  testWidgets('Akhlaq explicit negative remains Recorded', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-22')
          .withHomeTrace('akhlaq.patience', TernaryOutcome.negative),
    );
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'akhlaq');
    expect(
      find.descendant(
        of: find.byKey(const Key('today-row-akhlaq.patience')),
        matching: find.text(Copy.todayRecorded),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('today-row-marker-akhlaq.patience')),
          )
          .kind,
      MarkerKind.filled,
    );
  });

  testWidgets('last Dhikr row stays above a simulated system bottom inset', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await pumpHome(tester, visibleDomains: allVisibleDomains());
    await openDomain(tester, 'dhikr');
    final list = tester.widget<ListView>(
      find.descendant(
        of: find.byKey(const Key('today-workspace-dhikr')),
        matching: find.byType(ListView),
      ),
    );
    expect(list.padding, const EdgeInsets.fromLTRB(16, 12, 16, 64));
    await tester.scrollUntilVisible(
      find.byKey(const Key('today-row-dhikr.otherAdhkar')),
      200,
      scrollable: find.descendant(
        of: find.byKey(const Key('today-workspace-dhikr')),
        matching: find.byType(Scrollable),
      ),
    );
    final rowBottom = tester
        .getRect(find.byKey(const Key('today-row-dhikr.otherAdhkar')))
        .bottom;
    expect(rowBottom, lessThanOrEqualTo(1200 - 48));
    expect(
      tester
          .getRect(find.byKey(const Key('today-row-dhikr.otherAdhkar')))
          .height,
      greaterThan(40),
    );
  });

  testWidgets('recording sheet keeps the selector above the system inset', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await pumpHome(tester);
    await openDomain(tester, 'salah');
    await tester.tap(find.byKey(const Key('today-row-salah.fajr')));
    await tester.pumpAndSettle();
    final control = find.byKey(const Key('today-salah-fajr'));
    expect(control, findsOneWidget);
    expect(tester.getRect(control).bottom, lessThanOrEqualTo(1200 - 48));
  });

  testWidgets('recording sheet uses keyboard inset instead of stacking it', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    await pumpHome(tester);
    await openDomain(tester, 'salah');
    await tester.tap(find.byKey(const Key('today-row-salah.fajr')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-salah-fajr')), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const Key('today-salah-fajr'))).bottom,
      lessThanOrEqualTo(1200 - 280),
    );
  });

  testWidgets('contentBottomInset does not use a fixed oversized spacer', (
    tester,
  ) async {
    late double closed;
    late double open;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(bottom: 48),
          viewPadding: EdgeInsets.only(bottom: 48),
        ),
        child: Builder(
          builder: (context) {
            closed = contentBottomInset(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(closed, 64);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(bottom: 48),
          viewPadding: EdgeInsets.only(bottom: 48),
          viewInsets: EdgeInsets.only(bottom: 300),
        ),
        child: Builder(
          builder: (context) {
            open = contentBottomInset(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(open, 316);
  });
}
