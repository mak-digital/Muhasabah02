import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

void main() {
  testWidgets('five salah prayers record independently without scores', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final checkIns = MemoryCheckInRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(checkIns),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
    expect(find.text(Copy.unansweredNotMissed), findsOneWidget);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.textContaining('iman'), findsNothing);
    expect(find.textContaining('rank'), findsNothing);

    await tester.tap(find.byKey(const Key('salah-fajr-onTime')));
    await tester.tap(find.byKey(const Key('salah-dhuhr-late')));
    await tester.tap(find.byKey(const Key('salah-asr-missed')));
    await tester.tap(find.byKey(const Key('salah-isha-onTime')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();

    final stored = await checkIns.allHealthy();
    expect(stored, hasLength(1));
    final record = stored.single;
    expect(record.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(record.prayer(PrayerId.dhuhr), PrayerStatus.late);
    expect(record.prayer(PrayerId.asr), PrayerStatus.missed);
    expect(record.prayer(PrayerId.maghrib), PrayerStatus.unanswered);
    expect(record.prayer(PrayerId.isha), PrayerStatus.onTime);
  });
}
