import 'hajj_planning.dart';
import 'hajj_source_catalog.dart';

const kHajjDemoNoLiveVerification = 'Demo — no live verification';

const kHajjOnlineLookupRecipient =
    'A demonstration catalog on this device (not a live government feed).';
const kHajjOnlineAiRecipient =
    'A demonstration interpreter on this device. No live AI service is configured.';
const kHajjOnlineNoLiveBackend =
    'Live official lookup and paid AI are not enabled. Demonstration records and manual sources stay on this phone.';

const kHajjSensitivePayloadKeys = [
  'passport',
  'passportNumber',
  'scan',
  'reflection',
  'health',
  'displayName',
  'family',
  'notes',
];

class HajjOnlineAssistException implements Exception {
  HajjOnlineAssistException(this.message);
  final String message;
}

class HajjLookupRequest {
  const HajjLookupRequest({
    this.season,
    this.nationalityCountry,
    this.residenceCountry,
    this.departureCountry,
    this.returnCountry,
    this.pathwayIds = const [],
    this.nationalityCountries = const [],
    this.residenceCountries = const [],
    this.citizenships = const [],
  });

  final String? season;
  final String? nationalityCountry;
  final String? residenceCountry;
  final String? departureCountry;
  final String? returnCountry;
  final List<String> pathwayIds;
  final List<String> nationalityCountries;
  final List<String> residenceCountries;
  final List<String> citizenships;

  Map<String, Object?> toPayload() => {
    if (season != null) 'season': season,
    if (nationalityCountry != null) 'nationalityCountry': nationalityCountry,
    if (nationalityCountries.isNotEmpty)
      'nationalityCountries': nationalityCountries,
    if (residenceCountry != null) 'residenceCountry': residenceCountry,
    if (residenceCountries.isNotEmpty) 'residenceCountries': residenceCountries,
    if (departureCountry != null) 'departureCountry': departureCountry,
    if (returnCountry != null) 'returnCountry': returnCountry,
    if (citizenships.isNotEmpty) 'citizenships': citizenships,
    'pathwayIds': pathwayIds,
  };
}

HajjLookupRequest buildHajjLookupRequest({
  required HajjJourney journey,
  required List<HajjTravelerProfile> travelers,
}) {
  final linked = [
    for (final traveler in travelers)
      if (journey.travelerIds.isEmpty ||
          journey.travelerIds.contains(traveler.id))
        traveler,
  ];
  final first = linked.isEmpty ? null : linked.first;
  final nats = <String>{
    for (final traveler in linked)
      if (traveler.nationalityCountry != null &&
          traveler.nationalityCountry!.trim().isNotEmpty)
        traveler.nationalityCountry!.trim().toUpperCase(),
  };
  final res = <String>{
    for (final traveler in linked)
      if (traveler.residenceCountry != null &&
          traveler.residenceCountry!.trim().isNotEmpty)
        traveler.residenceCountry!.trim().toUpperCase(),
  };
  final passports = <String>{
    for (final traveler in linked)
      for (final code in traveler.citizenships)
        if (code.trim().isNotEmpty) code.trim().toUpperCase(),
  };
  return HajjLookupRequest(
    season:
        journey.targetSeason.label ??
        journey.targetSeason.hijriYear?.toString(),
    nationalityCountry: first?.nationalityCountry,
    residenceCountry: first?.residenceCountry,
    departureCountry: journey.departureCountry,
    returnCountry: journey.returnCountry,
    pathwayIds: journey.planning.confirmedPathwayIds,
    nationalityCountries: nats.toList()..sort(),
    residenceCountries: res.toList()..sort(),
    citizenships: passports.toList()..sort(),
  );
}

bool hajjOnlinePayloadIsSafe(Map<String, Object?> payload) {
  for (final key in payload.keys) {
    final lower = key.toLowerCase();
    for (final forbidden in kHajjSensitivePayloadKeys) {
      if (lower.contains(forbidden.toLowerCase())) return false;
    }
  }
  return true;
}

class HajjLookupBundle {
  const HajjLookupBundle({
    this.sources = const [],
    this.providers = const [],
    this.unavailable = false,
    this.message,
  });

  final List<HajjOfficialSource> sources;
  final List<HajjProviderSlot> providers;
  final bool unavailable;
  final String? message;
}

abstract class HajjOnlineAssistGateway {
  Future<HajjLookupBundle> lookupOfficial(HajjLookupRequest request);
  Future<HajjPlanProposal> interpret({
    required HajjLookupRequest request,
    required String todayKey,
  });
}

class DemoHajjOnlineAssistGateway implements HajjOnlineAssistGateway {
  const DemoHajjOnlineAssistGateway({
    this.registry = const BundledHajjSourceRegistry(),
  });

  final HajjSourceRegistry registry;

  @override
  Future<HajjLookupBundle> lookupOfficial(HajjLookupRequest request) async {
    if (!hajjOnlinePayloadIsSafe(request.toPayload())) {
      throw HajjOnlineAssistException('Request contained private fields.');
    }
    final season = request.season ?? 'unspecified';
    final nats = {
      if (request.nationalityCountry != null)
        request.nationalityCountry!.trim().toUpperCase(),
      ...request.nationalityCountries.map((item) => item.trim().toUpperCase()),
    }.difference({''});
    final res = {
      if (request.residenceCountry != null)
        request.residenceCountry!.trim().toUpperCase(),
      ...request.residenceCountries.map((item) => item.trim().toUpperCase()),
    }.difference({''});
    final dep = {
      if (request.departureCountry != null)
        request.departureCountry!.trim().toUpperCase(),
    }.difference({''});
    final ret = {
      if (request.returnCountry != null)
        request.returnCountry!.trim().toUpperCase(),
    }.difference({''});
    final relevant = registry.relevantTo(
      nationalityCodes: nats,
      residenceCodes: res,
      departureCodes: dep,
      returnCodes: ret,
      pathwayIds: request.pathwayIds,
    );
    return HajjLookupBundle(
      sources: [
        for (final entry in relevant)
          HajjOfficialSource(
            id: 'src.demo.${entry.id}',
            title: '${entry.authorityName} ($kHajjDemoNoLiveVerification)',
            uri: entry.officialUrl,
            issuingAuthority: entry.authorityName,
            jurisdictionCountry: entry.jurisdictionCountry,
            applicableSeason: season,
            requirementText:
                'Confirm current requirements on the official site. $kHajjDemoNoLiveVerification.',
            trustClass:
                entry.category == HajjSourceCategory.saudiOfficialAuthority
                ? HajjSourceTrustClass.official
                : HajjSourceTrustClass.secondary,
            verificationStatus: HajjVerificationStatus.unverified,
            origin: HajjSourceOrigin.demonstration,
            provenance: HajjProvenanceKind.demonstration,
            demonstration: true,
            retrievalMode: HajjSourceRetrievalMode.demonstration,
            notes: kHajjDemoNoLiveVerification,
          ),
      ],
      providers: const [],
      message: kHajjDemoNoLiveVerification,
    );
  }

  @override
  Future<HajjPlanProposal> interpret({
    required HajjLookupRequest request,
    required String todayKey,
  }) async {
    if (!hajjOnlinePayloadIsSafe(request.toPayload())) {
      throw HajjOnlineAssistException('Request contained private fields.');
    }
    return HajjPlanProposal(
      id: 'prop.demo.$todayKey',
      title: 'Ask your mission about the registration window',
      detail:
          '$kHajjDemoNoLiveVerification. An on-device demonstration suggestion. It is not a government ruling, eligibility decision, or official deadline. No verified official evidence is on file. Accept only if you want a reminder milestone.',
      origin: HajjProvenanceKind.aiInterpretation,
      milestoneTitle: 'Ask your mission about the registration window',
      sourceIds: const ['reg.sa.hajj.ministry'],
      extractedRequirement: null,
      jurisdiction: request.nationalityCountry,
      season: request.season,
      retrievedAt: todayKey,
      uncertaintyNote: 'Official sources are missing, outdated, or unverified. The app will not invent a deadline or eligibility ruling.',
      requiresUserApproval: true,
    );
  }
}

class FailingHajjOnlineAssistGateway implements HajjOnlineAssistGateway {
  const FailingHajjOnlineAssistGateway();

  @override
  Future<HajjLookupBundle> lookupOfficial(HajjLookupRequest request) async {
    throw HajjOnlineAssistException('Online assistance is unavailable.');
  }

  @override
  Future<HajjPlanProposal> interpret({
    required HajjLookupRequest request,
    required String todayKey,
  }) async {
    throw HajjOnlineAssistException('Online assistance is unavailable.');
  }
}

bool hajjSourceIsStale(HajjOfficialSource source, {required String todayKey}) {
  final retrieved = source.retrievedAt;
  if (retrieved == null || retrieved.length < 10) return false;
  final day = retrieved.substring(0, 10);
  return day.compareTo(todayKey) < 0 &&
      day.compareTo('2000-01-01') >= 0 &&
      _daysBetween(day, todayKey) > 180;
}

int _daysBetween(String a, String b) {
  final left = DateTime.tryParse(a);
  final right = DateTime.tryParse(b);
  if (left == null || right == null) return 0;
  return right.difference(left).inDays;
}

String hajjSourceStatusLabel(
  HajjOfficialSource source, {
  required String todayKey,
}) {
  if (source.verificationStatus == HajjVerificationStatus.unverified ||
      source.demonstration) {
    return 'Unverified';
  }
  if (hajjSourceIsStale(source, todayKey: todayKey) ||
      source.verificationStatus == HajjVerificationStatus.outdated) {
    return 'Outdated';
  }
  if (source.verificationStatus == HajjVerificationStatus.verifiedByUser &&
      source.trustClass == HajjSourceTrustClass.official) {
    return 'Verified by you against an official source';
  }
  return source.verificationStatus.name;
}

List<String> hajjConflictingSourceDeadlines(List<HajjOfficialSource> sources) {
  final byRequirement = <String, Set<String>>{};
  for (final source in sources) {
    final key = source.requirementText ?? source.title ?? source.id;
    final deadline = source.deadline;
    if (deadline == null || deadline.isEmpty) continue;
    byRequirement.putIfAbsent(key, () => <String>{}).add(deadline);
  }
  return [
    for (final entry in byRequirement.entries)
      if (entry.value.length > 1)
        'Conflicting deadlines for "${entry.key}": ${entry.value.join(', ')}. Keep both as unverified until you choose.',
  ];
}

HajjJourney acceptHajjPlanProposal(
  HajjJourney journey,
  HajjPlanProposal proposal,
) {
  if (proposal.milestoneTitle == null ||
      proposal.milestoneTitle!.trim().isEmpty) {
    return journey;
  }
  final exists = journey.milestones.any(
    (item) => item.title == proposal.milestoneTitle,
  );
  if (exists) return journey;
  return journey.copyWith(
    milestones: [
      ...journey.milestones,
      HajjMilestone(
        id: 'ms_${proposal.id}',
        title: proposal.milestoneTitle,
        status: HajjMilestoneStatus.pending,
        notes: 'AI interpretation awaiting your use. Not an official deadline or eligibility ruling.',
      ),
    ],
  );
}

bool hajjProviderMayBeCalledAuthorized(HajjProviderSlot provider) {
  if (provider.demonstration) return false;
  final evidence = provider.authorizationEvidence?.trim();
  return provider.officiallyAuthorized &&
      evidence != null &&
      evidence.isNotEmpty;
}
