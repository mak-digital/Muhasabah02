import 'activities.dart';
import 'daily_check_in.dart';
import 'display_calendar.dart';
import 'home_traces.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Descriptive Fasting observation kinds. Not a sawm score, quota,
/// or a ruling on validity, exemption, make-up, or fidyah.
enum FastingResponseKind {
  acted,
  partial,
  difficulty,
  constrained,
  noSituation,
  preferNot,
  unanswered,
}

abstract final class FastingObservationIds {
  static const acted = 'acted';
  static const partialEffort = 'partial_effort';
  static const difficultyRecognised = 'difficulty_recognised';
  static const constrained = 'constrained';
  static const noSituation = 'no_situation';
  static const preferNot = 'prefer_not';

  static const ordered = <String>[
    acted,
    partialEffort,
    difficultyRecognised,
    constrained,
    noSituation,
    preferNot,
  ];
}

class FastingPracticeCapture {
  const FastingPracticeCapture({this.primaryId = ActivityIds.unanswered});

  final String primaryId;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;

  FastingPracticeCapture copyWith({String? primaryId}) {
    return FastingPracticeCapture(primaryId: primaryId ?? this.primaryId);
  }
}

const kFastingRamadanObservedKey = 'fasting.ramadanObserved';
const kFastingRamadanConductKey = 'fasting.ramadanConduct';
const kFastingRamadanAttentionKey = 'fasting.ramadanAttention';
const kFastingRamadanQuranKey = 'fasting.ramadanQuran';
const kFastingRamadanSalahKey = 'fasting.ramadanSalah';
const kFastingRamadanExtraWorshipKey = 'fasting.ramadanExtraWorship';
const kFastingRamadanHabitsKey = 'fasting.ramadanHabits';
const kFastingRamadanPracticeKey = 'fasting.ramadanPractice';
const kFastingWeeklySunnahKey = 'fasting.weeklySunnah';
const kFastingMonthlyKey = 'fasting.monthly';
const kFastingMakeupKey = 'fasting.makeup';
const kFastingRamadanPrepKey = 'fasting.ramadanPrep';
const kFastingPostRamadanKey = 'fasting.postRamadan';

const kFastingBandFastConduct = 'Fast & Conduct';
const kFastingBandFocusedWorship = 'Focused Worship';
const kFastingBandStewardship = 'Stewardship';
const kFastingBandApplication = 'Application';
const kFastingBandVoluntary = 'Voluntary and make-up';

const fastingRamadanStorageKeys = <String>{
  kFastingRamadanObservedKey,
  kFastingRamadanConductKey,
  kFastingRamadanAttentionKey,
  kFastingRamadanQuranKey,
  kFastingRamadanSalahKey,
  kFastingRamadanExtraWorshipKey,
  kFastingRamadanHabitsKey,
  kFastingRamadanPracticeKey,
};

const fastingVoluntaryStorageKeys = <String>{
  kFastingWeeklySunnahKey,
  kFastingMonthlyKey,
  kFastingMakeupKey,
  kFastingRamadanPrepKey,
  kFastingPostRamadanKey,
};

const fastingTernaryStorageKeys = <String>{
  kFastingWeeklySunnahKey,
  kFastingMonthlyKey,
  kFastingMakeupKey,
};

int clampRamadanCalendarOffsetDays(int value) {
  if (value < -1) return -1;
  if (value > 1) return 1;
  return value;
}

bool isFastingRamadanTrace(String storageKey) =>
    fastingRamadanStorageKeys.contains(storageKey);

bool isFastingVoluntaryTrace(String storageKey) =>
    fastingVoluntaryStorageKeys.contains(storageKey);

bool isFastingPracticeTrace(String storageKey) =>
    storageKey.startsWith('fasting.') &&
    !fastingTernaryStorageKeys.contains(storageKey);

const fastingLegendLabels = <String, String>{
  FastingObservationIds.acted: 'Beneficial fasting or worship observed',
  FastingObservationIds.partialEffort: 'In progress, partial, or redirected',
  FastingObservationIds.difficultyRecognised:
      'A lapse, interruption, or missed opportunity recognised',
  FastingObservationIds.constrained:
      'Exemption, inability, or necessary duties',
  FastingObservationIds.noSituation: 'No particular situation today',
  FastingObservationIds.preferNot: 'Prefer not to record',
  ActivityIds.unanswered: 'Not recorded',
};

const _fastingKindById = <String, FastingResponseKind>{
  FastingObservationIds.acted: FastingResponseKind.acted,
  FastingObservationIds.partialEffort: FastingResponseKind.partial,
  FastingObservationIds.difficultyRecognised: FastingResponseKind.difficulty,
  FastingObservationIds.constrained: FastingResponseKind.constrained,
  FastingObservationIds.noSituation: FastingResponseKind.noSituation,
  FastingObservationIds.preferNot: FastingResponseKind.preferNot,
  ActivityIds.unanswered: FastingResponseKind.unanswered,
  'fasting.ramadanObserved.completed': FastingResponseKind.acted,
  'fasting.ramadanObserved.inProgress': FastingResponseKind.partial,
  'fasting.ramadanObserved.exemption': FastingResponseKind.constrained,
  'fasting.ramadanObserved.interrupted': FastingResponseKind.difficulty,
  'fasting.ramadanObserved.otherReason': FastingResponseKind.difficulty,
  'fasting.ramadanConduct.restrained': FastingResponseKind.acted,
  'fasting.ramadanConduct.respondedWithRestraint': FastingResponseKind.partial,
  'fasting.ramadanConduct.slippedCorrected': FastingResponseKind.difficulty,
  'fasting.ramadanConduct.noticedUnaddressed': FastingResponseKind.difficulty,
  'fasting.ramadanConduct.noChallenge': FastingResponseKind.noSituation,
  'fasting.ramadanAttention.setPriorities': FastingResponseKind.acted,
  'fasting.ramadanAttention.reducedMedia': FastingResponseKind.partial,
  'fasting.ramadanAttention.redirected': FastingResponseKind.partial,
  'fasting.ramadanAttention.uncorrected': FastingResponseKind.difficulty,
  'fasting.ramadanAttention.necessaryDuties': FastingResponseKind.constrained,
  'fasting.ramadanQuran.recitedReflected': FastingResponseKind.acted,
  'fasting.ramadanQuran.studied': FastingResponseKind.partial,
  'fasting.ramadanQuran.applied': FastingResponseKind.acted,
  'fasting.ramadanQuran.listenedLimitedStudy': FastingResponseKind.partial,
  'fasting.ramadanQuran.intendedDidNot': FastingResponseKind.difficulty,
  'fasting.ramadanSalah.deliberateAttention': FastingResponseKind.acted,
  'fasting.ramadanSalah.practicalImprovement': FastingResponseKind.partial,
  'fasting.ramadanSalah.refocused': FastingResponseKind.partial,
  'fasting.ramadanSalah.shortcomingRecognised': FastingResponseKind.difficulty,
  'fasting.ramadanSalah.circumstance': FastingResponseKind.constrained,
  'fasting.ramadanExtraWorship.taraweehQiyam': FastingResponseKind.acted,
  'fasting.ramadanExtraWorship.duaDhikr': FastingResponseKind.acted,
  'fasting.ramadanExtraWorship.usedOpportunity': FastingResponseKind.partial,
  'fasting.ramadanExtraWorship.intendedCouldNot':
      FastingResponseKind.constrained,
  'fasting.ramadanExtraWorship.choseDistraction':
      FastingResponseKind.difficulty,
  'fasting.ramadanHabits.plannedWellbeing': FastingResponseKind.acted,
  'fasting.ramadanHabits.moderation': FastingResponseKind.partial,
  'fasting.ramadanHabits.adjustedRoutine': FastingResponseKind.partial,
  'fasting.ramadanHabits.excessRecognised': FastingResponseKind.difficulty,
  'fasting.ramadanHabits.constrained': FastingResponseKind.constrained,
  'fasting.ramadanPractice.actedOnTeaching': FastingResponseKind.acted,
  'fasting.ramadanPractice.improvedHabit': FastingResponseKind.acted,
  'fasting.ramadanPractice.consciousResponsibility':
      FastingResponseKind.partial,
  'fasting.ramadanPractice.identifiedImprovement': FastingResponseKind.partial,
  'fasting.ramadanPractice.noStep': FastingResponseKind.difficulty,
  'fasting.ramadanPrep.plan': FastingResponseKind.acted,
  'fasting.ramadanPrep.voluntaryFast': FastingResponseKind.acted,
  'fasting.ramadanPrep.studyArrangements': FastingResponseKind.partial,
  'fasting.ramadanPrep.adjustedRoutines': FastingResponseKind.partial,
  'fasting.ramadanPrep.identifiedNotActed': FastingResponseKind.difficulty,
  'fasting.ramadanPrep.noParticular': FastingResponseKind.noSituation,
  'fasting.postRamadan.shawwalOrVoluntary': FastingResponseKind.acted,
  'fasting.postRamadan.maintainedPractice': FastingResponseKind.acted,
  'fasting.postRamadan.continuedHabit': FastingResponseKind.partial,
  'fasting.postRamadan.reviewedMakeup': FastingResponseKind.partial,
  'fasting.postRamadan.reflectedNextStep': FastingResponseKind.partial,
  'fasting.postRamadan.noParticular': FastingResponseKind.noSituation,
};

const _fastingResponseLabels = <String, List<(String, String)>>{
  kFastingRamadanObservedKey: [
    ('fasting.ramadanObserved.completed', "Completed today's fast"),
    ('fasting.ramadanObserved.inProgress', 'Fasting today; not yet completed'),
    (
      'fasting.ramadanObserved.exemption',
      'Did not fast due to a recognised exemption or genuine inability',
    ),
    (
      'fasting.ramadanObserved.interrupted',
      'Fast was interrupted or ended early',
    ),
    ('fasting.ramadanObserved.otherReason', 'Did not fast for another reason'),
  ],
  kFastingRamadanConductKey: [
    (
      'fasting.ramadanConduct.restrained',
      'I consciously restrained harmful speech and behaviour',
    ),
    (
      'fasting.ramadanConduct.respondedWithRestraint',
      'I faced provocation and responded with restraint',
    ),
    (
      'fasting.ramadanConduct.slippedCorrected',
      'I slipped but recognised it and sought to correct myself',
    ),
    (
      'fasting.ramadanConduct.noticedUnaddressed',
      'I noticed conduct needing improvement but did not address it',
    ),
    (
      'fasting.ramadanConduct.noChallenge',
      'I had no particular challenging interaction today',
    ),
  ],
  kFastingRamadanAttentionKey: [
    (
      'fasting.ramadanAttention.setPriorities',
      'I set priorities and kept avoidable distractions limited',
    ),
    (
      'fasting.ramadanAttention.reducedMedia',
      'I reduced unnecessary social media, TV or browsing',
    ),
    (
      'fasting.ramadanAttention.redirected',
      'I noticed distraction and redirected my attention',
    ),
    (
      'fasting.ramadanAttention.uncorrected',
      'I spent avoidable time on distractions without correcting course',
    ),
    (
      'fasting.ramadanAttention.necessaryDuties',
      'My time was largely occupied by necessary work or care duties',
    ),
  ],
  kFastingRamadanQuranKey: [
    (
      'fasting.ramadanQuran.recitedReflected',
      'I recited and reflected on its meaning',
    ),
    ('fasting.ramadanQuran.studied', 'I studied a passage or its explanation'),
    (
      'fasting.ramadanQuran.applied',
      'I applied or acted upon something I learned',
    ),
    (
      'fasting.ramadanQuran.listenedLimitedStudy',
      'I recited or listened attentively, with limited opportunity for study',
    ),
    (
      'fasting.ramadanQuran.intendedDidNot',
      'I intended to engage but did not make time',
    ),
  ],
  kFastingRamadanSalahKey: [
    (
      'fasting.ramadanSalah.deliberateAttention',
      'I prayed with deliberate attention and care',
    ),
    (
      'fasting.ramadanSalah.practicalImprovement',
      'I made a practical improvement in punctuality or preparation',
    ),
    (
      'fasting.ramadanSalah.refocused',
      'I noticed distraction in prayer and worked to refocus',
    ),
    (
      'fasting.ramadanSalah.shortcomingRecognised',
      'I recognised a shortcoming needing attention',
    ),
    (
      'fasting.ramadanSalah.circumstance',
      'My prayer practice was affected by a relevant circumstance',
    ),
  ],
  kFastingRamadanExtraWorshipKey: [
    (
      'fasting.ramadanExtraWorship.taraweehQiyam',
      'I performed Taraweeh, Qiyam or other voluntary prayer',
    ),
    (
      'fasting.ramadanExtraWorship.duaDhikr',
      "I devoted focused time to du'a, dhikr or remembrance",
    ),
    (
      'fasting.ramadanExtraWorship.usedOpportunity',
      'I used an available opportunity for extra worship',
    ),
    (
      'fasting.ramadanExtraWorship.intendedCouldNot',
      'I intended extra worship but could not manage it',
    ),
    (
      'fasting.ramadanExtraWorship.choseDistraction',
      'I recognised an opportunity but chose avoidable distraction',
    ),
  ],
  kFastingRamadanHabitsKey: [
    (
      'fasting.ramadanHabits.plannedWellbeing',
      'I planned sleep, suhur, iftar and duties to sustain wellbeing',
    ),
    (
      'fasting.ramadanHabits.moderation',
      'I ate and rested with moderation and consideration',
    ),
    (
      'fasting.ramadanHabits.adjustedRoutine',
      'I adjusted my routine responsibly around work or family needs',
    ),
    (
      'fasting.ramadanHabits.excessRecognised',
      'I recognised avoidable excess or a routine that impaired focus',
    ),
    (
      'fasting.ramadanHabits.constrained',
      'Health, access or other circumstances constrained my routine',
    ),
  ],
  kFastingRamadanPracticeKey: [
    (
      'fasting.ramadanPractice.actedOnTeaching',
      "I acted on a Qur'anic or Prophetic teaching today",
    ),
    (
      'fasting.ramadanPractice.improvedHabit',
      'I improved a personal habit or repaired a wrong',
    ),
    (
      'fasting.ramadanPractice.consciousResponsibility',
      'I fulfilled a responsibility with a more conscious intention',
    ),
    (
      'fasting.ramadanPractice.identifiedImprovement',
      'I identified a concrete improvement to pursue',
    ),
    (
      'fasting.ramadanPractice.noStep',
      'I recognised a needed change but took no step today',
    ),
  ],
  kFastingRamadanPrepKey: [
    (
      'fasting.ramadanPrep.plan',
      'I prepared a realistic worship and responsibilities plan',
    ),
    (
      'fasting.ramadanPrep.voluntaryFast',
      'I practised voluntary fasting where appropriate, including Sha‘ban',
    ),
    (
      'fasting.ramadanPrep.studyArrangements',
      'I prepared Qur’an study, prayer or learning arrangements',
    ),
    (
      'fasting.ramadanPrep.adjustedRoutines',
      'I adjusted sleep, meals, work or family routines in advance',
    ),
    (
      'fasting.ramadanPrep.identifiedNotActed',
      'I identified preparations but have not yet acted',
    ),
    (
      'fasting.ramadanPrep.noParticular',
      'No particular preparation action today',
    ),
  ],
  kFastingPostRamadanKey: [
    (
      'fasting.postRamadan.shawwalOrVoluntary',
      'I observed a voluntary fast, including a Shawwal fast where applicable',
    ),
    (
      'fasting.postRamadan.maintainedPractice',
      'I maintained a sustainable Qur’an, Salah or remembrance practice',
    ),
    (
      'fasting.postRamadan.continuedHabit',
      'I continued a beneficial habit or service begun in Ramadan',
    ),
    (
      'fasting.postRamadan.reviewedMakeup',
      'I reviewed outstanding make-up obligations or planned appropriate action',
    ),
    (
      'fasting.postRamadan.reflectedNextStep',
      'I reflected on Ramadan and identified a practical next step',
    ),
    (
      'fasting.postRamadan.noParticular',
      'No particular post-Ramadan action today',
    ),
  ],
};

TernaryOutcome _ternaryForKind(FastingResponseKind kind) {
  return switch (kind) {
    FastingResponseKind.unanswered => TernaryOutcome.unanswered,
    _ => TernaryOutcome.positive,
  };
}

ActivityOption _option(String id, String label) {
  final kind = fastingKindFor(id) ?? FastingResponseKind.unanswered;
  return ActivityOption(id: id, label: label, ternary: _ternaryForKind(kind));
}

List<ActivityOption> fastingCatalogFor(String storageKey) {
  final rows = _fastingResponseLabels[storageKey];
  if (rows == null) return const [];
  return [
    const ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Not recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    for (final row in rows) _option(row.$1, row.$2),
    _option(FastingObservationIds.preferNot, 'Prefer not to record'),
  ];
}

List<ActivityOption> get fastingLegendCatalog => [
  for (final id in [ActivityIds.unanswered, ...FastingObservationIds.ordered])
    ActivityOption(
      id: id,
      label: fastingLegendLabels[id] ?? id,
      ternary: _ternaryForKind(
        fastingKindFor(id) ?? FastingResponseKind.unanswered,
      ),
    ),
];

FastingResponseKind? fastingKindFor(String activityId) =>
    _fastingKindById[activityId];

String fastingPrimaryLabel(String storageKey, String activityId) {
  for (final option in fastingCatalogFor(storageKey)) {
    if (option.id == activityId) return option.label;
  }
  return fastingLegendLabels[activityId] ?? 'Not recorded';
}

FastingPracticeCapture readFastingPractice(
  DailyCheckIn record,
  String storageKey,
) {
  return FastingPracticeCapture(primaryId: record.activityFor(storageKey).id);
}

DailyCheckIn writeFastingPractice(
  DailyCheckIn record,
  String storageKey,
  FastingPracticeCapture capture,
) {
  return record
      .withHomeTraceActivity(
        storageKey,
        RecordedActivity(id: capture.primaryId),
      )
      .withHomeTraceFactors(storageKey, const SalahFactorCapture());
}

String fastingEvidenceValue(DailyCheckIn record, String storageKey) {
  if (!isFastingPracticeTrace(storageKey)) {
    final outcome = record.homeTrace(storageKey);
    if (!outcome.isRecorded) return 'Unanswered';
    return traceOutcomeLabel(storageKey, outcome);
  }
  final capture = readFastingPractice(record, storageKey);
  if (!capture.isPrimaryRecorded) {
    if (record.homeTrace(storageKey).isRecorded) return 'Recorded';
    return 'Not recorded';
  }
  return fastingPrimaryLabel(storageKey, capture.primaryId);
}

String? fastingEvidenceNote(DailyCheckIn record, String storageKey) => null;

bool recordHasFastingRamadan(DailyCheckIn record) =>
    _recordHasFastingKeys(record, fastingRamadanStorageKeys);

bool recordHasFastingVoluntary(DailyCheckIn record) =>
    _recordHasFastingKeys(record, fastingVoluntaryStorageKeys);

bool _recordHasFastingKeys(DailyCheckIn record, Set<String> keys) {
  for (final key in keys) {
    if (record.homeTrace(key).isRecorded) return true;
    final id = record.activities[key]?.id;
    if (id != null && id.isNotEmpty && id != ActivityIds.unanswered) {
      return true;
    }
  }
  return false;
}

class FastingSeasonGate {
  const FastingSeasonGate({
    required this.showRamadan,
    required this.showVoluntary,
  });

  final bool showRamadan;
  final bool showVoluntary;
}

/// Ramadan rows in Ramadan, voluntary rows outside it.
/// [showHistory] forces both for review. Leftover marks still show.
FastingSeasonGate fastingSeasonGate({
  required DateTime date,
  int offsetDays = 0,
  bool showHistory = false,
  Iterable<DateTime> extraDates = const [],
  Iterable<DailyCheckIn> records = const [],
}) {
  if (showHistory) {
    return const FastingSeasonGate(showRamadan: true, showVoluntary: true);
  }
  final days = extraDates.isEmpty ? <DateTime>[date] : extraDates;
  var showRamadan = false;
  var showVoluntary = false;
  for (final day in days) {
    if (isCivilRamadan(day, offsetDays: offsetDays)) {
      showRamadan = true;
    } else {
      showVoluntary = true;
    }
  }
  for (final record in records) {
    if (recordHasFastingRamadan(record)) showRamadan = true;
    if (recordHasFastingVoluntary(record)) showVoluntary = true;
  }
  return FastingSeasonGate(
    showRamadan: showRamadan,
    showVoluntary: showVoluntary,
  );
}

bool showsFastingRamadanRows({
  required DateTime date,
  int offsetDays = 0,
  bool showHistory = false,
  Iterable<DateTime> extraDates = const [],
  Iterable<DailyCheckIn> records = const [],
}) {
  return fastingSeasonGate(
    date: date,
    offsetDays: offsetDays,
    showHistory: showHistory,
    extraDates: extraDates,
    records: records,
  ).showRamadan;
}

List<HomeTraceRow> gateFastingHomeRows(
  List<HomeTraceRow> rows, {
  FastingSeasonGate? season,
  bool showRamadan = false,
  bool showVoluntary = true,
}) {
  final gate =
      season ??
      FastingSeasonGate(showRamadan: showRamadan, showVoluntary: showVoluntary);
  return [
    for (final row in rows)
      if (_keepFastingSeasonRow(row.storageKey, gate)) row,
  ];
}

List<HomeTraceRow> gatedFastingHomeRows(
  List<HomeTraceRow> rows, {
  required DateTime date,
  int offsetDays = 0,
  bool showHistory = false,
  Iterable<DateTime> extraDates = const [],
  Iterable<DailyCheckIn> records = const [],
}) {
  return gateFastingHomeRows(
    rows,
    season: fastingSeasonGate(
      date: date,
      offsetDays: offsetDays,
      showHistory: showHistory,
      extraDates: extraDates,
      records: records,
    ),
  );
}

bool _keepFastingSeasonRow(String storageKey, FastingSeasonGate gate) {
  if (isFastingRamadanTrace(storageKey)) return gate.showRamadan;
  if (isFastingVoluntaryTrace(storageKey)) return gate.showVoluntary;
  return true;
}
