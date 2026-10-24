import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/app.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/codecs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/domain_action.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/productivity_planning.dart';
import 'package:muhasabah02/presentation/settings/productivity_settings.dart';
import 'package:muhasabah02/presentation/settings/settings_screen.dart';

import '../support/home_domain_stage.dart';
import '../support/test_app.dart';

ProductivityAction _sample({
  required String id,
  required String title,
  bool today = true,
  ProductivityStatus status = ProductivityStatus.notStarted,
  ProductivityPriority priority = ProductivityPriority.medium,
  String? parentId,
  List<String> prerequisiteIds = const [],
  List<ProductivitySubtask> subtasks = const [],
  double hours = 1,
  double doneHours = 0,
  String? targetDateKey,
  int sortOrder = 0,
}) {
  return ProductivityAction(
    id: id,
    title: title,
    createdAt: DateTime(2026, 10, 18, 9),
    today: today,
    status: status,
    priority: priority,
    parentId: parentId,
    prerequisiteIds: prerequisiteIds,
    subtasks: subtasks,
    hours: hours,
    doneHours: doneHours,
    targetDateKey: targetDateKey,
    sortOrder: sortOrder,
    synthetic: true,
  );
}

Set<MonitorDomain> _shown() => {
  MonitorDomain.salah,
  MonitorDomain.quran,
  MonitorDomain.dhikr,
  MonitorDomain.productivity,
};

Future<void> _openDashboard(
  WidgetTester tester, {
  MemoryProductivityStoreRepository? store,
  MemoryDomainActionRepository? domainActions,
  Size size = const Size(400, 2400),
  int? themeMode,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    testApp(
      now: DateTime(2026, 10, 18, 10),
      visibleDomains: _shown(),
      productivityStore: store,
      domainActions: domainActions,
    ),
  );
  await tester.pumpAndSettle();
  if (themeMode != null) {
    ProviderScope.containerOf(tester.element(find.byType(MuhasabahApp)))
            .read(themeModePrefProvider.notifier)
            .state =
        themeMode;
    await tester.pumpAndSettle();
  }
  await showHomeDomain(tester, MonitorDomain.productivity);
  await tester.pump();
  await tester.pumpAndSettle();
  final dashboard = find.byKey(const Key('productivity-dashboard'));
  if (dashboard.evaluate().isNotEmpty) {
    await tester.ensureVisible(dashboard);
    await tester.pumpAndSettle();
  }
}

Future<void> _openTodayMenu(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('productivity-today-menu')));
  await tester.tap(find.byKey(const Key('productivity-today-menu')));
  await tester.pumpAndSettle();
}

Future<void> _openProductivitySettings(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Settings'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const Key('settings-productivity')));
  await tester.tap(find.byKey(const Key('settings-productivity')));
  await tester.pumpAndSettle();
}

Future<void> _chooseTodaySlots(WidgetTester tester, int n) async {
  await _openProductivitySettings(tester);
  await tester.tap(find.byKey(const Key('productivity-today-slots')));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(DropdownMenuItem<int>),
      matching: find.text('$n'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('W1 shown domain opens the Productivity dashboard', (
    tester,
  ) async {
    await _openDashboard(tester);
    expect(find.byKey(const Key('productivity-dashboard')), findsOneWidget);
    expect(find.text('Nothing queued'), findsOneWidget);
    expect(find.text('Today’s Actions (0 of 5)'), findsOneWidget);
    expect(find.text(Copy.productivityDailyActions), findsNothing);
    expect(find.byKey(const Key('productivity-today-menu')), findsOneWidget);
  });

  testWidgets('today’s board shows queued actions without empty slots', (
    tester,
  ) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [_sample(id: 'a', title: 'Alpha')],
        ),
      ),
    );
    expect(find.byKey(const Key('productivity-action-a')), findsOneWidget);
    expect(find.text('Today’s Actions (1 of 5)'), findsOneWidget);
    expect(find.byKey(const Key('productivity-slot-2')), findsNothing);
  });

  testWidgets('W2 add action appears in today and the register', (
    tester,
  ) async {
    await _openDashboard(tester);
    await _openTodayMenu(tester);
    await tester.tap(find.byKey(const Key('productivity-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('productivity-add-title')),
      'Write weekly note',
    );
    await tester.tap(find.byKey(const Key('productivity-add-save')));
    await tester.pumpAndSettle();
    expect(find.text('Write weekly note'), findsWidgets);
  });

  testWidgets('three new actions all stay in the register', (tester) async {
    final store = MemoryProductivityStoreRepository(
      store: const ProductivityStore(lastRolloverDateKey: '2026-10-18'),
    );
    await _openDashboard(tester, store: store);
    for (final title in ['One', 'Two', 'Three']) {
      await _openTodayMenu(tester);
      await tester.tap(find.byKey(const Key('productivity-add')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('productivity-add-title')),
        title,
      );
      await tester.tap(find.byKey(const Key('productivity-add-save')));
      await tester.pumpAndSettle();
    }
    expect(store.store.actions.length, 3);
    expect(find.text('Three'), findsWidgets);
    expect(find.text('One'), findsWidgets);
  });

  testWidgets('W3 today five reorder up and down', (tester) async {
    final store = MemoryProductivityStoreRepository(
      store: ProductivityStore(
        lastRolloverDateKey: '2026-10-18',
        actions: [
          _sample(id: 'a', title: 'Alpha', sortOrder: 0),
          _sample(id: 'b', title: 'Beta', sortOrder: 1),
        ],
      ),
    );
    await _openDashboard(tester, store: store);
    await tester.tap(find.byKey(const Key('productivity-menu-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('productivity-move-down-a')));
    await tester.pumpAndSettle();
    expect(store.store.todayActions.first.id, 'b');
    await tester.tap(find.byKey(const Key('productivity-menu-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('productivity-move-up-a')));
    await tester.pumpAndSettle();
    expect(store.store.todayActions.first.id, 'a');
  });

  testWidgets('W4 priority changes on the card without a new route', (
    tester,
  ) async {
    final store = MemoryProductivityStoreRepository(
      store: ProductivityStore(
        lastRolloverDateKey: '2026-10-18',
        actions: [_sample(id: 'a', title: 'Alpha')],
      ),
    );
    await _openDashboard(tester, store: store);
    await tester.tap(find.byKey(const Key('productivity-menu-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('productivity-priority-a')));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.priority, ProductivityPriority.low);
    await tester.tap(find.byKey(const Key('productivity-menu-a')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Low'), findsWidgets);
  });

  testWidgets('W5 start pause resume complete stay on the card', (
    tester,
  ) async {
    final store = MemoryProductivityStoreRepository(
      store: ProductivityStore(
        lastRolloverDateKey: '2026-10-18',
        actions: [_sample(id: 'a', title: 'Alpha')],
      ),
    );
    await _openDashboard(tester, store: store);
    await tester.tap(find.byKey(const Key('productivity-status-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In progress').last);
    await tester.pumpAndSettle();
    expect(store.store.actions.single.status, ProductivityStatus.inProgress);
    await tester.tap(find.byKey(const Key('productivity-status-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paused').last);
    await tester.pumpAndSettle();
    expect(store.store.actions.single.status, ProductivityStatus.paused);
    await tester.tap(find.byKey(const Key('productivity-status-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In progress').last);
    await tester.pumpAndSettle();
    expect(store.store.actions.single.status, ProductivityStatus.inProgress);
    await tester.tap(find.byKey(const Key('productivity-complete-a')));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.status, ProductivityStatus.completed);
    expect(store.store.actions.single.percent, 100);
    expect(store.store.actions.single.today, isTrue);
    expect(find.byKey(const Key('productivity-action-a')), findsOneWidget);
  });

  testWidgets('focus percent matches the list status', (tester) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(id: 'a', title: 'Ahmad Insurance', hours: 5, doneHours: 5),
          ],
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productivity-focus')),
        matching: find.text('Current focus (Today’s focus)'),
      ),
      findsOneWidget,
    );
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Complete'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('productivity-focus')),
        matching: find.text('0%'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productivity-focus')),
        matching: find.text('3 Medium'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productivity-focus')),
        matching: find.text('Not started'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productivity-action-a')),
        matching: find.text('0%'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productivity-action-a')),
        matching: find.text('Not started'),
      ),
      findsOneWidget,
    );
    expect(find.text('100%'), findsNothing);
  });

  testWidgets('W6 expand shows child and grandchild', (tester) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(id: 'p', title: 'Parent'),
            _sample(id: 'c', title: 'Child row', parentId: 'p', today: false),
            _sample(
              id: 'g',
              title: 'Grandchild row',
              parentId: 'c',
              today: false,
            ),
          ],
        ),
      ),
    );
    expect(find.text('Child row'), findsNothing);
    await tester.tap(find.byKey(const Key('productivity-expand-p')));
    await tester.pumpAndSettle();
    expect(find.text('Child row'), findsOneWidget);
    expect(find.text('Grandchild row'), findsNothing);
    await tester.tap(find.byKey(const Key('productivity-expand-c')));
    await tester.pumpAndSettle();
    expect(find.text('Grandchild row'), findsOneWidget);
  });

  testWidgets('expanding one today row does not open another', (tester) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(id: 'a', title: 'Alpha', sortOrder: 0),
            _sample(id: 'b', title: 'Beta', sortOrder: 1),
            _sample(
              id: 'ac',
              title: 'Alpha child',
              parentId: 'a',
              today: false,
            ),
            _sample(id: 'bc', title: 'Beta child', parentId: 'b', today: false),
          ],
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('productivity-expand-a')));
    await tester.pumpAndSettle();
    expect(find.text('Alpha child'), findsOneWidget);
    expect(find.text('Beta child'), findsNothing);
  });

  testWidgets('arrow reveals sub-activities under that action only', (
    tester,
  ) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(
              id: 'a',
              title: 'Alpha',
              subtasks: const [
                ProductivitySubtask(title: 'Draft step', hours: 1, percent: 20),
              ],
            ),
          ],
        ),
      ),
    );
    expect(find.text('Draft step'), findsNothing);
    await tester.tap(find.byKey(const Key('productivity-expand-a')));
    await tester.pumpAndSettle();
    expect(find.text('Draft step'), findsOneWidget);
    expect(
      find.byKey(const Key('productivity-action-group-a')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productivity-action-group-a')),
        matching: find.byKey(const Key('productivity-subtask-row-a-0')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('details rolls sub-activity progress onto the parent card', (
    tester,
  ) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(
              id: 'a',
              title: 'Alpha',
              subtasks: const [
                ProductivitySubtask(
                  title: 'Draft',
                  weight: 40,
                  percent: 50,
                  hours: 1,
                ),
                ProductivitySubtask(
                  title: 'Review',
                  weight: 60,
                  percent: 100,
                  hours: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    expect(find.textContaining('80%'), findsWidgets);
    await tester.tap(find.byKey(const Key('productivity-details-a')));
    await tester.pumpAndSettle();
    expect(find.text('Draft'), findsWidgets);
    expect(find.text('Review'), findsWidgets);
    await tester.tap(find.byKey(const Key('productivity-add-subtask-a')));
    await tester.pumpAndSettle();
    expect(find.text('Sub-activity 3'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('productivity-subtask-title-a-0')),
      'Outline draft',
    );
    await tester.tap(find.byKey(const Key('productivity-details-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('productivity-details-a')));
    await tester.pumpAndSettle();
    expect(find.text('Outline draft'), findsWidgets);
  });

  testWidgets('six dots save hours and percent on a main action', (
    tester,
  ) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [_sample(id: 'a', title: 'Alpha')],
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('productivity-details-a')));
    await tester.pumpAndSettle();
    expect(find.text('Progress details'), findsOneWidget);
    await tester.tap(find.byKey(const Key('productivity-hours-inc-a')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('productivity-details-save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('1h 15m'), findsWidgets);
  });

  testWidgets('six dots on a sub-item save share and percent', (tester) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(
              id: 'a',
              title: 'Alpha',
              subtasks: const [
                ProductivitySubtask(
                  title: 'Draft step',
                  weight: 100,
                  percent: 20,
                  hours: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('productivity-expand-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('productivity-subtask-details-a-0')));
    await tester.pumpAndSettle();
    expect(find.text('Sub-item progress'), findsOneWidget);
    expect(find.textContaining('Share of the main action'), findsWidgets);
    await tester.enterText(
      find.byKey(const Key('productivity-subtask-title-a-0')),
      'Named draft',
    );
    await tester.tap(find.byKey(const Key('productivity-subtask-save-a-0')));
    await tester.pumpAndSettle();
    expect(find.text('Named draft'), findsWidgets);
  });

  testWidgets('W7 MAL can place an item into today', (tester) async {
    final listed = DomainAction(
      id: 'health-clinic-1',
      domain: MonitorDomain.health,
      title: 'From list',
      targetDateKey: '2026-10-20',
      priority: ActionPriority.soon,
      status: ActionStatus.open,
      createdAt: DateTime(2026, 10, 12, 8),
    );
    final store = MemoryProductivityStoreRepository(
      store: const ProductivityStore(lastRolloverDateKey: '2026-10-18'),
    );
    await _openDashboard(
      tester,
      store: store,
      domainActions: MemoryDomainActionRepository(
        raw: {listed.id: encodeDomainAction(listed)},
      ),
    );
    await _openTodayMenu(tester);
    await tester.tap(find.byKey(const Key('productivity-pick-mal')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('productivity-mal-pick-health-clinic-1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('productivity-mal-import')));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.title, 'From list');
    expect(store.store.actions.single.today, isTrue);
    expect(store.store.actions.single.sourceActionId, listed.id);
    expect(find.text('From list'), findsWidgets);
  });

  testWidgets('today slot chips hide then restore nominated actions', (
    tester,
  ) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(id: 'a', title: 'Alpha', sortOrder: 0),
            _sample(id: 'b', title: 'Beta', sortOrder: 1),
            _sample(id: 'c', title: 'Gamma', sortOrder: 2),
          ],
        ),
      ),
    );
    await _chooseTodaySlots(tester, 2);
    expect(find.byKey(const Key('productivity-action-a')), findsOneWidget);
    expect(find.byKey(const Key('productivity-action-b')), findsOneWidget);
    expect(find.byKey(const Key('productivity-action-c')), findsNothing);
    await _chooseTodaySlots(tester, 5);
    expect(find.byKey(const Key('productivity-action-c')), findsOneWidget);
  });

  testWidgets('completing a today action offers pending register copy', (
    tester,
  ) async {
    final store = MemoryProductivityStoreRepository(
      store: ProductivityStore(
        lastRolloverDateKey: '2026-10-18',
        actions: [
          _sample(id: 'a', title: 'Alpha'),
          _sample(id: 'p', title: 'Pending note', today: false),
        ],
      ),
    );
    await _openDashboard(tester, store: store);
    await tester.tap(find.byKey(const Key('productivity-complete-a')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('productivity-register-sheet')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('productivity-register-row-p')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('productivity-register-import')));
    await tester.pumpAndSettle();
    expect(
      store.store.actions.firstWhere((action) => action.id == 'a').today,
      isTrue,
    );
    expect(
      store.store.actions.firstWhere((action) => action.id == 'a').status,
      ProductivityStatus.completed,
    );
    expect(
      store.store.actions.firstWhere((action) => action.id == 'p').today,
      isTrue,
    );
  });

  testWidgets('W8 history lists a completion event', (tester) async {
    final store = MemoryProductivityStoreRepository(
      store: ProductivityStore(
        lastRolloverDateKey: '2026-10-18',
        actions: [_sample(id: 'a', title: 'Alpha')],
      ),
    );
    await _openDashboard(tester, store: store);
    await tester.tap(find.byKey(const Key('productivity-complete-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('productivity-history')));
    await tester.pumpAndSettle();
    expect(find.text('completed'), findsWidgets);
  });

  testWidgets('W9 blocked card names the prerequisite', (tester) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(id: 'need', title: 'Need this first', today: false),
            _sample(
              id: 'blocked',
              title: 'Waiting item',
              prerequisiteIds: const ['need'],
            ),
          ],
        ),
      ),
    );
    expect(find.textContaining('Need this first'), findsWidgets);
  });

  testWidgets('W10 carry-forward notice after a date-key change', (
    tester,
  ) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-17',
          actions: [_sample(id: 'open', title: 'Still open')],
        ),
      ),
    );
    expect(find.byKey(const Key('productivity-carry-notice')), findsNothing);
    expect(find.text('Still open'), findsWidgets);
    await _openProductivitySettings(tester);
    expect(find.byType(ProductivitySettingsScreen), findsOneWidget);
    expect(find.text(Copy.productivityDailyActions), findsOneWidget);
    expect(find.text(Copy.productivityCarryForwardInfo), findsOneWidget);
    expect(find.byKey(const Key('productivity-carry-info')), findsOneWidget);
  });

  testWidgets('W11 empty state has Add and does not crash', (tester) async {
    await _openDashboard(tester);
    expect(find.byKey(const Key('productivity-today-menu')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('W12 360 by 800 at 1.5 scale does not overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _openDashboard(
      tester,
      size: const Size(360, 800),
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(
              id: 'a',
              title: 'A fairly long action title for the narrow phone',
              priority: ProductivityPriority.critical,
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('W13 dark theme still shows priority words', (tester) async {
    await _openDashboard(
      tester,
      themeMode: 2,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(
              id: 'a',
              title: 'Alpha',
              priority: ProductivityPriority.high,
            ),
          ],
        ),
      ),
    );
    expect(
      find.byKey(const Key('productivity-priority-chip-a')),
      findsOneWidget,
    );
    expect(find.textContaining('2 High'), findsWidgets);
  });

  testWidgets('planner shows weekday letters and daily-list priority lines', (
    tester,
  ) async {
    await _openDashboard(
      tester,
      store: MemoryProductivityStoreRepository(
        store: ProductivityStore(
          lastRolloverDateKey: '2026-10-18',
          actions: [
            _sample(
              id: 'a',
              title: 'Alpha',
              priority: ProductivityPriority.critical,
              targetDateKey: '2026-10-20',
            ),
            _sample(
              id: 'b',
              title: 'Register only',
              today: false,
              priority: ProductivityPriority.low,
              targetDateKey: '2026-10-21',
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('productivity-planner')), findsOneWidget);
    expect(
      find.byKey(const Key('productivity-planner-weekday-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('productivity-planner-mark-2026-10-18-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('productivity-planner-mark-2026-10-18-0-start')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('productivity-planner-mark-2026-10-18-0-progress')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('productivity-planner-mark-2026-10-20-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('productivity-planner-mark-2026-10-20-0-end')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('productivity-planner-mark-2026-10-21-0')),
      findsNothing,
    );
    expect(find.text('October 2026'), findsOneWidget);
    await tester.tap(find.byKey(const Key('productivity-planner-next')));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    expect(
      find.byKey(const Key('productivity-planner-mark-2026-10-18-0')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('productivity-planner-prev')));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    expect(
      find.byKey(const Key('productivity-planner-mark-2026-10-18-0')),
      findsOneWidget,
    );
  });

  testWidgets('tablet width shows the side column', (tester) async {
    await _openDashboard(tester, size: const Size(800, 1280));
    expect(find.byKey(const Key('productivity-tablet-side')), findsOneWidget);
    expect(find.text('Today’s time'), findsWidgets);
    expect(find.textContaining('Critical'), findsWidgets);
  });

  testWidgets('S1 Productivity is off on Salah, Qur’an & Dhikr', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApp(now: DateTime(2026, 10, 18)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('productivity-dashboard')), findsNothing);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Copy.visibleDomains));
    await tester.tap(find.text(Copy.visibleDomains));
    await tester.pumpAndSettle();
    expect(find.byType(VisibleDomainsSettingsScreen), findsOneWidget);
    final tile = tester.widget<CheckboxListTile>(
      find.byKey(const Key('domain-visible-productivity')),
    );
    expect(tile.value, isFalse);
    expect(tile.onChanged, isNull);
  });
}
