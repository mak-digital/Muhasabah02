import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/custom_selection_set.dart';
import 'package:muhasabah02/domain/display_calendar.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/personal_response.dart';
import 'package:muhasabah02/presentation/settings/settings_screen.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpLarge(WidgetTester tester, {required Widget app}) async {
    tester.view.physicalSize = const Size(400, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  Future<void> openDomains(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.visibleDomains));
    await tester.tap(find.text(Copy.visibleDomains));
    await tester.pumpAndSettle();
    expect(find.byType(VisibleDomainsSettingsScreen), findsOneWidget);
  }

  Future<void> showSlot(WidgetTester tester, int id) async {
    await tester.scrollUntilVisible(
      find.byKey(Key('custom-slot-$id')),
      400,
      scrollable: find.descendant(
        of: find.byType(VisibleDomainsSettingsScreen),
        matching: find.byType(Scrollable),
      ),
    );
  }

  testWidgets('save activate rename and overlap keep three independent slots', (
    tester,
  ) async {
    final prefs = MemoryAppPrefs(
      visibleDomains: {MonitorDomain.salah, MonitorDomain.quran},
      personalMix: mixForKind(
        PersonalMixKind.custom,
        customKeys: {'salah.fajr', 'quran.reading'},
      ),
    );
    await pumpLarge(
      tester,
      app: testApp(now: DateTime(2026, 9, 22), prefs: prefs),
    );
    await openDomains(tester);
    await showSlot(tester, 1);
    await tester.tap(find.byKey(const Key('custom-slot-save-1')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.customSlotActive), findsOneWidget);

    await tester.tap(find.byKey(const Key('domain-visible-quran')));
    await tester.pumpAndSettle();
    expect(prefs.customSelectionSets.slotById(1).domains, {
      MonitorDomain.salah,
      MonitorDomain.quran,
    });
    expect(prefs.visibleDomains, {MonitorDomain.salah});
    expect(find.byKey(const Key('custom-slot-status-1')), findsOneWidget);
    expect(find.text(Copy.customSlotModified), findsOneWidget);

    await tester.tap(find.byKey(const Key('custom-slot-save-2')));
    await tester.pumpAndSettle();
    expect(
      prefs.customSelectionSets
          .slotById(1)
          .domains
          .contains(MonitorDomain.quran),
      isTrue,
    );
    expect(prefs.customSelectionSets.slotById(2).domains, {
      MonitorDomain.salah,
    });
    expect(prefs.customSelectionSets.slotById(1).mix.keys, {
      'salah.fajr',
      'quran.reading',
    });
    expect(prefs.customSelectionSets.slotById(2).mix.keys, {
      'salah.fajr',
      'quran.reading',
    });

    await tester.tap(find.byKey(const Key('custom-slot-rename-3')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Night focus  ');
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('rename-custom-slot-dialog')),
        matching: find.text(Copy.customSlotRename),
      ),
    );
    await tester.pumpAndSettle();
    expect(prefs.customSelectionSets.slotById(3).name, 'Night focus');
    await showSlot(tester, 3);
    expect(find.text('Custom #3 (Night focus)'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('domain-visible-fasting')));
    await tester.tap(find.byKey(const Key('domain-visible-fasting')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.customSlotModified), findsOneWidget);

    await showSlot(tester, 1);
    final before = prefs.mutationCount;
    await tester.tap(find.byKey(const Key('custom-slot-activate-1')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('activate-custom-slot-dialog')),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('activate-custom-slot-dialog')),
        matching: find.text(Copy.cancel),
      ),
    );
    await tester.pumpAndSettle();
    expect(prefs.visibleDomains, {MonitorDomain.salah, MonitorDomain.fasting});
    expect(prefs.mutationCount, before);

    await tester.tap(find.byKey(const Key('custom-slot-activate-1')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('activate-custom-slot-dialog')),
        matching: find.text(Copy.activateModifiedAction),
      ),
    );
    await tester.pumpAndSettle();
    expect(prefs.visibleDomains, {MonitorDomain.salah, MonitorDomain.quran});
    expect(prefs.mutationCount, before + 1);
    expect(prefs.customSelectionSets.activeSlotId, 1);
    expect(find.text(Copy.customSlotActive), findsOneWidget);

    await tester.tap(find.byKey(const Key('custom-slot-activate-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('activate-custom-slot-dialog')), findsNothing);
    expect(prefs.mutationCount, before + 2);
  });

  testWidgets('clear all keeps slots names records and unrelated prefs', (
    tester,
  ) async {
    final checkIns = MemoryCheckInRepository();
    await checkIns.save(sampleDay('2026-09-03'));
    final responses = MemoryResponseRepository();
    await responses.save(
      PersonalResponse(
        id: 'r1',
        text: 'Kept note',
        createdAt: DateTime(2026, 9, 3),
      ),
    );
    final prefs = MemoryAppPrefs(
      displayCalendar: DisplayCalendar.islamic,
      appLockEnabled: true,
      visibleDomains: {MonitorDomain.salah, MonitorDomain.fasting},
      personalMix: mixForKind(PersonalMixKind.firstLook),
      customSelectionSets: CustomSelectionSetsRecord(
        activeSlotId: 2,
        slots: [
          const CustomSelectionSet(id: 1, name: 'Kept'),
          const CustomSelectionSet(
            id: 2,
            name: 'Fast',
            domains: {MonitorDomain.salah, MonitorDomain.fasting},
          ),
          const CustomSelectionSet(id: 3),
        ],
      ),
    );
    await pumpLarge(
      tester,
      app: testApp(
        now: DateTime(2026, 9, 22),
        prefs: prefs,
        checkIns: checkIns,
        responses: responses,
      ),
    );
    await openDomains(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('clear-all-selections')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('clear-all-selections')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.clearAllSelectionsTitle), findsOneWidget);
    await tester.tap(find.text(Copy.cancel));
    await tester.pumpAndSettle();
    expect(prefs.visibleDomains, {MonitorDomain.salah, MonitorDomain.fasting});

    await tester.tap(find.byKey(const Key('clear-all-selections')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.clearAllSelectionsAction));
    await tester.pumpAndSettle();
    expect(prefs.visibleDomains, isEmpty);
    expect(encodeVisibleDomains(prefs.visibleDomains), '');
    expect(prefs.personalMix, PersonalMix.sameAsDomains);
    expect(prefs.customSelectionSets.activeSlotId, isNull);
    expect(prefs.customSelectionSets.slotById(1).name, 'Kept');
    expect(prefs.customSelectionSets.slotById(2).name, 'Fast');
    expect(prefs.customSelectionSets.slotById(2).domains, {
      MonitorDomain.salah,
      MonitorDomain.fasting,
    });
    expect(prefs.displayCalendar, DisplayCalendar.islamic);
    expect(prefs.appLockEnabled, isTrue);
    expect((await checkIns.allHealthy()).single.dateKey, '2026-09-03');
    expect((await responses.allHealthy()).single.text, 'Kept note');

    Navigator.of(tester.element(find.byType(VisibleDomainsSettingsScreen)))
        .pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text(Copy.settingsTitle))).pop();
    await tester.pumpAndSettle();
    expect(find.text(Copy.todayEmpty), findsOneWidget);
  });

  testWidgets('clear all on a custom slot keeps other slots and names', (
    tester,
  ) async {
    final prefs = MemoryAppPrefs(
      visibleDomains: {MonitorDomain.salah, MonitorDomain.fasting},
      customSelectionSets: CustomSelectionSetsRecord(
        activeSlotId: 2,
        slots: [
          const CustomSelectionSet(id: 1, name: 'Kept'),
          const CustomSelectionSet(
            id: 2,
            name: 'Fast',
            domains: {MonitorDomain.salah, MonitorDomain.fasting},
          ),
          const CustomSelectionSet(
            id: 3,
            name: 'Night',
            domains: {MonitorDomain.quran},
          ),
        ],
      ),
    );
    await pumpLarge(
      tester,
      app: testApp(now: DateTime(2026, 9, 22), prefs: prefs),
    );
    await openDomains(tester);
    await showSlot(tester, 2);
    await tester.tap(find.byKey(const Key('custom-slot-clear-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('clear-custom-slot-dialog-2')), findsOneWidget);
    await tester.tap(find.text(Copy.cancel));
    await tester.pumpAndSettle();
    expect(prefs.customSelectionSets.slotById(2).domains, {
      MonitorDomain.salah,
      MonitorDomain.fasting,
    });

    await tester.tap(find.byKey(const Key('custom-slot-clear-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.clearAllSelectionsAction));
    await tester.pumpAndSettle();
    expect(prefs.customSelectionSets.slotById(2).name, 'Fast');
    expect(prefs.customSelectionSets.slotById(2).domains, isEmpty);
    expect(prefs.visibleDomains, isEmpty);
    expect(prefs.customSelectionSets.activeSlotId, 2);
    expect(prefs.customSelectionSets.slotById(1).name, 'Kept');
    expect(prefs.customSelectionSets.slotById(3).name, 'Night');
    expect(prefs.customSelectionSets.slotById(3).domains, {
      MonitorDomain.quran,
    });
  });

  testWidgets('activating a saved slot refreshes Today', (tester) async {
    final prefs = MemoryAppPrefs(
      visibleDomains: <MonitorDomain>{},
      customSelectionSets: CustomSelectionSetsRecord(
        slots: [
          const CustomSelectionSet(id: 1, domains: {MonitorDomain.salah}),
          const CustomSelectionSet(id: 2),
          const CustomSelectionSet(id: 3),
        ],
      ),
    );
    await pumpLarge(
      tester,
      app: testApp(now: DateTime(2026, 9, 22), prefs: prefs),
    );
    expect(find.text(Copy.todayEmpty), findsOneWidget);
    await openDomains(tester);
    await showSlot(tester, 1);
    await tester.tap(find.byKey(const Key('custom-slot-activate-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('activate-custom-slot-dialog')), findsNothing);
    Navigator.of(tester.element(find.byType(VisibleDomainsSettingsScreen)))
        .pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text(Copy.settingsTitle))).pop();
    await tester.pumpAndSettle();
    expect(find.text(Copy.todayEmpty), findsNothing);
    await expandActiveDomainMix(tester);
    expect(find.byKey(const Key('today-domain-salah')), findsOneWidget);
  });

  testWidgets(
    'activating an empty slot clears Today without restoring defaults',
    (tester) async {
      final prefs = MemoryAppPrefs(
        visibleDomains: kBasicDhikrVisibleDomains,
        customSelectionSets: CustomSelectionSetsRecord.empty(),
      );
      await pumpLarge(
        tester,
        app: testApp(now: DateTime(2026, 9, 22), prefs: prefs),
      );
      await expandActiveDomainMix(tester);
      expect(find.byKey(const Key('today-domain-salah')), findsOneWidget);
      await openDomains(tester);
      await showSlot(tester, 3);
      await tester.tap(find.byKey(const Key('custom-slot-activate-3')));
      await tester.pumpAndSettle();
      expect(prefs.visibleDomains, isEmpty);
      expect(encodeVisibleDomains(prefs.visibleDomains), '');
      expect(prefs.personalMix, PersonalMix.sameAsDomains);
      Navigator.of(tester.element(find.byType(VisibleDomainsSettingsScreen)))
          .pop();
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.text(Copy.settingsTitle))).pop();
      await tester.pumpAndSettle();
      expect(find.text(Copy.todayEmpty), findsOneWidget);
      expect(find.byKey(const Key('today-domain-salah')), findsNothing);
    },
  );

  testWidgets('third slot and Clear all stay above a 48dp system inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 22)));
    await tester.pumpAndSettle();
    await openDomains(tester);
    final clearAll = find.byKey(const Key('clear-all-selections'));
    expect(clearAll, findsOneWidget);
    expect(tester.getRect(clearAll).bottom, lessThanOrEqualTo(1200 - 48));
    await showSlot(tester, 3);
    final domainsScroll = find.descendant(
      of: find.byType(VisibleDomainsSettingsScreen),
      matching: find.byType(Scrollable),
    );
    final slot3 = find.byKey(const Key('custom-slot-3'), skipOffstage: false);
    for (var i = 0; i < 40; i++) {
      if (tester.getRect(slot3).bottom <= 1200 - 48) break;
      await tester.drag(domainsScroll, const Offset(0, -240));
      await tester.pumpAndSettle();
    }
    expect(tester.getRect(slot3).bottom, lessThanOrEqualTo(1200 - 48));
  });

  testWidgets('Rename dialog stays usable with a 280dp keyboard inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApp(now: DateTime(2026, 9, 22)));
    await tester.pumpAndSettle();
    await openDomains(tester);
    await showSlot(tester, 3);
    final domainsScroll = find.descendant(
      of: find.byType(VisibleDomainsSettingsScreen),
      matching: find.byType(Scrollable),
    );
    final rename = find.byKey(
      const Key('custom-slot-rename-3'),
      skipOffstage: false,
    );
    for (var i = 0; i < 40; i++) {
      final rect = tester.getRect(rename);
      if (rect.top >= 0 && rect.bottom <= 1200) break;
      await tester.drag(domainsScroll, const Offset(0, -240));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key('custom-slot-rename-3')));
    await tester.pumpAndSettle();
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rename-custom-slot-dialog')), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.getRect(find.text(Copy.customSlotRename).last).bottom,
      lessThanOrEqualTo(1200 - 280),
    );
  });
}
