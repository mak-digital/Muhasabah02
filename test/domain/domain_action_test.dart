import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/domain_action.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';

DomainAction action({
  required String id,
  ActionStatus status = ActionStatus.open,
  ActionPriority priority = ActionPriority.week,
  required String target,
  int sortOrder = 0,
  bool? listedOnHome,
  String? completedAt,
  DateTime? createdAt,
}) {
  return DomainAction(
    id: id,
    domain: MonitorDomain.salah,
    title: id,
    targetDateKey: target,
    priority: priority,
    status: status,
    createdAt: createdAt ?? DateTime(2026, 10, 1),
    sortOrder: sortOrder,
    listedOnHome: listedOnHome ?? status == ActionStatus.open,
    completedAt: completedAt,
  );
}

void main() {
  final today = DateTime(2026, 10, 7);

  test('home strip lists active actions by sort order, at most five', () {
    final strip = actionStripForHome([
      action(id: 'c', target: '2026-10-20', sortOrder: 2),
      action(id: 'a', target: '2026-10-08', sortOrder: 0),
      action(id: 'b', target: '2026-10-12', sortOrder: 1),
      action(
        id: 'closed',
        target: '2026-10-05',
        status: ActionStatus.done,
        completedAt: '2026-10-05',
      ),
    ]);
    expect(strip.map((a) => a.id), ['a', 'b', 'c']);
    expect(canAddActiveAction(strip), isTrue);

    final six = [
      for (var i = 0; i < 6; i++)
        action(id: '$i', target: '2026-10-08', sortOrder: i),
    ];
    expect(actionStripForHome(six).map((a) => a.id), ['0', '1', '2', '3', '4']);
    expect(canAddActiveAction(six), isFalse);
  });

  test('completed chips stay at the bottom until parked or overflow', () {
    final listed = actionStripForHome([
      action(id: 'a', target: '2026-10-08', sortOrder: 0),
      action(
        id: 'done-listed',
        target: '2026-10-05',
        status: ActionStatus.done,
        listedOnHome: true,
        completedAt: '2026-10-06',
      ),
      action(
        id: 'done-register',
        target: '2026-10-04',
        status: ActionStatus.done,
        listedOnHome: false,
        completedAt: '2026-10-05',
      ),
    ]);
    expect(listed.map((a) => a.id), ['a', 'done-listed']);

    final full = [
      for (var i = 0; i < 4; i++)
        action(id: 'a$i', target: '2026-10-08', sortOrder: i),
      action(
        id: 'done',
        target: '2026-10-05',
        status: ActionStatus.done,
        listedOnHome: true,
        completedAt: '2026-10-06',
      ),
      action(id: 'new', target: '2026-10-09', sortOrder: 4),
    ];
    expect(
      parkOverflowListedClosed(full).map((a) => '${a.id}:${a.listedOnHome}'),
      ['done:false'],
    );
  });

  test('move swaps adjacent active actions', () {
    final moved = movedActiveActions(
      [
        action(id: 'a', target: '2026-10-08', sortOrder: 0),
        action(id: 'b', target: '2026-10-09', sortOrder: 1),
      ],
      'b',
      -1,
    );
    expect(moved.map((a) => '${a.id}:${a.sortOrder}'), ['b:0', 'a:1']);
  });

  test('register lists active actions above closed ones', () {
    final rows = registerActions([
      action(
        id: 'closed',
        target: '2026-10-01',
        status: ActionStatus.done,
        completedAt: '2026-10-02',
      ),
      action(id: 'active', target: '2026-10-08', sortOrder: 0),
    ]);
    expect(rows.map((a) => a.id), ['active', 'closed']);
  });

  test('chip tone uses status, due date, and listed priority', () {
    expect(
      chipToneFor(action(id: 'past', target: '2026-10-01'), today),
      ActionChipTone.pastTarget,
    );
    expect(
      chipToneFor(
        action(id: 'soon', target: '2026-10-20', priority: ActionPriority.soon),
        today,
      ),
      ActionChipTone.soon,
    );
    expect(
      chipToneFor(
        action(id: 'done', status: ActionStatus.done, target: '2026-10-08'),
        today,
      ),
      ActionChipTone.done,
    );
    expect(
      chipToneFor(
        action(
          id: 'deleted',
          status: ActionStatus.deleted,
          target: '2026-10-08',
        ),
        today,
      ),
      ActionChipTone.deleted,
    );
  });

  test('register keeps deleted actions after they leave the wash', () {
    final rows = registerActions([
      action(id: 'active', target: '2026-10-08', sortOrder: 0),
      action(
        id: 'gone',
        target: '2026-10-01',
        status: ActionStatus.deleted,
        listedOnHome: false,
        completedAt: '2026-10-07',
      ),
    ]);
    expect(rows.map((a) => a.id), ['active', 'gone']);
  });
}
