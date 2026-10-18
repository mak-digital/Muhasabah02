import 'date_key.dart';
import 'hajj_planning.dart';

const kHajjHorizonOptions = [6, 9, 12];

int clampHajjHorizonMonths(int? months) {
  if (months == 9 || months == 12) return months!;
  return 6;
}

DateTime? tryParseHajjDate(String? key) {
  if (key == null || key.isEmpty) return null;
  try {
    return parseDateKey(key);
  } catch (_) {
    return null;
  }
}

final _hajjDateKeyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

bool isValidHajjDateKey(String? value) {
  final trimmed = value?.trim() ?? '';
  if (!_hajjDateKeyPattern.hasMatch(trimmed)) return false;
  final parsed = tryParseHajjDate(trimmed);
  if (parsed == null) return false;
  return dateKey(parsed) == trimmed;
}

bool isOptionalHajjDateKey(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return true;
  return isValidHajjDateKey(trimmed);
}

List<String> hajjMilestoneStoredDates(HajjMilestone milestone) {
  return [
    for (final key in [
      milestone.officialDeadline,
      milestone.plannedDate,
      milestone.recommendedCompletionDate,
      milestone.recommendedStartDate,
      milestone.internalTargetDate,
    ])
      if (key != null && key.isNotEmpty) key,
  ];
}

enum HajjMilestoneHorizonGroup { inHorizon, past, beyond, unscheduled }

HajjMilestoneHorizonGroup hajjMilestoneHorizonGroup(
  HajjMilestone milestone, {
  required String todayKey,
  required int horizonMonths,
}) {
  final dates = hajjMilestoneStoredDates(milestone);
  if (dates.isEmpty) return HajjMilestoneHorizonGroup.unscheduled;
  final months = clampHajjHorizonMonths(horizonMonths);
  final start = DateTime(
    parseDateKey(todayKey).year,
    parseDateKey(todayKey).month,
    1,
  );
  final firstKey = dateKey(start);
  final lastExclusive = DateTime(start.year, start.month + months, 1);
  final lastKey = dateKey(
    DateTime(lastExclusive.year, lastExclusive.month, lastExclusive.day - 1),
  );
  var anyInHorizon = false;
  var anyPast = false;
  var anyBeyond = false;
  for (final key in dates) {
    if (key.compareTo(firstKey) < 0) {
      anyPast = true;
    } else if (key.compareTo(lastKey) > 0) {
      anyBeyond = true;
    } else {
      anyInHorizon = true;
    }
  }
  if (anyInHorizon) return HajjMilestoneHorizonGroup.inHorizon;
  if (anyPast && !anyBeyond) return HajjMilestoneHorizonGroup.past;
  if (anyBeyond && !anyPast) return HajjMilestoneHorizonGroup.beyond;
  return anyPast
      ? HajjMilestoneHorizonGroup.past
      : HajjMilestoneHorizonGroup.beyond;
}

bool hajjCalendarMonthInitiallyExpanded({
  required String monthKey,
  required String todayKey,
  required List<HajjMilestone> milestones,
}) {
  if (milestones.isNotEmpty) return true;
  return monthKey == todayKey.substring(0, 7);
}

String? _laterDate(String? a, String? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.compareTo(b) >= 0 ? a : b;
}

String? _addDays(String? key, int days) {
  final date = tryParseHajjDate(key);
  if (date == null) return null;
  return dateKey(DateTime(date.year, date.month, date.day + days));
}

/// Recalculates recommended start/completion from official deadline, processing
/// duration, planning float, and prerequisite milestones. Never invents or
/// overwrites [HajjMilestone.officialDeadline].
HajjMilestone recalculateHajjMilestone(
  HajjMilestone milestone, {
  List<HajjMilestone> all = const [],
}) {
  final official = tryParseHajjDate(milestone.officialDeadline);
  String? recommendedCompletion;
  String? recommendedStart;
  if (official != null) {
    final float = milestone.bufferDays ?? 0;
    final processing = milestone.processingDurationDays ?? 0;
    recommendedCompletion = dateKey(
      DateTime(official.year, official.month, official.day - float),
    );
    recommendedStart = dateKey(
      DateTime(
        official.year,
        official.month,
        official.day - float - processing,
      ),
    );
  }
  final byId = {for (final item in all) item.id: item};
  String? dependencyGate;
  for (final id in milestone.dependsOn) {
    if (id == milestone.id) continue;
    final prior = byId[id];
    if (prior == null) continue;
    dependencyGate = _laterDate(
      dependencyGate,
      prior.recommendedCompletionDate ??
          prior.officialDeadline ??
          prior.plannedDate,
    );
  }
  final gatedStart = _addDays(dependencyGate, 1);
  if (gatedStart != null) {
    recommendedStart = _laterDate(recommendedStart, gatedStart);
    final start = recommendedStart;
    if (recommendedCompletion != null &&
        start != null &&
        start.compareTo(recommendedCompletion) > 0) {
      recommendedCompletion = start;
    }
  }
  return HajjMilestone(
    id: milestone.id,
    title: milestone.title,
    dependsOn: milestone.dependsOn,
    travelerIds: milestone.travelerIds,
    plannedDate: milestone.plannedDate,
    plannedDateCertainty: milestone.plannedDateCertainty,
    officialDeadline: milestone.officialDeadline,
    internalTargetDate: milestone.internalTargetDate ?? recommendedCompletion,
    recommendedStartDate: recommendedStart ?? milestone.recommendedStartDate,
    recommendedCompletionDate:
        recommendedCompletion ?? milestone.recommendedCompletionDate,
    bufferDays: milestone.bufferDays,
    processingDurationDays: milestone.processingDurationDays,
    status: milestone.status,
    notes: milestone.notes,
    templateId: milestone.templateId,
  );
}

HajjJourney recalculateJourneyMilestones(HajjJourney journey) {
  var current = journey.milestones;
  for (var i = 0; i < current.length + 1; i++) {
    final next = [
      for (final milestone in current)
        recalculateHajjMilestone(milestone, all: current),
    ];
    var changed = false;
    for (var j = 0; j < next.length; j++) {
      if (next[j].recommendedStartDate != current[j].recommendedStartDate ||
          next[j].recommendedCompletionDate !=
              current[j].recommendedCompletionDate) {
        changed = true;
      }
    }
    current = next;
    if (!changed) break;
  }
  return journey.copyWith(milestones: current);
}

bool hajjWouldCreateDependencyCycle({
  required String milestoneId,
  required Iterable<String> dependsOn,
  required List<HajjMilestone> all,
}) {
  if (dependsOn.contains(milestoneId)) return true;
  final graph = <String, List<String>>{
    for (final item in all)
      item.id: [
        for (final id in (item.id == milestoneId ? dependsOn : item.dependsOn))
          id,
      ],
  };
  graph.putIfAbsent(milestoneId, () => dependsOn.toList());
  final visiting = <String>{};
  final visited = <String>{};
  bool dfs(String node) {
    if (visiting.contains(node)) return true;
    if (visited.contains(node)) return false;
    visiting.add(node);
    for (final next in graph[node] ?? const <String>[]) {
      if (dfs(next)) return true;
    }
    visiting.remove(node);
    visited.add(node);
    return false;
  }

  return dfs(milestoneId);
}

class HajjScheduleConflict {
  const HajjScheduleConflict({
    required this.milestoneId,
    required this.message,
  });

  final String milestoneId;
  final String message;
}

List<HajjScheduleConflict> hajjScheduleConflicts(
  HajjMilestone milestone, {
  required List<HajjMilestone> all,
}) {
  final conflicts = <HajjScheduleConflict>[];
  if (hajjWouldCreateDependencyCycle(
    milestoneId: milestone.id,
    dependsOn: milestone.dependsOn,
    all: all,
  )) {
    conflicts.add(
      HajjScheduleConflict(
        milestoneId: milestone.id,
        message: 'This prerequisite list would loop back to the same milestone. Choose a different order.',
      ),
    );
  }
  final official = milestone.officialDeadline;
  final start = milestone.recommendedStartDate;
  final completion = milestone.recommendedCompletionDate;
  if (official != null && start != null && start.compareTo(official) > 0) {
    conflicts.add(
      HajjScheduleConflict(
        milestoneId: milestone.id,
        message:
            'Suggested start $start is after the official deadline you typed ($official). Processing, float, or a prerequisite may not fit.',
      ),
    );
  }
  if (official != null &&
      completion != null &&
      completion.compareTo(official) > 0) {
    conflicts.add(
      HajjScheduleConflict(
        milestoneId: milestone.id,
        message:
            'Suggested completion $completion is after the official deadline you typed ($official). Official date is unchanged.',
      ),
    );
  }
  if (official != null &&
      milestone.plannedDate != null &&
      milestone.plannedDate!.compareTo(official) > 0) {
    conflicts.add(
      HajjScheduleConflict(
        milestoneId: milestone.id,
        message:
            'Tentative date ${milestone.plannedDate} is after the official deadline you typed ($official).',
      ),
    );
  }
  final byId = {for (final item in all) item.id: item};
  for (final id in milestone.dependsOn) {
    final prior = byId[id];
    if (prior == null) continue;
    final priorDone =
        prior.recommendedCompletionDate ??
        prior.officialDeadline ??
        prior.plannedDate;
    if (priorDone != null &&
        official != null &&
        priorDone.compareTo(official) > 0) {
      conflicts.add(
        HajjScheduleConflict(
          milestoneId: milestone.id,
          message:
              'Prerequisite "${prior.title ?? prior.id}" is scheduled for $priorDone, after this official deadline ($official).',
        ),
      );
    }
  }
  return conflicts;
}

List<HajjScheduleConflict> hajjJourneyConflicts(HajjJourney journey) {
  return [
    for (final milestone in journey.milestones)
      ...hajjScheduleConflicts(milestone, all: journey.milestones),
  ];
}

enum HajjMilestoneAttention { none, upcoming, overdue }

HajjMilestoneAttention hajjMilestoneAttention(
  HajjMilestone milestone, {
  required String todayKey,
}) {
  if (milestone.status == HajjMilestoneStatus.done) {
    return HajjMilestoneAttention.none;
  }
  final due =
      milestone.officialDeadline ??
      milestone.plannedDate ??
      milestone.recommendedCompletionDate;
  if (due == null) return HajjMilestoneAttention.none;
  if (due.compareTo(todayKey) < 0) return HajjMilestoneAttention.overdue;
  final until = parseDateKey(due).difference(parseDateKey(todayKey)).inDays;
  if (until <= 14) return HajjMilestoneAttention.upcoming;
  return HajjMilestoneAttention.none;
}

bool hajjMilestoneDependenciesMet(
  HajjMilestone milestone,
  List<HajjMilestone> all,
) {
  if (milestone.dependsOn.isEmpty) return true;
  final byId = {for (final item in all) item.id: item};
  for (final id in milestone.dependsOn) {
    final prior = byId[id];
    if (prior == null || prior.status != HajjMilestoneStatus.done) {
      return false;
    }
  }
  return true;
}

bool hajjMilestoneIsCritical(HajjMilestone milestone) {
  return milestone.officialDeadline != null &&
      milestone.status != HajjMilestoneStatus.done;
}

List<({String monthKey, List<HajjMilestone> milestones})> hajjCalendarMonths({
  required DateTime from,
  required int horizonMonths,
  required List<HajjMilestone> milestones,
}) {
  final months = clampHajjHorizonMonths(horizonMonths);
  final start = DateTime(from.year, from.month, 1);
  return [
    for (var i = 0; i < months; i++)
      _monthBucket(DateTime(start.year, start.month + i, 1), milestones),
  ];
}

({String monthKey, List<HajjMilestone> milestones}) _monthBucket(
  DateTime month,
  List<HajjMilestone> milestones,
) {
  final prefix =
      '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
  return (
    monthKey: prefix,
    milestones: [
      for (final milestone in milestones)
        if (_fallsInMonth(milestone, prefix)) milestone,
    ],
  );
}

bool _fallsInMonth(HajjMilestone milestone, String yyyyMm) {
  for (final key in [
    milestone.officialDeadline,
    milestone.plannedDate,
    milestone.recommendedCompletionDate,
    milestone.recommendedStartDate,
    milestone.internalTargetDate,
  ]) {
    if (key != null && key.startsWith(yyyyMm)) return true;
  }
  return false;
}

List<HajjMilestone> hajjUpcomingMilestones({
  required List<HajjMilestone> milestones,
  required String todayKey,
}) {
  final ranked = [
    for (final milestone in milestones)
      if (hajjMilestoneAttention(milestone, todayKey: todayKey) !=
          HajjMilestoneAttention.none)
        milestone,
  ];
  ranked.sort((a, b) {
    final aDue =
        a.officialDeadline ??
        a.plannedDate ??
        a.recommendedCompletionDate ??
        '';
    final bDue =
        b.officialDeadline ??
        b.plannedDate ??
        b.recommendedCompletionDate ??
        '';
    return aDue.compareTo(bDue);
  });
  return ranked;
}
