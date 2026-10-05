import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/theme.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/presentation/shared/domain_visual.dart';
import 'package:muhasabah02/presentation/shared/state_marker.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    DateTime? now,
    DateTime Function()? clock,
    Set<MonitorDomain>? visibleDomains,
    PersonalMix? personalMix,
    MemoryCheckInRepository? checkIns,
  }) async {
    tester.view.physicalSize = const Size(400, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: now,
        clock: clock,
        visibleDomains: visibleDomains,
        personalMix: personalMix,
        checkIns: checkIns,
      ),
    );
    await tester.pumpAndSettle();
  }

  test('Today tiles reuse domain family colors, not status colors', () {
    expect(
      domainColorIdentity(MonitorDomain.salah).family,
      MuhasabahColors.salahFamily,
    );
    expect(
      domainColorIdentity(MonitorDomain.quran).family,
      MuhasabahColors.quranFamily,
    );
    expect(
      domainColorIdentity(MonitorDomain.dhikr).family,
      MuhasabahColors.dhikrFamily,
    );
    expect(
      domainColorIdentity(MonitorDomain.salah).family,
      isNot(MuhasabahColors.missedEarth),
    );
  });

  test('Today tile names use Akhlaq and Huquq, not Character or Rights', () {
    expect(todayDomainLabel(MonitorDomain.akhlaq), 'Akhlaq');
    expect(todayDomainLabel(MonitorDomain.huquq), 'Huquq');
    expect(todayDomainLabel(MonitorDomain.salah), 'Salah');
    expect(todayDomainLabel(MonitorDomain.quran), 'Qur’an');
    expect(todayDomainLabel(MonitorDomain.akhlaq), isNot('Character'));
    expect(todayDomainLabel(MonitorDomain.huquq), isNot('Rights'));
  });

  testWidgets('Today heading, weekday, and date are visible', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 9, 22));
    expect(find.byKey(const Key('today-overview')), findsOneWidget);
    expect(find.text(Copy.today), findsOneWidget);
    expect(find.textContaining('Tuesday'), findsOneWidget);
    expect(find.textContaining('22 Sep 2026'), findsOneWidget);
    expect(find.text(Copy.activeDomainAndMix), findsOneWidget);
    expect(find.byKey(const Key('today-domain-salah')), findsNothing);
    final dateBottom = tester.getBottomLeft(find.byKey(const Key('today-weekday-date'))).dy;
    final actions = tester.getRect(find.byKey(const Key('today-entry-actions')));
    final checkIn = tester.getRect(find.byKey(const Key('home-check-in')));
    final quickTap = tester.getRect(find.byKey(const Key('home-quick-tap')));
    expect(actions.top, greaterThan(dateBottom));
    expect(checkIn.top, closeTo(quickTap.top, 1));
    expect(checkIn.left, lessThan(quickTap.left));
    expect(checkIn.size.height, greaterThanOrEqualTo(48));
    expect(
      tester.widget<Material>(find.byKey(const Key('home-check-in'))).elevation,
      1.5,
    );
    expect(
      tester.widget<Material>(find.byKey(const Key('home-quick-tap'))).elevation,
      1.5,
    );
    await expandActiveDomainMix(tester);
    final salah = tester.getRect(find.byKey(const Key('today-domain-salah')));
    expect(salah.top, greaterThan(actions.bottom));
  });

  testWidgets('Today shows only derived selected domains in model order', (
    tester,
  ) async {
    await pumpHome(
      tester,
      now: DateTime(2026, 9, 22),
      visibleDomains: {
        MonitorDomain.salah,
        MonitorDomain.quran,
        MonitorDomain.dhikr,
        MonitorDomain.akhlaq,
      },
    );
    await expandActiveDomainMix(tester);
    expect(find.byKey(const Key('today-domain-salah')), findsOneWidget);
    expect(find.byKey(const Key('today-domain-quran')), findsOneWidget);
    expect(find.byKey(const Key('today-domain-dhikr')), findsOneWidget);
    expect(find.byKey(const Key('today-domain-akhlaq')), findsOneWidget);
    expect(find.byKey(const Key('today-domain-hadith')), findsNothing);
    expect(find.byKey(const Key('today-domain-huquq')), findsNothing);

    final salah = tester.getTopLeft(
      find.byKey(const Key('today-domain-salah')),
    );
    final quran = tester.getTopLeft(
      find.byKey(const Key('today-domain-quran')),
    );
    final dhikr = tester.getTopLeft(
      find.byKey(const Key('today-domain-dhikr')),
    );
    final akhlaq = tester.getTopLeft(
      find.byKey(const Key('today-domain-akhlaq')),
    );
    expect(salah.dy, lessThanOrEqualTo(quran.dy));
    expect(salah.dx, lessThan(quran.dx));
    expect(dhikr.dy, greaterThan(salah.dy));
    expect(akhlaq.dx, greaterThan(dhikr.dx));
  });

  testWidgets('Today tiles show Salah, Qur’an and Dhikr', (
    tester,
  ) async {
    await pumpHome(tester, now: DateTime(2026, 9, 22));
    await expandActiveDomainMix(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('today-domain-dhikr')),
        matching: find.text('Dhikr'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('today-domain-huquq')), findsNothing);
    expect(find.byKey(const Key('today-domain-hadith')), findsNothing);
    expect(find.byKey(const Key('today-domain-charity')), findsNothing);
    expect(find.byKey(const Key('today-domain-akhlaq')), findsNothing);
    expect(find.byKey(const Key('today-domain-salah')), findsOneWidget);
    expect(find.byKey(const Key('today-domain-quran')), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
  });

  testWidgets('hidden domain is absent from Today', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 9, 22));
    await expandActiveDomainMix(tester);
    expect(find.byKey(const Key('today-domain-salah')), findsOneWidget);
    expect(find.byKey(const Key('today-domain-akhlaq')), findsNothing);
    expect(find.byKey(const Key('today-domain-hajj')), findsNothing);
  });

  testWidgets('Today has no percentage or progress-score copy', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 9, 22));
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('progress'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.textContaining('incomplete'), findsNothing);
    expect(find.textContaining('0 percent'), findsNothing);
  });

  testWidgets('empty Today workspace is a neutral Settings pointer', (
    tester,
  ) async {
    await pumpHome(
      tester,
      now: DateTime(2026, 9, 22),
      visibleDomains: <MonitorDomain>{},
    );
    expect(find.text(Copy.today), findsOneWidget);
    expect(find.text(Copy.todayEmpty), findsOneWidget);
    expect(find.byKey(const Key('today-active-domain-mix')), findsNothing);
    expect(find.byKey(const Key('today-domain-salah')), findsNothing);
    expect(find.textContaining('error'), findsNothing);
    expect(find.textContaining('failed'), findsNothing);
  });

  testWidgets('opening Today does not create a DailyCheckIn', (tester) async {
    final checkIns = MemoryCheckInRepository();
    await pumpHome(tester, now: DateTime(2026, 9, 22), checkIns: checkIns);
    expect(find.byKey(const Key('today-overview')), findsOneWidget);
    expect(await checkIns.allHealthy(), isEmpty);
  });

  testWidgets('date provider update shows the new weekday and date', (
    tester,
  ) async {
    var clock = DateTime(2026, 9, 22, 23, 58);
    await pumpHome(tester, clock: () => clock);
    expect(find.textContaining('Tuesday'), findsOneWidget);
    expect(find.textContaining('22 Sep 2026'), findsOneWidget);

    clock = DateTime(2026, 9, 23, 0, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.textContaining('Wednesday'), findsOneWidget);
    expect(find.textContaining('23 Sep 2026'), findsOneWidget);
    expect(find.textContaining('Tuesday'), findsNothing);
  });

  testWidgets('Today tiles are announced as buttons', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 9, 22));
    await expandActiveDomainMix(tester);
    final semantics = tester.getSemantics(
      find.byKey(const Key('today-domain-salah')),
    );
    expect(semantics.label, contains('Salah'));
    expect(semantics.label, contains('recorded'));
    expect(semantics.flagsCollection.isButton, isTrue);
  });

  testWidgets('Today tiles use compact 12px domain-wash action frames', (
    tester,
  ) async {
    await pumpHome(tester, now: DateTime(2026, 9, 22));
    await expandActiveDomainMix(tester);
    final salah = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('today-domain-salah')),
        matching: find.byType(Material),
      ),
    );
    final quran = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('today-domain-quran')),
        matching: find.byType(Material),
      ),
    );
    final salahShape = salah.shape! as RoundedRectangleBorder;
    expect(salahShape.borderRadius, BorderRadius.circular(12));
    expect(
      salah.color,
      domainColorIdentity(MonitorDomain.salah).washFor(Brightness.light),
    );
    expect(
      quran.color,
      domainColorIdentity(MonitorDomain.quran).washFor(Brightness.light),
    );
    expect(quran.color, isNot(salah.color));
    expect(
      tester.getRect(find.byKey(const Key('today-domain-salah'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('today-domain-salah')),
        matching: find.byType(RecordedStateMarker),
      ),
      findsNothing,
    );
  });

  testWidgets('chips and mix header show mix recorded counts, not scores', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(
      DailyCheckIn.empty(
        '2026-09-22',
      ).withPrayer(PrayerId.fajr, PrayerStatus.onTime),
    );
    await pumpHome(
      tester,
      now: DateTime(2026, 9, 22),
      checkIns: checkIns,
      personalMix: const PersonalMix(
        kind: PersonalMixKind.custom,
        keys: {'salah.fajr', 'salah.dhuhr', 'quran.reading'},
      ),
      visibleDomains: {MonitorDomain.salah, MonitorDomain.quran},
    );
    expect(find.byKey(const Key('today-active-domain-mix-total')), findsOneWidget);
    expect(find.text('1 of 3 recorded'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('Score'), findsNothing);
    await expandActiveDomainMix(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('today-domain-salah')),
        matching: find.text('1 of 2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('today-domain-salah')),
        matching: find.text(Copy.todayRecorded),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('today-domain-quran')),
        matching: find.text('0 of 1'),
      ),
      findsOneWidget,
    );
  });
}
