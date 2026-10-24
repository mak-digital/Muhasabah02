import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/domain_action.dart';
import '../../domain/ids.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/practice_hadith.dart';
import '../../domain/practice_hadith_catalog.dart';
import '../../domain/registry_scope.dart';
import '../home/bring_hadith_sheet.dart';
import '../home/practice_hadith_home.dart';
import '../shared/domain_visual.dart';
import '../shared/ui_bits.dart';
import 'registry_filter_note.dart';
import 'registry_table.dart';

class HadithRegisterPage extends ConsumerStatefulWidget {
  const HadithRegisterPage({
    super.key,
    required this.scope,
    required this.note,
  });

  final RegistryScope scope;
  final String note;

  @override
  ConsumerState<HadithRegisterPage> createState() => _HadithRegisterPageState();
}

class _HadithRegisterPageState extends ConsumerState<HadithRegisterPage> {
  final _selected = <String>{};

  Color get _wash {
    return domainColorIdentity(MonitorDomain.hadith)
        .practiceWashFor(Theme.of(context).brightness, context);
  }

  List<PracticeHadithRecord> _allShown() {
    if (!widget.scope.includes(MonitorDomain.hadith)) {
      return const [];
    }
    return orderedPracticeHadithRegister(
      practiceRecordsForDomain(
        ref.watch(practiceHadithProvider).value ?? const [],
        MonitorDomain.hadith,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.scope.includes(MonitorDomain.hadith);
    final records = _allShown();
    final active = [
      for (final record in records)
        if (!record.isArchived) record,
    ];
    final archived = [
      for (final record in records)
        if (record.isArchived) record,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Copy.practiceHadithRegisterTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            shown ? Copy.practiceHadithRegisterNote : Copy.registryHadithHidden,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (shown) ...[
            const SizedBox(height: 12),
            RegistryWashButtonRow(
              children: [
                RegistryWashButton(
                  key: const Key('registry-hadith-add'),
                  label: Copy.addPracticeHadith,
                  wash: _wash,
                  onPressed: () => showBringHadithSheet(context),
                ),
                RegistryWashButton(
                  key: const Key('registry-hadith-delete'),
                  label: Copy.actionDeleteSelected,
                  wash: _wash,
                  onPressed: _selected.isEmpty ? null : _deleteSelected,
                ),
                RegistryWashButton(
                  key: const Key('registry-hadith-archive'),
                  label: Copy.archiveResponse,
                  wash: _wash,
                  onPressed: _selected.isEmpty ? null : _archiveSelected,
                ),
                RegistryWashButton(
                  key: const Key('registry-hadith-reminder'),
                  label: Copy.noteActionReminder,
                  wash: _wash,
                  onPressed: _selected.isEmpty ? null : _setActionReminder,
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: !shown
                ? Text(
                    Copy.registryHadithHidden,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : records.isEmpty
                ? Text(
                    Copy.practiceHadithRegisterEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Column(
                    children: [
                      if (active.isNotEmpty)
                        Expanded(
                          flex: archived.isEmpty ? 1 : 3,
                          child: _table(active, archivedKey: false),
                        ),
                      if (archived.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const SectionHeader('Archived'),
                        const SizedBox(height: 8),
                        RegistryWashButtonRow(
                          children: [
                            RegistryWashButton(
                              key: const Key('registry-hadith-restore'),
                              label: Copy.restoreResponse,
                              wash: _wash,
                              onPressed: _selected.isEmpty
                                  ? null
                                  : _restoreSelected,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: active.isEmpty ? 1 : 2,
                          child: _table(archived, archivedKey: true),
                        ),
                      ],
                    ],
                  ),
          ),
          RegistryFilterNote(
            key: const Key('registry-filter-note-hadith'),
            text: widget.note,
          ),
        ],
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

  Widget _table(List<PracticeHadithRecord> rows, {required bool archivedKey}) {
    final ids = {for (final record in rows) record.id};
    final allSelected = rows.isNotEmpty && ids.every(_selected.contains);
    return RegistryStickyTable(
      wash: _wash,
      header: _header(allSelected, ids, archivedKey: archivedKey),
      itemCount: rows.length,
      itemBuilder: (context, index) => _row(rows[index]),
    );
  }

  Widget _header(
    bool allSelected,
    Set<String> ids, {
    required bool archivedKey,
  }) {
    return Material(
      color: _wash,
      child: _columns(
        align: CrossAxisAlignment.center,
        check: RegistrySelectBox(
          key: Key(
            archivedKey
                ? 'registry-hadith-select-all-archived'
                : 'registry-hadith-select-all',
          ),
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
        topic: Text(Copy.hadithTopicColumn, style: _headerStyle),
        source: Text(Copy.hadithSourceColumn, style: _headerStyle),
        status: Text(Copy.hadithStatusColumn, style: _headerStyle),
        shared: Text(Copy.hadithSharedColumn, style: _headerStyle),
      ),
    );
  }

  Widget _row(PracticeHadithRecord record) {
    final theme = Theme.of(context);
    final selected = _selected.contains(record.id);
    final core = practiceHadithCore(record);
    return Material(
      color: selected
          ? _wash.withValues(alpha: 0.45)
          : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RegistrySelectBox(
              key: Key('registry-hadith-check-${record.id}'),
              value: selected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selected.add(record.id);
                  } else {
                    _selected.remove(record.id);
                  }
                });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _columns(
                    align: CrossAxisAlignment.center,
                    check: const SizedBox.shrink(),
                    includeCheck: false,
                    topic: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.topic,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatDayMonthYear(record.addedDateKey),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    source: PracticeCitationLink(
                      domain: MonitorDomain.hadith,
                      text: record.content,
                      source: record.source,
                      sourceDetail: '',
                    ),
                    status: PracticeRegisterStatusSelect(
                      dropdownKey: Key('registry-hadith-status-${record.id}'),
                      domain: MonitorDomain.hadith,
                      value: record.status,
                      compact: true,
                      fillWash: _wash,
                      onChanged: (status) async {
                        await ref
                            .read(practiceHadithProvider.notifier)
                            .save(record.copyWith(status: status));
                      },
                    ),
                    shared: Text(
                      _sharedHistory(record),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        height: 1.3,
                        color: record.sharedDateKeys.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PracticeRemembranceCore(
                    contextText: core.text,
                    arabic: core.arabic,
                    transliteration: core.transliteration,
                    translation: core.translation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _columns({
    required Widget check,
    required Widget topic,
    required Widget source,
    required Widget status,
    required Widget shared,
    CrossAxisAlignment align = CrossAxisAlignment.start,
    bool includeCheck = true,
  }) {
    return Padding(
      padding: includeCheck
          ? const EdgeInsets.fromLTRB(6, 8, 8, 8)
          : EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: align,
        children: [
          if (includeCheck) check,
          Expanded(flex: 9, child: topic),
          const SizedBox(width: 6),
          Expanded(flex: 8, child: source),
          const SizedBox(width: 6),
          Expanded(flex: 8, child: status),
          const SizedBox(width: 6),
          Expanded(flex: 7, child: shared),
        ],
      ),
    );
  }

  String _sharedHistory(PracticeHadithRecord record) {
    final keys = record.sharedDateKeys;
    if (keys.isEmpty) return '—';
    final last = formatDayMonthYear(keys.last);
    if (keys.length == 1) return last;
    return '$last · ${keys.length}';
  }

  List<PracticeHadithRecord> _chosen() {
    return [
      for (final record in _allShown())
        if (_selected.contains(record.id)) record,
    ];
  }

  Future<void> _setCatalogArchive(
    Iterable<String> catalogIds, {
    required bool archived,
  }) async {
    final prefs = ref.read(appPrefsProvider);
    final next = {...prefs.archivedPracticeHadithCatalogIds};
    if (archived) {
      next.addAll(catalogIds.where((id) => id.isNotEmpty));
    } else {
      next.removeAll(catalogIds);
    }
    await prefs.setArchivedPracticeHadithCatalogIds(next);
    ref.read(prefsTickProvider.notifier).state++;
  }

  Future<void> _archiveSelected() async {
    final chosen = _chosen();
    if (chosen.isEmpty) return;
    final notifier = ref.read(practiceHadithProvider.notifier);
    for (final record in chosen) {
      if (record.isArchived) continue;
      await notifier.save(record.copyWith(archivedAt: DateTime.now()));
    }
    await _setCatalogArchive(
      chosen.map((record) => record.catalogId),
      archived: true,
    );
    if (!mounted) return;
    setState(_selected.clear);
  }

  Future<void> _restoreSelected() async {
    final chosen = _chosen();
    if (chosen.isEmpty) return;
    final notifier = ref.read(practiceHadithProvider.notifier);
    for (final record in chosen) {
      if (!record.isArchived) continue;
      await notifier.save(record.copyWith(clearArchivedAt: true));
    }
    await _setCatalogArchive(
      chosen.map((record) => record.catalogId),
      archived: false,
    );
    if (!mounted) return;
    setState(_selected.clear);
  }

  Future<void> _setActionReminder() async {
    final chosen = _chosen();
    if (chosen.isEmpty) return;
    final now = ref.read(nowProvider);
    final actions = ref.read(domainActionsProvider).value ?? const [];
    var working = actionsForDomain(actions, MonitorDomain.hadith);
    if (!canAddActiveAction(working)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(Copy.noteReminderLimit)));
      return;
    }
    final actionNotifier = ref.read(domainActionsProvider.notifier);
    for (final record in chosen) {
      if (!canAddActiveAction(working)) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(Copy.noteReminderLimit)));
        break;
      }
      final action = DomainAction(
        id: newOpaqueId(),
        domain: MonitorDomain.hadith,
        title: normalizeActionTitle(record.topic),
        targetDateKey: dateKey(now),
        priority: ActionPriority.week,
        status: ActionStatus.open,
        createdAt: now,
        sortOrder: nextActiveSortOrder(working),
        listedOnHome: true,
      );
      working = [...working, action];
      await actionNotifier.save(action);
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
          content: const Text(Copy.practiceHadithConfirmDelete),
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
    await ref.read(practiceHadithProvider.notifier).deleteMany([..._selected]);
    if (!mounted) return;
    setState(_selected.clear);
  }
}
