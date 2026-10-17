import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../../domain/factor_groups.dart';
import '../../domain/knowledge_practices.dart';
import 'activity_picker.dart';

class KnowledgeFollowUpFields extends StatelessWidget {
  const KnowledgeFollowUpFields({
    super.key,
    required this.storageKey,
    required this.areaId,
    required this.sourceId,
    required this.verificationId,
    required this.understandingId,
    required this.applicationId,
    required this.quantityId,
    required this.minutes,
    required this.note,
    required this.onAreaChanged,
    required this.onSourceChanged,
    required this.onVerificationChanged,
    required this.onUnderstandingChanged,
    required this.onApplicationChanged,
    required this.onQuantityChanged,
    required this.onMinutesChanged,
    required this.onNoteChanged,
    this.minutesController,
    this.noteController,
  });

  final String storageKey;
  final String areaId;
  final String sourceId;
  final String verificationId;
  final String understandingId;
  final String applicationId;
  final String quantityId;
  final String minutes;
  final String note;
  final ValueChanged<String> onAreaChanged;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onVerificationChanged;
  final ValueChanged<String> onUnderstandingChanged;
  final ValueChanged<String> onApplicationChanged;
  final ValueChanged<String> onQuantityChanged;
  final ValueChanged<String> onMinutesChanged;
  final ValueChanged<String> onNoteChanged;
  final TextEditingController? minutesController;
  final TextEditingController? noteController;

  String _safe(String id, List<KnowledgeChoice> choices) {
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
            Copy.knowledgeFollowUpNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _heading(Copy.knowledgeTypeOfKnowledge, labelStyle),
        _select(
          field: 'area',
          value: _safe(areaId, knowledgeAreas),
          choices: knowledgeAreas,
          onChanged: onAreaChanged,
        ),
        _heading(Copy.knowledgeSourceOfLearning, labelStyle),
        _select(
          field: 'source',
          value: _safe(sourceId, knowledgeSources),
          choices: knowledgeSources,
          onChanged: onSourceChanged,
        ),
        _heading(Copy.knowledgeReliability, labelStyle),
        _select(
          field: 'verification',
          value: _safe(verificationId, knowledgeVerifications),
          choices: knowledgeVerifications,
          onChanged: onVerificationChanged,
        ),
        _heading(Copy.knowledgeUnderstanding, labelStyle),
        _select(
          field: 'understanding',
          value: _safe(understandingId, knowledgeUnderstandings),
          choices: knowledgeUnderstandings,
          onChanged: onUnderstandingChanged,
        ),
        _heading(Copy.knowledgeApplication, labelStyle),
        _select(
          field: 'application',
          value: _safe(applicationId, knowledgeApplications),
          choices: knowledgeApplications,
          onChanged: onApplicationChanged,
        ),
        _heading(Copy.knowledgeOptionalQuantity, labelStyle),
        _select(
          field: 'quantity',
          value: _safe(quantityId, knowledgeQuantities),
          choices: knowledgeQuantities,
          notRecordedLabel: 'No quantity recorded',
          onChanged: onQuantityChanged,
        ),
        if (quantityId == 'knowledge.quantity.approximateMinutes') ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: checkInNestedIndent),
            child: minutesController == null
                ? TextFormField(
                    key: Key('trace-$storageKey-minutes'),
                    initialValue: minutes,
                    decoration: const InputDecoration(
                      hintText: Copy.knowledgeMinutesHint,
                    ),
                    onChanged: onMinutesChanged,
                  )
                : TextField(
                    controller: minutesController,
                    decoration: const InputDecoration(
                      hintText: Copy.knowledgeMinutesHint,
                    ),
                    onChanged: onMinutesChanged,
                  ),
          ),
        ],
        _heading(Copy.knowledgePrivateReflection, labelStyle),
        Padding(
          padding: const EdgeInsets.only(left: checkInNestedIndent),
          child: noteController == null
              ? TextFormField(
                  key: Key('trace-$storageKey-reflection'),
                  initialValue: note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: Copy.knowledgeReflectionHint,
                  ),
                  onChanged: onNoteChanged,
                )
              : TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: Copy.knowledgeReflectionHint,
                  ),
                  onChanged: onNoteChanged,
                ),
        ),
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
    required List<KnowledgeChoice> choices,
    required ValueChanged<String> onChanged,
    String notRecordedLabel = 'Not recorded',
  }) {
    return CheckInSelect<String>(
      depth: CheckInFieldDepth.nested,
      dropdownKey: Key('trace-$storageKey-$field'),
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
