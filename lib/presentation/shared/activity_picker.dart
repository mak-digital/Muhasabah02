import 'package:flutter/material.dart';

import '../../domain/activities.dart';

class ActivityPicker extends StatelessWidget {
  const ActivityPicker({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.accent,
    this.statusKeyPrefix,
  });

  final List<ActivityOption> options;
  final String selectedId;
  final ValueChanged<ActivityOption> onSelected;
  final Color? accent;
  final String? statusKeyPrefix;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            key: _keyFor(option),
            selected: selectedId == option.id,
            label: Text(option.label),
            selectedColor: accent?.withValues(alpha: 0.22),
            onSelected: (_) => onSelected(option),
          ),
      ],
    );
  }

  Key? _keyFor(ActivityOption option) {
    if (statusKeyPrefix == null) return null;
    final status = option.prayerStatus?.name;
    if (option.id == 'aloneOnTime') {
      return Key('$statusKeyPrefix-onTime');
    }
    if (option.id == 'prayedLate') {
      return Key('$statusKeyPrefix-late');
    }
    if (option.id == 'missed') {
      return Key('$statusKeyPrefix-missed');
    }
    if (option.id == ActivityIds.unanswered) {
      return Key('$statusKeyPrefix-unanswered');
    }
    if (status != null) return Key('$statusKeyPrefix-${option.id}');
    return Key('$statusKeyPrefix-${option.id}');
  }
}
