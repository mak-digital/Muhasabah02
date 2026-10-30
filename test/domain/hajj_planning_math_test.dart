import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/hajj_learning_catalog.dart';
import 'package:muhasabah02/domain/hajj_planning.dart';
import 'package:muhasabah02/domain/hajj_planning_math.dart';
import 'package:muhasabah02/domain/hajj_readiness_catalog.dart';
import 'package:muhasabah02/domain/reflection_source.dart';

void main() {
  test('journey create edit archive delete leave standing unchanged', () async {
    final repo = MemoryHajjStoreRepository();
    await repo.initializeIfNeeded();
    var store = repo.store.withStanding(
      HajjStandingKind.performed,
      recordedAt: '2026-01-01',
    );
    store = store.upsertJourney(
      HajjJourney(id: 'j1', readiness: seededHajjReadiness()),
    );
    expect(store.standing.kind, HajjStandingKind.performed);
    expect(store.selectedJourney?.id, 'j1');

    store = store.upsertJourney(
      store.selectedJourney!.copyWith(
        lifecycle: HajjJourneyLifecycle.planning,
        datesUnknown: true,
        dateCertainty: HajjDateCertainty.unknown,
      ),
    );
    expect(store.journeys.single.lifecycle, HajjJourneyLifecycle.planning);
    expect(store.standing.kind, HajjStandingKind.performed);

    store = store.archiveJourney('j1');
    expect(store.journeys.single.archived, isTrue);
    expect(store.visibleJourneys, isEmpty);

    store = store.deleteJourney('j1');
    expect(store.journeys, isEmpty);
    expect(store.activeJourneyId, isNull);
    expect(store.standing.kind, HajjStandingKind.performed);
  });

  test('multiple travelers keep separate nationality and residence', () {
    var store = const HajjStore()
        .upsertTraveler(
          const HajjTravelerProfile(
            id: 't1',
            role: HajjTravelerRole.self,
            nationalityCountry: 'GB',
            residenceCountry: 'AE',
          ),
        )
        .upsertTraveler(
          const HajjTravelerProfile(
            id: 't2',
            role: HajjTravelerRole.spouse,
            nationalityCountry: 'PK',
            residenceCountry: 'GB',
          ),
        )
        .upsertJourney(const HajjJourney(id: 'j1', travelerIds: ['t1', 't2']));
    expect(store.travelers[0].nationalityCountry, 'GB');
    expect(store.travelers[0].residenceCountry, 'AE');
    expect(store.travelers[1].nationalityCountry, 'PK');
    store = store.upsertTraveler(
      store.travelers[0].copyWith(
        readinessStatus: HajjReadinessStatus.confirmedReady,
      ),
    );
    expect(
      store.travelers[0].readinessStatus,
      HajjReadinessStatus.confirmedReady,
    );
    expect(store.travelers[1].readinessStatus, HajjReadinessStatus.unanswered);
  });

  test('readiness confirmed by user is not official verification', () {
    final item = HajjReadinessPrerequisite(
      id: 'rdy.passport.valid',
      status: HajjReadinessStatus.confirmedReady,
      confirmedByUser: true,
    );
    expect(item.status.label, 'Confirmed by user');
    expect(HajjReadinessStatus.unknown.label, 'Needs verification');
    expect(HajjReadinessStatus.notApplicable.label, 'Not applicable');
    expect(item.confirmedByUser, isTrue);
  });

  test(
    'milestone dependencies and date recalculation preserve official deadline',
    () {
      final official = HajjMilestone(
        id: 'm1',
        title: 'Apply',
        officialDeadline: '2026-06-30',
        processingDurationDays: 10,
        bufferDays: 5,
        status: HajjMilestoneStatus.pending,
      );
      final calculated = recalculateHajjMilestone(official);
      expect(calculated.officialDeadline, '2026-06-30');
      expect(calculated.recommendedCompletionDate, '2026-06-25');
      expect(calculated.recommendedStartDate, '2026-06-15');

      final changedFloat = recalculateHajjMilestone(
        calculated.copyWith(bufferDays: 2),
      );
      expect(changedFloat.officialDeadline, '2026-06-30');
      expect(changedFloat.recommendedCompletionDate, '2026-06-28');

      final later = HajjMilestone(
        id: 'm2',
        title: 'Travel',
        dependsOn: ['m1'],
        status: HajjMilestoneStatus.pending,
      );
      expect(hajjMilestoneDependenciesMet(later, [calculated, later]), isFalse);
      expect(
        hajjMilestoneDependenciesMet(later, [
          calculated.copyWith(status: HajjMilestoneStatus.done),
          later,
        ]),
        isTrue,
      );
    },
  );

  test('unknown travel dates and horizon months stay local', () {
    const journey = HajjJourney(
      id: 'j1',
      datesUnknown: true,
      dateCertainty: HajjDateCertainty.unknown,
      horizonMonths: 9,
    );
    expect(journey.datesUnknown, isTrue);
    expect(clampHajjHorizonMonths(journey.horizonMonths), 9);
    expect(clampHajjHorizonMonths(3), 6);
    final months = hajjCalendarMonths(
      from: DateTime(2026, 10, 17),
      horizonMonths: 12,
      milestones: const [],
    );
    expect(months.length, 12);
    expect(months.first.monthKey, '2026-10');
  });

  test('Phase 1 JSON still loads after additive Phase 2 fields', () {
    final raw = jsonEncode({
      'schemaVersion': 1,
      'standing': {'kind': 'preparing'},
      'journeys': [
        {'id': 'legacy', 'lifecycle': 'considering', 'datesUnknown': true},
      ],
    });
    final decoded = decodeHajjStore(raw);
    expect(decoded.kind, HajjStoreDecodeKind.ok);
    expect(decoded.store!.standing.kind, HajjStandingKind.preparing);
    expect(decoded.store!.journeys.single.archived, isFalse);
    expect(decoded.store!.learningProgress, isEmpty);
  });

  test('offline persistence round-trips a planned journey', () async {
    final original = const HajjStore()
        .upsertTraveler(
          const HajjTravelerProfile(
            id: 't1',
            nationalityCountry: 'GB',
            residenceCountry: 'QA',
          ),
        )
        .upsertJourney(
          HajjJourney(
            id: 'j1',
            travelerIds: const ['t1'],
            readiness: seededHajjReadiness(),
            milestones: [
              recalculateHajjMilestone(
                const HajjMilestone(
                  id: 'm1',
                  officialDeadline: '2027-01-15',
                  bufferDays: 3,
                  processingDurationDays: 7,
                ),
              ),
            ],
          ),
        )
        .copyWith(
          afterHajj: const HajjAfterRecord(
            reflectionText: 'quiet note',
            returnIntention: HajjAfterReturnIntention.notPlanning,
          ),
        )
        .withLearningState('learn.conditions', HajjLearningState.learning);
    final repo = MemoryHajjStoreRepository(store: original);
    await repo.initializeIfNeeded();
    final restart = MemoryHajjStoreRepository(raw: repo.persistedRaw);
    expect(
      restart.store.selectedJourney?.milestones.single.officialDeadline,
      '2027-01-15',
    );
    expect(restart.store.afterHajj.reflectionText, 'quiet note');
    expect(
      restart.store.learningStateFor('learn.conditions'),
      HajjLearningState.learning,
    );
    expect(restart.store.standing.kind, HajjStandingKind.unanswered);
  });

  test('Learn catalog is cited and independent of a journey', () {
    expect(kHajjLearningCatalog.length, 8);
    expect(
      kHajjLearningCatalog.every(
        (item) => reflectionSourceUris(item.source).isNotEmpty,
      ),
      isTrue,
    );
    const store = HajjStore();
    expect(store.journeys, isEmpty);
    expect(store.learningStateFor('learn.ihram'), HajjLearningState.notStarted);
  });

  test('After Hajj stays empty when standing becomes performed', () {
    final store = const HajjStore().withStanding(
      HajjStandingKind.performed,
      recordedAt: '2026-10-17',
    );
    expect(store.afterHajj.isEmpty, isTrue);
  });

  test('self and circular milestone dependencies are rejected', () {
    const a = HajjMilestone(id: 'a', title: 'A', dependsOn: ['b']);
    const b = HajjMilestone(id: 'b', title: 'B');
    expect(
      hajjWouldCreateDependencyCycle(
        milestoneId: 'a',
        dependsOn: ['a'],
        all: const [a, b],
      ),
      isTrue,
    );
    expect(
      hajjWouldCreateDependencyCycle(
        milestoneId: 'b',
        dependsOn: ['a'],
        all: const [a, b],
      ),
      isTrue,
    );
    expect(
      hajjWouldCreateDependencyCycle(
        milestoneId: 'b',
        dependsOn: const [],
        all: const [a, b],
      ),
      isFalse,
    );
  });

  test(
    'dependency change shifts suggested dates and keeps official deadline',
    () {
      const prior = HajjMilestone(
        id: 'm1',
        title: 'Apply',
        officialDeadline: '2026-06-30',
      );
      const later = HajjMilestone(
        id: 'm2',
        title: 'Travel',
        dependsOn: ['m1'],
        officialDeadline: '2026-06-22',
        processingDurationDays: 1,
        bufferDays: 0,
      );
      final withoutDep = recalculateHajjMilestone(later);
      expect(withoutDep.recommendedStartDate, '2026-06-21');
      final journey = recalculateJourneyMilestones(
        const HajjJourney(id: 'j1', milestones: [prior, later]),
      );
      final travel = journey.milestones.singleWhere((item) => item.id == 'm2');
      expect(travel.officialDeadline, '2026-06-22');
      expect(travel.recommendedStartDate, '2026-07-01');
      expect(
        hajjScheduleConflicts(travel, all: journey.milestones),
        isNotEmpty,
      );
    },
  );

  test('date keys reject invalid calendar values', () {
    expect(isValidHajjDateKey('2026-12-01'), isTrue);
    expect(isValidHajjDateKey('2026-13-01'), isFalse);
    expect(isValidHajjDateKey('17/10/2026'), isFalse);
    expect(isOptionalHajjDateKey(''), isTrue);
    expect(isOptionalHajjDateKey('  '), isTrue);
  });

  test('past, beyond-horizon and unscheduled milestones are grouped', () {
    const past = HajjMilestone(id: 'p', officialDeadline: '2026-01-15');
    const beyond = HajjMilestone(id: 'b', officialDeadline: '2028-01-15');
    const open = HajjMilestone(id: 'u');
    expect(
      hajjMilestoneHorizonGroup(past, todayKey: '2026-10-17', horizonMonths: 6),
      HajjMilestoneHorizonGroup.past,
    );
    expect(
      hajjMilestoneHorizonGroup(
        beyond,
        todayKey: '2026-10-17',
        horizonMonths: 6,
      ),
      HajjMilestoneHorizonGroup.beyond,
    );
    expect(
      hajjMilestoneHorizonGroup(open, todayKey: '2026-10-17', horizonMonths: 6),
      HajjMilestoneHorizonGroup.unscheduled,
    );
    expect(
      hajjCalendarMonthInitiallyExpanded(
        monthKey: '2026-10',
        todayKey: '2026-10-17',
        milestones: const [],
      ),
      isTrue,
    );
    expect(
      hajjCalendarMonthInitiallyExpanded(
        monthKey: '2026-12',
        todayKey: '2026-10-17',
        milestones: const [],
      ),
      isFalse,
    );
  });

  test('traveler readiness confirmations stay independent', () {
    final first = withSeededTravelerReadiness(
      const HajjTravelerProfile(id: 't1', role: HajjTravelerRole.self),
    );
    final second = withSeededTravelerReadiness(
      const HajjTravelerProfile(id: 't2', role: HajjTravelerRole.spouse),
    );
    expect(first.readiness.length, 5);
    expect(second.readiness.length, 5);
    expect(first.readiness.first.id, isNot(second.readiness.first.id));
    final confirmed = first.copyWith(
      readiness: [
        for (final item in first.readiness)
          if (item.title == 'Passport validity')
            item.copyWith(
              status: HajjReadinessStatus.confirmedReady,
              confirmedByUser: true,
              confirmationRecordedAt: '2026-10-17T00:00:00.000',
              internalTargetDate: '2026-11-01',
              officialRequirementVerified: false,
            )
          else
            item,
      ],
    );
    expect(
      confirmed.readiness
          .singleWhere((item) => item.title == 'Passport validity')
          .confirmedByUser,
      isTrue,
    );
    expect(
      second.readiness
          .singleWhere((item) => item.title == 'Passport validity')
          .confirmedByUser,
      isFalse,
    );
    final store = const HajjStore()
        .upsertTraveler(confirmed)
        .upsertTraveler(second)
        .upsertJourney(
          const HajjJourney(
            id: 'j1',
            travelerIds: ['t1', 't2'],
            milestones: [
              HajjMilestone(id: 'shared', travelerIds: ['t1', 't2']),
            ],
          ),
        );
    expect(store.journeys.single.milestones.single.travelerIds, ['t1', 't2']);
    expect(
      store.travelers
          .singleWhere((item) => item.id == 't2')
          .readiness
          .singleWhere((item) => item.title == 'Passport validity')
          .status,
      HajjReadinessStatus.unanswered,
    );
    final encoded = encodeHajjStore(store);
    final decoded = decodeHajjStore(encoded);
    expect(
      decoded.store!.travelers
          .singleWhere((item) => item.id == 't1')
          .readiness
          .singleWhere((item) => item.title == 'Passport validity')
          .internalTargetDate,
      '2026-11-01',
    );
    expect(
      decoded.store!.travelers
          .singleWhere((item) => item.id == 't1')
          .readiness
          .singleWhere((item) => item.title == 'Passport validity')
          .officialRequirementVerified,
      isFalse,
    );
  });
}
