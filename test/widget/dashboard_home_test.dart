import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/dashboard_summary.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/review_period.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  test(
    'dashboard snapshot stays factual and excludes missing from outcomes',
    () {
      final today = DateTime(2026, 9, 3);
      final records = [
        DailyCheckIn.empty('2026-09-03')
            .withPrayer(PrayerId.fajr, PrayerStatus.onTime),
        DailyCheckIn.empty('2026-09-02')
            .withPrayer(PrayerId.fajr, PrayerStatus.unanswered),
      ];
      final snapshot = buildHomeDashboard(
        records: records,
        now: today,
        period: ReviewPeriod.days7,
        recognitionCount: 0,
      );
      expect(snapshot.salah.title, MonitorDomain.salah.label);
      expect(snapshot.salah.unansweredLine, contains('unanswered'));
      expect(snapshot.salah.periodLine, contains('missing excluded'));
      expect(snapshot.recognitionLine, contains('30-day'));
      expect(snapshot.reviewLine, contains('recorded'));
    },
  );

  testWidgets('home dashboard shows domain cards and ponder without scores', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 15500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 3), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    expect(find.text(MonitorDomain.salah.label), findsWidgets);
    expect(find.byKey(const Key('home-domain-next')), findsOneWidget);
    expect(find.textContaining('Qur’an ›'), findsOneWidget);
    expect(find.byKey(const Key('home-domain-pill-salah')), findsOneWidget);
    expect(find.byKey(const Key('home-domain-pill-dhikr')), findsOneWidget);
    expect(find.byKey(const Key('home-domain-pill-hajj')), findsOneWidget);
    expect(find.text('Family & Community Care'), findsNothing);
    expect(find.text(MonitorDomain.quran.label), findsNothing);
    expect(find.text(Copy.reflectionOfTheWeek), findsOneWidget);
    expect(find.text(Copy.thisWeekLookback), findsOneWidget);
    expect(find.text(Copy.lookbackPresenceNote), findsOneWidget);
    expect(find.text(Copy.lookbackEmpty), findsOneWidget);
    expect(find.byKey(const Key('home-lookback-recorded')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsOneWidget);
    expect(find.text(Copy.currentWeek), findsWidgets);
    expect(find.text('Parent Contact'), findsNothing);
    expect(find.text('Family & Community Care'), findsNothing);
    expect(find.text(Copy.ponderPrompt), findsWidgets);
    expect(find.text('Recognition'), findsWidgets);
    expect(find.text(Copy.addAResponse), findsWidgets);
    expect(find.text(Copy.homeCheckIn), findsOneWidget);
    expect(find.text(Copy.marksGuide), findsOneWidget);
    expect(find.byTooltip(Copy.marksGuideTitle), findsOneWidget);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);

    await tester.ensureVisible(find.text(MonitorDomain.salah.label).first);
    await tester.tap(find.text(MonitorDomain.salah.label).first);
    await tester.pumpAndSettle();
    expect(find.byType(CheckInScreen), findsOneWidget);
    expect(
      find.textContaining('${MonitorDomain.salah.label} ·'),
      findsOneWidget,
    );
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Recitation'), findsNothing);
  });

  testWidgets('first look Home shows the six-domain preset', (tester) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
    await tester.pumpAndSettle();
    expect(find.text(MonitorDomain.salah.label), findsWidgets);
    expect(find.byKey(const Key('home-domain-next')), findsOneWidget);
    expect(find.textContaining('Qur’an ›'), findsOneWidget);
    expect(find.byKey(const Key('home-domain-pill-salah')), findsOneWidget);
    expect(find.byKey(const Key('home-domain-pill-hadith')), findsOneWidget);
    expect(find.byKey(const Key('home-domain-pill-charity')), findsOneWidget);
    expect(find.byKey(const Key('home-domain-pill-dhikr')), findsNothing);
    expect(find.text(MonitorDomain.hadith.label), findsNothing);
    expect(find.text(MonitorDomain.akhlaq.label), findsNothing);
    expect(find.text(MonitorDomain.dhikr.label), findsNothing);
    expect(find.text(MonitorDomain.knowledge.label), findsNothing);
    expect(find.text('Family & Community Care'), findsNothing);
    expect(find.text('Weekly Sunnah Fast'), findsNothing);
    expect(find.text(MonitorDomain.hajj.label), findsNothing);
  });

  testWidgets('Dhikr title opens Dhikr Progress', (tester) async {
    tester.view.physicalSize = const Size(400, 15500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 3), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.dhikr);
    await tester.ensureVisible(find.text(MonitorDomain.dhikr.label).first);
    await tester.tap(find.text(MonitorDomain.dhikr.label).first);
    await tester.pumpAndSettle();
    expect(find.text('${MonitorDomain.dhikr.label} Progress'), findsWidgets);
    expect(find.text('Did I remember Allah outside of prayer?'), findsWidgets);
    expect(find.text('Post-fard Salah Adhkar'), findsWidgets);
    expect(find.text('Faj'), findsOneWidget);
    expect(find.textContaining('${MonitorDomain.dhikr.label} ·'), findsNothing);
    expect(find.textContaining('Check-in ·'), findsNothing);
  });

  testWidgets('Noticed This Week follows Domains and skips hidden Dhikr', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty('2026-09-03')
          .withHomeTrace('dhikr.morningAdhkar', TernaryOutcome.positive)
          .withHomeTrace('huquq.parents', TernaryOutcome.positive),
    );
    await tester.pumpWidget(
      testApp(now: DateTime(2026, 9, 3), checkIns: checkIns),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-lookback')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Morning Adhkar'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
  });

  testWidgets('This week recorded days opens Review', (tester) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 3)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-lookback-recorded')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('home-lookback-recorded')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.reviewThisPeriod), findsOneWidget);
    expect(find.textContaining('Score'), findsNothing);
  });

  testWidgets('Recognition is hidden when Qur’an is hidden', (tester) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 9, 3),
        visibleDomains: {MonitorDomain.salah, MonitorDomain.huquq},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Recognition'), findsNothing);
    expect(find.text(Copy.thisWeekLookback), findsOneWidget);
  });
}
