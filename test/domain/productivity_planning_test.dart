import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/domain_action.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/productivity_planning.dart';

ProductivityAction _action({
  required String id,
  required String title,
  bool today = false,
  ProductivityStatus status = ProductivityStatus.notStarted,
  ProductivityPriority priority = ProductivityPriority.medium,
  String? parentId,
  List<String> prerequisiteIds = const [],
  double hours = 1,
  double doneHours = 0,
  bool synthetic = true,
  DateTime? createdAt,
  String? targetDateKey,
  int sortOrder = 0,
}) {
  return ProductivityAction(
    id: id,
    title: title,
    createdAt: createdAt ?? DateTime(2026, 10, 18),
    today: today,
    status: status,
    priority: priority,
    parentId: parentId,
    prerequisiteIds: prerequisiteIds,
    hours: hours,
    doneHours: doneHours,
    targetDateKey: targetDateKey,
    sortOrder: sortOrder,
    synthetic: synthetic,
  );
}

void main() {
  test('D1 empty store is schema 1', () {
    const store = ProductivityStore();
    expect(store.schemaVersion, 1);
    expect(store.actions, isEmpty);
  });

  test('D2 action JSON round-trip', () {
    final action = _action(
      id: 'a1',
      title: 'Draft note',
      priority: ProductivityPriority.high,
      status: ProductivityStatus.inProgress,
      parentId: 'p1',
      prerequisiteIds: const ['x1'],
      hours: 2.5,
      doneHours: 1,
      today: true,
    );
    final copy = ProductivityAction.fromJson(action.toJson());
    expect(copy.title, 'Draft note');
    expect(copy.priority, ProductivityPriority.high);
    expect(copy.status, ProductivityStatus.inProgress);
    expect(copy.parentId, 'p1');
    expect(copy.prerequisiteIds, ['x1']);
    expect(copy.hours, 2.5);
    expect(copy.percent, 40);
  });

  test('D3 depth over grandchild is refused', () {
    var store = ProductivityStore(
      actions: [
        _action(id: 'p', title: 'Parent'),
        _action(id: 'c', title: 'Child', parentId: 'p'),
        _action(id: 'g', title: 'Grandchild', parentId: 'c'),
      ],
    );
    expect(canAddChildUnder(store, 'p'), isTrue);
    expect(canAddChildUnder(store, 'c'), isTrue);
    expect(canAddChildUnder(store, 'g'), isFalse);
  });

  test('D4 today cap refuses a sixth', () {
    final actions = [
      for (var i = 0; i < 5; i++)
        _action(id: 't$i', title: 'Item $i', today: true),
      _action(id: 'extra', title: 'Extra'),
    ];
    var store = ProductivityStore(actions: actions);
    expect(canAddToToday(store), isFalse);
    store = setTodayFlag(store, 'extra', true);
    expect(store.todayActions.length, 5);
  });

  test('D5 recommended next skips paused and blocked', () {
    final paused = _action(
      id: 'p',
      title: 'Paused',
      today: true,
      status: ProductivityStatus.paused,
    );
    final blocked = _action(
      id: 'b',
      title: 'Blocked',
      today: true,
      prerequisiteIds: const ['need'],
    );
    final ready = _action(id: 'r', title: 'Ready', today: true);
    final store = ProductivityStore(
      actions: [
        paused,
        blocked,
        ready,
        _action(
          id: 'need',
          title: 'Need',
          status: ProductivityStatus.notStarted,
        ),
      ],
    );
    final next = recommendedNext(
      store.todayActions,
      blocked: (action) => isActionBlocked(store, action),
    );
    expect(next?.id, 'r');
  });

  test('D7 D8 carry-forward keeps unfinished and completed until moved', () {
    final store = ProductivityStore(
      lastRolloverDateKey: '2026-10-17',
      actions: [
        _action(id: 'open', title: 'Still open', today: true),
        _action(
          id: 'done',
          title: 'Finished',
          today: true,
          status: ProductivityStatus.completed,
        ),
      ],
    );
    final next = applyProductivityRollover(
      store,
      '2026-10-18',
      now: DateTime(2026, 10, 18),
    );
    expect(actionById(next, 'open')?.today, isTrue);
    expect(actionById(next, 'done')?.today, isTrue);
    expect(next.events.single.kind, 'carriedForward');
  });

  test('D10 corrupt document is isolated', () {
    final decoded = decodeProductivityStore('{not-json');
    expect(decoded.kind, ProductivityStoreDecodeKind.corrupt);
    expect(decoded.store, isNull);
  });

  test('D11 fixtures can be synthetic', () {
    expect(_action(id: 's', title: 'Sample').synthetic, isTrue);
  });

  test('frozen clock still issues distinct action ids', () {
    final stamp = DateTime(2026, 10, 18, 10);
    expect(
      newProductivityId('act', stamp, disambiguator: 0),
      isNot(newProductivityId('act', stamp, disambiguator: 1)),
    );
  });

  test('import copies an open domain action once', () {
    final source = DomainAction(
      id: 'health-1',
      domain: MonitorDomain.health,
      title: 'Call clinic',
      targetDateKey: '2026-10-21',
      priority: ActionPriority.week,
      status: ActionStatus.open,
      createdAt: DateTime(2026, 10, 10),
    );
    var store = importDomainAction(
      const ProductivityStore(),
      source,
      now: DateTime(2026, 10, 18),
    );
    expect(store.actions.single.title, 'Call clinic');
    expect(store.actions.single.sourceActionId, 'health-1');
    expect(store.actions.single.today, isTrue);
    store = importDomainAction(store, source, now: DateTime(2026, 10, 18, 11));
    expect(store.actions.length, 1);
  });

  test('today slot count 2 keeps extras in the register', () {
    var store = ProductivityStore(
      actions: [
        for (var i = 0; i < 4; i++)
          _action(id: 't$i', title: 'Item $i', today: true, sortOrder: i),
      ],
    );
    store = setTodaySlotCount(store, 2);
    expect(store.todaySlotCount, 2);
    expect(store.visibleTodayActions.length, 2);
    expect(store.todayActions.length, 4);
    store = setTodaySlotCount(store, 4);
    expect(store.visibleTodayActions.map((action) => action.id), [
      't0',
      't1',
      't2',
      't3',
    ]);
  });

  test('completed today action stays on the board until moved off', () {
    var store = ProductivityStore(
      actions: [
        _action(id: 'done', title: 'Done', today: true),
        _action(id: 'wait', title: 'Wait', today: false),
      ],
    );
    store = markProductivityStatus(
      store,
      actionById(store, 'done')!,
      ProductivityStatus.completed,
      now: DateTime(2026, 10, 18, 12),
    );
    expect(actionById(store, 'done')?.today, isTrue);
    expect(actionById(store, 'done')?.listing, ProductivityListing.completed);
    expect(actionById(store, 'done')?.percent, 100);
    expect(actionById(store, 'done')?.status, ProductivityStatus.completed);
    expect(pendingRegisterActions(store).single.id, 'wait');
    store = setTodayFlag(store, 'done', false);
    expect(actionById(store, 'done')?.today, isFalse);
  });

  test('sub-activity weights roll up to the parent percent', () {
    final action = _action(id: 'p', title: 'Parent').copyWith(
      subtasks: const [
        ProductivitySubtask(title: 'A', weight: 40, percent: 50, hours: 2),
        ProductivitySubtask(title: 'B', weight: 60, percent: 100, hours: 3),
      ],
    );
    expect(subtaskWeightsComplete(action.subtasks), isTrue);
    expect(action.percent, 80);
    expect(
      paceAgainstTarget(
        actualPercent: 80,
        now: DateTime(2026, 10, 10),
        start: DateTime(2026, 10, 1),
        target: DateTime(2026, 10, 20),
      ),
      ProductivityPace.ahead,
    );
  });

  test('status and percent stay aligned across focus, list and details', () {
    var store = ProductivityStore(
      actions: [
        _action(id: 'a', title: 'Ahmad Insurance', today: true, hours: 5),
      ],
    );
    store = applyActionProgress(store, store.actions.single, percent: 100);
    expect(actionById(store, 'a')?.percent, 100);
    expect(actionById(store, 'a')?.status, ProductivityStatus.completed);

    store = markProductivityStatus(
      store,
      actionById(store, 'a')!,
      ProductivityStatus.notStarted,
      now: DateTime(2026, 10, 18, 12),
    );
    expect(actionById(store, 'a')?.status, ProductivityStatus.notStarted);
    expect(actionById(store, 'a')?.percent, 0);

    store = applyActionProgress(store, actionById(store, 'a')!, percent: 40);
    expect(actionById(store, 'a')?.status, ProductivityStatus.inProgress);
    expect(actionById(store, 'a')?.percent, 40);

    final healed = ProductivityAction.fromJson({
      'id': 'b',
      'title': 'Ahmad Insurance',
      'status': 'notStarted',
      'hours': 5,
      'doneHours': 5,
      'createdAt': '2026-10-18T09:00:00.000',
      'today': true,
    });
    expect(healed.status, ProductivityStatus.notStarted);
    expect(healed.percent, 0);
  });

  test('planner lines follow displayed daily actions and tentative dates', () {
    final displayed = [
      _action(
        id: 'a',
        title: 'Shown',
        today: true,
        priority: ProductivityPriority.critical,
        createdAt: DateTime(2026, 10, 18),
        targetDateKey: '2026-10-20',
      ),
      _action(
        id: 'paused',
        title: 'Paused row',
        today: true,
        status: ProductivityStatus.paused,
        priority: ProductivityPriority.high,
        createdAt: DateTime(2026, 10, 19),
      ),
      _action(
        id: 'done',
        title: 'Closed row',
        today: true,
        status: ProductivityStatus.completed,
        priority: ProductivityPriority.medium,
        createdAt: DateTime(2026, 10, 18),
        targetDateKey: '2026-10-18',
        doneHours: 1,
      ),
    ];
    final marks = plannerLinesForDisplayedActions(
      displayed,
      now: DateTime(2026, 10, 19),
    );
    expect(marks['2026-10-18'], [
      const PlannerDayMark(
        priority: ProductivityPriority.critical,
        isStart: true,
        isProgress: true,
      ),
      const PlannerDayMark(
        priority: ProductivityPriority.medium,
        isStart: true,
        isEnd: true,
        isProgress: true,
      ),
    ]);
    expect(marks['2026-10-19'], [
      const PlannerDayMark(priority: ProductivityPriority.critical),
      const PlannerDayMark(
        priority: ProductivityPriority.high,
        isStart: true,
        isEnd: true,
        isProgress: true,
      ),
    ]);
    expect(marks['2026-10-20'], [
      const PlannerDayMark(
        priority: ProductivityPriority.critical,
        isEnd: true,
      ),
    ]);
    expect(marks.containsKey('2026-10-21'), isFalse);
    expect(
      plannerProgressDateKey(
        startKey: '2026-10-18',
        endKey: '2026-10-22',
        percent: 50,
      ),
      '2026-10-20',
    );
    expect(
      plannerLinesForDisplayedActions(const [], now: DateTime(2026, 10, 19)),
      isEmpty,
    );
  });

  test('compact labels shorten long hex ids', () {
    expect(
      compactProductivityLabel('Wealth · b1c84c098a644ebc481bec5277e29e19'),
      'Wealth · b1c84c…',
    );
  });

  test('progress details store hours, percent and target on the action', () {
    var store = ProductivityStore(
      actions: [_action(id: 'a', title: 'Alpha', today: true)],
    );
    store = applyActionProgress(
      store,
      store.actions.single,
      hours: 2.5,
      percent: 40,
      targetAt: DateTime(2026, 10, 21, 16, 30),
    );
    final action = actionById(store, 'a')!;
    expect(action.hours, 2.5);
    expect(action.percent, 40);
    expect(action.status, ProductivityStatus.inProgress);
    expect(action.targetAt, DateTime(2026, 10, 21, 16, 30));
    expect(action.targetDateKey, '2026-10-21');
  });

  test('rename changes only the title', () {
    var store = ProductivityStore(
      actions: [
        _action(
          id: 'a',
          title: 'Old',
          today: true,
          status: ProductivityStatus.inProgress,
        ),
      ],
    );
    store = renameProductivityAction(store, 'a', 'New name');
    final action = actionById(store, 'a')!;
    expect(action.title, 'New name');
    expect(action.status, ProductivityStatus.inProgress);
    expect(action.today, isTrue);
  });

  test('G4 DailyCheckIn schema stays 6', () {
    expect(kDailyCheckInSchemaVersion, 6);
  });

  test('W14 Hajj files do not import Productivity', () {
    expect(
      File('lib/domain/hajj_planning.dart')
          .readAsStringSync()
          .contains('productivity'),
      isFalse,
    );
    expect(
      File('lib/presentation/home/hajj_home_dashboard.dart')
          .readAsStringSync()
          .contains('productivity'),
      isFalse,
    );
  });
}
