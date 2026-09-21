import 'home_traces.dart';
import 'monitor_domain.dart';
import 'quran.dart';

/// Read-only ontology metadata version. Independent of DailyCheckIn schema v6.
const int kOntologyRegistryVersion = 1;

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
    for (final row in _activeHomeTraceRows)
      _homeTraceRecord(row, OntologyNodeStatus.active),
    for (final row in _retiredHomeTraceRows)
      _homeTraceRecord(row, OntologyNodeStatus.retired),
  ];
}

const _activeHomeTraceRows = <HomeTraceRow>[
  ...dhikrHomeRows,
  ...akhlaqHomeRows,
  ...huquqHomeRows,
  ...knowledgeHomeRows,
  ...timeHomeRows,
  ...healthHomeRows,
  ...wealthHomeRows,
  ...ummahHomeRows,
  ...charityHomeRows,
  ...fastingHomeRows,
  ...hajjHomeRows,
  ...hadithHomeRows,
];

const _retiredHomeTraceRows = <HomeTraceRow>[
  ...familyRetiredHomeRows,
  ...akhlaqRetiredHomeRows,
  ...timeRetiredHomeRows,
  ...wealthRetiredHomeRows,
  ...ummahRetiredHomeRows,
];

HomeTraceOntologyRecord _homeTraceRecord(
  HomeTraceRow row,
  OntologyNodeStatus status,
) {
  return HomeTraceOntologyRecord(
    storageKey: row.storageKey,
    conceptualDomain: _conceptualDomainForTraceKey(row.storageKey),
    status: status,
    sourceMonitorDomain: monitorDomainForStorageKey(row.storageKey),
    familyLabel: row.band,
  );
}

ConceptualDomainId _conceptualDomainForTraceKey(String storageKey) {
  if (storageKey.startsWith('family.')) {
    return ConceptualDomainId.rightsFamilyRelationships;
  }
  final monitor = monitorDomainForStorageKey(storageKey);
  if (monitor == null) {
    throw StateError('No conceptual domain for homeTrace $storageKey');
  }
  return conceptualDomainForMonitor(monitor);
}
