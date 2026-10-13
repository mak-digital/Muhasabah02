import 'date_key.dart';
import 'monitor_domain.dart';
import 'personal_response.dart';

const int kDomainActionSchemaVersion = 1;
const int kActionStripCap = 5;
const int kActionTitleMaxScalars = 200;

enum ActionPriority { soon, week, later }

enum ActionStatus { open, done, deleted }

enum ActionChipTone { later, week, soon, pastTarget, done, deleted }

extension ActionStatusListing on ActionStatus {
  bool get isOpen => this == ActionStatus.open;
  bool get isSettled => this == ActionStatus.done || this == ActionStatus.deleted;
}

class DomainAction {
  const DomainAction({
    required this.id,
    required this.domain,
    required this.title,
    required this.targetDateKey,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.sortOrder = 0,
    this.listedOnHome = true,
    this.completedAt,
    this.schemaVersion = kDomainActionSchemaVersion,
  });

  final String id;
  final MonitorDomain domain;
  final String title;
  final String targetDateKey;
  final ActionPriority priority;
  final ActionStatus status;
  final DateTime createdAt;
  final int sortOrder;
  final bool listedOnHome;
  final String? completedAt;
  final int schemaVersion;

  DomainAction copyWith({
    String? title,
    String? targetDateKey,
    ActionPriority? priority,
    ActionStatus? status,
    int? sortOrder,
    bool? listedOnHome,
    String? completedAt,
    bool clearCompletedAt = false,
  }) {
    return DomainAction(
      id: id,
      domain: domain,
      title: title ?? this.title,
      targetDateKey: targetDateKey ?? this.targetDateKey,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      listedOnHome: listedOnHome ?? this.listedOnHome,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      schemaVersion: schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'id': id,
      'domain': domain.id,
      'title': title,
      'targetDateKey': targetDateKey,
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
      'listedOnHome': listedOnHome,
      if (completedAt != null) 'completedAt': completedAt,
    };
  }

  static DomainAction fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final domainName = json['domain'] as String?;
    final title = json['title'] as String?;
    final target = json['targetDateKey'] as String?;
    final created = json['createdAt'] as String?;
    if (id == null ||
        id.isEmpty ||
        domainName == null ||
        title == null ||
        target == null ||
        created == null) {
      throw const FormatException('Malformed DomainAction');
    }
    parseDateKey(target);
    final domain = MonitorDomain.values.where((d) => d.id == domainName);
    if (domain.isEmpty) {
      throw const FormatException('Unknown DomainAction domain');
    }
    final priorityName = json['priority'] as String?;
    final statusName = json['status'] as String?;
    final priority = ActionPriority.values.where((p) => p.name == priorityName);
    final status = ActionStatus.values.where((s) => s.name == statusName);
    if (priority.isEmpty || status.isEmpty) {
      throw const FormatException('Malformed DomainAction status');
    }
    return DomainAction(
      id: id,
      domain: domain.first,
      title: title,
      targetDateKey: target,
      priority: priority.first,
      status: status.first,
      createdAt: DateTime.parse(created),
      sortOrder: json['sortOrder'] is int ? json['sortOrder'] as int : 0,
      listedOnHome: json['listedOnHome'] is bool
          ? json['listedOnHome'] as bool
          : status.first == ActionStatus.open,
      completedAt: json['completedAt'] is String
          ? json['completedAt'] as String
          : null,
      schemaVersion: json['schemaVersion'] is int
          ? json['schemaVersion'] as int
          : kDomainActionSchemaVersion,
    );
  }
}

String normalizeActionTitle(String input) {
  final unified = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  return unified.replaceAll(RegExp(r'\s+'), ' ');
}

ResponseTextError? validateActionTitle(String raw) {
  final normalized = normalizeActionTitle(raw);
  if (normalized.isEmpty) return ResponseTextError.empty;
  if (unicodeScalarCount(normalized) > kActionTitleMaxScalars) {
    return ResponseTextError.tooLong;
  }
  return null;
}

int daysUntilTarget(String targetDateKey, DateTime today) {
  return parseDateKey(targetDateKey)
      .difference(parseDateKey(dateKey(today)))
      .inDays;
}

List<DomainAction> actionsForDomain(
  List<DomainAction> all,
  MonitorDomain domain,
) {
  return [
    for (final action in all)
      if (action.domain == domain) action,
  ];
}

List<DomainAction> orderedActiveActions(List<DomainAction> actions) {
  final open = [
    for (final action in actions)
      if (action.status == ActionStatus.open) action,
  ];
  open.sort((a, b) {
    final byOrder = a.sortOrder.compareTo(b.sortOrder);
    if (byOrder != 0) return byOrder;
    final byCreated = a.createdAt.compareTo(b.createdAt);
    if (byCreated != 0) return byCreated;
    return a.id.compareTo(b.id);
  });
  return open;
}

List<DomainAction> orderedClosedActions(List<DomainAction> actions) {
  return _orderedByEndedAt([
    for (final action in actions)
      if (action.status == ActionStatus.done) action,
  ]);
}

List<DomainAction> orderedDeletedActions(List<DomainAction> actions) {
  return _orderedByEndedAt([
    for (final action in actions)
      if (action.status == ActionStatus.deleted) action,
  ]);
}

List<DomainAction> _orderedByEndedAt(List<DomainAction> actions) {
  final copy = [...actions];
  copy.sort((a, b) => (b.completedAt ?? '').compareTo(a.completedAt ?? ''));
  return copy;
}

List<DomainAction> registerActions(List<DomainAction> actions) {
  return [
    ...orderedActiveActions(actions),
    ...orderedClosedActions(actions),
    ...orderedDeletedActions(actions),
  ];
}

int nextActiveSortOrder(List<DomainAction> actions) {
  final active = orderedActiveActions(actions);
  if (active.isEmpty) return 0;
  var max = active.first.sortOrder;
  for (final action in active) {
    if (action.sortOrder > max) max = action.sortOrder;
  }
  return max + 1;
}

bool canAddActiveAction(List<DomainAction> actions) {
  return orderedActiveActions(actions).length < kActionStripCap;
}

List<DomainAction> listedSettledOnHome(List<DomainAction> actions) {
  final settled = [
    for (final action in actions)
      if (action.status.isSettled && action.listedOnHome) action,
  ];
  settled.sort((a, b) => (a.completedAt ?? '').compareTo(b.completedAt ?? ''));
  return settled;
}

List<DomainAction> actionStripForHome(List<DomainAction> actions) {
  final active = orderedActiveActions(actions);
  final listedSettled = listedSettledOnHome(actions);
  final room = kActionStripCap - active.length;
  if (room <= 0) {
    return active.length <= kActionStripCap
        ? active
        : active.take(kActionStripCap).toList();
  }
  if (listedSettled.length <= room) return [...active, ...listedSettled];
  return [...active, ...listedSettled.take(room)];
}

List<DomainAction> parkOverflowListedClosed(List<DomainAction> actions) {
  final activeCount = orderedActiveActions(actions).length;
  final listedSettled = listedSettledOnHome(actions);
  final overflow = activeCount + listedSettled.length - kActionStripCap;
  if (overflow <= 0) return const [];
  return [
    for (final action in listedSettled.take(overflow))
      action.copyWith(listedOnHome: false),
  ];
}

List<DomainAction> movedActiveActions(
  List<DomainAction> actions,
  String id,
  int delta,
) {
  final ordered = [...orderedActiveActions(actions)];
  final index = ordered.indexWhere((action) => action.id == id);
  final next = index + delta;
  if (index < 0 || next < 0 || next >= ordered.length) return const [];
  final item = ordered.removeAt(index);
  ordered.insert(next, item);
  return [
    for (var i = 0; i < ordered.length; i++)
      if (ordered[i].sortOrder != i) ordered[i].copyWith(sortOrder: i),
  ];
}

ActionChipTone chipToneFor(DomainAction action, DateTime today) {
  if (action.status == ActionStatus.deleted) return ActionChipTone.deleted;
  if (action.status == ActionStatus.done) return ActionChipTone.done;
  final due = daysUntilTarget(action.targetDateKey, today);
  if (due < 0) return ActionChipTone.pastTarget;
  if (due <= 2 || action.priority == ActionPriority.soon) {
    return ActionChipTone.soon;
  }
  if (action.priority == ActionPriority.week) return ActionChipTone.week;
  return ActionChipTone.later;
}

String formatDayMonthYear(String key) {
  final date = parseDateKey(key);
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
