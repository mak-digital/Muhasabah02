import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/quran.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

Future<void> expandCheckInBand(
  WidgetTester tester, {
  required String title,
  required String band,
}) async {
  final finder = find.byKey(Key('checkin-band-$title-$band'));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('full check-in records the same Home trace rows', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final checkIns = MemoryCheckInRepository();
    await tester.pumpWidget(
      testApp(
        checkIns: checkIns,
        now: DateTime(2026, 9, 3),
        visibleDomains: allVisibleDomains(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(Copy.homeCheckIn));
    await tester.pumpAndSettle();

    expect(find.text('Financial charity'), findsNothing);
    expect(find.text('Optional domains'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.byKey(const Key('checkin-domain-next')), findsOneWidget);
    expect(find.text('HADITH & LIVING SUNNAH'), findsNothing);

    await showCheckInDomain(tester, MonitorDomain.hadith);
    expect(find.text('HADITH & LIVING SUNNAH'), findsOneWidget);
    expect(find.text('ENGAGED WITH HADITH'), findsWidgets);
    expect(find.text('RETENTION'), findsNothing);
    expect(find.text('LEARNING'), findsNothing);
    expect(find.text('LIVED / NOTICED'), findsNothing);
    expect(find.text('Read and/or Listened'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lived /Noticed others'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Memorization/Revision'), findsOneWidget);
    expect(find.text('Study Circle/Discussion'), findsOneWidget);
    expect(find.text('Lived /Noticed others'), findsWidgets);
    expect(find.text('Hadith Reflection'), findsNothing);
    expect(find.text('Noticed a sunnah in how I lived today'), findsNothing);

    await showCheckInDomain(tester, MonitorDomain.dhikr);
    expect(find.text('POST-FARD SALAH ADHKAR'), findsOneWidget);
    expect(find.text('Fajr'), findsWidgets);
    expect(find.text('Morning Adhkar'), findsNothing);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.dhikr.label,
      band: 'Morning and evening',
    );
    expect(find.text('Morning Adhkar'), findsOneWidget);
    expect(find.text('Character / conduct'), findsNothing);
    await showCheckInDomain(tester, MonitorDomain.akhlaq);
    expect(find.text('Patience'), findsWidgets);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.akhlaq.label,
      band: 'Modesty',
    );
    await expandCheckInBand(
      tester,
      title: MonitorDomain.akhlaq.label,
      band: 'Restraint',
    );
    await tester.scrollUntilVisible(
      find.text('Held back from a habit I am trying to leave'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Thankfulness in how I acted'), findsOneWidget);
    expect(find.text('Guarded how I spoke (tone)'), findsOneWidget);
    expect(find.text('Guarded my gaze'), findsOneWidget);
    expect(
      find.text('Held back from a habit I am trying to leave'),
      findsOneWidget,
    );
    expect(find.text('Modest speech'), findsNothing);
    expect(find.text('Modest gaze'), findsNothing);
    expect(find.text('Guarded my glance'), findsNothing);
    await showCheckInDomain(tester, MonitorDomain.huquq);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.huquq.label,
      band: 'Extended family',
    );
    await expandCheckInBand(
      tester,
      title: MonitorDomain.huquq.label,
      band: 'Repair',
    );
    await tester.scrollUntilVisible(
      find.text('A step toward reconciliation'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('HOUSEHOLD'), findsWidgets);
    expect(find.text('Siblings'), findsOneWidget);
    expect(find.text('Grandparents'), findsOneWidget);
    expect(find.text('EXTENDED FAMILY'), findsOneWidget);
    expect(find.text('Other relatives'), findsOneWidget);
    expect(find.text('A step toward reconciliation'), findsOneWidget);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.huquq.label,
      band: 'Care in hardship',
    );
    await tester.scrollUntilVisible(
      find.text('Sick Visit'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('CARE IN HARDSHIP'), findsOneWidget);
    expect(find.text('Sick Visit'), findsOneWidget);
    expect(find.text('Sick Contact'), findsOneWidget);
    expect(find.text('Support Under Stress'), findsOneWidget);
    expect(find.text('Family & Community Care'), findsNothing);
    await showCheckInDomain(tester, MonitorDomain.knowledge);
    await tester.scrollUntilVisible(
      find.text('Learned something true'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('SEEKING TRUTH'), findsOneWidget);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.knowledge.label,
      band: 'Sharing',
    );
    await expandCheckInBand(
      tester,
      title: MonitorDomain.knowledge.label,
      band: 'Beneficial speech',
    );
    expect(find.text('Taught someone'), findsOneWidget);
    expect(
      find.text('Beneficial reading (not Qur’an or Hadith)'),
      findsOneWidget,
    );
    expect(find.text('Held back useless speech'), findsOneWidget);
    await showCheckInDomain(tester, MonitorDomain.time);
    await tester.scrollUntilVisible(
      find.text('Began with a worthwhile intention'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('INTENTION & PRIORITY'), findsOneWidget);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.time.label,
      band: 'Attention & Presence',
    );
    await expandCheckInBand(
      tester,
      title: MonitorDomain.time.label,
      band: 'Responsibility & Action',
    );
    await expandCheckInBand(
      tester,
      title: MonitorDomain.time.label,
      band: 'Balance & Renewal',
    );
    expect(find.text('Put aside a digital distraction'), findsOneWidget);
    expect(find.text('Took a step on something delayed'), findsOneWidget);
    expect(find.text('Took needed rest'), findsOneWidget);
    expect(find.text('Guarded a prayer window from waste'), findsNothing);
    expect(find.text('Present in what I was doing'), findsNothing);
    await showCheckInDomain(tester, MonitorDomain.health);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.health.label,
      band: 'Strength',
    );
    await expandCheckInBand(
      tester,
      title: MonitorDomain.health.label,
      band: 'Illness & harm',
    );
    await tester.scrollUntilVisible(
      find.text('Sought care in illness'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('SLEEP'), findsOneWidget);
    expect(find.text('Movement for worship and service'), findsOneWidget);
    expect(find.text('Sought care in illness'), findsOneWidget);
    await showCheckInDomain(tester, MonitorDomain.wealth);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.wealth.label,
      band: 'Restraint',
    );
    await tester.scrollUntilVisible(
      find.text('Avoided waste'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('EARNING'), findsOneWidget);
    expect(find.text('Stayed clear of riba'), findsOneWidget);
    expect(find.text('Avoided waste'), findsOneWidget);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.wealth.label,
      band: 'Lawful wealth management',
    );
    await tester.scrollUntilVisible(
      find.text('Managed wealth responsibly and lawfully'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Managed wealth responsibly and lawfully'),
      findsOneWidget,
    );
    expect(find.text('Gave sadaqah'), findsNothing);
    expect(find.text('Attended to zakat'), findsNothing);
    await showCheckInDomain(tester, MonitorDomain.ummah);
    await expandCheckInBand(
      tester,
      title: MonitorDomain.ummah.label,
      band: 'Witness',
    );
    await expandCheckInBand(
      tester,
      title: MonitorDomain.ummah.label,
      band: 'Solidarity',
    );
    await tester.scrollUntilVisible(
      find.text('Prayed for the Ummah'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('MASJID'), findsOneWidget);
    expect(
      find.text('Masjid class or gathering (not the fard)'),
      findsOneWidget,
    );
    expect(find.text('Served beyond myself'), findsNothing);
    expect(find.text('Da’wah by character'), findsOneWidget);
    expect(find.text('Prayed for the Ummah'), findsOneWidget);
    expect(find.textContaining('Score'), findsNothing);

    await showCheckInDomain(tester, MonitorDomain.dhikr);
    await tester.ensureVisible(
      find.byKey(const Key('trace-dhikr.postFardFajr')),
    );
    await tester.tap(find.byKey(const Key('trace-dhikr.postFardFajr')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.dhikrPerformedHint), findsWidgets);
    expect(find.text(Copy.howAttentiveWasI.toUpperCase()), findsNothing);
    await tester.tap(
      find.byKey(const Key('dhikr-pick-dhikr.postFardFajr.dh.post.istighfar3')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();

    final stored = await checkIns.allHealthy();
    expect(stored, hasLength(1));
    expect(
      stored.single.homeTrace('dhikr.postFardFajr'),
      TernaryOutcome.positive,
    );
    expect(
      stored.single.dhikrContextFor('dhikr.postFardFajr').single.activityId,
      'dhikr.postFardFajr.dh.post.istighfar3',
    );
  });
}
