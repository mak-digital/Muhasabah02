import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/settings/settings_screen.dart';

import '../support/fake_device_unlock.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('app lock gate stays closed until device unlock succeeds', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 10),
        appLockEnabled: true,
        deviceUnlock: FakeDeviceUnlock(succeeds: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(Copy.appLockTitle), findsOneWidget);
    expect(find.text(Copy.homeCheckIn), findsNothing);
  });

  testWidgets('successful device unlock shows Home', (tester) async {
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 10),
        appLockEnabled: true,
        deviceUnlock: FakeDeviceUnlock(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(Copy.appLockTitle), findsNothing);
    expect(find.text(Copy.homeCheckIn), findsOneWidget);
  });

  testWidgets('privacy explains on-device storage and optional device lock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final unlock = FakeDeviceUnlock();
    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 10), deviceUnlock: unlock),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.onDeviceStorage));
    await tester.tap(find.text(Copy.onDeviceStorage));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacySettingsScreen), findsOneWidget);
    expect(find.text(Copy.appLockTitle), findsOneWidget);
    expect(find.textContaining('does not encrypt'), findsWidgets);
    expect(find.textContaining('encryption-at-rest'), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(unlock.authenticateCalls, 1);
    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.value, isTrue);
  });

  testWidgets('app lock stays off when the device has no credential', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 10),
        deviceUnlock: FakeDeviceUnlock(available: false),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.onDeviceStorage));
    await tester.tap(find.text(Copy.onDeviceStorage));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(find.text(Copy.appLockUnavailable), findsOneWidget);
    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.value, isFalse);
  });
}
