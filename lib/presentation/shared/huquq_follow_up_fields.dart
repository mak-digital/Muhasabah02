import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../../domain/factor_groups.dart';
import '../../domain/huquq_practices.dart';
import 'activity_picker.dart';

class HuquqFollowUpFields extends StatelessWidget {
  const HuquqFollowUpFields({
    super.key,
    required this.storageKey,
    required this.engagementId,
    required this.outcomeId,
    required this.occasions,
    required this.timeSpent,
    required this.note,
    required this.onEngagementChanged,
    required this.onOutcomeChanged,
    required this.onOccasionsChanged,
    required this.onTimeSpentChanged,
    required this.onNoteChanged,
    this.occasionsController,
    this.timeSpentController,
    this.noteController,
  });

  final String storageKey;
  final String engagementId;
  final String outcomeId;
  final String occasions;
  final String timeSpent;
  final String note;
  final ValueChanged<String> onEngagementChanged;
  final ValueChanged<String> onOutcomeChanged;
  final ValueChanged<String> onOccasionsChanged;
  final ValueChanged<String> onTimeSpentChanged;
  final ValueChanged<String> onNoteChanged;
  final TextEditingController? occasionsController;
  final TextEditingController? timeSpentController;
  final TextEditingController? noteController;

  String _safe(String id, List<HuquqChoice> choices) {
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
            Copy.huquqFollowUpNote,
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
          child: Text(
            Copy.huquqNatureOfEngagement.toUpperCase(),
            style: labelStyle,
          ),
        ),
        CheckInSelect<String>(
          depth: CheckInFieldDepth.nested,
          dropdownKey: Key('trace-$storageKey-engagement'),
          value: _safe(engagementId, huquqEngagements),
          sortLabels: false,
          entries: [
            const CheckInSelectEntry(
              value: kFactorNotRecorded,
              label: 'Not recorded',
            ),
            for (final choice in huquqEngagements)
              CheckInSelectEntry(value: choice.id, label: choice.label),
          ],
          onChanged: onEngagementChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: checkInNestedIndent,
            top: 8,
            bottom: 6,
          ),
          child: Text(
            Copy.huquqOutcomeObserved.toUpperCase(),
            style: labelStyle,
          ),
        ),
        CheckInSelect<String>(
          depth: CheckInFieldDepth.nested,
          dropdownKey: Key('trace-$storageKey-outcome'),
          value: _safe(outcomeId, huquqOutcomes),
          sortLabels: false,
          entries: [
            const CheckInSelectEntry(
              value: kFactorNotRecorded,
              label: 'Not recorded',
            ),
            for (final choice in huquqOutcomes)
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
          child: Text(
            Copy.huquqOptionalQuantity.toUpperCase(),
            style: labelStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: checkInNestedIndent),
          child: occasionsController == null
              ? TextFormField(
                  key: Key('trace-$storageKey-occasions'),
                  initialValue: occasions,
                  decoration: const InputDecoration(
                    hintText: Copy.huquqOccasionsHint,
                  ),
                  onChanged: onOccasionsChanged,
                )
              : TextField(
                  controller: occasionsController,
                  decoration: const InputDecoration(
                    hintText: Copy.huquqOccasionsHint,
                  ),
                  onChanged: onOccasionsChanged,
                ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: checkInNestedIndent),
          child: timeSpentController == null
              ? TextFormField(
                  key: Key('trace-$storageKey-time'),
                  initialValue: timeSpent,
                  decoration: const InputDecoration(
                    hintText: Copy.huquqTimeSpentHint,
                  ),
                  onChanged: onTimeSpentChanged,
                )
              : TextField(
                  controller: timeSpentController,
                  decoration: const InputDecoration(
                    hintText: Copy.huquqTimeSpentHint,
                  ),
                  onChanged: onTimeSpentChanged,
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: checkInNestedIndent,
            top: 8,
            bottom: 6,
          ),
          child: Text(
            Copy.huquqPrivateReflection.toUpperCase(),
            style: labelStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: checkInNestedIndent),
          child: noteController == null
              ? TextFormField(
                  key: Key('trace-$storageKey-reflection'),
                  initialValue: note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: Copy.huquqReflectionHint,
                  ),
                  onChanged: onNoteChanged,
                )
              : TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: Copy.huquqReflectionHint,
                  ),
                  onChanged: onNoteChanged,
                ),
        ),
      ],
    );
  }
}
