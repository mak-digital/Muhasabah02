import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/dev_feedback.dart';
import 'package:muhasabah02/domain/domain_action.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/personal_response.dart';
import 'package:muhasabah02/domain/practice_hadith.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('Registry filters stored registers to the active mix', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final actions = MemoryDomainActionRepository();
    await actions.save(
      DomainAction(
        id: 'salah-a',
        domain: MonitorDomain.salah,
        title: 'Salah listed action',
        targetDateKey: '2026-10-20',
        priority: ActionPriority.week,
        status: ActionStatus.open,
        createdAt: DateTime(2026, 10, 1),
      ),
    );
    await actions.save(
      DomainAction(
        id: 'hadith-a',
        domain: MonitorDomain.hadith,
        title: 'Hadith listed action',
        targetDateKey: '2026-10-21',
        priority: ActionPriority.week,
        status: ActionStatus.open,
        createdAt: DateTime(2026, 10, 2),
      ),
    );

    final notes = MemoryDevFeedbackRepository();
    await notes.save(
      DevFeedback(
        id: 'fb-s',
        serial: 1,
        domain: MonitorDomain.salah,
        dateKey: '2026-10-01',
        body: 'Salah developer note',
        createdAt: DateTime(2026, 10, 1),
      ),
    );
    await notes.save(
      DevFeedback(
        id: 'fb-h',
        serial: 2,
        domain: MonitorDomain.hadith,
        dateKey: '2026-10-02',
        body: 'Hadith developer note',
        createdAt: DateTime(2026, 10, 2),
      ),
    );

    final responses = MemoryResponseRepository();
    await responses.save(
      PersonalResponse(
        id: 'gen',
        text: 'Independent GEN note',
        createdAt: DateTime(2026, 10, 1),
      ),
    );
    await responses.save(
      PersonalResponse(
        id: 'q',
        text: 'Qur’an mix note',
        createdAt: DateTime(2026, 10, 1),
        provenance: const ResponseProvenance(
          originType: ProvenanceOrigin.quranPonder,
          domain: 'quran',
          labelSnapshot: 'Qur’an',
        ),
      ),
    );
    await responses.save(
      PersonalResponse(
        id: 'h',
        text: 'Hadith mix note',
        createdAt: DateTime(2026, 10, 1),
        provenance: const ResponseProvenance(
          originType: ProvenanceOrigin.historicalReflection,
          domain: 'hadith',
          labelSnapshot: 'Hadith',
        ),
      ),
    );

    final hadith = MemoryPracticeHadithRepository();
    await hadith.save(
      PracticeHadithRecord(
        id: 'ph1',
        catalogId: 'c1',
        addedDateKey: '2026-10-01',
        topic: 'Intention',
        content: 'Actions are by intention',
        source: 'Bukhari 1',
        status: PracticeHadithStatus.learning,
      ),
    );

    final checkIns = MemoryCheckInRepository();
    await checkIns.save(sampleDay('2026-09-01'));

    await tester.pumpWidget(
      testApp(
        checkIns: checkIns,
        domainActions: actions,
        devFeedback: notes,
        responses: responses,
        practiceHadith: hadith,
        visibleDomains: allVisibleDomains(),
        personalMix: mixForKind(PersonalMixKind.firstLook),
        now: DateTime(2026, 10, 8),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(Copy.registryTab),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('History'),
      ),
      findsNothing,
    );

    await tester.tap(find.text(Copy.registryTab));
    await tester.pumpAndSettle();
    expect(find.text(Copy.registryTabActions), findsWidgets);
    expect(find.text('Salah listed action'), findsOneWidget);
    expect(find.text('Hadith listed action'), findsNothing);
    expect(
      find.byKey(const Key('registry-filter-note-actions')),
      findsOneWidget,
    );
    expect(find.textContaining('Showing First season:'), findsWidgets);

    await openRegistryTab(tester, tab: const Key('registry-tab-hadith'));
    expect(find.text(Copy.registryHadithHidden), findsWidgets);
    expect(find.text('Intention'), findsNothing);
    expect(
      find.byKey(const Key('registry-filter-note-hadith')),
      findsOneWidget,
    );

    await openRegistryTab(tester, tab: const Key('registry-tab-developer'));
    expect(find.text('Salah developer note'), findsOneWidget);
    expect(find.text('Hadith developer note'), findsNothing);
    expect(
      find.byKey(const Key('registry-filter-note-developer')),
      findsOneWidget,
    );

    await openRegistryTab(tester, tab: const Key('registry-tab-notes'));
    expect(find.text('Independent GEN note'), findsOneWidget);
    expect(find.text('Qur’an mix note'), findsOneWidget);
    expect(find.text('Hadith mix note'), findsNothing);
    expect(find.byKey(const Key('registry-filter-note-notes')), findsOneWidget);

    await openRegistryTab(tester, tab: const Key('registry-tab-history'));
    expect(find.text(Copy.historyTitle), findsOneWidget);
    expect(find.byKey(const Key('history-day-2026-09-01')), findsOneWidget);
    expect(find.text(Copy.registryHistoryFilterNote), findsOneWidget);
  });

  testWidgets('Registry tabs fit and registers use washed tables', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final actions = MemoryDomainActionRepository();
    await actions.save(
      DomainAction(
        id: 'salah-a',
        domain: MonitorDomain.salah,
        title: 'Salah listed action',
        targetDateKey: '2026-10-20',
        priority: ActionPriority.week,
        status: ActionStatus.open,
        createdAt: DateTime(2026, 10, 1),
      ),
    );
    final notes = MemoryDevFeedbackRepository();
    await notes.save(
      DevFeedback(
        id: 'fb-s',
        serial: 1,
        domain: MonitorDomain.salah,
        dateKey: '2026-10-01',
        body: 'Salah developer note',
        createdAt: DateTime(2026, 10, 1),
      ),
    );
    final responses = MemoryResponseRepository();
    await responses.save(
      PersonalResponse(
        id: 'gen',
        text: 'Independent GEN note',
        createdAt: DateTime(2026, 10, 1),
      ),
    );
    final hadith = MemoryPracticeHadithRepository();
    await hadith.save(
      PracticeHadithRecord(
        id: 'ph1',
        catalogId: 'c1',
        addedDateKey: '2026-10-01',
        topic: 'Intention',
        content: 'Actions are by intention',
        source: 'Bukhari 1',
        arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
        transliteration: 'Innama al-a\'malu bin-niyyat',
        translation: 'Actions are but by intentions.',
        status: PracticeHadithStatus.learning,
        sharedDateKeys: const ['2026-10-07'],
      ),
    );
    await tester.pumpWidget(
      testApp(
        domainActions: actions,
        devFeedback: notes,
        responses: responses,
        practiceHadith: hadith,
        visibleDomains: allVisibleDomains(),
        personalMix: PersonalMix.sameAsDomains,
        now: DateTime(2026, 10, 8),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(Copy.registryTab),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('registry-tab-actions')), findsOneWidget);
    expect(find.byKey(const Key('registry-tab-hadith')), findsOneWidget);
    expect(find.byKey(const Key('registry-tab-developer')), findsOneWidget);
    expect(find.byKey(const Key('registry-tab-notes')), findsOneWidget);
    expect(find.byKey(const Key('registry-tab-history')), findsOneWidget);
    expect(find.text(Copy.registryTabActionsShort), findsOneWidget);
    expect(find.text(Copy.registryTabHadithShort), findsOneWidget);
    expect(find.text(Copy.registryTabDeveloperShort), findsOneWidget);
    expect(find.text(Copy.actionField), findsWidgets);
    expect(find.text(Copy.actionDomainDateColumn), findsOneWidget);
    expect(find.text(Copy.actionStatusShort), findsOneWidget);
    expect(find.byKey(const Key('registry-action-select-all')), findsOneWidget);
    expect(find.text('Salah listed action'), findsOneWidget);
    expect(find.byKey(const Key('registry-action-add')), findsOneWidget);
    expect(find.byKey(const Key('registry-action-delete')), findsOneWidget);
    expect(find.byKey(const Key('registry-action-reminder')), findsOneWidget);
    expect(find.text(Copy.addReminder), findsOneWidget);

    await tester.tap(find.byKey(const Key('registry-tab-hadith')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.hadithTopicColumn), findsOneWidget);
    expect(find.text(Copy.hadithSourceColumn), findsOneWidget);
    expect(find.text(Copy.hadithStatusColumn), findsOneWidget);
    expect(find.text(Copy.hadithSharedColumn), findsOneWidget);
    expect(find.text(formatDayMonthYear('2026-10-07')), findsOneWidget);
    expect(find.byKey(const Key('registry-hadith-select-all')), findsOneWidget);
    expect(find.text('Intention'), findsOneWidget);
    expect(find.text('Actions are by intention'), findsOneWidget);
    expect(find.text('إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ'), findsOneWidget);
    expect(find.text("Innama al-a'malu bin-niyyat"), findsOneWidget);
    expect(find.text('Actions are but by intentions.'), findsOneWidget);
    expect(find.byKey(const Key('registry-hadith-add')), findsOneWidget);
    expect(find.byKey(const Key('registry-hadith-archive')), findsOneWidget);
    expect(find.byKey(const Key('registry-hadith-reminder')), findsOneWidget);

    await tester.tap(find.byKey(const Key('registry-tab-developer')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.noteCodeColumn), findsWidgets);
    expect(find.text(Copy.developerDomainDateColumn), findsOneWidget);
    expect(find.byKey(const Key('registry-dev-select-all')), findsOneWidget);
    expect(find.text('Salah developer note'), findsOneWidget);
    expect(find.text(Copy.downloadDeveloperNotes), findsOneWidget);
    expect(find.byKey(const Key('registry-dev-add')), findsOneWidget);

    await tester.tap(find.byKey(const Key('registry-tab-notes')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.addAResponse), findsWidgets);
    expect(find.text(Copy.noteActionReminder), findsWidgets);
    expect(find.text(Copy.noteCodeColumn), findsWidgets);
    expect(find.text(Copy.noteContentColumn), findsWidgets);
  });

  testWidgets(
    'Archived notes hide Add and Archive and keep three equal actions',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final responses = MemoryResponseRepository();
      await responses.save(
        PersonalResponse(
          id: 'live',
          text: 'Open note',
          createdAt: DateTime(2026, 10, 22),
        ),
      );
      await responses.save(
        PersonalResponse(
          id: 'parked',
          text: 'Parked note',
          createdAt: DateTime(2026, 10, 21),
          archivedAt: DateTime(2026, 10, 22),
        ),
      );

      await tester.pumpWidget(
        testApp(
          responses: responses,
          visibleDomains: allVisibleDomains(),
          now: DateTime(2026, 10, 23),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(Copy.registryTab),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('registry-tab-notes')));
      await tester.pumpAndSettle();

      expect(find.text('Archived'), findsOneWidget);
      expect(find.text(Copy.addAResponse), findsOneWidget);
      expect(find.text(Copy.archiveResponse), findsOneWidget);
      expect(find.text(Copy.restoreResponse), findsOneWidget);
      expect(find.text(Copy.deleteResponse), findsNWidgets(2));
      expect(find.byKey(const Key('note-action-reminder')), findsOneWidget);
      expect(
        find.byKey(const Key('note-action-reminder-archived')),
        findsOneWidget,
      );

      final archivedRestore = tester.getRect(find.text(Copy.restoreResponse));
      final archivedDelete = tester.getRect(
        find.text(Copy.deleteResponse).last,
      );
      expect(archivedRestore.width, closeTo(archivedDelete.width, 12));
    },
  );
}
