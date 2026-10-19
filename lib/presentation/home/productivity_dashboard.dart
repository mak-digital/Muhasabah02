import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/productivity_planning.dart';

class ProductivityDashboard extends ConsumerStatefulWidget {
  const ProductivityDashboard({super.key, required this.family});

  final Color family;

  @override
  ConsumerState<ProductivityDashboard> createState() =>
      _ProductivityDashboardState();
}

class _ProductivityDashboardState extends ConsumerState<ProductivityDashboard> {
  String? _selectedId;
  final _quick = TextEditingController();
  var _expandedIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _rollover());
  }

  @override
  void dispose() {
    _quick.dispose();
    super.dispose();
  }

  Future<void> _rollover() async {
    if (!mounted) return;
    final now = ref.read(nowProvider);
    await persistProductivityStore(
      ref,
      (store) => applyProductivityRollover(store, dateKey(now), now: now),
    );
  }

  Future<void> _save(ProductivityStore Function(ProductivityStore) update) {
    return persistProductivityStore(ref, update);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(productivityStoreTickProvider);
    final store = ref.watch(productivityStoreRepositoryProvider).store;
    final now = ref.watch(nowProvider);
    final today = store.todayActions;
    final next = recommendedNext(
      today,
      blocked: (action) => isActionBlocked(store, action),
    );
    final unfinished = unfinishedTodayCount(today);
    final planned = plannedHours(today);
    final recorded = recordedHours(today);
    final remaining = (planned - recorded).clamp(0.0, planned).toDouble();
    final selected = _selectedId == null
        ? next
        : actionById(store, _selectedId!) ?? next;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tablet = constraints.maxWidth >= kProductivityTabletMinWidth;
        final main = _mainColumn(
          store: store,
          today: today,
          next: next,
          selected: selected,
          unfinished: unfinished,
          now: now,
          tablet: tablet,
        );
        if (!tablet) {
          return KeyedSubtree(
            key: const Key('productivity-dashboard'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...main,
                const SizedBox(height: 8),
                _collapsedPanels(store, now),
                const SizedBox(height: 8),
                _quickAdd(),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text('Priority guide'),
                  children: [_priorityGuide()],
                ),
              ],
            ),
          );
        }
        return KeyedSubtree(
          key: const Key('productivity-dashboard'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: main,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 300,
                child: KeyedSubtree(
                  key: const Key('productivity-tablet-side'),
                  child: _sideColumn(
                    store: store,
                    now: now,
                    planned: planned,
                    recorded: recorded,
                    remaining: remaining,
                    unfinished: unfinished,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _mainColumn({
    required ProductivityStore store,
    required List<ProductivityAction> today,
    required ProductivityAction? next,
    required ProductivityAction? selected,
    required int unfinished,
    required DateTime now,
    required bool tablet,
  }) {
    return [
      _header(today, now),
      const SizedBox(height: 8),
      _focusBanner(next, today),
      const SizedBox(height: 8),
      _todayList(store, today),
      if (!tablet && unfinished > 0) ...[
        const SizedBox(height: 8),
        _notice(unfinished),
      ],
      if (selected != null) ...[
        const SizedBox(height: 8),
        _details(store, selected),
      ],
    ];
  }

  Widget _sideColumn({
    required ProductivityStore store,
    required DateTime now,
    required double planned,
    required double recorded,
    required double remaining,
    required int unfinished,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _monthCalendar(now),
        const SizedBox(height: 8),
        _timeCard(planned, recorded, remaining),
        if (unfinished > 0) ...[const SizedBox(height: 8), _notice(unfinished)],
        const SizedBox(height: 8),
        _quickAdd(),
        const SizedBox(height: 8),
        _priorityGuide(),
        const SizedBox(height: 8),
        _collapsedPanels(store, now),
      ],
    );
  }

  Widget _header(List<ProductivityAction> today, DateTime now) {
    final inProgress = today
        .where((action) => action.status == ProductivityStatus.inProgress)
        .length;
    final look = today
        .where((action) => action.status == ProductivityStatus.needsLook)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                formatGregorianAndHijri(now),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              key: const Key('productivity-add'),
              onPressed: _openAddSheet,
              child: const Text('Add'),
            ),
          ],
        ),
        Text(
          'Focus ${today.length}/$kProductivityTodayCap · In progress $inProgress · Needs a look $look',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _focusBanner(
    ProductivityAction? next,
    List<ProductivityAction> today,
  ) {
    final planned = plannedHours(today);
    final remaining = (planned - recordedHours(today))
        .clamp(0.0, planned)
        .toDouble();
    return Material(
      key: const Key('productivity-focus'),
      color: widget.family.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: next == null
            ? const Text('Nothing queued')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s focus',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    next.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (next.note.isNotEmpty)
                    Text(
                      next.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  _effortBar(next.percent),
                  Text(
                    'Remaining ${formatEffortHours(remaining)} of ${formatEffortHours(planned)} planned',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () =>
                            _setStatus(next, ProductivityStatus.inProgress),
                        child: const Text('Start'),
                      ),
                      TextButton(
                        onPressed: () =>
                            _setStatus(next, ProductivityStatus.paused),
                        child: const Text('Pause'),
                      ),
                      TextButton(
                        onPressed: () =>
                            _setStatus(next, ProductivityStatus.inProgress),
                        child: const Text('Resume'),
                      ),
                      TextButton(
                        onPressed: () =>
                            _setStatus(next, ProductivityStatus.completed),
                        child: const Text('Complete'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _todayList(ProductivityStore store, List<ProductivityAction> today) {
    return Column(
      key: const Key('productivity-today-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Today’s actions (${today.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton(
              key: const Key('productivity-pick-mal'),
              onPressed: () => _openMalSheet(store),
              child: const Text('Pick from MAL'),
            ),
          ],
        ),
        if (today.isEmpty)
          const Text(
            'No actions on today yet. Add one, or pick from the list.',
          ),
        for (var i = 0; i < today.length; i++)
          _actionCard(store, today[i], index: i + 1, depth: 0),
      ],
    );
  }

  Widget _actionCard(
    ProductivityStore store,
    ProductivityAction action, {
    required int index,
    required int depth,
  }) {
    final blockedTitles = openPrerequisiteTitles(store, action);
    final expanded = _expandedIds.contains(action.id);
    final kids = childrenOf(store, action.id);
    return Padding(
      padding: EdgeInsets.only(left: depth * 12, bottom: 8),
      child: Material(
        key: Key('productivity-action-${action.id}'),
        color: _priorityWash(action.priority),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _selectedId = action.id),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _priorityColor(action.priority),
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Checkbox(
                      key: Key('productivity-complete-${action.id}'),
                      value: action.status == ProductivityStatus.completed,
                      onChanged: (value) {
                        _setStatus(
                          action,
                          value == true
                              ? ProductivityStatus.completed
                              : ProductivityStatus.notStarted,
                        );
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (action.note.isNotEmpty)
                            Text(
                              action.note,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final tag in action.tags)
                                Chip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(tag),
                                ),
                            ],
                          ),
                          Text(
                            '${formatEffortHours(action.hours)} · ${action.percent}% of estimate',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          _effortBar(action.percent),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _priorityChip(action),
                              _statusChip(action),
                              if (blockedTitles.isNotEmpty)
                                Text(
                                  'Waiting on ${blockedTitles.join(', ')}',
                                  key: Key('productivity-blocked-${action.id}'),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          key: Key('productivity-move-up-${action.id}'),
                          icon: const Icon(Icons.keyboard_arrow_up),
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: action.today
                              ? () => _save(
                                  (store) => reorderToday(store, action.id, -1),
                                )
                              : null,
                        ),
                        IconButton(
                          key: Key('productivity-move-down-${action.id}'),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: action.today
                              ? () => _save(
                                  (store) => reorderToday(store, action.id, 1),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        final next = {..._expandedIds};
                        if (!next.add(action.id)) next.remove(action.id);
                        _expandedIds = next;
                      });
                    },
                    child: Text(expanded ? 'Hide children' : 'Show children'),
                  ),
                ),
                if (expanded) ...[
                  for (var i = 0; i < kids.length; i++)
                    _actionCard(store, kids[i], index: i + 1, depth: depth + 1),
                  if (canAddChildUnder(store, action.id))
                    TextButton(
                      onPressed: () => _openAddSheet(parentId: action.id),
                      child: const Text('Add child'),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(ProductivityAction action) {
    return ActionChip(
      key: Key('productivity-priority-${action.id}'),
      label: Text('${action.priority.number} ${action.priority.shortLabel}'),
      onPressed: () {
        final next =
            ProductivityPriority.values[(action.priority.index + 1) %
                ProductivityPriority.values.length];
        _save((store) {
          final now = ref.read(nowProvider);
          var nextStore = upsertAction(store, action.copyWith(priority: next));
          return recordProductivityEvent(
            nextStore,
            kind: 'priorityChanged',
            at: now,
            actionId: action.id,
            detail: next.shortLabel,
          );
        });
      },
    );
  }

  Widget _statusChip(ProductivityAction action) {
    return PopupMenuButton<ProductivityStatus>(
      key: Key('productivity-status-${action.id}'),
      onSelected: (status) => _setStatus(action, status),
      itemBuilder: (context) => [
        for (final status in ProductivityStatus.values)
          if (status != ProductivityStatus.deleted)
            PopupMenuItem(value: status, child: Text(status.label)),
      ],
      child: Chip(label: Text(action.status.label)),
    );
  }

  Widget _details(ProductivityStore store, ProductivityAction action) {
    final blocked = openPrerequisiteTitles(store, action);
    return Material(
      key: const Key('productivity-details'),
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected action details',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(action.title, style: Theme.of(context).textTheme.titleMedium),
            Text('Status: ${action.status.label}'),
            Text('Estimate: ${formatEffortHours(action.hours)}'),
            if (action.targetDateKey != null)
              Text('Target: ${action.targetDateKey}'),
            if (blocked.isNotEmpty)
              Text('Must complete before: ${blocked.join(', ')}'),
            const SizedBox(height: 8),
            Text('Subtasks', style: Theme.of(context).textTheme.titleSmall),
            for (var i = 0; i < action.subtasks.length; i++)
              CheckboxListTile(
                dense: true,
                value: action.subtasks[i].done,
                title: Text(action.subtasks[i].title),
                onChanged: (value) {
                  final next = [...action.subtasks];
                  next[i] = next[i].copyWith(done: value == true);
                  _save(
                    (store) =>
                        upsertAction(store, action.copyWith(subtasks: next)),
                  );
                },
              ),
            TextButton(
              onPressed: () => _addSubtask(action),
              child: const Text('+ Add subtask'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notice(int unfinished) {
    return Material(
      key: const Key('productivity-carry-notice'),
      color: widget.family.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          '$unfinished unfinished action${unfinished == 1 ? '' : 's'} will move to tomorrow. That is carry-forward, not a fail.',
        ),
      ),
    );
  }

  Widget _collapsedPanels(ProductivityStore store, DateTime now) {
    return Column(
      children: [
        ExpansionTile(
          key: const Key('productivity-mal'),
          title: const Text('Master Action List'),
          children: [
            for (final action in store.masterList)
              ListTile(
                title: Text(action.title),
                subtitle: Text(action.today ? 'On today' : action.status.label),
                trailing: action.today
                    ? null
                    : TextButton(
                        onPressed: canAddToToday(store)
                            ? () => _save(
                                (current) =>
                                    setTodayFlag(current, action.id, true),
                              )
                            : null,
                        child: const Text('Today'),
                      ),
              ),
          ],
        ),
        ExpansionTile(
          key: const Key('productivity-history'),
          title: const Text('History and trends'),
          children: [
            _timeCard(
              plannedHours(store.todayActions),
              recordedHours(store.todayActions),
              (plannedHours(store.todayActions) -
                      recordedHours(store.todayActions))
                  .clamp(0.0, plannedHours(store.todayActions))
                  .toDouble(),
            ),
            _monthCalendar(now),
            for (final event in store.events.take(12))
              ListTile(
                dense: true,
                title: Text(event.kind),
                subtitle: Text(event.detail),
              ),
          ],
        ),
      ],
    );
  }

  Widget _timeCard(double planned, double recorded, double remaining) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today’s time', style: Theme.of(context).textTheme.titleSmall),
            Row(
              children: [
                Expanded(child: Text('Planned\n${formatEffortHours(planned)}')),
                Expanded(
                  child: Text('Recorded\n${formatEffortHours(recorded)}'),
                ),
                Expanded(
                  child: Text('Remaining\n${formatEffortHours(remaining)}'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _effortBar(planned <= 0 ? 0 : ((recorded / planned) * 100).round()),
            Text(
              'Effort vs plan for today. Not a productivity score.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarCell({
    required DateTime now,
    required int lead,
    required int days,
    required int index,
  }) {
    if (index < lead || index >= lead + days) {
      return const SizedBox(height: 28);
    }
    final day = index - lead + 1;
    final isToday = day == now.day;
    return Center(
      child: CircleAvatar(
        radius: 12,
        backgroundColor: isToday ? widget.family : Colors.transparent,
        foregroundColor: isToday
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
        child: Text('$day', style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _monthCalendar(DateTime now) {
    final first = DateTime(now.year, now.month, 1);
    final days = DateTime(now.year, now.month + 1, 0).day;
    final lead = first.weekday % 7;
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_gregorianMonth(now.month)} ${now.year}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Table(
              children: [
                for (var row = 0; row < ((lead + days) / 7).ceil(); row++)
                  TableRow(
                    children: [
                      for (var col = 0; col < 7; col++)
                        _calendarCell(
                          now: now,
                          lead: lead,
                          days: days,
                          index: row * 7 + col,
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAdd() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('productivity-quick-add'),
            controller: _quick,
            decoration: const InputDecoration(
              hintText: 'Quick add title',
              isDense: true,
            ),
            onSubmitted: (_) => _quickCreate(),
          ),
        ),
        IconButton(
          key: const Key('productivity-quick-add-go'),
          onPressed: _quickCreate,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _priorityGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final priority in ProductivityPriority.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundColor: _priorityColor(priority),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(priority.label)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _effortBar(int percent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(value: (percent.clamp(0, 100)) / 100),
    );
  }

  Future<void> _setStatus(
    ProductivityAction action,
    ProductivityStatus status,
  ) {
    return _save((store) {
      final now = ref.read(nowProvider);
      final next = action.copyWith(
        status: status,
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
        detail: status.label,
      );
    });
  }

  Future<void> _quickCreate() async {
    final title = _quick.text.trim();
    if (title.isEmpty) return;
    await _createAction(title: title, addToToday: true);
    _quick.clear();
  }

  Future<void> _openAddSheet({String? parentId}) async {
    final title = TextEditingController();
    var addToToday = parentId == null;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const Key('productivity-add-title'),
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  if (parentId == null)
                    SwitchListTile(
                      title: const Text('Add to today'),
                      value: addToToday,
                      onChanged: (value) => setModal(() => addToToday = value),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      key: const Key('productivity-add-save'),
                      onPressed: () {
                        final value = title.text.trim();
                        final placeToday = addToToday;
                        Navigator.pop(context);
                        _createAction(
                          title: value,
                          addToToday: placeToday,
                          parentId: parentId,
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openMalSheet(ProductivityStore store) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            for (final action in store.masterList)
              ListTile(
                title: Text(action.title),
                onTap: () {
                  Navigator.pop(context);
                  _save((current) => setTodayFlag(current, action.id, true));
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _addSubtask(ProductivityAction action) async {
    final title = TextEditingController(text: 'Next step');
    final next = [...action.subtasks, ProductivitySubtask(title: title.text)];
    await _save(
      (store) => upsertAction(store, action.copyWith(subtasks: next)),
    );
    title.dispose();
  }

  Future<void> _createAction({
    required String title,
    required bool addToToday,
    double hours = 1,
    String? parentId,
  }) async {
    if (title.isEmpty) return;
    await _save((store) {
      if (parentId != null && !canAddChildUnder(store, parentId)) return store;
      var placeToday = addToToday && canAddToToday(store);
      final now = ref.read(nowProvider);
      final action = ProductivityAction(
        id: newProductivityId('act', now),
        title: title,
        createdAt: now,
        hours: hours,
        today: placeToday,
        parentId: parentId,
        sortOrder: store.todayActions.length,
        synthetic: false,
      );
      var next = upsertAction(store, action);
      return recordProductivityEvent(
        next,
        kind: 'created',
        at: now,
        actionId: action.id,
        detail: title,
      );
    });
  }
}

Color _priorityColor(ProductivityPriority priority) => switch (priority) {
  ProductivityPriority.critical => const Color(0xFFD45B5B),
  ProductivityPriority.high => const Color(0xFFE39A3C),
  ProductivityPriority.medium => const Color(0xFF4D86D6),
  ProductivityPriority.low => const Color(0xFF7A6FD1),
};

Color _priorityWash(ProductivityPriority priority) => switch (priority) {
  ProductivityPriority.critical => const Color(0xFFFDEEEE),
  ProductivityPriority.high => const Color(0xFFFFF4E4),
  ProductivityPriority.medium => const Color(0xFFEAF2FC),
  ProductivityPriority.low => const Color(0xFFF0EEFB),
};

String _gregorianMonth(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return names[(month - 1).clamp(0, 11)];
}
