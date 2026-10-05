import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('full check-in stage shows one domain and names the next', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.homeCheckIn));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(find.text('SALAH & PRAYER QUALITY'), findsOneWidget);
    expect(find.text('QUR’AN ENGAGEMENT'), findsNothing);
    expect(find.textContaining('Qur’an ›'), findsNothing);
    expect(find.byKey(const Key('checkin-domain-prev')), findsOneWidget);
    expect(find.byKey(const Key('checkin-domain-next')), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('checkin-domain-prev')))
          .onPressed,
      isNull,
    );
    expect(find.text(Copy.personalMixAlsoRecorded), findsNothing);

    await tester.tap(find.byKey(const Key('checkin-domain-next')));
    await tester.pumpAndSettle();
    expect(find.text('QUR’AN ENGAGEMENT'), findsOneWidget);
    expect(find.text('SALAH & PRAYER QUALITY'), findsNothing);
    expect(find.textContaining('‹ Salah'), findsNothing);

    await showCheckInDomain(tester, MonitorDomain.dhikr);
    expect(find.text('DHIKR & DUA'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('checkin-domain-next')))
          .onPressed,
      isNull,
    );
    expect(find.textContaining('Score'), findsNothing);
    expect(find.bySemanticsLabel(Copy.checkInDomainPillsNote), findsOneWidget);
  });

  testWidgets('full check-in hides chrome when only one domain is shown', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 3), visibleDomains: {MonitorDomain.salah}),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.homeCheckIn));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkin-domain-next')), findsNothing);
    expect(find.byKey(const Key('checkin-domain-pill-salah')), findsNothing);
    expect(find.text('SALAH & PRAYER QUALITY'), findsOneWidget);
  });
}
