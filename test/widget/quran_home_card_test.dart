import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  final now = DateTime(2026, 9, 3);

  Future<void> pumpHome(
    WidgetTester tester, {
    List<DailyCheckIn> days = const [],
    FirstDayOfWeekPref firstDay = FirstDayOfWeekPref.monday,
  }) async {
    tester.view.physicalSize = const Size(400, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final checkIns = MemoryCheckInRepository();
    for (final day in days) {
      await checkIns.save(day);
    }
    await tester.pumpWidget(
      testApp(checkIns: checkIns, now: now, firstDayOfWeek: firstDay),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.quran);
  }

  testWidgets('Monday first places Monday as the first Qur’an column', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(
      tester
          .getTopLeft(find.byKey(const Key('quran-home-reading-2026-08-31')))
          .dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('quran-home-reading-2026-09-01')))
            .dx,
      ),
    );
  });

  testWidgets('Sunday first places Sunday as the first Qur’an column', (
    tester,
  ) async {
    await pumpHome(tester, firstDay: FirstDayOfWeekPref.sunday);
    expect(
      tester
          .getTopLeft(find.byKey(const Key('quran-home-reading-2026-08-30')))
          .dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('quran-home-reading-2026-08-31')))
            .dx,
      ),
    );
  });

  testWidgets(
    'Qur’an card uses approved row labels and not Application Reflection',
    (tester) async {
      await pumpHome(tester);
      expect(find.text('Recitation with Meaning'), findsWidgets);
      expect(find.text('Qur’anic Reflection'), findsWidgets);
      expect(find.text('Conscious Application'), findsWidgets);
      expect(find.text('Application Reflection'), findsNothing);
    },
  );

  testWidgets('meaning engagement fills recitation on the same date cell', (
    tester,
  ) async {
    await pumpHome(
      tester,
      days: [
        DailyCheckIn.empty('2026-08-31')
            .withQuran(QuranDimension.meaning, TernaryOutcome.positive),
      ],
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('quran-home-meaning-2026-08-31')),
          )
          .kind,
      MarkerKind.filled,
    );
    expect(
      tester
          .widget<RecordedStateMarker>(
            find.byKey(const Key('quran-home-reading-2026-08-31')),
          )
          .kind,
      MarkerKind.filled,
    );
  });

  testWidgets('Qur’an title opens Qur’an entry only', (tester) async {
    await pumpHome(tester);
    await tester.ensureVisible(find.text(MonitorDomain.quran.label).first);
    await tester.tap(find.text(MonitorDomain.quran.label).first);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.quran.label} ·'),
      findsOneWidget,
    );
    expect(find.text('Did I let the Qur’an speak to me today?'), findsWidgets);
    expect(find.text('Recitation'), findsOneWidget);
    expect(find.text('Fajr'), findsNothing);
    expect(find.text('Morning Adhkar'), findsNothing);
    expect(find.text('Memorisation'), findsNothing);
  });

  testWidgets('Qur’an cell opens that day’s entry like the title', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.ensureVisible(
      find.byKey(const Key('quran-home-reading-2026-09-03')),
    );
    await tester.tap(find.byKey(const Key('quran-home-reading-2026-09-03')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.quran.label} · 3 Sep 2026'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    expect(find.text(Copy.edit), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quran-home-reading-2026-08-31')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('${MonitorDomain.quran.label} · 31 Aug 2026'),
      findsOneWidget,
    );
    expect(find.text(Copy.edit), findsWidgets);
    await tester.tap(find.text(Copy.edit).last);
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Qur’an Retention cell opens that band only', (tester) async {
    await pumpHome(tester);
    await tester.ensureVisible(
      find.byKey(const Key('quran-home-memorisation-2026-09-03')),
    );
    await tester.tap(
      find.byKey(const Key('quran-home-memorisation-2026-09-03')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('checkin-recording-date'))).data,
      '3 Sep 2026',
    );
    expect(find.text('Memorisation'), findsOneWidget);
    expect(find.text('Recitation with Meaning'), findsNothing);
    expect(find.text('Tafsir'), findsNothing);
  });

  testWidgets('future Qur’an cell does not open entry', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('quran-home-reading-2026-09-04')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsNothing);
  });

  testWidgets('Marks Guide opens without card legends', (tester) async {
    await pumpHome(tester);
    expect(find.textContaining('On time / performed'), findsNothing);
    await tester.tap(find.byTooltip(Copy.marksGuideTitle));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('These marks show what was recorded'),
      findsOneWidget,
    );
    expect(find.text('On time'), findsOneWidget);
    expect(find.text('Recorded engagement'), findsWidgets);
    expect(find.textContaining('do not measure spirituality'), findsOneWidget);
    expect(find.text('Close'), findsWidgets);
    final close = find.byKey(const Key('marks-guide-close'));
    await tester.ensureVisible(close);
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.text(Copy.marksGuideTitle), findsNothing);
    expect(find.text(Copy.appName), findsOneWidget);
  });
}
