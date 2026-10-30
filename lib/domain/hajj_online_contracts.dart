import 'hajj_online_assist.dart';
import 'hajj_planning.dart';
import 'hajj_source_catalog.dart';

const kHajjAllowedPayloadKeys = {
  'season',
  'nationalityCountry',
  'nationalityCountries',
  'residenceCountry',
  'residenceCountries',
  'departureCountry',
  'returnCountry',
  'pathwayIds',
  'citizenships',
};

enum HajjAuthenticity { unknown, officialPortalBookmark, userMarked }

enum HajjFreshness { unknown, current, stale }

enum HajjApplicability { unknown, possiblyRelevant, notApplicable }

class HajjSourceAssessment {
  const HajjSourceAssessment({
    required this.authenticity,
    required this.freshness,
    required this.applicability,
    this.interpretationIsOfficial = false,
  });

  final HajjAuthenticity authenticity;
  final HajjFreshness freshness;
  final HajjApplicability applicability;

  /// Always false for AI and demonstration bookmarks.
  final bool interpretationIsOfficial;
}

class HajjPathwayResolutionQuery {
  const HajjPathwayResolutionQuery({
    this.nationalityCountries = const [],
    this.residenceCountries = const [],
    this.citizenships = const [],
    this.departureCountry,
    this.returnCountry,
    this.season,
    this.pathwayIds = const [],
    this.travelerCount = 0,
  });

  final List<String> nationalityCountries;
  final List<String> residenceCountries;
  final List<String> citizenships;
  final String? departureCountry;
  final String? returnCountry;
  final String? season;
  final List<String> pathwayIds;
  final int travelerCount;

  Set<String> get _nats => {
    for (final item in [...nationalityCountries, ...citizenships])
      item.trim().toUpperCase(),
  }.difference({''});

  Set<String> get _res =>
      {for (final item in residenceCountries) item.trim().toUpperCase()}
          .difference({''});
}

class HajjPathwayResolution {
  const HajjPathwayResolution({
    this.sources = const [],
    this.confirmationQuestions = const [],
    this.unknownInputs = const [],
  });

  final List<HajjRegistrySource> sources;
  final List<String> confirmationQuestions;
  final List<String> unknownInputs;
}

abstract class HajjOfficialSourceGateway {
  Future<HajjLookupBundle> lookup(HajjLookupRequest request);
}

abstract class HajjSourceVerificationService {
  HajjSourceAssessment assess(
    HajjOfficialSource source, {
    required String todayKey,
  });
}

abstract class HajjPathwayResolver {
  HajjPathwayResolution resolve(HajjPathwayResolutionQuery query);
}

abstract class HajjProviderDirectoryGateway {
  Future<List<HajjProviderSlot>> lookup(HajjLookupRequest request);
}

abstract class HajjAIInterpretationGateway {
  Future<HajjPlanProposal> interpret({
    required HajjLookupRequest request,
    required String todayKey,
    List<HajjOfficialSource> storedSources,
  });
}

class LocalHajjSourceVerificationService
    implements HajjSourceVerificationService {
  const LocalHajjSourceVerificationService();

  @override
  HajjSourceAssessment assess(
    HajjOfficialSource source, {
    required String todayKey,
  }) {
    final stale = hajjSourceIsStale(source, todayKey: todayKey);
    return HajjSourceAssessment(
      authenticity: source.demonstration
          ? HajjAuthenticity.officialPortalBookmark
          : source.verificationStatus == HajjVerificationStatus.verifiedByUser
          ? HajjAuthenticity.userMarked
          : HajjAuthenticity.unknown,
      freshness: stale ? HajjFreshness.stale : HajjFreshness.unknown,
      applicability: HajjApplicability.possiblyRelevant,
      interpretationIsOfficial: false,
    );
  }
}

class LocalHajjPathwayResolver implements HajjPathwayResolver {
  const LocalHajjPathwayResolver({
    this.registry = const BundledHajjSourceRegistry(),
  });

  final HajjSourceRegistry registry;

  @override
  HajjPathwayResolution resolve(HajjPathwayResolutionQuery query) {
    final nats = query._nats;
    final res = query._res;
    final dep = {
      if (query.departureCountry != null &&
          query.departureCountry!.trim().isNotEmpty)
        query.departureCountry!.trim().toUpperCase(),
    };
    final ret = {
      if (query.returnCountry != null && query.returnCountry!.trim().isNotEmpty)
        query.returnCountry!.trim().toUpperCase(),
    };
    final unknown = <String>[];
    if (nats.isEmpty) unknown.add('nationality');
    if (res.isEmpty) unknown.add('residence');
    if (dep.isEmpty) unknown.add('departure');
    if (query.season == null || query.season!.trim().isEmpty) {
      unknown.add('season');
    }
    if (query.pathwayIds.isEmpty) unknown.add('planning pathway');

    final sources = registry.relevantTo(
      nationalityCodes: nats,
      residenceCodes: res,
      departureCodes: dep,
      returnCodes: ret,
      pathwayIds: query.pathwayIds,
    );

    final questions = <String>[
      if (unknown.isNotEmpty)
        'Official requirements are unknown until you record: ${unknown.join(', ')}.',
      if (query.citizenships.length > 1) 'More than one passport country is recorded. Which document would you present? The app does not choose.',
      if (nats.length > 1 ||
          (query.travelerCount > 1 && nats.length != res.length))
        'Companions may have different nationalities or residences. Confirm each person’s route separately. This is not an eligibility decision.',
      if (dep.isNotEmpty && ret.isNotEmpty && dep.first != ret.first) 'Return country differs from departure. Confirm entry and visa conditions on official sites for both.',
      'The app does not declare visa eligibility, registration entitlement, or religious obligation.',
    ];

    return HajjPathwayResolution(
      sources: sources,
      confirmationQuestions: questions,
      unknownInputs: unknown,
    );
  }
}

class HajjConsentManager {
  const HajjConsentManager();

  bool mayLookup(HajjOnlineAssistConsent consent) => consent.lookupConsented;

  bool mayInterpret(HajjOnlineAssistConsent consent) => consent.aiConsented;

  HajjOnlineAssistConsent apply({
    required HajjOnlineAssistConsent current,
    bool? lookup,
    bool? ai,
    required String nowIso,
  }) {
    final nextLookup = lookup ?? current.lookupConsented;
    final nextAi = ai ?? current.aiConsented;
    return HajjOnlineAssistConsent(
      lookupConsented: nextLookup,
      aiConsented: nextAi,
      acknowledgedAt: (nextLookup || nextAi)
          ? (current.acknowledgedAt ?? nowIso)
          : current.acknowledgedAt,
      revokedAt: (!nextLookup && !nextAi) ? nowIso : null,
    );
  }

  bool payloadKeysAllowed(Map<String, Object?> payload) {
    for (final key in payload.keys) {
      if (!kHajjAllowedPayloadKeys.contains(key)) return false;
    }
    return hajjOnlinePayloadIsSafe(payload);
  }
}

class HajjProposedPlanChangeReviewer {
  const HajjProposedPlanChangeReviewer();

  HajjStore accept(HajjStore store, HajjPlanProposal proposal) {
    if (proposal.dismissed) return store;
    final journey = store.selectedJourney;
    if (journey == null) return store;
    return store
        .upsertJourney(acceptHajjPlanProposal(journey, proposal))
        .copyWith(
          pendingProposals: [
            for (final item in store.pendingProposals)
              if (item.id == proposal.id)
                item.copyWith(accepted: true)
              else
                item,
          ],
        );
  }

  HajjStore reject(HajjStore store, HajjPlanProposal proposal) {
    return store.copyWith(
      pendingProposals: [
        for (final item in store.pendingProposals)
          if (item.id == proposal.id) item.copyWith(dismissed: true) else item,
      ],
    );
  }
}

class EmptyHajjProviderDirectoryGateway
    implements HajjProviderDirectoryGateway {
  const EmptyHajjProviderDirectoryGateway();

  @override
  Future<List<HajjProviderSlot>> lookup(HajjLookupRequest request) async {
    if (!hajjOnlinePayloadIsSafe(request.toPayload())) {
      throw HajjOnlineAssistException('Request contained private fields.');
    }
    return const [];
  }
}

/// Adapts the on-device demo gateway to the split contracts. No HTTP.
class DemoHajjOfficialSourceGateway implements HajjOfficialSourceGateway {
  const DemoHajjOfficialSourceGateway({
    this.inner = const DemoHajjOnlineAssistGateway(),
  });

  final DemoHajjOnlineAssistGateway inner;

  @override
  Future<HajjLookupBundle> lookup(HajjLookupRequest request) {
    return inner.lookupOfficial(request);
  }
}

class DemoHajjAIInterpretationGateway implements HajjAIInterpretationGateway {
  const DemoHajjAIInterpretationGateway({
    this.inner = const DemoHajjOnlineAssistGateway(),
  });

  final DemoHajjOnlineAssistGateway inner;

  @override
  Future<HajjPlanProposal> interpret({
    required HajjLookupRequest request,
    required String todayKey,
    List<HajjOfficialSource> storedSources = const [],
  }) async {
    final proposal = await inner.interpret(
      request: request,
      todayKey: todayKey,
    );
    final verifiedOfficial = storedSources.where(
      (item) =>
          !item.demonstration &&
          item.verificationStatus == HajjVerificationStatus.verifiedByUser,
    );
    if (verifiedOfficial.isEmpty) return proposal;
    final conflicts = hajjConflictingSourceDeadlines(storedSources);
    if (conflicts.isEmpty) return proposal;
    return HajjPlanProposal(
      id: proposal.id,
      title: proposal.title,
      detail: proposal.detail,
      origin: proposal.origin,
      milestoneTitle: proposal.milestoneTitle,
      sourceIds: proposal.sourceIds,
      uncertaintyNote: conflicts.join(' '),
      requiresUserApproval: true,
      retrievedAt: todayKey,
    );
  }
}
