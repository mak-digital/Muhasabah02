import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/progress/optional_domain_progress_screen.dart';
import 'package:muhasabah02/presentation/progress/salah_progress_screen.dart';
import 'package:muhasabah02/presentation/shared/ui_bits.dart';

import '../support/test_app.dart';

void main() {
  Finder verticalList(Finder host) {
    return find.descendant(of: host, matching: find.byType(ListView));
  }

  Future<void> openSalahProgress(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-domain-salah')));
    await tester.pumpAndSettle();
  }

  testWidgets('Salah Review pins the period selector while calendars scroll', (
    tester,
  ) async {
    await openSalahProgress(tester);

    expect(find.byType(SalahProgressScreen), findsOneWidget);
    expect(find.byType(PeriodSelector), findsOneWidget);
    expect(find.text(Copy.progressMarksTitle), findsOneWidget);
    expect(find.text('Prayed on time'), findsOneWidget);
    expect(find.text(MonitorDomain.salah.focusQuestion!), findsOneWidget);

    final pinnedTop = tester.getTopLeft(find.byType(PeriodSelector)).dy;
    await tester.drag(
      verticalList(find.byType(SalahProgressScreen)),
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PeriodSelector), findsOneWidget);
    expect(tester.getTopLeft(find.byType(PeriodSelector)).dy, pinnedTop);
    expect(find.text(MonitorDomain.salah.focusQuestion!), findsOneWidget);
  });

  testWidgets('Salah Review marks collapse on period change and reopen', (
    tester,
  ) async {
    await openSalahProgress(tester);
    expect(find.text('Prayed on time'), findsOneWidget);

    await tester.tap(find.text('90 days'));
    await tester.pumpAndSettle();
    expect(find.text('Prayed on time'), findsNothing);

    await tester.tap(find.text(Copy.progressMarksTitle));
    await tester.pumpAndSettle();
    expect(find.text('Prayed on time'), findsOneWidget);
  });

  testWidgets('Salah Review marks collapse when a cell is opened', (
    tester,
  ) async {
    await openSalahProgress(tester);
    expect(find.text('Prayed on time'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('progress-cell-salah-fajr-2026-09-06')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Prayed on time'), findsNothing);
    expect(find.text(Copy.progressMarksTitle), findsOneWidget);
  });

  testWidgets('Huquq Review pins the period and collapses About this domain', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('review-domain-huquq')));
    await tester.tap(find.byKey(const Key('review-domain-huquq')));
    await tester.pumpAndSettle();

    expect(find.byType(OptionalDomainProgressScreen), findsOneWidget);
    expect(find.byType(PeriodSelector), findsOneWidget);
    expect(find.text(Copy.aboutThisDomain), findsOneWidget);
    expect(find.text('Repair'), findsOneWidget);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Repair'), findsNothing);
    expect(find.byType(PeriodSelector), findsOneWidget);
  });
}
