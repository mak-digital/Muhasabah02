import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/hajj_pathway.dart';
import 'package:muhasabah02/domain/hajj_planning_windows.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/presentation/home/hajj_lunar_date_picker.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('rites picker opens Dhul-Hijjah with a shaded window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  chosen = await showHajjLunarDatePicker(
                    context: context,
                    kind: HajjLunarPickerKind.ritesStart,
                    hijriYear: 1447,
                  );
                },
                child: const Text('open-rites'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-rites'));
    await tester.pumpAndSettle();

    expect(find.text('Dhul-Hijjah 1447'), findsOneWidget);
    final window = hajjRitesPlanningWindow(1447);
    expect(
      find.byKey(Key('hajj-lunar-day-${window.start.dateKeyValue}')),
      findsOneWidget,
    );
    expect(find.textContaining('Use 8 Dhul-Hijjah'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hajj-lunar-use-typical')));
    await tester.pumpAndSettle();
    expect(chosen, window.start.dateKeyValue);
  });

  testWidgets('rites picker stays within a narrow 1.5x text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          );
        },
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showHajjLunarDatePicker(
                    context: context,
                    kind: HajjLunarPickerKind.ritesEnd,
                    hijriYear: 1447,
                  );
                },
                child: const Text('open-end'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-end'));
    await tester.pumpAndSettle();
    expect(find.text('Dhul-Hijjah 1447'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-lunar-use-typical')),
      80,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('hajj-lunar-use-typical')));
    await tester.pumpAndSettle();
  });

  testWidgets('registration picker uses pathway typical estimate', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? chosen;
    final estimate = hajjRegistrationEstimate(
      family: HajjPathwayFamily.nationalMission,
      hijriYear: 1447,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  chosen = await showHajjLunarDatePicker(
                    context: context,
                    kind: HajjLunarPickerKind.regOpen,
                    hijriYear: 1447,
                    pathway: HajjPathwayFamily.nationalMission,
                  );
                },
                child: const Text('open-reg'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-reg'));
    await tester.pumpAndSettle();

    expect(find.text('Rajab 1447'), findsOneWidget);
    expect(find.textContaining('Use typical estimate'), findsOneWidget);
    await tester.tap(find.byKey(const Key('hajj-lunar-use-typical')));
    await tester.pumpAndSettle();
    expect(chosen, estimate.suggestedOpen.dateKeyValue);
  });

  testWidgets('Edit plan date fields open lunar calendars and keep estimates', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 12000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(now: DateTime(2026, 10, 17), visibleDomains: allVisibleDomains()),
    );
    await tester.pumpAndSettle();
    await showHomeDomain(tester, MonitorDomain.hajj);
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-create-journey')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('hajj-create-journey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-season-undecided')));
    await tester.enterText(find.byKey(const Key('hajj-season-year')), '1447');
    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-period-start')),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('hajj-period-start')));
    await tester.pumpAndSettle();
    expect(find.text('Dhul-Hijjah 1447'), findsOneWidget);
    await tester.tap(find.byKey(const Key('hajj-lunar-use-typical')));
    await tester.pumpAndSettle();
    final rites = hajjRitesPlanningWindow(1447);
    expect(find.text(rites.start.dateKeyValue), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('hajj-planning-pathway')),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('hajj-planning-pathway')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(HajjPathwayFamily.nationalMission.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hajj-reg-open')));
    await tester.pumpAndSettle();
    expect(find.text('Rajab 1447'), findsOneWidget);
    await tester.tap(find.byKey(const Key('hajj-lunar-use-typical')));
    await tester.pumpAndSettle();
    final estimate = hajjRegistrationEstimate(
      family: HajjPathwayFamily.nationalMission,
      hijriYear: 1447,
    );
    expect(find.text(estimate.suggestedOpen.dateKeyValue), findsWidgets);
    await tester.tap(find.byKey(const Key('hajj-journey-save')));
    await tester.pumpAndSettle();
  });
}
