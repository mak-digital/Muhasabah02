import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/hajj_pathway.dart';
import 'package:muhasabah02/domain/hajj_planning.dart';
import 'package:muhasabah02/domain/hajj_planning_engine.dart';
import 'package:muhasabah02/domain/hajj_planning_math.dart';
import 'package:muhasabah02/domain/hajj_readiness_catalog.dart';

void main() {
  const today = '2026-10-17';

  HajjTravelerProfile traveler({
    required String id,
    String? nationality,
    String? residence,
    String? passport,
    String? residenceExpiry,
  }) {
    return HajjTravelerProfile(
      id: id,
      nationalityCountry: nationality,
      residenceCountry: residence,
      passportExpiryDate: passport,
      residenceExpiryDate: residenceExpiry,
      readiness: seededHajjTravelerReadiness(id),
    );
  }

  HajjJourney journey({
    String departure = 'GB',
    String returning = 'GB',
    List<String> travelerIds = const ['a'],
    String? departDate = '2027-05-20',
  }) {
    return HajjJourney(
      id: 'j1',
      departureCountry: departure,
      returnCountry: returning,
      intendedDepartureDate: departDate,
      travelerIds: travelerIds,
      readiness: seededHajjReadiness(),
      horizonMonths: 12,
    );
  }

  test('all six planning pathway families can be suggested', () {
    final mixed = journey(departure: 'SA', travelerIds: ['sa', 'gb', 'pk']);
    final people = [
      traveler(id: 'sa', nationality: 'SA', residence: 'SA'),
      traveler(id: 'gb', nationality: 'GB', residence: 'AE'),
      traveler(id: 'pk', nationality: 'PK', residence: 'AE'),
    ];
    final names = {
      for (final item in suggestHajjPathways(journey: mixed, travelers: people))
        item.family,
    };
    expect(names, containsAll(HajjPathwayFamily.values));
    expect(names.length, HajjPathwayFamily.values.length);
  });

  test(
    'expatriate and mixed-nationality cases are suggested, not auto-selected',
    () {
      final result = suggestHajjPathways(
        journey: journey(travelerIds: ['a', 'b']),
        travelers: [
          traveler(id: 'a', nationality: 'GB', residence: 'AE'),
          traveler(id: 'b', nationality: 'PK', residence: 'AE'),
        ],
      );
      expect(
        result.map((item) => item.family),
        containsAll([
          HajjPathwayFamily.expatriate,
          HajjPathwayFamily.mixedFamily,
        ]),
      );
      expect(journey().planning.pathwaysConfirmedByUser, isFalse);
    },
  );

  test('unknown registration route stays unconfirmed', () {
    final empty = HajjJourney(id: 'j2');
    expect(suggestHajjPathways(journey: empty, travelers: const []), isEmpty);
    final summary = buildHajjJourneyPlanSummary(
      journey: empty,
      travelers: const [],
      todayKey: today,
    );
    expect(summary.unknownRoute, isTrue);
  });

  test('missing and expired travel documents are notices, not neglect', () {
    final missing = hajjTravelerDocumentNotice(
      traveler(id: 'a', nationality: 'GB', residence: 'GB'),
      todayKey: today,
    );
    expect(missing?.kind, HajjDocumentAttention.missing);
    final expired = hajjTravelerDocumentNotice(
      traveler(
        id: 'b',
        nationality: 'GB',
        residence: 'GB',
        passport: '2025-01-01',
      ),
      todayKey: today,
    );
    expect(expired?.kind, HajjDocumentAttention.expired);
  });

  test(
    'backward scheduling, float, official preservation and critical path',
    () {
      var plan = applyHajjPreparationTemplates(journey());
      expect(plan.milestones.length, kHajjPreparationTemplates.length);
      expect(
        plan.milestones.every((item) => item.officialDeadline == null),
        isTrue,
      );
      expect(
        plan.milestones.every(
          (item) => item.notes == kHajjPlanningEstimateNote,
        ),
        isTrue,
      );
      final passport = plan.milestones.firstWhere(
        (item) => item.templateId == 'tpl.documents',
      );
      expect(passport.recommendedCompletionDate, isNotNull);
      expect(passport.dependsOn, isNotEmpty);
      final official = '2027-01-15';
      plan = plan.copyWith(
        milestones: [
          for (final item in plan.milestones)
            if (item.templateId == 'tpl.documents')
              item.copyWith(
                officialDeadline: official,
                processingDurationDays: 40,
                bufferDays: 5,
              )
            else
              item,
        ],
      );
      plan = recalculateJourneyMilestones(plan);
      final after = plan.milestones.firstWhere(
        (item) => item.templateId == 'tpl.documents',
      );
      expect(after.officialDeadline, official);
      expect(
        hajjMilestoneDateKind(after),
        HajjMilestoneDateKind.officialEntered,
      );
      expect(hajjInsufficientFloat(after), isTrue);
      expect(hajjCriticalPathIds(plan.milestones), isNotEmpty);
      expect(
        hajjEngineConflicts(plan).any((item) => item.message.contains('float')),
        isTrue,
      );
    },
  );

  test('multiple travelers keep independent document and readiness state', () {
    final a = traveler(id: 'a', nationality: 'GB', residence: 'GB');
    final b = withSeededTravelerReadiness(
      traveler(id: 'b', nationality: 'PK', residence: 'AE'),
    );
    expect(
      a.readiness.map((item) => item.id),
      isNot(equals(b.readiness.map((item) => item.id))),
    );
    expect(a.nationalityCountry, isNot(b.nationalityCountry));
    expect(a.residenceCountry, isNot(b.residenceCountry));
  });

  test('standard, early, and different-country returns compare costs without assuming refunds', () {
    final plan = HajjJourneyReturnPlan(
      standard: const HajjReturnScenario(
        kind: HajjReturnScenarioKind.standardPackage,
        packageCost: 10000,
        confirmedRefunds: 0,
      ),
      earlyAfterRites: const HajjReturnScenario(
        kind: HajjReturnScenarioKind.earlyAfterRites,
        packageCost: 10000,
        changeFees: 800,
        extraTransport: 200,
        confirmedRefunds: 0,
      ),
      differentCountry: const HajjReturnScenario(
        kind: HajjReturnScenarioKind.differentCountry,
        packageCost: 10000,
        extraTransport: 1500,
        extraAccommodation: 400,
        confirmedRefunds: 250,
      ),
    );
    final compared = compareHajjReturnScenarios(plan);
    expect(compared, hasLength(3));
    expect(compared[0].totalEstimated, 10000);
    expect(compared[1].totalEstimated, 11000);
    expect(compared[2].totalEstimated, 11650);
    expect(
      compared.every((item) => item.unusedPackageRefundAssumed == false),
      isTrue,
    );
    expect(
      compared.every((item) => item.ritesOmissionSuggested == false),
      isTrue,
    );
    expect(kHajjUnusedPackageNotRefundable, contains('not assumed refundable'));
    expect(kHajjRitesMustNotBeOmitted, contains('required Hajj rites'));
  });

  test('Phase 1 JSON still loads after additive planning fields', () {
    const raw = '''
{"schemaVersion":1,"standing":{"kind":"believeDue"},"standingHistory":[],"travelers":[],"journeys":[{"id":"j1","lifecycle":"considering","archived":false,"targetSeason":{"datesUnknown":true},"routeTags":[],"countries":[],"datesUnknown":true,"dateCertainty":"unknown","travelerIds":[],"readiness":[],"milestones":[],"sourceIds":[],"providers":[],"travelLegs":[],"returnPlan":{}}],"sources":[],"afterHajj":{"continuingPracticeIds":[],"returnIntention":"unanswered"},"providers":[],"activeJourneyId":"j1","learningProgress":[]}
''';
    final decoded = decodeHajjStore(raw);
    expect(decoded.kind, HajjStoreDecodeKind.ok);
    expect(decoded.store!.schemaVersion, 1);
    expect(
      decoded.store!.selectedJourney?.planning.pathwaysConfirmedByUser,
      isFalse,
    );
  });

  test('planning engine is offline and does not invent official deadlines', () {
    final plan = applyHajjPreparationTemplates(
      journey(departDate: '2027-06-01'),
    );
    expect(
      plan.milestones.any((item) => item.officialDeadline != null),
      isFalse,
    );
    final json = encodeHajjStore(const HajjStore().upsertJourney(plan));
    expect(json.contains('http'), isFalse);
  });
}
