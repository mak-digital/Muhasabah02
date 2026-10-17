import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import 'activity_picker.dart';

class HealthPracticeFields extends StatelessWidget {
  const HealthPracticeFields({
    super.key,
    required this.storageKey,
    required this.note,
    required this.onNoteChanged,
    this.noteController,
  });

  final String storageKey;
  final String note;
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
            Copy.healthFollowUpNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: checkInValueIndent,
            top: 12,
            bottom: 4,
          ),
          child: Text(Copy.healthPrivateReflection.toUpperCase(), style: labelStyle),
        ),
        Padding(
          padding: const EdgeInsets.only(left: checkInValueIndent),
          child: TextField(
            key: Key('health-$storageKey-note'),
            controller: noteController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: Copy.healthReflectionHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onNoteChanged,
          ),
        ),
      ],
    );
  }
}
