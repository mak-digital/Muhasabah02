import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/shared/activity_picker.dart';

import '../support/check_in_select.dart';
import '../support/home_domain_stage.dart';

void main() {
  testWidgets('salah factors appear by group from the prayer choice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(MemoryAppPrefs()),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Prayed alone on time',
    );
    expect(find.text('HELPING FACTORS'), findsOneWidget);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Missed',
    );
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('DISTRACTING FACTORS'), findsOneWidget);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Prayed late',
    );
    expect(find.text('HELPING FACTORS'), findsOneWidget);
    expect(find.text('DISTRACTING FACTORS'), findsOneWidget);

    final fajrChoice = tester.getTopLeft(find.byKey(const Key('salah-fajr')));
    final fajrHelping = tester.getTopLeft(
      find.byKey(const Key('salah-fajr-helping')),
    );
    expect(
      fajrHelping.dx - fajrChoice.dx,
      checkInNestedIndent - checkInValueIndent,
    );

    await tester.tap(find.byKey(const Key('salah-fajr-helping')));
    await tester.pumpAndSettle();
    expect(find.text('Slept early').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Not recorded').hitTestable());
    await tester.pumpAndSettle();
  });

  testWidgets('daytime salah omits Fajr sleep cues from factor lists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(MemoryAppPrefs()),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-dhuhr'),
      optionLabel: 'Prayed alone on time',
    );
    await tester.tap(find.byKey(const Key('salah-dhuhr-helping')));
    await tester.pumpAndSettle();
    expect(find.text('Slept early'), findsNothing);
    expect(find.text('Alarm worked'), findsNothing);
    expect(find.text('Reminder').hitTestable(), findsOneWidget);
  });

  testWidgets('charity Giving rows share one helping and distracting catalog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(MemoryAppPrefs()),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    await showCheckInDomain(tester, MonitorDomain.charity);

    Future<void> expectSharedHelping(String storageKey) async {
      await tester.scrollUntilVisible(
        find.byKey(Key('trace-$storageKey')),
        280,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await chooseCheckInOption(
        tester,
        dropdownKey: Key('trace-$storageKey'),
        optionLabel: traceOutcomeLabel(storageKey, TernaryOutcome.positive),
      );
      await tester.tap(find.byKey(Key('trace-$storageKey-helping')));
      await tester.pumpAndSettle();
      expect(find.text('Values & Beliefs').hitTestable(), findsOneWidget);
      expect(find.text('Relationships & Trust').hitTestable(), findsOneWidget);
      expect(find.text('Study circle'), findsNothing);
      expect(find.text('Strong Family Bonds & Affection'), findsNothing);
      expect(find.text('Religious/Moral Motivation'), findsNothing);
      await tester.tap(find.text('Not recorded').hitTestable());
      await tester.pumpAndSettle();
    }

    await expectSharedHelping('charity.voluntary');
    await expectSharedHelping('charity.householdGiving');
    await expectSharedHelping('charity.community');

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-charity.community'),
      optionLabel: traceOutcomeLabel(
        'charity.community',
        TernaryOutcome.negative,
      ),
    );
    await tester.tap(
      find.byKey(const Key('trace-charity.community-distracting')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Financial Constraints').hitTestable(), findsOneWidget);
    expect(find.text('Trust Deficits').hitTestable(), findsOneWidget);
    expect(
      find.text('Competing Priorities & Low Engagement').hitTestable(),
      findsOneWidget,
    );
    expect(find.text('Donor Fatigue'), findsNothing);
    expect(find.text('Individualism'), findsNothing);
    expect(find.text('Social media distraction'), findsNothing);
  });
}
