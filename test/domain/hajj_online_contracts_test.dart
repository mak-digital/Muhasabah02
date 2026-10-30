import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/hajj_online_assist.dart';
import 'package:muhasabah02/domain/hajj_online_contracts.dart';
import 'package:muhasabah02/domain/hajj_planning.dart';
import 'package:muhasabah02/domain/hajj_source_catalog.dart';

void main() {
  const today = '2026-10-18';
  const manager = HajjConsentManager();
  const reviewer = HajjProposedPlanChangeReviewer();
  const resolver = LocalHajjPathwayResolver();

  test('consent denial and revocation block requests', () {
    const off = HajjOnlineAssistConsent();
    expect(manager.mayLookup(off), isFalse);
    expect(manager.mayInterpret(off), isFalse);
    final on = manager.apply(
      current: off,
      lookup: true,
      ai: true,
      nowIso: '2026-10-18T00:00:00Z',
    );
    expect(on.anyOnline, isTrue);
    final revoked = manager.apply(
      current: on,
      lookup: false,
      ai: false,
      nowIso: '2026-10-18T01:00:00Z',
    );
    expect(revoked.anyOnline, isFalse);
    expect(revoked.revokedAt, isNotNull);
  });

  test('minimum payload omits names, health, reflections and passports', () {
    final request = buildHajjLookupRequest(
      journey: const HajjJourney(
        id: 'j1',
        departureCountry: 'AE',
        returnCountry: 'GB',
        travelerIds: ['a', 'b'],
      ),
      travelers: const [
        HajjTravelerProfile(
          id: 'a',
          displayName: 'Must not travel',
          nationalityCountry: 'PK',
          residenceCountry: 'AE',
          citizenships: ['PK', 'GB'],
          healthPreparationNote: 'private',
          notes: 'secret',
        ),
        HajjTravelerProfile(
          id: 'b',
          displayName: 'Companion',
          nationalityCountry: 'GB',
          residenceCountry: 'AE',
        ),
      ],
    );
    final payload = request.toPayload();
    expect(manager.payloadKeysAllowed(payload), isTrue);
    expect(payload.containsKey('displayName'), isFalse);
    expect(payload['nationalityCountries'], ['GB', 'PK']);
    expect(payload['citizenships'], ['GB', 'PK']);
    expect(payload['returnCountry'], 'GB');
  });

  test('unknown country still returns Saudi portals and questions', () {
    final resolution = resolver.resolve(const HajjPathwayResolutionQuery());
    expect(resolution.unknownInputs, isNotEmpty);
    expect(
      resolution.sources.any((item) => item.id == 'reg.sa.hajj.ministry'),
      isTrue,
    );
    expect(
      resolution.confirmationQuestions.join(' '),
      contains('does not declare visa eligibility'),
    );
  });

  test('PK nationality with AE residence is not treated as GB', () {
    final resolution = resolver.resolve(
      const HajjPathwayResolutionQuery(
        nationalityCountries: ['PK'],
        residenceCountries: ['AE'],
        departureCountry: 'AE',
        season: '1448',
        pathwayIds: ['expatriate'],
      ),
    );
    final ids = resolution.sources.map((item) => item.id).toSet();
    expect(ids, contains('reg.pk.mora'));
    expect(ids, contains('reg.ae.awqaf'));
    expect(ids, isNot(contains('reg.gb.mission')));
  });

  test('multiple passports ask which document to present', () {
    final resolution = resolver.resolve(
      const HajjPathwayResolutionQuery(
        nationalityCountries: ['PK'],
        citizenships: ['PK', 'GB'],
        residenceCountries: ['AE'],
        departureCountry: 'AE',
        travelerCount: 1,
      ),
    );
    expect(
      resolution.confirmationQuestions.join(' '),
      contains('Which document would you present'),
    );
  });

  test('stale missing and conflicting sources are not auto-chosen', () {
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
    const service = LocalHajjSourceVerificationService();
    expect(
      service.assess(stale, todayKey: today).freshness,
      HajjFreshness.stale,
    );
    expect(
      service.assess(stale, todayKey: today).interpretationIsOfficial,
      isFalse,
    );
    expect(hajjConflictingSourceDeadlines([stale, other]), isNotEmpty);
  });

  test('unverified providers are never labelled authorised', () {
    const fake = HajjProviderSlot(
      id: 'p1',
      name: 'Invented',
      officiallyAuthorized: true,
      demonstration: true,
    );
    expect(hajjProviderMayBeCalledAuthorized(fake), isFalse);
  });

  test('AI without official evidence still requires user approval', () async {
    final proposal = await const DemoHajjAIInterpretationGateway().interpret(
      request: const HajjLookupRequest(nationalityCountry: 'PK'),
      todayKey: today,
    );
    expect(proposal.requiresUserApproval, isTrue);
    expect(proposal.extractedRequirement, isNull);
    expect(proposal.uncertaintyNote, contains('will not invent'));
    expect(proposal.detail, contains(kHajjDemoNoLiveVerification));
  });

  test('rejecting a proposal leaves standing and milestones unchanged', () {
    const journey = HajjJourney(id: 'j1');
    const store = HajjStore(
      journeys: [journey],
      activeJourneyId: 'j1',
      pendingProposals: [
        HajjPlanProposal(id: 'p1', title: 'Ask', detail: 'demo'),
      ],
    );
    final rejected = reviewer.reject(store, store.pendingProposals.single);
    expect(rejected.pendingProposals.single.dismissed, isTrue);
    expect(rejected.selectedJourney!.milestones, isEmpty);
    expect(rejected.standing.kind, store.standing.kind);
  });

  test(
    'sensitive keys and extra keys are rejected by the consent contract',
    () {
      expect(manager.payloadKeysAllowed({'season': '1448'}), isTrue);
      expect(
        manager.payloadKeysAllowed({'passportNumber': 'X', 'season': '1448'}),
        isFalse,
      );
      expect(manager.payloadKeysAllowed({'reflection': 'no'}), isFalse);
      expect(manager.payloadKeysAllowed({'displayName': 'A'}), isFalse);
    },
  );

  test('demo lookup labels every source as unverified demonstration', () async {
    final bundle = await const DemoHajjOnlineAssistGateway().lookupOfficial(
      const HajjLookupRequest(nationalityCountry: 'PK', residenceCountry: 'AE'),
    );
    expect(bundle.sources, isNotEmpty);
    expect(
      bundle.sources.every(
        (item) =>
            item.demonstration &&
            item.verificationStatus == HajjVerificationStatus.unverified &&
            (item.title?.contains(kHajjDemoNoLiveVerification) ?? false),
      ),
      isTrue,
    );
    expect(bundle.providers, isEmpty);
    expect(bundle.message, kHajjDemoNoLiveVerification);
  });

  test('bundled registry contains no quotas or registration dates', () {
    for (final entry in kBundledHajjRegistrySources) {
      expect(entry.officialUrl, startsWith('https://'));
      expect(entry.notes ?? '', isNot(contains('quota')));
    }
  });
}
