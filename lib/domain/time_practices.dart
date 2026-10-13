import 'activities.dart';
import 'daily_check_in.dart';
import 'quran.dart';
import 'factor_groups.dart';
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
    required this.contexts,
    required this.outcomes,
  });

  final String practiceId;
  final String storageKey;
  final String sectionId;
  final String band;
  final String sectionQuestion;
  final String label;
  final String detail;
  final String matrixColumn;
  final List<TimeChoice> contexts;
  final List<TimeChoice> outcomes;
}

class TimePracticeCapture {
  const TimePracticeCapture({
    this.primaryId = ActivityIds.unanswered,
    this.contextId = kFactorNotRecorded,
    this.outcomeId = kFactorNotRecorded,
    this.note = '',
  });

  final String primaryId;
  final String contextId;
  final String outcomeId;
  final String note;

  bool get isPrimaryRecorded =>
      primaryId != ActivityIds.unanswered && primaryId.isNotEmpty;
}

const timePractices = <TimePractice>[
  TimePractice(
    practiceId: 'time_t01',
    storageKey: 'time.t01',
    sectionId: kTimeIntentionSectionId,
    band: kTimeIntentionBand,
    sectionQuestion: 'Did I approach my time with purpose?',
    label: 'Began with a worthwhile intention',
    detail: 'Recognised a beneficial purpose before starting an activity, whether worship, work, study, family care or daily responsibility.',
    matrixColumn: 'Intention',
    contexts: [
      TimeChoice(id: 'worship', label: 'Worship'),
      TimeChoice(id: 'workStudy', label: 'Work or study'),
      TimeChoice(id: 'family', label: 'Family'),
      TimeChoice(id: 'other', label: 'Other'),
    ],
    outcomes: [
      TimeChoice(
        id: 'recalledBefore',
        label: 'Intention recalled before starting',
      ),
      TimeChoice(id: 'recalledDuring', label: 'Recalled during activity'),
      TimeChoice(id: 'notRecalled', label: 'Not recalled'),
    ],
  ),
  TimePractice(
    practiceId: 'time_t02',
    storageKey: 'time.t02',
    sectionId: kTimeIntentionSectionId,
    band: kTimeIntentionBand,
    sectionQuestion: 'Did I approach my time with purpose?',
    label: 'Chose what mattered first',
    detail: 'Identified an important responsibility or beneficial activity and gave it appropriate priority over something less important.',
    matrixColumn: 'Priority',
    contexts: [
      TimeChoice(id: 'responsibility', label: 'Responsibility'),
      TimeChoice(id: 'beneficialOpportunity', label: 'Beneficial opportunity'),
      TimeChoice(id: 'competingActivities', label: 'Competing activities'),
    ],
    outcomes: [
      TimeChoice(id: 'prioritised', label: 'Important activity prioritised'),
      TimeChoice(id: 'partlyPrioritised', label: 'Partly prioritised'),
      TimeChoice(id: 'deferred', label: 'Deferred'),
    ],
  ),
  TimePractice(
    practiceId: 'time_t03',
    storageKey: 'time.t03',
    sectionId: kTimeAttentionSectionId,
    band: kTimeAttentionBand,
    sectionQuestion: 'Did I give proper attention to what mattered?',
    label: 'Gave focused attention',
    detail: 'Stayed meaningfully engaged with a task, conversation, learning activity or act of worship, or returned attention after noticing it had wandered.',
    matrixColumn: 'Focus',
    contexts: [
      TimeChoice(id: 'worship', label: 'Worship'),
      TimeChoice(id: 'workStudy', label: 'Work or study'),
      TimeChoice(id: 'conversation', label: 'Conversation'),
      TimeChoice(id: 'other', label: 'Other'),
    ],
    outcomes: [
      TimeChoice(id: 'maintained', label: 'Attention maintained'),
      TimeChoice(id: 'restored', label: 'Attention restored'),
      TimeChoice(id: 'frequentlyDistracted', label: 'Frequently distracted'),
    ],
  ),
  TimePractice(
    practiceId: 'time_t04',
    storageKey: 'time.t04',
    sectionId: kTimeAttentionSectionId,
    band: kTimeAttentionBand,
    sectionQuestion: 'Did I give proper attention to what mattered?',
    label: 'Put aside a digital distraction',
    detail: 'Resisted or interrupted unnecessary scrolling, notifications, device checking or other digital interruptions.',
    matrixColumn: 'Digital',
    contexts: [
      TimeChoice(id: 'socialMedia', label: 'Social media'),
      TimeChoice(id: 'notifications', label: 'Notifications'),
      TimeChoice(id: 'entertainment', label: 'Entertainment'),
      TimeChoice(id: 'repeatedChecking', label: 'Repeated checking'),
      TimeChoice(id: 'other', label: 'Other'),
    ],
    outcomes: [
      TimeChoice(id: 'avoided', label: 'Avoided interruption'),
      TimeChoice(id: 'stoppedAfterStarting', label: 'Stopped after starting'),
      TimeChoice(id: 'continued', label: 'Continued'),
    ],
  ),
  TimePractice(
    practiceId: 'time_t05',
    storageKey: 'time.t05',
    sectionId: kTimeActionSectionId,
    band: kTimeActionBand,
    sectionQuestion: 'Did I turn available time into beneficial action?',
    label: 'Took a step on something delayed',
    detail: 'Started or advanced a worthwhile task that had been unnecessarily postponed.',
    matrixColumn: 'Delayed',
    contexts: [
      TimeChoice(id: 'workStudy', label: 'Work or study'),
      TimeChoice(id: 'personalDuty', label: 'Personal duty'),
      TimeChoice(id: 'family', label: 'Family'),
      TimeChoice(id: 'other', label: 'Other'),
    ],
    outcomes: [
      TimeChoice(id: 'started', label: 'Started'),
      TimeChoice(id: 'madeProgress', label: 'Made progress'),
      TimeChoice(id: 'completed', label: 'Completed'),
      TimeChoice(id: 'stillPostponed', label: 'Still postponed'),
    ],
  ),
  TimePractice(
    practiceId: 'time_t06',
    storageKey: 'time.t06',
    sectionId: kTimeActionSectionId,
    band: kTimeActionBand,
    sectionQuestion: 'Did I turn available time into beneficial action?',
    label: 'Used time for something beneficial',
    detail: 'Consciously used an opportunity for learning, service, useful work, worship or another legitimate benefit.',
    matrixColumn: 'Benefit',
    contexts: [
      TimeChoice(id: 'learning', label: 'Learning'),
      TimeChoice(id: 'service', label: 'Service'),
      TimeChoice(id: 'work', label: 'Work'),
      TimeChoice(id: 'worship', label: 'Worship'),
      TimeChoice(id: 'other', label: 'Other'),
    ],
    outcomes: [
      TimeChoice(id: 'completed', label: 'Meaningful action completed'),
      TimeChoice(id: 'usefulProgress', label: 'Useful progress made'),
      TimeChoice(id: 'unused', label: 'Opportunity unused'),
    ],
  ),
  TimePractice(
    practiceId: 'time_t07',
    storageKey: 'time.t07',
    sectionId: kTimeBalanceSectionId,
    band: kTimeBalanceBand,
    sectionQuestion:
        'Did I respect the rights of others and my own need for recovery?',
    label: 'Gave someone needed attention',
    detail: 'Made appropriate time for a family member, colleague, neighbour or another person with a legitimate need.',
    matrixColumn: 'Others',
    contexts: [
      TimeChoice(id: 'family', label: 'Family'),
      TimeChoice(id: 'friends', label: 'Friends'),
      TimeChoice(id: 'colleagues', label: 'Colleagues'),
      TimeChoice(id: 'community', label: 'Community'),
      TimeChoice(id: 'other', label: 'Other'),
    ],
    outcomes: [
      TimeChoice(id: 'gaveAttention', label: 'Gave needed attention'),
      TimeChoice(id: 'partlyAttended', label: 'Partly attended'),
      TimeChoice(id: 'couldNotAttend', label: 'Could not attend'),
    ],
  ),
  TimePractice(
    practiceId: 'time_t08',
    storageKey: 'time.t08',
    sectionId: kTimeBalanceSectionId,
    band: kTimeBalanceBand,
    sectionQuestion:
        'Did I respect the rights of others and my own need for recovery?',
    label: 'Took needed rest',
    detail: 'Allowed suitable sleep, recovery or restorative breaks rather than unnecessarily neglecting the body\'s needs.',
    matrixColumn: 'Rest',
    contexts: [
      TimeChoice(id: 'sleep', label: 'Sleep'),
      TimeChoice(id: 'breakRest', label: 'Break'),
      TimeChoice(id: 'physicalRecovery', label: 'Physical recovery'),
      TimeChoice(id: 'mentalRecovery', label: 'Mental recovery'),
    ],
    outcomes: [
      TimeChoice(id: 'sufficient', label: 'Rest was sufficient'),
      TimeChoice(id: 'partial', label: 'Rest was partial'),
      TimeChoice(id: 'missed', label: 'Needed rest was missed'),
    ],
  ),
];

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

String timePrimaryLabel(String activityId) {
  for (final option in ActivityCatalog.timeObservation) {
    if (option.id == activityId) return option.label;
  }
  return 'Unanswered';
}

String? timeChoiceLabel(List<TimeChoice> choices, String id) {
  if (id.isEmpty || id == kFactorNotRecorded) return null;
  for (final choice in choices) {
    if (choice.id == id) return choice.label;
  }
  return null;
}

TimePracticeCapture readTimePractice(DailyCheckIn record, String storageKey) {
  final activity = record.activityFor(storageKey);
  final factors =
      record.homeTraceFactors[storageKey] ?? const SalahFactorCapture();
  return TimePracticeCapture(
    primaryId: activity.id,
    contextId: selectedFactorId(factors.supportIds),
    outcomeId: selectedFactorId(factors.challengeIds),
    note: factors.otherText ?? '',
  );
}

DailyCheckIn writeTimePractice(
  DailyCheckIn record,
  String storageKey,
  TimePracticeCapture capture,
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
      challengeIds: idsFromFactorChoice(capture.outcomeId),
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
  return timePrimaryLabel(capture.primaryId);
}

String? timeEvidenceNote(DailyCheckIn record, String storageKey) {
  final practice = timePracticeByKey(storageKey);
  if (practice == null) return null;
  final capture = readTimePractice(record, storageKey);
  if (!capture.isPrimaryRecorded) return null;
  final parts = <String>[];
  final context = timeChoiceLabel(practice.contexts, capture.contextId);
  final outcome = timeChoiceLabel(practice.outcomes, capture.outcomeId);
  if (context != null) parts.add(context);
  if (outcome != null) parts.add(outcome);
  final note = capture.note.trim();
  if (note.isNotEmpty) parts.add(note);
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}
