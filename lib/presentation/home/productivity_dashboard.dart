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

enum _DashSection { today, planner, mal, history }

class _ProductivityDashboardState extends ConsumerState<ProductivityDashboard> {
  String? _selectedId;
  final _quick = TextEditingController();
  var _expandedIds = <String>{};
  var _section = _DashSection.today;

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
        final chrome = _chrome(now);
        if (!tablet) {
          return KeyedSubtree(
            key: const Key('productivity-dashboard'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                chrome,
                ...main,
                if (_section == _DashSection.today) ...[
                  const SizedBox(height: 8),
                  _collapsedPanels(store, now),
                ],
              ],
            ),
          );
        }
        return KeyedSubtree(
          key: const Key('productivity-dashboard'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              chrome,
              Row(
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
    switch (_section) {
      case _DashSection.today:
        return [
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
      case _DashSection.planner:
        return [
          _monthCalendar(now),
          const SizedBox(height: 8),
          _timeCard(
            plannedHours(today),
            recordedHours(today),
            remainingHours(today),
          ),
          if (unfinished > 0) ...[
            const SizedBox(height: 8),
            _notice(unfinished),
          ],
          const SizedBox(height: 8),
          _paper(child: _quickAdd()),
          const SizedBox(height: 8),
          _paper(child: _priorityGuide()),
        ];
      case _DashSection.mal:
        return [_malPanel(store, expanded: true)];
      case _DashSection.history:
        return [_historyPanel(store, now, expanded: true)];
    }
  }

  double remainingHours(List<ProductivityAction> today) {
    final planned = plannedHours(today);
    return (planned - recordedHours(today)).clamp(0.0, planned).toDouble();
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

  Widget _chrome(DateTime now) {
    final hijri = formatDayMonthYear(now, DisplayCalendar.islamic);
    final gregorian = formatDayMonthYear(now, DisplayCalendar.gregorian);
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[now.weekday - 1];
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: _teal,
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          'Productivity',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
    final date = Text(
      '$weekday, $gregorian\n$hijri',
      textAlign: TextAlign.right,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).hintColor),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 8),
                  _sectionTabs(),
                  const SizedBox(height: 6),
                  Align(alignment: Alignment.centerRight, child: date),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                title,
                const SizedBox(width: 12),
                Expanded(child: _sectionTabs()),
                date,
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Tabs stay on this page; they show or hide sections. They are not separate screens.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _sectionTabs() {
    Widget tab(_DashSection section, String label) {
      final selected = _section == section;
      return GestureDetector(
        onTap: () => setState(() => _section = section),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? _teal : Theme.of(context).hintColor,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      children: [
        tab(_DashSection.today, 'Today'),
        tab(_DashSection.planner, 'Planner'),
        tab(_DashSection.mal, 'Master List'),
        tab(_DashSection.history, 'History'),
      ],
    );
  }

  Widget _focusBanner(
    ProductivityAction? next,
    List<ProductivityAction> today,
  ) {
    final planned = plannedHours(today);
    final remaining = remainingHours(today);
    final dark = Theme.of(context).brightness == Brightness.dark;
    const kickerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _teal,
    );
    final timeBox = next == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Time remaining', style: kickerStyle),
              Text(
                formatEffortHours(remaining),
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: _teal, fontWeight: FontWeight.w700),
              ),
              Text(
                'of ${formatEffortHours(planned)} planned today',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
    final body = next == null
        ? const Text('Nothing queued')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today’s focus', style: kickerStyle),
              Text(
                next.title,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (next.note.isNotEmpty)
                Text(
                  next.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 6),
              _effortBar(next.percent, color: _teal),
              Text(
                '${next.percent}% of this action’s estimate · not a grade',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
    return _paper(
      key: const Key('productivity-focus'),
      color: dark ? widget.family.withValues(alpha: 0.28) : _focusWash,
      child: next == null
          ? body
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 420) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [body, const SizedBox(height: 10), timeBox],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: body),
                        const SizedBox(width: 12),
                        timeBox,
                      ],
                    );
                  },
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
    );
  }

  Widget _todayList(ProductivityStore store, List<ProductivityAction> today) {
    return _paper(
      child: Column(
        key: const Key('productivity-today-list'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s Actions ($kProductivityTodayCap)',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Reorder · tap a row for details · unfinished moves to tomorrow',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    key: const Key('productivity-add'),
                    style: FilledButton.styleFrom(backgroundColor: _teal),
                    onPressed: canAddToToday(store)
                        ? () => _openAddSheet()
                        : null,
                    child: const Text('+ Add action'),
                  ),
                  OutlinedButton(
                    key: const Key('productivity-pick-mal'),
                    onPressed: () => _openMalSheet(store),
                    child: const Text('Pick from Master List'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < kProductivityTodayCap; i++)
            if (i < today.length)
              _actionCard(store, today[i], index: i + 1, depth: 0)
            else
              _emptySlot(i + 1, enabled: canAddToToday(store)),
        ],
      ),
    );
  }

  Widget _emptySlot(int number, {required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        key: Key('productivity-slot-$number'),
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? () => _openAddSheet() : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: _teal.withValues(alpha: 0.25),
                  foregroundColor: _teal,
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Open slot $number of $kProductivityTodayCap',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  enabled ? 'Tap to add' : 'Today is full',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
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
    final selected = _selectedId == action.id;
    return Padding(
      padding: EdgeInsets.only(left: depth * 12, bottom: 8),
      child: Material(
        key: Key('productivity-action-${action.id}'),
        color: _priorityWash(action.priority),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? _teal : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _selectedId = action.id),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: _priorityColor(action.priority),
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Checkbox(
                      key: Key('productivity-complete-${action.id}'),
                      visualDensity: VisualDensity.compact,
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
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (action.note.isNotEmpty)
                            Text(
                              action.note,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (action.tags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  for (final tag in action.tags)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${formatEffortHours(action.hours)} · ${action.percent}% of estimate',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              _statusChip(action),
                              _priorityChip(action),
                              if (action.today) ...[
                                IconButton(
                                  key: Key('productivity-move-up-${action.id}'),
                                  visualDensity: VisualDensity.compact,
                                  iconSize: 18,
                                  onPressed: () => _save(
                                    (store) =>
                                        reorderToday(store, action.id, -1),
                                  ),
                                  icon: const Icon(Icons.arrow_upward),
                                ),
                                IconButton(
                                  key: Key(
                                    'productivity-move-down-${action.id}',
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  iconSize: 18,
                                  onPressed: () => _save(
                                    (store) =>
                                        reorderToday(store, action.id, 1),
                                  ),
                                  icon: const Icon(Icons.arrow_downward),
                                ),
                              ],
                            ],
                          ),
                          if (blockedTitles.isNotEmpty)
                            Text(
                              'Waiting on ${blockedTitles.join(', ')}',
                              key: Key('productivity-blocked-${action.id}'),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          const SizedBox(height: 4),
                          _effortBar(action.percent, color: _teal),
                        ],
                      ),
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
    final colors = _statusColors(action.status);
    return PopupMenuButton<ProductivityStatus>(
      key: Key('productivity-status-${action.id}'),
      onSelected: (status) => _setStatus(action, status),
      itemBuilder: (context) => [
        for (final status in ProductivityStatus.values)
          if (status != ProductivityStatus.deleted)
            PopupMenuItem(value: status, child: Text(status.label)),
      ],
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.$1,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          action.status.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.$2,
          ),
        ),
      ),
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
        _malPanel(store, expanded: false),
        _historyPanel(store, now, expanded: false),
      ],
    );
  }

  Widget _malPanel(ProductivityStore store, {required bool expanded}) {
    return _paper(
      child: ExpansionTile(
        key: const Key('productivity-mal'),
        initiallyExpanded: expanded,
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
                      child: const Text('Use today'),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _historyPanel(
    ProductivityStore store,
    DateTime now, {
    required bool expanded,
  }) {
    return _paper(
      child: ExpansionTile(
        key: const Key('productivity-history'),
        initiallyExpanded: expanded,
        title: const Text('History and trends'),
        children: [
          _timeCard(
            plannedHours(store.todayActions),
            recordedHours(store.todayActions),
            remainingHours(store.todayActions),
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
    );
  }

  Widget _paper({Key? key, required Widget child, Color? color}) {
    return Material(
      key: key,
      color: color ?? Theme.of(context).colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
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

  Widget _effortBar(int percent, {Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: (percent.clamp(0, 100)) / 100,
        color: color,
        backgroundColor: (color ?? Theme.of(context).colorScheme.primary)
            .withValues(alpha: 0.18),
        minHeight: 8,
      ),
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

const _teal = Color(0xFF2F6F73);
const _focusWash = Color(0xFFE7F6EE);

(Color, Color) _statusColors(ProductivityStatus status) => switch (status) {
  ProductivityStatus.needsLook => (
    const Color(0xFFFAD4D4),
    const Color(0xFF8A2F2F),
  ),
  ProductivityStatus.completed => (
    const Color(0xFFD7F0E2),
    const Color(0xFF216246),
  ),
  ProductivityStatus.inProgress => (
    const Color(0xFFD9E7FA),
    const Color(0xFF2A4F86),
  ),
  ProductivityStatus.paused => (
    const Color(0xFFF3EAD4),
    const Color(0xFF6A5420),
  ),
  ProductivityStatus.notStarted || ProductivityStatus.deleted => (
    const Color(0xFFE8ECEE),
    const Color(0xFF4D5C63),
  ),
};

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
