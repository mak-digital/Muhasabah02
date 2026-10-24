import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/dev_feedback.dart';
import '../../domain/domain_action.dart';
import '../../domain/ids.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/registry_scope.dart';
import '../shared/domain_visual.dart';
import 'registry_filter_note.dart';
import 'registry_table.dart';

class DeveloperNotesRegisterPage extends ConsumerStatefulWidget {
  const DeveloperNotesRegisterPage({
    super.key,
    required this.scope,
    required this.note,
  });

  final RegistryScope scope;
  final String note;

  @override
  ConsumerState<DeveloperNotesRegisterPage> createState() =>
      _DeveloperNotesRegisterPageState();
}

class _DeveloperNotesRegisterPageState
    extends ConsumerState<DeveloperNotesRegisterPage> {
  final _selected = <String>{};
  String? _message;

  Color get _wash {
    return domainColorIdentity(MonitorDomain.salah)
        .notesWashFor(Theme.of(context).brightness, context);
  }

  @override
  Widget build(BuildContext context) {
    final notes = registerDeveloperNotes([
      for (final note in ref.watch(devFeedbackProvider).value ?? const [])
        if (widget.scope.includes(note.domain)) note,
    ]);
    final ids = {for (final note in notes) note.id};
    final allSelected = notes.isNotEmpty && ids.every(_selected.contains);
    return RegistryPageBody(
      top: [
        Text(
          Copy.notesRegisterTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          Copy.notesRegisterNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        RegistryWashButtonRow(
          children: [
            RegistryWashButton(
              key: const Key('registry-dev-add'),
              label: Copy.addDeveloperNote,
              wash: _wash,
              onPressed: _addNote,
            ),
            RegistryWashButton(
              key: const Key('registry-dev-delete'),
              label: Copy.actionDeleteSelected,
              wash: _wash,
              onPressed: _selected.isEmpty ? null : _deleteSelected,
            ),
            RegistryWashButton(
              key: const Key('registry-dev-download'),
              label: Copy.downloadDeveloperNotes,
              wash: _wash,
              onPressed: notes.isEmpty ? null : () => _download(notes),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(_message!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
      table: notes.isEmpty
          ? null
          : RegistryStickyTable(
              wash: _wash,
              header: _header(allSelected, ids),
              itemCount: notes.length,
              itemBuilder: (context, index) => _row(notes[index]),
            ),
      empty: notes.isEmpty ? const Text(Copy.notesRegisterEmpty) : null,
      bottom: RegistryFilterNote(
        key: const Key('registry-filter-note-developer'),
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
          key: const Key('registry-dev-select-all'),
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
        serial: Text(Copy.noteCodeColumn, style: _headerStyle),
        note: Text(Copy.noteContentColumn, style: _headerStyle),
        source: Text(Copy.developerDomainDateColumn, style: _headerStyle),
      ),
    );
  }

  Widget _row(DevFeedback note) {
    final theme = Theme.of(context);
    final selected = _selected.contains(note.id);
    return Material(
      color: selected
          ? _wash.withValues(alpha: 0.45)
          : theme.colorScheme.surface,
      child: _columns(
        check: RegistrySelectBox(
          key: Key('registry-dev-check-${note.id}'),
          value: selected,
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
        serial: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              note.serialLabel,
              maxLines: 1,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                height: 1.25,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        note: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            note.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
        source: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.domain.shortLabel,
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
                formatDayMonthYear(note.dateKey),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
      child: Row(
        crossAxisAlignment: align,
        children: [
          check,
          SizedBox(width: 90, child: serial),
          const SizedBox(width: 8),
          Expanded(flex: 11, child: note),
          const SizedBox(width: 10),
          Expanded(flex: 8, child: source),
        ],
      ),
    );
  }

  Future<void> _addNote() async {
    final domains = [
      for (final domain in selectableMonitorDomains())
        if (widget.scope.includes(domain)) domain,
    ];
    if (domains.isEmpty) return;
    var domain = domains.first;
    final body = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return AlertDialog(
              title: const Text(Copy.addDeveloperNote),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<MonitorDomain>(
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
                    key: const Key('registry-dev-body'),
                    controller: body,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: Copy.developerNotesPrompt,
                    ),
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
                  child: const Text(Copy.saveDeveloperNote),
                ),
              ],
            );
          },
        );
      },
    );
    final text = body.text;
    body.dispose();
    if (saved != true || !mounted) return;
    if (validateFeedbackBody(text) != null) {
      setState(() => _message = Copy.developerNoteNeedsText);
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
            domain: domain,
            dateKey: dateKey(now),
            body: normalizeFeedbackBody(text),
            createdAt: now,
          ),
        );
    if (!mounted) return;
    setState(() {
      _message = Copy.developerNoteSaved(
        formatFeedbackSerial(serial),
        domain.shortLabel,
        formatDayMonthYear(dateKey(now)),
      );
    });
  }

  Future<void> _deleteSelected() async {
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
              onPressed: () => Navigator.pop(context, true),
              child: const Text(Copy.notesConfirmPermanentDeleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await ref.read(devFeedbackProvider.notifier).deleteMany([..._selected]);
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _message = null;
    });
  }

  Future<void> _download(List<DevFeedback> notes) async {
    if (notes.isEmpty) {
      setState(() => _message = Copy.noDeveloperNotes);
      return;
    }
    final text = formatDevFeedbackExport(notes);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() => _message = Copy.developerNotesCopied);
  }
}
