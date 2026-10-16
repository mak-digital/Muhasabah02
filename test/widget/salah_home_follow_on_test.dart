import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/domain_action.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/salah_extras.dart';
import 'package:muhasabah02/domain/practice_akhlaq_catalog.dart';
import 'package:muhasabah02/domain/practice_dhikr_catalog.dart';
import 'package:muhasabah02/domain/practice_hadith_catalog.dart';
import 'package:muhasabah02/domain/practice_huquq_catalog.dart';
import 'package:muhasabah02/domain/practice_knowledge_catalog.dart';
import 'package:muhasabah02/domain/practice_quran_catalog.dart';
import 'package:muhasabah02/domain/practice_salah_catalog.dart';
import 'package:muhasabah02/domain/practice_health_catalog.dart';
import 'package:muhasabah02/domain/practice_time_catalog.dart';
import 'package:muhasabah02/domain/practice_charity_catalog.dart';
import 'package:muhasabah02/domain/practice_fasting_catalog.dart';
import 'package:muhasabah02/domain/practice_hajj_catalog.dart';
import 'package:muhasabah02/domain/practice_ummah_catalog.dart';
import 'package:muhasabah02/domain/practice_wealth_catalog.dart';
import 'package:muhasabah02/presentation/shared/domain_visual.dart';
import 'package:muhasabah02/presentation/shared/ui_bits.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    MemoryDomainActionRepository? actions,
    MemoryDevFeedbackRepository? feedback,
    MemoryPracticeHadithRepository? practiceHadith,
    Set<MonitorDomain>? visibleDomains,
  }) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        domainActions: actions,
        devFeedback: feedback,
        practiceHadith: practiceHadith,
        visibleDomains: visibleDomains,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> expandActions(WidgetTester tester) async {
    await tester.tap(
      find.text(Copy.domainActionsTitle(MonitorDomain.salah.shortLabel)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> expandNotes(WidgetTester tester) async {
    await tester.tap(find.text(Copy.developerNotesTitle));
    await tester.pumpAndSettle();
  }

  Future<void> addAction(
    WidgetTester tester,
    String title, {
    String prefix = 'salah',
  }) async {
    if (find.byKey(Key('$prefix-action-title')).evaluate().isEmpty) {
      await tester.tap(find.byKey(Key('$prefix-action-add')));
      await tester.pumpAndSettle();
    }
    await tester.enterText(find.byKey(Key('$prefix-action-title')), title);
    await tester.tap(find.byKey(Key('$prefix-action-save')));
    await tester.pumpAndSettle();
  }

  testWidgets('Salah action and note washes stay collapsed until opened', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.byKey(const Key('salah-practice-wash')), findsOneWidget);
    expect(find.text(Copy.practiceSalahTitle), findsOneWidget);
    expect(find.byKey(const Key('salah-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('salah-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.domainActionsNote), findsNothing);
    expect(find.text(Copy.addAction), findsNothing);
    expect(find.text(Copy.addDeveloperNote), findsNothing);
    expect(find.text(Copy.openActionRegister), findsNothing);
    expect(find.text(Copy.openNotesRegister), findsNothing);
    expect(find.byKey(const Key('salah-action-title')), findsNothing);
    expect(find.byKey(const Key('salah-feedback-body')), findsNothing);
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('salah-feedback-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('salah-actions-panel')))
            .color,
      ),
    );
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('salah-practice-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('salah-actions-panel')))
            .color,
      ),
    );
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('salah-practice-panel')))
          .color,
      domainColorIdentity(MonitorDomain.salah).practiceWashFor(Brightness.light),
    );
    expect(
      tester.getSize(find.byKey(const Key('salah-actions-panel'))).height,
      lessThan(56),
    );
    expect(
      tester.getSize(find.byKey(const Key('salah-feedback-panel'))).height,
      lessThan(56),
    );
    expect(
      tester.getSize(find.byKey(const Key('salah-practice-panel'))).height,
      lessThan(56),
    );
  });

  testWidgets('Salah Home lists grouped Learn & Practice, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    await pumpHome(tester, practiceHadith: register);
    expect(find.byKey(const Key('salah-practice-wash')), findsOneWidget);
    expect(find.text(Copy.practiceSalahTitle), findsOneWidget);

    await tester.tap(find.text(Copy.practiceSalahTitle));
    await tester.pumpAndSettle();
    expect(find.text('HIGHLY RECOMMENDED'), findsNothing);
    expect(find.text(Copy.practiceSalahNote), findsOneWidget);
    expect(find.text(Copy.openPracticeSalahRegister), findsOneWidget);
    final about = tester.getRect(
      find.byKey(const Key('salah-practice-about')),
    );
    final registerBtn = tester.getRect(
      find.byKey(const Key('salah-practice-open-register')),
    );
    expect(registerBtn.bottom, lessThanOrEqualTo(about.top + 1));
    expect(registerBtn.height, lessThanOrEqualTo(32));
    expect(registerBtn.left, closeTo(about.left, 8));
    expect(find.text(kPracticeSalahCatalog.first.topic), findsWidgets);
    expect(find.text(kPracticeSalahCatalog.first.arabic), findsNothing);

    await tester.tap(
      find.byKey(Key('salah-practice-item-${kPracticeSalahCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeSalahCatalog.first.arabic), findsOneWidget);
    expect(
      find.text(
        '1 of ${kPracticeSalahCatalog.where((item) => item.topic == kPracticeSalahCatalog.first.topic).length}',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        Key(
          'salah-practice-source-wash-${kPracticeSalahCatalog.first.id}',
        ),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('arabic-script-face')), findsNothing);
    expect(
      find.byKey(
        Key('salah-script-smaller-${kPracticeSalahCatalog.first.id}'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(Key('salah-practice-add-${kPracticeSalahCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.salah);
  });

  testWidgets(
    'active actions are full width, capped at five, and reorderable',
    (tester) async {
      final actions = MemoryDomainActionRepository();
      await pumpHome(tester, actions: actions);
      await expandActions(tester);
      expect(find.text(Copy.domainActionsNote), findsOneWidget);

      await addAction(tester, 'First listed');
      expect(find.text(Copy.domainActionsNote), findsNothing);
      await addAction(tester, 'Second listed');
      expect(find.text('First listed'), findsOneWidget);
      expect(find.text('Second listed'), findsOneWidget);
      final first = (await actions.allHealthy()).firstWhere(
        (action) => action.title == 'First listed',
      );
      expect(
        tester.getSize(find.byKey(Key('salah-action-chip-${first.id}'))).height,
        lessThan(52),
      );
      expect(
        tester.getTopLeft(find.text('First listed')).dy,
        lessThan(tester.getTopLeft(find.text('Second listed')).dy),
      );

      final second = (await actions.allHealthy()).firstWhere(
        (action) => action.title == 'Second listed',
      );
      await tester.tap(find.byKey(Key('salah-action-up-${second.id}')));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Second listed')).dy,
        lessThan(tester.getTopLeft(find.text('First listed')).dy),
      );

      await addAction(tester, 'Three');
      await addAction(tester, 'Four');
      await addAction(tester, 'Five');
      expect((await actions.allHealthy()).length, 5);
      await tester.tap(find.byKey(const Key('salah-action-add')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.actionLimitReached), findsOneWidget);
      expect(find.byKey(const Key('salah-action-title')), findsNothing);
    },
  );

  Future<void> chooseCircle(
    WidgetTester tester,
    String id,
    String label,
  ) async {
    await tester.tap(find.byKey(Key('salah-action-menu-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('circle menu completes, edits, parks, and marks deleted', (
    tester,
  ) async {
    final actions = MemoryDomainActionRepository();
    await pumpHome(tester, actions: actions);
    await expandActions(tester);
    await addAction(tester, 'Keep the phone outside');
    final saved = (await actions.allHealthy()).single;
    expect(find.byIcon(Icons.check), findsNothing);

    await chooseCircle(tester, saved.id, Copy.actionEdit);
    expect(find.text(Copy.saveEditedAction), findsOneWidget);
    expect(find.text(Copy.actionPriorityWeek), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('salah-action-title')),
      'Leave the phone in the hall',
    );
    await tester.tap(find.byKey(const Key('salah-action-save')));
    await tester.pumpAndSettle();
    expect(find.text('Leave the phone in the hall'), findsOneWidget);

    await chooseCircle(tester, saved.id, Copy.actionCompletedClosed);
    expect(find.text('Leave the phone in the hall'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect((await actions.allHealthy()).single.status, ActionStatus.done);

    await tester.tap(find.byKey(Key('salah-action-menu-${saved.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Leave the phone in the hall'), findsNothing);

    await tester.tap(find.byKey(const Key('salah-open-register')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.actionStatusColumn), findsOneWidget);
    expect(find.text(Copy.actionClosed), findsOneWidget);
    expect(find.textContaining('Leave the phone in the hall'), findsOneWidget);
    await tester.tap(find.text(Copy.closeActionRegister));
    await tester.pumpAndSettle();

    await addAction(tester, 'Stand for Isha earlier');
    final active = (await actions.allHealthy()).firstWhere(
      (action) => action.title == 'Stand for Isha earlier',
    );
    await chooseCircle(tester, active.id, Copy.deleteAction);
    expect(find.text('Stand for Isha earlier'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsWidgets);
    expect(
      (await actions.allHealthy())
          .firstWhere((action) => action.title == 'Stand for Isha earlier')
          .status,
      ActionStatus.deleted,
    );
    await tester.tap(find.byKey(Key('salah-action-menu-${active.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Stand for Isha earlier'), findsNothing);
    await tester.tap(find.byKey(const Key('salah-open-register')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.actionDeleted), findsOneWidget);
    expect(find.textContaining('Stand for Isha earlier'), findsOneWidget);
  });

  testWidgets('register can select all and delete permanently', (tester) async {
    final actions = MemoryDomainActionRepository();
    await pumpHome(tester, actions: actions);
    await expandActions(tester);
    await addAction(tester, 'Register keep row');
    await addAction(tester, 'Register leave row');
    final keep = (await actions.allHealthy()).firstWhere(
      (action) => action.title == 'Register keep row',
    );
    final leave = (await actions.allHealthy()).firstWhere(
      (action) => action.title == 'Register leave row',
    );
    await chooseCircle(tester, keep.id, Copy.actionCompletedClosed);
    await tester.tap(find.byKey(Key('salah-action-menu-${keep.id}')));
    await tester.pumpAndSettle();
    await chooseCircle(tester, leave.id, Copy.deleteAction);
    await tester.tap(find.byKey(Key('salah-action-menu-${leave.id}')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('salah-open-register')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Register keep row'), findsOneWidget);
    expect(find.textContaining('Register leave row'), findsOneWidget);
    await tester.tap(find.byKey(const Key('salah-register-select-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('salah-register-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('salah-register-delete-confirm')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Register keep row'), findsNothing);
    expect(find.textContaining('Register leave row'), findsNothing);
    expect(await actions.allHealthy(), isEmpty);
  });

  testWidgets('adding a sixth chip parks a completed chip from the wash', (
    tester,
  ) async {
    final actions = MemoryDomainActionRepository();
    await pumpHome(tester, actions: actions);
    await expandActions(tester);
    await addAction(tester, 'One');
    await addAction(tester, 'Two');
    await addAction(tester, 'Three');
    await addAction(tester, 'Four');
    await addAction(tester, 'Five');
    final first = (await actions.allHealthy()).firstWhere(
      (action) => action.title == 'One',
    );
    await chooseCircle(tester, first.id, Copy.actionCompletedClosed);
    expect(find.text('One'), findsOneWidget);
    await addAction(tester, 'Six');
    expect(find.text('One'), findsNothing);
    expect(find.text('Six'), findsOneWidget);
  });

  testWidgets('Salah developer notes stay behind + add Note', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final feedback = MemoryDevFeedbackRepository();
    await pumpHome(tester, feedback: feedback);
    await expandNotes(tester);
    expect(find.text(Copy.addDeveloperNote), findsOneWidget);
    expect(find.text(Copy.openNotesRegister), findsOneWidget);
    expect(find.byKey(const Key('salah-open-notes-register')), findsOneWidget);
    expect(find.byKey(const Key('salah-feedback-body')), findsNothing);
    expect(find.byKey(const Key('salah-feedback-save')), findsNothing);

    await tester.tap(find.byKey(const Key('salah-note-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('salah-feedback-body')),
      'The Fajr row is hard to tap.',
    );
    await tester.tap(find.byKey(const Key('salah-feedback-save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Saved as FB-00001 · Salah'), findsOneWidget);
    expect((await feedback.allHealthy()).single.serial, 1);

    await tester.tap(find.byKey(const Key('salah-open-notes-register')));
    await tester.pumpAndSettle();
    expect(find.textContaining('The Fajr row is hard to tap.'), findsOneWidget);

    final first = (await feedback.allHealthy()).single;
    await tester.tap(find.byKey(Key('salah-notes-edit-${first.id}')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('salah-note-edit-body')),
      'The Fajr row needs a larger tap target.',
    );
    await tester.tap(find.byKey(const Key('salah-note-edit-save')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('The Fajr row needs a larger tap target.'),
      findsOneWidget,
    );
    await tester.tap(find.text(Copy.closeActionRegister).last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('salah-note-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('salah-feedback-body')),
      'Keep this note for download.',
    );
    await tester.tap(find.byKey(const Key('salah-feedback-save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('salah-open-notes-register')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('salah-notes-check-${first.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('salah-notes-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('salah-notes-delete-confirm')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('The Fajr row needs a larger tap target.'),
      findsNothing,
    );
    expect(
      (await feedback.allHealthy()).single.body,
      'Keep this note for download.',
    );

    await tester.tap(find.byKey(const Key('salah-notes-download')));
    await tester.pumpAndSettle();
    expect(find.textContaining('FB-00002\tSalah\t2026-10-07'), findsOneWidget);
    expect(find.textContaining('FB-00001\tSalah\t2026-10-07'), findsNothing);
  });

  testWidgets('Qur’an Home lists actions and notes like Salah', (tester) async {
    final actions = MemoryDomainActionRepository();
    final feedback = MemoryDevFeedbackRepository();
    await pumpHome(tester, actions: actions, feedback: feedback);
    await showHomeDomain(tester, MonitorDomain.quran);
    expect(find.byKey(const Key('quran-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('quran-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('quran-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('quran-feedback-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('quran-actions-panel')))
            .color,
      ),
    );

    await tester.tap(find.text(Copy.practiceQuranTitle));
    await tester.pumpAndSettle();
    expect(find.text('HIGHLY RECOMMENDED'), findsNothing);
    expect(find.text(Copy.practiceQuranNote), findsOneWidget);
    expect(find.text(kPracticeQuranCatalog.first.topic), findsOneWidget);
    expect(find.text(kPracticeQuranCatalog.first.arabic), findsOneWidget);
    expect(find.byKey(const Key('quran-practice-source-wash')), findsOneWidget);
    expect(find.byKey(const Key('quran-practice-bring')), findsOneWidget);
    final quranRegister = tester.getRect(
      find.byKey(const Key('quran-practice-open-register')),
    );
    final quranBring = tester.getRect(
      find.byKey(const Key('quran-practice-bring')),
    );
    expect(
      (quranRegister.center.dy - quranBring.center.dy).abs(),
      lessThan(1),
    );
    expect(
      find.text('1 of ${kPracticeQuranCatalog.length}'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('arabic-script-face')), findsOneWidget);
    await tester.tap(find.byKey(const Key('arabic-script-larger')));
    await tester.pumpAndSettle();
    expect(find.text(kPracticeQuranCatalog.first.arabic), findsOneWidget);
    await tester.tap(find.byKey(const Key('quran-practice-next')));
    await tester.pumpAndSettle();
    expect(find.text(kPracticeQuranCatalog[1].arabic), findsOneWidget);
    await tester.tap(find.text(Copy.practiceQuranTitle));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.text(Copy.domainActionsTitle(MonitorDomain.quran.shortLabel)),
    );
    await tester.tap(
      find.text(Copy.domainActionsTitle(MonitorDomain.quran.shortLabel)),
    );
    await tester.pumpAndSettle();
    await addAction(tester, 'Read with meaning after Fajr', prefix: 'quran');
    expect(find.text('Read with meaning after Fajr'), findsOneWidget);
    expect((await actions.allHealthy()).single.domain, MonitorDomain.quran);

    await showHomeDomain(tester, MonitorDomain.salah);
    await expandActions(tester);
    expect(find.text('Read with meaning after Fajr'), findsNothing);

    await showHomeDomain(tester, MonitorDomain.quran);
    await tester.tap(find.text(Copy.developerNotesTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quran-note-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('quran-feedback-body')),
      'The duration row is hard to tap.',
    );
    await tester.tap(find.byKey(const Key('quran-feedback-save')));
    await tester.pumpAndSettle();
    expect((await feedback.allHealthy()).single.domain, MonitorDomain.quran);
  });

  testWidgets('Hadith Home lists actions and notes like Salah', (tester) async {
    final actions = MemoryDomainActionRepository();
    final feedback = MemoryDevFeedbackRepository();
    await pumpHome(
      tester,
      actions: actions,
      feedback: feedback,
      visibleDomains: {
        MonitorDomain.salah,
        MonitorDomain.quran,
        MonitorDomain.hadith,
      },
    );
    await showHomeDomain(tester, MonitorDomain.hadith);
    expect(find.byKey(const Key('hadith-practice-wash')), findsOneWidget);
    expect(find.text(Copy.hadithMemorisationFocus), findsNothing);
    expect(find.byKey(const Key('hadith-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('hadith-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('hadith-feedback-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('hadith-actions-panel')))
            .color,
      ),
    );

    await tester.tap(
      find.text(Copy.domainActionsTitle(MonitorDomain.hadith.shortLabel)),
    );
    await tester.pumpAndSettle();
    await addAction(
      tester,
      'Review a short hadith after Maghrib',
      prefix: 'hadith',
    );
    expect(find.text('Review a short hadith after Maghrib'), findsOneWidget);
    expect((await actions.allHealthy()).single.domain, MonitorDomain.hadith);

    await showHomeDomain(tester, MonitorDomain.salah);
    await expandActions(tester);
    expect(find.text('Review a short hadith after Maghrib'), findsNothing);

    await showHomeDomain(tester, MonitorDomain.hadith);
    await tester.tap(find.text(Copy.developerNotesTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hadith-note-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('hadith-feedback-body')),
      'The duration row is hard to tap.',
    );
    await tester.tap(find.byKey(const Key('hadith-feedback-save')));
    await tester.pumpAndSettle();
    expect((await feedback.allHealthy()).single.domain, MonitorDomain.hadith);
  });

  testWidgets(
    'Hadith to learn & practice adds once and lists in the register',
    (tester) async {
      final register = MemoryPracticeHadithRepository();
      await pumpHome(
        tester,
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.hadith,
        },
      );
      await showHomeDomain(tester, MonitorDomain.hadith);
      expect(find.text(Copy.practiceHadithNote), findsNothing);
      await tester.tap(find.text(Copy.practiceHadithTitle));
      await tester.pumpAndSettle();
      expect(find.text(Copy.practiceHadithNote), findsOneWidget);
      expect(find.byKey(const Key('hadith-practice-source-wash')), findsOneWidget);
      expect(
        find.text('1 of ${kPracticeHadithCatalog.length}'),
        findsOneWidget,
      );
      expect(find.text(kPracticeHadithCatalog.first.text), findsOneWidget);
      expect(find.text(kPracticeHadithCatalog.first.arabic), findsOneWidget);
      expect(
        find.text(kPracticeHadithCatalog.first.translation),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('hadith-practice-next')));
      await tester.pumpAndSettle();
      expect(find.text(kPracticeHadithCatalog[1].arabic), findsOneWidget);
      expect(find.text(kPracticeHadithCatalog[1].translation), findsOneWidget);

      await tester.tap(find.byKey(const Key('hadith-practice-add')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.practiceHadithAdded), findsOneWidget);
      expect(find.text(Copy.practiceHadithAlreadyAdded), findsOneWidget);
      expect(
        (await register.allHealthy()).single.catalogId,
        kPracticeHadithCatalog[1].id,
      );

      await tester.tap(find.byKey(const Key('hadith-practice-add')));
      await tester.pumpAndSettle();
      expect((await register.allHealthy()), hasLength(1));

      await tester.tap(find.byKey(const Key('hadith-practice-open-register')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.practiceHadithRegisterTitle), findsWidgets);
      expect(find.text(kPracticeHadithCatalog[1].arabic), findsWidgets);
      expect(find.text(kPracticeHadithCatalog[1].translation), findsWidgets);
      expect(find.text(Copy.practiceStatusLearning), findsWidgets);
    },
  );

  testWidgets('Dhikr Home lists grouped adhkar, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.dhikr,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.dhikr);
    expect(find.byKey(const Key('dhikr-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('dhikr-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('dhikr-feedback-wash')), findsOneWidget);
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('dhikr-practice-panel')))
          .color,
      domainColorIdentity(MonitorDomain.dhikr).practiceWashFor(Brightness.light),
    );
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('dhikr-practice-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('dhikr-actions-panel')))
            .color,
      ),
    );
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.practiceDhikrNote), findsNothing);

    await tester.tap(find.text(Copy.practiceDhikrTitle));
    await tester.pumpAndSettle();
    expect(find.text('HIGHLY RECOMMENDED'), findsNothing);
    expect(find.text(Copy.practiceDhikrNote), findsOneWidget);
    expect(find.text(displayHomeBand(kDhikrGroupPost)), findsWidgets);
    expect(find.text(displayHomeBand(kDhikrGroupMorning)), findsWidgets);
    expect(find.text(kPracticeDhikrCatalog.first.topic), findsOneWidget);
    expect(find.text(kPracticeDhikrCatalog.first.arabic), findsNothing);

    await tester.tap(find.text(kPracticeDhikrCatalog.first.topic));
    await tester.pumpAndSettle();
    expect(find.text(kPracticeDhikrCatalog.first.arabic), findsOneWidget);
    expect(
      find.text(
        '1 of ${kPracticeDhikrCatalog.where((item) => item.group == kPracticeDhikrCatalog.first.group && item.topic == kPracticeDhikrCatalog.first.topic).length}',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        Key(
          'dhikr-practice-source-wash-${kPracticeDhikrCatalog.first.id}',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        Key('dhikr-practice-source-${kPracticeDhikrCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(Copy.openReflectionSource), findsOneWidget);
    await tester.tap(find.text(Copy.openReflectionSource));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('citation-reader')), findsOneWidget);
    expect(
      (tester.widget<Text>(find.byKey(const Key('citation-uri'))).data ?? ''),
      contains('sunnah.com/muslim:591'),
    );
    await tester.tap(find.byKey(const Key('citation-close')));
    await tester.pumpAndSettle();

    final kursi = kPracticeDhikrCatalog.firstWhere(
      (item) => item.id == 'dh.post.kursi',
    );
    await tester.ensureVisible(find.text(kursi.topic));
    await tester.tap(find.text(kursi.topic));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('dhikr-practice-source-${kursi.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.openReflectionSource));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('citation-page-index')), findsOneWidget);
    expect(find.text('1 of 2'), findsOneWidget);
    expect(
      (tester.widget<Text>(find.byKey(const Key('citation-uri'))).data ?? ''),
      contains('quran.com/2/255'),
    );
    await tester.tap(find.byKey(const Key('citation-next-page')));
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
    expect(
      (tester.widget<Text>(find.byKey(const Key('citation-uri'))).data ?? ''),
      contains('sunnah.com/nasai:7280'),
    );
    await tester.tap(find.byKey(const Key('citation-close')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(Key('dhikr-practice-add-${kPracticeDhikrCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.dhikr);
    expect(find.text(Copy.practiceHadithAlreadyAdded), findsOneWidget);
  });

  testWidgets('Akhlaq Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.akhlaq,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.akhlaq);
    expect(find.byKey(const Key('akhlaq-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('akhlaq-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('akhlaq-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);

    await tester.tap(find.text(Copy.practiceAkhlaqTitle));
    await tester.pumpAndSettle();
    expect(find.text(Copy.openPracticeAkhlaqRegister), findsOneWidget);
    expect(find.text(Copy.practiceAkhlaqNote), findsOneWidget);
    expect(find.text(displayHomeBand(kAkhlaqGroupVirtues)), findsWidgets);
    expect(find.text(displayHomeBand(kAkhlaqGroupAnger)), findsWidgets);
    expect(find.text(kPracticeAkhlaqCatalog.first.topic), findsWidgets);
    expect(find.text(kPracticeAkhlaqCatalog.first.arabic), findsNothing);

    await tester.tap(
      find.byKey(
        Key('akhlaq-practice-item-${kPracticeAkhlaqCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeAkhlaqCatalog.first.arabic), findsOneWidget);
    expect(
      find.text(
        '1 of ${kPracticeAkhlaqCatalog.where((item) => item.topic == kPracticeAkhlaqCatalog.first.topic).length}',
      ),
      findsOneWidget,
    );
    expect(find.text(Copy.practiceAkhlaqNote), findsNothing);
    await tester.tap(find.byKey(const Key('akhlaq-practice-about')));
    await tester.pumpAndSettle();
    expect(find.text(Copy.practiceAkhlaqNote), findsOneWidget);

    await tester.tap(
      find.byKey(Key('akhlaq-practice-add-${kPracticeAkhlaqCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.akhlaq);
  });

  testWidgets('Huquq Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.huquq,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.huquq);
    expect(find.byKey(const Key('huquq-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('huquq-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('huquq-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('huquq-feedback-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('huquq-actions-panel')))
            .color,
      ),
    );

    await tester.tap(find.text(Copy.practiceHuquqTitle));
    await tester.pumpAndSettle();
    expect(find.text(displayHomeBand(kHuquqGroupHousehold)), findsWidgets);
    expect(find.text(displayHomeBand(kHuquqGroupHardship)), findsWidgets);
    expect(find.text(kPracticeHuquqCatalog.first.topic), findsWidgets);
    expect(find.text(kPracticeHuquqCatalog.first.arabic), findsNothing);

    await tester.tap(
      find.byKey(Key('huquq-practice-item-${kPracticeHuquqCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeHuquqCatalog.first.arabic), findsOneWidget);

    await tester.tap(
      find.byKey(Key('huquq-practice-add-${kPracticeHuquqCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.huquq);
  });

  testWidgets('Knowledge Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.knowledge,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.knowledge);
    expect(find.byKey(const Key('knowledge-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('knowledge-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('knowledge-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('knowledge-feedback-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('knowledge-actions-panel')))
            .color,
      ),
    );

    await tester.tap(find.text(Copy.practiceKnowledgeTitle));
    await tester.pumpAndSettle();
    expect(find.text(displayHomeBand(kKnowledgeGroupSeeking)), findsWidgets);
    expect(find.text(displayHomeBand(kKnowledgeGroupSpeech)), findsWidgets);
    expect(find.text(kPracticeKnowledgeCatalog.first.topic), findsWidgets);
    expect(find.text(kPracticeKnowledgeCatalog.first.arabic), findsNothing);

    await tester.tap(
      find.byKey(
        Key('knowledge-practice-item-${kPracticeKnowledgeCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeKnowledgeCatalog.first.arabic), findsOneWidget);

    await tester.tap(
      find.byKey(
        Key('knowledge-practice-add-${kPracticeKnowledgeCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      (await register.allHealthy()).single.domain,
      MonitorDomain.knowledge,
    );
  });

  testWidgets('Time Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.time,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.time);
    expect(find.byKey(const Key('time-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('time-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('time-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('time-feedback-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('time-actions-panel')))
            .color,
      ),
    );

    await tester.tap(find.text(Copy.practiceTimeTitle));
    await tester.pumpAndSettle();
    expect(find.text(displayHomeBand(kPracticeTimeGroups.first)), findsWidgets);
    expect(find.text(displayHomeBand(kPracticeTimeGroups.last)), findsWidgets);
    expect(find.text(kPracticeTimeCatalog.first.topic), findsWidgets);
    expect(find.text(kPracticeTimeCatalog.first.arabic), findsNothing);

    await tester.tap(
      find.byKey(Key('time-practice-item-${kPracticeTimeCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeTimeCatalog.first.arabic), findsOneWidget);

    await tester.tap(
      find.byKey(Key('time-practice-add-${kPracticeTimeCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.time);
  });

  testWidgets('Health Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.health,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.health);
    expect(find.byKey(const Key('health-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('health-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('health-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);
    expect(
      tester
          .widget<WashPanel>(find.byKey(const Key('health-feedback-panel')))
          .color,
      isNot(
        tester
            .widget<WashPanel>(find.byKey(const Key('health-actions-panel')))
            .color,
      ),
    );

    await tester.tap(find.text(Copy.practiceHealthTitle));
    await tester.pumpAndSettle();
    expect(
      find.text(displayHomeBand(kPracticeHealthGroups.first)),
      findsWidgets,
    );
    expect(
      find.text(displayHomeBand(kPracticeHealthGroups.last)),
      findsWidgets,
    );
    expect(find.text(kPracticeHealthCatalog.first.topic), findsWidgets);
    expect(find.text(kPracticeHealthCatalog.first.arabic), findsNothing);
    expect(find.text('HIGHLY RECOMMENDED'), findsNothing);

    await tester.tap(
      find.byKey(
        Key('health-practice-item-${kPracticeHealthCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeHealthCatalog.first.arabic), findsOneWidget);
    expect(find.text('1 of 5'), findsOneWidget);
    final chrome = tester
        .widget<Material>(
          find.ancestor(
            of: find.byKey(
              Key('health-practice-item-${kPracticeHealthCatalog.first.id}'),
            ),
            matching: find.byType(Material),
          ).first,
        )
        .color;
    final source = tester
        .widget<ColoredBox>(
          find.byKey(
            Key(
              'health-practice-source-wash-${kPracticeHealthCatalog.first.id}',
            ),
          ),
        )
        .color;
    expect(chrome, isNot(source));
    await tester.tap(
      find.byKey(
        Key('health-practice-next-${kPracticeHealthCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeHealthCatalog[1].arabic), findsOneWidget);
    expect(find.text('2 of 5'), findsOneWidget);
    await tester.tap(
      find.byKey(
        Key('health-practice-prev-${kPracticeHealthCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeHealthCatalog.first.arabic), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(Key('health-practice-add-${kPracticeHealthCatalog.first.id}')),
    );
    expect(
      find.byKey(
        Key('health-script-smaller-${kPracticeHealthCatalog.first.id}'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        Key('health-script-larger-${kPracticeHealthCatalog.first.id}'),
      ),
      findsOneWidget,
    );
    expect(find.text('A'), findsWidgets);
    await tester.tap(
      find.byKey(Key('health-practice-add-${kPracticeHealthCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.health);

    await tester.ensureVisible(
      find.byKey(const Key('health-practice-group-$kHealthGroupStrength')),
    );
    await tester.tap(
      find.byKey(const Key('health-practice-group-$kHealthGroupStrength')),
    );
    await tester.pumpAndSettle();
    final movement = kPracticeHealthCatalog.firstWhere(
      (item) => item.topic == 'Movement for worship and service',
    );
    await tester.ensureVisible(
      find.byKey(Key('health-practice-item-${movement.id}')),
    );
    await tester.tap(find.byKey(Key('health-practice-item-${movement.id}')));
    await tester.pumpAndSettle();
    expect(find.text(movement.arabic), findsOneWidget);
    expect(find.byKey(Key('health-practice-next-${movement.id}')), findsOneWidget);
  });

  testWidgets('Wealth Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.wealth,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.wealth);
    expect(find.byKey(const Key('wealth-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('wealth-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('wealth-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);

    await tester.tap(find.text(Copy.practiceWealthTitle));
    await tester.pumpAndSettle();
    expect(
      find.text(displayHomeBand(kPracticeWealthGroups.first)),
      findsWidgets,
    );
    expect(
      find.text(displayHomeBand(kPracticeWealthGroups.last)),
      findsWidgets,
    );
    expect(find.text(kPracticeWealthCatalog.first.topic), findsWidgets);
    expect(find.text(kPracticeWealthCatalog.first.arabic), findsNothing);

    await tester.tap(
      find.byKey(
        Key('wealth-practice-item-${kPracticeWealthCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeWealthCatalog.first.arabic), findsOneWidget);

    await tester.tap(
      find.byKey(Key('wealth-practice-add-${kPracticeWealthCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.wealth);
  });

  testWidgets('Ummah Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.ummah,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.ummah);
    expect(find.byKey(const Key('ummah-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('ummah-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('ummah-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);

    await tester.tap(find.text(Copy.practiceUmmahTitle));
    await tester.pumpAndSettle();
    expect(
      find.text(displayHomeBand(kPracticeUmmahGroups.first)),
      findsWidgets,
    );
    expect(find.text(displayHomeBand(kPracticeUmmahGroups.last)), findsWidgets);
    expect(find.text(kPracticeUmmahCatalog.first.topic), findsWidgets);
    expect(find.text(kPracticeUmmahCatalog.first.arabic), findsNothing);

    await tester.tap(
      find.byKey(Key('ummah-practice-item-${kPracticeUmmahCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeUmmahCatalog.first.arabic), findsOneWidget);

    await tester.tap(
      find.byKey(Key('ummah-practice-add-${kPracticeUmmahCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.ummah);
  });

  testWidgets('Fasting Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.fasting,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.fasting);
    expect(find.byKey(const Key('fasting-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('fasting-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('fasting-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);
    expect(find.text(Copy.addAResponse), findsNothing);

    await tester.tap(find.text(Copy.practiceFastingTitle));
    await tester.pumpAndSettle();
    expect(
      find.text(displayHomeBand(kPracticeFastingGroups.first)),
      findsWidgets,
    );
    expect(find.text(kPracticeFastingCatalog.first.topic), findsWidgets);
    expect(find.text(Copy.openPracticeFastingRegister), findsOneWidget);

    await tester.tap(
      find.byKey(
        Key('fasting-practice-item-${kPracticeFastingCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeFastingCatalog.first.arabic), findsOneWidget);

    await tester.tap(
      find.byKey(
        Key('fasting-practice-add-${kPracticeFastingCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.fasting);
  });

  testWidgets('Hajj Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.hajj,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.hajj);
    expect(find.byKey(const Key('hajj-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('hajj-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('hajj-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);

    await tester.tap(find.text(Copy.practiceHajjTitle));
    await tester.pumpAndSettle();
    expect(find.text(displayHomeBand(kPracticeHajjGroups.first)), findsWidgets);
    expect(find.text(kPracticeHajjCatalog.first.topic), findsWidgets);

    await tester.tap(
      find.byKey(Key('hajj-practice-item-${kPracticeHajjCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeHajjCatalog.first.arabic), findsOneWidget);

    await tester.tap(
      find.byKey(Key('hajj-practice-add-${kPracticeHajjCatalog.first.id}')),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.hajj);
  });

  testWidgets('Charity Home lists grouped reminders, actions, and notes', (
    tester,
  ) async {
    final register = MemoryPracticeHadithRepository();
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        practiceHadith: register,
        visibleDomains: {
          MonitorDomain.salah,
          MonitorDomain.quran,
          MonitorDomain.charity,
        },
      ),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.charity);
    expect(find.byKey(const Key('charity-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('charity-actions-wash')), findsOneWidget);
    expect(find.byKey(const Key('charity-feedback-wash')), findsOneWidget);
    expect(find.text(Copy.weeklyJournalTitle), findsNothing);

    await tester.tap(find.text(Copy.practiceCharityTitle));
    await tester.pumpAndSettle();
    expect(
      find.text(displayHomeBand(kPracticeCharityGroups.first)),
      findsWidgets,
    );
    expect(
      find.text(displayHomeBand(kPracticeCharityGroups.last)),
      findsWidgets,
    );
    expect(find.text(kPracticeCharityCatalog.first.topic), findsWidgets);

    await tester.tap(
      find.byKey(
        Key('charity-practice-item-${kPracticeCharityCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(kPracticeCharityCatalog.first.arabic), findsOneWidget);

    await tester.tap(
      find.byKey(
        Key('charity-practice-add-${kPracticeCharityCatalog.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect((await register.allHealthy()).single.domain, MonitorDomain.charity);
  });

  testWidgets('Learn & Practice follows Domains in Focus and the personal mix', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        visibleDomains: kBasicDhikrVisibleDomains,
        personalMix: mixForKind(PersonalMixKind.firstLook),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('salah-practice-wash')), findsOneWidget);
    expect(find.byKey(const Key('huquq-practice-wash')), findsNothing);

    await tester.tap(find.text(Copy.practiceSalahTitle));
    await tester.pumpAndSettle();
    expect(find.text(displayHomeBand(kSalahObligatoryBand)), findsWidgets);
    expect(find.text(displayHomeBand(kSalahVoluntaryBand)), findsNothing);
    expect(find.text('Fajr'), findsWidgets);
    expect(find.text('Tahajjud'), findsNothing);

    await showHomeDomain(tester, MonitorDomain.dhikr);
    await tester.tap(find.text(Copy.practiceDhikrTitle));
    await tester.pumpAndSettle();
    expect(find.text(displayHomeBand(kDhikrGroupPost)), findsWidgets);
    expect(find.text(displayHomeBand(kDhikrGroupMorning)), findsWidgets);
    expect(find.text(displayHomeBand(kDhikrGroupEvening)), findsNothing);
  });

  testWidgets('Dhikr Learn & Practice follows mix rows under Other Adhkar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        now: DateTime(2026, 10, 7),
        visibleDomains: kBasicDhikrVisibleDomains,
        personalMix: mixForKind(
          PersonalMixKind.custom,
          customKeys: {'dhikr.generalDhikr'},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dhikr-practice-wash')), findsOneWidget);
    await tester.tap(find.text(Copy.practiceDhikrTitle));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('dhikr-practice-group-$kDhikrGroupOther')), findsOneWidget);
    expect(find.text(displayHomeBand(kDhikrGroupMorning)), findsNothing);
    expect(find.text(displayHomeBand(kDhikrGroupEvening)), findsNothing);
    expect(find.text(displayHomeBand(kDhikrSubGeneral)), findsWidgets);
    expect(find.text(displayHomeBand(kDhikrSubGratitude)), findsNothing);
    expect(find.text(displayHomeBand(kDhikrSubTravel)), findsNothing);
  });

  testWidgets('Dhikr Learn hides post-fard when Salah is not in Domains in Focus', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final prefs = MemoryAppPrefs(
      visibleDomains: {MonitorDomain.quran, MonitorDomain.dhikr},
      personalMix: PersonalMix.sameAsDomains,
    );
    await tester.pumpWidget(
      testApp(now: DateTime(2026, 10, 7), prefs: prefs),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.dhikr);
    await tester.tap(find.text(Copy.practiceDhikrTitle));
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('dhikr-practice-group-$kDhikrGroupPost')),
      findsNothing,
    );
    expect(
      find.byKey(Key('dhikr-practice-group-$kDhikrGroupMorning')),
      findsOneWidget,
    );
    expect(
      find.byKey(Key('dhikr-practice-group-$kDhikrGroupEvening')),
      findsOneWidget,
    );
    expect(
      find.byKey(Key('dhikr-practice-group-$kDhikrGroupOther')),
      findsOneWidget,
    );

    await prefs.setVisibleDomains(kBasicDhikrVisibleDomains);
    ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    ).read(prefsTickProvider.notifier).state++;
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.dhikr);
    if (find.byKey(const Key('dhikr-practice-group-$kDhikrGroupMorning')).evaluate().isEmpty) {
      await tester.tap(find.text(Copy.practiceDhikrTitle));
      await tester.pumpAndSettle();
    }
    expect(
      find.byKey(Key('dhikr-practice-group-$kDhikrGroupPost')),
      findsOneWidget,
    );
  });
}
