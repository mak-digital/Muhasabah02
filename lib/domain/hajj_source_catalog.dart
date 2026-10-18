/// Bundled official-portal registry. URLs only — never quotas, windows, or eligibility.
library;

enum HajjSourceCategory {
  saudiOfficialAuthority,
  officialBookingPlatform,
  nationalMission,
  healthVaccination,
  authorizedProviderRegister,
  travelVisaResidence,
}

enum HajjRetrievalMethod { bundledCatalog, futureHttpsGet, manualUser }

class HajjRegistrySource {
  const HajjRegistrySource({
    required this.id,
    required this.authorityName,
    required this.category,
    required this.officialUrl,
    this.jurisdictionCountry,
    this.nationalityCodes = const [],
    this.residenceCodes = const [],
    this.departureCodes = const [],
    this.languages = const ['en'],
    this.retrievalMethod = HajjRetrievalMethod.bundledCatalog,
    this.notes,
  });

  final String id;
  final String authorityName;
  final HajjSourceCategory category;
  final String officialUrl;
  final String? jurisdictionCountry;

  /// Empty means not limited to a nationality. Never an eligibility list.
  final List<String> nationalityCodes;
  final List<String> residenceCodes;
  final List<String> departureCodes;
  final List<String> languages;
  final HajjRetrievalMethod retrievalMethod;
  final String? notes;

  bool get isGloballyRelevant =>
      nationalityCodes.isEmpty &&
      residenceCodes.isEmpty &&
      departureCodes.isEmpty;
}

abstract class HajjSourceRegistry {
  List<HajjRegistrySource> get entries;
  List<HajjRegistrySource> relevantTo({
    required Set<String> nationalityCodes,
    required Set<String> residenceCodes,
    required Set<String> departureCodes,
    required Set<String> returnCodes,
    required List<String> pathwayIds,
  });
}

class BundledHajjSourceRegistry implements HajjSourceRegistry {
  const BundledHajjSourceRegistry();

  @override
  List<HajjRegistrySource> get entries => kBundledHajjRegistrySources;

  @override
  List<HajjRegistrySource> relevantTo({
    required Set<String> nationalityCodes,
    required Set<String> residenceCodes,
    required Set<String> departureCodes,
    required Set<String> returnCodes,
    required List<String> pathwayIds,
  }) {
    final travel = {...departureCodes, ...returnCodes};
    return [
      for (final entry in entries)
        if (_matches(
          entry,
          nationalityCodes: nationalityCodes,
          residenceCodes: residenceCodes,
          travelCodes: travel,
          pathwayIds: pathwayIds,
        ))
          entry,
    ];
  }
}

bool _matches(
  HajjRegistrySource entry, {
  required Set<String> nationalityCodes,
  required Set<String> residenceCodes,
  required Set<String> travelCodes,
  required List<String> pathwayIds,
}) {
  if (entry.category == HajjSourceCategory.authorizedProviderRegister &&
      !pathwayIds.contains('licensedOperator') &&
      !pathwayIds.contains('nationalMission')) {
    return entry.isGloballyRelevant;
  }
  if (entry.isGloballyRelevant) return true;
  bool hit(List<String> codes, Set<String> query) {
    if (codes.isEmpty) return false;
    for (final code in codes) {
      if (query.contains(code)) return true;
    }
    return false;
  }

  return hit(entry.nationalityCodes, nationalityCodes) ||
      hit(entry.residenceCodes, residenceCodes) ||
      hit(entry.departureCodes, travelCodes);
}

/// Maintainable catalog of official portals. No assumed dates, quotas, or licences.
const kBundledHajjRegistrySources = <HajjRegistrySource>[
  HajjRegistrySource(
    id: 'reg.sa.hajj.ministry',
    authorityName: 'Ministry of Hajj and Umrah',
    category: HajjSourceCategory.saudiOfficialAuthority,
    officialUrl: 'https://www.haj.gov.sa',
    jurisdictionCountry: 'SA',
    languages: ['ar', 'en'],
    notes: 'Primary Saudi Hajj authority portal. Confirm current rules on the site.',
  ),
  HajjRegistrySource(
    id: 'reg.sa.nusuk',
    authorityName: 'Nusuk',
    category: HajjSourceCategory.officialBookingPlatform,
    officialUrl: 'https://www.nusuk.sa',
    jurisdictionCountry: 'SA',
    languages: ['ar', 'en'],
    notes:
        'Official Saudi platform. The app does not book or decide eligibility.',
  ),
  HajjRegistrySource(
    id: 'reg.sa.moh',
    authorityName: 'Saudi Ministry of Health',
    category: HajjSourceCategory.healthVaccination,
    officialUrl: 'https://www.moh.gov.sa',
    jurisdictionCountry: 'SA',
    languages: ['ar', 'en'],
    notes:
        'Health and vaccination guidance must be read on the authority site.',
  ),
  HajjRegistrySource(
    id: 'reg.sa.mofa',
    authorityName: 'Saudi Ministry of Foreign Affairs',
    category: HajjSourceCategory.travelVisaResidence,
    officialUrl: 'https://www.mofa.gov.sa',
    jurisdictionCountry: 'SA',
    languages: ['ar', 'en'],
  ),
  HajjRegistrySource(
    id: 'reg.sa.nusuk.providers',
    authorityName: 'Nusuk licensed services (confirm on the official site)',
    category: HajjSourceCategory.authorizedProviderRegister,
    officialUrl: 'https://www.nusuk.sa',
    jurisdictionCountry: 'SA',
    languages: ['ar', 'en'],
    notes:
        'A register URL only. No operator names or licences are stored here.',
  ),
  HajjRegistrySource(
    id: 'reg.who.travel',
    authorityName: 'World Health Organization travel advice',
    category: HajjSourceCategory.healthVaccination,
    officialUrl: 'https://www.who.int/travel-advice',
    notes: 'General travel health. Not a Hajj ruling.',
  ),
  HajjRegistrySource(
    id: 'reg.gb.mission',
    authorityName: 'UK government Hajj and Umrah guidance',
    category: HajjSourceCategory.nationalMission,
    officialUrl:
        'https://www.gov.uk/foreign-travel-advice/saudi-arabia/pilgrimage',
    jurisdictionCountry: 'GB',
    nationalityCodes: ['GB'],
    residenceCodes: ['GB'],
    departureCodes: ['GB'],
  ),
  HajjRegistrySource(
    id: 'reg.us.travel',
    authorityName: 'US Department of State international travel',
    category: HajjSourceCategory.travelVisaResidence,
    officialUrl: 'https://travel.state.gov',
    jurisdictionCountry: 'US',
    nationalityCodes: ['US'],
    residenceCodes: ['US'],
    departureCodes: ['US'],
  ),
  HajjRegistrySource(
    id: 'reg.pk.mora',
    authorityName:
        'Pakistan Ministry of Religious Affairs and Interfaith Harmony',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://www.mora.gov.pk',
    jurisdictionCountry: 'PK',
    nationalityCodes: ['PK'],
    residenceCodes: ['PK'],
    departureCodes: ['PK'],
  ),
  HajjRegistrySource(
    id: 'reg.ae.awqaf',
    authorityName: 'UAE General Authority of Islamic Affairs and Endowments',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://www.awqaf.gov.ae',
    jurisdictionCountry: 'AE',
    nationalityCodes: ['AE'],
    residenceCodes: ['AE'],
    departureCodes: ['AE'],
  ),
  HajjRegistrySource(
    id: 'reg.id.kemenag',
    authorityName: 'Indonesia Ministry of Religious Affairs',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://www.kemenag.go.id',
    jurisdictionCountry: 'ID',
    nationalityCodes: ['ID'],
    residenceCodes: ['ID'],
    departureCodes: ['ID'],
  ),
  HajjRegistrySource(
    id: 'reg.my.lth',
    authorityName: 'Lembaga Tabung Haji Malaysia',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://www.tabunghaji.gov.my',
    jurisdictionCountry: 'MY',
    nationalityCodes: ['MY'],
    residenceCodes: ['MY'],
    departureCodes: ['MY'],
  ),
  HajjRegistrySource(
    id: 'reg.in.hajj',
    authorityName: 'Hajj Committee of India',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://hajcommittee.gov.in',
    jurisdictionCountry: 'IN',
    nationalityCodes: ['IN'],
    residenceCodes: ['IN'],
    departureCodes: ['IN'],
  ),
  HajjRegistrySource(
    id: 'reg.bd.hajj',
    authorityName: 'Bangladesh Directorate of Hajj',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://hajj.gov.bd',
    jurisdictionCountry: 'BD',
    nationalityCodes: ['BD'],
    residenceCodes: ['BD'],
    departureCodes: ['BD'],
  ),
  HajjRegistrySource(
    id: 'reg.eg.hajj',
    authorityName: 'Egypt Ministry of Awqaf',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://www.awkaf.gov.eg',
    jurisdictionCountry: 'EG',
    nationalityCodes: ['EG'],
    residenceCodes: ['EG'],
    departureCodes: ['EG'],
  ),
  HajjRegistrySource(
    id: 'reg.ng.nscia',
    authorityName: 'Nigeria Supreme Council for Islamic Affairs (confirm current official Hajj portal)',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://www.nscia.com.ng',
    jurisdictionCountry: 'NG',
    nationalityCodes: ['NG'],
    residenceCodes: ['NG'],
    departureCodes: ['NG'],
    notes: 'Confirm the current government Hajj portal; this bookmark is not verification.',
  ),
  HajjRegistrySource(
    id: 'reg.fr.afh',
    authorityName:
        'France — confirm the current official Hajj organisation portal',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://www.interieur.gouv.fr',
    jurisdictionCountry: 'FR',
    nationalityCodes: ['FR'],
    residenceCodes: ['FR'],
    departureCodes: ['FR'],
    languages: ['fr', 'en'],
    notes: 'National portal to confirm. Not a booking or eligibility decision.',
  ),
  HajjRegistrySource(
    id: 'reg.ca.travel',
    authorityName: 'Government of Canada travel advice',
    category: HajjSourceCategory.travelVisaResidence,
    officialUrl: 'https://travel.gc.ca',
    jurisdictionCountry: 'CA',
    nationalityCodes: ['CA'],
    residenceCodes: ['CA'],
    departureCodes: ['CA'],
  ),
  HajjRegistrySource(
    id: 'reg.au.smartraveller',
    authorityName: 'Australian Government Smartraveller',
    category: HajjSourceCategory.travelVisaResidence,
    officialUrl: 'https://www.smartraveller.gov.au',
    jurisdictionCountry: 'AU',
    nationalityCodes: ['AU'],
    residenceCodes: ['AU'],
    departureCodes: ['AU'],
  ),
  HajjRegistrySource(
    id: 'reg.tr.diyanet',
    authorityName: 'Türkiye Presidency of Religious Affairs',
    category: HajjSourceCategory.nationalMission,
    officialUrl: 'https://www.diyanet.gov.tr',
    jurisdictionCountry: 'TR',
    nationalityCodes: ['TR'],
    residenceCodes: ['TR'],
    departureCodes: ['TR'],
    languages: ['tr', 'en'],
  ),
];
