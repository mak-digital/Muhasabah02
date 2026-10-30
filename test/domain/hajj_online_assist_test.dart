import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/hajj_online_assist.dart';
import 'package:muhasabah02/domain/hajj_planning.dart';
import 'package:muhasabah02/domain/hajj_planning_engine.dart';

void main() {
  const today = '2026-10-18';

  test('untitled milestones are excluded from the critical path', () {
    const untitled = HajjMilestone(id: 'old', title: 'Milestone');
    const named = HajjMilestone(
      id: 'new',
      title: 'Passport',
      processingDurationDays: 10,
    );
    expect(hajjMilestoneIsLegacyUntitled(untitled), isTrue);
    expect(hajjCriticalPathIds([untitled, named]), ['new']);
  });

  test('missing return costs are not estimated; explicit zero is kept', () {
    const empty = HajjReturnScenario(
      kind: HajjReturnScenarioKind.standardPackage,
    );
    const zero = HajjReturnScenario(
      kind: HajjReturnScenarioKind.standardPackage,
      packageCost: 0,
    );
    expect(_optional(empty), isNull);
    expect(hajjReturnScenarioTotal(zero), 0);
    final compared = compareHajjReturnScenarios(
      const HajjJourneyReturnPlan(standard: zero),
    );
    expect(compared.first.costsEntered, isTrue);
    expect(compared.first.costLabel, 'Estimate 0');
    expect(
      compareHajjReturnScenarios(const HajjJourneyReturnPlan()).first.costLabel,
      'Not estimated',
    );
  });

  test('offline consent default sends nothing and payload stays minimum', () {
    expect(const HajjOnlineAssistConsent().anyOnline, isFalse);
    final request = buildHajjLookupRequest(
      journey: const HajjJourney(
        id: 'j1',
        departureCountry: 'GB',
        travelerIds: ['a'],
      ),
      travelers: const [
        HajjTravelerProfile(
          id: 'a',
          displayName: 'Must not travel',
          nationalityCountry: 'GB',
          residenceCountry: 'AE',
          passportExpiryDate: '2028-01-01',
          healthPreparationNote: 'private',
          notes: 'secret',
        ),
      ],
    );
    final payload = request.toPayload();
    expect(hajjOnlinePayloadIsSafe(payload), isTrue);
    expect(payload.containsKey('displayName'), isFalse);
    expect(payload.containsKey('healthPreparationNote'), isFalse);
    expect(payload['nationalityCountry'], 'GB');
    expect(payload['residenceCountry'], 'AE');
    expect(payload['departureCountry'], 'GB');
  });

  test('lookup and AI consent are independent; denial blocks the gateway', () {
    const consent = HajjOnlineAssistConsent(lookupConsented: true);
    expect(consent.lookupConsented, isTrue);
    expect(consent.aiConsented, isFalse);
    expect(
      const HajjOnlineAssistConsent()
          .copyWith(lookupConsented: false)
          .anyOnline,
      isFalse,
    );
  });

  test(
    'demonstration lookup never marks sources officially verified',
    () async {
      final bundle = await const DemoHajjOnlineAssistGateway().lookupOfficial(
        const HajjLookupRequest(
          nationalityCountry: 'PK',
          residenceCountry: 'AE',
        ),
      );
      expect(bundle.sources, isNotEmpty);
      expect(
        bundle.sources.every(
          (item) =>
              item.verificationStatus == HajjVerificationStatus.unverified &&
              item.origin == HajjSourceOrigin.demonstration &&
              item.demonstration,
        ),
        isTrue,
      );
      expect(
        bundle.providers.every(
          (item) => !hajjProviderMayBeCalledAuthorized(item),
        ),
        isTrue,
      );
    },
  );

  test('stale and conflicting sources stay distinguishable', () {
    const stale = HajjOfficialSource(
      id: 's1',
      title: 'Window',
      deadline: '2026-01-01',
      retrievedAt: '2025-01-01',
      verificationStatus: HajjVerificationStatus.verifiedByUser,
    );
    const other = HajjOfficialSource(
      id: 's2',
      title: 'Window',
      deadline: '2026-06-01',
      retrievedAt: today,
    );
    expect(hajjSourceIsStale(stale, todayKey: today), isTrue);
    expect(hajjSourceStatusLabel(stale, todayKey: today), 'Outdated');
    expect(hajjConflictingSourceDeadlines([stale, other]), isNotEmpty);
    expect(hajjSourceStatusLabel(other, todayKey: today), 'Unverified');
  });

  test('AI proposal does not change the plan until accepted', () {
    const journey = HajjJourney(id: 'j1');
    const proposal = HajjPlanProposal(
      id: 'p1',
      title: 'Ask',
      detail: 'demo',
      milestoneTitle: 'Ask your mission about the registration window',
    );
    expect(journey.milestones, isEmpty);
    final accepted = acceptHajjPlanProposal(journey, proposal);
    expect(accepted.milestones.single.officialDeadline, isNull);
    expect(accepted.milestones.single.notes, contains('Not an official'));
  });

  test('network failure does not rewrite the store', () async {
    const store = HajjStore();
    expect(
      () => const FailingHajjOnlineAssistGateway().lookupOfficial(
        const HajjLookupRequest(),
      ),
      throwsA(isA<HajjOnlineAssistException>()),
    );
    expect(store.sources, isEmpty);
    expect(store.schemaVersion, 1);
  });

  test('unsafe payloads are rejected before a request', () {
    expect(hajjOnlinePayloadIsSafe({'passportNumber': 'X'}), isFalse);
    expect(hajjOnlinePayloadIsSafe({'season': '1448'}), isTrue);
  });
}

int? _optional(HajjReturnScenario scenario) {
  if (scenario.packageCost == null &&
      scenario.changeFees == null &&
      scenario.extraTransport == null &&
      scenario.extraAccommodation == null &&
      scenario.confirmedRefunds == null) {
    return null;
  }
  return hajjReturnScenarioTotal(scenario);
}
