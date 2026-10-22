import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/dhikr_context.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/quran.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';
import 'checkin_home_traces_test.dart';

void main() {
  testWidgets(
    'Dhikr performed lists cover Other Adhkar, morning, and keep unanswered empty',
    (tester) async {
      tester.view.physicalSize = const Size(390, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final checkIns = MemoryCheckInRepository();
      final prefs = MemoryAppPrefs(
        visibleDomains: {MonitorDomain.dhikr, MonitorDomain.salah},
      );
      await tester.pumpWidget(
        testApp(
          checkIns: checkIns,
          prefs: prefs,
          now: DateTime(2026, 10, 20),
          visibleDomains: {MonitorDomain.dhikr, MonitorDomain.salah},
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(Copy.homeCheckIn));
      await tester.pumpAndSettle();
      await showCheckInDomain(tester, MonitorDomain.dhikr);

      await expandCheckInBand(
        tester,
        title: MonitorDomain.dhikr.label,
        band: 'Morning and evening',
      );
      expect(find.text('Morning Adhkar'), findsOneWidget);
      expect(find.text('Ayat al-Kursi in the morning'), findsNothing);
      await tester.ensureVisible(
        find.byKey(const Key('trace-dhikr.morningAdhkar')),
      );
      await tester.tap(find.byKey(const Key('trace-dhikr.morningAdhkar')));
      await tester.pumpAndSettle();
      expect(find.text('Ayat al-Kursi in the morning'), findsOneWidget);
      expect(find.text(Copy.dhikrPerformedHint), findsWidgets);
      expect(find.text('SubhanAllah — Tasbih'), findsNothing);

      await expandCheckInBand(
        tester,
        title: MonitorDomain.dhikr.label,
        band: 'Other remembrance',
      );
      expect(find.text('General Dhikr'), findsOneWidget);
      expect(find.text('Gratitude Dhikr'), findsOneWidget);
      expect(find.text('Travel Remembrance'), findsOneWidget);
      expect(find.text('Personal'), findsWidgets);
      expect(find.text('Other Adhkars'), findsOneWidget);
      expect(find.text('Not recorded'), findsWidgets);

      await tester.ensureVisible(
        find.byKey(const Key('trace-dhikr.generalDhikr')),
      );
      await tester.tap(find.byKey(const Key('trace-dhikr.generalDhikr')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.dhikrPerformedHint), findsWidgets);
      expect(find.text('Add a General Dhikr activity'), findsNothing);
      expect(find.text('SubhanAllah — Tasbih'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('dhikr-pick-dhikr.general.tasbih')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('dhikr-count-dhikr.general.tasbih')),
        '100',
      );
      await tester.pumpAndSettle();
      expect(find.text(Copy.seePonderExplore), findsNothing);
      expect(tester.takeException(), isNull);
      expect(
        tester
            .getSize(find.byKey(const Key('dhikr-count-dhikr.general.tasbih')))
            .width,
        greaterThanOrEqualTo(80),
      );
      await tester.tap(
        find.byKey(const Key('dhikr-pick-dhikr.general.istighfar')),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 performed'), findsOneWidget);
      expect(find.text('Activity description'), findsNothing);
      await tester.tap(
        find.byKey(const Key('dhikr-wording-dhikr.general.tasbih')),
      );
      await tester.pumpAndSettle();
      expect(find.text(Copy.practiceDhikrTitle), findsOneWidget);
      expect(find.text('Learn & Practice · Other Adhkar'), findsOneWidget);
      expect(
        find.byKey(const Key('dhikr-practice-script-face')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dhikr-practice-script-smaller')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dhikr-practice-script-larger')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('dhikr-practice-close')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.dhikrPerformedHint), findsWidgets);
      expect(find.text('2 performed'), findsOneWidget);
      expect(
        find.byKey(const Key('dhikr-add-dhikr.generalDhikr')),
        findsNothing,
      );
      await tester.tap(find.byKey(const Key('checkin-save')));
      await tester.pumpAndSettle();

      final saved = (await checkIns.allHealthy()).single;
      expect(saved.homeTrace(kDhikrGeneralKey), TernaryOutcome.positive);
      expect(saved.dhikrContextFor(kDhikrGeneralKey), hasLength(2));
      expect(saved.dhikrContextFor(kDhikrGeneralKey).first.repetitions, 100);
      expect(saved.homeTrace('dhikr.morningAdhkar'), TernaryOutcome.unanswered);
      expect(prefs.dhikrCountDefaultFor('dhikr.general.tasbih'), 100);
    },
  );

  testWidgets(
    'source sheet shows verified wording and pending istikhara has no formula',
    (tester) async {
      tester.view.physicalSize = const Size(390, 4200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(
          now: DateTime(2026, 10, 20),
          visibleDomains: {MonitorDomain.dhikr, MonitorDomain.salah},
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(Copy.homeCheckIn));
      await tester.pumpAndSettle();
      await showCheckInDomain(tester, MonitorDomain.dhikr);
      await expandCheckInBand(
        tester,
        title: MonitorDomain.dhikr.label,
        band: 'Other remembrance',
      );

      await tester.ensureVisible(
        find.byKey(const Key('trace-dhikr.personalDhikr')),
      );
      await tester.tap(find.byKey(const Key('trace-dhikr.personalDhikr')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.relatedWordingAvailable), findsWidgets);
      expect(
        find.byKey(const Key('dhikr-wording-dhikr.personal.forgiveness')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dhikr-wording-dhikr.personal.istikhara')),
        findsNothing,
      );
      await tester.tap(
        find.byKey(const Key('dhikr-pick-dhikr.personal.rabbanaAtina')),
      );
      await tester.pumpAndSettle();
      final wording = find.byKey(
        const Key('dhikr-wording-dhikr.personal.rabbanaAtina'),
      );
      await tester.ensureVisible(wording);
      await tester.pumpAndSettle();
      await tester.tap(wording);
      await tester.pumpAndSettle();
      expect(find.textContaining('Qur’an 2:201'), findsWidgets);
      expect(find.text(Copy.practiceDhikrTitle), findsOneWidget);
      expect(
        find.byKey(const Key('dhikr-practice-script-face')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('dhikr-practice-close')));
      await tester.pumpAndSettle();
      expect(find.text('1 performed'), findsOneWidget);
    },
  );

  testWidgets(
    'Other Adhkar editor has a screen-reader label and survives 1.5 text scale',
    (tester) async {
      tester.view.physicalSize = const Size(360, 2800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        testApp(
          now: DateTime(2026, 10, 20),
          visibleDomains: {MonitorDomain.dhikr, MonitorDomain.salah},
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(Copy.homeCheckIn));
      await tester.pumpAndSettle();
      await showCheckInDomain(tester, MonitorDomain.dhikr);
      await expandCheckInBand(
        tester,
        title: MonitorDomain.dhikr.label,
        band: 'Other remembrance',
      );
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(RegExp('General Dhikr')), findsWidgets);
    },
  );

  testWidgets(
    'Adhkar performed-list sheets omit evidence and response buttons',
    (tester) async {
      tester.view.physicalSize = const Size(390, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(
          now: DateTime(2026, 10, 20),
          visibleDomains: {MonitorDomain.dhikr, MonitorDomain.salah},
        ),
      );
      await tester.pumpAndSettle();
      await expandActiveDomainMix(tester);
      await tester.ensureVisible(find.byKey(const Key('today-domain-dhikr')));
      await tester.tap(find.byKey(const Key('today-domain-dhikr')));
      await tester.pumpAndSettle();
      final morning = find.byKey(const Key('today-row-dhikr.morningAdhkar'));
      await tester.ensureVisible(morning);
      await tester.tap(morning);
      await tester.pumpAndSettle();
      expect(find.text('Verified wording available'), findsWidgets);
      expect(find.text('Open recorded evidence'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(Copy.addAResponse),
        ),
        findsNothing,
      );
    },
  );
}
