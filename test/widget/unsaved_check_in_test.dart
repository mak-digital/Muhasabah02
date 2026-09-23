import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/data/repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/other_domains.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

import '../support/check_in_select.dart';
import '../support/controllable_check_in_repository.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    DateTime Function()? clock,
    DateTime? now,
    MemoryCheckInRepository? checkIns,
    CheckInRepository? checkInRepository,
  }) async {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        clock: clock,
        now: now ?? (clock == null ? DateTime(2026, 9, 3) : null),
        checkIns: checkIns,
        checkInRepository: checkInRepository,
        visibleDomains: allVisibleDomains(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openFull(WidgetTester tester) async {
    await tester.tap(find.text(Copy.homeCheckIn));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
  }

  Future<void> dirtyFajr(WidgetTester tester) async {
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Prayed alone on time',
    );
    await tester.pumpAndSettle();
  }

  testWidgets('clean AppBar Back closes without confirmation', (tester) async {
    await pumpHome(tester);
    await openFull(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect(find.text(Copy.unsavedCheckInTitle), findsNothing);
  });

  testWidgets('dirty AppBar Back shows one confirmation dialog', (
    tester,
  ) async {
    await pumpHome(tester);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedCheckInTitle), findsOneWidget);
    expect(find.byType(CheckInScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
  });

  testWidgets('dirty system Back shows confirmation', (tester) async {
    await pumpHome(tester);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedCheckInTitle), findsOneWidget);
  });

  testWidgets('Continue editing keeps the draft', (tester) async {
    await pumpHome(tester);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.unsavedCheckInContinue));
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedCheckInTitle), findsNothing);
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.text('Prayed alone on time'), findsWidgets);
  });

  testWidgets('Discard does not persist', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, checkIns: checkIns);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.unsavedCheckInDiscard));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect(await checkIns.allHealthy(), isEmpty);
  });

  testWidgets('dialog Save persists exactly once', (tester) async {
    final repo = ControllableCheckInRepository();
    await pumpHome(tester, checkInRepository: repo);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.unsavedCheckInSave));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect(repo.saveCount, 1);
    final stored = await repo.inner.allHealthy();
    expect(stored.single.dateKey, '2026-09-03');
    expect(stored.single.prayer(PrayerId.fajr), PrayerStatus.onTime);
  });

  testWidgets('ordinary Save still works', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, checkIns: checkIns);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.ensureVisible(find.text('Save check-in'));
    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect(find.text(Copy.unsavedCheckInTitle), findsNothing);
    expect((await checkIns.allHealthy()).single.dateKey, '2026-09-03');
  });

  testWidgets('failed Save retains editor and draft', (tester) async {
    final repo = ControllableCheckInRepository()..throwOnSave = true;
    await pumpHome(tester, checkInRepository: repo);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.ensureVisible(find.text('Save check-in'));
    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.text('The check-in could not be saved. Your draft is still here.'),
      findsOneWidget,
    );
    expect(await repo.inner.allHealthy(), isEmpty);
  });

  testWidgets('Back during in-flight save cannot dismiss', (tester) async {
    final repo = ControllableCheckInRepository()..saveGate = Completer<void>();
    await pumpHome(tester, checkInRepository: repo);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.ensureVisible(find.text('Save check-in'));
    await tester.tap(find.text('Save check-in'));
    await tester.pump();
    await tester.pageBack();
    await tester.pump();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.text(Copy.unsavedCheckInTitle), findsNothing);
    expect(repo.saveCount, 1);
    repo.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
  });

  testWidgets('duplicate Save cannot write twice', (tester) async {
    final repo = ControllableCheckInRepository()..saveGate = Completer<void>();
    await pumpHome(tester, checkInRepository: repo);
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.ensureVisible(find.text('Save check-in'));
    await tester.tap(find.text('Save check-in'));
    await tester.pump();
    await tester.tap(find.text('Save check-in'));
    await tester.pump();
    expect(repo.saveCount, 1);
    repo.saveGate!.complete();
    await tester.pumpAndSettle();
    expect((await repo.inner.allHealthy()).length, 1);
  });

  testWidgets('historical focused check-in uses the same protection', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, now: DateTime(2026, 9, 3), checkIns: checkIns);
    await tester.tap(find.byKey(const Key('salah-home-fajr-2026-09-01')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    await tester.tap(find.text(Copy.edit).last);
    await tester.pumpAndSettle();
    await dirtyFajr(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedCheckInTitle), findsOneWidget);
    await tester.tap(find.text(Copy.unsavedCheckInSave));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect((await checkIns.allHealthy()).single.dateKey, '2026-09-01');
  });

  testWidgets('History-opened check-in uses the same protection', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(sampleDay('2026-09-03'));
    await pumpHome(tester, checkIns: checkIns, now: DateTime(2026, 9, 6));
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('history-day-2026-09-03')));
    await tester.pumpAndSettle();
    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Missed',
    );
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(Copy.unsavedCheckInTitle), findsOneWidget);
    await tester.tap(find.text(Copy.unsavedCheckInDiscard));
    await tester.pumpAndSettle();
    expect(
      (await checkIns.getByDate('2026-09-03'))!.prayer(PrayerId.fajr),
      PrayerStatus.onTime,
    );
  });

  testWidgets('midnight rollover keeps dirty editor and original dateKey', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpHome(tester, clock: () => clock, checkIns: checkIns);
    await openFull(tester);
    await dirtyFajr(tester);
    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.text(Copy.unsavedCheckInTitle), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.textContaining('22 Sep 2026'), findsWidgets);
    await tester.tap(find.text(Copy.unsavedCheckInSave));
    await tester.pumpAndSettle();
    expect((await checkIns.allHealthy()).single.dateKey, '2026-09-22');
    expect(await checkIns.getByDate('2026-09-23'), isNull);
  });

  testWidgets('date refresh without edits remains clean', (tester) async {
    var clock = DateTime(2026, 9, 22, 12);
    await pumpHome(tester, clock: () => clock);
    await openFull(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
    expect(find.text(Copy.unsavedCheckInTitle), findsNothing);
  });

  testWidgets(
    'late hydration keeps the user edit and unrelated stored fields',
    (tester) async {
      tester.view.physicalSize = const Size(400, 3600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final inner = MemoryCheckInRepository();
      await inner.save(
        DailyCheckIn.empty('2026-09-03')
            .withPrayer(PrayerId.asr, PrayerStatus.missed)
            .copyWith(
              gratitudeStatus: EntryStatus.recorded,
              gratitudeText: 'Kept gratitude',
              personalReflectionStatus: EntryStatus.recorded,
              personalReflectionText: 'Kept reflection',
            ),
      );
      final repo = ControllableCheckInRepository(inner: inner)
        ..hydrateGate = Completer<void>();
      final now = DateTime(2026, 9, 3);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checkInRepositoryProvider.overrideWithValue(repo),
            nowClockProvider.overrideWithValue(() => now),
            nowProvider.overrideWithValue(now),
            appPrefsProvider.overrideWithValue(
              MemoryAppPrefs(visibleDomains: allVisibleDomains()),
            ),
          ],
          child: MaterialApp(home: CheckInScreen(date: now)),
        ),
      );
      await tester.pump();
      await dirtyFajr(tester);
      repo.hydrateGate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Prayed alone on time'), findsWidgets);
      await tester.ensureVisible(find.text('Save check-in'));
      await tester.tap(find.text('Save check-in'));
      await tester.pumpAndSettle();
      final stored = await inner.getByDate('2026-09-03');
      expect(stored!.prayer(PrayerId.fajr), PrayerStatus.onTime);
      expect(stored.prayer(PrayerId.asr), PrayerStatus.missed);
      expect(stored.gratitudeText, 'Kept gratitude');
      expect(stored.personalReflectionText, 'Kept reflection');
    },
  );

  testWidgets('Save stays above a 48dp system inset', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 3), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await openFull(tester);
    expect(
      tester.getRect(find.byKey(const Key('checkin-save'))).bottom,
      lessThanOrEqualTo(900 - 48),
    );
  });

  testWidgets('situation note and draft dialog stay above keyboard inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 3), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await openFull(tester);
    await dirtyFajr(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('checkin-situation-custom')),
      400,
      scrollable: find
          .descendant(
            of: find.byType(CheckInScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const Key('checkin-situation-custom')), findsOneWidget);
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('unsaved-check-in-dialog')), findsOneWidget);
    expect(
      tester.getRect(find.text(Copy.unsavedCheckInContinue)).bottom,
      lessThanOrEqualTo(900 - 280),
    );
  });
}
