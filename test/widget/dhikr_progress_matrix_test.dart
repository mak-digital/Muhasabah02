import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/progress/optional_domain_progress_screen.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('Dhikr 7-day Progress uses week matrices', (tester) async {
    tester.view.physicalSize = const Size(520, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 6), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-dhikr')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-dhikr')));
    await tester.pumpAndSettle();

    expect(find.text('Post-fard Salah Adhkar'), findsWidgets);
    expect(find.text('(for the week starting on 31 Aug 2026)'), findsWidgets);
    expect(find.text('Faj'), findsOneWidget);
    expect(find.text('Dhr'), findsOneWidget);
    expect(find.text('Isa'), findsOneWidget);
    expect(find.text('Morning & Evening Adhkar'), findsOneWidget);
    expect(find.text('Mor-Adk'), findsOneWidget);
    expect(find.text('Eve-Adk'), findsOneWidget);
    expect(find.text('Other Adhkar'), findsOneWidget);
    expect(find.text('Personal'), findsWidgets);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Morning Adhkar'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.byTooltip('Previous period'), findsWidgets);
    expect(find.byTooltip('Next period'), findsWidgets);
    expect(find.byKey(const Key('week-matrix-today-2026-09-06')), findsWidgets);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Faj'), findsNothing);

    await tester.ensureVisible(find.text('90 days'));
    await tester.tap(find.text('90 days'));
    await tester.pumpAndSettle();
    expect(find.text('Jun'), findsWidgets);
    expect(find.byTooltip('Previous period'), findsWidgets);
    expect(find.byKey(const Key('calendar-today-2026-09-06')), findsWidgets);
  });

  testWidgets('Huquq 7-day Progress includes care in hardship', (tester) async {
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-huquq')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-huquq')));
    await tester.pumpAndSettle();
    expect(find.byType(OptionalDomainProgressScreen), findsOneWidget);
    expect(find.byKey(const Key('week-matrix-prev-Household')), findsOneWidget);
    expect(find.text('Parent Contact'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
  });

  testWidgets('Salah 7-day Progress uses one obligatory matrix', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1800);
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

    expect(find.text('Obligatory Salah'), findsOneWidget);
    expect(find.text('Faj'), findsOneWidget);
    expect(find.text('Isa'), findsOneWidget);
    expect(find.text('(for the week starting on 31 Aug 2026)'), findsOneWidget);
    expect(find.text('Fajr'), findsNothing);

    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Faj'), findsNothing);
  });

  testWidgets('Qur’an 7-day Progress uses recitation matrix', (tester) async {
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
    await tester.tap(find.byKey(const Key('review-domain-quran')));
    await tester.pumpAndSettle();

    expect(find.text('Recitation'), findsOneWidget);
    expect(find.text('Recite'), findsOneWidget);
    expect(find.text('Meaning'), findsOneWidget);
    expect(find.text('Retention'), findsOneWidget);
    expect(find.text('Study & notice'), findsOneWidget);
    expect(find.text('Recitation with Meaning'), findsNothing);
  });

  testWidgets('Salah and Qur’an Progress cells open focused check-in', (
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
    await tester.tap(find.byKey(const Key('review-domain-salah')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('progress-cell-salah-fajr-2026-09-06')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.salah.label} · 6 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('review-domain-quran')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('progress-cell-quran-reading-2026-09-06')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.quran.label} · 6 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('7-day matrix opens focused check-in and keeps future inactive', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 4), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-domain-dhikr')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('review-domain-dhikr')));
    await tester.pumpAndSettle();

    expect(find.text('(for the week starting on 31 Aug 2026)'), findsWidgets);
    expect(find.byKey(const Key('week-matrix-today-2026-09-04')), findsWidgets);

    await tester.tap(
      find.byKey(const Key('progress-cell-dhikr.postFardFajr-2026-09-04')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.dhikr.label} · 4 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    expect(find.text(Copy.edit), findsNothing);
    expect(find.text('Fajr'), findsWidgets);
    expect(find.text('Morning Adhkar'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('progress-cell-dhikr.postFardFajr-2026-09-03')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.dhikr.label} · 3 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text(Copy.edit), findsWidgets);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.text(Copy.edit).last);
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('week-matrix-next-Post-fard Salah Adhkar')),
    );
    await tester.pumpAndSettle();
    expect(find.text('(for the week starting on 7 Sep 2026)'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('progress-cell-dhikr.postFardFajr-2026-09-07')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('What happened?'), findsNothing);
    expect(find.byType(CheckInScreen), findsNothing);

    final next = tester.widget<IconButton>(
      find.byKey(const Key('week-matrix-next-Post-fard Salah Adhkar')),
    );
    expect(next.onPressed, isNull);
  });
}
