import 'activities.dart';
import 'daily_check_in.dart';
import 'factor_groups.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Stable observation codes for Character & Morals. Not a rank or score.
abstract final class AkhlaqObservationIds {
  static const practised = 'practised';
  static const struggled = 'struggled';
  static const lapseRecognised = 'lapse_recognised';
  static const corrected = 'corrected';
  static const noSituation = 'no_situation';

  static const ordered = <String>[
    practised,
    struggled,
    lapseRecognised,
    corrected,
    noSituation,
  ];
}

class AkhlaqChoice {
  const AkhlaqChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class AkhlaqFollowUpCapture {
  const AkhlaqFollowUpCapture({
    this.primaryId = ActivityIds.unanswered,
    this.contextId = kFactorNotRecorded,
    this.helpId = kFactorNotRecorded,
    this.note = '',
  });

  final String primaryId;
  final String contextId;
  final String helpId;
  final String note;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;
}

const akhlaqContexts = <AkhlaqChoice>[
  AkhlaqChoice(id: 'akhlaq.context.familyHome', label: 'Family / Home'),
  AkhlaqChoice(id: 'akhlaq.context.workStudy', label: 'Work / Study'),
  AkhlaqChoice(id: 'akhlaq.context.friendsCommunity', label: 'Friends / Community'),
  AkhlaqChoice(id: 'akhlaq.context.online', label: 'Online'),
  AkhlaqChoice(id: 'akhlaq.context.public', label: 'Public'),
  AkhlaqChoice(id: 'akhlaq.context.privatePersonal', label: 'Private / Personal'),
  AkhlaqChoice(id: 'akhlaq.context.preferNotToSay', label: 'Prefer not to say'),
];

const akhlaqHelps = <AkhlaqChoice>[
  AkhlaqChoice(
    id: 'akhlaq.help.pausingBeforeReacting',
    label: 'Pausing before reacting',
  ),
  AkhlaqChoice(
    id: 'akhlaq.help.rememberingAllah',
    label: 'Remembering Allah',
  ),
  AkhlaqChoice(
    id: 'akhlaq.help.consideringRights',
    label: 'Considering another person\'s rights',
  ),
  AkhlaqChoice(id: 'akhlaq.help.seekingAdvice', label: 'Seeking advice'),
  AkhlaqChoice(
    id: 'akhlaq.help.apologisingOrRepairing',
    label: 'Apologising or repairing harm',
  ),
  AkhlaqChoice(id: 'akhlaq.help.avoidingTrigger', label: 'Avoiding a trigger'),
  AkhlaqChoice(id: 'akhlaq.help.other', label: 'Other'),
];

const akhlaqLegendLabels = <String, String>{
  AkhlaqObservationIds.practised: 'Virtue demonstrated',
  AkhlaqObservationIds.struggled: 'Attempted but experienced difficulty',
  AkhlaqObservationIds.lapseRecognised: 'Shortcoming recognised',
  AkhlaqObservationIds.corrected: 'Corrective action taken after a lapse',
  AkhlaqObservationIds.noSituation: 'No relevant situation noticed',
  ActivityIds.unanswered: 'Unanswered',
};

const _akhlaqResponseLabels = <String, List<String>>{
  'akhlaq.patience': [
    'Remained patient when tested',
    'Tried but struggled to remain patient',
    'Lost patience and recognised it',
    'Lost patience, then corrected my response',
    'No situation requiring patience noticed',
  ],
  'akhlaq.humility': [
    'Accepted advice, correction or another viewpoint',
    'Tried to be humble but felt defensive',
    'Reacted with pride or arrogance and recognised it',
    'Acknowledged my mistake or apologised afterwards',
    'No relevant situation noticed',
  ],
  'akhlaq.truthfulness': [
    'Spoke truthfully despite difficulty',
    'Tried to be truthful but avoided necessary honesty',
    'Said something untrue or misleading and recognised it',
    'Corrected a false or misleading statement',
    'No relevant situation noticed',
  ],
  'akhlaq.gentleness': [
    'Responded gently, including when challenged',
    'Tried to be gentle but struggled with my tone',
    'Spoke or acted harshly and recognised it',
    'Apologised or corrected a harsh response',
    'No relevant interaction noticed',
  ],
  'akhlaq.courage': [
    'Took a principled action despite difficulty',
    'Made an effort but hesitated',
    'Avoided a needed action out of fear and recognised it',
    'Returned and took an appropriate corrective step',
    'No relevant situation requiring courage noticed',
  ],
  'akhlaq.gratitude': [
    'Expressed appreciation or used a blessing responsibly',
    'Intended to show gratitude but did not fully act',
    'Recognised an ungrateful response',
    'Corrected my response or expressed appreciation afterwards',
    'No specific situation noticed',
  ],
  'akhlaq.contentment': [
    'Accepted my circumstances without undue resentment',
    'Tried to be content but struggled with comparison',
    'Recognised envy or undue dissatisfaction',
    'Redirected myself towards gratitude and constructive action',
    'No relevant challenge to contentment noticed',
  ],
  'akhlaq.pausedBeforeReacting': [
    'Paused and responded thoughtfully',
    'Tried to pause but reacted too quickly',
    'Reacted impulsively and recognised it',
    'Paused later, apologised or repaired my response',
    'No situation requiring a pause noticed',
  ],
  'akhlaq.honestyInSmallMatters': [
    'Acted honestly even in a small matter',
    'Tried to be honest but hesitated or avoided clarity',
    'Was misleading or unfair and recognised it',
    'Corrected the misleading or unfair action',
    'No relevant situation noticed',
  ],
  'akhlaq.letGoOfGrudge': [
    'Let go of resentment without excusing wrongdoing',
    'Made an effort to release resentment',
    'Continued holding resentment and recognised it',
    'Took a constructive step towards forgiveness',
    'No relevant resentment noticed',
  ],
  'akhlaq.modestSpeech': [
    'Maintained a respectful and appropriate tone',
    'Tried to guard my tone but struggled',
    'Used an inappropriate tone and recognised it',
    'Corrected my tone or apologised',
    'No relevant conversation noticed',
  ],
  'akhlaq.modestDress': [
    'Dressed according to my understood modesty obligations',
    'Made an effort but fell short of my intended standard',
    'Recognised that my dress did not meet my understood obligations',
    'Adjusted my clothing appropriately',
    'No relevant situation or change to assess',
  ],
  'akhlaq.modestGaze': [
    'Lowered or redirected my gaze appropriately',
    'Tried to look away but struggled',
    'Continued looking inappropriately and recognised it',
    'Stopped and redirected my gaze afterwards',
    'No relevant situation noticed',
  ],
  'akhlaq.walkedAwayFromArgument': [
    'Disengaged appropriately before escalation',
    'Tried to disengage but continued briefly',
    'Continued an unnecessary argument and recognised it',
    'Stopped later or repaired harm caused',
    'No unnecessary argument occurred',
  ],
  'akhlaq.heldBackFromAHabit': [
    'Resisted the habit when tempted',
    'Interrupted the habit after starting',
    'Continued the habit and recognised it',
    'Took a constructive step to repair or prevent recurrence',
    'No temptation or relevant situation noticed',
  ],
};

List<ActivityOption> akhlaqCatalogFor(String storageKey) {
  final labels =
      _akhlaqResponseLabels[storageKey] ??
      _akhlaqResponseLabels['akhlaq.patience']!;
  return [
    ActivityOption(
      id: AkhlaqObservationIds.practised,
      label: labels[0],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: AkhlaqObservationIds.struggled,
      label: labels[1],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: AkhlaqObservationIds.lapseRecognised,
      label: labels[2],
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: AkhlaqObservationIds.corrected,
      label: labels[3],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: AkhlaqObservationIds.noSituation,
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

List<ActivityOption> get akhlaqLegendCatalog => [
  for (final id in [
    ...AkhlaqObservationIds.ordered,
    ActivityIds.unanswered,
  ])
    ActivityOption(
      id: id,
      label: akhlaqLegendLabels[id] ?? id,
      ternary: switch (id) {
        AkhlaqObservationIds.lapseRecognised => TernaryOutcome.negative,
        ActivityIds.unanswered => TernaryOutcome.unanswered,
        _ => TernaryOutcome.positive,
      },
    ),
];

String canonicalAkhlaqId(TernaryOutcome outcome) {
  return switch (outcome) {
    TernaryOutcome.unanswered => ActivityIds.unanswered,
    TernaryOutcome.positive => AkhlaqObservationIds.practised,
    TernaryOutcome.negative => AkhlaqObservationIds.noSituation,
  };
}

String? akhlaqChoiceLabel(List<AkhlaqChoice> choices, String id) {
  if (id.isEmpty || id == kFactorNotRecorded) return null;
  for (final choice in choices) {
    if (choice.id == id) return choice.label;
  }
  return null;
}

String akhlaqFollowUpLabel(String id) {
  return akhlaqChoiceLabel(akhlaqContexts, id) ??
      akhlaqChoiceLabel(akhlaqHelps, id) ??
      id;
}

AkhlaqFollowUpCapture readAkhlaqFollowUp(
  DailyCheckIn record,
  String storageKey,
) {
  final activity = record.activityFor(storageKey);
  final factors =
      record.homeTraceFactors[storageKey] ?? const SalahFactorCapture();
  return AkhlaqFollowUpCapture(
    primaryId: activity.id,
    contextId: selectedFactorId(factors.supportIds),
    helpId: selectedFactorId(factors.challengeIds),
    note: factors.otherText ?? '',
  );
}

DailyCheckIn writeAkhlaqFollowUp(
  DailyCheckIn record,
  String storageKey,
  AkhlaqFollowUpCapture capture,
) {
  var next = record.withHomeTraceActivity(
    storageKey,
    RecordedActivity(id: capture.primaryId),
  );
  if (!capture.isPrimaryRecorded) {
    return next.withHomeTraceFactors(storageKey, const SalahFactorCapture());
  }
  return next.withHomeTraceFactors(
    storageKey,
    SalahFactorCapture(
      supportIds: idsFromFactorChoice(capture.contextId),
      challengeIds: idsFromFactorChoice(capture.helpId),
      otherText: capture.note.trim().isEmpty ? null : capture.note.trim(),
    ),
  );
}
