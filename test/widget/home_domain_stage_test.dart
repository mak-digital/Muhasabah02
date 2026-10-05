import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('Home stage shows one domain and names the next', (tester) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
    await tester.pumpAndSettle();
    expect(find.text(MonitorDomain.salah.label), findsWidgets);
    expect(find.text(MonitorDomain.quran.label), findsNothing);
    expect(find.byKey(const Key('home-domain-prev')), findsOneWidget);
    expect(find.byKey(const Key('home-domain-next')), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('home-domain-prev')))
          .onPressed,
      isNull,
    );
    expect(find.textContaining('Qur’an ›'), findsNothing);

    final prevBefore = tester.getRect(find.byKey(const Key('home-domain-prev')));
    final nextBefore = tester.getRect(find.byKey(const Key('home-domain-next')));
    expect(prevBefore.width, nextBefore.width);
    expect(prevBefore.height, nextBefore.height);
    expect(prevBefore.top, nextBefore.top);

    await tester.tap(find.byKey(const Key('home-domain-next')));
    await tester.pumpAndSettle();
    expect(find.text(MonitorDomain.quran.label), findsWidgets);
    expect(find.text(MonitorDomain.salah.label), findsNothing);
    expect(find.text(MonitorDomain.quran.shortLabel), findsWidgets);
    expect(find.textContaining('‹ Salah'), findsNothing);
    expect(find.textContaining('Hadith ›'), findsNothing);
    expect(
      tester.getRect(find.byKey(const Key('home-domain-prev'))).left,
      prevBefore.left,
    );
    expect(
      tester.getRect(find.byKey(const Key('home-domain-next'))).right,
      nextBefore.right,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('home-domain-prev')))
          .onPressed,
      isNotNull,
    );

    await showHomeDomain(tester, MonitorDomain.dhikr);
    expect(find.text(MonitorDomain.dhikr.label), findsWidgets);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('home-domain-next')))
          .onPressed,
      isNull,
    );
    expect(find.textContaining('Score'), findsNothing);
    expect(find.bySemanticsLabel(Copy.homeDomainPillsNote), findsOneWidget);
  });

  testWidgets('Home stage hides chrome when only one domain is shown', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 3),
        visibleDomains: {MonitorDomain.salah},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-domain-next')), findsNothing);
    expect(find.byKey(const Key('home-domain-pill-salah')), findsNothing);
    expect(find.text(MonitorDomain.salah.label), findsWidgets);
  });
}
