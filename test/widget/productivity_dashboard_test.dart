import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/app.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/productivity_planning.dart';
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

void main() {
  testWidgets('W1 shown domain opens the Productivity dashboard', (
    tester,
  ) async {
    await _openDashboard(tester);
    expect(find.byKey(const Key('productivity-dashboard')), findsOneWidget);
    expect(find.text('Nothing queued'), findsOneWidget);
  });

  testWidgets('W2 add action appears in MAL and today', (tester) async {
    await _openDashboard(tester);
    await tester.tap(find.byKey(const Key('productivity-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('productivity-add-title')),
      'Write weekly note',
    );
    await tester.tap(find.byKey(const Key('productivity-add-save')));
    await tester.pumpAndSettle();
    expect(find.text('Write weekly note'), findsWidgets);
    await tester.tap(find.byKey(const Key('productivity-mal')));
    await tester.pumpAndSettle();
    expect(find.text('Write weekly note'), findsWidgets);
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
    await tester.tap(find.byKey(const Key('productivity-move-down-a')));
    await tester.pumpAndSettle();
    expect(store.store.todayActions.first.id, 'b');
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
    await tester.tap(find.byKey(const Key('productivity-priority-a')));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.priority, ProductivityPriority.low);
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
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.status, ProductivityStatus.inProgress);
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.status, ProductivityStatus.paused);
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.status, ProductivityStatus.inProgress);
    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.status, ProductivityStatus.completed);
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
    await tester.tap(find.text('Show children').first);
    await tester.pumpAndSettle();
    expect(find.text('Child row'), findsOneWidget);
    await tester.tap(find.text('Show children').last);
    await tester.pumpAndSettle();
    expect(find.text('Grandchild row'), findsOneWidget);
  });

  testWidgets('W7 MAL can place an item into today', (tester) async {
    final store = MemoryProductivityStoreRepository(
      store: ProductivityStore(
        lastRolloverDateKey: '2026-10-18',
        actions: [_sample(id: 'm', title: 'From list', today: false)],
      ),
    );
    await _openDashboard(tester, store: store);
    await tester.tap(find.byKey(const Key('productivity-mal')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(store.store.actions.single.today, isTrue);
  });

  testWidgets('W8 history lists a completion event', (tester) async {
    final store = MemoryProductivityStoreRepository(
      store: ProductivityStore(
        lastRolloverDateKey: '2026-10-18',
        actions: [_sample(id: 'a', title: 'Alpha')],
      ),
    );
    await _openDashboard(tester, store: store);
    await tester.tap(find.text('Complete'));
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
    expect(find.byKey(const Key('productivity-carry-notice')), findsOneWidget);
  });

  testWidgets('W11 empty state has Add and does not crash', (tester) async {
    await _openDashboard(tester);
    expect(find.byKey(const Key('productivity-add')), findsOneWidget);
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
    expect(find.textContaining('High'), findsWidgets);
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
    expect(tile.onChanged, isNotNull);
  });
}
