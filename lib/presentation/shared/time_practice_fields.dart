import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../../domain/factor_groups.dart';
import '../../domain/time_practices.dart';
import 'activity_picker.dart';

class TimePracticeFields extends StatelessWidget {
  const TimePracticeFields({
    super.key,
    required this.storageKey,
    required this.contextId,
    required this.challengeId,
    required this.helpId,
    required this.outcomeId,
    required this.quantityId,
    required this.quantityText,
    required this.onContextChanged,
    required this.onChallengeChanged,
    required this.onHelpChanged,
    required this.onOutcomeChanged,
    required this.onQuantityChanged,
    required this.onQuantityTextChanged,
    this.quantityController,
  });

  final String storageKey;
  final String contextId;
  final String challengeId;
  final String helpId;
  final String outcomeId;
  final String quantityId;
  final String quantityText;
  final ValueChanged<String> onContextChanged;
  final ValueChanged<String> onChallengeChanged;
  final ValueChanged<String> onHelpChanged;
  final ValueChanged<String> onOutcomeChanged;
  final ValueChanged<String> onQuantityChanged;
  final ValueChanged<String> onQuantityTextChanged;
  final TextEditingController? quantityController;

  String _safe(String id, List<TimeChoice> choices) {
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
            Copy.timeFollowUpNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _heading(Copy.timeActivityContext, labelStyle),
        _select(
          field: 'context',
          value: _safe(contextId, timeContexts),
          choices: timeContexts,
          onChanged: onContextChanged,
        ),
        _heading(Copy.timeMainChallenge, labelStyle),
        _select(
          field: 'challenge',
          value: _safe(challengeId, timeChallenges),
          choices: timeChallenges,
          onChanged: onChallengeChanged,
        ),
        _heading(Copy.timeWhatHelped, labelStyle),
        _select(
          field: 'help',
          value: _safe(helpId, timeHelps),
          choices: timeHelps,
          onChanged: onHelpChanged,
        ),
        _heading(Copy.timeObservableOutcome, labelStyle),
        _select(
          field: 'outcome',
          value: _safe(outcomeId, timeOutcomes),
          choices: timeOutcomes,
          onChanged: onOutcomeChanged,
        ),
        _heading(Copy.timeOptionalQuantity, labelStyle),
        _select(
          field: 'quantity',
          value: _safe(quantityId, timeQuantities),
          choices: timeQuantities,
          notRecordedLabel: 'No quantity recorded',
          onChanged: onQuantityChanged,
        ),
        if (quantityId != kFactorNotRecorded && quantityId.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: checkInNestedIndent),
            child: quantityController == null
                ? TextFormField(
                    key: Key('time-$storageKey-amount'),
                    initialValue: quantityText,
                    decoration: const InputDecoration(
                      hintText: Copy.timeQuantityHint,
                    ),
                    onChanged: onQuantityTextChanged,
                  )
                : TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      hintText: Copy.timeQuantityHint,
                    ),
                    onChanged: onQuantityTextChanged,
                  ),
          ),
        ],
      ],
    );
  }

  Widget _heading(String label, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(
        left: checkInNestedIndent,
        top: 8,
        bottom: 6,
      ),
      child: Text(label.toUpperCase(), style: style),
    );
  }

  Widget _select({
    required String field,
    required String value,
    required List<TimeChoice> choices,
    required ValueChanged<String> onChanged,
    String notRecordedLabel = 'Not recorded',
  }) {
    return CheckInSelect<String>(
      depth: CheckInFieldDepth.nested,
      dropdownKey: Key('time-$storageKey-$field'),
      value: value,
      sortLabels: false,
      entries: [
        CheckInSelectEntry(
          value: kFactorNotRecorded,
          label: notRecordedLabel,
        ),
        for (final choice in choices)
          CheckInSelectEntry(value: choice.id, label: choice.label),
      ],
      onChanged: onChanged,
    );
  }
}
