import 'package:flutter/material.dart';

import '../../domain/akhlaq_practices.dart';
import '../../domain/copy.dart';
import '../../domain/factor_groups.dart';
import 'activity_picker.dart';

class AkhlaqFollowUpFields extends StatelessWidget {
  const AkhlaqFollowUpFields({
    super.key,
    required this.storageKey,
    required this.contextId,
    required this.helpId,
    required this.note,
    required this.onContextChanged,
    required this.onHelpChanged,
    required this.onNoteChanged,
    this.noteController,
  });

  final String storageKey;
  final String contextId;
  final String helpId;
  final String note;
  final ValueChanged<String> onContextChanged;
  final ValueChanged<String> onHelpChanged;
  final ValueChanged<String> onNoteChanged;
  final TextEditingController? noteController;

  String _safe(String id, List<AkhlaqChoice> choices) {
    if (id == kFactorNotRecorded) return id;
    if (choices.any((choice) => choice.id == id)) return id;
    return kFactorNotRecorded;
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 0.4,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: checkInValueIndent, top: 8),
          child: Text(
            Copy.akhlaqFollowUpNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: checkInNestedIndent,
            top: 8,
            bottom: 6,
          ),
          child: Text(Copy.akhlaqWhereDidItHappen.toUpperCase(), style: labelStyle),
        ),
        CheckInSelect<String>(
          depth: CheckInFieldDepth.nested,
          dropdownKey: Key('trace-$storageKey-context'),
          value: _safe(contextId, akhlaqContexts),
          sortLabels: false,
          entries: [
            const CheckInSelectEntry(
              value: kFactorNotRecorded,
              label: 'Not recorded',
            ),
            for (final choice in akhlaqContexts)
              CheckInSelectEntry(value: choice.id, label: choice.label),
          ],
          onChanged: onContextChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: checkInNestedIndent,
            top: 8,
            bottom: 6,
          ),
          child: Text(Copy.akhlaqWhatHelped.toUpperCase(), style: labelStyle),
        ),
        CheckInSelect<String>(
          depth: CheckInFieldDepth.nested,
          dropdownKey: Key('trace-$storageKey-helped'),
          value: _safe(helpId, akhlaqHelps),
          sortLabels: false,
          entries: [
            const CheckInSelectEntry(
              value: kFactorNotRecorded,
              label: 'Not recorded',
            ),
            for (final choice in akhlaqHelps)
              CheckInSelectEntry(value: choice.id, label: choice.label),
          ],
          onChanged: onHelpChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: checkInNestedIndent,
            top: 8,
            bottom: 6,
          ),
          child: Text(Copy.akhlaqPrivateStruggleNote.toUpperCase(), style: labelStyle),
        ),
        Padding(
          padding: const EdgeInsets.only(left: checkInNestedIndent),
          child: noteController == null
              ? TextFormField(
                  key: Key('trace-$storageKey-struggle'),
                  initialValue: note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: Copy.akhlaqStruggleFieldHint,
                  ),
                  onChanged: onNoteChanged,
                )
              : TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: Copy.akhlaqStruggleFieldHint,
                  ),
                  onChanged: onNoteChanged,
                ),
        ),
      ],
    );
  }
}
