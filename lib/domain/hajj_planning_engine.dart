import 'date_key.dart';
import 'hajj_pathway.dart';
import 'hajj_planning.dart';
import 'hajj_planning_math.dart';

const kHajjPlanningEstimateNote =
    'Planning estimate. Not an official requirement unless you typed and verified a deadline.';

const kHajjRitesMustNotBeOmitted =
    'Do not omit required Hajj rites to leave earlier.';

const kHajjUnusedPackageNotRefundable =
    'Unused package services are not assumed refundable.';

enum HajjDocumentAttention { none, missing, expired, needsVerification }

class HajjDocumentNotice {
  const HajjDocumentNotice({
    required this.travelerId,
    required this.kind,
    required this.message,
  });

  final String travelerId;
  final HajjDocumentAttention kind;
  final String message;
}

enum HajjMilestoneDateKind { planningEstimate, officialEntered }

HajjMilestoneDateKind hajjMilestoneDateKind(HajjMilestone milestone) {
  if (milestone.officialDeadline != null &&
      milestone.officialDeadline!.isNotEmpty) {
    return HajjMilestoneDateKind.officialEntered;
  }
  return HajjMilestoneDateKind.planningEstimate;
}

String? hajjPlanningAnchorDate(HajjJourney journey) {
  return journey.intendedDepartureDate ??
      journey.planning.expectedHajjPeriodStart ??
      journey.intendedReturnDate;
}

HajjJourney applyHajjPreparationTemplates(
  HajjJourney journey, {
  DateTime? now,
}) {
  final existingByTemplate = <String, HajjMilestone>{
    for (final milestone in journey.milestones)
      if (milestone.templateId != null) milestone.templateId!: milestone,
  };
  final created = <HajjMilestone>[];
  for (final template in kHajjPreparationTemplates) {
    final previous = existingByTemplate[template.id];
    if (previous != null) {
      created.add(previous);
      continue;
    }
    created.add(
      HajjMilestone(
        id: 'ms_${template.id}_${journey.id}',
        title: template.title,
        templateId: template.id,
        processingDurationDays: template.processingDurationDays,
        bufferDays: template.bufferDays,
        status: HajjMilestoneStatus.pending,
        notes: kHajjPlanningEstimateNote,
      ),
    );
  }
  final byTemplate = <String, String>{
    for (final milestone in created)
      if (milestone.templateId != null) milestone.templateId!: milestone.id,
  };
  final withDeps = [
    for (final milestone in created)
      milestone.copyWith(
        dependsOn: [
          for (final templateId
              in kHajjPreparationTemplates
                  .firstWhere((item) => item.id == milestone.templateId)
                  .dependsOn)
            if (byTemplate[templateId] != null) byTemplate[templateId]!,
        ],
      ),
  ];
  final other = [
    for (final milestone in journey.milestones)
      if (milestone.templateId == null) milestone,
  ];
  var next = journey.copyWith(
    milestones: [...other, ...withDeps],
    planning: journey.planning.copyWith(templatesApplied: true),
  );
  next = _applyTemplateWindows(next, now: now);
  return recalculateJourneyMilestones(next);
}

HajjJourney _applyTemplateWindows(HajjJourney journey, {DateTime? now}) {
  final anchorKey = hajjPlanningAnchorDate(journey);
  if (anchorKey == null) return journey;
  final anchor = tryParseHajjDate(anchorKey);
  if (anchor == null) return journey;
  final templates = {
    for (final template in kHajjPreparationTemplates) template.id: template,
  };
  return journey.copyWith(
    milestones: [
      for (final milestone in journey.milestones)
        _windowFromTemplate(milestone, templates, anchor),
    ],
  );
}

HajjMilestone _windowFromTemplate(
  HajjMilestone milestone,
  Map<String, HajjPreparationTemplate> templates,
  DateTime anchor,
) {
  final template = templates[milestone.templateId];
  if (template == null) return milestone;
  if (milestone.officialDeadline != null) return milestone;
  final completion = dateKey(
    DateTime(
      anchor.year,
      anchor.month,
      anchor.day - template.leadDaysBeforeAnchor,
    ),
  );
  final start = dateKey(
    DateTime(
      anchor.year,
      anchor.month,
      anchor.day -
          template.leadDaysBeforeAnchor -
          template.processingDurationDays,
    ),
  );
  return milestone.copyWith(
    recommendedStartDate: start,
    recommendedCompletionDate: completion,
    internalTargetDate: milestone.internalTargetDate ?? completion,
    notes: milestone.notes ?? kHajjPlanningEstimateNote,
  );
}

bool hajjMilestoneIsLegacyUntitled(HajjMilestone milestone) {
  final title = milestone.title?.trim();
  if (title == null || title.isEmpty) return true;
  return title.toLowerCase() == 'milestone';
}

List<String> hajjCriticalPathIds(List<HajjMilestone> milestones) {
  final usable = [
    for (final item in milestones)
      if (!hajjMilestoneIsLegacyUntitled(item)) item,
  ];
  if (usable.isEmpty) return const [];
  final byId = {for (final item in usable) item.id: item};
  final memo = <String, int>{};
  final via = <String, String?>{};
  int weight(HajjMilestone item) =>
      (item.processingDurationDays ?? 0) + (item.bufferDays ?? 0);
  int longest(String id) {
    if (memo.containsKey(id)) return memo[id]!;
    final item = byId[id];
    if (item == null) {
      memo[id] = 0;
      return 0;
    }
    var best = weight(item);
    String? bestPrior;
    for (final priorId in item.dependsOn) {
      final candidate = longest(priorId) + weight(item);
      if (candidate >= best) {
        best = candidate;
        bestPrior = priorId;
      }
    }
    memo[id] = best;
    via[id] = bestPrior;
    return best;
  }

  var bestId = usable.first.id;
  var bestScore = 0;
  for (final item in usable) {
    final score = longest(item.id);
    if (score > bestScore) {
      bestScore = score;
      bestId = item.id;
    }
  }
  final path = <String>[];
  String? cursor = bestId;
  while (cursor != null) {
    path.add(cursor);
    cursor = via[cursor];
  }
  return path.reversed.toList();
}

bool hajjMilestoneOnCriticalPath(
  HajjMilestone milestone,
  List<HajjMilestone> all,
) {
  return hajjCriticalPathIds(all).contains(milestone.id);
}

bool hajjInsufficientFloat(HajjMilestone milestone) {
  final official = milestone.officialDeadline;
  if (official == null) return false;
  final processing = milestone.processingDurationDays ?? 0;
  final float = milestone.bufferDays ?? 0;
  if (processing + float <= 0) return false;
  final start = milestone.recommendedStartDate;
  if (start == null) return false;
  return start.compareTo(official) > 0 || float < 7;
}

List<HajjScheduleConflict> hajjEngineConflicts(HajjJourney journey) {
  final conflicts = [...hajjJourneyConflicts(journey)];
  for (final milestone in journey.milestones) {
    if (hajjInsufficientFloat(milestone)) {
      conflicts.add(
        HajjScheduleConflict(
          milestoneId: milestone.id,
          message:
              'Planning float may be too short for "${milestone.title ?? milestone.id}". The official deadline you typed is unchanged.',
        ),
      );
    }
  }
  return conflicts;
}

HajjDocumentNotice? hajjTravelerDocumentNotice(
  HajjTravelerProfile traveler, {
  required String todayKey,
}) {
  final passport = traveler.passportExpiryDate;
  if (passport == null || passport.isEmpty) {
    return HajjDocumentNotice(
      travelerId: traveler.id,
      kind: HajjDocumentAttention.missing,
      message:
          'Passport expiry is not recorded for ${traveler.displayName ?? traveler.role.label}. Missing is not a judgment.',
    );
  }
  if (isValidHajjDateKey(passport) && passport.compareTo(todayKey) < 0) {
    return HajjDocumentNotice(
      travelerId: traveler.id,
      kind: HajjDocumentAttention.expired,
      message:
          'Passport expiry $passport is before $todayKey. Confirm a current document yourself.',
    );
  }
  final residence = traveler.residenceExpiryDate;
  if (residence != null &&
      residence.isNotEmpty &&
      isValidHajjDateKey(residence) &&
      residence.compareTo(todayKey) < 0) {
    return HajjDocumentNotice(
      travelerId: traveler.id,
      kind: HajjDocumentAttention.expired,
      message:
          'Residence document expiry $residence is before $todayKey. Confirm a current document yourself.',
    );
  }
  return null;
}

class HajjReturnComparison {
  const HajjReturnComparison({
    required this.kind,
    required this.totalEstimated,
    required this.confirmedRefunds,
    required this.costsEntered,
    required this.restrictions,
    required this.leaveImplications,
    required this.familyCoordination,
    required this.residenceReentry,
  });

  final HajjReturnScenarioKind kind;
  final int totalEstimated;
  final int confirmedRefunds;
  final bool costsEntered;
  final String? restrictions;
  final String? leaveImplications;
  final String? familyCoordination;
  final String? residenceReentry;

  String get costLabel =>
      costsEntered ? 'Estimate $totalEstimated' : 'Not estimated';

  bool get unusedPackageRefundAssumed => false;
  bool get ritesOmissionSuggested => false;
}

int? _optionalReturnTotal(HajjReturnScenario scenario) {
  if (scenario.packageCost == null &&
      scenario.changeFees == null &&
      scenario.extraTransport == null &&
      scenario.extraAccommodation == null &&
      scenario.confirmedRefunds == null) {
    return null;
  }
  return hajjReturnScenarioTotal(scenario);
}

int hajjReturnScenarioTotal(HajjReturnScenario scenario) {
  final package = scenario.packageCost ?? 0;
  final change = scenario.changeFees ?? 0;
  final transport = scenario.extraTransport ?? 0;
  final stay = scenario.extraAccommodation ?? 0;
  final refunds = scenario.confirmedRefunds ?? 0;
  final total = package + change + transport + stay - refunds;
  return total < 0 ? 0 : total;
}

List<HajjReturnComparison> compareHajjReturnScenarios(
  HajjJourneyReturnPlan plan,
) {
  return [
    for (final scenario in [
      plan.standard,
      plan.earlyAfterRites,
      plan.differentCountry,
    ])
      HajjReturnComparison(
        kind: scenario.kind,
        totalEstimated: hajjReturnScenarioTotal(scenario),
        confirmedRefunds: scenario.confirmedRefunds ?? 0,
        costsEntered: _optionalReturnTotal(scenario) != null,
        restrictions: scenario.packageRestrictions,
        leaveImplications: scenario.leaveImplications,
        familyCoordination: scenario.familyCoordination,
        residenceReentry: scenario.residenceReentry,
      ),
  ];
}

class HajjJourneyPlanSummary {
  const HajjJourneyPlanSummary({
    required this.pathways,
    required this.seasonLabel,
    required this.criticalTitles,
    required this.actionWindows,
    required this.officialDeadlines,
    required this.needsConfirmation,
    required this.conflicts,
    required this.estimatedTravelCost,
    required this.readinessAttention,
    required this.unknownRoute,
  });

  final List<HajjPathwayFamily> pathways;
  final String seasonLabel;
  final List<String> criticalTitles;
  final List<String> actionWindows;
  final List<String> officialDeadlines;
  final List<String> needsConfirmation;
  final List<String> conflicts;
  final int? estimatedTravelCost;
  final List<String> readinessAttention;
  final bool unknownRoute;
}

HajjJourneyPlanSummary buildHajjJourneyPlanSummary({
  required HajjJourney journey,
  required List<HajjTravelerProfile> travelers,
  required String todayKey,
}) {
  final confirmed = [
    for (final id in journey.planning.confirmedPathwayIds)
      if (HajjPathwayFamilyX.fromId(id) != null) HajjPathwayFamilyX.fromId(id)!,
  ];
  final unknownRoute =
      !journey.planning.pathwaysConfirmedByUser || confirmed.isEmpty;
  final criticalIds = hajjCriticalPathIds(journey.milestones);
  final byId = {for (final item in journey.milestones) item.id: item};
  return HajjJourneyPlanSummary(
    pathways: confirmed,
    seasonLabel:
        journey.targetSeason.label ??
        (journey.targetSeason.hijriYear != null
            ? 'Season ${journey.targetSeason.hijriYear}'
            : 'Season undecided'),
    criticalTitles: [
      for (final id in criticalIds)
        if (byId[id]?.title != null) byId[id]!.title!,
    ],
    actionWindows: [
      for (final milestone in journey.milestones)
        if (milestone.recommendedStartDate != null &&
            milestone.recommendedCompletionDate != null)
          '${milestone.title ?? milestone.id}: ${milestone.recommendedStartDate}–${milestone.recommendedCompletionDate} (planning estimate)',
    ],
    officialDeadlines: [
      for (final milestone in journey.milestones)
        if (milestone.officialDeadline != null)
          '${milestone.title ?? milestone.id}: ${milestone.officialDeadline} (you typed)',
    ],
    needsConfirmation: [
      if (unknownRoute) 'Planning pathway is not confirmed yet.',
      for (final traveler in travelers)
        if (hajjTravelerDocumentNotice(traveler, todayKey: todayKey) != null)
          hajjTravelerDocumentNotice(traveler, todayKey: todayKey)!.message,
    ],
    conflicts: [
      for (final conflict in hajjEngineConflicts(journey)) conflict.message,
    ],
    estimatedTravelCost: _optionalReturnTotal(journey.returnPlan.selected),
    readinessAttention: [
      for (final item in journey.readiness)
        if (item.status != HajjReadinessStatus.confirmedReady &&
            item.status != HajjReadinessStatus.notApplicable)
          item.title ?? item.id,
    ],
    unknownRoute: unknownRoute,
  );
}
