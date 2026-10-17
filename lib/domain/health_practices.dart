import 'activities.dart';
import 'daily_check_in.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Descriptive Health observation kinds. Not a fitness, compliance, or
/// spiritual scale. Unique item option ids map onto these kinds for colour
/// and marks only.
enum HealthResponseKind {
  cared,
  partial,
  difficulty,
  lapse,
  corrected,
  constrained,
  noSituation,
  preferNot,
  unanswered,
}

abstract final class HealthObservationIds {
  static const cared = 'cared';
  static const partialEffort = 'partial_effort';
  static const difficultyRecognised = 'difficulty_recognised';
  static const lapseRecognised = 'lapse_recognised';
  static const corrected = 'corrected';
  static const constrained = 'constrained';
  static const noSituation = 'no_situation';
  static const preferNot = 'prefer_not';

  static const ordered = <String>[
    cared,
    partialEffort,
    difficultyRecognised,
    lapseRecognised,
    corrected,
    constrained,
    noSituation,
    preferNot,
  ];
}

class HealthPracticeCapture {
  const HealthPracticeCapture({this.primaryId = ActivityIds.unanswered});

  final String primaryId;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;

  HealthPracticeCapture copyWith({String? primaryId}) {
    return HealthPracticeCapture(primaryId: primaryId ?? this.primaryId);
  }
}

const healthLegendLabels = <String, String>{
  HealthObservationIds.cared: 'Beneficial care observed',
  HealthObservationIds.partialEffort: 'Partial or mixed care',
  HealthObservationIds.difficultyRecognised:
      'Difficulty noticed — not a failing of the body',
  HealthObservationIds.lapseRecognised: 'Avoidable neglect recognised',
  HealthObservationIds.corrected: 'Adjustment towards care',
  HealthObservationIds.constrained: 'Circumstances beyond my control',
  HealthObservationIds.noSituation: 'No relevant need or situation',
  HealthObservationIds.preferNot: 'Prefer not to record',
  ActivityIds.unanswered: 'Unanswered',
};

const _healthKindById = <String, HealthResponseKind>{
  HealthObservationIds.cared: HealthResponseKind.cared,
  HealthObservationIds.partialEffort: HealthResponseKind.partial,
  HealthObservationIds.difficultyRecognised: HealthResponseKind.difficulty,
  HealthObservationIds.lapseRecognised: HealthResponseKind.lapse,
  HealthObservationIds.corrected: HealthResponseKind.corrected,
  HealthObservationIds.constrained: HealthResponseKind.constrained,
  HealthObservationIds.noSituation: HealthResponseKind.noSituation,
  HealthObservationIds.preferNot: HealthResponseKind.preferNot,
  ActivityIds.unanswered: HealthResponseKind.unanswered,
  'health.sleepQuality.refreshed': HealthResponseKind.cared,
  'health.sleepQuality.interruptedRested': HealthResponseKind.partial,
  'health.sleepQuality.sleptPoorly': HealthResponseKind.difficulty,
  'health.sleepQuality.addressedDifficulty': HealthResponseKind.corrected,
  'health.sleepQuality.constrained': HealthResponseKind.constrained,
  'health.sleepAmount.sufficient': HealthResponseKind.cared,
  'health.sleepAmount.necessaryDuties': HealthResponseKind.constrained,
  'health.sleepAmount.unnecessarilyReduced': HealthResponseKind.lapse,
  'health.sleepAmount.adjustedRoutine': HealthResponseKind.corrected,
  'health.sleepAmount.constrained': HealthResponseKind.constrained,
  'health.movement.suitableActivity': HealthResponseKind.cared,
  'health.movement.ordinaryDuties': HealthResponseKind.partial,
  'health.movement.despiteLimitations': HealthResponseKind.difficulty,
  'health.movement.inactivityDisplaced': HealthResponseKind.lapse,
  'health.movement.notPossible': HealthResponseKind.constrained,
  'health.energyForIbadah.sufficient': HealthResponseKind.cared,
  'health.energyForIbadah.managedLimited': HealthResponseKind.partial,
  'health.energyForIbadah.fatigueDespiteEffort': HealthResponseKind.difficulty,
  'health.energyForIbadah.avoidableFatigueStep': HealthResponseKind.corrected,
  'health.energyForIbadah.illnessLimited': HealthResponseKind.constrained,
  'health.nutrition.balanced': HealthResponseKind.cared,
  'health.nutrition.moderation': HealthResponseKind.partial,
  'health.nutrition.unhelpfulPattern': HealthResponseKind.lapse,
  'health.nutrition.practicalImprovement': HealthResponseKind.corrected,
  'health.nutrition.constrained': HealthResponseKind.constrained,
  'health.hydration.appropriate': HealthResponseKind.cared,
  'health.hydration.consciousEffort': HealthResponseKind.partial,
  'health.hydration.neglected': HealthResponseKind.lapse,
  'health.hydration.correctedRoutine': HealthResponseKind.corrected,
  'health.hydration.medicalGuidance': HealthResponseKind.constrained,
  'health.illnessCare.soughtAdvice': HealthResponseKind.cared,
  'health.illnessCare.followedGuidance': HealthResponseKind.partial,
  'health.illnessCare.recognisedAndStepped': HealthResponseKind.corrected,
  'health.illnessCare.delayedCare': HealthResponseKind.lapse,
  'health.illnessCare.noIllness': HealthResponseKind.noSituation,
  'health.avoidedHarm.avoidedForeseeable': HealthResponseKind.cared,
  'health.avoidedHarm.reducedRisky': HealthResponseKind.partial,
  'health.avoidedHarm.recognisedNotChanged': HealthResponseKind.difficulty,
  'health.avoidedHarm.correctedChoice': HealthResponseKind.corrected,
  'health.avoidedHarm.noRisk': HealthResponseKind.noSituation,
};

const _healthResponseLabels = <String, List<(String, String)>>{
  'health.sleepQuality': [
    (
      'health.sleepQuality.refreshed',
      'I slept well and felt reasonably refreshed.',
    ),
    (
      'health.sleepQuality.interruptedRested',
      'My sleep was interrupted, but I felt adequately rested.',
    ),
    (
      'health.sleepQuality.sleptPoorly',
      'I slept poorly and noticed reduced alertness or energy.',
    ),
    (
      'health.sleepQuality.addressedDifficulty',
      'I recognised a sleep difficulty and took a reasonable step to address it.',
    ),
    (
      'health.sleepQuality.constrained',
      'My sleep was affected by illness, care duties or circumstances beyond my control.',
    ),
  ],
  'health.sleepAmount': [
    (
      'health.sleepAmount.sufficient',
      'I had sufficient sleep for my circumstances.',
    ),
    (
      'health.sleepAmount.necessaryDuties',
      'I slept less than I needed because of necessary responsibilities.',
    ),
    (
      'health.sleepAmount.unnecessarilyReduced',
      'I unnecessarily reduced my available sleeping time.',
    ),
    (
      'health.sleepAmount.adjustedRoutine',
      'I adjusted my routine to make more time for needed sleep.',
    ),
    (
      'health.sleepAmount.constrained',
      'My sleep duration was affected by circumstances beyond my control.',
    ),
  ],
  'health.movement': [
    (
      'health.movement.suitableActivity',
      'I engaged in suitable physical movement or activity.',
    ),
    (
      'health.movement.ordinaryDuties',
      'I incorporated useful movement into ordinary daily responsibilities.',
    ),
    (
      'health.movement.despiteLimitations',
      'I made a reasonable effort despite physical limitations.',
    ),
    (
      'health.movement.inactivityDisplaced',
      'I recognised that unnecessary inactivity displaced suitable movement.',
    ),
    (
      'health.movement.notPossible',
      'Movement was not appropriate or possible because of my health or circumstances.',
    ),
  ],
  'health.energyForIbadah': [
    (
      'health.energyForIbadah.sufficient',
      'I had sufficient energy for my worship and responsibilities.',
    ),
    (
      'health.energyForIbadah.managedLimited',
      'I managed limited energy and adjusted my activities appropriately.',
    ),
    (
      'health.energyForIbadah.fatigueDespiteEffort',
      'Fatigue affected my worship or responsibilities despite reasonable effort.',
    ),
    (
      'health.energyForIbadah.avoidableFatigueStep',
      'I recognised avoidable fatigue and took a step to manage it.',
    ),
    (
      'health.energyForIbadah.illnessLimited',
      'Illness or circumstances significantly limited my available energy.',
    ),
  ],
  'health.nutrition': [
    (
      'health.nutrition.balanced',
      'I ate in a reasonably balanced and nourishing way.',
    ),
    (
      'health.nutrition.moderation',
      'I ate with moderation and avoided unnecessary excess.',
    ),
    (
      'health.nutrition.unhelpfulPattern',
      'I recognised an unhelpful eating choice or pattern.',
    ),
    (
      'health.nutrition.practicalImprovement',
      'I made a practical improvement in my food choices.',
    ),
    (
      'health.nutrition.constrained',
      'My food choices were constrained by health, access or other circumstances.',
    ),
  ],
  'health.hydration': [
    (
      'health.hydration.appropriate',
      'I maintained hydration appropriate to my needs.',
    ),
    (
      'health.hydration.consciousEffort',
      'I made a conscious effort to drink appropriately.',
    ),
    (
      'health.hydration.neglected',
      'I recognised that I had unnecessarily neglected hydration.',
    ),
    (
      'health.hydration.correctedRoutine',
      'I corrected my hydration routine after noticing a problem.',
    ),
    (
      'health.hydration.medicalGuidance',
      'My fluid intake was affected by medical guidance or circumstances beyond my control.',
    ),
  ],
  'health.illnessCare': [
    (
      'health.illnessCare.soughtAdvice',
      'I sought appropriate medical advice or care when needed.',
    ),
    (
      'health.illnessCare.followedGuidance',
      'I followed appropriate treatment or recovery guidance.',
    ),
    (
      'health.illnessCare.recognisedAndStepped',
      'I recognised a health concern and took a reasonable step to address it.',
    ),
    (
      'health.illnessCare.delayedCare',
      'I recognised a need for care but unnecessarily delayed taking action.',
    ),
    (
      'health.illnessCare.noIllness',
      'I experienced no particular illness or need for medical care today.',
    ),
  ],
  'health.avoidedHarm': [
    (
      'health.avoidedHarm.avoidedForeseeable',
      'I consciously avoided a foreseeable harm to my health.',
    ),
    (
      'health.avoidedHarm.reducedRisky',
      'I reduced an unhealthy or unnecessarily risky behaviour.',
    ),
    (
      'health.avoidedHarm.recognisedNotChanged',
      'I recognised a harmful behaviour but did not yet change it.',
    ),
    (
      'health.avoidedHarm.correctedChoice',
      'I corrected a harmful choice after recognising it.',
    ),
    (
      'health.avoidedHarm.noRisk',
      'I noticed no particular preventable health risk today.',
    ),
  ],
};

TernaryOutcome _ternaryForKind(HealthResponseKind kind) {
  return switch (kind) {
    HealthResponseKind.unanswered => TernaryOutcome.unanswered,
    HealthResponseKind.lapse => TernaryOutcome.negative,
    _ => TernaryOutcome.positive,
  };
}

ActivityOption _option(String id, String label) {
  final kind = healthKindFor(id) ?? HealthResponseKind.unanswered;
  return ActivityOption(
    id: id,
    label: label,
    ternary: _ternaryForKind(kind),
  );
}

List<ActivityOption> healthCatalogFor(String storageKey) {
  final rows =
      _healthResponseLabels[storageKey] ??
      _healthResponseLabels['health.sleepQuality']!;
  return [
    for (final row in rows) _option(row.$1, row.$2),
    _option(HealthObservationIds.preferNot, 'Prefer not to record'),
    const ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Unanswered',
      ternary: TernaryOutcome.unanswered,
    ),
  ];
}

List<ActivityOption> get healthLegendCatalog => [
  for (final id in [...HealthObservationIds.ordered, ActivityIds.unanswered])
    ActivityOption(
      id: id,
      label: healthLegendLabels[id] ?? id,
      ternary: _ternaryForKind(
        healthKindFor(id) ?? HealthResponseKind.unanswered,
      ),
    ),
];

HealthResponseKind? healthKindFor(String activityId) =>
    _healthKindById[activityId];

String healthPrimaryLabel(String storageKey, String activityId) {
  for (final option in healthCatalogFor(storageKey)) {
    if (option.id == activityId) return option.label;
  }
  return healthLegendLabels[activityId] ?? 'Unanswered';
}

HealthPracticeCapture readHealthPractice(
  DailyCheckIn record,
  String storageKey,
) {
  return HealthPracticeCapture(
    primaryId: record.activityFor(storageKey).id,
  );
}

DailyCheckIn writeHealthPractice(
  DailyCheckIn record,
  String storageKey,
  HealthPracticeCapture capture,
) {
  return record
      .withHomeTraceActivity(
        storageKey,
        RecordedActivity(id: capture.primaryId),
      )
      .withHomeTraceFactors(storageKey, const SalahFactorCapture());
}

String healthEvidenceValue(DailyCheckIn record, String storageKey) {
  final capture = readHealthPractice(record, storageKey);
  if (!capture.isPrimaryRecorded) {
    if (record.homeTrace(storageKey).isRecorded) return 'Recorded';
    return 'Unanswered';
  }
  return healthPrimaryLabel(storageKey, capture.primaryId);
}

String? healthEvidenceNote(DailyCheckIn record, String storageKey) => null;
