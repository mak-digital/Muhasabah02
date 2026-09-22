import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/device_unlock.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/date_key.dart';
import 'package:muhasabah02/presentation/lock/app_lock_gate.dart';
import 'package:muhasabah02/presentation/shared/current_date_binder.dart';

import '../support/fake_device_unlock.dart';
import '../support/test_app.dart';

void main() {
  group('localCalendarDateChanged', () {
    test('same local date is not a change', () {
      expect(
        localCalendarDateChanged(
          DateTime(2026, 9, 22, 9),
          DateTime(2026, 9, 22, 14),
        ),
        isFalse,
      );
    });

    test('next local date is a change', () {
      expect(
        localCalendarDateChanged(
          DateTime(2026, 9, 22, 23, 58),
          DateTime(2026, 9, 23, 0, 3),
        ),
        isTrue,
      );
    });

    test('multi-day gap is a change to the current date, not one day', () {
      expect(
        localCalendarDateChanged(
          DateTime(2026, 9, 20, 9),
          DateTime(2026, 9, 23, 9),
        ),
        isTrue,
      );
      expect(dateKey(DateTime(2026, 9, 23, 9)), '2026-09-23');
    });
  });

  group('nextLocalMidnight', () {
    test('uses the following local calendar day, not a 24-hour offset', () {
      final now = DateTime(2026, 9, 22, 23, 58);
      expect(nextLocalMidnight(now), DateTime(2026, 9, 23));
      expect(
        delayUntilNextLocalMidnight(now),
        const Duration(minutes: 2) + kLocalMidnightTimerMargin,
      );
    });

    test('same-day afternoon still targets that night’s midnight', () {
      final now = DateTime(2026, 9, 22, 15, 30);
      expect(nextLocalMidnight(now), DateTime(2026, 9, 23));
    });
  });

  group('resume date refresh', () {
    testWidgets('same local date keeps cached now', (tester) async {
      var clock = DateTime(2026, 9, 22, 9);
      final probe = _NowProbe();
      await tester.pumpWidget(_clockApp(() => clock, probe: probe));
      await tester.pump();
      final first = probe.now!;
      expect(dateKey(first), '2026-09-22');

      clock = DateTime(2026, 9, 22, 14);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(probe.now, same(first));
      expect(dateKey(probe.now!), '2026-09-22');
    });

    testWidgets('next local date refreshes nowProvider', (tester) async {
      var clock = DateTime(2026, 9, 22, 23, 58);
      final probe = _NowProbe();
      await tester.pumpWidget(_clockApp(() => clock, probe: probe));
      await tester.pump();
      expect(dateKey(probe.now!), '2026-09-22');

      clock = DateTime(2026, 9, 23, 0, 3);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(dateKey(probe.now!), '2026-09-23');
    });

    testWidgets('multi-day resume uses the current local date', (tester) async {
      var clock = DateTime(2026, 9, 20, 9);
      final probe = _NowProbe();
      await tester.pumpWidget(_clockApp(() => clock, probe: probe));
      await tester.pump();
      expect(dateKey(probe.now!), '2026-09-20');

      clock = DateTime(2026, 9, 23, 11);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(dateKey(probe.now!), '2026-09-23');
    });

    testWidgets('injected now stays deterministic after resume', (
      tester,
    ) async {
      final injected = DateTime(2026, 9, 3, 8);
      await tester.pumpWidget(testApp(now: injected));
      await tester.pumpAndSettle();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      final context = tester.element(find.byType(CurrentDateBinder));
      final now = ProviderScope.containerOf(context).read(nowProvider);
      expect(now, injected);
      expect(dateKey(now), '2026-09-03');
    });

    testWidgets('date refresh does not create a DailyCheckIn', (tester) async {
      var clock = DateTime(2026, 9, 22, 23, 58);
      final checkIns = MemoryCheckInRepository();
      final probe = _NowProbe();
      await tester.pumpWidget(
        _clockApp(() => clock, probe: probe, checkIns: checkIns),
      );
      await tester.pump();

      clock = DateTime(2026, 9, 23, 0, 3);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(dateKey(probe.now!), '2026-09-23');
      expect(await checkIns.allHealthy(), isEmpty);
    });

    testWidgets('resume refreshes date while lock gate stays closed', (
      tester,
    ) async {
      var clock = DateTime(2026, 9, 22, 23, 58);
      final probe = _NowProbe();
      await tester.pumpWidget(
        _clockApp(
          () => clock,
          probe: probe,
          appLockEnabled: true,
          deviceUnlock: FakeDeviceUnlock(succeeds: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(Copy.appLockTitle), findsOneWidget);
      expect(dateKey(probe.now!), '2026-09-22');

      clock = DateTime(2026, 9, 23, 0, 3);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(dateKey(probe.now!), '2026-09-23');
      expect(find.text(Copy.appLockTitle), findsOneWidget);
    });
  });

  group('foreground midnight timer', () {
    testWidgets('fires after local midnight without resume', (tester) async {
      var clock = DateTime(2026, 9, 22, 23, 58);
      final probe = _NowProbe();
      await tester.pumpWidget(_clockApp(() => clock, probe: probe));
      await tester.pump();
      expect(dateKey(probe.now!), '2026-09-22');
      final first = probe.now;

      clock = DateTime(2026, 9, 23, 0, 3);
      await tester.pump(delayUntilNextLocalMidnight(DateTime(2026, 9, 22, 23, 58)));
      await tester.pump();

      expect(dateKey(probe.now!), '2026-09-23');
      expect(probe.now, isNot(same(first)));
    });

    testWidgets('same-date timer fire does not invalidate twice', (tester) async {
      var clock = DateTime(2026, 9, 22, 23, 58);
      final probe = _NowProbe();
      await tester.pumpWidget(_clockApp(() => clock, probe: probe));
      await tester.pump();

      clock = DateTime(2026, 9, 23, 0, 3);
      await tester.pump(delayUntilNextLocalMidnight(DateTime(2026, 9, 22, 23, 58)));
      await tester.pump();
      final refreshed = probe.now;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(probe.now, same(refreshed));
    });
  });
}

class _NowProbe {
  DateTime? now;
}

Widget _clockApp(
  DateTime Function() clock, {
  required _NowProbe probe,
  MemoryCheckInRepository? checkIns,
  bool appLockEnabled = false,
  DeviceUnlock? deviceUnlock,
}) {
  return ProviderScope(
    overrides: [
      nowClockProvider.overrideWithValue(clock),
      checkInRepositoryProvider.overrideWithValue(
        checkIns ?? MemoryCheckInRepository(),
      ),
      responseRepositoryProvider.overrideWithValue(MemoryResponseRepository()),
      deviceUnlockProvider.overrideWithValue(
        deviceUnlock ?? FakeDeviceUnlock(),
      ),
      appPrefsProvider.overrideWithValue(
        MemoryAppPrefs(appLockEnabled: appLockEnabled),
      ),
    ],
    child: CurrentDateBinder(
      child: Consumer(
        builder: (context, ref, _) {
          probe.now = ref.watch(nowProvider);
          if (appLockEnabled) {
            return MaterialApp(
              home: AppLockGate(child: const SizedBox.shrink()),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}
