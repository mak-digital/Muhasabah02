import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
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

  test('D7 D8 carry-forward keeps unfinished and drops completed', () {
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
    expect(actionById(next, 'done')?.today, isFalse);
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
