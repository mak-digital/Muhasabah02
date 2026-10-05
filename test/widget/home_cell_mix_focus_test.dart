import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  final now = DateTime(2026, 9, 20);

  PersonalMix householdMix() {
    return mixForKind(
      PersonalMixKind.custom,
      customKeys: {
        'salah.fajr',
        'salah.isha',
        'huquq.spouse',
        'huquq.children',
        'dhikr.postFardFajr',
        'dhikr.morningAdhkar',
      },
    );
  }

  Future<void> pumpHome(WidgetTester tester, {PersonalMix? mix}) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: now,
        visibleDomains: allVisibleDomains(),
        personalMix: mix ?? householdMix(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Huquq Home cell check-in follows mix and omits unused rows', (
    tester,
  ) async {
    await pumpHome(tester);
    await showHomeDomain(tester, MonitorDomain.huquq);
    final spouse = find.byKey(const Key('home-huquq.spouse-2026-09-20'));
    await tester.scrollUntilVisible(
      spouse,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(spouse);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.text('Spouse'), findsWidgets);
    expect(find.text('Children'), findsOneWidget);
    expect(find.text('Parents'), findsNothing);
    expect(find.text('Siblings'), findsNothing);
    expect(find.text('A step toward reconciliation'), findsNothing);
    expect(find.text('Sick Visit'), findsNothing);
  });

  testWidgets('focused Huquq check-in scrolls to the tapped Children row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(now),
        ],
        child: MaterialApp(
          home: CheckInScreen(
            date: now,
            focus: CheckInFocus.traces,
            domainTitle: MonitorDomain.huquq.label,
            focusBand: 'Household',
            focusRowId: 'huquq.children',
            traceRows: huquqHomeRows,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('trace-huquq.children')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('trace-huquq.parents')).hitTestable(),
      findsNothing,
    );
  });

  testWidgets('Salah Home cell check-in follows mix and opens Isha', (
    tester,
  ) async {
    await pumpHome(tester);
    await showHomeDomain(tester, MonitorDomain.salah);
    final isha = find.byKey(const Key('salah-home-isha-2026-09-20'));
    await tester.ensureVisible(isha);
    await tester.tap(isha);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.text('Tahajjud'), findsNothing);
    expect(find.text('Dhuhr'), findsNothing);
    expect(find.byKey(const Key('salah-isha')), findsOneWidget);
  });

  testWidgets('Dhikr Home cell check-in follows mix', (tester) async {
    await pumpHome(tester);
    await showHomeDomain(tester, MonitorDomain.dhikr);
    final fajr = find.byKey(const Key('home-dhikr.postFardFajr-2026-09-20'));
    await tester.scrollUntilVisible(
      fajr,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(fajr);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.byKey(const Key('trace-dhikr.postFardFajr')), findsOneWidget);
    expect(find.text('General Dhikr'), findsNothing);
    expect(find.text('Gratitude Dhikr'), findsNothing);
  });
}
