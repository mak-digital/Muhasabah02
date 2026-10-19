import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/domain_action.dart' hide formatDayMonthYear;
import '../../domain/monitor_domain.dart';
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
    final listed =
        ref.watch(domainActionsProvider).asData?.value ??
        const <DomainAction>[];
    final candidates = openMasterListCandidates(listed);
    final today = store.visibleTodayActions;
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
          candidates: candidates,
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
                  _collapsedPanels(store, now, candidates),
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
                        candidates: candidates,
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
    required List<DomainAction> candidates,
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
        return [_malPanel(store, candidates, expanded: true)];
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
    required List<DomainAction> candidates,
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
        _collapsedPanels(store, now, candidates),
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
              _effortBar(
                next.percent,
                color: _paceColor(
                  paceForAction(next, ref.read(nowClockProvider)()),
                ),
              ),
              Text(
                '${next.percent}% of this action’s estimate · not a grade',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                paceForAction(next, ref.read(nowClockProvider)()).label,
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
    final cap = effectiveTodayCap(store);
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
                    'Today’s Actions (${today.length} of $cap)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Six dots open sub-activities · three dots edit · unfinished moves to tomorrow',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontSize: 12, height: 1.3),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    key: const Key('productivity-add'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _teal,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _openAddSheet(),
                    child: const Text('+ Add action'),
                  ),
                  OutlinedButton(
                    key: const Key('productivity-pick-mal'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _openMalSheet(store),
                    child: const Text('Pick from Master List'),
                  ),
                  OutlinedButton(
                    key: const Key('productivity-register'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _openRegisterSheet(),
                    child: const Text('Productivity register'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'How many to show today',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Wrap(
            spacing: 4,
            children: [
              for (var n = 1; n <= kProductivityTodayCap; n++)
                ChoiceChip(
                  key: Key('productivity-today-slots-$n'),
                  label: Text('$n'),
                  selected: cap == n,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) =>
                      _save((current) => setTodaySlotCount(current, n)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (today.isEmpty)
            Text(
              'Nothing on today’s board. Add an action or copy one from the Master List. Extra items stay in the Productivity register.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            for (var i = 0; i < today.length; i++)
              _actionCard(store, today[i], index: i + 1, depth: 0),
        ],
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
    final selected = _selectedId == action.id;
    final now = ref.read(nowClockProvider)();
    final pace = paceForAction(action, now);
    const titleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.2,
    );
    final noteStyle = TextStyle(
      fontSize: 12,
      height: 1.3,
      color: Theme.of(context).hintColor,
    );
    final tagStyle = TextStyle(
      fontSize: 11,
      height: 1.2,
      color: Theme.of(context).hintColor,
    );
    return Padding(
      padding: EdgeInsets.only(left: depth * 10, bottom: 8),
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
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 520;
                final handle = IconButton(
                  key: Key('productivity-details-${action.id}'),
                  tooltip: 'Sub-activities',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.drag_indicator, size: 22),
                  onPressed: () => _openDetailsSheet(action),
                );
                final disc = CircleAvatar(
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
                );
                final check = Checkbox(
                  key: Key('productivity-complete-${action.id}'),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: action.status == ProductivityStatus.completed,
                  onChanged: (value) {
                    _setStatus(
                      action,
                      value == true
                          ? ProductivityStatus.completed
                          : ProductivityStatus.notStarted,
                    );
                  },
                );
                final titleCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    if (action.note.isNotEmpty)
                      Text(
                        action.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: noteStyle,
                      ),
                    if (action.tags.isNotEmpty)
                      Text(
                        action.tags.join(' › '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tagStyle,
                      ),
                    if (blockedTitles.isNotEmpty)
                      Text(
                        'Waiting on ${blockedTitles.join(', ')}',
                        key: Key('productivity-blocked-${action.id}'),
                        style: tagStyle,
                      ),
                  ],
                );
                final hoursCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatEffortHours(action.hours),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 72,
                      child: _effortBar(
                        action.percent,
                        color: _paceColor(pace),
                      ),
                    ),
                    Text('${action.percent}%', style: tagStyle),
                  ],
                );
                final chevron = IconButton(
                  tooltip: 'Sub-activities',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_right, size: 22),
                  onPressed: () => _openDetailsSheet(action),
                );
                final menu = PopupMenuButton<String>(
                  key: Key('productivity-menu-${action.id}'),
                  tooltip: 'Edit action',
                  onSelected: (value) {
                    switch (value) {
                      case 'rename':
                        _renameTitle(action);
                      case 'edit':
                        _openEditSheet(action);
                      case 'subs':
                        _openDetailsSheet(action);
                      case 'priority':
                        _cyclePriority(action);
                      case 'up':
                        _save((store) => reorderToday(store, action.id, -1));
                      case 'down':
                        _save((store) => reorderToday(store, action.id, 1));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'rename', child: Text('Rename')),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit information'),
                    ),
                    const PopupMenuItem(
                      value: 'subs',
                      child: Text('Sub-activities'),
                    ),
                    PopupMenuItem(
                      key: Key('productivity-priority-${action.id}'),
                      value: 'priority',
                      child: Text(
                        'Priority: ${action.priority.number} ${action.priority.shortLabel}',
                      ),
                    ),
                    if (action.today) ...[
                      PopupMenuItem(
                        key: Key('productivity-move-up-${action.id}'),
                        value: 'up',
                        child: const Text('Move up'),
                      ),
                      PopupMenuItem(
                        key: Key('productivity-move-down-${action.id}'),
                        value: 'down',
                        child: const Text('Move down'),
                      ),
                    ],
                  ],
                  icon: const Icon(Icons.more_vert, size: 20),
                );
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      handle,
                      disc,
                      check,
                      Expanded(child: titleCol),
                      hoursCol,
                      const SizedBox(width: 6),
                      _statusChip(action),
                      chevron,
                      menu,
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        handle,
                        disc,
                        check,
                        Expanded(child: titleCol),
                        menu,
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 8, 0),
                      child: Row(
                        children: [
                          hoursCol,
                          const SizedBox(width: 8),
                          _statusChip(action),
                          const Spacer(),
                          chevron,
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _cyclePriority(ProductivityAction action) {
    final next =
        ProductivityPriority.values[(action.priority.index + 1) %
            ProductivityPriority.values.length];
    _save((store) {
      final stamp = ref.read(nowClockProvider)();
      var nextStore = upsertAction(store, action.copyWith(priority: next));
      return recordProductivityEvent(
        nextStore,
        kind: 'priorityChanged',
        at: stamp,
        actionId: action.id,
        detail: next.shortLabel,
      );
    });
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            Text(
              'Entered: ${formatDayMonthYear(action.createdAt, DisplayCalendar.gregorian)}',
            ),
            Text('Listing: ${action.listing.label}'),
            Text('Status: ${action.status.label}'),
            Text(
              'Priority: ${action.priority.number} ${action.priority.shortLabel}',
            ),
            if (action.sourceDomainId != null)
              Text('Source domain: ${action.sourceDomainId}'),
            Text('Sub-activities: ${action.subtasks.length}'),
            Text('Estimate: ${formatEffortHours(action.hours)}'),
            if (action.targetDateKey != null)
              Text('Target: ${action.targetDateKey}'),
            if (blocked.isNotEmpty)
              Text('Must complete before: ${blocked.join(', ')}'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _openDetailsSheet(action),
              child: const Text('Open details'),
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

  Widget _collapsedPanels(
    ProductivityStore store,
    DateTime now,
    List<DomainAction> candidates,
  ) {
    return Column(
      children: [
        _malPanel(store, candidates, expanded: false),
        _historyPanel(store, now, expanded: false),
      ],
    );
  }

  Widget _malPanel(
    ProductivityStore store,
    List<DomainAction> candidates, {
    required bool expanded,
  }) {
    return _paper(
      child: ExpansionTile(
        key: const Key('productivity-mal'),
        initiallyExpanded: expanded,
        title: const Text('Master Action List'),
        subtitle: const Text(
          'Open actions from other domains. Copy into Productivity to work them here.',
        ),
        children: [
          if (candidates.isEmpty)
            const ListTile(
              dense: true,
              title: Text('No open actions on other domains yet.'),
            )
          else
            for (final action in candidates)
              CheckboxListTile(
                key: Key('productivity-mal-row-${action.id}'),
                dense: true,
                value: alreadyImportedSource(store, action.id),
                onChanged: alreadyImportedSource(store, action.id)
                    ? null
                    : (_) => _importSources([action]),
                title: Text(action.title),
                subtitle: Text(
                  '${action.domain.shortLabel} · ${action.id} · ${formatDayMonthYear(action.createdAt, DisplayCalendar.gregorian)} · ${action.priority.name}',
                ),
              ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _openMalSheet(store),
              child: const Text('Fetch / copy…'),
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
            plannedHours(store.visibleTodayActions),
            recordedHours(store.visibleTodayActions),
            remainingHours(store.visibleTodayActions),
          ),
          _monthCalendar(now),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => _openRegisterSheet(),
              child: const Text('Open Productivity register'),
            ),
          ),
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
  ) async {
    await _save((store) {
      return markProductivityStatus(
        store,
        action,
        status,
        now: ref.read(nowClockProvider)(),
      );
    });
    if (status == ProductivityStatus.completed && mounted) {
      final store = ref.read(productivityStoreRepositoryProvider).store;
      if (pendingRegisterActions(store).isNotEmpty) {
        await _openRegisterSheet(pendingOnly: true);
      }
    }
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
    final listed =
        ref.read(domainActionsProvider).asData?.value ?? const <DomainAction>[];
    final candidates = openMasterListCandidates(listed);
    final selected = <String>{};
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  key: const Key('productivity-mal-sheet'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Master Action List',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Open actions from other domains. Tick rows, then Fetch / copy into Productivity.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: candidates.isEmpty
                          ? const Text('No open actions on other domains yet.')
                          : ListView(
                              shrinkWrap: true,
                              children: [
                                for (final action in candidates)
                                  CheckboxListTile(
                                    key: Key(
                                      'productivity-mal-pick-${action.id}',
                                    ),
                                    dense: true,
                                    value: selected.contains(action.id),
                                    onChanged:
                                        alreadyImportedSource(store, action.id)
                                        ? null
                                        : (value) {
                                            setModal(() {
                                              if (value == true) {
                                                selected.add(action.id);
                                              } else {
                                                selected.remove(action.id);
                                              }
                                            });
                                          },
                                    title: Text(action.title),
                                    subtitle: Text(
                                      '${action.domain.shortLabel} · ID ${action.id} · ${formatDayMonthYear(action.createdAt, DisplayCalendar.gregorian)} · ${action.priority.name}',
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      key: const Key('productivity-mal-import'),
                      onPressed: selected.isEmpty
                          ? null
                          : () {
                              final picked = [
                                for (final action in candidates)
                                  if (selected.contains(action.id)) action,
                              ];
                              Navigator.pop(context);
                              _importSources(picked);
                            },
                      child: const Text('Fetch / copy'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _importSources(List<DomainAction> sources) async {
    var needsPick = false;
    await _save((store) {
      var next = store;
      final clock = ref.read(nowClockProvider);
      for (final source in sources) {
        final before = next.actions.length;
        final wantToday = canAddToToday(next);
        next = importDomainAction(
          next,
          source,
          now: clock(),
          addToToday: wantToday,
        );
        if (next.actions.length > before && !wantToday) needsPick = true;
      }
      return next;
    });
    if (needsPick && mounted) await _openTodayPicker();
  }

  String _registerSubtitle(ProductivityStore store, ProductivityAction action) {
    final entered = formatDayMonthYear(
      action.createdAt,
      DisplayCalendar.gregorian,
    );
    final kids = childrenOf(store, action.id).length;
    final source = action.sourceDomainId ?? 'Productivity';
    return '${action.listing.label} · ${action.priority.shortLabel} · entered $entered · ${action.id} · $source · $kids children';
  }

  Future<void> _openRegisterSheet({bool pendingOnly = false}) async {
    final store = ref.read(productivityStoreRepositoryProvider).store;
    final rows = pendingOnly ? pendingRegisterActions(store) : store.masterList;
    final selected = <String>{};
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  key: const Key('productivity-register-sheet'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      pendingOnly
                          ? 'Pending in the Productivity register'
                          : 'Productivity register',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pendingOnly
                          ? 'Tick a pending action, then Fetch / copy to put it on today’s board.'
                          : 'Tick pending actions, then Fetch / copy to put them on today’s board.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: rows.isEmpty
                          ? Text(
                              pendingOnly
                                  ? 'No pending actions.'
                                  : 'The register is empty.',
                            )
                          : ListView(
                              shrinkWrap: true,
                              children: [
                                for (final action in rows)
                                  CheckboxListTile(
                                    key: Key(
                                      'productivity-register-row-${action.id}',
                                    ),
                                    dense: true,
                                    value: selected.contains(action.id),
                                    onChanged:
                                        action.listing ==
                                            ProductivityListing.pending
                                        ? (value) {
                                            setModal(() {
                                              if (value == true) {
                                                selected.add(action.id);
                                              } else {
                                                selected.remove(action.id);
                                              }
                                            });
                                          }
                                        : null,
                                    title: Text(action.title),
                                    subtitle: Text(
                                      _registerSubtitle(store, action),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      key: const Key('productivity-register-import'),
                      onPressed: selected.isEmpty
                          ? null
                          : () {
                              final ids = [...selected];
                              Navigator.pop(context);
                              _save((current) {
                                var next = current;
                                for (final id in ids) {
                                  next = setTodayFlag(next, id, true);
                                }
                                return next;
                              });
                            },
                      child: const Text('Fetch / copy'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openTodayPicker() async {
    final store = ref.read(productivityStoreRepositoryProvider).store;
    final cap = kProductivityTodayCap;
    final open = [
      for (final action in store.masterList)
        if (action.status.isOpen) action,
    ];
    final selected = [for (final action in store.visibleTodayActions) action.id]
        .toSet();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  key: const Key('productivity-today-pick'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Choose up to $cap for today'),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final action in open)
                            CheckboxListTile(
                              dense: true,
                              value: selected.contains(action.id),
                              onChanged: (value) {
                                setModal(() {
                                  if (value == true) {
                                    if (selected.length >= cap) {
                                      selected.remove(selected.first);
                                    }
                                    selected.add(action.id);
                                  } else {
                                    selected.remove(action.id);
                                  }
                                });
                              },
                              title: Text(action.title),
                            ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        final ids = [...selected];
                        Navigator.pop(context);
                        _save((current) => applyTodaySelection(current, ids));
                      },
                      child: const Text('Use these today'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _paceColor(ProductivityPace pace) => switch (pace) {
    ProductivityPace.ahead => _teal,
    ProductivityPace.onPlan => const Color(0xFF4D86D6),
    ProductivityPace.behind => const Color(0xFFC48A2A),
    ProductivityPace.unknown => Theme.of(context).hintColor,
  };

  Future<void> _openEditSheet(ProductivityAction action) async {
    final title = TextEditingController(text: action.title);
    final note = TextEditingController(text: action.note);
    final hours = TextEditingController(text: action.hours.toString());
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              TextField(
                controller: hours,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Expected hours'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    final nextTitle = title.text.trim();
                    final nextHours =
                        double.tryParse(hours.text) ?? action.hours;
                    Navigator.pop(context);
                    _save((store) {
                      final current = actionById(store, action.id) ?? action;
                      return upsertAction(
                        store,
                        current.copyWith(
                          title: nextTitle.isEmpty ? current.title : nextTitle,
                          note: note.text.trim(),
                          hours: nextHours,
                        ),
                      );
                    });
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _renameTitle(ProductivityAction action) async {
    final title = TextEditingController(text: action.title);
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Rename action'),
              TextField(
                key: const Key('productivity-rename-title'),
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Title only — other fields stay as they are',
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: const Key('productivity-rename-save'),
                  onPressed: () {
                    final value = title.text;
                    Navigator.pop(context);
                    _save(
                      (store) =>
                          renameProductivityAction(store, action.id, value),
                    );
                  },
                  child: const Text('Save title'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickTarget(DateTime? current) async {
    final now = ref.read(nowClockProvider)();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 6),
    );
    if (date == null || !mounted) return current;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current ?? now),
    );
    if (time == null) return DateTime(date.year, date.month, date.day);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _openDetailsSheet(ProductivityAction seed) async {
    final store = ref.read(productivityStoreRepositoryProvider).store;
    final action = actionById(store, seed.id) ?? seed;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _ProductivityDetailsPanel(
          action: action,
          kids: childrenOf(store, action.id),
          canLink: canAddChildUnder(store, action.id),
          now: ref.read(nowClockProvider)(),
          onPickTarget: _pickTarget,
          onPersist: (title, subtasks) {
            return _save((current) {
              var next = renameProductivityAction(current, action.id, title);
              final latest = actionById(next, action.id) ?? action;
              return applyActionSubtasks(next, latest, subtasks);
            });
          },
          onAddLinked: () => _openAddSheet(parentId: action.id),
          onOpenChild: _openDetailsSheet,
        );
      },
    );
  }

  Future<void> _createAction({
    required String title,
    required bool addToToday,
    double hours = 1,
    String? parentId,
  }) async {
    if (title.isEmpty) return;
    var needsPick = false;
    await _save((store) {
      if (parentId != null && !canAddChildUnder(store, parentId)) return store;
      final stamp = ref.read(nowClockProvider)();
      final placeToday = addToToday && canAddToToday(store);
      needsPick = addToToday && !placeToday && parentId == null;
      final action = ProductivityAction(
        id: newProductivityId(
          'act',
          stamp,
          disambiguator: store.actions.length,
        ),
        title: title,
        createdAt: stamp,
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
        at: stamp,
        actionId: action.id,
        detail: title,
      );
    });
    if (needsPick && mounted) await _openTodayPicker();
  }
}

class _ProductivityDetailsPanel extends StatefulWidget {
  const _ProductivityDetailsPanel({
    required this.action,
    required this.kids,
    required this.canLink,
    required this.now,
    required this.onPickTarget,
    required this.onPersist,
    required this.onAddLinked,
    required this.onOpenChild,
  });

  final ProductivityAction action;
  final List<ProductivityAction> kids;
  final bool canLink;
  final DateTime now;
  final Future<DateTime?> Function(DateTime? current) onPickTarget;
  final Future<void> Function(String title, List<ProductivitySubtask> subtasks)
  onPersist;
  final VoidCallback onAddLinked;
  final Future<void> Function(ProductivityAction child) onOpenChild;

  @override
  State<_ProductivityDetailsPanel> createState() =>
      _ProductivityDetailsPanelState();
}

class _ProductivityDetailsPanelState extends State<_ProductivityDetailsPanel> {
  late final TextEditingController _title;
  late List<ProductivitySubtask> _subtasks;
  var _saved = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.action.title);
    _subtasks = [...widget.action.subtasks];
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _flush() async {
    if (_saved) return;
    _saved = true;
    final title = _title.text.trim();
    await widget.onPersist(
      title.isEmpty ? widget.action.title : title,
      _subtasks,
    );
  }

  void _replace(int index, ProductivitySubtask item) {
    setState(() {
      _subtasks = [..._subtasks]..[index] = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weight = subtaskWeightTotal(_subtasks);
    final rolled = rolledUpSubtaskPercent(_subtasks);
    final draft = widget.action.copyWith(subtasks: _subtasks);
    final pace = paceForAction(draft, widget.now);
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _flush();
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + inset),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.86,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Details', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '$rolled% of the main action · ${pace.label}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextField(
                  key: Key('productivity-details-title-${widget.action.id}'),
                  controller: _title,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Action title',
                    helperText: 'Renaming does not change hours, dates, or %',
                  ),
                ),
                const SizedBox(height: 8),
                if (_subtasks.isNotEmpty)
                  Text(
                    subtaskWeightsComplete(_subtasks)
                        ? 'Shares add to 100%.'
                        : 'Shares now add to ${weight.round()}%. They should add to 100%.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Expanded(
                  child: ListView(
                    key: Key('productivity-details-sheet-${widget.action.id}'),
                    children: [
                      Text(
                        'Sub-activities',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      for (var i = 0; i < _subtasks.length; i++)
                        _subtaskCard(i),
                      TextButton(
                        key: Key(
                          'productivity-add-subtask-${widget.action.id}',
                        ),
                        onPressed: () {
                          final remaining = (100 - weight).clamp(0, 100);
                          setState(() {
                            _subtasks = [
                              ..._subtasks,
                              ProductivitySubtask(
                                title: 'Sub-activity ${_subtasks.length + 1}',
                                weight: remaining.toDouble(),
                              ),
                            ];
                          });
                        },
                        child: const Text('+ Add sub-activity'),
                      ),
                      if (_subtasks.length >= 2)
                        TextButton(
                          onPressed: () {
                            final share = 100 / _subtasks.length;
                            setState(() {
                              _subtasks = [
                                for (final item in _subtasks)
                                  item.copyWith(weight: share),
                              ];
                            });
                          },
                          child: const Text('Split shares equally'),
                        ),
                      if (widget.kids.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Linked actions',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        for (final child in widget.kids)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(child.title),
                            subtitle: Text(child.listing.label),
                            trailing: TextButton(
                              onPressed: () async {
                                await _flush();
                                if (!context.mounted) return;
                                await widget.onOpenChild(child);
                              },
                              child: const Text('Details'),
                            ),
                          ),
                      ],
                      if (widget.canLink)
                        TextButton(
                          onPressed: widget.onAddLinked,
                          child: const Text('Add linked action'),
                        ),
                    ],
                  ),
                ),
                FilledButton(
                  key: const Key('productivity-details-save'),
                  onPressed: () async {
                    await _flush();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save and close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _subtaskCard(int index) {
    final item = _subtasks[index];
    return Card(
      key: Key('productivity-subtask-${widget.action.id}-$index'),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: Key('productivity-subtask-title-${widget.action.id}-$index'),
              initialValue: item.title,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'What is this step?',
                isDense: true,
              ),
              onChanged: (value) {
                _subtasks[index] = _subtasks[index].copyWith(title: value);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Expected time: ${formatEffortHours(item.hours)}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _replace(
                    index,
                    item.copyWith(hours: (item.hours - 0.25).clamp(0.25, 40)),
                  ),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(formatEffortHours(item.hours)),
                IconButton(
                  onPressed: () => _replace(
                    index,
                    item.copyWith(hours: (item.hours + 0.25).clamp(0.25, 40)),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Text(
              'Share of the main action: ${item.weight.round()}%',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Slider(
              key: Key(
                'productivity-subtask-weight-${widget.action.id}-$index',
              ),
              value: item.weight.clamp(0, 100),
              min: 0,
              max: 100,
              divisions: 20,
              label: '${item.weight.round()}%',
              onChanged: (value) =>
                  _replace(index, item.copyWith(weight: value)),
            ),
            Text(
              'Done on this step: ${item.percent}%',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Slider(
              key: Key(
                'productivity-subtask-percent-${widget.action.id}-$index',
              ),
              value: item.percent.toDouble().clamp(0, 100),
              min: 0,
              max: 100,
              divisions: 20,
              label: '${item.percent}%',
              onChanged: (value) =>
                  _replace(index, item.copyWith(percent: value.round())),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                item.targetAt == null
                    ? 'No target date and time'
                    : _formatTarget(context, item.targetAt!),
              ),
              subtitle: const Text('When this step should be finished'),
              trailing: Wrap(
                children: [
                  TextButton(
                    onPressed: () async {
                      final at = await widget.onPickTarget(item.targetAt);
                      _replace(
                        index,
                        item.copyWith(targetAt: at, clearTarget: at == null),
                      );
                    },
                    child: const Text('Set date'),
                  ),
                  IconButton(
                    tooltip: 'Delete this step',
                    onPressed: () {
                      setState(() {
                        _subtasks = [..._subtasks]..removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTarget(BuildContext context, DateTime at) {
  final local = MaterialLocalizations.of(context);
  return '${local.formatMediumDate(at)} · ${local.formatTimeOfDay(TimeOfDay.fromDateTime(at))}';
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
