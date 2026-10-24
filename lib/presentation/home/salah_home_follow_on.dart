import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/dev_feedback.dart';
import '../../domain/domain_action.dart';
import '../../domain/ids.dart';
import '../../domain/monitor_domain.dart';
import '../shared/domain_visual.dart';
import '../shared/ui_bits.dart';
import 'practice_dhikr_home.dart';
import 'practice_hadith_home.dart';

void _revealInHomeScroll(
  BuildContext fallback, {
  GlobalKey? key,
  double alignment = 0.12,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final context = key?.currentContext ?? fallback;
    if (!context.mounted) return;
    await Scrollable.ensureVisible(
      context,
      alignment: alignment,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  });
}

ButtonStyle get _compactFillStyle => FilledButton.styleFrom(
  visualDensity: VisualDensity.compact,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  minimumSize: const Size.fromHeight(36),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
);

ButtonStyle get _compactOutlineStyle => OutlinedButton.styleFrom(
  visualDensity: VisualDensity.compact,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  minimumSize: const Size.fromHeight(32),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
);

Widget _followOnLinkPair({
  required Key leftKey,
  required String leftLabel,
  required VoidCallback onLeft,
  required Key rightKey,
  required String rightLabel,
  required VoidCallback onRight,
}) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          key: leftKey,
          style: _compactOutlineStyle,
          onPressed: onLeft,
          child: Text(leftLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton(
          key: rightKey,
          style: _compactOutlineStyle,
          onPressed: onRight,
          child: Text(rightLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    ],
  );
}

Key followOnKey(MonitorDomain domain, String rest) => Key('${domain.id}-$rest');

/// Learn & Practice for the domain currently on Home. Shown under the domain
/// chrome so the wash is not lost below a tall week grid.
Widget? homePracticeWash(MonitorDomain domain) {
  return switch (domain) {
    MonitorDomain.salah => PracticeSalahWash(domain: domain),
    MonitorDomain.quran => PracticeQuranWash(domain: domain),
    MonitorDomain.hadith => PracticeHadithWash(domain: domain),
    MonitorDomain.dhikr => PracticeDhikrWash(domain: domain),
    MonitorDomain.akhlaq => PracticeAkhlaqWash(domain: domain),
    MonitorDomain.huquq => PracticeHuquqWash(domain: domain),
    MonitorDomain.knowledge => PracticeKnowledgeWash(domain: domain),
    MonitorDomain.time => PracticeTimeWash(domain: domain),
    MonitorDomain.health => PracticeHealthWash(domain: domain),
    MonitorDomain.wealth => PracticeWealthWash(domain: domain),
    MonitorDomain.ummah => PracticeUmmahWash(domain: domain),
    MonitorDomain.fasting => PracticeFastingWash(domain: domain),
    MonitorDomain.hajj => PracticeHajjWash(domain: domain),
    MonitorDomain.productivity => null,
    MonitorDomain.charity => PracticeCharityWash(domain: domain),
  };
}

class DomainHomeFollowOn extends ConsumerWidget {
  const DomainHomeFollowOn({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SalahActionsWash(domain: domain),
        const SizedBox(height: 10),
        _SalahDeveloperNotesWash(domain: domain),
      ],
    );
  }
}

class SalahHomeFollowOn extends DomainHomeFollowOn {
  const SalahHomeFollowOn({super.key}) : super(domain: MonitorDomain.salah);
}

class _SalahActionsWash extends ConsumerStatefulWidget {
  const _SalahActionsWash({required this.domain});

  final MonitorDomain domain;

  @override
  ConsumerState<_SalahActionsWash> createState() => _SalahActionsWashState();
}

enum _ActionCircleChoice { completed, active, edit, delete }

class _SalahActionsWashState extends ConsumerState<_SalahActionsWash> {
  final _title = TextEditingController();
  final _formKey = GlobalKey();
  var _priority = ActionPriority.week;
  var _composing = false;
  var _aboutOpen = true;
  late String _targetDateKey;
  String? _error;

  void _collapseAbout() {
    if (!_aboutOpen) return;
    setState(() => _aboutOpen = false);
  }

  @override
  void initState() {
    super.initState();
    _targetDateKey = dateKey(ref.read(nowProvider));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(nowProvider);
    final actions = ref.watch(domainActionsProvider).value ?? const [];
    final domain = widget.domain;
    final salah = actionsForDomain(actions, domain);
    final strip = actionStripForHome(salah);
    final identity = domainColorIdentity(domain);
    final wash = identity.washFor(Theme.of(context).brightness, context);
    return WashPanel(
      key: followOnKey(domain, 'actions-panel'),
      color: wash,
      padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: followOnKey(domain, 'actions-wash'),
          initiallyExpanded: false,
          dense: true,
          visualDensity: VisualDensity.compact,
          minTileHeight: 40,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
          onExpansionChanged: (open) {
            if (open) _revealInHomeScroll(context);
          },
          title: Text(
            Copy.domainActionsTitle(domain.shortLabel),
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          children: [
            CollapsingIntroNote(
              key: followOnKey(domain, 'actions-about'),
              title: Copy.washAboutTitle,
              note: Copy.domainActionsNote,
              expanded: _aboutOpen,
              onExpansionChanged: (open) {
                if (open == _aboutOpen) return;
                setState(() => _aboutOpen = open);
              },
            ),
            if (strip.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  Copy.actionEmpty,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              for (var i = 0; i < strip.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _actionRow(
                  action: strip[i],
                  now: now,
                  activeCount: [
                    for (final item in strip)
                      if (item.status == ActionStatus.open) item,
                  ].length,
                  index: i,
                ),
              ],
            const SizedBox(height: 8),
            _followOnLinkPair(
              leftKey: followOnKey(domain, 'action-add'),
              leftLabel: Copy.addAction,
              onLeft: () {
                _collapseAbout();
                _toggleComposer(salah);
              },
              rightKey: followOnKey(domain, 'open-register'),
              rightLabel: Copy.openActionRegister,
              onRight: () {
                _collapseAbout();
                _openRegister();
              },
            ),
            if (_composing)
              KeyedSubtree(key: _formKey, child: _actionForm(now)),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionForm(DateTime now) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: followOnKey(widget.domain, 'action-title'),
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: Copy.actionField),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const SizedBox(height: 8),
        _DatePriorityRow(
          targetDateKey: _targetDateKey,
          priority: _priority,
          onPickDate: () => _pickDate(now),
          onPriority: (value) => setState(() => _priority = value),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: followOnKey(widget.domain, 'action-save'),
          style: _compactFillStyle,
          onPressed: _save,
          child: const Text(Copy.saveListedAction),
        ),
      ],
    );
  }

  Widget _actionRow({
    required DomainAction action,
    required DateTime now,
    required int activeCount,
    required int index,
  }) {
    final tone = chipToneFor(action, now);
    final open = action.status == ActionStatus.open;
    return Material(
      key: followOnKey(widget.domain, 'action-chip-${action.id}'),
      color: _toneColor(tone),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _statusCircle(action, now),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.2, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _rowMeta(action, now),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(height: 1.15),
                  ),
                ],
              ),
            ),
            if (open) ...[
              _nudgeButton(
                key: followOnKey(widget.domain, 'action-up-${action.id}'),
                tooltip: Copy.moveActionUp,
                icon: Icons.keyboard_arrow_up,
                onPressed: index > 0 ? () => _move(action, -1) : null,
              ),
              _nudgeButton(
                key: followOnKey(widget.domain, 'action-down-${action.id}'),
                tooltip: Copy.moveActionDown,
                icon: Icons.keyboard_arrow_down,
                onPressed: index < activeCount - 1
                    ? () => _move(action, 1)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusCircle(DomainAction action, DateTime now) {
    final tone = chipToneFor(action, now);
    final color = _circleColor(tone);
    final settled = action.status.isSettled;
    final mark = Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: settled ? color : color.withValues(alpha: 0.16),
        border: Border.all(color: color, width: 2.5),
      ),
      child: action.status == ActionStatus.done
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : action.status == ActionStatus.deleted
          ? const Icon(Icons.close, size: 14, color: Colors.white)
          : null,
    );
    if (settled) {
      return Tooltip(
        message: Copy.parkSettledAction,
        child: InkWell(
          key: followOnKey(widget.domain, 'action-menu-${action.id}'),
          customBorder: const CircleBorder(),
          onTap: () => _parkSettled(action),
          child: mark,
        ),
      );
    }
    return PopupMenuButton<_ActionCircleChoice>(
      key: followOnKey(widget.domain, 'action-menu-${action.id}'),
      tooltip: Copy.actionCircleMenu,
      onSelected: (choice) => _onCircleChoice(action, choice, now),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ActionCircleChoice.completed,
          child: Text(Copy.actionCompletedClosed),
        ),
        PopupMenuItem(
          value: _ActionCircleChoice.active,
          child: Text(Copy.actionInProgressActive),
        ),
        PopupMenuItem(
          value: _ActionCircleChoice.edit,
          child: Text(Copy.actionEdit),
        ),
        PopupMenuItem(
          value: _ActionCircleChoice.delete,
          child: Text(Copy.deleteAction),
        ),
      ],
      child: mark,
    );
  }

  Widget _nudgeButton({
    required Key key,
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        key: key,
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(28, 28),
          padding: EdgeInsets.zero,
        ),
        icon: Icon(icon, size: 18),
      ),
    );
  }

  Color _toneColor(ActionChipTone tone) {
    final brightness = Theme.of(context).brightness;
    return switch (tone) {
      ActionChipTone.deleted => MuhasabahColors.wash(
        MuhasabahColors.summaryWash,
        MuhasabahColors.summaryWashDark,
        brightness,
        context,
      ),
      ActionChipTone.done => MuhasabahColors.wash(
        MuhasabahColors.salahVoluntaryBand,
        MuhasabahColors.salahVoluntaryBandDark,
        brightness,
        context,
      ),
      ActionChipTone.pastTarget => MuhasabahColors.missedEarth.withValues(
        alpha: brightness == Brightness.dark ? 0.45 : 0.28,
      ),
      ActionChipTone.soon => MuhasabahColors.wash(
        MuhasabahColors.todayMarkWash,
        MuhasabahColors.todayMarkWashDark,
        brightness,
        context,
      ),
      ActionChipTone.week => MuhasabahColors.wash(
        MuhasabahColors.salahFridayBand,
        MuhasabahColors.salahFridayBandDark,
        brightness,
        context,
      ),
      ActionChipTone.later => MuhasabahColors.wash(
        MuhasabahColors.summaryWash,
        MuhasabahColors.summaryWashDark,
        brightness,
        context,
      ),
    };
  }

  Color _circleColor(ActionChipTone tone) {
    return switch (tone) {
      ActionChipTone.deleted => const Color(0xFF616161),
      ActionChipTone.done => const Color(0xFF2E7D32),
      ActionChipTone.pastTarget => MuhasabahColors.missedEarth,
      ActionChipTone.soon => const Color(0xFFC49A3C),
      ActionChipTone.week => MuhasabahColors.salahFamily,
      ActionChipTone.later => MuhasabahColors.journal,
    };
  }

  String _rowMeta(DomainAction action, DateTime now) {
    if (action.status.isSettled) {
      final ended = action.completedAt ?? action.targetDateKey;
      final label = action.status == ActionStatus.deleted
          ? Copy.actionDeleted
          : Copy.actionClosed;
      return '$label · ${formatDayMonthYear(ended)}';
    }
    final due = daysUntilTarget(action.targetDateKey, now);
    if (due < 0) {
      return 'Past target · ${formatDayMonthYear(action.targetDateKey)}';
    }
    if (due == 0) return 'Target today';
    if (due == 1) return 'Target tomorrow';
    final date = formatDayMonthYear(action.targetDateKey);
    return switch (action.priority) {
      ActionPriority.soon => '${Copy.actionPrioritySoon} · $date',
      ActionPriority.week => '${Copy.actionPriorityWeek} · $date',
      ActionPriority.later => '${Copy.actionPriorityLater} · $date',
    };
  }

  void _toggleComposer(List<DomainAction> salah) {
    if (!canAddActiveAction(salah)) {
      setState(() {
        _composing = false;
        _error = Copy.actionLimitReached;
      });
      return;
    }
    setState(() {
      _composing = !_composing;
      _error = null;
    });
    if (_composing) {
      _revealInHomeScroll(context, key: _formKey, alignment: 0.92);
    }
  }

  Future<void> _pickDate(DateTime now) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: parseDateKey(_targetDateKey),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );
    if (picked == null) return;
    setState(() => _targetDateKey = dateKey(picked));
  }

  Future<void> _save() async {
    if (validateActionTitle(_title.text) != null) {
      setState(() => _error = Copy.actionNeedsText);
      return;
    }
    final notifier = ref.read(domainActionsProvider.notifier);
    final actions = ref.read(domainActionsProvider).value ?? const [];
    final salah = actionsForDomain(actions, widget.domain);
    if (!canAddActiveAction(salah)) {
      setState(() {
        _composing = false;
        _error = Copy.actionLimitReached;
      });
      return;
    }
    final now = ref.read(nowProvider);
    for (final parked in parkOverflowListedClosed([
      ...salah,
      DomainAction(
        id: 'pending',
        domain: widget.domain,
        title: 'pending',
        targetDateKey: _targetDateKey,
        priority: _priority,
        status: ActionStatus.open,
        createdAt: now,
        sortOrder: nextActiveSortOrder(salah),
      ),
    ])) {
      if (parked.id == 'pending') continue;
      await notifier.save(parked);
    }
    await notifier.save(
      DomainAction(
        id: newOpaqueId(),
        domain: widget.domain,
        title: normalizeActionTitle(_title.text),
        targetDateKey: _targetDateKey,
        priority: _priority,
        status: ActionStatus.open,
        createdAt: now,
        sortOrder: nextActiveSortOrder(salah),
        listedOnHome: true,
      ),
    );
    _title.clear();
    setState(() {
      _error = null;
      _composing = false;
    });
  }

  Future<void> _onCircleChoice(
    DomainAction action,
    _ActionCircleChoice choice,
    DateTime now,
  ) async {
    final notifier = ref.read(domainActionsProvider.notifier);
    switch (choice) {
      case _ActionCircleChoice.completed:
        await notifier.save(
          action.copyWith(
            status: ActionStatus.done,
            listedOnHome: true,
            completedAt: dateKey(now),
          ),
        );
      case _ActionCircleChoice.active:
        return;
      case _ActionCircleChoice.edit:
        await _openEditSheet(action);
      case _ActionCircleChoice.delete:
        await notifier.save(
          action.copyWith(
            status: ActionStatus.deleted,
            listedOnHome: true,
            completedAt: dateKey(now),
          ),
        );
    }
  }

  Future<void> _parkSettled(DomainAction action) {
    return ref
        .read(domainActionsProvider.notifier)
        .save(action.copyWith(listedOnHome: false));
  }

  Future<void> _openEditSheet(DomainAction action) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return _EditActionSheet(action: action);
      },
    );
  }

  Future<void> _move(DomainAction action, int delta) async {
    final actions = ref.read(domainActionsProvider).value ?? const [];
    final salah = actionsForDomain(actions, widget.domain);
    final changed = movedActiveActions(salah, action.id, delta);
    for (final next in changed) {
      await ref.read(domainActionsProvider.notifier).save(next);
    }
  }

  void _openRegister() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _ActionRegisterSheet(domain: widget.domain),
    );
  }
}

class _ActionRegisterSheet extends ConsumerStatefulWidget {
  const _ActionRegisterSheet({required this.domain});

  final MonitorDomain domain;

  @override
  ConsumerState<_ActionRegisterSheet> createState() =>
      _ActionRegisterSheetState();
}

class _ActionRegisterSheetState extends ConsumerState<_ActionRegisterSheet> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(domainActionsProvider).value ?? const [];
    final rows = registerActions(actionsForDomain(actions, widget.domain));
    final ids = {for (final action in rows) action.id};
    final allSelected = rows.isNotEmpty && ids.every(_selected.contains);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Copy.actionRegisterTitle(widget.domain.shortLabel),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const BalancedProse(Copy.actionRegisterNote),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Text(Copy.actionRegisterEmpty)
          else ...[
            Row(
              children: [
                TextButton(
                  key: followOnKey(widget.domain, 'register-select-all'),
                  onPressed: () {
                    setState(() {
                      if (allSelected) {
                        _selected.clear();
                      } else {
                        _selected
                          ..clear()
                          ..addAll(ids);
                      }
                    });
                  },
                  child: const Text(Copy.actionSelectAll),
                ),
                const Spacer(),
                FilledButton(
                  key: followOnKey(widget.domain, 'register-delete'),
                  onPressed: _selected.isEmpty ? null : _deleteSelected,
                  child: const Text(Copy.actionDeleteSelected),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.45,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Checkbox(
                          key: followOnKey(widget.domain, 'register-check-all'),
                          value: allSelected
                              ? true
                              : _selected.isEmpty
                              ? false
                              : null,
                          tristate: true,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (_) {
                            setState(() {
                              if (allSelected) {
                                _selected.clear();
                              } else {
                                _selected
                                  ..clear()
                                  ..addAll(ids);
                              }
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          Copy.actionField,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      SizedBox(
                        width: 88,
                        child: Text(
                          Copy.actionStatusColumn,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  for (final action in rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              key: followOnKey(
                                widget.domain,
                                'register-check-${action.id}',
                              ),
                              value: _selected.contains(action.id),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selected.add(action.id);
                                  } else {
                                    _selected.remove(action.id);
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${action.title}\n${_priorityLabel(action.priority)} · ${formatDayMonthYear(action.targetDateKey)}',
                            ),
                          ),
                          SizedBox(
                            width: 88,
                            child: Text(
                              _statusLabel(action.status),
                              key: followOnKey(
                                widget.domain,
                                'register-status-${action.id}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(Copy.closeActionRegister),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text(Copy.actionConfirmPermanentDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(Copy.closeActionRegister),
            ),
            FilledButton(
              key: followOnKey(widget.domain, 'register-delete-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(Copy.actionConfirmPermanentDeleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final ids = [..._selected];
    await ref.read(domainActionsProvider.notifier).deleteMany(ids);
    if (!mounted) return;
    setState(_selected.clear);
  }

  String _statusLabel(ActionStatus status) {
    return switch (status) {
      ActionStatus.open => Copy.actionActive,
      ActionStatus.done => Copy.actionClosed,
      ActionStatus.deleted => Copy.actionDeleted,
    };
  }

  String _priorityLabel(ActionPriority priority) {
    return switch (priority) {
      ActionPriority.soon => Copy.actionPrioritySoon,
      ActionPriority.week => Copy.actionPriorityWeek,
      ActionPriority.later => Copy.actionPriorityLater,
    };
  }
}

class _SalahDeveloperNotesWash extends ConsumerStatefulWidget {
  const _SalahDeveloperNotesWash({required this.domain});

  final MonitorDomain domain;

  @override
  ConsumerState<_SalahDeveloperNotesWash> createState() =>
      _SalahDeveloperNotesWashState();
}

class _SalahDeveloperNotesWashState
    extends ConsumerState<_SalahDeveloperNotesWash> {
  final _body = TextEditingController();
  final _composerKey = GlobalKey();
  var _composing = false;
  var _aboutOpen = true;
  String? _error;
  String? _saved;

  void _collapseAbout() {
    if (!_aboutOpen) return;
    setState(() => _aboutOpen = false);
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identity = domainColorIdentity(widget.domain);
    final wash = identity.notesWashFor(Theme.of(context).brightness, context);
    return WashPanel(
      key: followOnKey(widget.domain, 'feedback-panel'),
      color: wash,
      padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: followOnKey(widget.domain, 'feedback-wash'),
          initiallyExpanded: false,
          dense: true,
          visualDensity: VisualDensity.compact,
          minTileHeight: 40,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
          onExpansionChanged: (open) {
            if (open) _revealInHomeScroll(context);
          },
          title: Text(
            Copy.developerNotesTitle,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          children: [
            CollapsingIntroNote(
              key: followOnKey(widget.domain, 'feedback-about'),
              title: Copy.washAboutTitle,
              note: Copy.developerNotesNote,
              expanded: _aboutOpen,
              onExpansionChanged: (open) {
                if (open == _aboutOpen) return;
                setState(() => _aboutOpen = open);
              },
            ),
            _followOnLinkPair(
              leftKey: followOnKey(widget.domain, 'note-add'),
              leftLabel: Copy.addDeveloperNote,
              onLeft: () {
                _collapseAbout();
                setState(() {
                  _composing = !_composing;
                  _error = null;
                });
                if (_composing) {
                  _revealInHomeScroll(
                    context,
                    key: _composerKey,
                    alignment: 0.92,
                  );
                }
              },
              rightKey: followOnKey(widget.domain, 'open-notes-register'),
              rightLabel: Copy.openNotesRegister,
              onRight: () {
                _collapseAbout();
                showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (context) =>
                      _NotesRegisterSheet(domain: widget.domain),
                );
              },
            ),
            if (_saved != null && !_composing) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _saved!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            if (_composing)
              Column(
                key: _composerKey,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: followOnKey(widget.domain, 'feedback-body'),
                    controller: _body,
                    autofocus: true,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: Copy.developerNotesPrompt,
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  if (_saved != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _saved!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    key: followOnKey(widget.domain, 'feedback-save'),
                    style: _compactFillStyle,
                    onPressed: _save,
                    child: const Text(Copy.saveDeveloperNote),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (validateFeedbackBody(_body.text) != null) {
      setState(() {
        _saved = null;
        _error = Copy.developerNoteNeedsText;
      });
      return;
    }
    final now = ref.read(nowProvider);
    final serial = await ref.read(devFeedbackProvider.notifier).nextSerial();
    await ref
        .read(devFeedbackProvider.notifier)
        .save(
          DevFeedback(
            id: newOpaqueId(),
            serial: serial,
            domain: widget.domain,
            dateKey: dateKey(now),
            body: normalizeFeedbackBody(_body.text),
            createdAt: now,
          ),
        );
    _body.clear();
    setState(() {
      _error = null;
      _composing = false;
      _saved = Copy.developerNoteSaved(
        formatFeedbackSerial(serial),
        widget.domain.shortLabel,
        formatDayMonthYear(dateKey(now)),
      );
    });
  }
}

class _NotesRegisterSheet extends ConsumerStatefulWidget {
  const _NotesRegisterSheet({required this.domain});

  final MonitorDomain domain;

  @override
  ConsumerState<_NotesRegisterSheet> createState() =>
      _NotesRegisterSheetState();
}

class _NotesRegisterSheetState extends ConsumerState<_NotesRegisterSheet> {
  final _selected = <String>{};
  String? _message;

  @override
  Widget build(BuildContext context) {
    final notes = registerDeveloperNotes(
      ref.watch(devFeedbackProvider).value ?? const [],
    );
    final ids = [for (final note in notes) note.id];
    final allSelected = ids.isNotEmpty && ids.every(_selected.contains);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Copy.notesRegisterTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const BalancedProse(Copy.notesRegisterNote),
          const SizedBox(height: 12),
          if (notes.isEmpty)
            const Text(Copy.notesRegisterEmpty)
          else ...[
            Row(
              children: [
                TextButton(
                  key: followOnKey(widget.domain, 'notes-select-all'),
                  onPressed: () {
                    setState(() {
                      if (allSelected) {
                        _selected.clear();
                      } else {
                        _selected
                          ..clear()
                          ..addAll(ids);
                      }
                    });
                  },
                  child: const Text(Copy.actionSelectAll),
                ),
                const Spacer(),
                FilledButton(
                  key: followOnKey(widget.domain, 'notes-delete'),
                  onPressed: _selected.isEmpty ? null : _deleteSelected,
                  child: const Text(Copy.actionDeleteSelected),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final note in notes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              key: followOnKey(
                                widget.domain,
                                'notes-check-${note.id}',
                              ),
                              value: _selected.contains(note.id),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selected.add(note.id);
                                  } else {
                                    _selected.remove(note.id);
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${note.serialLabel} · ${note.domain.shortLabel} · ${formatDayMonthYear(note.dateKey)}\n${note.body}',
                            ),
                          ),
                          TextButton(
                            key: followOnKey(
                              widget.domain,
                              'notes-edit-${note.id}',
                            ),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                showDragHandle: true,
                                isScrollControlled: true,
                                builder: (context) =>
                                    _EditNoteSheet(note: note),
                              );
                            },
                            child: const Text(Copy.editDeveloperNote),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: followOnKey(widget.domain, 'notes-download'),
              style: _compactFillStyle,
              onPressed: _download,
              child: const Text(Copy.downloadDeveloperNotes),
            ),
          ],
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: Theme.of(context).textTheme.bodySmall),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(Copy.closeActionRegister),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text(Copy.notesConfirmPermanentDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(Copy.closeActionRegister),
            ),
            FilledButton(
              key: followOnKey(widget.domain, 'notes-delete-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(Copy.notesConfirmPermanentDeleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final ids = [..._selected];
    await ref.read(devFeedbackProvider.notifier).deleteMany(ids);
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _message = null;
    });
  }

  Future<void> _download() async {
    final notes = registerDeveloperNotes(
      ref.read(devFeedbackProvider).value ?? const [],
    );
    if (notes.isEmpty) {
      setState(() => _message = Copy.noDeveloperNotes);
      return;
    }
    final text = formatDevFeedbackExport(notes);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() => _message = Copy.developerNotesCopied);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(Copy.downloadDeveloperNotes),
          content: SingleChildScrollView(child: SelectableText(text)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(Copy.closeActionRegister),
            ),
          ],
        );
      },
    );
  }
}

class _DatePriorityRow extends StatelessWidget {
  const _DatePriorityRow({
    required this.targetDateKey,
    required this.priority,
    required this.onPickDate,
    required this.onPriority,
  });

  final String targetDateKey;
  final ActionPriority priority;
  final VoidCallback onPickDate;
  final ValueChanged<ActionPriority> onPriority;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 8,
          child: OutlinedButton(
            onPressed: onPickDate,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              '${Copy.actionTargetDate}: ${formatDayMonthYear(targetDateKey)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 7,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: Copy.actionPriority,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(12, 8, 8, 8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ActionPriority>(
                value: priority,
                isExpanded: true,
                isDense: true,
                items: const [
                  DropdownMenuItem(
                    value: ActionPriority.soon,
                    child: Text(Copy.actionPrioritySoon),
                  ),
                  DropdownMenuItem(
                    value: ActionPriority.week,
                    child: Text(Copy.actionPriorityWeek),
                  ),
                  DropdownMenuItem(
                    value: ActionPriority.later,
                    child: Text(Copy.actionPriorityLater),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onPriority(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditActionSheet extends ConsumerStatefulWidget {
  const _EditActionSheet({required this.action});

  final DomainAction action;

  @override
  ConsumerState<_EditActionSheet> createState() => _EditActionSheetState();
}

class _EditActionSheetState extends ConsumerState<_EditActionSheet> {
  late final TextEditingController _title;
  late String _targetDateKey;
  late ActionPriority _priority;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.action.title);
    _targetDateKey = widget.action.targetDateKey;
    _priority = widget.action.priority;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(nowProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(Copy.actionEdit, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            key: followOnKey(widget.action.domain, 'action-title'),
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: Copy.actionField),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 8),
          _DatePriorityRow(
            targetDateKey: _targetDateKey,
            priority: _priority,
            onPickDate: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: parseDateKey(_targetDateKey),
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 2, now.month, now.day),
              );
              if (picked == null) return;
              setState(() => _targetDateKey = dateKey(picked));
            },
            onPriority: (value) => setState(() => _priority = value),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            key: followOnKey(widget.action.domain, 'action-save'),
            style: _compactFillStyle,
            onPressed: () async {
              if (validateActionTitle(_title.text) != null) {
                setState(() => _error = Copy.actionNeedsText);
                return;
              }
              await ref
                  .read(domainActionsProvider.notifier)
                  .save(
                    widget.action.copyWith(
                      title: normalizeActionTitle(_title.text),
                      targetDateKey: _targetDateKey,
                      priority: _priority,
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(Copy.saveEditedAction),
          ),
        ],
      ),
    );
  }
}

class _EditNoteSheet extends ConsumerStatefulWidget {
  const _EditNoteSheet({required this.note});

  final DevFeedback note;

  @override
  ConsumerState<_EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends ConsumerState<_EditNoteSheet> {
  late final TextEditingController _body;
  String? _error;

  @override
  void initState() {
    super.initState();
    _body = TextEditingController(text: widget.note.body);
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Copy.editDeveloperNote,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            key: followOnKey(widget.note.domain, 'note-edit-body'),
            controller: _body,
            autofocus: true,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: Copy.developerNotesPrompt,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            key: followOnKey(widget.note.domain, 'note-edit-save'),
            style: _compactFillStyle,
            onPressed: () async {
              if (validateFeedbackBody(_body.text) != null) {
                setState(() => _error = Copy.developerNoteNeedsText);
                return;
              }
              await ref
                  .read(devFeedbackProvider.notifier)
                  .save(
                    widget.note.copyWith(
                      body: normalizeFeedbackBody(_body.text),
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(Copy.saveEditedAction),
          ),
        ],
      ),
    );
  }
}
