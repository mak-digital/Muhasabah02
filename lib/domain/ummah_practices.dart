import 'activities.dart';
import 'daily_check_in.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Descriptive Ummah observation kinds. Not a social grade, political log,
/// or religious verdict. Unique option ids map onto these kinds for colour
/// and marks only.
enum UmmahResponseKind {
  cared,
  partial,
  difficulty,
  corrected,
  noSituation,
  preferNot,
  unanswered,
}

abstract final class UmmahObservationIds {
  static const cared = 'cared';
  static const partialEffort = 'partial_effort';
  static const difficultyRecognised = 'difficulty_recognised';
  static const corrected = 'corrected';
  static const noSituation = 'no_situation';
  static const preferNot = 'prefer_not';

  static const ordered = <String>[
    cared,
    partialEffort,
    difficultyRecognised,
    corrected,
    noSituation,
    preferNot,
  ];
}

class UmmahPracticeCapture {
  const UmmahPracticeCapture({this.primaryId = ActivityIds.unanswered});

  final String primaryId;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;

  UmmahPracticeCapture copyWith({String? primaryId}) {
    return UmmahPracticeCapture(primaryId: primaryId ?? this.primaryId);
  }
}

const ummahLegendLabels = <String, String>{
  UmmahObservationIds.cared: 'Constructive service observed',
  UmmahObservationIds.partialEffort: 'Remote, spoken, or included effort',
  UmmahObservationIds.difficultyRecognised:
      'Opportunity noticed without the wished action',
  UmmahObservationIds.corrected: 'Held back from harm or tended a shared space',
  UmmahObservationIds.noSituation: 'No relevant opportunity, or not recalled',
  UmmahObservationIds.preferNot: 'Prefer not to record',
  ActivityIds.unanswered: 'Unanswered',
};

const _ummahKindById = <String, UmmahResponseKind>{
  UmmahObservationIds.cared: UmmahResponseKind.cared,
  UmmahObservationIds.partialEffort: UmmahResponseKind.partial,
  UmmahObservationIds.difficultyRecognised: UmmahResponseKind.difficulty,
  UmmahObservationIds.corrected: UmmahResponseKind.corrected,
  UmmahObservationIds.noSituation: UmmahResponseKind.noSituation,
  UmmahObservationIds.preferNot: UmmahResponseKind.preferNot,
  ActivityIds.unanswered: UmmahResponseKind.unanswered,
  'ummah.masjidAttendance.attended': UmmahResponseKind.cared,
  'ummah.masjidAttendance.remote': UmmahResponseKind.partial,
  'ummah.masjidAttendance.intendedDidNot': UmmahResponseKind.difficulty,
  'ummah.masjidAttendance.noOpportunity': UmmahResponseKind.noSituation,
  'ummah.dawahByCharacter.showedValues': UmmahResponseKind.cared,
  'ummah.dawahByCharacter.respondedRespectfully': UmmahResponseKind.partial,
  'ummah.dawahByCharacter.didNotActAsWished': UmmahResponseKind.difficulty,
  'ummah.dawahByCharacter.noOpportunity': UmmahResponseKind.noSituation,
  'ummah.supportedOppressed.practicalHelp': UmmahResponseKind.cared,
  'ummah.supportedOppressed.spokeVerified': UmmahResponseKind.partial,
  'ummah.supportedOppressed.madeDua': UmmahResponseKind.cared,
  'ummah.supportedOppressed.didNotAct': UmmahResponseKind.difficulty,
  'ummah.supportedOppressed.noOpportunity': UmmahResponseKind.noSituation,
  'ummah.unityEfforts.reconciled': UmmahResponseKind.cared,
  'ummah.unityEfforts.cooperated': UmmahResponseKind.partial,
  'ummah.unityEfforts.avoidedDivisiveSpeech': UmmahResponseKind.corrected,
  'ummah.unityEfforts.noConstructiveResponse': UmmahResponseKind.difficulty,
  'ummah.unityEfforts.noOpportunity': UmmahResponseKind.noSituation,
  'ummah.prayedForUmmah.specificDua': UmmahResponseKind.cared,
  'ummah.prayedForUmmah.includedRegular': UmmahResponseKind.partial,
  'ummah.prayedForUmmah.intendedDidNotRecall': UmmahResponseKind.difficulty,
  'ummah.prayedForUmmah.didNotRecall': UmmahResponseKind.noSituation,
  'ummah.earthCare.reducedWaste': UmmahResponseKind.cared,
  'ummah.earthCare.conservedResources': UmmahResponseKind.partial,
  'ummah.earthCare.caredForPlace': UmmahResponseKind.corrected,
  'ummah.earthCare.didNotAct': UmmahResponseKind.difficulty,
  'ummah.earthCare.noOpportunity': UmmahResponseKind.noSituation,
};

const _ummahResponseLabels = <String, List<(String, String)>>{
  'ummah.masjidAttendance': [
    (
      'ummah.masjidAttendance.attended',
      'I attended a beneficial masjid class or gathering.',
    ),
    (
      'ummah.masjidAttendance.remote',
      'I participated remotely in a masjid-led learning or community gathering.',
    ),
    (
      'ummah.masjidAttendance.intendedDidNot',
      'I intended to attend but did not attend.',
    ),
    (
      'ummah.masjidAttendance.noOpportunity',
      'I had no relevant opportunity today.',
    ),
  ],
  'ummah.dawahByCharacter': [
    (
      'ummah.dawahByCharacter.showedValues',
      'I showed honesty, patience or kindness that reflected my values.',
    ),
    (
      'ummah.dawahByCharacter.respondedRespectfully',
      'I responded respectfully when asked about Islam or my conduct.',
    ),
    (
      'ummah.dawahByCharacter.didNotActAsWished',
      'I recognised an opportunity to show better character but did not act as I wished.',
    ),
    (
      'ummah.dawahByCharacter.noOpportunity',
      'I had no relevant interaction or opportunity today.',
    ),
  ],
  'ummah.supportedOppressed': [
    (
      'ummah.supportedOppressed.practicalHelp',
      'I provided practical help through a lawful, appropriate channel.',
    ),
    (
      'ummah.supportedOppressed.spokeVerified',
      'I spoke up or shared verified information responsibly.',
    ),
    (
      'ummah.supportedOppressed.madeDua',
      'I made du’a for people facing oppression.',
    ),
    (
      'ummah.supportedOppressed.didNotAct',
      'I recognised a way to help but did not act today.',
    ),
    (
      'ummah.supportedOppressed.noOpportunity',
      'I had no relevant opportunity beyond private concern today.',
    ),
  ],
  'ummah.unityEfforts': [
    (
      'ummah.unityEfforts.reconciled',
      'I helped reconcile a disagreement or reduce tension.',
    ),
    (
      'ummah.unityEfforts.cooperated',
      'I cooperated constructively across differences.',
    ),
    (
      'ummah.unityEfforts.avoidedDivisiveSpeech',
      'I avoided divisive or harmful speech when disagreement arose.',
    ),
    (
      'ummah.unityEfforts.noConstructiveResponse',
      'I noticed a division but did not find a constructive response today.',
    ),
    (
      'ummah.unityEfforts.noOpportunity',
      'I had no relevant opportunity today.',
    ),
  ],
  'ummah.prayedForUmmah': [
    (
      'ummah.prayedForUmmah.specificDua',
      'I made a specific du’a for the Ummah or people in need.',
    ),
    (
      'ummah.prayedForUmmah.includedRegular',
      'I included the wider Muslim community in my regular du’a.',
    ),
    (
      'ummah.prayedForUmmah.intendedDidNotRecall',
      'I intended to make du’a but did not recall doing so.',
    ),
    (
      'ummah.prayedForUmmah.didNotRecall',
      'I did not recall making such du’a today.',
    ),
  ],
  'ummah.earthCare': [
    (
      'ummah.earthCare.reducedWaste',
      'I reduced avoidable waste or pollution.',
    ),
    (
      'ummah.earthCare.conservedResources',
      'I conserved water, energy or other resources.',
    ),
    (
      'ummah.earthCare.caredForPlace',
      'I cared for a shared space, plant, animal or local environment.',
    ),
    (
      'ummah.earthCare.didNotAct',
      'I noticed an opportunity to reduce harm but did not act today.',
    ),
    (
      'ummah.earthCare.noOpportunity',
      'I had no relevant opportunity today.',
    ),
  ],
};

TernaryOutcome _ternaryForKind(UmmahResponseKind kind) {
  return switch (kind) {
    UmmahResponseKind.unanswered => TernaryOutcome.unanswered,
    _ => TernaryOutcome.positive,
  };
}

ActivityOption _option(String id, String label) {
  final kind = ummahKindFor(id) ?? UmmahResponseKind.unanswered;
  return ActivityOption(
    id: id,
    label: label,
    ternary: _ternaryForKind(kind),
  );
}

List<ActivityOption> ummahCatalogFor(String storageKey) {
  final rows = _ummahResponseLabels[storageKey];
  if (rows == null) return const [];
  return [
    for (final row in rows) _option(row.$1, row.$2),
    _option(UmmahObservationIds.preferNot, 'Prefer not to record.'),
    const ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Unanswered',
      ternary: TernaryOutcome.unanswered,
    ),
  ];
}

List<ActivityOption> get ummahLegendCatalog => [
  for (final id in [...UmmahObservationIds.ordered, ActivityIds.unanswered])
    ActivityOption(
      id: id,
      label: ummahLegendLabels[id] ?? id,
      ternary: _ternaryForKind(
        ummahKindFor(id) ?? UmmahResponseKind.unanswered,
      ),
    ),
];

UmmahResponseKind? ummahKindFor(String activityId) => _ummahKindById[activityId];

String ummahPrimaryLabel(String storageKey, String activityId) {
  for (final option in ummahCatalogFor(storageKey)) {
    if (option.id == activityId) return option.label;
  }
  return ummahLegendLabels[activityId] ?? 'Unanswered';
}

UmmahPracticeCapture readUmmahPractice(
  DailyCheckIn record,
  String storageKey,
) {
  return UmmahPracticeCapture(primaryId: record.activityFor(storageKey).id);
}

DailyCheckIn writeUmmahPractice(
  DailyCheckIn record,
  String storageKey,
  UmmahPracticeCapture capture,
) {
  return record
      .withHomeTraceActivity(
        storageKey,
        RecordedActivity(id: capture.primaryId),
      )
      .withHomeTraceFactors(storageKey, const SalahFactorCapture());
}

String ummahEvidenceValue(DailyCheckIn record, String storageKey) {
  final capture = readUmmahPractice(record, storageKey);
  if (!capture.isPrimaryRecorded) {
    if (record.homeTrace(storageKey).isRecorded) return 'Recorded';
    return 'Unanswered';
  }
  return ummahPrimaryLabel(storageKey, capture.primaryId);
}

String? ummahEvidenceNote(DailyCheckIn record, String storageKey) => null;
