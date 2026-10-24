import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/domain_action.dart';
import '../../domain/ids.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_response.dart';
import '../registry/registry_filter_note.dart';
import '../registry/registry_table.dart';
import '../shared/ui_bits.dart';
import 'note_source.dart';
import 'response_editor_screen.dart';

class ResponseListScreen extends ConsumerStatefulWidget {
  const ResponseListScreen({
    super.key,
    this.embedded = false,
    this.activeDomains,
    this.filterNote,
  });

  final bool embedded;
  final Set<MonitorDomain>? activeDomains;
  final String? filterNote;

  @override
  ConsumerState<ResponseListScreen> createState() => _ResponseListScreenState();
}

class _ResponseListScreenState extends ConsumerState<ResponseListScreen> {
  final _selected = <String>{};

  void _openEditor({PersonalResponse? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResponseEditorScreen(existing: existing),
      ),
    );
  }

  List<PersonalResponse> _selectedItems(List<PersonalResponse> items) {
    return [
      for (final item in items)
        if (_selected.contains(item.id)) item,
    ];
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteSelected(List<PersonalResponse> items) async {
    final chosen = _selectedItems(items);
    if (chosen.isEmpty) {
      _toast(Copy.noteNothingSelected);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(Copy.deleteResponse),
          content: const Text(Copy.noteConfirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(Copy.deleteResponse),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    await ref
        .read(responsesProvider.notifier)
        .deleteMany(chosen.map((item) => item.id));
    if (!mounted) return;
    setState(_selected.clear);
  }

  Future<void> _archiveSelected(List<PersonalResponse> items) async {
    final chosen = _selectedItems(items);
    if (chosen.isEmpty) {
      _toast(Copy.noteNothingSelected);
      return;
    }
    final notifier = ref.read(responsesProvider.notifier);
    for (final item in chosen) {
      if (item.isArchived) continue;
      await notifier.save(item.copyWith(archivedAt: DateTime.now()));
    }
    if (!mounted) return;
    setState(_selected.clear);
  }

  Future<void> _restoreSelected(List<PersonalResponse> items) async {
    final chosen = _selectedItems(items);
    if (chosen.isEmpty) {
      _toast(Copy.noteNothingSelected);
      return;
    }
    final notifier = ref.read(responsesProvider.notifier);
    for (final item in chosen) {
      if (!item.isArchived) continue;
      await notifier.save(item.copyWith(clearArchivedAt: true));
    }
    if (!mounted) return;
    setState(_selected.clear);
  }

  Future<void> _setActionReminder(List<PersonalResponse> items) async {
    final chosen = _selectedItems(items);
    if (chosen.isEmpty) {
      _toast(Copy.noteNothingSelected);
      return;
    }
    final now = ref.read(nowProvider);
    var domain = noteMonitorDomain(chosen.first) ?? MonitorDomain.salah;
    var target = dateKey(now);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return AlertDialog(
              title: const Text(Copy.noteActionReminder),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<MonitorDomain>(
                    key: const Key('note-reminder-domain'),
                    initialValue: domain,
                    decoration: const InputDecoration(
                      labelText: Copy.noteDomainColumn,
                    ),
                    items: [
                      for (final option in selectableMonitorDomains())
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
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('note-reminder-date'),
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
                    child: Text(target),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(Copy.noteActionReminder),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed != true) return;
    final actions = ref.read(domainActionsProvider).value ?? const [];
    final domainActions = actionsForDomain(actions, domain);
    if (!canAddActiveAction(domainActions)) {
      _toast(Copy.noteReminderLimit);
      return;
    }
    final actionNotifier = ref.read(domainActionsProvider.notifier);
    final noteNotifier = ref.read(responsesProvider.notifier);
    var working = [...domainActions];
    for (final item in chosen) {
      if (!canAddActiveAction(working)) {
        _toast(Copy.noteReminderLimit);
        break;
      }
      final action = DomainAction(
        id: newOpaqueId(),
        domain: domain,
        title: normalizeActionTitle(item.text),
        targetDateKey: target,
        priority: ActionPriority.week,
        status: ActionStatus.open,
        createdAt: now,
        sortOrder: nextActiveSortOrder(working),
        listedOnHome: true,
      );
      working = [...working, action];
      await actionNotifier.save(action);
      await noteNotifier.save(item.copyWith(reminderDateKey: target));
    }
    if (!mounted) return;
    setState(_selected.clear);
    _toast(Copy.noteReminderSaved);
  }

  bool _inScope(PersonalResponse item) {
    final domains = widget.activeDomains;
    if (domains == null) return true;
    final domain = noteMonitorDomain(item);
    if (domain == null) return true;
    return domains.contains(domain);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(responsesProvider);
    final body = async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const EmptyState(
        title: Copy.myResponse,
        message: 'Saved notes could not be listed. Existing records were left unchanged.',
      ),
      data: (stored) {
        final items = [
          for (final item in stored)
            if (_inScope(item)) item,
        ];
        if (items.isEmpty) {
          return RegistryPageBody(
            top: [
              _intro(),
              const SizedBox(height: 12),
              _actionBar(const [], archived: false),
            ],
            empty: Text(
              Copy.emptyResponses,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            bottom: widget.filterNote == null
                ? null
                : RegistryFilterNote(
                    key: const Key('registry-filter-note-notes'),
                    text: widget.filterNote!,
                  ),
          );
        }
        final active = items.where((item) => !item.isArchived).toList();
        final archived = items.where((item) => item.isArchived).toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _intro(),
              const SizedBox(height: 12),
              _actionBar(active, archived: false),
              const SizedBox(height: 12),
              Expanded(flex: archived.isEmpty ? 1 : 3, child: _table(active)),
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 12),
                const SectionHeader('Archived'),
                const SizedBox(height: 8),
                _actionBar(archived, archived: true),
                const SizedBox(height: 12),
                Expanded(flex: 2, child: _table(archived)),
              ],
              if (widget.filterNote != null)
                RegistryFilterNote(
                  key: const Key('registry-filter-note-notes'),
                  text: widget.filterNote!,
                ),
            ],
          ),
        );
      },
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.myResponse)),
      body: body,
    );
  }

  Color get _wash {
    return MuhasabahColors.wash(
      MuhasabahColors.salahWash,
      MuhasabahColors.salahWashDark,
      Theme.of(context).brightness,
      context,
    );
  }

  Widget _intro() {
    return Text(
      Copy.myResponseDescription,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
        fontSize: 13,
      ),
    );
  }

  Widget _actionBar(List<PersonalResponse> items, {required bool archived}) {
    return RegistryWashButtonRow(
      children: [
        if (!archived)
          RegistryWashButton(
            label: Copy.addAResponse,
            wash: _wash,
            onPressed: _openEditor,
          ),
        RegistryWashButton(
          label: Copy.deleteResponse,
          wash: _wash,
          onPressed: () => _deleteSelected(items),
        ),
        if (!archived)
          RegistryWashButton(
            label: Copy.archiveResponse,
            wash: _wash,
            onPressed: () => _archiveSelected(items),
          ),
        if (archived)
          RegistryWashButton(
            label: Copy.restoreResponse,
            wash: _wash,
            onPressed: () => _restoreSelected(items),
          ),
        RegistryWashButton(
          key: Key(
            archived ? 'note-action-reminder-archived' : 'note-action-reminder',
          ),
          label: Copy.noteActionReminder,
          wash: _wash,
          onPressed: () => _setActionReminder(items),
        ),
      ],
    );
  }

  static const _checkW = 36.0;
  static const _serialW = 90.0;
  static const _rowPad = EdgeInsets.fromLTRB(8, 8, 10, 8);

  Widget _table(List<PersonalResponse> rows) {
    if (rows.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Text(
          Copy.emptyResponses,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    final ids = {for (final row in rows) row.id};
    final allSelected = ids.every(_selected.contains);
    final theme = Theme.of(context);
    return RegistryStickyTable(
      wash: _wash,
      header: _headerRow(theme, allSelected, ids),
      itemCount: rows.length,
      itemBuilder: (context, index) => _dataRow(theme, rows[index]),
    );
  }

  Widget _selectBox({
    required Key key,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return SizedBox(
      width: _checkW,
      child: Align(
        alignment: Alignment.topCenter,
        child: Checkbox(
          key: key,
          value: value,
          tristate: value == null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _columns({
    required Widget check,
    required Widget serial,
    required Widget note,
    required Widget source,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Padding(
      padding: _rowPad,
      child: Row(
        crossAxisAlignment: align,
        children: [
          check,
          SizedBox(width: _serialW, child: serial),
          const SizedBox(width: 8),
          Expanded(flex: 11, child: note),
          const SizedBox(width: 10),
          Expanded(flex: 8, child: source),
        ],
      ),
    );
  }

  Widget _headerRow(ThemeData theme, bool allSelected, Set<String> ids) {
    final style = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      letterSpacing: 0.2,
      color: theme.colorScheme.onSurface,
    );
    return Material(
      color: _wash,
      child: _columns(
        align: CrossAxisAlignment.center,
        check: _selectBox(
          key: const Key('note-select-all'),
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
        serial: Text(Copy.noteCodeColumn, style: style),
        note: Text(Copy.noteContentColumn, style: style),
        source: Text(Copy.noteDomainSourceColumn, style: style),
      ),
    );
  }

  Widget _dataRow(ThemeData theme, PersonalResponse row) {
    final selected = _selected.contains(row.id);
    final source = noteSourceLabel(row);
    final linked = noteHasOpenableSource(row);
    final domain = noteDomainLabel(row);
    final serial = theme.textTheme.bodySmall?.copyWith(
      fontSize: 11,
      height: 1.25,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final body = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      height: 1.35,
    );
    final domainStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 11,
      height: 1.25,
      fontWeight: FontWeight.w600,
    );
    final sourceStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 10,
      height: 1.3,
      color: linked
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant,
      decoration: linked ? TextDecoration.underline : TextDecoration.none,
    );
    return Material(
      color: selected
          ? _wash.withValues(alpha: 0.45)
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: () => _openEditor(existing: row),
        child: _columns(
          check: _selectBox(
            key: Key('note-select-${row.id}'),
            value: selected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selected.add(row.id);
                } else {
                  _selected.remove(row.id);
                }
              });
            },
          ),
          serial: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      row.noteCode ?? formatNoteCode(row.createdAt, 1),
                      maxLines: 1,
                      style: serial,
                    ),
                  ),
                ),
                if (row.reminderDateKey != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(
                      Icons.alarm_outlined,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          note: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              row.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: body,
            ),
          ),
          source: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Tooltip(
              message: domain == kNoteGeneralDomain
                  ? Copy.noteGeneralDomainHint
                  : domain,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domain,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: domainStyle,
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: linked ? () => openNoteSource(context, row) : null,
                    child: Text(
                      source,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: sourceStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
