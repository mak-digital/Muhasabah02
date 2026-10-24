import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/theme.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/domain/app_appearance.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/settings/settings_screen.dart';
import 'package:muhasabah02/presentation/shared/domain_visual.dart';
import 'package:muhasabah02/presentation/shared/week_nav_strip.dart';

import '../support/test_app.dart';

void main() {
  Future<void> openAppearance(
    WidgetTester tester, {
    MemoryAppPrefs? prefs,
  }) async {
    tester.view.physicalSize = const Size(400, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApp(prefs: prefs));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.appearance));
    await tester.tap(find.text(Copy.appearance));
    await tester.pumpAndSettle();
    expect(find.byType(AppearanceSettingsScreen), findsOneWidget);
  }

  testWidgets('appearance lists every named look', (tester) async {
    await openAppearance(tester);
    expect(find.text(Copy.appearanceNote), findsOneWidget);
    for (final look in AppAppearance.values) {
      expect(find.text(look.label), findsWidgets);
    }
  });

  testWidgets('Warm paper is stored and paints cream paper', (tester) async {
    final prefs = MemoryAppPrefs();
    await openAppearance(tester, prefs: prefs);
    await tester.tap(find.text(AppAppearance.warmPaper.label));
    await tester.pumpAndSettle();
    expect(prefs.appearance, AppAppearance.warmPaper);
    expect(
      Theme.of(tester.element(find.byType(AppearanceSettingsScreen)))
          .scaffoldBackgroundColor,
      MuhasabahPalette.warmPaper.surface,
    );
  });

  testWidgets('Quiet slate and Midnight apply and persist', (tester) async {
    final prefs = MemoryAppPrefs();
    await openAppearance(tester, prefs: prefs);
    await tester.tap(find.text(AppAppearance.quietSlate.label));
    await tester.pumpAndSettle();
    expect(prefs.appearance, AppAppearance.quietSlate);
    expect(
      Theme.of(tester.element(find.byType(AppearanceSettingsScreen)))
          .scaffoldBackgroundColor,
      MuhasabahPalette.quietSlate.surface,
    );
    await tester.ensureVisible(find.text(AppAppearance.midnight.label));
    await tester.tap(find.text(AppAppearance.midnight.label));
    await tester.pumpAndSettle();
    expect(prefs.appearance, AppAppearance.midnight);
    expect(
      Theme.of(tester.element(find.byType(AppearanceSettingsScreen)))
          .scaffoldBackgroundColor,
      MuhasabahPalette.midnight.surface,
    );
  });

  testWidgets('stored Midnight is used on launch', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(prefs: MemoryAppPrefs(appearance: AppAppearance.midnight)),
    );
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first))
          .scaffoldBackgroundColor,
      MuhasabahPalette.midnight.surface,
    );
  });

  testWidgets('Warm paper blends domain washes toward cream paper', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(prefs: MemoryAppPrefs(appearance: AppAppearance.warmPaper)),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold).first);
    final identity = domainColorIdentity(MonitorDomain.salah);
    final wash = identity.washFor(Theme.of(context).brightness, context);
    expect(wash, isNot(MuhasabahColors.salahWash));
    expect(
      identity.practiceWashFor(Theme.of(context).brightness, context),
      isNot(MuhasabahColors.practiceWash),
    );
    expect(identity.familyFor(context), isNot(identity.family));
    expect(
      bandHeadingWash(
        MuhasabahColors.salahFamily,
        MuhasabahColors.salahWash,
        context,
      ),
      isNot(
        bandHeadingWash(MuhasabahColors.salahFamily, MuhasabahColors.salahWash),
      ),
    );
  });
}
