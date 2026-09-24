import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/custom_selection_set.dart';

class CustomSelectionSetsEditor extends ConsumerWidget {
  const CustomSelectionSetsEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final record = prefs.customSelectionSets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Copy.customSelectionSets,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          Copy.customSelectionSetsNote,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        for (final slot in record.slots)
          _CustomSlotTile(
            slot: slot,
            status: customSlotStatus(
              slot: slot,
              activeSlotId: record.activeSlotId,
              workingDomains: prefs.visibleDomains,
              workingMix: prefs.personalMix,
            ),
          ),
      ],
    );
  }
}

class _CustomSlotTile extends ConsumerWidget {
  const _CustomSlotTile({required this.slot, required this.status});

  final CustomSelectionSet slot;
  final CustomSlotStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusLabel = switch (status) {
      CustomSlotStatus.active => Copy.customSlotActive,
      CustomSlotStatus.modified => Copy.customSlotModified,
      CustomSlotStatus.saved => Copy.customSlotSaved,
    };
    return Card(
      key: Key('custom-slot-${slot.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    slot.displayTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  statusLabel,
                  key: Key('custom-slot-status-${slot.id}'),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  key: Key('custom-slot-clear-${slot.id}'),
                  onPressed: () =>
                      confirmClearCustomSlot(context, ref, slot.id),
                  child: const Text(Copy.clearAllSelections),
                ),
                TextButton(
                  key: Key('custom-slot-activate-${slot.id}'),
                  onPressed: () => _activate(context, ref),
                  child: const Text(Copy.customSlotActivate),
                ),
                TextButton(
                  key: Key('custom-slot-save-${slot.id}'),
                  onPressed: () async {
                    await ref
                        .read(appPrefsProvider)
                        .saveWorkingToCustomSlot(slot.id);
                    if (!context.mounted) return;
                    ref.read(prefsTickProvider.notifier).state++;
                  },
                  child: const Text(Copy.customSlotSave),
                ),
                TextButton(
                  key: Key('custom-slot-rename-${slot.id}'),
                  onPressed: () => _rename(context, ref),
                  child: const Text(Copy.customSlotRename),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activate(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(appPrefsProvider);
    final needsConfirm = workingModifiedFromActive(
      record: prefs.customSelectionSets,
      workingDomains: prefs.visibleDomains,
      workingMix: prefs.personalMix,
    );
    if (needsConfirm) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            key: const Key('activate-custom-slot-dialog'),
            title: const Text(Copy.activateModifiedTitle),
            content: const Text(Copy.activateModifiedBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(Copy.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(Copy.activateModifiedAction),
              ),
            ],
          );
        },
      );
      if (ok != true) return;
    }
    await prefs.activateCustomSlot(slot.id);
    if (!context.mounted) return;
    ref.read(prefsTickProvider.notifier).state++;
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final next = await showDialog<String>(
      context: context,
      builder: (context) => _RenameCustomSlotDialog(initial: slot.name),
    );
    if (next == null) return;
    await ref.read(appPrefsProvider).renameCustomSlot(slot.id, next);
    if (!context.mounted) return;
    ref.read(prefsTickProvider.notifier).state++;
  }
}

class _RenameCustomSlotDialog extends StatefulWidget {
  const _RenameCustomSlotDialog({required this.initial});

  final String initial;

  @override
  State<_RenameCustomSlotDialog> createState() =>
      _RenameCustomSlotDialogState();
}

class _RenameCustomSlotDialogState extends State<_RenameCustomSlotDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('rename-custom-slot-dialog'),
      title: const Text(Copy.customSlotRenameTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: kCustomSelectionSetNameMaxLength,
        decoration: const InputDecoration(hintText: Copy.customSlotRenameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(Copy.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text(Copy.customSlotRename),
        ),
      ],
    );
  }
}

Future<void> confirmClearWorkingSelection(
  BuildContext context,
  WidgetRef ref,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        key: const Key('clear-working-selection-dialog'),
        title: const Text(Copy.clearAllSelectionsTitle),
        content: const Text(Copy.clearAllSelectionsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(Copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(Copy.clearAllSelectionsAction),
          ),
        ],
      );
    },
  );
  if (ok != true) return;
  await ref.read(appPrefsProvider).clearWorkingSelection();
  if (!context.mounted) return;
  ref.read(prefsTickProvider.notifier).state++;
}

Future<void> confirmClearCustomSlot(
  BuildContext context,
  WidgetRef ref,
  int slotId,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        key: Key('clear-custom-slot-dialog-$slotId'),
        title: const Text(Copy.clearCustomSlotTitle),
        content: const Text(Copy.clearCustomSlotBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(Copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(Copy.clearAllSelectionsAction),
          ),
        ],
      );
    },
  );
  if (ok != true) return;
  await ref.read(appPrefsProvider).clearCustomSlot(slotId);
  if (!context.mounted) return;
  ref.read(prefsTickProvider.notifier).state++;
}
