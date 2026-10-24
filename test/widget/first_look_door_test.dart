import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/presentation/home/home_screen.dart';
import 'package:muhasabah02/presentation/shared/brand_mark.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('first-look door states the recorder and offers a quiet week', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = MemoryAppPrefs(applicationReflectionAcknowledged: false);
    final checkIns = MemoryCheckInRepository();
    await tester.pumpWidget(
      testApp(prefs: prefs, checkIns: checkIns, now: DateTime(2026, 9, 13)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BrandMark), findsWidgets);
    expect(find.text(Copy.appName), findsOneWidget);
    expect(find.text(Copy.appSlogan), findsWidgets);
    expect(find.text(Copy.appNotice), findsWidgets);
    expect(find.text(Copy.applicationReflectionIntroTitle), findsNothing);
    expect(find.text(Copy.firstLookDoorTitle), findsOneWidget);
    expect(find.text(Copy.firstLookDoorPrivate), findsOneWidget);
    expect(find.text(Copy.firstLookDoorEmpty), findsOneWidget);
    expect(find.text(Copy.firstLookDoorSeason), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    await tester.tap(find.text(Copy.firstLookStartBlank));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(prefs.applicationReflectionAcknowledged, isTrue);
    expect(prefs.sampleSeeded, isTrue);
    expect(prefs.sampleRemovedByUser, isFalse);
    expect(prefs.personalMix.kind, PersonalMixKind.firstLook);
    expect(await checkIns.allHealthy(), isEmpty);
  });

  testWidgets('first-look door can show sample days after the user chooses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = MemoryAppPrefs(applicationReflectionAcknowledged: false);
    final checkIns = MemoryCheckInRepository();
    await tester.pumpWidget(
      testApp(prefs: prefs, checkIns: checkIns, now: DateTime(2026, 9, 13)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.firstLookShowSample));
    await tester.pump();
    // Seed then Home loads records. decodeStoredCheckIns yields with
    // Future.delayed(Duration.zero); flush those timers. Do not
    // pumpAndSettle: a progress indicator never goes idle, and a
    // Duration(minutes: 1) argument is the frame interval, not a timeout.
    for (var i = 0; i < 12; i++) {
      await tester.pump(Duration.zero);
    }
    expect(prefs.applicationReflectionAcknowledged, isTrue);
    expect(prefs.personalMix.kind, PersonalMixKind.firstLook);
    final records = await tester.runAsync(checkIns.allHealthy);
    expect(records, isNotEmpty);
    expect(records!.every((record) => record.synthetic), isTrue);
  });
}
