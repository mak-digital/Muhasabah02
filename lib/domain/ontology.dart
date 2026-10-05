import 'activities.dart';
import 'charity_factors.dart';
import 'context_catalog.dart';
import 'home_traces.dart';
import 'monitor_domain.dart';
import 'quran.dart';
import 'salah_factors.dart';

/// Read-only ontology metadata version. Independent of DailyCheckIn schema v6.
///
/// Version 2 adds explicit activity and context-factor records for existing
/// persisted IDs. It does not change DailyCheckIn schema v6.
const int kOntologyRegistryVersion = 2;

/// Active catalog rows vs historically readable retired rows.
enum OntologyNodeStatus { active, retired }

/// Conceptual domains. Labels are metadata, not UI copy and not a score.
enum ConceptualDomainId {
  salahPrayerPractice,
  quranRevelationEngagement,
  hadithPropheticGuidance,
  remembranceAndDua,
  characterSelfRegulation,
  rightsFamilyRelationships,
  knowledgeBeneficialCommunication,
  timeAndResponsibility,
  physicalWellbeing,
  financialStewardshipGiving,
  communityAndService,
  fasting,
  hajj,
  reflectionPersonalResponse,
}

/// Independent Qur’an groupings. Not an ordinal path and not a journey rank.
enum QuranConceptualGroup {
  directEngagement,
  understandingActivities,
  memorisationRetention,
  reflection,
  practicalRelevance,
  privatePracticalReflection,
}

class ConceptualDomainRecord {
  const ConceptualDomainRecord({
    required this.id,
    required this.label,
    required this.sourceMonitorDomains,
    required this.isObservationDomain,
  });

  final ConceptualDomainId id;
  final String label;
  final Set<MonitorDomain> sourceMonitorDomains;
  final bool isObservationDomain;
}

class QuranOntologyRecord {
  const QuranOntologyRecord({
    required this.dimension,
    required this.conceptualDomain,
    required this.group,
  });

  final QuranDimension dimension;
  final ConceptualDomainId conceptualDomain;
  final QuranConceptualGroup group;

  String get persistedId => dimension.name;
}

class HomeTraceOntologyRecord {
  const HomeTraceOntologyRecord({
    required this.storageKey,
    required this.conceptualDomain,
    required this.status,
    this.sourceMonitorDomain,
    this.familyLabel,
  });

  final String storageKey;
  final ConceptualDomainId conceptualDomain;
  final OntologyNodeStatus status;
  final MonitorDomain? sourceMonitorDomain;
  final String? familyLabel;
}

/// Production activity catalog a persisted activity id belongs to.
///
/// Raw ids such as `reading` or `other` are not globally unique. The stable
/// ontology key is [ActivityOntologyRecord.stableId] (`catalog:persistedId`).
enum OntologyActivityCatalog {
  salah,
  quranReading,
  quranMeaning,
  quranMemorisation,
  quranRevision,
  quranTafsir,
  quranReflection,
  quranConsciousApplication,
  quranLegacy,
  dhikr,
  conduct,
  gratitude,
  personalReflection,
  fasting,
  charity,
  zakat,
  family,
  hadith,
}

/// Production factor catalog. Factors are provenance, not practices or outcomes.
enum OntologyFactorCatalog { quranContext, salah, charity }

/// Minimum construct kind. Not a maturity ladder and not a score.
enum OntologyConstructKind {
  practiceObservation,
  observationState,
  standingStatus,
  contextProvenance,
  reflectiveContent,
}

class ActivityOntologyRecord {
  const ActivityOntologyRecord({
    required this.catalog,
    required this.persistedId,
    required this.conceptualDomain,
    required this.status,
    required this.kind,
    this.quranDimension,
    this.quranGroup,
    this.impliesSpiritualQuality = false,
    this.impliesOrdinalStage = false,
    this.impliesCertifiedMerit = false,
  });

  final OntologyActivityCatalog catalog;
  final String persistedId;
  final ConceptualDomainId conceptualDomain;
  final OntologyNodeStatus status;
  final OntologyConstructKind kind;
  final QuranDimension? quranDimension;
  final QuranConceptualGroup? quranGroup;
  final bool impliesSpiritualQuality;
  final bool impliesOrdinalStage;
  final bool impliesCertifiedMerit;

  String get stableId => '${catalog.name}:$persistedId';
}

class FactorOntologyRecord {
  const FactorOntologyRecord({
    required this.catalog,
    required this.persistedId,
    required this.status,
    this.polarity,
  });

  final OntologyFactorCatalog catalog;
  final String persistedId;
  final OntologyNodeStatus status;
  final String? polarity;

  OntologyConstructKind get kind => OntologyConstructKind.contextProvenance;
  bool get isCause => false;
  bool get isOutcome => false;
  bool get isRecommendation => false;

  String get stableId => polarity == null
      ? '${catalog.name}:$persistedId'
      : '${catalog.name}:$polarity:$persistedId';
}

/// Gratitude, Personal Reflection, and Personal Response. Not observation scores.
class ReflectionOntologyRecord {
  const ReflectionOntologyRecord({
    required this.storageId,
    required this.label,
  });

  final String storageId;
  final String label;
  ConceptualDomainId get conceptualDomain =>
      ConceptualDomainId.reflectionPersonalResponse;
  bool get isObservationScore => false;
  bool get mayBeSemanticallyInterpreted => false;
}

/// Immutable registry. Lookups do not rewrite persisted identifiers.
class OntologyRegistry {
  OntologyRegistry._();

  static const version = kOntologyRegistryVersion;

  static const conceptualDomains = <ConceptualDomainRecord>[
    ConceptualDomainRecord(
      id: ConceptualDomainId.salahPrayerPractice,
      label: 'Salah & Prayer Practice',
      sourceMonitorDomains: {MonitorDomain.salah},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.quranRevelationEngagement,
      label: 'Qur’an & Revelation Engagement',
      sourceMonitorDomains: {MonitorDomain.quran},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.hadithPropheticGuidance,
      label: 'Hadith & Prophetic Guidance Engagement',
      sourceMonitorDomains: {MonitorDomain.hadith},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.remembranceAndDua,
      label: 'Remembrance & Dua',
      sourceMonitorDomains: {MonitorDomain.dhikr},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.characterSelfRegulation,
      label: 'Character & Self-Regulation',
      sourceMonitorDomains: {MonitorDomain.akhlaq},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.rightsFamilyRelationships,
      label: 'Rights, Family & Relationships',
      sourceMonitorDomains: {MonitorDomain.huquq},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.knowledgeBeneficialCommunication,
      label: 'Knowledge & Beneficial Communication',
      sourceMonitorDomains: {MonitorDomain.knowledge},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.timeAndResponsibility,
      label: 'Time & Responsibility',
      sourceMonitorDomains: {MonitorDomain.time},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.physicalWellbeing,
      label: 'Physical Wellbeing',
      sourceMonitorDomains: {MonitorDomain.health},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.financialStewardshipGiving,
      label: 'Financial Stewardship & Giving',
      sourceMonitorDomains: {MonitorDomain.wealth, MonitorDomain.charity},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.communityAndService,
      label: 'Community & Service',
      sourceMonitorDomains: {MonitorDomain.ummah},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.fasting,
      label: 'Fasting',
      sourceMonitorDomains: {MonitorDomain.fasting},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.hajj,
      label: 'Hajj',
      sourceMonitorDomains: {MonitorDomain.hajj},
      isObservationDomain: true,
    ),
    ConceptualDomainRecord(
      id: ConceptualDomainId.reflectionPersonalResponse,
      label: 'Reflection & Personal Response',
      sourceMonitorDomains: {},
      isObservationDomain: false,
    ),
  ];

  static const quranDimensions = <QuranOntologyRecord>[
    QuranOntologyRecord(
      dimension: QuranDimension.reading,
      conceptualDomain: ConceptualDomainId.quranRevelationEngagement,
      group: QuranConceptualGroup.directEngagement,
    ),
    QuranOntologyRecord(
      dimension: QuranDimension.meaning,
      conceptualDomain: ConceptualDomainId.quranRevelationEngagement,
      group: QuranConceptualGroup.understandingActivities,
    ),
    QuranOntologyRecord(
      dimension: QuranDimension.memorisation,
      conceptualDomain: ConceptualDomainId.quranRevelationEngagement,
      group: QuranConceptualGroup.memorisationRetention,
    ),
    QuranOntologyRecord(
      dimension: QuranDimension.revision,
      conceptualDomain: ConceptualDomainId.quranRevelationEngagement,
      group: QuranConceptualGroup.memorisationRetention,
    ),
    QuranOntologyRecord(
      dimension: QuranDimension.tafsir,
      conceptualDomain: ConceptualDomainId.quranRevelationEngagement,
      group: QuranConceptualGroup.understandingActivities,
    ),
    QuranOntologyRecord(
      dimension: QuranDimension.reflection,
      conceptualDomain: ConceptualDomainId.quranRevelationEngagement,
      group: QuranConceptualGroup.reflection,
    ),
    QuranOntologyRecord(
      dimension: QuranDimension.consciousApplication,
      conceptualDomain: ConceptualDomainId.quranRevelationEngagement,
      group: QuranConceptualGroup.practicalRelevance,
    ),
    QuranOntologyRecord(
      dimension: QuranDimension.applicationReflection,
      conceptualDomain: ConceptualDomainId.quranRevelationEngagement,
      group: QuranConceptualGroup.privatePracticalReflection,
    ),
  ];

  static const reflectionSubjects = <ReflectionOntologyRecord>[
    ReflectionOntologyRecord(storageId: 'gratitude', label: 'Gratitude'),
    ReflectionOntologyRecord(
      storageId: 'personalReflection',
      label: 'Personal Reflection',
    ),
    ReflectionOntologyRecord(
      storageId: 'personalResponse',
      label: 'Personal Response',
    ),
  ];

  static final homeTraces = _buildHomeTraces();
  static final activities = _buildActivities();
  static final factors = _buildFactors();

  static ConceptualDomainRecord conceptualDomain(ConceptualDomainId id) {
    return conceptualDomains.firstWhere((record) => record.id == id);
  }

  static ConceptualDomainRecord forMonitorDomain(MonitorDomain domain) {
    final matches = [
      for (final record in conceptualDomains)
        if (record.sourceMonitorDomains.contains(domain)) record,
    ];
    if (matches.length != 1) {
      throw StateError(
        'MonitorDomain.${domain.name} must resolve to exactly one conceptual domain',
      );
    }
    return matches.single;
  }

  static QuranOntologyRecord forQuranDimension(QuranDimension dimension) {
    return quranDimensions.firstWhere(
      (record) => record.dimension == dimension,
    );
  }

  static HomeTraceOntologyRecord? forHomeTrace(String storageKey) {
    for (final record in homeTraces) {
      if (record.storageKey == storageKey) return record;
    }
    return null;
  }

  static ReflectionOntologyRecord? forReflection(String storageId) {
    for (final record in reflectionSubjects) {
      if (record.storageId == storageId) return record;
    }
    return null;
  }

  static ActivityOntologyRecord? forActivity(
    OntologyActivityCatalog catalog,
    String persistedId,
  ) {
    final key = '${catalog.name}:$persistedId';
    for (final record in activities) {
      if (record.stableId == key) return record;
    }
    return null;
  }

  static FactorOntologyRecord? forFactor({
    required OntologyFactorCatalog catalog,
    required String persistedId,
    String? polarity,
  }) {
    for (final record in factors) {
      if (record.catalog != catalog) continue;
      if (record.persistedId != persistedId) continue;
      if (record.polarity != polarity) continue;
      return record;
    }
    return null;
  }
}

ConceptualDomainId conceptualDomainForMonitor(MonitorDomain domain) {
  return OntologyRegistry.forMonitorDomain(domain).id;
}

/// Explicitly not a rank. Groups may be listed in any order.
int? quranGroupOrdinal(QuranConceptualGroup group) {
  switch (group) {
    case QuranConceptualGroup.directEngagement:
    case QuranConceptualGroup.understandingActivities:
    case QuranConceptualGroup.memorisationRetention:
    case QuranConceptualGroup.reflection:
    case QuranConceptualGroup.practicalRelevance:
    case QuranConceptualGroup.privatePracticalReflection:
      return null;
  }
}

List<HomeTraceOntologyRecord> _buildHomeTraces() {
  return [
    for (final row in dhikrHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.remembranceAndDua,
      ),
    for (final row in akhlaqHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.characterSelfRegulation,
      ),
    for (final row in huquqHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.rightsFamilyRelationships,
      ),
    for (final row in knowledgeHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.knowledgeBeneficialCommunication,
      ),
    for (final row in timeHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.timeAndResponsibility,
      ),
    for (final row in healthHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.physicalWellbeing,
      ),
    for (final row in wealthHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.financialStewardshipGiving,
      ),
    for (final row in ummahHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.communityAndService,
      ),
    for (final row in charityHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.financialStewardshipGiving,
      ),
    for (final row in fastingHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.fasting,
      ),
    for (final row in hajjHomeRows)
      _homeTraceRecord(row, OntologyNodeStatus.active, ConceptualDomainId.hajj),
    for (final row in hadithHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.active,
        ConceptualDomainId.hadithPropheticGuidance,
      ),
    for (final row in familyRetiredHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.retired,
        ConceptualDomainId.rightsFamilyRelationships,
      ),
    for (final row in akhlaqRetiredHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.retired,
        ConceptualDomainId.characterSelfRegulation,
      ),
    for (final row in timeRetiredHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.retired,
        ConceptualDomainId.timeAndResponsibility,
      ),
    for (final row in wealthRetiredHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.retired,
        ConceptualDomainId.financialStewardshipGiving,
      ),
    for (final row in ummahRetiredHomeRows)
      _homeTraceRecord(
        row,
        OntologyNodeStatus.retired,
        ConceptualDomainId.communityAndService,
      ),
  ];
}

HomeTraceOntologyRecord _homeTraceRecord(
  HomeTraceRow row,
  OntologyNodeStatus status,
  ConceptualDomainId conceptualDomain,
) {
  return HomeTraceOntologyRecord(
    storageKey: row.storageKey,
    conceptualDomain: conceptualDomain,
    status: status,
    sourceMonitorDomain: monitorDomainForStorageKey(row.storageKey),
    familyLabel: row.band,
  );
}

List<ActivityOntologyRecord> _buildActivities() {
  return [
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.salah,
      options: ActivityCatalog.salah,
      domain: ConceptualDomainId.salahPrayerPractice,
      status: OntologyNodeStatus.active,
    ),
    ..._mapQuranCatalog(
      OntologyActivityCatalog.quranReading,
      ActivityCatalog.quranReading,
      QuranDimension.reading,
      QuranConceptualGroup.directEngagement,
      OntologyNodeStatus.active,
    ),
    ..._mapQuranCatalog(
      OntologyActivityCatalog.quranMeaning,
      ActivityCatalog.quranMeaning,
      QuranDimension.meaning,
      QuranConceptualGroup.understandingActivities,
      OntologyNodeStatus.active,
    ),
    ..._mapQuranCatalog(
      OntologyActivityCatalog.quranMemorisation,
      ActivityCatalog.quranMemorisation,
      QuranDimension.memorisation,
      QuranConceptualGroup.memorisationRetention,
      OntologyNodeStatus.active,
    ),
    ..._mapQuranCatalog(
      OntologyActivityCatalog.quranRevision,
      ActivityCatalog.quranRevision,
      QuranDimension.revision,
      QuranConceptualGroup.memorisationRetention,
      OntologyNodeStatus.active,
    ),
    ..._mapQuranCatalog(
      OntologyActivityCatalog.quranTafsir,
      ActivityCatalog.quranTafsir,
      QuranDimension.tafsir,
      QuranConceptualGroup.understandingActivities,
      OntologyNodeStatus.active,
    ),
    ..._mapQuranCatalog(
      OntologyActivityCatalog.quranReflection,
      ActivityCatalog.quranReflection,
      QuranDimension.reflection,
      QuranConceptualGroup.reflection,
      OntologyNodeStatus.active,
    ),
    ..._mapQuranCatalog(
      OntologyActivityCatalog.quranConsciousApplication,
      ActivityCatalog.quranConsciousApplication,
      QuranDimension.consciousApplication,
      QuranConceptualGroup.practicalRelevance,
      OntologyNodeStatus.active,
    ),
    ..._mapQuranCatalog(
      OntologyActivityCatalog.quranLegacy,
      ActivityCatalog.quranLegacy,
      null,
      null,
      OntologyNodeStatus.retired,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.dhikr,
      options: ActivityCatalog.dhikr,
      domain: ConceptualDomainId.remembranceAndDua,
      status: OntologyNodeStatus.active,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.conduct,
      options: ActivityCatalog.conduct,
      domain: ConceptualDomainId.characterSelfRegulation,
      status: OntologyNodeStatus.retired,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.gratitude,
      options: ActivityCatalog.gratitude,
      domain: ConceptualDomainId.reflectionPersonalResponse,
      status: OntologyNodeStatus.retired,
      kind: OntologyConstructKind.reflectiveContent,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.personalReflection,
      options: ActivityCatalog.personalReflection,
      domain: ConceptualDomainId.reflectionPersonalResponse,
      status: OntologyNodeStatus.retired,
      kind: OntologyConstructKind.reflectiveContent,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.fasting,
      options: ActivityCatalog.fasting,
      domain: ConceptualDomainId.fasting,
      status: OntologyNodeStatus.active,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.charity,
      options: ActivityCatalog.charity,
      domain: ConceptualDomainId.financialStewardshipGiving,
      status: OntologyNodeStatus.active,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.zakat,
      options: ActivityCatalog.zakat,
      domain: ConceptualDomainId.financialStewardshipGiving,
      status: OntologyNodeStatus.active,
      kind: OntologyConstructKind.standingStatus,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.family,
      options: ActivityCatalog.family,
      domain: ConceptualDomainId.rightsFamilyRelationships,
      status: OntologyNodeStatus.retired,
    ),
    ..._mapActivityCatalog(
      catalog: OntologyActivityCatalog.hadith,
      options: ActivityCatalog.hadith,
      domain: ConceptualDomainId.hadithPropheticGuidance,
      status: OntologyNodeStatus.active,
    ),
  ];
}

List<ActivityOntologyRecord> _mapQuranCatalog(
  OntologyActivityCatalog catalog,
  List<ActivityOption> options,
  QuranDimension? dimension,
  QuranConceptualGroup? group,
  OntologyNodeStatus status,
) {
  return _mapActivityCatalog(
    catalog: catalog,
    options: options,
    domain: ConceptualDomainId.quranRevelationEngagement,
    status: status,
    quranDimension: dimension,
    quranGroup: group,
  );
}

List<ActivityOntologyRecord> _mapActivityCatalog({
  required OntologyActivityCatalog catalog,
  required List<ActivityOption> options,
  required ConceptualDomainId domain,
  required OntologyNodeStatus status,
  OntologyConstructKind? kind,
  QuranDimension? quranDimension,
  QuranConceptualGroup? quranGroup,
}) {
  return [
    for (final option in options)
      ActivityOntologyRecord(
        catalog: catalog,
        persistedId: option.id,
        conceptualDomain: domain,
        status: status,
        kind: _activityKind(option.id, kind),
        quranDimension: quranDimension,
        quranGroup: quranGroup,
      ),
  ];
}

OntologyConstructKind _activityKind(
  String id,
  OntologyConstructKind? fallback,
) {
  if (id == ActivityIds.unanswered ||
      id == ActivityIds.noActivity ||
      id == ActivityIds.other) {
    return OntologyConstructKind.observationState;
  }
  if (fallback != null) return fallback;
  return OntologyConstructKind.practiceObservation;
}

List<FactorOntologyRecord> _buildFactors() {
  return [
    for (final factor in ContextCatalog.positive)
      FactorOntologyRecord(
        catalog: OntologyFactorCatalog.quranContext,
        persistedId: factor.id,
        status: OntologyNodeStatus.active,
        polarity: 'positive',
      ),
    for (final factor in ContextCatalog.negative)
      FactorOntologyRecord(
        catalog: OntologyFactorCatalog.quranContext,
        persistedId: factor.id,
        status: OntologyNodeStatus.active,
        polarity: 'negative',
      ),
    for (final id in _retiredQuranContextAliases)
      FactorOntologyRecord(
        catalog: OntologyFactorCatalog.quranContext,
        persistedId: id,
        status: OntologyNodeStatus.retired,
      ),
    for (final factor in SalahFactorCatalog.support)
      FactorOntologyRecord(
        catalog: OntologyFactorCatalog.salah,
        persistedId: factor.id,
        status: OntologyNodeStatus.active,
        polarity: 'positive',
      ),
    for (final factor in SalahFactorCatalog.challenge)
      FactorOntologyRecord(
        catalog: OntologyFactorCatalog.salah,
        persistedId: factor.id,
        status: OntologyNodeStatus.active,
        polarity: 'negative',
      ),
    for (final factor in CharityFactorCatalog.support)
      FactorOntologyRecord(
        catalog: OntologyFactorCatalog.charity,
        persistedId: factor.id,
        status: OntologyNodeStatus.active,
        polarity: 'positive',
      ),
    for (final factor in CharityFactorCatalog.challenge)
      FactorOntologyRecord(
        catalog: OntologyFactorCatalog.charity,
        persistedId: factor.id,
        status: OntologyNodeStatus.active,
        polarity: 'negative',
      ),
    for (final id in _retiredCharityFactorIds)
      FactorOntologyRecord(
        catalog: OntologyFactorCatalog.charity,
        persistedId: id,
        status: OntologyNodeStatus.retired,
      ),
  ];
}

const _retiredQuranContextAliases = <String>[
  'energy',
  'company',
  'illness',
  'distraction',
  'forgot',
];

const _retiredCharityFactorIds = <String>[
  'charity.religiousMoralMotivation',
  'charity.empathyCompassion',
  'charity.trustInInstitutions',
  'charity.socialCommunityInfluence',
  'charity.financialCapacity',
  'charity.lackOfTrust',
  'charity.limitedAwareness',
  'charity.donorFatigue',
  'charity.competingPriorities',
];
