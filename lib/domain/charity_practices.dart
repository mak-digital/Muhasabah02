import 'activities.dart';
import 'daily_check_in.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Descriptive Charity observation kinds. Not a generosity score,
/// leaderboard, or zakat calculator. Unique option ids map onto these
/// kinds for colour and marks only.
enum CharityResponseKind {
  cared,
  partial,
  difficulty,
  noSituation,
  preferNot,
  unanswered,
}

abstract final class CharityObservationIds {
  static const cared = 'cared';
  static const partialEffort = 'partial_effort';
  static const difficultyRecognised = 'difficulty_recognised';
  static const noSituation = 'no_situation';
  static const preferNot = 'prefer_not';

  static const ordered = <String>[
    cared,
    partialEffort,
    difficultyRecognised,
    noSituation,
    preferNot,
  ];
}

class CharityPracticeCapture {
  const CharityPracticeCapture({this.primaryId = ActivityIds.unanswered});

  final String primaryId;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;

  CharityPracticeCapture copyWith({String? primaryId}) {
    return CharityPracticeCapture(primaryId: primaryId ?? this.primaryId);
  }
}

const charityLegendLabels = <String, String>{
  CharityObservationIds.cared: 'Gave or provided support',
  CharityObservationIds.partialEffort: 'Intended, arranged, or offered access',
  CharityObservationIds.difficultyRecognised:
      'Recognised a need without the wished action',
  CharityObservationIds.noSituation: 'No relevant opportunity or need',
  CharityObservationIds.preferNot: 'Prefer not to record',
  ActivityIds.unanswered: 'Not recorded',
};

const _charityKindById = <String, CharityResponseKind>{
  CharityObservationIds.cared: CharityResponseKind.cared,
  CharityObservationIds.partialEffort: CharityResponseKind.partial,
  CharityObservationIds.difficultyRecognised: CharityResponseKind.difficulty,
  CharityObservationIds.noSituation: CharityResponseKind.noSituation,
  CharityObservationIds.preferNot: CharityResponseKind.preferNot,
  ActivityIds.unanswered: CharityResponseKind.unanswered,
  'charity.voluntary.gave': CharityResponseKind.cared,
  'charity.voluntary.intended': CharityResponseKind.partial,
  'charity.voluntary.didNotGive': CharityResponseKind.difficulty,
  'charity.voluntary.noOpportunity': CharityResponseKind.noSituation,
  'charity.householdGiving.financialSupport': CharityResponseKind.cared,
  'charity.householdGiving.practicalCare': CharityResponseKind.partial,
  'charity.householdGiving.didNotAct': CharityResponseKind.difficulty,
  'charity.householdGiving.noNeed': CharityResponseKind.noSituation,
  'charity.community.contributed': CharityResponseKind.cared,
  'charity.community.volunteered': CharityResponseKind.partial,
  'charity.community.didNotAct': CharityResponseKind.difficulty,
  'charity.community.noOpportunity': CharityResponseKind.noSituation,
  'charity.educational.helpedLearn': CharityResponseKind.cared,
  'charity.educational.materials': CharityResponseKind.partial,
  'charity.educational.didNotHelp': CharityResponseKind.difficulty,
  'charity.educational.noOpportunity': CharityResponseKind.noSituation,
  'charity.emergency.immediate': CharityResponseKind.cared,
  'charity.emergency.arranged': CharityResponseKind.partial,
  'charity.emergency.couldNotHelp': CharityResponseKind.difficulty,
  'charity.emergency.noEmergency': CharityResponseKind.noSituation,
  'charity.financialStress.relief': CharityResponseKind.cared,
  'charity.financialStress.accessAssistance': CharityResponseKind.partial,
  'charity.financialStress.practicalEmotional': CharityResponseKind.partial,
  'charity.financialStress.didNotAct': CharityResponseKind.difficulty,
  'charity.financialStress.noSituation': CharityResponseKind.noSituation,
};

const _charityResponseLabels = <String, List<(String, String)>>{
  'charity.voluntary': [
    ('charity.voluntary.gave', 'Gave voluntary charity'),
    ('charity.voluntary.intended', 'Intended or arranged to give'),
    (
      'charity.voluntary.didNotGive',
      'Had an opportunity but did not give',
    ),
    ('charity.voluntary.noOpportunity', 'No relevant opportunity today'),
  ],
  'charity.householdGiving': [
    (
      'charity.householdGiving.financialSupport',
      'Provided financial or material support',
    ),
    (
      'charity.householdGiving.practicalCare',
      'Provided practical assistance or care',
    ),
    (
      'charity.householdGiving.didNotAct',
      'Recognised a need but did not act',
    ),
    ('charity.householdGiving.noNeed', 'No relevant need today'),
  ],
  'charity.community': [
    (
      'charity.community.contributed',
      'Contributed money or useful items',
    ),
    (
      'charity.community.volunteered',
      'Volunteered time, skills or effort',
    ),
    (
      'charity.community.didNotAct',
      'Intended to help but did not act',
    ),
    ('charity.community.noOpportunity', 'No relevant opportunity today'),
  ],
  'charity.educational': [
    ('charity.educational.helpedLearn', 'Helped someone learn'),
    (
      'charity.educational.materials',
      'Provided learning materials or resources',
    ),
    (
      'charity.educational.didNotHelp',
      'Recognised a learning need but did not help',
    ),
    ('charity.educational.noOpportunity', 'No relevant opportunity today'),
  ],
  'charity.emergency': [
    ('charity.emergency.immediate', 'Provided immediate assistance'),
    ('charity.emergency.arranged', 'Helped arrange assistance'),
    (
      'charity.emergency.couldNotHelp',
      'Recognised an emergency but could not help',
    ),
    ('charity.emergency.noEmergency', 'No emergency encountered today'),
  ],
  'charity.financialStress': [
    (
      'charity.financialStress.relief',
      'Provided financial or material relief',
    ),
    (
      'charity.financialStress.accessAssistance',
      'Helped someone access assistance',
    ),
    (
      'charity.financialStress.practicalEmotional',
      'Offered practical or emotional support',
    ),
    (
      'charity.financialStress.didNotAct',
      'Recognised a need but did not act',
    ),
    ('charity.financialStress.noSituation', 'No relevant situation today'),
  ],
};

TernaryOutcome _ternaryForKind(CharityResponseKind kind) {
  return switch (kind) {
    CharityResponseKind.unanswered => TernaryOutcome.unanswered,
    _ => TernaryOutcome.positive,
  };
}

ActivityOption _option(String id, String label) {
  final kind = charityKindFor(id) ?? CharityResponseKind.unanswered;
  return ActivityOption(
    id: id,
    label: label,
    ternary: _ternaryForKind(kind),
  );
}

List<ActivityOption> charityCatalogFor(String storageKey) {
  final rows = _charityResponseLabels[storageKey];
  if (rows == null) return const [];
  return [
    const ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Not recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    for (final row in rows) _option(row.$1, row.$2),
    _option(CharityObservationIds.preferNot, 'Prefer not to record'),
  ];
}

List<ActivityOption> get charityLegendCatalog => [
  for (final id in [ActivityIds.unanswered, ...CharityObservationIds.ordered])
    ActivityOption(
      id: id,
      label: charityLegendLabels[id] ?? id,
      ternary: _ternaryForKind(
        charityKindFor(id) ?? CharityResponseKind.unanswered,
      ),
    ),
];

CharityResponseKind? charityKindFor(String activityId) =>
    _charityKindById[activityId];

String charityPrimaryLabel(String storageKey, String activityId) {
  for (final option in charityCatalogFor(storageKey)) {
    if (option.id == activityId) return option.label;
  }
  return charityLegendLabels[activityId] ?? 'Not recorded';
}

CharityPracticeCapture readCharityPractice(
  DailyCheckIn record,
  String storageKey,
) {
  return CharityPracticeCapture(primaryId: record.activityFor(storageKey).id);
}

DailyCheckIn writeCharityPractice(
  DailyCheckIn record,
  String storageKey,
  CharityPracticeCapture capture,
) {
  return record
      .withHomeTraceActivity(
        storageKey,
        RecordedActivity(id: capture.primaryId),
      )
      .withHomeTraceFactors(storageKey, const SalahFactorCapture());
}

String charityEvidenceValue(DailyCheckIn record, String storageKey) {
  final capture = readCharityPractice(record, storageKey);
  if (!capture.isPrimaryRecorded) {
    if (record.homeTrace(storageKey).isRecorded) return 'Recorded';
    return 'Not recorded';
  }
  return charityPrimaryLabel(storageKey, capture.primaryId);
}

String? charityEvidenceNote(DailyCheckIn record, String storageKey) => null;
