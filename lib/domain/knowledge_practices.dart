import 'dart:convert';

import 'activities.dart';
import 'daily_check_in.dart';
import 'factor_groups.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Stable observation codes for Knowledge & Beneficial Speech. Not a rank,
/// intelligence score, or religious grade.
abstract final class KnowledgeObservationIds {
  static const engaged = 'engaged';
  static const progress = 'progress';
  static const gapRecognised = 'gap_recognised';
  static const corrected = 'corrected';
  static const noSituation = 'no_situation';

  static const ordered = <String>[
    engaged,
    progress,
    gapRecognised,
    corrected,
    noSituation,
  ];
}

class KnowledgeChoice {
  const KnowledgeChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class KnowledgeFollowUpCapture {
  const KnowledgeFollowUpCapture({
    this.primaryId = ActivityIds.unanswered,
    this.areaId = kFactorNotRecorded,
    this.sourceId = kFactorNotRecorded,
    this.verificationId = kFactorNotRecorded,
    this.understandingId = kFactorNotRecorded,
    this.applicationId = kFactorNotRecorded,
    this.quantityId = kFactorNotRecorded,
    this.minutes = '',
    this.note = '',
  });

  final String primaryId;
  final String areaId;
  final String sourceId;
  final String verificationId;
  final String understandingId;
  final String applicationId;
  final String quantityId;
  final String minutes;
  final String note;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;

  bool get showsMinutes =>
      quantityId == 'knowledge.quantity.approximateMinutes';

  KnowledgeFollowUpCapture copyWith({
    String? primaryId,
    String? areaId,
    String? sourceId,
    String? verificationId,
    String? understandingId,
    String? applicationId,
    String? quantityId,
    String? minutes,
    String? note,
  }) {
    return KnowledgeFollowUpCapture(
      primaryId: primaryId ?? this.primaryId,
      areaId: areaId ?? this.areaId,
      sourceId: sourceId ?? this.sourceId,
      verificationId: verificationId ?? this.verificationId,
      understandingId: understandingId ?? this.understandingId,
      applicationId: applicationId ?? this.applicationId,
      quantityId: quantityId ?? this.quantityId,
      minutes: minutes ?? this.minutes,
      note: note ?? this.note,
    );
  }
}

const knowledgeAreas = <KnowledgeChoice>[
  KnowledgeChoice(
    id: 'knowledge.area.religiousOutsideQuranHadith',
    label:
        'Religious knowledge outside separately tracked Qur’an and Hadith study',
  ),
  KnowledgeChoice(
    id: 'knowledge.area.scienceTechnology',
    label: 'Science and technology',
  ),
  KnowledgeChoice(
    id: 'knowledge.area.professional',
    label: 'Professional or vocational knowledge',
  ),
  KnowledgeChoice(
    id: 'knowledge.area.healthWellbeing',
    label: 'Health and wellbeing',
  ),
  KnowledgeChoice(
    id: 'knowledge.area.familyRelationships',
    label: 'Family and relationships',
  ),
  KnowledgeChoice(
    id: 'knowledge.area.personalDevelopment',
    label: 'Personal development',
  ),
  KnowledgeChoice(
    id: 'knowledge.area.socialCommunity',
    label: 'Social or community knowledge',
  ),
  KnowledgeChoice(
    id: 'knowledge.area.practicalLifeSkills',
    label: 'Practical life skills',
  ),
  KnowledgeChoice(id: 'knowledge.area.other', label: 'Other'),
  KnowledgeChoice(
    id: 'knowledge.area.preferNotToSpecify',
    label: 'Prefer not to specify',
  ),
];

const knowledgeSources = <KnowledgeChoice>[
  KnowledgeChoice(
    id: 'knowledge.source.book',
    label: 'Book or written publication',
  ),
  KnowledgeChoice(
    id: 'knowledge.source.teacher',
    label: 'Teacher or qualified expert',
  ),
  KnowledgeChoice(
    id: 'knowledge.source.course',
    label: 'Formal course or lecture',
  ),
  KnowledgeChoice(
    id: 'knowledge.source.research',
    label: 'Research paper or technical reference',
  ),
  KnowledgeChoice(
    id: 'knowledge.source.discussion',
    label: 'Discussion with another person',
  ),
  KnowledgeChoice(
    id: 'knowledge.source.online',
    label: 'Online educational content',
  ),
  KnowledgeChoice(
    id: 'knowledge.source.aiAssisted',
    label: 'AI-assisted learning',
  ),
  KnowledgeChoice(
    id: 'knowledge.source.experience',
    label: 'Personal experience or observation',
  ),
  KnowledgeChoice(id: 'knowledge.source.other', label: 'Other'),
];

const knowledgeVerifications = <KnowledgeChoice>[
  KnowledgeChoice(
    id: 'knowledge.verification.primarySource',
    label: 'Checked against a reliable primary source',
  ),
  KnowledgeChoice(
    id: 'knowledge.verification.qualifiedSource',
    label: 'Confirmed through a qualified source',
  ),
  KnowledgeChoice(
    id: 'knowledge.verification.multipleSources',
    label: 'Compared with more than one independent source',
  ),
  KnowledgeChoice(
    id: 'knowledge.verification.notIndependentlyVerified',
    label: 'Understood but not independently verified',
  ),
  KnowledgeChoice(
    id: 'knowledge.verification.pending',
    label: 'Still uncertain or requiring verification',
  ),
  KnowledgeChoice(
    id: 'knowledge.verification.notApplicable',
    label: 'Not applicable',
  ),
];

const knowledgeUnderstandings = <KnowledgeChoice>[
  KnowledgeChoice(
    id: 'knowledge.understanding.canExplain',
    label: 'Understood and can explain it',
  ),
  KnowledgeChoice(
    id: 'knowledge.understanding.mainIdea',
    label: 'Understood the main idea',
  ),
  KnowledgeChoice(
    id: 'knowledge.understanding.partial',
    label: 'Partially understood',
  ),
  KnowledgeChoice(
    id: 'knowledge.understanding.needClarification',
    label: 'Need further clarification',
  ),
];

const knowledgeApplications = <KnowledgeChoice>[
  KnowledgeChoice(
    id: 'knowledge.application.applied',
    label: 'Applied the knowledge in a practical situation',
  ),
  KnowledgeChoice(
    id: 'knowledge.application.identified',
    label: 'Identified a specific application',
  ),
  KnowledgeChoice(
    id: 'knowledge.application.correctedMisunderstanding',
    label: 'Corrected a previous misunderstanding',
  ),
  KnowledgeChoice(
    id: 'knowledge.application.sharedResponsibly',
    label: 'Shared responsibly with someone',
  ),
  KnowledgeChoice(
    id: 'knowledge.application.createdUseful',
    label: 'Created something useful',
  ),
  KnowledgeChoice(
    id: 'knowledge.application.didNotShareUnverified',
    label: 'Decided not to share unverified information',
  ),
  KnowledgeChoice(
    id: 'knowledge.application.furtherLearning',
    label: 'Further learning required',
  ),
  KnowledgeChoice(
    id: 'knowledge.application.noneYet',
    label: 'No specific application yet',
  ),
];

const knowledgeQuantities = <KnowledgeChoice>[
  KnowledgeChoice(
    id: 'knowledge.quantity.oneOccasion',
    label: 'One learning or sharing occasion',
  ),
  KnowledgeChoice(
    id: 'knowledge.quantity.severalOccasions',
    label: 'Several occasions',
  ),
  KnowledgeChoice(
    id: 'knowledge.quantity.approximateMinutes',
    label: 'Approximate minutes spent',
  ),
];

const knowledgeLegendLabels = <String, String>{
  KnowledgeObservationIds.engaged: 'Relevant beneficial activity recorded',
  KnowledgeObservationIds.progress:
      'Partial or developing engagement recorded',
  KnowledgeObservationIds.gapRecognised:
      'Uncertainty, limitation or shortcoming identified',
  KnowledgeObservationIds.corrected:
      'Misunderstanding, inaccurate information or conduct corrected',
  KnowledgeObservationIds.noSituation:
      'No relevant activity or situation recorded',
  ActivityIds.unanswered: 'Unanswered',
};

const _knowledgeResponseLabels = <String, List<String>>{
  'knowledge.learnedSomethingTrue': [
    'Learned something new and verified its reliability',
    'Learned something useful and understood its meaning',
    'Learned something but need further clarification or verification',
    'Recognised a previous misunderstanding and corrected it',
    'No new learning specifically noticed today',
  ],
  'knowledge.beneficialReading': [
    'Read beneficial material and gained useful understanding',
    'Read beneficial material and identified something to apply',
    'Read but understood only part of the material',
    'Recognised unreliable or misleading information and checked it',
    'No beneficial reading recorded today',
  ],
  'knowledge.askedToRemoveIgnorance': [
    'Asked a knowledgeable or reliable source and obtained clarification',
    'Asked a question and gained partial understanding',
    'Identified something I did not know but have not yet sought clarification',
    'Recognised an incorrect assumption and sought to correct it',
    'No specific question or knowledge gap noticed today',
  ],
  'knowledge.taughtSomeone': [
    'Explained something reliable and helped another person understand',
    'Shared useful knowledge and attempted to explain it clearly',
    'Tried to explain but recognised gaps in my own understanding',
    'Corrected information I had previously explained inaccurately',
    'No relevant teaching opportunity noticed today',
  ],
  'knowledge.sincereAdvice': [
    'Offered relevant advice with care and a sound basis',
    'Offered advice while acknowledging uncertainty or limitations',
    'Recognised that my advice was incomplete or insufficiently supported',
    'Clarified or corrected advice I had previously given',
    'No appropriate opportunity to offer advice noticed today',
  ],
  'knowledge.beneficialCreating': [
    'Completed useful content or work with a clear beneficial purpose',
    'Made meaningful progress on beneficial content or work',
    'Started creating something but have not yet established its usefulness or accuracy',
    'Reviewed and corrected inaccurate or potentially harmful content',
    'No relevant writing or creation recorded today',
  ],
  'knowledge.heldBackUselessSpeech': [
    'Chose beneficial speech or appropriate silence when needed',
    'Paused and reconsidered what I was about to say',
    'Engaged in unnecessary or harmful speech and recognised it',
    'Stopped, corrected or apologised for inappropriate speech',
    'No specific situation requiring restraint noticed today',
  ],
};

List<ActivityOption> knowledgeCatalogFor(String storageKey) {
  final labels =
      _knowledgeResponseLabels[storageKey] ??
      _knowledgeResponseLabels['knowledge.learnedSomethingTrue']!;
  return [
    ActivityOption(
      id: KnowledgeObservationIds.engaged,
      label: labels[0],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: KnowledgeObservationIds.progress,
      label: labels[1],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: KnowledgeObservationIds.gapRecognised,
      label: labels[2],
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: KnowledgeObservationIds.corrected,
      label: labels[3],
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: KnowledgeObservationIds.noSituation,
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

List<ActivityOption> get knowledgeLegendCatalog => [
  for (final id in [
    ...KnowledgeObservationIds.ordered,
    ActivityIds.unanswered,
  ])
    ActivityOption(
      id: id,
      label: knowledgeLegendLabels[id] ?? id,
      ternary: switch (id) {
        KnowledgeObservationIds.gapRecognised => TernaryOutcome.negative,
        ActivityIds.unanswered => TernaryOutcome.unanswered,
        _ => TernaryOutcome.positive,
      },
    ),
];

String canonicalKnowledgeId(TernaryOutcome outcome) {
  return switch (outcome) {
    TernaryOutcome.unanswered => ActivityIds.unanswered,
    TernaryOutcome.positive => KnowledgeObservationIds.engaged,
    TernaryOutcome.negative => KnowledgeObservationIds.noSituation,
  };
}

String? knowledgeChoiceLabel(List<KnowledgeChoice> choices, String id) {
  if (id.isEmpty || id == kFactorNotRecorded) return null;
  for (final choice in choices) {
    if (choice.id == id) return choice.label;
  }
  return null;
}

String knowledgeFollowUpLabel(String id) {
  return knowledgeChoiceLabel(knowledgeAreas, id) ??
      knowledgeChoiceLabel(knowledgeSources, id) ??
      knowledgeChoiceLabel(knowledgeVerifications, id) ??
      knowledgeChoiceLabel(knowledgeUnderstandings, id) ??
      knowledgeChoiceLabel(knowledgeApplications, id) ??
      knowledgeChoiceLabel(knowledgeQuantities, id) ??
      id;
}

String? encodeKnowledgeExtras(KnowledgeFollowUpCapture capture) {
  final map = <String, String>{
    if (_stored(capture.sourceId)) 'source': capture.sourceId,
    if (_stored(capture.understandingId))
      'understanding': capture.understandingId,
    if (_stored(capture.applicationId)) 'application': capture.applicationId,
    if (_stored(capture.quantityId)) 'quantity': capture.quantityId,
    if (capture.showsMinutes && capture.minutes.trim().isNotEmpty)
      'minutes': capture.minutes.trim(),
  };
  if (map.isEmpty) return null;
  return jsonEncode(map);
}

({
  String sourceId,
  String understandingId,
  String applicationId,
  String quantityId,
  String minutes,
})
decodeKnowledgeExtras(String? customText) {
  if (customText == null || customText.trim().isEmpty) {
    return (
      sourceId: kFactorNotRecorded,
      understandingId: kFactorNotRecorded,
      applicationId: kFactorNotRecorded,
      quantityId: kFactorNotRecorded,
      minutes: '',
    );
  }
  try {
    final decoded = jsonDecode(customText);
    if (decoded is! Map) {
      return (
        sourceId: kFactorNotRecorded,
        understandingId: kFactorNotRecorded,
        applicationId: kFactorNotRecorded,
        quantityId: kFactorNotRecorded,
        minutes: '',
      );
    }
    final map = Map<String, dynamic>.from(decoded);
    return (
      sourceId: _asId(map['source']),
      understandingId: _asId(map['understanding']),
      applicationId: _asId(map['application']),
      quantityId: _asId(map['quantity']),
      minutes: map['minutes'] is String ? (map['minutes'] as String) : '',
    );
  } on FormatException {
    return (
      sourceId: kFactorNotRecorded,
      understandingId: kFactorNotRecorded,
      applicationId: kFactorNotRecorded,
      quantityId: kFactorNotRecorded,
      minutes: '',
    );
  }
}

bool _stored(String id) => id.isNotEmpty && id != kFactorNotRecorded;

String _asId(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  return kFactorNotRecorded;
}

KnowledgeFollowUpCapture readKnowledgeFollowUp(
  DailyCheckIn record,
  String storageKey,
) {
  final activity = record.activityFor(storageKey);
  final factors =
      record.homeTraceFactors[storageKey] ?? const SalahFactorCapture();
  final extras = decodeKnowledgeExtras(activity.customText);
  return KnowledgeFollowUpCapture(
    primaryId: activity.id,
    areaId: selectedFactorId(factors.supportIds),
    sourceId: extras.sourceId,
    verificationId: selectedFactorId(factors.challengeIds),
    understandingId: extras.understandingId,
    applicationId: extras.applicationId,
    quantityId: extras.quantityId,
    minutes: extras.minutes,
    note: factors.otherText ?? '',
  );
}

DailyCheckIn writeKnowledgeFollowUp(
  DailyCheckIn record,
  String storageKey,
  KnowledgeFollowUpCapture capture,
) {
  final packed = encodeKnowledgeExtras(capture);
  var next = record.withHomeTraceActivity(
    storageKey,
    RecordedActivity(
      id: capture.primaryId,
      customText: packed,
    ),
  );
  if (!capture.isPrimaryRecorded) {
    return next.withHomeTraceFactors(storageKey, const SalahFactorCapture());
  }
  return next.withHomeTraceFactors(
    storageKey,
    SalahFactorCapture(
      supportIds: idsFromFactorChoice(capture.areaId),
      challengeIds: idsFromFactorChoice(capture.verificationId),
      otherText: capture.note.trim().isEmpty ? null : capture.note.trim(),
    ),
  );
}

String? knowledgeEvidenceNote(DailyCheckIn record, String storageKey) {
  final capture = readKnowledgeFollowUp(record, storageKey);
  final parts = <String>[
    if (knowledgeChoiceLabel(knowledgeAreas, capture.areaId) != null)
      knowledgeChoiceLabel(knowledgeAreas, capture.areaId)!,
    if (knowledgeChoiceLabel(knowledgeSources, capture.sourceId) != null)
      knowledgeChoiceLabel(knowledgeSources, capture.sourceId)!,
    if (knowledgeChoiceLabel(knowledgeVerifications, capture.verificationId) !=
        null)
      knowledgeChoiceLabel(knowledgeVerifications, capture.verificationId)!,
    if (knowledgeChoiceLabel(
          knowledgeUnderstandings,
          capture.understandingId,
        ) !=
        null)
      knowledgeChoiceLabel(knowledgeUnderstandings, capture.understandingId)!,
    if (knowledgeChoiceLabel(knowledgeApplications, capture.applicationId) !=
        null)
      knowledgeChoiceLabel(knowledgeApplications, capture.applicationId)!,
    if (knowledgeChoiceLabel(knowledgeQuantities, capture.quantityId) != null)
      knowledgeChoiceLabel(knowledgeQuantities, capture.quantityId)!,
    if (capture.showsMinutes && capture.minutes.trim().isNotEmpty)
      '${capture.minutes.trim()} min',
    if (capture.note.trim().isNotEmpty) capture.note.trim(),
  ];
  if (parts.isEmpty) return null;
  return parts.join(', ');
}
