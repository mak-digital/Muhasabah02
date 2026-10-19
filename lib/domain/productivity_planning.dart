import 'dart:convert';

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

class ProductivitySubtask {
  const ProductivitySubtask({
    required this.title,
    this.hours = 0.2,
    this.done = false,
  });

  final String title;
  final double hours;
  final bool done;

  ProductivitySubtask copyWith({bool? done}) {
    return ProductivitySubtask(
      title: title,
      hours: hours,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'hours': hours,
    'done': done,
  };

  static ProductivitySubtask fromJson(Map<String, dynamic> json) {
    return ProductivitySubtask(
      title: json['title'] as String? ?? '',
      hours: (json['hours'] as num?)?.toDouble() ?? 0.2,
      done: json['done'] == true,
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
  final DateTime createdAt;
  final bool synthetic;

  int get percent =>
      hours <= 0 ? 0 : ((doneHours / hours) * 100).round().clamp(0, 100);

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
  });

  final int schemaVersion;
  final List<ProductivityAction> actions;
  final List<ProductivityEvent> events;
  final String? lastRolloverDateKey;

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

  ProductivityStore copyWith({
    List<ProductivityAction>? actions,
    List<ProductivityEvent>? events,
    String? lastRolloverDateKey,
  }) {
    return ProductivityStore(
      schemaVersion: schemaVersion,
      actions: actions ?? this.actions,
      events: events ?? this.events,
      lastRolloverDateKey: lastRolloverDateKey ?? this.lastRolloverDateKey,
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

String encodeProductivityStore(ProductivityStore store) {
  return jsonEncode({
    'schemaVersion': store.schemaVersion,
    'lastRolloverDateKey': store.lastRolloverDateKey,
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

String newProductivityId(String prefix, DateTime now) =>
    '$prefix${now.microsecondsSinceEpoch}';

String formatEffortHours(double hours) {
  final whole = hours.floor();
  final minutes = ((hours - whole) * 60).round();
  if (whole == 0) return '${minutes}m';
  if (minutes == 0) return '${whole}h';
  return '${whole}h ${minutes}m';
}
