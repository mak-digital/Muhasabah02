import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/domain_action.dart';
import '../../domain/ids.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/registry_scope.dart';
import 'registry_filter_note.dart';
import 'registry_table.dart';

class ActionRegisterPage extends ConsumerStatefulWidget {
  const ActionRegisterPage({
    super.key,
    required this.scope,
    required this.note,
  });

  final RegistryScope scope;
  final String note;

  @override
  ConsumerState<ActionRegisterPage> createState() => _ActionRegisterPageState();
}

class _ActionRegisterPageState extends ConsumerState<ActionRegisterPage> {
  final _selected = <String>{};

  Color get _wash {
    return MuhasabahColors.wash(
      MuhasabahColors.salahWash,
      MuhasabahColors.salahWashDark,
      Theme.of(context).brightness,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = registerActions([
      for (final action in ref.watch(domainActionsProvider).value ?? const [])
        if (widget.scope.includes(action.domain)) action,
    ]);
    final ids = {for (final action in rows) action.id};
    final allSelected = rows.isNotEmpty && ids.every(_selected.contains);
    return RegistryPageBody(
      top: [
        Text(
          Copy.registryTabActions,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          Copy.actionRegisterNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        RegistryWashButtonRow(
          children: [
            RegistryWashButton(
              key: const Key('registry-action-add'),
              label: Copy.addAction,
              wash: _wash,
              onPressed: _addAction,
            ),
            RegistryWashButton(
              key: const Key('registry-action-delete'),
              label: Copy.actionDeleteSelected,
              wash: _wash,
              onPressed: _selected.isEmpty ? null : _deleteSelected,
            ),
            RegistryWashButton(
              key: const Key('registry-action-reminder'),
              label: Copy.addReminder,
              wash: _wash,
              onPressed: _selected.isEmpty ? null : _addReminder,
            ),
          ],
        ),
      ],
      table: rows.isEmpty
          ? null
          : RegistryStickyTable(
              wash: _wash,
              header: _header(allSelected, ids),
              itemCount: rows.length,
              itemBuilder: (context, index) => _row(rows[index]),
            ),
      empty: rows.isEmpty ? const Text(Copy.actionRegisterEmpty) : null,
      bottom: RegistryFilterNote(
        key: const Key('registry-filter-note-actions'),
        text: widget.note,
      ),
    );
  }

  TextStyle? get _headerStyle {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      letterSpacing: 0.2,
    );
  }

  Widget _header(bool allSelected, Set<String> ids) {
    return Material(
      color: _wash,
      child: _columns(
        align: CrossAxisAlignment.center,
        check: RegistrySelectBox(
          key: const Key('registry-action-select-all'),
          value: allSelected
              ? true
              : _selected.intersection(ids).isEmpty
              ? false
              : null,
          onChanged: (_) {
            setState(() {
              if (allSelected) {
                _selected.removeAll(ids);
              } else {
                _selected.addAll(ids);
              }
            });
          },
        ),
        action: Text(Copy.actionField, style: _headerStyle),
        domain: Text(Copy.actionDomainDateColumn, style: _headerStyle),
        status: Text(Copy.actionStatusShort, style: _headerStyle),
      ),
    );
  }

  Widget _row(DomainAction action) {
    final theme = Theme.of(context);
    final selected = _selected.contains(action.id);
    return Material(
      color: selected
          ? _wash.withValues(alpha: 0.45)
          : theme.colorScheme.surface,
      child: _columns(
        check: RegistrySelectBox(
          key: Key('registry-action-check-${action.id}'),
          value: selected,
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
        action: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            action.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        domain: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action.domain.shortLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDayMonthYear(action.targetDateKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  height: 1.3,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        status: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _statusLabel(action.status),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _priorityLabel(action.priority),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _columns({
    required Widget check,
    required Widget action,
    required Widget domain,
    required Widget status,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
      child: Row(
        crossAxisAlignment: align,
        children: [
          check,
          Expanded(flex: 11, child: action),
          const SizedBox(width: 8),
          Expanded(flex: 8, child: domain),
          const SizedBox(width: 8),
          Expanded(flex: 7, child: status),
        ],
      ),
    );
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

  Future<void> _addAction() async {
    final now = ref.read(nowProvider);
    final domains = [
      for (final domain in selectableMonitorDomains())
        if (widget.scope.includes(domain)) domain,
    ];
    if (domains.isEmpty) return;
    var domain = domains.first;
    var target = dateKey(now);
    final title = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return AlertDialog(
              title: const Text(Copy.addAction),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<MonitorDomain>(
                    key: const Key('registry-action-domain'),
                    initialValue: domain,
                    decoration: const InputDecoration(
                      labelText: Copy.noteDomainColumn,
                    ),
                    items: [
                      for (final option in domains)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.shortLabel),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialog(() => domain = value);
                    },
                  ),
                  TextField(
                    key: const Key('registry-action-title'),
                    controller: title,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: Copy.actionField,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: parseDateKey(target),
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 2, now.month, now.day),
                      );
                      if (picked == null) return;
                      setDialog(() => target = dateKey(picked));
                    },
                    child: Text('${Copy.actionTargetDate}: $target'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(Copy.closeActionRegister),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(Copy.saveListedAction),
                ),
              ],
            );
          },
        );
      },
    );
    final text = normalizeActionTitle(title.text);
    title.dispose();
    if (saved != true || !mounted) return;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(Copy.actionNeedsText)));
      return;
    }
    final existing = actionsForDomain(
      ref.read(domainActionsProvider).value ?? const [],
      domain,
    );
    if (!canAddActiveAction(existing)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(Copy.actionLimitReached)));
      return;
    }
    await ref
        .read(domainActionsProvider.notifier)
        .save(
          DomainAction(
            id: newOpaqueId(),
            domain: domain,
            title: text,
            targetDateKey: target,
            priority: ActionPriority.week,
            status: ActionStatus.open,
            createdAt: now,
            sortOrder: nextActiveSortOrder(existing),
            listedOnHome: true,
          ),
        );
  }

  Future<void> _addReminder() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Copy.actionNothingSelected)));
      return;
    }
    final now = ref.read(nowProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );
    if (picked == null || !mounted) return;
    final key = dateKey(picked);
    final notifier = ref.read(domainActionsProvider.notifier);
    final rows = ref.read(domainActionsProvider).value ?? const [];
    for (final action in rows) {
      if (!_selected.contains(action.id)) continue;
      await notifier.save(
        action.copyWith(targetDateKey: key, listedOnHome: true),
      );
    }
    if (!mounted) return;
    setState(_selected.clear);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text(Copy.noteReminderSaved)));
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
              onPressed: () => Navigator.pop(context, true),
              child: const Text(Copy.actionConfirmPermanentDeleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await ref.read(domainActionsProvider.notifier).deleteMany([..._selected]);
    if (!mounted) return;
    setState(_selected.clear);
  }
}
