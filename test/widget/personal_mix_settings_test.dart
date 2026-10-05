import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/presentation/settings/settings_screen.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('settings open Domains mix and copy a named starting set', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 14000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 10)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.visibleDomains));
    expect(find.textContaining('Mix: Same as Domains'), findsOneWidget);
    await tester.tap(find.text(Copy.visibleDomains));
    await tester.pumpAndSettle();
    expect(find.byType(VisibleDomainsSettingsScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(Copy.thisSeasonsMix),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(Copy.personalMixNote), findsOneWidget);
    expect(find.text(Copy.personalMixShortListNote), findsOneWidget);
    expect(find.text(Copy.mixNotShownInDomains), findsOneWidget);
    expect(find.byKey(const Key('mix-domain-dhikr')), findsOneWidget);
    expect(find.byKey(const Key('mix-domain-hajj')), findsOneWidget);
    await tester.ensureVisible(find.text(PersonalMixKind.worship.label));
    await tester.tap(find.text(PersonalMixKind.worship.label));
    await tester.pump();
    expect(find.text(Copy.mixKeptUntilDomainsShown), findsOneWidget);
    ScaffoldMessenger.of(
      tester.element(find.byType(VisibleDomainsSettingsScreen)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(VisibleDomainsSettingsScreen)))
        .pop();
    await tester.pumpAndSettle();
    expect(find.textContaining(PersonalMixKind.worship.label), findsWidgets);
  });

  testWidgets('Home season line appears for a named mix', (tester) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 10),
        personalMix: mixForKind(PersonalMixKind.worship),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining(Copy.personalMixSeasonPrefix), findsOneWidget);
    expect(find.text(MonitorDomain.salah.label), findsWidgets);
    expect(find.text('Fajr'), findsWidgets);
    expect(find.text('Tahajjud'), findsNothing);
    expect(find.text(MonitorDomain.akhlaq.label), findsNothing);
    expect(find.text('Charity'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
  });

  testWidgets('check-in keeps mix domains first and folds the rest', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 10),
        personalMix: mixForKind(PersonalMixKind.worship),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.homeCheckIn));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkin-domain-next')), findsOneWidget);
    expect(find.textContaining('Qur’an ›'), findsNothing);
    expect(find.text(Copy.personalMixAlsoRecorded), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
  });
}
