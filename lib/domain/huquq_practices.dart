import 'activities.dart';
import 'daily_check_in.dart';
import 'factor_groups.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Stable observation codes for Rights of Others. Not a rank, score, or
/// religious verdict. Lack of daily contact is not neglect.
abstract final class HuquqObservationIds {
  static const practised = 'practised';
  static const partialEffort = 'partial_effort';
  static const neglectRecognised = 'neglect_recognised';
  static const correctiveAction = 'corrective_action';
  static const noSituation = 'no_situation';

  static const ordered = <String>[
    practised,
    partialEffort,
    neglectRecognised,
    correctiveAction,
    noSituation,
  ];
}

class HuquqChoice {
  const HuquqChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class HuquqFollowUpCapture {
  const HuquqFollowUpCapture({
    this.primaryId = ActivityIds.unanswered,
    this.engagementId = kFactorNotRecorded,
    this.outcomeId = kFactorNotRecorded,
    this.occasions = '',
    this.timeSpent = '',
    this.note = '',
  });

  final String primaryId;
  final String engagementId;
  final String outcomeId;
  final String occasions;
  final String timeSpent;
  final String note;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;

  HuquqFollowUpCapture copyWith({
    String? primaryId,
    String? engagementId,
    String? outcomeId,
    String? occasions,
    String? timeSpent,
    String? note,
  }) {
    return HuquqFollowUpCapture(
      primaryId: primaryId ?? this.primaryId,
      engagementId: engagementId ?? this.engagementId,
      outcomeId: outcomeId ?? this.outcomeId,
      occasions: occasions ?? this.occasions,
      timeSpent: timeSpent ?? this.timeSpent,
      note: note ?? this.note,
    );
  }
}

const huquqEngagements = <HuquqChoice>[
  HuquqChoice(
    id: 'huquq.engagement.respectfulInteraction',
    label: 'Respectful interaction',
  ),
  HuquqChoice(
    id: 'huquq.engagement.contactOrCommunication',
    label: 'Contact or communication',
  ),
  HuquqChoice(
    id: 'huquq.engagement.practicalAssistance',
    label: 'Practical assistance',
  ),
  HuquqChoice(
    id: 'huquq.engagement.financialOrMaterialSupport',
    label: 'Financial or material support',
  ),
  HuquqChoice(
    id: 'huquq.engagement.emotionalSupport',
    label: 'Emotional support',
  ),
  HuquqChoice(
    id: 'huquq.engagement.adviceOrGuidance',
    label: 'Advice or guidance',
  ),
  HuquqChoice(id: 'huquq.engagement.dua', label: 'Du‘a'),
  HuquqChoice(
    id: 'huquq.engagement.apologyOrReconciliation',
    label: 'Apology or reconciliation',
  ),
  HuquqChoice(
    id: 'huquq.engagement.restitutionOrFulfilment',
    label: 'Restitution or fulfilment of a right',
  ),
  HuquqChoice(id: 'huquq.engagement.other', label: 'Other'),
  HuquqChoice(
    id: 'huquq.engagement.preferNotToSay',
    label: 'Prefer not to say',
  ),
];

const huquqOutcomes = <HuquqChoice>[
  HuquqChoice(
    id: 'huquq.outcome.needAddressed',
    label: 'Need or responsibility addressed',
  ),
  HuquqChoice(
    id: 'huquq.outcome.partialProgress',
    label: 'Partial progress made',
  ),
  HuquqChoice(
    id: 'huquq.outcome.followUpNeeded',
    label: 'Follow-up still needed',
  ),
  HuquqChoice(
    id: 'huquq.outcome.unableToComplete',
    label: 'Unable to complete',
  ),
  HuquqChoice(
    id: 'huquq.outcome.noOutcomeConfirmed',
    label: 'No outcome confirmed',
  ),
  HuquqChoice(
    id: 'huquq.outcome.preferNotToSay',
    label: 'Prefer not to say',
  ),
];

const huquqLegendLabels = <String, String>{
  HuquqObservationIds.practised: 'Appropriate positive action recorded',
  HuquqObservationIds.partialEffort: 'Effort made but not fully completed',
  HuquqObservationIds.neglectRecognised:
      'Possible shortcoming or neglected right recognised',
  HuquqObservationIds.correctiveAction: 'Repair or corrective step recorded',
  HuquqObservationIds.noSituation:
      'No applicable situation or unmet responsibility recorded',
  ActivityIds.unanswered: 'Unanswered',
};

const _huquqQuantitySep = '\u001e';

const _huquqResponseLabels = <String, List<String>>{
  'huquq.parents': [
    'Honoured my parents through care, respect, contact or du‘a',
    'Made an effort but could have responded better to their needs',
    'Recognised that I neglected a responsibility or behaved disrespectfully',
    'Took steps to apologise, restore contact or fulfil a neglected responsibility',
    'No specific action or unmet responsibility to record today',
  ],
  'huquq.spouse': [
    'Showed kindness, fairness or practical support to my spouse',
    'Made an effort but fell short in attention, understanding or support',
    'Recognised that I neglected a right or responded unfairly',
    'Apologised, corrected my behaviour or addressed a neglected responsibility',
    'Not applicable or no specific situation to record today',
  ],
  'huquq.children': [
    'Gave appropriate care, guidance, affection or attention to my children',
    'Made an effort but could have been more attentive or supportive',
    'Recognised that I neglected a need or responded unfairly',
    'Repaired my response or took steps to fulfil a neglected responsibility',
    'Not applicable or no specific situation to record today',
  ],
  'huquq.siblings': [
    'Maintained family ties through kindness, contact, assistance or du‘a',
    'Intended or attempted to support a sibling but did not fully follow through',
    'Recognised avoidable neglect, unfairness or hurtful conduct',
    'Reached out, apologised or addressed a neglected responsibility',
    'No specific situation or unmet responsibility noticed today',
  ],
  'huquq.grandparents': [
    'Showed respect, maintained contact, offered support or made du‘a',
    'Made an effort but could have responded better to an identified need',
    'Recognised that I neglected an appropriate responsibility',
    'Reached out or took steps to correct a neglected responsibility',
    'Not applicable or no specific situation to record today',
  ],
  'huquq.otherRelatives': [
    'Maintained family ties through contact, kindness, assistance or du‘a',
    'Made an effort but did not fully follow through on an intended action',
    'Recognised avoidable neglect or unfair treatment of a relative',
    'Reached out, apologised or addressed a neglected family responsibility',
    'No specific situation or unmet responsibility noticed today',
  ],
  'huquq.neighbours': [
    'Respected a neighbour\'s rights or offered kindness or assistance',
    'Tried to be considerate but could have responded better',
    'Recognised that my actions caused avoidable inconvenience or harm',
    'Corrected the disturbance, apologised or offered appropriate assistance',
    'No specific interaction or unmet responsibility noticed today',
  ],
  'huquq.colleaguesFriends': [
    'Acted fairly, kept a commitment or offered appropriate support',
    'Made an effort but did not fully meet an identified responsibility',
    'Recognised unfairness, broken trust or avoidable neglect',
    'Apologised, corrected an action or fulfilled an outstanding commitment',
    'No specific interaction or unmet responsibility noticed today',
  ],
  'huquq.muslims': [
    'Showed kindness, fairness, assistance or concern for fellow Muslims',
    'Made an effort but missed an opportunity to provide appropriate support',
    'Recognised unfairness, harmful conduct or neglect of an identified right',
    'Corrected my conduct, apologised or provided appropriate assistance',
    'No specific interaction or unmet responsibility noticed today',
  ],
  'huquq.nonMuslims': [
    'Treated non-Muslims with fairness, dignity, kindness or appropriate assistance',
    'Made an effort but could have responded more fairly or considerately',
    'Recognised prejudice, unfairness or harmful conduct',
    'Corrected my conduct, apologised or restored an affected right',
    'No specific interaction or unmet responsibility noticed today',
  ],
  'huquq.reconciliation': [
    'Took a constructive and appropriate step towards reconciliation',
    'Considered or attempted reconciliation but did not complete a step',
    'Recognised my contribution to an unresolved disagreement',
    'Apologised, corrected a wrong or made an appropriate reconciliation effort',
    'No appropriate reconciliation action needed or possible today',
  ],
  'huquq.returnedFromNeglect': [
    'Fulfilled or restored a right I had previously neglected',
    'Began addressing a neglected right but have not completed it',
    'Recognised an outstanding right that still needs attention',
    'Took a concrete step towards restitution, repayment or correction',
    'No outstanding neglected right identified today',
  ],
  'huquq.sickVisit': [
    'Visited a sick person when appropriate and reasonably possible',
    'Attempted or arranged a visit but could not complete it',
    'Recognised that I had unnecessarily neglected an appropriate visit',
    'Arranged a suitable visit or alternative support',
    'No appropriate visit needed or reasonably possible today',
  ],
  'huquq.sickContact': [
    'Contacted a sick person to offer concern, comfort or support',
    'Attempted contact but could not reach the person',
    'Recognised that I unnecessarily delayed appropriate contact',
    'Reached out after the delay or arranged appropriate follow-up',
    'No appropriate contact needed or reasonably possible today',
  ],
  'huquq.supportUnderStress': [
    'Offered practical, emotional or other appropriate support to someone in difficulty',
    'Tried to help but could provide only limited support',
    'Recognised that I overlooked a reasonable opportunity to help',
    'Followed up or took a constructive step to provide support',
    'No identified opportunity to provide appropriate support today',
  ],
};

List<ActivityOption> huquqCatalogFor(String storageKey) {
  final labels =
      _huquqResponseLabels[storageKey] ?? _huquqResponseLabels['huquq.parents']!;
  return [
    ActivityOption(
      id: HuquqObservationIds.practised,
      label: labels[0],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: HuquqObservationIds.partialEffort,
      label: labels[1],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: HuquqObservationIds.neglectRecognised,
      label: labels[2],
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: HuquqObservationIds.correctiveAction,
      label: labels[3],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: HuquqObservationIds.noSituation,
      label: labels[4],
      ternary: TernaryOutcome.positive,
    ),
    const ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Unanswered',
      ternary: TernaryOutcome.unanswered,
    ),
  ];
}

List<ActivityOption> get huquqLegendCatalog => [
  for (final id in [...HuquqObservationIds.ordered, ActivityIds.unanswered])
    ActivityOption(
      id: id,
      label: huquqLegendLabels[id] ?? id,
      ternary: switch (id) {
        HuquqObservationIds.neglectRecognised => TernaryOutcome.negative,
        ActivityIds.unanswered => TernaryOutcome.unanswered,
        _ => TernaryOutcome.positive,
      },
    ),
];

String canonicalHuquqId(TernaryOutcome outcome) {
  return switch (outcome) {
    TernaryOutcome.unanswered => ActivityIds.unanswered,
    TernaryOutcome.positive => HuquqObservationIds.practised,
    TernaryOutcome.negative => HuquqObservationIds.neglectRecognised,
  };
}

String? huquqChoiceLabel(List<HuquqChoice> choices, String id) {
  if (id.isEmpty || id == kFactorNotRecorded) return null;
  for (final choice in choices) {
    if (choice.id == id) return choice.label;
  }
  return null;
}

String huquqFollowUpLabel(String id) {
  return huquqChoiceLabel(huquqEngagements, id) ??
      huquqChoiceLabel(huquqOutcomes, id) ??
      id;
}

String encodeHuquqQuantity(String occasions, String timeSpent) {
  final a = occasions.trim();
  final b = timeSpent.trim();
  if (a.isEmpty && b.isEmpty) return '';
  return '$a$_huquqQuantitySep$b';
}

({String occasions, String timeSpent}) decodeHuquqQuantity(String? customText) {
  if (customText == null || customText.isEmpty) {
    return (occasions: '', timeSpent: '');
  }
  final index = customText.indexOf(_huquqQuantitySep);
  if (index < 0) return (occasions: customText, timeSpent: '');
  return (
    occasions: customText.substring(0, index),
    timeSpent: customText.substring(index + 1),
  );
}

HuquqFollowUpCapture readHuquqFollowUp(
  DailyCheckIn record,
  String storageKey,
) {
  final activity = record.activityFor(storageKey);
  final factors =
      record.homeTraceFactors[storageKey] ?? const SalahFactorCapture();
  final quantity = decodeHuquqQuantity(activity.customText);
  return HuquqFollowUpCapture(
    primaryId: activity.id,
    engagementId: selectedFactorId(factors.supportIds),
    outcomeId: selectedFactorId(factors.challengeIds),
    occasions: quantity.occasions,
    timeSpent: quantity.timeSpent,
    note: factors.otherText ?? '',
  );
}

DailyCheckIn writeHuquqFollowUp(
  DailyCheckIn record,
  String storageKey,
  HuquqFollowUpCapture capture,
) {
  final packed = encodeHuquqQuantity(capture.occasions, capture.timeSpent);
  var next = record.withHomeTraceActivity(
    storageKey,
    RecordedActivity(
      id: capture.primaryId,
      customText: packed.isEmpty ? null : packed,
    ),
  );
  if (!capture.isPrimaryRecorded) {
    return next.withHomeTraceFactors(storageKey, const SalahFactorCapture());
  }
  return next.withHomeTraceFactors(
    storageKey,
    SalahFactorCapture(
      supportIds: idsFromFactorChoice(capture.engagementId),
      challengeIds: idsFromFactorChoice(capture.outcomeId),
      otherText: capture.note.trim().isEmpty ? null : capture.note.trim(),
    ),
  );
}

String? huquqEvidenceNote(DailyCheckIn record, String storageKey) {
  final capture = readHuquqFollowUp(record, storageKey);
  final parts = <String>[
    if (huquqChoiceLabel(huquqEngagements, capture.engagementId) != null)
      huquqChoiceLabel(huquqEngagements, capture.engagementId)!,
    if (huquqChoiceLabel(huquqOutcomes, capture.outcomeId) != null)
      huquqChoiceLabel(huquqOutcomes, capture.outcomeId)!,
    if (capture.occasions.trim().isNotEmpty)
      '${capture.occasions.trim()} occasions',
    if (capture.timeSpent.trim().isNotEmpty) capture.timeSpent.trim(),
    if (capture.note.trim().isNotEmpty) capture.note.trim(),
  ];
  if (parts.isEmpty) return null;
  return parts.join(', ');
}
