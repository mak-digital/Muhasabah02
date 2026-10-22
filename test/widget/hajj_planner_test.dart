import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  Future<void> openHajj(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 12000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(now: DateTime(2026, 10, 17), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.hajj);
  }

  testWidgets('Hajj Home invites a plan and keeps Learn without a journey', (
    tester,
  ) async {
    await openHajj(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-create-journey')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(Copy.hajjJourneyInvite), findsWidgets);
    expect(find.text(Copy.practiceHajjTitle), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-learning-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('hajj-learning-card')));
    await tester.pumpAndSettle();
    expect(find.text('Conditions and significance of Hajj'), findsWidgets);
  });

  testWidgets('Hajj journey, travelers, readiness and horizon persist in UI', (
    tester,
  ) async {
    await openHajj(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-create-journey')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('hajj-create-journey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-journey-save')));
    await tester.pumpAndSettle();
    expect(find.text('Season undecided'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-family-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(Copy.hajjFamilySection));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-add-traveler')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('hajj-traveler-nationality')),
      'GB',
    );
    await tester.enterText(
      find.byKey(const Key('hajj-traveler-residence')),
      'AE',
    );
    await tester.tap(find.byKey(const Key('hajj-traveler-save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nationality GB'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-calendar-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(Copy.hajjCalendarSection));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-horizon-12')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hajj-horizon-12')), findsOneWidget);
  });

  testWidgets('readiness details and independent traveler checklists persist', (
    tester,
  ) async {
    await openHajj(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-create-journey')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('hajj-create-journey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-journey-save')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-readiness-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(Copy.hajjReadinessSection));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('hajj-ready-details-rdy.passport.valid')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('hajj-ready-target-rdy.passport.valid')),
      '2026-11-15',
    );
    await tester.tap(
      find.byKey(const Key('hajj-ready-official-rdy.passport.valid')),
    );
    await tester.tap(
      find.byKey(const Key('hajj-ready-save-rdy.passport.valid')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Target 2026-11-15'), findsWidgets);
    expect(find.textContaining(Copy.hajjOfficialVerifiedLabel), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-family-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(Copy.hajjFamilySection));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-add-traveler')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('hajj-traveler-nationality')),
      'GB',
    );
    await tester.tap(find.byKey(const Key('hajj-traveler-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-add-traveler')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('hajj-traveler-nationality')),
      'PK',
    );
    await tester.tap(find.byKey(const Key('hajj-traveler-save')));
    await tester.pumpAndSettle();
    expect(find.text('Passport validity'), findsNWidgets(2));
  });

  testWidgets('milestone prerequisite picker blocks a dependency loop', (
    tester,
  ) async {
    await openHajj(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-create-journey')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('hajj-create-journey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-journey-save')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-calendar-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(Copy.hajjCalendarSection));
    await tester.pumpAndSettle();

    Future<void> addMilestone(String name, String deadline) async {
      await tester.tap(find.byKey(const Key('hajj-add-milestone')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('hajj-milestone-title')),
        name,
      );
      await tester.enterText(
        find.byKey(const Key('hajj-milestone-official')),
        deadline,
      );
      await tester.tap(find.byKey(const Key('hajj-milestone-save')));
      await tester.pumpAndSettle();
    }

    await addMilestone('Apply', '2026-12-01');
    await addMilestone('Travel', '2026-12-15');
    final milestoneTiles = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> && key.value.startsWith('hajj-milestone-');
    });
    expect(milestoneTiles, findsNWidgets(2));
    await tester.tap(milestoneTiles.last);
    await tester.pumpAndSettle();
    expect(find.text('Prerequisites'), findsOneWidget);
    final depTiles = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> && key.value.startsWith('hajj-dep-');
    });
    await tester.tap(depTiles);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-milestone-save')));
    await tester.pumpAndSettle();
    await tester.tap(milestoneTiles.first);
    await tester.pumpAndSettle();
    await tester.tap(depTiles);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hajj-dep-cycle')), findsOneWidget);
    expect(find.text(Copy.hajjDependencyCycle), findsOneWidget);
  });

  testWidgets(
    'empty and invalid milestones are rejected; unscheduled can save',
    (tester) async {
      await openHajj(tester);
      await tester.scrollUntilVisible(
        find.byKey(const Key('hajj-create-journey')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('hajj-create-journey')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hajj-journey-save')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('hajj-calendar-card')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(Copy.hajjCalendarSection));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hajj-add-milestone')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hajj-milestone-save')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.hajjMilestoneTitleRequired), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('hajj-milestone-title')),
        'Apply',
      );
      await tester.tap(find.byKey(const Key('hajj-milestone-save')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.hajjMilestoneDateRequired), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('hajj-milestone-official')),
        '17/10/2026',
      );
      await tester.tap(find.byKey(const Key('hajj-milestone-save')));
      await tester.pumpAndSettle();
      expect(find.text(Copy.hajjMilestoneDateInvalid), findsOneWidget);
      await tester.tap(find.byKey(const Key('hajj-milestone-unscheduled')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hajj-milestone-save')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hajj-milestone-save')), findsNothing);
      expect(find.text('Apply'), findsWidgets);
    },
  );

  testWidgets('Family stays reachable without expanding the month list', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openHajj(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-create-journey')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('hajj-create-journey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-journey-save')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-family-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('hajj-family-card')), findsOneWidget);
    expect(find.byKey(const Key('hajj-learning-card')), findsOneWidget);
    expect(find.byKey(const Key('hajj-after-card')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-calendar-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(Copy.hajjCalendarSection));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hajj-past-milestones')), findsOneWidget);
    expect(find.byKey(const Key('hajj-beyond-horizon')), findsOneWidget);
    expect(
      find.byKey(const Key('hajj-unscheduled-milestones')),
      findsOneWidget,
    );
    expect(find.text(Copy.appName), findsWidgets);
  });

  testWidgets(
    'pathways need confirmation and templates stay planning estimates',
    (tester) async {
      await openHajj(tester);
      await tester.scrollUntilVisible(
        find.byKey(const Key('hajj-create-journey')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('hajj-create-journey')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('hajj-departure-country')),
        'GB',
      );
      await tester.enterText(
        find.byKey(const Key('hajj-depart-date')),
        '2027-05-20',
      );
      await tester.tap(find.byKey(const Key('hajj-journey-save')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('hajj-family-card')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(Copy.hajjFamilySection));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hajj-add-traveler')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('hajj-traveler-nationality')),
        'GB',
      );
      await tester.enterText(
        find.byKey(const Key('hajj-traveler-residence')),
        'AE',
      );
      await tester.tap(find.byKey(const Key('hajj-traveler-save')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('hajj-pathway-card')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(Copy.hajjPathwaySection));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hajj-pathway-confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hajj-pathway-expatriate')));
      await tester.tap(find.byKey(const Key('hajj-pathway-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Expatriate'), findsWidgets);
      await tester.scrollUntilVisible(
        find.byKey(const Key('hajj-apply-templates')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('hajj-apply-templates')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('hajj-calendar-card')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(Copy.hajjCalendarSection));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'Registration route verification',
          skipOffstage: false,
        ),
        findsWidgets,
      );
    },
  );

  testWidgets('online assistance stays off until consent and review', (
    tester,
  ) async {
    await openHajj(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-create-journey')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('hajj-create-journey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-journey-save')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-online-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(Copy.hajjOnlineSection));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('hajj-online-lookup')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('hajj-consent-lookup')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-online-lookup')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-sources-card')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(Copy.hajjSourcesSection));
    await tester.pumpAndSettle();
    expect(find.textContaining('Unverified'), findsWidgets);
    expect(find.textContaining('Demonstration catalog'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-consent-ai')),
      -240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('hajj-consent-ai')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-online-ai')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ask your mission'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-proposal-accept-prop.demo.2026-10-17')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const Key('hajj-proposal-accept-prop.demo.2026-10-17')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Accepted'), findsWidgets);
  });
}
