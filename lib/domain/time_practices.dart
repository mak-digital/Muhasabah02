import 'dart:convert';

import 'activities.dart';
import 'daily_check_in.dart';
import 'factor_groups.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Spec practice IDs (`time_t01`–`time_t08`). Storage keys stay `time.t01`
/// so existing `time.` domain routing continues to work.
const kTimeIntentionSectionId = 'time_intention';
const kTimeAttentionSectionId = 'time_attention';
const kTimeActionSectionId = 'time_action';
const kTimeBalanceSectionId = 'time_balance';

const kTimeIntentionBand = 'Intention & Priority';
const kTimeAttentionBand = 'Attention & Presence';
const kTimeActionBand = 'Responsibility & Action';
const kTimeBalanceBand = 'Balance & Renewal';

/// Stable observation codes for Time & Barakah. Not a productivity scale
/// or a measure of barakah.
abstract final class TimeObservationIds {
  static const acted = ActivityIds.acted;
  static const partialEffort = 'partial_effort';
  static const lapseRecognised = 'lapse_recognised';
  static const corrected = 'corrected';
  static const noSituation = 'no_situation';

  static const ordered = <String>[
    acted,
    partialEffort,
    lapseRecognised,
    corrected,
    noSituation,
  ];
}

class TimeChoice {
  const TimeChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class TimePractice {
  const TimePractice({
    required this.practiceId,
    required this.storageKey,
    required this.sectionId,
    required this.band,
    required this.sectionQuestion,
    required this.label,
    required this.detail,
    required this.matrixColumn,
  });

  final String practiceId;
  final String storageKey;
  final String sectionId;
  final String band;
  final String sectionQuestion;
  final String label;
  final String detail;
  final String matrixColumn;
}

class TimePracticeCapture {
  const TimePracticeCapture({
    this.primaryId = ActivityIds.unanswered,
    this.contextId = kFactorNotRecorded,
    this.challengeId = kFactorNotRecorded,
    this.helpId = kFactorNotRecorded,
    this.outcomeId = kFactorNotRecorded,
    this.quantityId = kFactorNotRecorded,
    this.quantityText = '',
    this.note = '',
  });

  final String primaryId;
  final String contextId;
  final String challengeId;
  final String helpId;
  final String outcomeId;
  final String quantityId;
  final String quantityText;
  final String note;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;

  bool get showsQuantityText =>
      quantityId != kFactorNotRecorded && quantityId.isNotEmpty;

  TimePracticeCapture copyWith({
    String? primaryId,
    String? contextId,
    String? challengeId,
    String? helpId,
    String? outcomeId,
    String? quantityId,
    String? quantityText,
    String? note,
  }) {
    return TimePracticeCapture(
      primaryId: primaryId ?? this.primaryId,
      contextId: contextId ?? this.contextId,
      challengeId: challengeId ?? this.challengeId,
      helpId: helpId ?? this.helpId,
      outcomeId: outcomeId ?? this.outcomeId,
      quantityId: quantityId ?? this.quantityId,
      quantityText: quantityText ?? this.quantityText,
      note: note ?? this.note,
    );
  }
}

const timeContexts = <TimeChoice>[
  TimeChoice(id: 'time.context.worship', label: 'Worship'),
  TimeChoice(
    id: 'time.context.familyCaregiving',
    label: 'Family or caregiving',
  ),
  TimeChoice(
    id: 'time.context.work',
    label: 'Work or professional responsibility',
  ),
  TimeChoice(id: 'time.context.study', label: 'Study or learning'),
  TimeChoice(
    id: 'time.context.healthPersonalCare',
    label: 'Health or personal care',
  ),
  TimeChoice(
    id: 'time.context.communityService',
    label: 'Community or service',
  ),
  TimeChoice(
    id: 'time.context.household',
    label: 'Household responsibilities',
  ),
  TimeChoice(
    id: 'time.context.restRecreation',
    label: 'Rest or recreation',
  ),
  TimeChoice(id: 'time.context.other', label: 'Other'),
  TimeChoice(
    id: 'time.context.preferNotToSpecify',
    label: 'Prefer not to specify',
  ),
];

const timeChallenges = <TimeChoice>[
  TimeChoice(
    id: 'time.challenge.phoneSocial',
    label: 'Phone or social media distraction',
  ),
  TimeChoice(
    id: 'time.challenge.browsingEntertainment',
    label: 'Unnecessary browsing or entertainment',
  ),
  TimeChoice(
    id: 'time.challenge.interruptions',
    label: 'Interruptions or competing demands',
  ),
  TimeChoice(
    id: 'time.challenge.unclearPriorities',
    label: 'Unclear priorities',
  ),
  TimeChoice(
    id: 'time.challenge.procrastination',
    label: 'Avoidable procrastination',
  ),
  TimeChoice(
    id: 'time.challenge.fatigue',
    label: 'Fatigue or insufficient rest',
  ),
  TimeChoice(
    id: 'time.challenge.stressOverload',
    label: 'Stress or mental overload',
  ),
  TimeChoice(id: 'time.challenge.overcommitment', label: 'Overcommitment'),
  TimeChoice(
    id: 'time.challenge.noParticular',
    label: 'No particular challenge',
  ),
  TimeChoice(
    id: 'time.challenge.preferNotToSpecify',
    label: 'Prefer not to specify',
  ),
];

const timeHelps = <TimeChoice>[
  TimeChoice(
    id: 'time.help.clarifiedIntention',
    label: 'Clarified my intention',
  ),
  TimeChoice(
    id: 'time.help.oneNextAction',
    label: 'Chose one important next action',
  ),
  TimeChoice(id: 'time.help.putDeviceAside', label: 'Put my device aside'),
  TimeChoice(
    id: 'time.help.reducedInterruptions',
    label: 'Reduced interruptions',
  ),
  TimeChoice(
    id: 'time.help.smallStep',
    label: 'Started with a small manageable step',
  ),
  TimeChoice(id: 'time.help.adjustedSchedule', label: 'Adjusted my schedule'),
  TimeChoice(id: 'time.help.askedForAssistance', label: 'Asked for assistance'),
  TimeChoice(id: 'time.help.tookRest', label: 'Took appropriate rest'),
  TimeChoice(
    id: 'time.help.reconsideredCompeting',
    label: 'Reconsidered competing responsibilities',
  ),
  TimeChoice(id: 'time.help.other', label: 'Other'),
];

const timeOutcomes = <TimeChoice>[
  TimeChoice(
    id: 'time.outcome.responsibilityCompleted',
    label: 'Important responsibility completed',
  ),
  TimeChoice(
    id: 'time.outcome.meaningfulProgress',
    label: 'Meaningful progress made',
  ),
  TimeChoice(id: 'time.outcome.attentionRestored', label: 'Attention restored'),
  TimeChoice(
    id: 'time.outcome.distractionReduced',
    label: 'Unnecessary distraction reduced',
  ),
  TimeChoice(
    id: 'time.outcome.needAddressed',
    label: 'Someone\'s need addressed',
  ),
  TimeChoice(
    id: 'time.outcome.restTaken',
    label: 'Rest or recovery taken',
  ),
  TimeChoice(
    id: 'time.outcome.postponedAppropriately',
    label: 'Activity appropriately postponed',
  ),
  TimeChoice(
    id: 'time.outcome.followUpNeeded',
    label: 'Follow-up still needed',
  ),
];

const timeQuantities = <TimeChoice>[
  TimeChoice(
    id: 'time.quantity.focusedMinutes',
    label: 'Approximate focused minutes',
  ),
  TimeChoice(
    id: 'time.quantity.distractionMinutesAvoided',
    label: 'Approximate distraction minutes avoided',
  ),
  TimeChoice(
    id: 'time.quantity.interruptedResumed',
    label: 'Number of interrupted activities resumed',
  ),
  TimeChoice(
    id: 'time.quantity.delayedProgressed',
    label: 'Number of delayed tasks progressed',
  ),
];

const timeLegendLabels = <String, String>{
  TimeObservationIds.acted: 'Beneficial action observed',
  TimeObservationIds.partialEffort: 'Partial effort or progress',
  TimeObservationIds.lapseRecognised:
      'Distraction, delay or shortcoming recognised',
  TimeObservationIds.corrected: 'Deliberate adjustment or corrective action',
  TimeObservationIds.noSituation: 'No relevant situation noticed',
  ActivityIds.unanswered: 'Unanswered',
};

const _timeResponseLabels = <String, List<String>>{
  'time.t01': [
    'Began an activity with a clear beneficial intention',
    'Remembered my intention after starting and continued purposefully',
    'Started without considering my purpose and later recognised it',
    'Reconsidered my purpose and redirected an unhelpful activity',
    'No specific situation involving intention noticed today',
  ],
  'time.t02': [
    'Prioritised an important responsibility or beneficial activity',
    'Made progress on a priority but was delayed by less important activities',
    'Recognised that I gave unnecessary priority to something less important',
    'Reordered my activities and returned to an important responsibility',
    'No particular priority decision noticed today',
  ],
  'time.t03': [
    'Gave meaningful attention to a task, person or act of worship',
    'Maintained attention for part of the activity despite interruptions',
    'Recognised that distraction reduced my attention',
    'Noticed my attention wandering and deliberately returned to the activity',
    'No specific attention-related situation noticed today',
  ],
  'time.t04': [
    'Put away or silenced a digital device when attention was needed',
    'Reduced unnecessary device use but was still distracted',
    'Recognised that unnecessary screen use displaced something important',
    'Stopped unnecessary device use and returned to a beneficial activity',
    'No significant digital distraction noticed today',
  ],
  'time.t05': [
    'Completed a responsibility or task I had been unnecessarily delaying',
    'Made meaningful progress on a previously delayed responsibility',
    'Recognised that I continued postponing something requiring attention',
    'Took a concrete first step after recognising unnecessary delay',
    'No relevant overdue or unnecessarily delayed responsibility noticed today',
  ],
  'time.t06': [
    'Used time meaningfully for worship, responsibility, learning or useful work',
    'Made some beneficial use of available time despite interruptions',
    'Recognised that avoidable activity displaced a beneficial opportunity',
    'Redirected available time towards a beneficial activity',
    'No specific discretionary-time decision noticed today',
  ],
  'time.t07': [
    'Gave appropriate attention to someone who needed it',
    'Made an effort to be present but was partly distracted',
    'Recognised that I unnecessarily overlooked someone\'s reasonable need',
    'Put aside another activity and gave the person appropriate attention',
    'No specific unmet need for my attention noticed today',
  ],
  'time.t08': [
    'Took appropriate rest or recovery when needed',
    'Made some time for rest but did not recover sufficiently',
    'Recognised that I unnecessarily neglected needed rest',
    'Adjusted my activities to allow appropriate rest or recovery',
    'No particular rest or recovery decision noticed today',
  ],
};

const timePractices = <TimePractice>[
  TimePractice(
    practiceId: 'time_t01',
    storageKey: 'time.t01',
    sectionId: kTimeIntentionSectionId,
    band: kTimeIntentionBand,
    sectionQuestion: 'Did I approach my time with purpose?',
    label: 'Began with a worthwhile intention',
    detail:
        'Recognised a beneficial purpose before starting an activity, whether worship, work, study, family care or daily responsibility.',
    matrixColumn: 'Intention',
  ),
  TimePractice(
    practiceId: 'time_t02',
    storageKey: 'time.t02',
    sectionId: kTimeIntentionSectionId,
    band: kTimeIntentionBand,
    sectionQuestion: 'Did I approach my time with purpose?',
    label: 'Chose what mattered first',
    detail:
        'Identified an important responsibility or beneficial activity and gave it appropriate priority over something less important.',
    matrixColumn: 'Priority',
  ),
  TimePractice(
    practiceId: 'time_t03',
    storageKey: 'time.t03',
    sectionId: kTimeAttentionSectionId,
    band: kTimeAttentionBand,
    sectionQuestion: 'Did I give proper attention to what mattered?',
    label: 'Gave focused attention',
    detail:
        'Stayed meaningfully engaged with a task, conversation, learning activity or act of worship, or returned attention after noticing it had wandered.',
    matrixColumn: 'Focus',
  ),
  TimePractice(
    practiceId: 'time_t04',
    storageKey: 'time.t04',
    sectionId: kTimeAttentionSectionId,
    band: kTimeAttentionBand,
    sectionQuestion: 'Did I give proper attention to what mattered?',
    label: 'Put aside a digital distraction',
    detail:
        'Resisted or interrupted unnecessary scrolling, notifications, device checking or other digital interruptions.',
    matrixColumn: 'Digital',
  ),
  TimePractice(
    practiceId: 'time_t05',
    storageKey: 'time.t05',
    sectionId: kTimeActionSectionId,
    band: kTimeActionBand,
    sectionQuestion: 'Did I turn available time into beneficial action?',
    label: 'Took a step on something delayed',
    detail:
        'Started or advanced a worthwhile task that had been unnecessarily postponed.',
    matrixColumn: 'Delayed',
  ),
  TimePractice(
    practiceId: 'time_t06',
    storageKey: 'time.t06',
    sectionId: kTimeActionSectionId,
    band: kTimeActionBand,
    sectionQuestion: 'Did I turn available time into beneficial action?',
    label: 'Used time for something beneficial',
    detail:
        'Consciously used an opportunity for learning, service, useful work, worship or another legitimate benefit.',
    matrixColumn: 'Benefit',
  ),
  TimePractice(
    practiceId: 'time_t07',
    storageKey: 'time.t07',
    sectionId: kTimeBalanceSectionId,
    band: kTimeBalanceBand,
    sectionQuestion:
        'Did I respect the rights of others and my own need for recovery?',
    label: 'Gave someone needed attention',
    detail:
        'Made appropriate time for a family member, colleague, neighbour or another person with a legitimate need.',
    matrixColumn: 'Others',
  ),
  TimePractice(
    practiceId: 'time_t08',
    storageKey: 'time.t08',
    sectionId: kTimeBalanceSectionId,
    band: kTimeBalanceBand,
    sectionQuestion:
        'Did I respect the rights of others and my own need for recovery?',
    label: 'Took needed rest',
    detail:
        'Allowed suitable sleep, recovery or restorative breaks rather than unnecessarily neglecting the body\'s needs. Intentional rest is not wasted time.',
    matrixColumn: 'Rest',
  ),
];

List<ActivityOption> timeCatalogFor(String storageKey) {
  final labels =
      _timeResponseLabels[storageKey] ?? _timeResponseLabels['time.t01']!;
  return [
    ActivityOption(
      id: TimeObservationIds.acted,
      label: labels[0],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: TimeObservationIds.partialEffort,
      label: labels[1],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: TimeObservationIds.lapseRecognised,
      label: labels[2],
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: TimeObservationIds.corrected,
      label: labels[3],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: TimeObservationIds.noSituation,
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

List<ActivityOption> get timeLegendCatalog => [
  for (final id in [...TimeObservationIds.ordered, ActivityIds.unanswered])
    ActivityOption(
      id: id,
      label: timeLegendLabels[id] ?? id,
      ternary: switch (id) {
        TimeObservationIds.lapseRecognised => TernaryOutcome.negative,
        ActivityIds.unanswered => TernaryOutcome.unanswered,
        _ => TernaryOutcome.positive,
      },
    ),
];

String canonicalizeTimeActivityId(String id) {
  return switch (id) {
    ActivityIds.noticedNotActed => TimeObservationIds.lapseRecognised,
    ActivityIds.noSituation => TimeObservationIds.noSituation,
    _ => id,
  };
}

String canonicalTimeId(TernaryOutcome outcome) {
  return switch (outcome) {
    TernaryOutcome.unanswered => ActivityIds.unanswered,
    TernaryOutcome.positive => TimeObservationIds.acted,
    TernaryOutcome.negative => TimeObservationIds.lapseRecognised,
  };
}

TimePractice? timePracticeByKey(String storageKey) {
  for (final practice in timePractices) {
    if (practice.storageKey == storageKey) return practice;
  }
  return null;
}

String? timeSectionQuestion(String band) {
  for (final practice in timePractices) {
    if (practice.band == band) return practice.sectionQuestion;
  }
  return null;
}

String timePrimaryLabel(String storageKey, String activityId) {
  final id = canonicalizeTimeActivityId(activityId);
  for (final option in timeCatalogFor(storageKey)) {
    if (option.id == id) return option.label;
  }
  return timeLegendLabels[id] ?? 'Unanswered';
}

String? timeChoiceLabel(List<TimeChoice> choices, String id) {
  if (id.isEmpty || id == kFactorNotRecorded) return null;
  for (final choice in choices) {
    if (choice.id == id) return choice.label;
  }
  return null;
}

String timeFollowUpLabel(String id) {
  return timeChoiceLabel(timeContexts, id) ??
      timeChoiceLabel(timeChallenges, id) ??
      timeChoiceLabel(timeHelps, id) ??
      timeChoiceLabel(timeOutcomes, id) ??
      timeChoiceLabel(timeQuantities, id) ??
      id;
}

bool _stored(String id) => id.isNotEmpty && id != kFactorNotRecorded;

String _asId(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  return kFactorNotRecorded;
}

String? encodeTimeExtras(TimePracticeCapture capture) {
  final map = <String, String>{
    if (_stored(capture.helpId)) 'help': capture.helpId,
    if (_stored(capture.outcomeId)) 'outcome': capture.outcomeId,
    if (_stored(capture.quantityId)) 'quantity': capture.quantityId,
    if (capture.showsQuantityText && capture.quantityText.trim().isNotEmpty)
      'amount': capture.quantityText.trim(),
  };
  if (map.isEmpty) return null;
  return jsonEncode(map);
}

({String helpId, String outcomeId, String quantityId, String quantityText})
decodeTimeExtras(String? customText) {
  if (customText == null || customText.trim().isEmpty) {
    return (
      helpId: kFactorNotRecorded,
      outcomeId: kFactorNotRecorded,
      quantityId: kFactorNotRecorded,
      quantityText: '',
    );
  }
  try {
    final decoded = jsonDecode(customText);
    if (decoded is! Map) {
      return (
        helpId: kFactorNotRecorded,
        outcomeId: kFactorNotRecorded,
        quantityId: kFactorNotRecorded,
        quantityText: '',
      );
    }
    final map = Map<String, dynamic>.from(decoded);
    return (
      helpId: _asId(map['help']),
      outcomeId: _asId(map['outcome']),
      quantityId: _asId(map['quantity']),
      quantityText: map['amount'] is String ? map['amount'] as String : '',
    );
  } on FormatException {
    return (
      helpId: kFactorNotRecorded,
      outcomeId: kFactorNotRecorded,
      quantityId: kFactorNotRecorded,
      quantityText: '',
    );
  }
}

TimePracticeCapture readTimePractice(DailyCheckIn record, String storageKey) {
  final activity = record.activityFor(storageKey);
  final factors =
      record.homeTraceFactors[storageKey] ?? const SalahFactorCapture();
  final extras = decodeTimeExtras(activity.customText);
  return TimePracticeCapture(
    primaryId: canonicalizeTimeActivityId(activity.id),
    contextId: selectedFactorId(factors.supportIds),
    challengeId: selectedFactorId(factors.challengeIds),
    helpId: extras.helpId,
    outcomeId: extras.outcomeId,
    quantityId: extras.quantityId,
    quantityText: extras.quantityText,
    note: factors.otherText ?? '',
  );
}

DailyCheckIn writeTimePractice(
  DailyCheckIn record,
  String storageKey,
  TimePracticeCapture capture,
) {
  final packed = encodeTimeExtras(capture);
  var next = record.withHomeTraceActivity(
    storageKey,
    RecordedActivity(
      id: canonicalizeTimeActivityId(capture.primaryId),
      customText: packed,
    ),
  );
  if (!capture.isPrimaryRecorded) {
    return next.withHomeTraceFactors(storageKey, const SalahFactorCapture());
  }
  return next.withHomeTraceFactors(
    storageKey,
    SalahFactorCapture(
      supportIds: idsFromFactorChoice(capture.contextId),
      challengeIds: idsFromFactorChoice(capture.challengeId),
      otherText: capture.note.trim().isEmpty ? null : capture.note.trim(),
    ),
  );
}

String timeEvidenceValue(DailyCheckIn record, String storageKey) {
  final capture = readTimePractice(record, storageKey);
  if (!capture.isPrimaryRecorded) {
    if (record.homeTrace(storageKey).isRecorded) {
      return 'Recorded';
    }
    return 'Unanswered';
  }
  return timePrimaryLabel(storageKey, capture.primaryId);
}

String? timeEvidenceNote(DailyCheckIn record, String storageKey) {
  final capture = readTimePractice(record, storageKey);
  if (!capture.isPrimaryRecorded) return null;
  final parts = <String>[
    if (timeChoiceLabel(timeContexts, capture.contextId) != null)
      timeChoiceLabel(timeContexts, capture.contextId)!,
    if (timeChoiceLabel(timeChallenges, capture.challengeId) != null)
      timeChoiceLabel(timeChallenges, capture.challengeId)!,
    if (timeChoiceLabel(timeHelps, capture.helpId) != null)
      timeChoiceLabel(timeHelps, capture.helpId)!,
    if (timeChoiceLabel(timeOutcomes, capture.outcomeId) != null)
      timeChoiceLabel(timeOutcomes, capture.outcomeId)!,
    if (timeChoiceLabel(timeQuantities, capture.quantityId) != null)
      timeChoiceLabel(timeQuantities, capture.quantityId)!,
    if (capture.showsQuantityText && capture.quantityText.trim().isNotEmpty)
      capture.quantityText.trim(),
    if (capture.note.trim().isNotEmpty) capture.note.trim(),
  ];
  if (parts.isEmpty) return null;
  return parts.join(', ');
}
