import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/device_unlock.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quick_tap.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/today_workspace.dart';
import 'package:muhasabah02/presentation/home/today_row_record.dart';
import 'package:muhasabah02/presentation/shared/domain_visual.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';
import 'package:muhasabah02/presentation/shared/system_insets.dart';

import '../support/check_in_select.dart';
import '../support/fake_device_unlock.dart';
import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    DateTime? now,
    DateTime Function()? clock,
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
        now: now ?? (clock == null ? DateTime(2026, 9, 22) : null),
        clock: clock,
        visibleDomains: visibleDomains,
        personalMix: personalMix,
        checkIns: checkIns,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openDomain(WidgetTester tester, String id) async {
    await expandActiveDomainMix(tester);
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

  testWidgets('tapping Dhikr keeps Today identity', (tester) async {
    await pumpHome(tester);
    await openDomain(tester, 'dhikr');
    expect(find.byKey(const Key('today-workspace-dhikr')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('today-workspace-dhikr')),
        matching: find.text('Dhikr'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today-row-dhikr.morningAdhkar')),
      findsOneWidget,
    );
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
    expect(find.byKey(const Key('today-domain-akhlaq')), findsNothing);
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
    await pumpHome(tester, visibleDomains: allVisibleDomains());
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
      optionLabel: 'Engaged more than 20 minutes — Engagement',
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
      optionLabel: 'I did not notice this today — Engagement',
    );
    await tester.pumpAndSettle();
    expect(
      (await checkIns.getByDate('2026-09-22'))
          ?.quranOutcome(QuranDimension.reading),
      TernaryOutcome.negative,
    );
  });

  testWidgets('Dhikr negative observation is recorded and editable', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'dhikr');
    await tester.tap(find.byKey(const Key('today-row-dhikr.morningAdhkar')));
    await tester.pumpAndSettle();
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-trace-dhikr.morningAdhkar'),
      optionLabel: traceOutcomeLabel(
        'dhikr.morningAdhkar',
        TernaryOutcome.negative,
      ),
    );
    expect(
      (await checkIns.getByDate('2026-09-22'))
          ?.homeTrace('dhikr.morningAdhkar'),
      TernaryOutcome.negative,
    );
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-trace-dhikr.morningAdhkar'),
      optionLabel: traceOutcomeLabel(
        'dhikr.morningAdhkar',
        TernaryOutcome.positive,
      ),
    );
    expect(
      (await checkIns.getByDate('2026-09-22'))
          ?.homeTrace('dhikr.morningAdhkar'),
      TernaryOutcome.positive,
    );
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('today-row-dhikr.morningAdhkar')),
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
    expect(marker.size, 18);
    final unansweredShape =
        tester
                .widget<Material>(
                  find.descendant(
                    of: find.byKey(const Key('today-row-salah.fajr')),
                    matching: find.byType(Material),
                  ),
                )
                .shape!
            as RoundedRectangleBorder;
    expect(unansweredShape.borderRadius, BorderRadius.circular(12));
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
              find.byKey(const Key('today-row-marker-salah.fajr')),
            )
            .size,
        18,
      );
      final recordedShape =
          tester
                  .widget<Material>(
                    find.descendant(
                      of: find.byKey(const Key('today-row-salah.fajr')),
                      matching: find.byType(Material),
                    ),
                  )
                  .shape!
              as RoundedRectangleBorder;
      expect(recordedShape.borderRadius, BorderRadius.circular(12));
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

  testWidgets('Dhikr explicit negative remains Recorded', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-22')
          .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.negative),
    );
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'dhikr');
    expect(
      find.descendant(
        of: find.byKey(const Key('today-row-dhikr.morningAdhkar')),
        matching: find.text(Copy.todayRecorded),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('today-row-marker-dhikr.morningAdhkar')),
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

  Future<void> openConsumedTodaySheet(
    WidgetTester tester, {
    required TodayRow row,
    required Key control,
    DateTime? now,
    double keyboard = 0,
  }) async {
    final date = now ?? DateTime(2026, 9, 22);
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    if (keyboard > 0) {
      tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    if (keyboard > 0) addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          responseRepositoryProvider.overrideWithValue(
            MemoryResponseRepository(),
          ),
          deviceUnlockProvider.overrideWithValue(FakeDeviceUnlock()),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(
              applicationReflectionAcknowledged: true,
              visibleDomains: allVisibleDomains(),
            ),
          ),
          nowClockProvider.overrideWithValue(() => date),
          nowProvider.overrideWithValue(date),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(400, 1200),
              devicePixelRatio: 1,
              viewInsets: keyboard > 0
                  ? EdgeInsets.only(bottom: keyboard)
                  : EdgeInsets.zero,
            ),
            child: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return TextButton(
                    key: const Key('open-today-sheet'),
                    onPressed: () {
                      showTodayRowRecordSheet(
                        context: context,
                        ref: ref,
                        row: row,
                        dateKey: dateKey(date),
                        record: null,
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-today-sheet')));
    await tester.pumpAndSettle();
    expect(find.byKey(control), findsOneWidget);
    final ceiling = 1200 - (keyboard > 0 ? keyboard : 48);
    expect(
      tester.getRect(find.byKey(control)).bottom,
      lessThanOrEqualTo(ceiling),
    );
  }

  testWidgets('Dhuhr sheet clears a consumed 48dp system inset', (
    tester,
  ) async {
    await openConsumedTodaySheet(
      tester,
      row: const TodayRow(
        mixId: 'salah.dhuhr',
        domain: MonitorDomain.salah,
        kind: TodayRowKind.salah,
        recordedState: TodayRecordedState.noResponse,
      ),
      control: const Key('today-salah-dhuhr'),
    );
  });

  testWidgets('Qur’an sheet clears a consumed 48dp system inset', (
    tester,
  ) async {
    await openConsumedTodaySheet(
      tester,
      row: const TodayRow(
        mixId: 'quran.reading',
        domain: MonitorDomain.quran,
        kind: TodayRowKind.quran,
        recordedState: TodayRecordedState.noResponse,
      ),
      control: const Key('today-quran-reading'),
    );
  });

  testWidgets('Jumu‘ah sheet clears a consumed 48dp system inset on Friday', (
    tester,
  ) async {
    await openConsumedTodaySheet(
      tester,
      now: DateTime(2026, 9, 18),
      row: const TodayRow(
        mixId: 'salah.jumuah',
        domain: MonitorDomain.salah,
        kind: TodayRowKind.salah,
        recordedState: TodayRecordedState.noResponse,
      ),
      control: const Key('today-salah-jumuah'),
    );
  });

  testWidgets('Ishraq sheet clears a consumed 48dp system inset', (
    tester,
  ) async {
    await openConsumedTodaySheet(
      tester,
      row: const TodayRow(
        mixId: 'salah.ishraq',
        domain: MonitorDomain.salah,
        kind: TodayRowKind.salah,
        recordedState: TodayRecordedState.noResponse,
      ),
      control: const Key('today-salah-ishraq'),
    );
  });

  testWidgets('Jumu‘ah sheet uses keyboard inset instead of stacking it', (
    tester,
  ) async {
    await openConsumedTodaySheet(
      tester,
      now: DateTime(2026, 9, 18),
      keyboard: 280,
      row: const TodayRow(
        mixId: 'salah.jumuah',
        domain: MonitorDomain.salah,
        kind: TodayRowKind.salah,
        recordedState: TodayRecordedState.noResponse,
      ),
      control: const Key('today-salah-jumuah'),
    );
  });

  testWidgets('all unanswered rows stay prominent without a Recorded section', (
    tester,
  ) async {
    await pumpHome(tester);
    await openDomain(tester, 'salah');
    expect(find.byKey(const Key('today-recorded-section')), findsNothing);
    expect(find.text(Copy.todayRecordedToday), findsNothing);
    expect(find.text(Copy.todayRecordedForToday), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.dhuhr'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.dhuhr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.asr'))).dy,
      ),
    );
  });

  testWidgets('missed and on-time Salah compact in catalog order', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-22')
          .withSalahActivity(
            PrayerId.fajr,
            const RecordedActivity(id: 'missed'),
          )
          .withSalahActivity(
            PrayerId.dhuhr,
            const RecordedActivity(id: 'aloneOnTime'),
          ),
    );
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    expect(find.text(Copy.todayRecordedToday), findsOneWidget);
    expect(find.text(Copy.todayRecordedForToday), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.asr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.maghrib'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.dhuhr'))).dy,
      ),
    );
    expect(
      tester.getRect(find.byKey(const Key('today-row-salah.fajr'))).height,
      lessThan(
        tester.getRect(find.byKey(const Key('today-row-salah.asr'))).height,
      ),
    );
    expect(
      tester.getRect(find.byKey(const Key('today-row-salah.fajr'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('today-row-marker-salah.fajr')),
          )
          .kind,
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('today-row-marker-salah.dhuhr')),
          )
          .kind,
    );
  });

  testWidgets('late and excused Salah compact like any recorded row', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-22')
          .withSalahActivity(
            PrayerId.asr,
            const RecordedActivity(id: 'prayedLate'),
          )
          .withSalahActivity(
            PrayerId.maghrib,
            const RecordedActivity(id: 'excused'),
          ),
    );
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.asr'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.asr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.maghrib'))).dy,
      ),
    );
  });

  testWidgets('recording a prominent row moves it to compact immediately', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    expect(find.byKey(const Key('today-recorded-section')), findsNothing);
    await tester.tap(find.byKey(const Key('today-row-salah.fajr')));
    await tester.pumpAndSettle();
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-salah-fajr'),
      optionLabel: 'Missed',
    );
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();
    expect(find.text(Copy.todayRecordedToday), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.dhuhr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      ),
    );
  });

  testWidgets('editing a compact row keeps it recorded', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty(
        '2026-09-22',
      ).withSalahActivity(PrayerId.fajr, const RecordedActivity(id: 'missed')),
    );
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    await tester.tap(find.byKey(const Key('today-row-salah.fajr')));
    await tester.pumpAndSettle();
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-salah-fajr'),
      optionLabel: 'Prayed alone on time',
    );
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();
    expect(find.text(Copy.todayRecordedToday), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.dhuhr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      ),
    );
  });

  testWidgets('resetting Salah to unanswered returns the row to prominent', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty(
        '2026-09-22',
      ).withSalahActivity(PrayerId.fajr, const RecordedActivity(id: 'missed')),
    );
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    await tester.tap(find.byKey(const Key('today-row-salah.fajr')));
    await tester.pumpAndSettle();
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('today-salah-fajr'),
      optionLabel: 'No answer recorded',
    );
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-recorded-section')), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.dhuhr'))).dy,
      ),
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('today-row-marker-salah.fajr')),
          )
          .kind,
      MarkerKind.outlined,
    );
  });

  testWidgets('all recorded Salah uses a neutral heading', (tester) async {
    var record = DailyCheckIn.empty('2026-09-22');
    for (final prayer in PrayerId.values) {
      record = record.withSalahActivity(
        prayer,
        const RecordedActivity(id: 'missed'),
      );
    }
    record = record.copyWith(
      tahajjud: TernaryOutcome.negative,
      ishraq: TernaryOutcome.positive,
    );
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(record);
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    expect(find.text(Copy.todayRecordedForToday), findsOneWidget);
    expect(find.text(Copy.todayNoResponseYet), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('complete'), findsNothing);
    expect(find.textContaining('Perfect'), findsNothing);
  });

  testWidgets('Qur’an duration rows stay independent in Today', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-22')
          .withQuran(QuranDimension.reading, TernaryOutcome.positive)
          .withQuran(QuranDimension.meaning, TernaryOutcome.positive),
    );
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'quran');
    expect(find.text(Copy.todayRecordedToday), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-quran.reading'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-quran.meaning'))).dy,
      ),
    );
  });

  testWidgets('explicit Zakat status compacts as recorded', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-22').copyWith(zakat: ZakatStatus.due),
    );
    await pumpHome(
      tester,
      checkIns: checkIns,
      visibleDomains: allVisibleDomains(),
    );
    await openDomain(tester, 'charity');
    expect(find.text(Copy.todayRecordedToday), findsOneWidget);
    expect(find.text(Copy.todayRecordedForToday), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('today-row-zakat')),
        matching: find.text(Copy.todayRecorded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Quick Tap Fajr appears compact in the Salah workspace', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    final empty = DailyCheckIn.empty('2026-09-22');
    final item = quickTapItemsFor({'salah.fajr'}).single;
    final next = nextQuickTapChoice(empty, item);
    await checkIns.save(applyQuickTapChoice(empty, item, next));
    await pumpHome(tester, checkIns: checkIns);
    await openDomain(tester, 'salah');
    expect(
      (await checkIns.getByDate('2026-09-22'))?.prayer(PrayerId.fajr),
      isNot(PrayerStatus.unanswered),
    );
    expect(find.text(Copy.todayRecordedToday), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.dhuhr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      ),
    );
  });

  testWidgets('new local date does not keep yesterday’s recorded grouping', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty(
        '2026-09-22',
      ).withSalahActivity(PrayerId.fajr, const RecordedActivity(id: 'missed')),
    );
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpHome(tester, clock: () => clock, checkIns: checkIns);
    await openDomain(tester, 'salah');
    expect(find.text(Copy.todayRecordedToday), findsOneWidget);
    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.textContaining('Wednesday'), findsWidgets);
    expect(find.byKey(const Key('today-recorded-section')), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const Key('today-row-salah.fajr'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('today-row-salah.dhuhr'))).dy,
      ),
    );
  });
}
