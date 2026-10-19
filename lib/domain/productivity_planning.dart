import 'dart:convert';

import 'domain_action.dart';
import 'monitor_domain.dart';

const kProductivityStoreSchemaVersion = 1;
const kProductivityTodayCap = 5;
const kProductivityTabletMinWidth = 720.0;
const kProductivityStoreDocumentKey = 'current';
const kProductivityStoreBoxName = 'muhasabah_productivity_v1';

enum ProductivityPriority { critical, high, medium, low }

enum ProductivityStatus {
  notStarted,
  inProgress,
  paused,
  needsLook,
  completed,
  deleted,
}

enum ProductivityListing { pending, active, inProgress, hold, completed }

enum ProductivityStoreDecodeKind { missing, ok, corrupt, unknownVersion }

extension ProductivityPriorityX on ProductivityPriority {
  int get number => index + 1;

  String get label => switch (this) {
    ProductivityPriority.critical => 'Critical (Do first)',
    ProductivityPriority.high => 'High (Important)',
    ProductivityPriority.medium => 'Medium (Do today)',
    ProductivityPriority.low => 'Low (If time permits)',
  };

  String get shortLabel => switch (this) {
    ProductivityPriority.critical => 'Critical',
    ProductivityPriority.high => 'High',
    ProductivityPriority.medium => 'Medium',
    ProductivityPriority.low => 'Low',
  };

  static ProductivityPriority fromNumber(int number) {
    final index = (number - 1).clamp(0, 3);
    return ProductivityPriority.values[index];
  }
}

extension ProductivityStatusX on ProductivityStatus {
  String get label => switch (this) {
    ProductivityStatus.notStarted => 'Not started',
    ProductivityStatus.inProgress => 'In progress',
    ProductivityStatus.paused => 'Paused',
    ProductivityStatus.needsLook => 'Needs a look',
    ProductivityStatus.completed => 'Completed',
    ProductivityStatus.deleted => 'Deleted',
  };

  bool get isOpen =>
      this != ProductivityStatus.completed &&
      this != ProductivityStatus.deleted;
}

extension ProductivityListingX on ProductivityListing {
  String get label => switch (this) {
    ProductivityListing.pending => 'Pending',
    ProductivityListing.active => 'Active',
    ProductivityListing.inProgress => 'In progress',
    ProductivityListing.hold => 'Hold',
    ProductivityListing.completed => 'Completed',
  };
}

enum ProductivityPace { unknown, ahead, onPlan, behind }

extension ProductivityPaceX on ProductivityPace {
  String get label => switch (this) {
    ProductivityPace.unknown => 'No target date yet',
    ProductivityPace.ahead => 'Ahead of the target pace',
    ProductivityPace.onPlan => 'On the target pace',
    ProductivityPace.behind => 'Behind the target pace',
  };
}

class ProductivitySubtask {
  const ProductivitySubtask({
    required this.title,
    this.hours = 1,
    this.percent = 0,
    this.weight = 0,
    this.targetAt,
    this.done = false,
  });

  final String title;
  final double hours;
  final int percent;
  final double weight;
  final DateTime? targetAt;
  final bool done;

  ProductivitySubtask copyWith({
    String? title,
    double? hours,
    int? percent,
    double? weight,
    DateTime? targetAt,
    bool clearTarget = false,
    bool? done,
  }) {
    final nextPercent = (percent ?? this.percent).clamp(0, 100);
    return ProductivitySubtask(
      title: title ?? this.title,
      hours: hours ?? this.hours,
      percent: nextPercent,
      weight: weight ?? this.weight,
      targetAt: clearTarget ? null : (targetAt ?? this.targetAt),
      done: done ?? nextPercent >= 100,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'hours': hours,
    'percent': percent,
    'weight': weight,
    if (targetAt != null) 'targetAt': targetAt!.toIso8601String(),
    'done': done || percent >= 100,
  };

  static ProductivitySubtask fromJson(Map<String, dynamic> json) {
    final percent =
        (json['percent'] as num?)?.round() ??
        ((json['done'] == true) ? 100 : 0);
    return ProductivitySubtask(
      title: json['title'] as String? ?? '',
      hours: (json['hours'] as num?)?.toDouble() ?? 1,
      percent: percent.clamp(0, 100),
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      targetAt: DateTime.tryParse(json['targetAt'] as String? ?? ''),
      done: json['done'] == true || percent >= 100,
    );
  }
}

class ProductivityAction {
  const ProductivityAction({
    required this.id,
    required this.title,
    required this.createdAt,
    this.note = '',
    this.tags = const [],
    this.priority = ProductivityPriority.medium,
    this.status = ProductivityStatus.notStarted,
    this.hours = 1,
    this.doneHours = 0,
    this.targetDateKey,
    this.parentId,
    this.prerequisiteIds = const [],
    this.blocksTitles = const [],
    this.subtasks = const [],
    this.today = false,
    this.sortOrder = 0,
    this.sourceDomainId,
    this.sourceActionId,
    this.synthetic = false,
  });

  final String id;
  final String title;
  final String note;
  final List<String> tags;
  final ProductivityPriority priority;
  final ProductivityStatus status;
  final double hours;
  final double doneHours;
  final String? targetDateKey;
  final String? parentId;
  final List<String> prerequisiteIds;
  final List<String> blocksTitles;
  final List<ProductivitySubtask> subtasks;
  final bool today;
  final int sortOrder;
  final String? sourceDomainId;
  final String? sourceActionId;
  final DateTime createdAt;
  final bool synthetic;

  int get percent {
    if (subtasks.isNotEmpty) return rolledUpSubtaskPercent(subtasks);
    return hours <= 0 ? 0 : ((doneHours / hours) * 100).round().clamp(0, 100);
  }

  ProductivityListing get listing {
    if (status == ProductivityStatus.completed ||
        status == ProductivityStatus.deleted) {
      return ProductivityListing.completed;
    }
    if (status == ProductivityStatus.paused) return ProductivityListing.hold;
    if (status == ProductivityStatus.inProgress) {
      return ProductivityListing.inProgress;
    }
    if (today) return ProductivityListing.active;
    return ProductivityListing.pending;
  }

  ProductivityAction copyWith({
    String? title,
    String? note,
    List<String>? tags,
    ProductivityPriority? priority,
    ProductivityStatus? status,
    double? hours,
    double? doneHours,
    String? targetDateKey,
    bool clearTarget = false,
    List<String>? prerequisiteIds,
    List<ProductivitySubtask>? subtasks,
    bool? today,
    int? sortOrder,
    String? sourceDomainId,
    String? sourceActionId,
  }) {
    return ProductivityAction(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      hours: hours ?? this.hours,
      doneHours: doneHours ?? this.doneHours,
      targetDateKey: clearTarget ? null : (targetDateKey ?? this.targetDateKey),
      parentId: parentId,
      prerequisiteIds: prerequisiteIds ?? this.prerequisiteIds,
      blocksTitles: blocksTitles,
      subtasks: subtasks ?? this.subtasks,
      today: today ?? this.today,
      sortOrder: sortOrder ?? this.sortOrder,
      sourceDomainId: sourceDomainId ?? this.sourceDomainId,
      sourceActionId: sourceActionId ?? this.sourceActionId,
      createdAt: createdAt,
      synthetic: synthetic,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'tags': tags,
    'priority': priority.name,
    'status': status.name,
    'hours': hours,
    'doneHours': doneHours,
    'targetDateKey': targetDateKey,
    'parentId': parentId,
    'prerequisiteIds': prerequisiteIds,
    'blocksTitles': blocksTitles,
    'subtasks': [for (final item in subtasks) item.toJson()],
    'today': today,
    'sortOrder': sortOrder,
    if (sourceDomainId != null) 'sourceDomainId': sourceDomainId,
    if (sourceActionId != null) 'sourceActionId': sourceActionId,
    'createdAt': createdAt.toIso8601String(),
    'synthetic': synthetic,
  };

  static ProductivityAction fromJson(Map<String, dynamic> json) {
    return ProductivityAction(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      tags: [
        for (final tag in json['tags'] as List? ?? const [])
          if (tag is String) tag,
      ],
      priority: ProductivityPriority.values.firstWhere(
        (value) => value.name == json['priority'],
        orElse: () => ProductivityPriority.medium,
      ),
      status: ProductivityStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => ProductivityStatus.notStarted,
      ),
      hours: (json['hours'] as num?)?.toDouble() ?? 1,
      doneHours: (json['doneHours'] as num?)?.toDouble() ?? 0,
      targetDateKey: json['targetDateKey'] as String?,
      parentId: json['parentId'] as String?,
      prerequisiteIds: [
        for (final id in json['prerequisiteIds'] as List? ?? const [])
          if (id is String) id,
      ],
      blocksTitles: [
        for (final title in json['blocksTitles'] as List? ?? const [])
          if (title is String) title,
      ],
      subtasks: [
        for (final item in json['subtasks'] as List? ?? const [])
          if (item is Map)
            ProductivitySubtask.fromJson(Map<String, dynamic>.from(item)),
      ],
      today: json['today'] == true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      sourceDomainId: json['sourceDomainId'] as String?,
      sourceActionId: json['sourceActionId'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime(2026, 1, 1),
      synthetic: json['synthetic'] == true,
    );
  }
}

class ProductivityEvent {
  const ProductivityEvent({
    required this.id,
    required this.kind,
    required this.at,
    this.actionId,
    this.detail = '',
  });

  final String id;
  final String kind;
  final DateTime at;
  final String? actionId;
  final String detail;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'at': at.toIso8601String(),
    'actionId': actionId,
    'detail': detail,
  };

  static ProductivityEvent fromJson(Map<String, dynamic> json) {
    return ProductivityEvent(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      at:
          DateTime.tryParse(json['at'] as String? ?? '') ??
          DateTime(2026, 1, 1),
      actionId: json['actionId'] as String?,
      detail: json['detail'] as String? ?? '',
    );
  }
}

class ProductivityStore {
  const ProductivityStore({
    this.schemaVersion = kProductivityStoreSchemaVersion,
    this.actions = const [],
    this.events = const [],
    this.lastRolloverDateKey,
    this.todaySlotCount = kProductivityTodayCap,
  });

  final int schemaVersion;
  final List<ProductivityAction> actions;
  final List<ProductivityEvent> events;
  final String? lastRolloverDateKey;
  final int todaySlotCount;

  List<ProductivityAction> get todayActions {
    final list = [
      for (final action in actions)
        if (action.today && action.status != ProductivityStatus.deleted) action,
    ];
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<ProductivityAction> get masterList => [
    for (final action in actions)
      if (action.status != ProductivityStatus.deleted &&
          action.parentId == null)
        action,
  ];

  List<ProductivityAction> get visibleTodayActions {
    final cap = todaySlotCount.clamp(1, kProductivityTodayCap);
    final today = todayActions;
    if (today.length <= cap) return today;
    return today.take(cap).toList();
  }

  ProductivityStore copyWith({
    List<ProductivityAction>? actions,
    List<ProductivityEvent>? events,
    String? lastRolloverDateKey,
    int? todaySlotCount,
  }) {
    return ProductivityStore(
      schemaVersion: schemaVersion,
      actions: actions ?? this.actions,
      events: events ?? this.events,
      lastRolloverDateKey: lastRolloverDateKey ?? this.lastRolloverDateKey,
      todaySlotCount: (todaySlotCount ?? this.todaySlotCount).clamp(
        1,
        kProductivityTodayCap,
      ),
    );
  }
}

class ProductivityStoreDecode {
  const ProductivityStoreDecode({required this.kind, this.store});

  final ProductivityStoreDecodeKind kind;
  final ProductivityStore? store;
}

const kProductivityMaxNestingDepth = 2;

ProductivityAction? actionById(ProductivityStore store, String id) {
  for (final action in store.actions) {
    if (action.id == id) return action;
  }
  return null;
}

int actionDepth(ProductivityStore store, ProductivityAction action) {
  var depth = 0;
  var current = action;
  final seen = <String>{};
  while (current.parentId != null) {
    if (!seen.add(current.id)) break;
    final parent = actionById(store, current.parentId!);
    if (parent == null) break;
    depth++;
    current = parent;
    if (depth > 8) break;
  }
  return depth;
}

bool canAddChildUnder(ProductivityStore store, String parentId) {
  final parent = actionById(store, parentId);
  if (parent == null) return false;
  return actionDepth(store, parent) < kProductivityMaxNestingDepth;
}

List<ProductivityAction> childrenOf(ProductivityStore store, String parentId) {
  return [
    for (final action in store.actions)
      if (action.parentId == parentId &&
          action.status != ProductivityStatus.deleted)
        action,
  ];
}

List<String> openPrerequisiteTitles(
  ProductivityStore store,
  ProductivityAction action,
) {
  final titles = <String>[];
  for (final id in action.prerequisiteIds) {
    final prereq = actionById(store, id);
    if (prereq != null && prereq.status.isOpen) titles.add(prereq.title);
  }
  return titles;
}

bool isActionBlocked(ProductivityStore store, ProductivityAction action) =>
    openPrerequisiteTitles(store, action).isNotEmpty;

ProductivityAction? recommendedNext(
  List<ProductivityAction> today, {
  bool Function(ProductivityAction action)? blocked,
}) {
  bool skip(ProductivityAction action) => blocked?.call(action) ?? false;
  for (final action in today) {
    if (skip(action)) continue;
    if (action.status == ProductivityStatus.inProgress ||
        action.status == ProductivityStatus.notStarted) {
      return action;
    }
  }
  for (final action in today) {
    if (skip(action)) continue;
    if (action.status.isOpen) return action;
  }
  return null;
}

ProductivityStore recordProductivityEvent(
  ProductivityStore store, {
  required String kind,
  required DateTime at,
  String? actionId,
  String detail = '',
}) {
  return addEvent(
    store,
    ProductivityEvent(
      id: newProductivityId('ev', at),
      kind: kind,
      at: at,
      actionId: actionId,
      detail: detail,
    ),
  );
}

int effectiveTodayCap(ProductivityStore store) =>
    store.todaySlotCount.clamp(1, kProductivityTodayCap);

ProductivityStore setTodayFlag(ProductivityStore store, String id, bool today) {
  final action = actionById(store, id);
  if (action == null) return store;
  if (today && !action.today && !canAddToToday(store)) return store;
  return upsertAction(
    store,
    action.copyWith(
      today: today,
      sortOrder: today ? store.todayActions.length : action.sortOrder,
    ),
  );
}

ProductivityStore applyTodaySelection(
  ProductivityStore store,
  Iterable<String> ids,
) {
  final cap = kProductivityTodayCap;
  final chosen = <String>[];
  for (final id in ids) {
    if (chosen.contains(id)) continue;
    if (actionById(store, id) == null) continue;
    chosen.add(id);
    if (chosen.length >= cap) break;
  }
  final chosenSet = chosen.toSet();
  final actions = [
    for (final action in store.actions)
      action.copyWith(
        today: chosenSet.contains(action.id),
        sortOrder: chosen.indexOf(action.id),
      ),
  ];
  return store.copyWith(actions: actions);
}

ProductivityStore setTodaySlotCount(ProductivityStore store, int count) {
  return store.copyWith(todaySlotCount: count);
}

ProductivityStore reorderToday(ProductivityStore store, String id, int delta) {
  final today = [...store.todayActions];
  final index = today.indexWhere((action) => action.id == id);
  if (index < 0) return store;
  final nextIndex = index + delta;
  if (nextIndex < 0 || nextIndex >= today.length) return store;
  final item = today.removeAt(index);
  today.insert(nextIndex, item);
  var actions = [...store.actions];
  for (var i = 0; i < today.length; i++) {
    final current = today[i];
    actions = [
      for (final action in actions)
        if (action.id == current.id) action.copyWith(sortOrder: i) else action,
    ];
  }
  return store.copyWith(actions: actions);
}

double plannedHours(List<ProductivityAction> today) =>
    today.fold<double>(0, (sum, action) => sum + action.hours);

double recordedHours(List<ProductivityAction> today) =>
    today.fold<double>(0, (sum, action) => sum + action.doneHours);

int unfinishedTodayCount(List<ProductivityAction> today) =>
    today.where((action) => action.status.isOpen).length;

ProductivityStore applyProductivityRollover(
  ProductivityStore store,
  String todayKey, {
  DateTime? now,
}) {
  if (store.lastRolloverDateKey == todayKey) return store;
  if (store.lastRolloverDateKey == null) {
    return store.copyWith(lastRolloverDateKey: todayKey);
  }
  final stamp = now ?? DateTime.now();
  final events = [...store.events];
  final actions = <ProductivityAction>[];
  for (final action in store.actions) {
    if (action.today && action.status == ProductivityStatus.completed) {
      actions.add(action.copyWith(today: false));
      continue;
    }
    if (action.today && action.status.isOpen) {
      events.add(
        ProductivityEvent(
          id: 'ev-${action.id}-$todayKey',
          kind: 'carriedForward',
          at: stamp,
          actionId: action.id,
          detail: action.title,
        ),
      );
    }
    actions.add(action);
  }
  return store.copyWith(
    actions: actions,
    events: events,
    lastRolloverDateKey: todayKey,
  );
}

ProductivityStore upsertAction(
  ProductivityStore store,
  ProductivityAction action,
) {
  final next = <ProductivityAction>[];
  var found = false;
  for (final item in store.actions) {
    if (item.id == action.id) {
      next.add(action);
      found = true;
    } else {
      next.add(item);
    }
  }
  if (!found) next.add(action);
  return store.copyWith(actions: next);
}

ProductivityStore addEvent(ProductivityStore store, ProductivityEvent event) {
  return store.copyWith(events: [event, ...store.events]);
}

bool canAddToToday(ProductivityStore store) =>
    store.todayActions.length < kProductivityTodayCap;

List<ProductivityAction> pendingRegisterActions(ProductivityStore store) {
  return [
    for (final action in store.masterList)
      if (action.listing == ProductivityListing.pending) action,
  ];
}

ProductivityStore markProductivityStatus(
  ProductivityStore store,
  ProductivityAction action,
  ProductivityStatus status, {
  required DateTime now,
}) {
  final next = action.copyWith(
    status: status,
    today: status == ProductivityStatus.completed ? false : action.today,
    doneHours: status == ProductivityStatus.completed
        ? action.hours
        : action.doneHours,
  );
  var updated = upsertAction(store, next);
  return recordProductivityEvent(
    updated,
    kind: status == ProductivityStatus.completed
        ? 'completed'
        : 'statusChanged',
    at: now,
    actionId: action.id,
    detail: next.listing.label,
  );
}

List<DomainAction> openMasterListCandidates(List<DomainAction> all) {
  final open = [
    for (final action in all)
      if (action.status.isOpen && action.domain != MonitorDomain.productivity)
        action,
  ];
  open.sort((a, b) {
    final byCreated = b.createdAt.compareTo(a.createdAt);
    if (byCreated != 0) return byCreated;
    return a.id.compareTo(b.id);
  });
  return open;
}

ProductivityPriority priorityFromDomainAction(ActionPriority priority) {
  return switch (priority) {
    ActionPriority.soon => ProductivityPriority.critical,
    ActionPriority.week => ProductivityPriority.high,
    ActionPriority.later => ProductivityPriority.medium,
  };
}

bool alreadyImportedSource(ProductivityStore store, String sourceActionId) {
  for (final action in store.actions) {
    if (action.sourceActionId == sourceActionId && action.status.isOpen) {
      return true;
    }
  }
  return false;
}

ProductivityStore importDomainAction(
  ProductivityStore store,
  DomainAction source, {
  required DateTime now,
  bool addToToday = true,
}) {
  if (source.status != ActionStatus.open) return store;
  if (alreadyImportedSource(store, source.id)) return store;
  final placeToday = addToToday && canAddToToday(store);
  final action = ProductivityAction(
    id: newProductivityId('act', now, disambiguator: store.actions.length),
    title: source.title,
    createdAt: now,
    note: '${source.domain.shortLabel} · ${source.id}',
    tags: [source.domain.shortLabel],
    priority: priorityFromDomainAction(source.priority),
    targetDateKey: source.targetDateKey,
    today: placeToday,
    sortOrder: store.todayActions.length,
    sourceDomainId: source.domain.id,
    sourceActionId: source.id,
    synthetic: false,
  );
  var next = upsertAction(store, action);
  return recordProductivityEvent(
    next,
    kind: 'imported',
    at: now,
    actionId: action.id,
    detail: source.domain.id,
  );
}

String encodeProductivityStore(ProductivityStore store) {
  return jsonEncode({
    'schemaVersion': store.schemaVersion,
    'lastRolloverDateKey': store.lastRolloverDateKey,
    'todaySlotCount': store.todaySlotCount,
    'actions': [for (final action in store.actions) action.toJson()],
    'events': [for (final event in store.events) event.toJson()],
  });
}

ProductivityStoreDecode decodeProductivityStore(String? raw) {
  if (raw == null || raw.isEmpty) {
    return const ProductivityStoreDecode(
      kind: ProductivityStoreDecodeKind.missing,
    );
  }
  try {
    final json = jsonDecode(raw);
    if (json is! Map) {
      return const ProductivityStoreDecode(
        kind: ProductivityStoreDecodeKind.corrupt,
      );
    }
    final version = json['schemaVersion'] as int? ?? 0;
    if (version > kProductivityStoreSchemaVersion) {
      return const ProductivityStoreDecode(
        kind: ProductivityStoreDecodeKind.unknownVersion,
      );
    }
    return ProductivityStoreDecode(
      kind: ProductivityStoreDecodeKind.ok,
      store: ProductivityStore(
        schemaVersion: kProductivityStoreSchemaVersion,
        lastRolloverDateKey: json['lastRolloverDateKey'] as String?,
        todaySlotCount: json['todaySlotCount'] as int? ?? kProductivityTodayCap,
        actions: [
          for (final item in json['actions'] as List? ?? const [])
            if (item is Map)
              ProductivityAction.fromJson(Map<String, dynamic>.from(item)),
        ],
        events: [
          for (final item in json['events'] as List? ?? const [])
            if (item is Map)
              ProductivityEvent.fromJson(Map<String, dynamic>.from(item)),
        ],
      ),
    );
  } catch (_) {
    return const ProductivityStoreDecode(
      kind: ProductivityStoreDecodeKind.corrupt,
    );
  }
}

String newProductivityId(
  String prefix,
  DateTime now, {
  int disambiguator = 0,
}) => '$prefix${now.microsecondsSinceEpoch}-$disambiguator';

String formatEffortHours(double hours) {
  final whole = hours.floor();
  final minutes = ((hours - whole) * 60).round();
  if (whole == 0) return '${minutes}m';
  if (minutes == 0) return '${whole}h';
  return '${whole}h ${minutes}m';
}

double subtaskWeightTotal(List<ProductivitySubtask> subtasks) =>
    subtasks.fold<double>(0, (sum, item) => sum + item.weight);

bool subtaskWeightsComplete(List<ProductivitySubtask> subtasks) =>
    subtasks.isNotEmpty && (subtaskWeightTotal(subtasks) - 100).abs() < 0.51;

int rolledUpSubtaskPercent(List<ProductivitySubtask> subtasks) {
  if (subtasks.isEmpty) return 0;
  final total = subtaskWeightTotal(subtasks);
  if (total <= 0) {
    final avg =
        subtasks.fold<int>(0, (sum, item) => sum + item.percent) /
        subtasks.length;
    return avg.round().clamp(0, 100);
  }
  final weighted = subtasks.fold<double>(
    0,
    (sum, item) => sum + item.weight * item.percent,
  );
  return (weighted / total).round().clamp(0, 100);
}

DateTime? actionTargetAt(ProductivityAction action) {
  DateTime? latest;
  for (final item in action.subtasks) {
    final at = item.targetAt;
    if (at == null) continue;
    if (latest == null || at.isAfter(latest)) latest = at;
  }
  if (latest != null) return latest;
  final key = action.targetDateKey;
  if (key == null || key.isEmpty) return null;
  return DateTime.tryParse('${key}T23:59:00');
}

ProductivityPace paceAgainstTarget({
  required int actualPercent,
  required DateTime now,
  required DateTime start,
  DateTime? target,
}) {
  if (target == null) return ProductivityPace.unknown;
  final window = target.difference(start);
  if (window.inMinutes <= 0) {
    return actualPercent >= 100
        ? ProductivityPace.onPlan
        : ProductivityPace.behind;
  }
  final expected = ((now.difference(start).inMinutes / window.inMinutes) * 100)
      .clamp(0, 100);
  final delta = actualPercent - expected;
  if (delta >= 8) return ProductivityPace.ahead;
  if (delta <= -8) return ProductivityPace.behind;
  return ProductivityPace.onPlan;
}

ProductivityPace paceForAction(ProductivityAction action, DateTime now) {
  return paceAgainstTarget(
    actualPercent: action.percent,
    now: now,
    start: action.createdAt,
    target: actionTargetAt(action),
  );
}

ProductivityStore renameProductivityAction(
  ProductivityStore store,
  String id,
  String title,
) {
  final action = actionById(store, id);
  final nextTitle = title.trim();
  if (action == null || nextTitle.isEmpty) return store;
  return upsertAction(store, action.copyWith(title: nextTitle));
}

ProductivityStore applyActionSubtasks(
  ProductivityStore store,
  ProductivityAction action,
  List<ProductivitySubtask> subtasks,
) {
  var hours = action.hours;
  if (subtasks.isNotEmpty) {
    final summed = subtasks.fold<double>(0, (sum, item) => sum + item.hours);
    if (summed > 0) hours = summed;
  }
  final rolled = ProductivityAction(
    id: action.id,
    title: action.title,
    createdAt: action.createdAt,
    note: action.note,
    tags: action.tags,
    priority: action.priority,
    status: action.status,
    hours: hours,
    doneHours: hours * rolledUpSubtaskPercent(subtasks) / 100,
    targetDateKey: action.targetDateKey,
    parentId: action.parentId,
    prerequisiteIds: action.prerequisiteIds,
    blocksTitles: action.blocksTitles,
    subtasks: subtasks,
    today: action.today,
    sortOrder: action.sortOrder,
    sourceDomainId: action.sourceDomainId,
    sourceActionId: action.sourceActionId,
    synthetic: action.synthetic,
  );
  return upsertAction(store, rolled);
}
