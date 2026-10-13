import 'package:flutter/material.dart';

import '../../domain/factor_groups.dart';
import '../../domain/time_practices.dart';
import 'activity_picker.dart';

class TimePracticeFields extends StatelessWidget {
  const TimePracticeFields({
    super.key,
    required this.practice,
    required this.contextId,
    required this.outcomeId,
    required this.note,
    required this.onContextChanged,
    required this.onOutcomeChanged,
    required this.onNoteChanged,
    this.noteController,
  });

  final TimePractice practice;
  final String contextId;
  final String outcomeId;
  final String note;
  final ValueChanged<String> onContextChanged;
  final ValueChanged<String> onOutcomeChanged;
  final ValueChanged<String> onNoteChanged;
  final TextEditingController? noteController;

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
            'Optional. Stored as you report it. Not a score or a judgment.',
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
          child: Text('WHAT WAS INVOLVED?', style: labelStyle),
        ),
        CheckInSelect<String>(
          depth: CheckInFieldDepth.nested,
          dropdownKey: Key('time-${practice.storageKey}-context'),
          value: _safe(contextId, practice.contexts),
          sortLabels: false,
          entries: [
            const CheckInSelectEntry(
              value: kFactorNotRecorded,
              label: 'Not recorded',
            ),
            for (final choice in practice.contexts)
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
          child: Text('WHAT HAPPENED AFTERWARDS?', style: labelStyle),
        ),
        CheckInSelect<String>(
          depth: CheckInFieldDepth.nested,
          dropdownKey: Key('time-${practice.storageKey}-outcome'),
          value: _safe(outcomeId, practice.outcomes),
          sortLabels: false,
          entries: [
            const CheckInSelectEntry(
              value: kFactorNotRecorded,
              label: 'Not recorded',
            ),
            for (final choice in practice.outcomes)
              CheckInSelectEntry(value: choice.id, label: choice.label),
          ],
          onChanged: onOutcomeChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: checkInNestedIndent,
            top: 8,
            bottom: 6,
          ),
          child: Text('PRIVATE REFLECTION (OPTIONAL)', style: labelStyle),
        ),
        Padding(
          padding: const EdgeInsets.only(left: checkInNestedIndent),
          child: noteController == null
              ? TextFormField(
                  key: Key('time-${practice.storageKey}-note'),
                  initialValue: note,
                  decoration: const InputDecoration(
                    hintText: 'Private reflection (optional)',
                  ),
                  minLines: 1,
                  maxLines: 4,
                  onChanged: onNoteChanged,
                )
              : TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    hintText: 'Private reflection (optional)',
                  ),
                  minLines: 1,
                  maxLines: 4,
                  onChanged: onNoteChanged,
                ),
        ),
      ],
    );
  }

  String _safe(String id, List<TimeChoice> choices) {
    if (id == kFactorNotRecorded) return id;
    if (choices.any((choice) => choice.id == id)) return id;
    return kFactorNotRecorded;
  }
}
