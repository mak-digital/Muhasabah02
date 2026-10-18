import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/hajj_learning_catalog.dart';
import '../../domain/hajj_pathway.dart';
import '../../domain/hajj_planning.dart';
import '../../domain/hajj_planning_engine.dart';
import '../../domain/hajj_planning_math.dart';
import '../../domain/hajj_readiness_catalog.dart';
import 'hajj_online_assist_panel.dart';
import '../shared/activity_picker.dart';
import '../shared/hajj_standing_editor.dart';

class HajjHomeDashboard extends ConsumerWidget {
  const HajjHomeDashboard({super.key, required this.family});

  final Color family;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(hajjStoreTickProvider);
    final store = ref.watch(hajjStoreRepositoryProvider).store;
    final journey = store.selectedJourney;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HajjStandingEditor(bottomPadding: 8),
        _HajjSummaryCard(
          key: const Key('hajj-journey-card'),
          family: family,
          title: Copy.hajjJourneySection,
          summary: journey == null
              ? 'No plan stored'
              : '${journey.lifecycle.label}${journey.archived ? ' (archived)' : ''}',
          initiallyExpanded: true,
          child: _JourneyBody(store: store),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-plan-summary-card'),
          family: family,
          title: Copy.hajjPlanSummarySection,
          summary: journey == null
              ? 'Opens with a plan'
              : (journey.planning.pathwaysConfirmedByUser
                    ? 'Route confirmed'
                    : 'Route not confirmed'),
          initiallyExpanded: true,
          child: journey == null
              ? const SizedBox.shrink()
              : _PlanSummaryBody(store: store, journey: journey),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-pathway-card'),
          family: family,
          title: Copy.hajjPathwaySection,
          summary: journey == null
              ? 'Opens with a plan'
              : '${journey.planning.confirmedPathwayIds.length} confirmed',
          child: journey == null
              ? const SizedBox.shrink()
              : _PathwayBody(store: store, journey: journey),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-readiness-card'),
          family: family,
          title: Copy.hajjReadinessSection,
          summary: journey == null
              ? 'Opens with a plan'
              : _readinessSummary(journey),
          child: journey == null
              ? Text(
                  Copy.hajjJourneyInvite,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : _ReadinessBody(journey: journey),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-family-card'),
          family: family,
          title: Copy.hajjFamilySection,
          summary: '${store.travelers.length} traveler(s)',
          child: _FamilyBody(store: store),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-return-card'),
          family: family,
          title: Copy.hajjReturnSection,
          summary: journey == null
              ? 'Opens with a plan'
              : journey.returnPlan.selectedKind.label,
          child: journey == null
              ? const SizedBox.shrink()
              : _ReturnBody(journey: journey),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-learning-card'),
          family: family,
          title: Copy.hajjLearningSection,
          summary: 'Always available',
          initiallyExpanded: false,
          child: _LearningBody(store: store),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-after-card'),
          family: family,
          title: Copy.hajjAfterSection,
          summary: store.afterHajj.isEmpty ? 'Optional' : 'Recorded',
          child: _AfterBody(store: store),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-online-card'),
          family: family,
          title: Copy.hajjOnlineSection,
          summary: store.onlineAssist.anyOnline
              ? 'Opted in (revocable)'
              : 'Offline',
          child: HajjOnlineAssistPanel(store: store),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-sources-card'),
          family: family,
          title: Copy.hajjSourcesSection,
          summary: '${store.sources.length} stored',
          child: HajjSourcesBody(store: store),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-providers-card'),
          family: family,
          title: Copy.hajjProvidersSection,
          summary: '${store.providers.length} stored',
          child: HajjProvidersBody(store: store),
        ),
        _HajjSummaryCard(
          key: const Key('hajj-calendar-card'),
          family: family,
          title: Copy.hajjCalendarSection,
          summary: journey == null
              ? 'Opens with a plan'
              : '${clampHajjHorizonMonths(journey.horizonMonths)} months',
          child: journey == null
              ? const SizedBox.shrink()
              : _CalendarBody(journey: journey),
        ),
      ],
    );
  }
}

String _readinessSummary(HajjJourney journey) {
  final confirmed = journey.readiness
      .where((item) => item.status == HajjReadinessStatus.confirmedReady)
      .length;
  return '$confirmed of ${journey.readiness.length} confirmed by you';
}

class _HajjSummaryCard extends StatelessWidget {
  const _HajjSummaryCard({
    super.key,
    required this.family,
    required this.title,
    required this.summary,
    required this.child,
    this.initiallyExpanded = false,
  });

  final Color family;
  final String title;
  final String summary;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: family.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            title: Text(title, style: Theme.of(context).textTheme.titleSmall),
            subtitle: Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyBody extends ConsumerWidget {
  const _JourneyBody({required this.store});

  final HajjStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = store.visibleJourneys;
    if (visible.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copy.hajjJourneyInvite,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('hajj-create-journey'),
            onPressed: () => _openJourneySheet(context, ref),
            child: const Text(Copy.hajjCreateJourney),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final journey in visible)
          ListTile(
            key: Key('hajj-select-journey-${journey.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            selected: store.selectedJourney?.id == journey.id,
            title: Text(
              journey.targetSeason.label ??
                  (journey.targetSeason.hijriYear != null
                      ? 'Season ${journey.targetSeason.hijriYear}'
                      : 'Season undecided'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${journey.lifecycle.label} · ${journey.dateCertainty.label} dates',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => persistHajjStore(
              ref,
              (current) => current.selectJourney(journey.id),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              key: const Key('hajj-edit-journey'),
              onPressed: store.selectedJourney == null
                  ? null
                  : () => _openJourneySheet(
                      context,
                      ref,
                      existing: store.selectedJourney,
                    ),
              child: const Text('Edit plan'),
            ),
            OutlinedButton(
              key: const Key('hajj-create-journey'),
              onPressed: () => _openJourneySheet(context, ref),
              child: const Text('Another plan'),
            ),
            OutlinedButton(
              key: const Key('hajj-archive-journey'),
              onPressed: store.selectedJourney == null
                  ? null
                  : () => persistHajjStore(
                      ref,
                      (current) =>
                          current.archiveJourney(current.selectedJourney!.id),
                    ),
              child: const Text('Archive'),
            ),
            OutlinedButton(
              key: const Key('hajj-apply-templates'),
              onPressed: store.selectedJourney == null
                  ? null
                  : () => persistHajjStore(ref, (current) {
                      final selected = current.selectedJourney;
                      if (selected == null) return current;
                      return current.upsertJourney(
                        applyHajjPreparationTemplates(selected),
                      );
                    }),
              child: const Text(Copy.hajjApplyTemplates),
            ),
            OutlinedButton(
              key: const Key('hajj-delete-journey'),
              onPressed: store.selectedJourney == null
                  ? null
                  : () => persistHajjStore(
                      ref,
                      (current) =>
                          current.deleteJourney(current.selectedJourney!.id),
                    ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanSummaryBody extends ConsumerWidget {
  const _PlanSummaryBody({required this.store, required this.journey});

  final HajjStore store;
  final HajjJourney journey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = dateKey(ref.watch(nowProvider));
    final summary = buildHajjJourneyPlanSummary(
      journey: journey,
      travelers: store.travelers,
      todayKey: today,
    );
    final style = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Copy.hajjEstimateNotOfficial, style: style),
        Text(
          summary.unknownRoute
              ? 'Planning pathway is not confirmed yet.'
              : summary.pathways.map((item) => item.label).join(' · '),
          style: style,
        ),
        Text(summary.seasonLabel, style: style),
        if (summary.officialDeadlines.isNotEmpty)
          Text(
            'Official deadlines you typed: ${summary.officialDeadlines.join('; ')}',
            style: style,
          ),
        if (summary.criticalTitles.isNotEmpty)
          Text(
            'Critical path: ${summary.criticalTitles.join(', ')}',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        if (summary.conflicts.isNotEmpty)
          Text(
            summary.conflicts.first,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        if (summary.estimatedTravelCost != null)
          Text(
            'Selected return estimate: ${summary.estimatedTravelCost}',
            style: style,
          ),
        if (summary.needsConfirmation.isNotEmpty)
          Text(
            summary.needsConfirmation.first,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
      ],
    );
  }
}

class _PathwayBody extends ConsumerWidget {
  const _PathwayBody({required this.store, required this.journey});

  final HajjStore store;
  final HajjJourney journey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = suggestHajjPathways(
      journey: journey,
      travelers: store.travelers,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copy.hajjPathwayNotEligibility,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (suggestions.isEmpty)
          Text(
            'No route is suggested yet. Unknown is allowed. Confirm only what you choose.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        for (final item in suggestions)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${item.family.label}: ${item.reason}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('hajj-pathway-confirm'),
          onPressed: () => _openPathwaySheet(context, ref, store, journey),
          child: const Text(Copy.hajjPathwayConfirm),
        ),
      ],
    );
  }
}

class _ReturnBody extends ConsumerWidget {
  const _ReturnBody({required this.journey});

  final HajjJourney journey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compared = compareHajjReturnScenarios(journey.returnPlan);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copy.hajjUnusedNotRefundable,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          Copy.hajjRitesMustComplete,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        for (final item in compared)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(item.kind.label, maxLines: 2),
            subtitle: Text(
              '${item.costLabel} · Confirmed refunds ${item.costsEntered ? item.confirmedRefunds : Copy.hajjNotEstimated}',
            ),
            selected: journey.returnPlan.selectedKind == item.kind,
            onTap: () => persistHajjStore(ref, (store) {
              final current = store.selectedJourney ?? journey;
              return store.upsertJourney(
                current.copyWith(
                  returnPlan: current.returnPlan.copyWith(
                    selectedKind: item.kind,
                  ),
                ),
              );
            }),
          ),
        OutlinedButton(
          key: const Key('hajj-return-edit'),
          onPressed: () => _openReturnSheet(context, ref, journey),
          child: const Text('Edit return costs'),
        ),
      ],
    );
  }
}

class _ReadinessBody extends ConsumerWidget {
  const _ReadinessBody({required this.journey});

  final HajjJourney journey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copy.hajjConfirmationNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          Copy.hajjNoDocumentUpload,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        for (final group in kHajjReadinessGroups) ...[
          Text(group, style: Theme.of(context).textTheme.labelLarge),
          for (final item in journey.readiness)
            if (item.group == group && item.travelerId == null)
              _ReadinessRow(
                item: item,
                onChanged: (next) => persistHajjStore(ref, (store) {
                  final current = store.selectedJourney ?? journey;
                  return store.upsertJourney(
                    current.copyWith(
                      readiness: [
                        for (final row in current.readiness)
                          if (row.id == item.id) next else row,
                      ],
                    ),
                  );
                }),
              ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _ReadinessRow extends ConsumerWidget {
  const _ReadinessRow({required this.item, required this.onChanged});

  final HajjReadinessPrerequisite item;
  final Future<void> Function(HajjReadinessPrerequisite next) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title ?? item.id,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _readinessMetaLine(item),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          CheckInSelect<HajjReadinessStatus>(
            dropdownKey: Key('hajj-ready-${item.id}'),
            value: kHajjReadinessPlannerStatuses.contains(item.status)
                ? item.status
                : HajjReadinessStatus.unanswered,
            entries: [
              for (final status in kHajjReadinessPlannerStatuses)
                CheckInSelectEntry(value: status, label: status.label),
            ],
            onChanged: (status) async {
              final now = ref.read(nowProvider).toIso8601String();
              await onChanged(
                item.copyWith(
                  status: status,
                  confirmedByUser: status == HajjReadinessStatus.confirmedReady,
                  confirmationRecordedAt:
                      status == HajjReadinessStatus.confirmedReady
                      ? now
                      : item.confirmationRecordedAt,
                ),
              );
            },
          ),
          TextButton(
            key: Key('hajj-ready-details-${item.id}'),
            onPressed: () => _openReadinessSheet(
              context,
              ref,
              item: item,
              onChanged: onChanged,
            ),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }
}

String _readinessMetaLine(HajjReadinessPrerequisite item) {
  final parts = <String>[
    item.confirmedByUser
        ? Copy.hajjUserConfirmedLabel
        : 'Not confirmed by user',
    item.officialRequirementVerified
        ? Copy.hajjOfficialVerifiedLabel
        : 'Official requirement not marked verified',
    if (item.internalTargetDate != null) 'Target ${item.internalTargetDate}',
    if (item.confirmationRecordedAt != null)
      'Last confirmation ${item.confirmationRecordedAt}',
    if (item.evidenceSourceId != null) 'Source ${item.evidenceSourceId}',
  ];
  return parts.join(' · ');
}

class _CalendarBody extends ConsumerWidget {
  const _CalendarBody({required this.journey});

  final HajjJourney journey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider);
    final today = dateKey(now);
    final horizon = clampHajjHorizonMonths(journey.horizonMonths);
    final months = hajjCalendarMonths(
      from: now,
      horizonMonths: horizon,
      milestones: journey.milestones,
    );
    final past = [
      for (final milestone in journey.milestones)
        if (hajjMilestoneHorizonGroup(
              milestone,
              todayKey: today,
              horizonMonths: horizon,
            ) ==
            HajjMilestoneHorizonGroup.past)
          milestone,
    ];
    final beyond = [
      for (final milestone in journey.milestones)
        if (hajjMilestoneHorizonGroup(
              milestone,
              todayKey: today,
              horizonMonths: horizon,
            ) ==
            HajjMilestoneHorizonGroup.beyond)
          milestone,
    ];
    final unscheduled = [
      for (final milestone in journey.milestones)
        if (hajjMilestoneHorizonGroup(
              milestone,
              todayKey: today,
              horizonMonths: horizon,
            ) ==
            HajjMilestoneHorizonGroup.unscheduled)
          milestone,
    ];
    final upcoming = hajjUpcomingMilestones(
      milestones: journey.milestones,
      todayKey: today,
    );
    final conflicts = hajjJourneyConflicts(journey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in kHajjHorizonOptions)
              Semantics(
                button: true,
                label: '$option month planning horizon',
                child: ChoiceChip(
                  key: Key('hajj-horizon-$option'),
                  label: Text('$option mo'),
                  selected: horizon == option,
                  onSelected: (_) => persistHajjStore(ref, (store) {
                    final current = store.selectedJourney ?? journey;
                    return store.upsertJourney(
                      current.copyWith(horizonMonths: option),
                    );
                  }),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('hajj-add-milestone'),
          onPressed: () => _openMilestoneSheet(context, ref, journey),
          child: const Text('Add milestone'),
        ),
        Builder(
          builder: (context) {
            final untitled = [
              for (final milestone in journey.milestones)
                if (hajjMilestoneIsLegacyUntitled(milestone)) milestone,
            ];
            if (untitled.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Copy.hajjUntitledMilestones,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  for (final milestone in untitled)
                    ListTile(
                      key: Key('hajj-untitled-${milestone.id}'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Untitled milestone'),
                      subtitle: const Text('Name it or delete it.'),
                      onTap: () => _openMilestoneSheet(
                        context,
                        ref,
                        journey,
                        existing: milestone,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (conflicts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Scheduling notes',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          for (final conflict in conflicts)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                conflict.message,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
        if (upcoming.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming deadlines',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                for (final milestone in upcoming)
                  Text(
                    '${milestone.title ?? 'Milestone'} · ${_milestoneLine(milestone, today, journey.milestones)}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        for (final bucket in months)
          KeyedSubtree(
            key: ValueKey(
              'hajj-month-${bucket.monthKey}-${bucket.milestones.isEmpty}',
            ),
            child: _HajjMonthGroup(
              key: Key('hajj-month-${bucket.monthKey}'),
              monthKey: bucket.monthKey,
              initiallyExpanded: hajjCalendarMonthInitiallyExpanded(
                monthKey: bucket.monthKey,
                todayKey: today,
                milestones: bucket.milestones,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bucket.milestones.isEmpty)
                    Text(
                      Copy.hajjMonthEmpty,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  for (final milestone in bucket.milestones)
                    _milestoneTile(context, ref, journey, milestone, today),
                ],
              ),
            ),
          ),
        KeyedSubtree(
          key: ValueKey('hajj-past-${past.isEmpty}'),
          child: _HajjMonthGroup(
            key: const Key('hajj-past-milestones'),
            monthKey: Copy.hajjPastMilestones,
            semanticLabel: '${Copy.hajjPastMilestones}. ${past.length} stored.',
            initiallyExpanded: past.isNotEmpty,
            child: past.isEmpty
                ? Text(
                    Copy.hajjMonthEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Column(
                    children: [
                      for (final milestone in past)
                        _milestoneTile(context, ref, journey, milestone, today),
                    ],
                  ),
          ),
        ),
        KeyedSubtree(
          key: ValueKey('hajj-beyond-${beyond.isEmpty}'),
          child: _HajjMonthGroup(
            key: const Key('hajj-beyond-horizon'),
            monthKey: Copy.hajjBeyondHorizon,
            semanticLabel:
                '${Copy.hajjBeyondHorizon}. ${beyond.length} stored.',
            initiallyExpanded: false,
            child: beyond.isEmpty
                ? Text(
                    Copy.hajjMonthEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Column(
                    children: [
                      for (final milestone in beyond)
                        _milestoneTile(context, ref, journey, milestone, today),
                    ],
                  ),
          ),
        ),
        KeyedSubtree(
          key: ValueKey('hajj-unscheduled-${unscheduled.isEmpty}'),
          child: _HajjMonthGroup(
            key: const Key('hajj-unscheduled-milestones'),
            monthKey: Copy.hajjUnscheduledMilestones,
            semanticLabel:
                '${Copy.hajjUnscheduledMilestones}. ${unscheduled.length} stored.',
            initiallyExpanded: unscheduled.isNotEmpty,
            child: unscheduled.isEmpty
                ? Text(
                    Copy.hajjMonthEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Column(
                    children: [
                      for (final milestone in unscheduled)
                        _milestoneTile(context, ref, journey, milestone, today),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _HajjMonthGroup extends StatelessWidget {
  const _HajjMonthGroup({
    super.key,
    required this.monthKey,
    required this.child,
    required this.initiallyExpanded,
    this.semanticLabel,
  });

  final String monthKey;
  final Widget child;
  final bool initiallyExpanded;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel ?? 'Planning month $monthKey',
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: Text(monthKey, style: Theme.of(context).textTheme.labelLarge),
          children: [child],
        ),
      ),
    );
  }
}

Widget _milestoneTile(
  BuildContext context,
  WidgetRef ref,
  HajjJourney journey,
  HajjMilestone milestone,
  String today,
) {
  return ListTile(
    key: Key('hajj-milestone-${milestone.id}'),
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text(
      '${hajjMilestoneIsCritical(milestone) ? 'Critical · ' : ''}${milestone.title ?? 'Milestone'}',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Text(
      _milestoneLine(milestone, today, journey.milestones),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    ),
    onTap: () =>
        _openMilestoneSheet(context, ref, journey, existing: milestone),
  );
}

String _milestoneLine(
  HajjMilestone milestone,
  String today,
  List<HajjMilestone> all,
) {
  final attention = hajjMilestoneAttention(milestone, todayKey: today);
  final conflicts = hajjScheduleConflicts(milestone, all: all);
  final parts = <String>[
    if (milestone.officialDeadline != null)
      'Official ${milestone.officialDeadline}',
    if (milestone.plannedDate != null)
      '${milestone.plannedDateCertainty.label} ${milestone.plannedDate}',
    if (milestone.recommendedStartDate != null &&
        milestone.recommendedCompletionDate != null)
      '${Copy.hajjActionWindow} ${milestone.recommendedStartDate}–${milestone.recommendedCompletionDate}',
    if (milestone.processingDurationDays != null)
      'Processing ${milestone.processingDurationDays}d',
    if (milestone.bufferDays != null) 'Float ${milestone.bufferDays}d',
    if (milestone.dependsOn.isNotEmpty)
      'Depends on ${milestone.dependsOn.length}',
    if (milestone.status == HajjMilestoneStatus.done) 'Completed',
    if (attention == HajjMilestoneAttention.overdue) 'Overdue (your dates)',
    if (attention == HajjMilestoneAttention.upcoming) 'Upcoming',
    if (conflicts.isNotEmpty) conflicts.first.message,
  ];
  return parts.isEmpty ? 'No date stored' : parts.join(' · ');
}

class _FamilyBody extends ConsumerWidget {
  const _FamilyBody({required this.store});

  final HajjStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copy.hajjNoPassportScan,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          Copy.hajjTravelerReadinessNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        for (final traveler in store.travelers) ...[
          ListTile(
            key: Key('hajj-traveler-${traveler.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              traveler.displayName ?? traveler.role.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Nationality ${traveler.nationalityCountry ?? 'unrecorded'} · residence ${traveler.residenceCountry ?? 'unrecorded'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _openTravelerSheet(context, ref, existing: traveler),
          ),
          for (final item in withSeededTravelerReadiness(traveler).readiness)
            _ReadinessRow(
              item: item,
              onChanged: (next) => persistHajjStore(ref, (current) {
                final stored =
                    current.travelers
                        .where((row) => row.id == traveler.id)
                        .firstOrNull ??
                    traveler;
                final seeded = withSeededTravelerReadiness(stored);
                return current.upsertTraveler(
                  seeded.copyWith(
                    readiness: [
                      for (final row in seeded.readiness)
                        if (row.id == item.id) next else row,
                    ],
                  ),
                );
              }),
            ),
        ],
        OutlinedButton(
          key: const Key('hajj-add-traveler'),
          onPressed: () => _openTravelerSheet(context, ref),
          child: const Text('Add traveler'),
        ),
      ],
    );
  }
}

class _LearningBody extends ConsumerWidget {
  const _LearningBody({required this.store});

  final HajjStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (final topic in kHajjLearningCatalog)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(
                  topic.source,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                CheckInSelect<HajjLearningState>(
                  dropdownKey: Key('hajj-learn-${topic.id}'),
                  value: store.learningStateFor(topic.id),
                  entries: [
                    for (final state in HajjLearningState.values)
                      CheckInSelectEntry(value: state, label: state.label),
                  ],
                  onChanged: (state) => persistHajjStore(
                    ref,
                    (current) => current.withLearningState(topic.id, state),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AfterBody extends ConsumerStatefulWidget {
  const _AfterBody({required this.store});

  final HajjStore store;

  @override
  ConsumerState<_AfterBody> createState() => _AfterBodyState();
}

class _AfterBodyState extends ConsumerState<_AfterBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.store.afterHajj.reflectionText ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Copy.hajjAfterNote, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextField(
          key: const Key('hajj-after-reflection'),
          minLines: 2,
          maxLines: 4,
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Optional reflection',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('hajj-after-save'),
          onPressed: () {
            final text = _controller.text.trim();
            persistHajjStore(ref, (current) {
              return current.copyWith(
                afterHajj: HajjAfterRecord(
                  reflectionText: text.isEmpty ? null : text,
                  continuingPracticeIds:
                      current.afterHajj.continuingPracticeIds,
                  returnIntention: current.afterHajj.returnIntention,
                  updatedAt: ref.read(nowProvider).toIso8601String(),
                ),
              );
            });
          },
          child: const Text('Save reflection'),
        ),
        const SizedBox(height: 8),
        CheckInSelect<HajjAfterReturnIntention>(
          dropdownKey: const Key('hajj-after-return'),
          value: store.afterHajj.returnIntention,
          entries: [
            for (final option in HajjAfterReturnIntention.values)
              CheckInSelectEntry(value: option, label: option.label),
          ],
          onChanged: (option) => persistHajjStore(ref, (current) {
            return current.copyWith(
              afterHajj: current.afterHajj.copyWith(returnIntention: option),
            );
          }),
        ),
      ],
    );
  }
}

Future<void> _openJourneySheet(
  BuildContext context,
  WidgetRef ref, {
  HajjJourney? existing,
}) async {
  final season = TextEditingController(
    text: existing?.targetSeason.hijriYear?.toString() ?? '',
  );
  final departure = TextEditingController(
    text: existing?.departureCountry ?? '',
  );
  final returning = TextEditingController(text: existing?.returnCountry ?? '');
  final departDate = TextEditingController(
    text: existing?.intendedDepartureDate ?? '',
  );
  final returnDate = TextEditingController(
    text: existing?.intendedReturnDate ?? '',
  );
  final budget = TextEditingController(text: existing?.budgetNote ?? '');
  final prefs = TextEditingController(text: existing?.travelPreferences ?? '');
  final periodStartCtrl = TextEditingController(
    text: existing?.planning.expectedHajjPeriodStart ?? '',
  );
  final periodEndCtrl = TextEditingController(
    text: existing?.planning.expectedHajjPeriodEnd ?? '',
  );
  final authorityCtrl = TextEditingController(
    text: existing?.planning.registrationAuthority ?? '',
  );
  final openCtrl = TextEditingController(
    text: existing?.planning.registrationOpenDate ?? '',
  );
  final closeCtrl = TextEditingController(
    text: existing?.planning.registrationCloseDate ?? '',
  );
  final packageCtrl = TextEditingController(
    text: existing?.planning.packageBookingDeadline ?? '',
  );
  final leaveCtrl = TextEditingController(
    text: existing?.planning.workLeaveNote ?? '',
  );
  final familyCtrl = TextEditingController(
    text: existing?.planning.familyCommitmentsNote ?? '',
  );
  final healthCtrl = TextEditingController(
    text: existing?.planning.healthAccessibilityNote ?? '',
  );
  final amountCtrl = TextEditingController(
    text: existing?.planning.budgetAmount?.toString() ?? '',
  );
  final flexCtrl = TextEditingController(
    text: existing?.planning.returnFlexibilityNote ?? '',
  );
  var lifecycle = existing?.lifecycle ?? HajjJourneyLifecycle.considering;
  var certainty = existing?.dateCertainty ?? HajjDateCertainty.unknown;
  var horizon = clampHajjHorizonMonths(existing?.horizonMonths);
  var undecidedSeason = existing?.targetSeason.datesUnknown ?? true;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _hajjEditorSheet(
        context: context,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(existing == null ? Copy.hajjCreateJourney : 'Edit plan'),
                  CheckboxListTile(
                    key: const Key('hajj-season-undecided'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Season undecided'),
                    value: undecidedSeason,
                    onChanged: (value) =>
                        setState(() => undecidedSeason = value ?? true),
                  ),
                  TextField(
                    key: const Key('hajj-season-year'),
                    controller: season,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hijri season year (optional)',
                    ),
                  ),
                  TextField(
                    key: const Key('hajj-departure-country'),
                    controller: departure,
                    decoration: const InputDecoration(
                      labelText: 'Intended departure country',
                    ),
                  ),
                  TextField(
                    key: const Key('hajj-return-country'),
                    controller: returning,
                    decoration: const InputDecoration(
                      labelText: 'Expected return country',
                    ),
                  ),
                  TextField(
                    key: const Key('hajj-depart-date'),
                    controller: departDate,
                    decoration: const InputDecoration(
                      labelText: 'Departure date YYYY-MM-DD or blank',
                    ),
                  ),
                  TextField(
                    key: const Key('hajj-return-date'),
                    controller: returnDate,
                    decoration: const InputDecoration(
                      labelText: 'Return date YYYY-MM-DD or blank',
                    ),
                  ),
                  DropdownButton<HajjDateCertainty>(
                    key: const Key('hajj-date-certainty'),
                    value: certainty,
                    items: [
                      for (final option in HajjDateCertainty.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => certainty = value ?? certainty),
                  ),
                  DropdownButton<HajjJourneyLifecycle>(
                    value: lifecycle,
                    items: [
                      for (final option in HajjJourneyLifecycle.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => lifecycle = value ?? lifecycle),
                  ),
                  DropdownButton<int>(
                    value: horizon,
                    items: [
                      for (final option in kHajjHorizonOptions)
                        DropdownMenuItem(
                          value: option,
                          child: Text('$option months'),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => horizon = value ?? horizon),
                  ),
                  TextField(
                    key: const Key('hajj-period-start'),
                    controller: periodStartCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Expected Hajj period start YYYY-MM-DD',
                    ),
                  ),
                  TextField(
                    controller: periodEndCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Expected Hajj period end YYYY-MM-DD',
                    ),
                  ),
                  TextField(
                    controller: authorityCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Registration pathway or authority (optional)',
                    ),
                  ),
                  TextField(
                    controller: openCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Registration opening date if known',
                    ),
                  ),
                  TextField(
                    controller: closeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Registration closing date if known',
                    ),
                  ),
                  TextField(
                    controller: packageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Package booking deadline if known',
                    ),
                  ),
                  TextField(
                    controller: leaveCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Work leave notes (optional)',
                    ),
                  ),
                  TextField(
                    controller: familyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Family commitments (optional)',
                    ),
                  ),
                  TextField(
                    controller: healthCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Health and accessibility notes (optional)',
                    ),
                  ),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget amount (optional whole units)',
                    ),
                  ),
                  TextField(
                    controller: flexCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Return flexibility (optional)',
                    ),
                  ),
                  TextField(
                    controller: budget,
                    decoration: const InputDecoration(
                      labelText: 'Optional budget notes',
                    ),
                  ),
                  TextField(
                    controller: prefs,
                    decoration: const InputDecoration(
                      labelText: 'Optional travel preferences',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const Key('hajj-journey-save'),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Save plan'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  if (saved != true) return;
  final year = int.tryParse(season.text.trim());
  final periodStart = periodStartCtrl.text;
  final periodEnd = periodEndCtrl.text;
  final authority = authorityCtrl.text;
  final openDate = openCtrl.text;
  final closeDate = closeCtrl.text;
  final packageDeadline = packageCtrl.text;
  final leave = leaveCtrl.text;
  final familyNote = familyCtrl.text;
  final health = healthCtrl.text;
  final amount = int.tryParse(amountCtrl.text.trim());
  final flexibility = flexCtrl.text;
  await persistHajjStore(ref, (store) {
    final id = existing?.id ?? newHajjEntityId('jny', ref.read(nowProvider));
    final journey =
        (existing ?? HajjJourney(id: id, readiness: seededHajjReadiness()))
            .copyWith(
              lifecycle: lifecycle,
              targetSeason: HajjSeason(
                hijriYear: undecidedSeason ? null : year,
                datesUnknown: undecidedSeason || year == null,
              ),
              departureCountry: _blankToNull(departure.text),
              returnCountry: _blankToNull(returning.text),
              intendedDepartureDate: _blankToNull(departDate.text),
              intendedReturnDate: _blankToNull(returnDate.text),
              datesUnknown:
                  certainty == HajjDateCertainty.unknown ||
                  departDate.text.trim().isEmpty,
              dateCertainty: certainty,
              horizonMonths: horizon,
              budgetNote: _blankToNull(budget.text),
              travelPreferences: _blankToNull(prefs.text),
              planning: (existing?.planning ?? const HajjPlanningInputs())
                  .copyWith(
                    expectedHajjPeriodStart: _blankToNull(periodStart),
                    expectedHajjPeriodEnd: _blankToNull(periodEnd),
                    registrationAuthority: _blankToNull(authority),
                    registrationOpenDate: _blankToNull(openDate),
                    registrationCloseDate: _blankToNull(closeDate),
                    packageBookingDeadline: _blankToNull(packageDeadline),
                    workLeaveNote: _blankToNull(leave),
                    familyCommitmentsNote: _blankToNull(familyNote),
                    healthAccessibilityNote: _blankToNull(health),
                    budgetAmount: amount,
                    returnFlexibilityNote: _blankToNull(flexibility),
                  ),
            );
    return store.upsertJourney(journey).selectJourney(id);
  });
}

Future<void> _openPathwaySheet(
  BuildContext context,
  WidgetRef ref,
  HajjStore store,
  HajjJourney journey,
) async {
  final suggestions = suggestHajjPathways(
    journey: journey,
    travelers: store.travelers,
  );
  var selected = {...journey.planning.confirmedPathwayIds};
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _hajjEditorSheet(
        context: context,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(Copy.hajjPathwayNotEligibility),
                  for (final family in HajjPathwayFamily.values)
                    CheckboxListTile(
                      key: Key('hajj-pathway-${family.name}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(family.label),
                      subtitle: Text(() {
                        final match = suggestions.where(
                          (item) => item.family == family,
                        );
                        return match.isEmpty ? family.note : match.first.reason;
                      }()),
                      value: selected.contains(family.name),
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          selected.add(family.name);
                        } else {
                          selected.remove(family.name);
                        }
                      }),
                    ),
                  FilledButton(
                    key: const Key('hajj-pathway-save'),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Save confirmed routes'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  if (saved != true) return;
  await persistHajjStore(ref, (current) {
    final active = current.selectedJourney ?? journey;
    return current.upsertJourney(
      active.copyWith(
        planning: active.planning.copyWith(
          suggestedPathwayIds: [
            for (final item in suggestions) item.family.name,
          ],
          confirmedPathwayIds: selected.toList(),
          pathwaysConfirmedByUser: true,
        ),
      ),
    );
  });
}

Future<void> _openReturnSheet(
  BuildContext context,
  WidgetRef ref,
  HajjJourney journey,
) async {
  final standardCost = TextEditingController(
    text: journey.returnPlan.standard.packageCost?.toString() ?? '',
  );
  final earlyFees = TextEditingController(
    text: journey.returnPlan.earlyAfterRites.changeFees?.toString() ?? '',
  );
  final earlyPackage = TextEditingController(
    text: journey.returnPlan.earlyAfterRites.packageCost?.toString() ?? '',
  );
  final otherTransport = TextEditingController(
    text: journey.returnPlan.differentCountry.extraTransport?.toString() ?? '',
  );
  final otherStay = TextEditingController(
    text:
        journey.returnPlan.differentCountry.extraAccommodation?.toString() ??
        '',
  );
  final otherRefund = TextEditingController(
    text:
        journey.returnPlan.differentCountry.confirmedRefunds?.toString() ?? '',
  );
  var selected = journey.returnPlan.selectedKind;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _hajjEditorSheet(
        context: context,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(Copy.hajjUnusedNotRefundable),
                  Text(Copy.hajjRitesMustComplete),
                  for (final kind in HajjReturnScenarioKind.values)
                    ListTile(
                      key: Key('hajj-return-${kind.name}'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      selected: selected == kind,
                      title: Text(kind.label),
                      onTap: () => setState(() => selected = kind),
                    ),
                  TextField(
                    key: const Key('hajj-return-standard-cost'),
                    controller: standardCost,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Standard package cost',
                    ),
                  ),
                  TextField(
                    controller: earlyPackage,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Early-return package cost',
                    ),
                  ),
                  TextField(
                    controller: earlyFees,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Airline change fees if known',
                    ),
                  ),
                  TextField(
                    controller: otherTransport,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Different-country extra transport',
                    ),
                  ),
                  TextField(
                    controller: otherStay,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Different-country extra stay',
                    ),
                  ),
                  TextField(
                    controller: otherRefund,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Confirmed refunds only',
                    ),
                  ),
                  FilledButton(
                    key: const Key('hajj-return-save'),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Save return comparison'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  if (saved != true) return;
  await persistHajjStore(ref, (store) {
    final current = store.selectedJourney ?? journey;
    return store.upsertJourney(
      current.copyWith(
        returnPlan: current.returnPlan.copyWith(
          selectedKind: selected,
          standard: HajjReturnScenario(
            kind: HajjReturnScenarioKind.standardPackage,
            packageCost: _optIntText(standardCost.text),
          ),
          earlyAfterRites: HajjReturnScenario(
            kind: HajjReturnScenarioKind.earlyAfterRites,
            packageCost: _optIntText(earlyPackage.text),
            changeFees: _optIntText(earlyFees.text),
          ),
          differentCountry: HajjReturnScenario(
            kind: HajjReturnScenarioKind.differentCountry,
            extraTransport: _optIntText(otherTransport.text),
            extraAccommodation: _optIntText(otherStay.text),
            confirmedRefunds: _optIntText(otherRefund.text),
          ),
        ),
      ),
    );
  });
}

Future<void> _openTravelerSheet(
  BuildContext context,
  WidgetRef ref, {
  HajjTravelerProfile? existing,
}) async {
  final name = TextEditingController(text: existing?.displayName ?? '');
  final nationality = TextEditingController(
    text: existing?.nationalityCountry ?? '',
  );
  final residence = TextEditingController(
    text: existing?.residenceCountry ?? '',
  );
  final passport = TextEditingController(
    text: existing?.passportExpiryDate ?? '',
  );
  final residenceExpiry = TextEditingController(
    text: existing?.residenceExpiryDate ?? '',
  );
  final healthNote = TextEditingController(
    text: existing?.healthPreparationNote ?? '',
  );
  var role = existing?.role ?? HajjTravelerRole.self;
  var readiness = existing?.readinessStatus ?? HajjReadinessStatus.unanswered;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _hajjEditorSheet(
        context: context,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('hajj-traveler-name'),
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Display name (optional)',
                    ),
                  ),
                  DropdownButton<HajjTravelerRole>(
                    value: role,
                    items: [
                      for (final option in HajjTravelerRole.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) => setState(() => role = value ?? role),
                  ),
                  TextField(
                    key: const Key('hajj-traveler-nationality'),
                    controller: nationality,
                    decoration: const InputDecoration(
                      labelText: 'Passport nationality',
                    ),
                  ),
                  TextField(
                    key: const Key('hajj-traveler-residence'),
                    controller: residence,
                    decoration: const InputDecoration(
                      labelText: 'Legal residence country',
                    ),
                  ),
                  TextField(
                    key: const Key('hajj-traveler-passport'),
                    controller: passport,
                    decoration: const InputDecoration(
                      labelText: 'Passport expiry YYYY-MM-DD (no number)',
                    ),
                  ),
                  TextField(
                    key: const Key('hajj-traveler-residence-expiry'),
                    controller: residenceExpiry,
                    decoration: const InputDecoration(
                      labelText: 'Residence document expiry YYYY-MM-DD',
                    ),
                  ),
                  TextField(
                    controller: healthNote,
                    decoration: const InputDecoration(
                      labelText: 'Health preparation notes (optional)',
                    ),
                  ),
                  DropdownButton<HajjReadinessStatus>(
                    value: kHajjReadinessPlannerStatuses.contains(readiness)
                        ? readiness
                        : HajjReadinessStatus.unanswered,
                    items: [
                      for (final option in kHajjReadinessPlannerStatuses)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => readiness = value ?? readiness),
                  ),
                  FilledButton(
                    key: const Key('hajj-traveler-save'),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Save traveler'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  if (saved != true) return;
  await persistHajjStore(ref, (store) {
    final traveler = withSeededTravelerReadiness(
      HajjTravelerProfile(
        id:
            existing?.id ??
            newHajjEntityId(
              'trv',
              ref.read(nowProvider),
              store.travelers.length,
            ),
        role: role,
        displayName: _blankToNull(name.text),
        nationalityCountry: _blankToNull(nationality.text),
        residenceCountry: _blankToNull(residence.text),
        passportExpiryDate: _blankToNull(passport.text),
        residenceExpiryDate: _blankToNull(residenceExpiry.text),
        healthPreparationNote: _blankToNull(healthNote.text),
        readinessStatus: readiness,
        readiness: existing?.readiness ?? const [],
      ),
    );
    var next = store.upsertTraveler(traveler);
    final journey = next.selectedJourney;
    if (journey != null && !journey.travelerIds.contains(traveler.id)) {
      next = next.upsertJourney(
        journey.copyWith(travelerIds: [...journey.travelerIds, traveler.id]),
      );
    }
    return next;
  });
}

Future<void> _openReadinessSheet(
  BuildContext context,
  WidgetRef ref, {
  required HajjReadinessPrerequisite item,
  required Future<void> Function(HajjReadinessPrerequisite next) onChanged,
}) async {
  final target = TextEditingController(text: item.internalTargetDate ?? '');
  final notes = TextEditingController(text: item.notes ?? '');
  final evidence = TextEditingController(text: item.evidenceSourceId ?? '');
  var status = kHajjReadinessPlannerStatuses.contains(item.status)
      ? item.status
      : HajjReadinessStatus.unanswered;
  var officialVerified = item.officialRequirementVerified;
  var error = '';
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _hajjEditorSheet(
        context: context,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.title ?? item.id,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    Copy.hajjNoDocumentUpload,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  DropdownButton<HajjReadinessStatus>(
                    key: Key('hajj-ready-status-${item.id}'),
                    value: status,
                    items: [
                      for (final option in kHajjReadinessPlannerStatuses)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => status = value ?? status),
                  ),
                  SwitchListTile(
                    key: Key('hajj-ready-official-${item.id}'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text(Copy.hajjOfficialVerifiedLabel),
                    subtitle: const Text(
                      'A mark you keep. It is not a government check or document upload.',
                    ),
                    value: officialVerified,
                    onChanged: (value) =>
                        setState(() => officialVerified = value),
                  ),
                  Text(
                    item.confirmedByUser
                        ? Copy.hajjUserConfirmedLabel
                        : 'Not ${Copy.hajjUserConfirmedLabel.toLowerCase()}',
                  ),
                  if (item.confirmationRecordedAt != null)
                    Text('Last confirmation ${item.confirmationRecordedAt}'),
                  Semantics(
                    textField: true,
                    label: 'Target completion date YYYY-MM-DD',
                    child: TextField(
                      key: Key('hajj-ready-target-${item.id}'),
                      controller: target,
                      keyboardType: TextInputType.datetime,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Target completion date YYYY-MM-DD',
                      ),
                    ),
                  ),
                  Semantics(
                    textField: true,
                    label: 'Source or evidence reference, no uploads',
                    child: TextField(
                      key: Key('hajj-ready-evidence-${item.id}'),
                      controller: evidence,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Source or evidence reference (no uploads)',
                      ),
                    ),
                  ),
                  Semantics(
                    textField: true,
                    label: 'Notes',
                    child: TextField(
                      key: Key('hajj-ready-notes-${item.id}'),
                      controller: notes,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                  ),
                  if (error.isNotEmpty)
                    Text(error, key: Key('hajj-ready-error-${item.id}')),
                  FilledButton(
                    key: Key('hajj-ready-save-${item.id}'),
                    onPressed: () {
                      if (!isOptionalHajjDateKey(target.text)) {
                        setState(() => error = Copy.hajjMilestoneDateInvalid);
                        return;
                      }
                      Navigator.pop(context, true);
                    },
                    child: const Text('Save details'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  if (saved != true) return;
  final now = ref.read(nowProvider).toIso8601String();
  await onChanged(
    item.copyWith(
      status: status,
      confirmedByUser: status == HajjReadinessStatus.confirmedReady,
      confirmationRecordedAt: status == HajjReadinessStatus.confirmedReady
          ? (item.confirmationRecordedAt ?? now)
          : item.confirmationRecordedAt,
      officialRequirementVerified: officialVerified,
      internalTargetDate: _blankToNull(target.text),
      evidenceSourceId: _blankToNull(evidence.text),
      notes: _blankToNull(notes.text),
    ),
  );
}

Future<void> _openMilestoneSheet(
  BuildContext context,
  WidgetRef ref,
  HajjJourney journey, {
  HajjMilestone? existing,
}) async {
  final title = TextEditingController(text: existing?.title ?? '');
  final official = TextEditingController(
    text: existing?.officialDeadline ?? '',
  );
  final planned = TextEditingController(text: existing?.plannedDate ?? '');
  final processing = TextEditingController(
    text: existing?.processingDurationDays?.toString() ?? '',
  );
  final float = TextEditingController(
    text: existing?.bufferDays?.toString() ?? '',
  );
  var status = existing?.status ?? HajjMilestoneStatus.pending;
  var certainty = existing?.plannedDateCertainty ?? HajjDateCertainty.tentative;
  var dependsOn = [...?existing?.dependsOn];
  var cycleMessage = '';
  var error = '';
  var unscheduled =
      existing != null &&
      (existing.officialDeadline == null ||
          existing.officialDeadline!.trim().isEmpty) &&
      (existing.plannedDate == null || existing.plannedDate!.trim().isEmpty);
  final milestoneId =
      existing?.id ??
      newHajjEntityId('ms', ref.read(nowProvider), journey.milestones.length);
  final saved = await showModalBottomSheet<Object?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _hajjEditorSheet(
        context: context,
        child: StatefulBuilder(
          builder: (context, setState) {
            final others = [
              for (final item in journey.milestones)
                if (item.id != milestoneId) item,
            ];
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    textField: true,
                    label: 'Milestone name',
                    child: TextField(
                      key: const Key('hajj-milestone-title'),
                      controller: title,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Milestone name',
                        helperText:
                            'Required. Dates are optional if unscheduled.',
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    key: const Key('hajj-milestone-unscheduled'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text(Copy.hajjMilestoneUnscheduled),
                    value: unscheduled,
                    onChanged: (value) => setState(() {
                      unscheduled = value ?? false;
                      error = '';
                    }),
                  ),
                  Semantics(
                    textField: true,
                    label: 'Official deadline you typed, YYYY-MM-DD',
                    child: TextField(
                      key: const Key('hajj-milestone-official'),
                      controller: official,
                      enabled: !unscheduled,
                      keyboardType: TextInputType.datetime,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Official deadline you typed (YYYY-MM-DD)',
                      ),
                    ),
                  ),
                  Semantics(
                    textField: true,
                    label: 'Tentative date YYYY-MM-DD',
                    child: TextField(
                      key: const Key('hajj-milestone-planned'),
                      controller: planned,
                      enabled: !unscheduled,
                      keyboardType: TextInputType.datetime,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Tentative date YYYY-MM-DD',
                      ),
                    ),
                  ),
                  Semantics(
                    textField: true,
                    label: 'Estimated processing days',
                    child: TextField(
                      key: const Key('hajj-milestone-processing'),
                      controller: processing,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Estimated processing days',
                      ),
                    ),
                  ),
                  Semantics(
                    textField: true,
                    label: 'Planning float days',
                    child: TextField(
                      key: const Key('hajj-milestone-float'),
                      controller: float,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Planning float days',
                      ),
                    ),
                  ),
                  DropdownButton<HajjMilestoneStatus>(
                    value: status,
                    items: [
                      for (final option in HajjMilestoneStatus.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => status = value ?? status),
                  ),
                  DropdownButton<HajjDateCertainty>(
                    value: certainty,
                    items: [
                      for (final option in HajjDateCertainty.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => certainty = value ?? certainty),
                  ),
                  Text(
                    'Prerequisites',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (others.isEmpty)
                    Text(
                      'Save another milestone first to choose a prerequisite.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  for (final other in others)
                    CheckboxListTile(
                      key: Key('hajj-dep-${other.id}'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        other.title ?? other.id,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: dependsOn.contains(other.id),
                      onChanged: (selected) {
                        final next = [
                          for (final id in dependsOn)
                            if (id != other.id) id,
                          if (selected == true) other.id,
                        ];
                        if (hajjWouldCreateDependencyCycle(
                          milestoneId: milestoneId,
                          dependsOn: next,
                          all: [
                            ...journey.milestones,
                            if (existing == null)
                              HajjMilestone(id: milestoneId),
                          ],
                        )) {
                          setState(
                            () => cycleMessage = Copy.hajjDependencyCycle,
                          );
                          return;
                        }
                        setState(() {
                          dependsOn = next;
                          cycleMessage = '';
                        });
                      },
                    ),
                  if (cycleMessage.isNotEmpty)
                    Text(cycleMessage, key: const Key('hajj-dep-cycle')),
                  if (error.isNotEmpty)
                    Text(error, key: const Key('hajj-milestone-error')),
                  if (existing != null)
                    TextButton(
                      key: const Key('hajj-milestone-delete'),
                      onPressed: () => Navigator.pop(context, 'delete'),
                      child: const Text('Delete milestone'),
                    ),
                  FilledButton(
                    key: const Key('hajj-milestone-save'),
                    onPressed: () {
                      if (title.text.trim().isEmpty) {
                        setState(() => error = Copy.hajjMilestoneTitleRequired);
                        return;
                      }
                      if (!unscheduled) {
                        final officialText = official.text.trim();
                        final plannedText = planned.text.trim();
                        if (officialText.isEmpty && plannedText.isEmpty) {
                          setState(
                            () => error = Copy.hajjMilestoneDateRequired,
                          );
                          return;
                        }
                        if (!isOptionalHajjDateKey(officialText) ||
                            !isOptionalHajjDateKey(plannedText)) {
                          setState(() => error = Copy.hajjMilestoneDateInvalid);
                          return;
                        }
                      }
                      Navigator.pop(context, true);
                    },
                    child: const Text('Save milestone'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  if (saved == 'delete' && existing != null) {
    await persistHajjStore(ref, (store) {
      final current = store.selectedJourney ?? journey;
      return store.upsertJourney(
        current.copyWith(
          milestones: [
            for (final item in current.milestones)
              if (item.id != existing.id) item,
          ],
        ),
      );
    });
    return;
  }
  if (saved != true) return;
  await persistHajjStore(ref, (store) {
    final current = store.selectedJourney ?? journey;
    final draft = HajjMilestone(
      id: milestoneId,
      title: _blankToNull(title.text),
      officialDeadline: unscheduled
          ? null
          : (existing?.officialDeadline == official.text.trim()
                ? existing?.officialDeadline
                : _blankToNull(official.text)),
      plannedDate: unscheduled ? null : _blankToNull(planned.text),
      plannedDateCertainty: unscheduled ? HajjDateCertainty.unknown : certainty,
      processingDurationDays: int.tryParse(processing.text.trim()),
      bufferDays: int.tryParse(float.text.trim()),
      status: status,
      dependsOn: dependsOn,
      travelerIds: existing?.travelerIds ?? const [],
      templateId: existing?.templateId,
    );
    return store.upsertJourney(
      recalculateJourneyMilestones(
        current.copyWith(
          milestones: _upsertMilestone(current.milestones, draft),
        ),
      ),
    );
  });
}

List<HajjMilestone> _upsertMilestone(
  List<HajjMilestone> items,
  HajjMilestone next,
) {
  var replaced = false;
  final updated = <HajjMilestone>[];
  for (final item in items) {
    if (item.id == next.id) {
      updated.add(next);
      replaced = true;
    } else {
      updated.add(item);
    }
  }
  if (!replaced) updated.add(next);
  return updated;
}

String? _blankToNull(String text) {
  final trimmed = text.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int? _optIntText(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  return int.tryParse(trimmed);
}

Widget _hajjEditorSheet({
  required BuildContext context,
  required Widget child,
}) {
  final media = MediaQuery.of(context);
  return Padding(
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      top: 8,
      bottom: media.viewInsets.bottom + media.padding.bottom + 24,
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.82),
      child: child,
    ),
  );
}
