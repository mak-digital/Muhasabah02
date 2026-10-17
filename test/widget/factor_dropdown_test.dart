import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/checkin/check_in_screen.dart';
import 'package:muhasabah02/presentation/shared/activity_picker.dart';

import '../support/check_in_select.dart';
import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('salah factors appear by group from the prayer choice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(MemoryAppPrefs()),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Prayed alone on time',
    );
    expect(find.text('HELPING FACTORS'), findsOneWidget);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Missed',
    );
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('DISTRACTING FACTORS'), findsOneWidget);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-fajr'),
      optionLabel: 'Prayed late',
    );
    expect(find.text('HELPING FACTORS'), findsOneWidget);
    expect(find.text('DISTRACTING FACTORS'), findsOneWidget);

    final fajrChoice = tester.getTopLeft(find.byKey(const Key('salah-fajr')));
    final fajrHelping = tester.getTopLeft(
      find.byKey(const Key('salah-fajr-helping')),
    );
    expect(
      fajrHelping.dx - fajrChoice.dx,
      checkInNestedIndent - checkInValueIndent,
    );

    await tester.tap(find.byKey(const Key('salah-fajr-helping')));
    await tester.pumpAndSettle();
    expect(find.text('Slept early').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Not recorded').hitTestable());
    await tester.pumpAndSettle();
  });

  testWidgets('quran factors nest under each duration choice', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(MemoryAppPrefs()),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.quran);

    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('quran-reading'),
      optionLabel: 'Engaged 5–10 minutes — Engagement',
    );
    expect(find.text('HELPING FACTORS'), findsOneWidget);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('quran-reading'),
      optionLabel: 'I did not notice this today — Engagement',
    );
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('DISTRACTING FACTORS'), findsOneWidget);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('quran-reading'),
      optionLabel: 'No answer recorded — Engagement',
    );
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('quran-reading'),
      optionLabel: 'Engaged 5–10 minutes — Engagement',
    );
    final readingChoice = tester.getTopLeft(
      find.byKey(const Key('quran-reading')),
    );
    final readingHelping = tester.getTopLeft(
      find.byKey(const Key('quran-reading-helping')),
    );
    expect(
      readingHelping.dx - readingChoice.dx,
      checkInNestedIndent - checkInValueIndent,
    );
  });

  testWidgets('daytime salah omits Fajr sleep cues from factor lists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(MemoryAppPrefs()),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('salah-dhuhr'),
      optionLabel: 'Prayed alone on time',
    );
    await tester.tap(find.byKey(const Key('salah-dhuhr-helping')));
    await tester.pumpAndSettle();
    expect(find.text('Slept early'), findsNothing);
    expect(find.text('Alarm worked'), findsNothing);
    expect(find.text('Reminder').hitTestable(), findsOneWidget);
  });

  testWidgets('charity voluntary uses item wording without a note field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.charity);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-charity.voluntary')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-charity.voluntary'),
      optionLabel: 'Gave voluntary charity',
    );
    expect(find.text('Gave voluntary charity — Voluntary Charity'), findsNothing);
    expect(find.text('PRIVATE REFLECTION'), findsNothing);
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('Recorded sitting'), findsNothing);
  });

  testWidgets('post-fard dhikr uses remembrance and attentiveness lists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(MemoryAppPrefs()),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.dhikr);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-dhikr.postFardFajr')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-dhikr.postFardFajr'),
      optionLabel:
          'Remembrance with action (I noticed a beneficial response in my behaviour) — Fajr',
    );
    expect(find.text('HOW ATTENTIVE WAS I'), findsOneWidget);
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);

    await tester.tap(find.byKey(const Key('trace-dhikr.postFardFajr-helping')));
    await tester.pumpAndSettle();
    expect(find.text('Reflected on the meaning').hitTestable(), findsOneWidget);
    expect(
      find.text('Aware of what I was saying').hitTestable(),
      findsOneWidget,
    );
    expect(
      find.text('Mostly habitual recitation').hitTestable(),
      findsOneWidget,
    );
    await tester.tap(find.text('Not recorded').hitTestable());
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-dhikr.postFardDhuhr'),
      optionLabel:
          'Not today (I did not practise or do not recall doing so) — Dhuhr',
    );
    expect(find.text('HOW ATTENTIVE WAS I'), findsWidgets);
    expect(find.text('DISTRACTING FACTORS'), findsNothing);
  });

  testWidgets('akhlaq patience uses item wording and optional follow-up', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.akhlaq);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-akhlaq.patience')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-akhlaq.patience'),
      optionLabel: 'Remained patient when tested — Patience',
    );
    expect(find.text(Copy.akhlaqWhereDidItHappen.toUpperCase()), findsOneWidget);
    expect(find.text(Copy.akhlaqWhatHelped.toUpperCase()), findsOneWidget);
    expect(find.text('HELPING FACTORS'), findsNothing);

    await tester.tap(find.byKey(const Key('trace-akhlaq.patience-context')));
    await tester.pumpAndSettle();
    expect(find.text('Family / Home').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Not recorded').hitTestable());
    await tester.pumpAndSettle();
  });

  testWidgets('huquq parents uses item wording and optional follow-up', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.huquq);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-huquq.parents')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-huquq.parents'),
      optionLabel:
          'Honoured my parents through care, respect, contact or du‘a — Parents',
    );
    expect(find.text(Copy.huquqNatureOfEngagement.toUpperCase()), findsOneWidget);
    expect(find.text(Copy.huquqOutcomeObserved.toUpperCase()), findsOneWidget);
    expect(find.text('HELPING FACTORS'), findsNothing);

    await tester.tap(find.byKey(const Key('trace-huquq.parents-engagement')));
    await tester.pumpAndSettle();
    expect(find.text('Respectful interaction').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Not recorded').hitTestable());
    await tester.pumpAndSettle();
  });

  testWidgets('knowledge learned uses item wording and optional follow-up', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.knowledge);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-knowledge.learnedSomethingTrue')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-knowledge.learnedSomethingTrue'),
      optionLabel:
          'Learned something new and verified its reliability — Learned something true',
    );
    expect(find.text(Copy.knowledgeTypeOfKnowledge.toUpperCase()), findsOneWidget);
    expect(find.text(Copy.knowledgeReliability.toUpperCase()), findsOneWidget);
    expect(find.text('HELPING FACTORS'), findsNothing);

    await tester.tap(
      find.byKey(const Key('trace-knowledge.learnedSomethingTrue-area')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Professional or vocational knowledge').hitTestable(),
      findsOneWidget,
    );
    await tester.tap(find.text('Not recorded').hitTestable());
    await tester.pumpAndSettle();
  });

  testWidgets('time intention uses item wording and optional follow-up', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.time);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-time.t01')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-time.t01'),
      optionLabel:
          'Began an activity with a clear beneficial intention — Began with a worthwhile intention',
    );
    expect(find.text(Copy.timeActivityContext.toUpperCase()), findsOneWidget);
    expect(find.text(Copy.timeMainChallenge.toUpperCase()), findsOneWidget);
    expect(find.text('HELPING FACTORS'), findsNothing);

    await tester.tap(find.byKey(const Key('time-time.t01-context')));
    await tester.pumpAndSettle();
    expect(find.text('Worship').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Not recorded').hitTestable());
    await tester.pumpAndSettle();
  });

  testWidgets('health sleep quality uses item wording without a note field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.health);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-health.sleepQuality')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-health.sleepQuality'),
      optionLabel:
          'I slept well and felt reasonably refreshed. — Sleep quality',
    );
    expect(find.text('PRIVATE REFLECTION'), findsNothing);
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(find.text('I noticed this in myself — Sleep quality'), findsNothing);
  });

  testWidgets('wealth earning uses item wording without a note field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.wealth);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-wealth.halalEarning')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-wealth.halalEarning'),
      optionLabel:
          'My income or work today came from a source I reasonably understand to be lawful. — Earned from a halal source',
    );
    expect(find.text('PRIVATE REFLECTION'), findsNothing);
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(
      find.text('I noticed this in myself — Earned from a halal source'),
      findsNothing,
    );
  });

  testWidgets('ummah masjid uses item wording without a note field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRepositoryProvider.overrideWithValue(
            MemoryCheckInRepository(),
          ),
          appPrefsProvider.overrideWithValue(
            MemoryAppPrefs(visibleDomains: allVisibleDomains()),
          ),
          nowProvider.overrideWithValue(DateTime(2026, 9, 3)),
        ],
        child: MaterialApp(home: CheckInScreen(date: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();
    await showCheckInDomain(tester, MonitorDomain.ummah);
    await tester.scrollUntilVisible(
      find.byKey(const Key('trace-ummah.masjidAttendance')),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await chooseCheckInOption(
      tester,
      dropdownKey: const Key('trace-ummah.masjidAttendance'),
      optionLabel:
          'I participated remotely in a masjid-led learning or community gathering. — Masjid class or gathering (not the fard)',
    );
    expect(find.text('PRIVATE REFLECTION'), findsNothing);
    expect(find.text('HELPING FACTORS'), findsNothing);
    expect(
      find.text(
        'I noticed this in myself — Masjid class or gathering (not the fard)',
      ),
      findsNothing,
    );
  });
}
