import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  final now = DateTime(2026, 9, 3);

  Future<void> pumpHome(
    WidgetTester tester, {
    MonitorDomain domain = MonitorDomain.dhikr,
  }) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        checkIns: MemoryCheckInRepository(),
        now: now,
        visibleDomains: allVisibleDomains(),
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, domain);
  }

  testWidgets('Dhikr Home cell opens that day’s entry ready to save', (
    tester,
  ) async {
    await pumpHome(tester);
    final today = find.byKey(const Key('home-compact-dhikr-2026-09-03'));
    await tester.scrollUntilVisible(
      today,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(today);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.dhikr.label} · 3 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    expect(find.text(Copy.edit), findsNothing);
    expect(find.text('Fajr'), findsWidgets);
  });

  testWidgets('past Dhikr Home cell stays locked until Edit', (tester) async {
    await pumpHome(tester);
    final past = find.byKey(const Key('home-compact-dhikr-2026-08-31'));
    await tester.scrollUntilVisible(
      past,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(past);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.dhikr.label} · 31 Aug 2026'),
      findsOneWidget,
    );
    expect(find.text(Copy.edit), findsWidgets);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.text(Copy.edit).last);
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('future Dhikr Home cell does not open entry', (tester) async {
    await pumpHome(tester);
    final future = find.byKey(const Key('home-compact-dhikr-2026-09-04'));
    await tester.scrollUntilVisible(
      future,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(future);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
  });

  testWidgets('Huquq Home cell opens that band and shows the date', (
    tester,
  ) async {
    await pumpHome(tester, domain: MonitorDomain.huquq);
    final repair = find.byKey(
      const Key('home-huquq.reconciliation-2026-09-03'),
    );
    await tester.scrollUntilVisible(
      repair,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(repair);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.huquq.label} · 3 Sep 2026'),
      findsOneWidget,
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('checkin-recording-date'))).data,
      '3 Sep 2026',
    );
    expect(find.text('A step toward reconciliation'), findsOneWidget);
    expect(find.text('Parents'), findsNothing);
    expect(find.text('Sick Visit'), findsNothing);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Huquq Household cell leaves later Huquq bands collapsed', (
    tester,
  ) async {
    await pumpHome(tester, domain: MonitorDomain.huquq);
    final household = find.byKey(const Key('home-huquq.parents-2026-09-03'));
    await tester.scrollUntilVisible(
      household,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(household);
    await tester.pumpAndSettle();
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('A step toward reconciliation'), findsNothing);
    expect(find.text('Sick Visit'), findsNothing);
  });

  testWidgets('past Huquq cell shows that day’s date', (tester) async {
    await pumpHome(tester, domain: MonitorDomain.huquq);
    final past = find.byKey(const Key('home-huquq.parents-2026-08-31'));
    await tester.scrollUntilVisible(
      past,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(past);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('checkin-recording-date'))).data,
      '31 Aug 2026',
    );
    expect(find.text(Copy.edit), findsWidgets);
  });
}
