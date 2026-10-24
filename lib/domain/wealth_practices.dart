import 'activities.dart';
import 'daily_check_in.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Descriptive Wealth observation kinds. Not a money score, halal
/// certification, or spiritual grade. Unique option ids map onto these
/// kinds for colour and marks only.
enum WealthResponseKind {
  cared,
  partial,
  difficulty,
  corrected,
  noSituation,
  preferNot,
  unanswered,
}

abstract final class WealthObservationIds {
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

class WealthPracticeCapture {
  const WealthPracticeCapture({this.primaryId = ActivityIds.unanswered});

  final String primaryId;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;

  WealthPracticeCapture copyWith({String? primaryId}) {
    return WealthPracticeCapture(primaryId: primaryId ?? this.primaryId);
  }
}

const wealthLegendLabels = <String, String>{
  WealthObservationIds.cared: 'Responsible or lawful action observed',
  WealthObservationIds.partialEffort: 'Checked, clarified, or chose a need',
  WealthObservationIds.difficultyRecognised:
      'Unresolved concern — not a legal ruling',
  WealthObservationIds.corrected: 'Reduced, exited, or fulfilled an obligation',
  WealthObservationIds.noSituation: 'No relevant activity or decision',
  WealthObservationIds.preferNot: 'Prefer not to record',
  ActivityIds.unanswered: 'Unanswered',
};

const _wealthKindById = <String, WealthResponseKind>{
  WealthObservationIds.cared: WealthResponseKind.cared,
  WealthObservationIds.partialEffort: WealthResponseKind.partial,
  WealthObservationIds.difficultyRecognised: WealthResponseKind.difficulty,
  WealthObservationIds.corrected: WealthResponseKind.corrected,
  WealthObservationIds.noSituation: WealthResponseKind.noSituation,
  WealthObservationIds.preferNot: WealthResponseKind.preferNot,
  ActivityIds.unanswered: WealthResponseKind.unanswered,
  'wealth.halalEarning.lawfulSource': WealthResponseKind.cared,
  'wealth.halalEarning.checkedConcern': WealthResponseKind.partial,
  'wealth.halalEarning.avoidedQuestionable': WealthResponseKind.corrected,
  'wealth.halalEarning.unresolvedConcern': WealthResponseKind.difficulty,
  'wealth.halalEarning.noActivity': WealthResponseKind.noSituation,
  'wealth.avoidedRiba.avoidedEntering': WealthResponseKind.cared,
  'wealth.avoidedRiba.reviewedArrangement': WealthResponseKind.partial,
  'wealth.avoidedRiba.reducedOrExited': WealthResponseKind.corrected,
  'wealth.avoidedRiba.unresolvedConcern': WealthResponseKind.difficulty,
  'wealth.avoidedRiba.noTransaction': WealthResponseKind.noSituation,
  'wealth.avoidedWaste.usedCarefully': WealthResponseKind.cared,
  'wealth.avoidedWaste.choseNeed': WealthResponseKind.partial,
  'wealth.avoidedWaste.reducedWaste': WealthResponseKind.corrected,
  'wealth.avoidedWaste.recognisedNotChanged': WealthResponseKind.difficulty,
  'wealth.avoidedWaste.noDecision': WealthResponseKind.noSituation,
  'wealth.lawfulManagement.managedResponsibly': WealthResponseKind.cared,
  'wealth.lawfulManagement.reviewedCommitments': WealthResponseKind.partial,
  'wealth.lawfulManagement.fulfilledObligation': WealthResponseKind.corrected,
  'wealth.lawfulManagement.safeguardedTrust': WealthResponseKind.cared,
  'wealth.lawfulManagement.notYetActed': WealthResponseKind.difficulty,
  'wealth.lawfulManagement.noDecision': WealthResponseKind.noSituation,
};

const _wealthResponseLabels = <String, List<(String, String)>>{
  'wealth.halalEarning': [
    (
      'wealth.halalEarning.lawfulSource',
      'My income or work today came from a source I reasonably understand to be lawful.',
    ),
    (
      'wealth.halalEarning.checkedConcern',
      'I checked or clarified a concern about the lawfulness of an income source.',
    ),
    (
      'wealth.halalEarning.avoidedQuestionable',
      'I recognised a questionable source and avoided or stopped involvement.',
    ),
    (
      'wealth.halalEarning.unresolvedConcern',
      'I recognised a concern about an income source but have not yet resolved it.',
    ),
    (
      'wealth.halalEarning.noActivity',
      'I had no income-earning activity or relevant decision today.',
    ),
  ],
  'wealth.avoidedRiba': [
    (
      'wealth.avoidedRiba.avoidedEntering',
      'I avoided entering a transaction involving prohibited riba.',
    ),
    (
      'wealth.avoidedRiba.reviewedArrangement',
      'I reviewed or clarified whether a financial arrangement involved riba.',
    ),
    (
      'wealth.avoidedRiba.reducedOrExited',
      'I took a practical step to reduce or exit an arrangement involving riba.',
    ),
    (
      'wealth.avoidedRiba.unresolvedConcern',
      'I recognised a possible riba concern but have not yet addressed it.',
    ),
    (
      'wealth.avoidedRiba.noTransaction',
      'I had no relevant financial transaction or decision today.',
    ),
  ],
  'wealth.avoidedWaste': [
    (
      'wealth.avoidedWaste.usedCarefully',
      'I used money or resources carefully and avoided unnecessary waste.',
    ),
    (
      'wealth.avoidedWaste.choseNeed',
      'I chose a reasonable need over an unnecessary purchase or expense.',
    ),
    (
      'wealth.avoidedWaste.reducedWaste',
      'I reduced or corrected waste after recognising it.',
    ),
    (
      'wealth.avoidedWaste.recognisedNotChanged',
      'I recognised unnecessary waste but did not yet change my behaviour.',
    ),
    (
      'wealth.avoidedWaste.noDecision',
      'I had no relevant spending or resource-use decision today.',
    ),
  ],
  'wealth.lawfulManagement': [
    (
      'wealth.lawfulManagement.managedResponsibly',
      'I managed available money or assets responsibly for legitimate needs and obligations.',
    ),
    (
      'wealth.lawfulManagement.reviewedCommitments',
      'I reviewed my budget, savings, debts or financial commitments and made an appropriate decision.',
    ),
    (
      'wealth.lawfulManagement.fulfilledObligation',
      'I fulfilled a due financial obligation or took a step to protect another person\'s financial right.',
    ),
    (
      'wealth.lawfulManagement.safeguardedTrust',
      'I safeguarded or maintained property, records or resources entrusted to me.',
    ),
    (
      'wealth.lawfulManagement.notYetActed',
      'I recognised a financial responsibility needing attention but have not yet acted.',
    ),
    (
      'wealth.lawfulManagement.noDecision',
      'I had no relevant financial management decision or action today.',
    ),
  ],
};

TernaryOutcome _ternaryForKind(WealthResponseKind kind) {
  return switch (kind) {
    WealthResponseKind.unanswered => TernaryOutcome.unanswered,
    _ => TernaryOutcome.positive,
  };
}

ActivityOption _option(String id, String label) {
  final kind = wealthKindFor(id) ?? WealthResponseKind.unanswered;
  return ActivityOption(id: id, label: label, ternary: _ternaryForKind(kind));
}

List<ActivityOption> wealthCatalogFor(String storageKey) {
  final rows = _wealthResponseLabels[storageKey];
  if (rows == null) return const [];
  return [
    for (final row in rows) _option(row.$1, row.$2),
    _option(WealthObservationIds.preferNot, 'Prefer not to record.'),
    const ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Unanswered',
      ternary: TernaryOutcome.unanswered,
    ),
  ];
}

List<ActivityOption> get wealthLegendCatalog => [
  for (final id in [...WealthObservationIds.ordered, ActivityIds.unanswered])
    ActivityOption(
      id: id,
      label: wealthLegendLabels[id] ?? id,
      ternary: _ternaryForKind(
        wealthKindFor(id) ?? WealthResponseKind.unanswered,
      ),
    ),
];

WealthResponseKind? wealthKindFor(String activityId) =>
    _wealthKindById[activityId];

String wealthPrimaryLabel(String storageKey, String activityId) {
  for (final option in wealthCatalogFor(storageKey)) {
    if (option.id == activityId) return option.label;
  }
  return wealthLegendLabels[activityId] ?? 'Unanswered';
}

WealthPracticeCapture readWealthPractice(
  DailyCheckIn record,
  String storageKey,
) {
  return WealthPracticeCapture(primaryId: record.activityFor(storageKey).id);
}

DailyCheckIn writeWealthPractice(
  DailyCheckIn record,
  String storageKey,
  WealthPracticeCapture capture,
) {
  return record
      .withHomeTraceActivity(
        storageKey,
        RecordedActivity(id: capture.primaryId),
      )
      .withHomeTraceFactors(storageKey, const SalahFactorCapture());
}

String wealthEvidenceValue(DailyCheckIn record, String storageKey) {
  final capture = readWealthPractice(record, storageKey);
  if (!capture.isPrimaryRecorded) {
    if (record.homeTrace(storageKey).isRecorded) return 'Recorded';
    return 'Unanswered';
  }
  return wealthPrimaryLabel(storageKey, capture.primaryId);
}

String? wealthEvidenceNote(DailyCheckIn record, String storageKey) => null;
