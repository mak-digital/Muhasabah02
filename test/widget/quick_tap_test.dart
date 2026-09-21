import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('quick tap records fajr on time from Home', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final checkIns = MemoryCheckInRepository();
    await tester.pumpWidget(
      testApp(
        checkIns: checkIns,
        now: DateTime(2026, 9, 14),
        personalMix: mixForKind(PersonalMixKind.firstLook),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.quickTap));
    await tester.pumpAndSettle();
    expect(find.text(Copy.quickTapNote), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-salah.fajr')), findsOneWidget);
    expect(find.byKey(const Key('quick-tap-dhikr.generalDhikr')), findsNothing);
    await tester.tap(find.byKey(const Key('quick-tap-salah.fajr')));
    await tester.pumpAndSettle();
    final stored = await checkIns.getByDate('2026-09-14');
    expect(stored?.activityFor('salah.fajr').id, 'congregationOnTime');
    expect(stored?.prayer(PrayerId.fajr), PrayerStatus.onTime);
    expect(stored?.prayer(PrayerId.dhuhr), PrayerStatus.unanswered);
    expect(
      stored?.quranOutcome(QuranDimension.reading),
      TernaryOutcome.unanswered,
    );
  });
}
