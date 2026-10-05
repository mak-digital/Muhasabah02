import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/activities.dart';
import 'package:muhasabah02/domain/charity_factors.dart';
import 'package:muhasabah02/domain/context_catalog.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/ontology.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/salah_factors.dart';

void main() {
  test(
    'ontology registry has an explicit version independent of schema v6',
    () {
      expect(kOntologyRegistryVersion, 2);
      expect(OntologyRegistry.version, kOntologyRegistryVersion);
      expect(OntologyRegistry.version, isNot(6));
    },
  );

  test(
    'every active MonitorDomain resolves to exactly one conceptual domain',
    () {
      final seen = <MonitorDomain>{};
      for (final domain in MonitorDomain.values) {
        final record = OntologyRegistry.forMonitorDomain(domain);
        expect(record.sourceMonitorDomains, contains(domain));
        expect(record.isObservationDomain, isTrue);
        expect(seen.add(domain), isTrue);
      }
      expect(seen, MonitorDomain.values.toSet());

      expect(
        OntologyRegistry.forMonitorDomain(MonitorDomain.wealth).id,
        ConceptualDomainId.financialStewardshipGiving,
      );
      expect(
        OntologyRegistry.forMonitorDomain(MonitorDomain.charity).id,
        ConceptualDomainId.financialStewardshipGiving,
      );
      expect(
        OntologyRegistry.conceptualDomain(
          ConceptualDomainId.reflectionPersonalResponse,
        ).sourceMonitorDomains,
        isEmpty,
      );
    },
  );

  test(
    'every QuranDimension resolves exactly once without renaming persisted ids',
    () {
      final seen = <QuranDimension>{};
      for (final dimension in QuranDimension.values) {
        final record = OntologyRegistry.forQuranDimension(dimension);
        expect(record.dimension, dimension);
        expect(record.persistedId, dimension.name);
        expect(record.persistedId, dimension.jsonKey);
        expect(
          record.conceptualDomain,
          ConceptualDomainId.quranRevelationEngagement,
        );
        expect(seen.add(dimension), isTrue);
      }
      expect(seen.length, QuranDimension.values.length);
      expect(
        OntologyRegistry.quranDimensions.length,
        QuranDimension.values.length,
      );
    },
  );

  test('Qur’an conceptual groups are non-ordinal metadata', () {
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.reading).group,
      QuranConceptualGroup.directEngagement,
    );
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.meaning).group,
      QuranConceptualGroup.understandingActivities,
    );
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.tafsir).group,
      QuranConceptualGroup.understandingActivities,
    );
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.memorisation).group,
      QuranConceptualGroup.memorisationRetention,
    );
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.revision).group,
      QuranConceptualGroup.memorisationRetention,
    );
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.reflection).group,
      QuranConceptualGroup.reflection,
    );
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.consciousApplication)
          .group,
      QuranConceptualGroup.practicalRelevance,
    );
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.applicationReflection)
          .group,
      QuranConceptualGroup.privatePracticalReflection,
    );

    for (final group in QuranConceptualGroup.values) {
      expect(quranGroupOrdinal(group), isNull);
    }

    final ranks = {
      for (final record in OntologyRegistry.quranDimensions)
        record.group: quranGroupOrdinal(record.group),
    };
    expect(ranks.values.every((rank) => rank == null), isTrue);
  });

  test(
    'every active homeTrace key from the production catalog resolves once',
    () {
      final catalog = _activeCatalogRows();
      final keys = catalog.map((row) => row.storageKey).toList();
      expect(keys.toSet().length, keys.length);

      for (final row in catalog) {
        final record = OntologyRegistry.forHomeTrace(row.storageKey);
        expect(record, isNotNull, reason: row.storageKey);
        expect(record!.storageKey, row.storageKey);
        expect(record.status, OntologyNodeStatus.active);
        expect(record.familyLabel, row.band);
      }

      final activeRecords = [
        for (final record in OntologyRegistry.homeTraces)
          if (record.status == OntologyNodeStatus.active) record,
      ];
      expect(activeRecords.length, catalog.length);
      expect(
        {for (final record in activeRecords) record.storageKey},
        {for (final row in catalog) row.storageKey},
      );
    },
  );

  test('retired homeTrace keys remain resolvable and are marked retired', () {
    final catalog = _retiredCatalogRows();
    expect(catalog, isNotEmpty);
    for (final row in catalog) {
      final record = OntologyRegistry.forHomeTrace(row.storageKey);
      expect(record, isNotNull, reason: row.storageKey);
      expect(record!.storageKey, row.storageKey);
      expect(record.status, OntologyNodeStatus.retired);
    }

    final family = OntologyRegistry.forHomeTrace('family.parentsContact');
    expect(family, isNotNull);
    expect(family!.status, OntologyNodeStatus.retired);
    expect(
      family.conceptualDomain,
      ConceptualDomainId.rightsFamilyRelationships,
    );
    expect(family.sourceMonitorDomain, isNull);

    expect(
      OntologyRegistry.forHomeTrace('akhlaq.guardedMyGlance')?.status,
      OntologyNodeStatus.retired,
    );
    expect(
      OntologyRegistry.forHomeTrace('time.guardedPrayerWindow')?.status,
      OntologyNodeStatus.retired,
    );
  });

  test('registry lookup does not mutate persisted ids', () {
    const key = 'huquq.parents';
    final first = OntologyRegistry.forHomeTrace(key)!;
    final second = OntologyRegistry.forHomeTrace(key)!;
    expect(first.storageKey, key);
    expect(second.storageKey, key);
    expect(identical(first.storageKey, key) || first.storageKey == key, isTrue);

    final quran = OntologyRegistry.forQuranDimension(QuranDimension.reading);
    expect(quran.persistedId, 'reading');
    expect(QuranDimension.reading.name, 'reading');
    expect(QuranDimension.reading.jsonKey, 'reading');
  });

  test('homeTrace registry has no duplicate storage ids', () {
    final keys = [
      for (final record in OntologyRegistry.homeTraces) record.storageKey,
    ];
    expect(keys.toSet().length, keys.length);

    final catalogKeys = [for (final row in allHomeTraceRows) row.storageKey];
    expect(
      keys.toSet(),
      catalogKeys.toSet(),
      reason: 'registry must cover the production allHomeTraceRows catalog',
    );
  });

  test('ontology lookups are deterministic', () {
    expect(
      OntologyRegistry.forMonitorDomain(MonitorDomain.salah).id,
      OntologyRegistry.forMonitorDomain(MonitorDomain.salah).id,
    );
    expect(
      OntologyRegistry.forQuranDimension(QuranDimension.tafsir).group,
      OntologyRegistry.forQuranDimension(QuranDimension.tafsir).group,
    );
    expect(
      OntologyRegistry.forHomeTrace('dhikr.postFardFajr')?.conceptualDomain,
      OntologyRegistry.forHomeTrace('dhikr.postFardFajr')?.conceptualDomain,
    );
    expect(
      OntologyRegistry.homeTraces.map((record) => record.storageKey).toList(),
      OntologyRegistry.homeTraces.map((record) => record.storageKey).toList(),
    );
  });

  test(
    'registry does not change unanswered or negative observation semantics',
    () {
      expect(TernaryOutcome.unanswered.isRecorded, isFalse);
      expect(TernaryOutcome.negative.isRecorded, isTrue);
      expect(TernaryOutcome.positive.legendLabel, 'Recorded sitting');
      expect(TernaryOutcome.negative.legendLabel, 'I did not notice this today');
      expect(TernaryOutcome.unanswered.legendLabel, 'Unanswered');

      for (final record in OntologyRegistry.reflectionSubjects) {
        expect(record.isObservationScore, isFalse);
        expect(record.mayBeSemanticallyInterpreted, isFalse);
        expect(
          record.conceptualDomain,
          ConceptualDomainId.reflectionPersonalResponse,
        );
      }
    },
  );

  test('every production activity id resolves exactly once per catalog', () {
    for (final entry in _productionActivityCatalogs()) {
      final seen = <String>{};
      for (final option in entry.options) {
        expect(seen.add(option.id), isTrue, reason: option.id);
        final record = OntologyRegistry.forActivity(entry.catalog, option.id);
        expect(record, isNotNull, reason: '${entry.catalog.name}:${option.id}');
        expect(record!.persistedId, option.id);
        expect(record.catalog, entry.catalog);
        expect(record.status, entry.status);
        expect(record.impliesOrdinalStage, isFalse);
        expect(record.impliesSpiritualQuality, isFalse);
        expect(record.impliesCertifiedMerit, isFalse);
      }
    }
  });

  test('retired activity catalogs remain resolvable', () {
    expect(
      OntologyRegistry.forActivity(
        OntologyActivityCatalog.quranLegacy,
        'readWithTranslation',
      )?.status,
      OntologyNodeStatus.retired,
    );
    expect(
      OntologyRegistry.forActivity(
        OntologyActivityCatalog.family,
        'parentCommunication',
      )?.status,
      OntologyNodeStatus.retired,
    );
    expect(
      OntologyRegistry.forActivity(
        OntologyActivityCatalog.conduct,
        'patience',
      )?.status,
      OntologyNodeStatus.retired,
    );
    expect(
      OntologyRegistry.forActivity(
        OntologyActivityCatalog.family,
        'parentCommunication',
      )?.persistedId,
      'parentCommunication',
    );
  });

  test('activity registry has no duplicate stable ids', () {
    final ids = [
      for (final record in OntologyRegistry.activities) record.stableId,
    ];
    expect(ids.toSet().length, ids.length);
  });

  test('activity persisted ids match production catalogs', () {
    for (final entry in _productionActivityCatalogs()) {
      final production = {for (final option in entry.options) option.id};
      final registered = {
        for (final record in OntologyRegistry.activities)
          if (record.catalog == entry.catalog) record.persistedId,
      };
      expect(registered, production);
    }
  });

  test('Salah activity metadata is not a spiritual quality rank', () {
    for (final option in ActivityCatalog.salah) {
      final record = OntologyRegistry.forActivity(
        OntologyActivityCatalog.salah,
        option.id,
      )!;
      expect(record.conceptualDomain, ConceptualDomainId.salahPrayerPractice);
      expect(record.impliesSpiritualQuality, isFalse);
      expect(record.impliesOrdinalStage, isFalse);
      if (option.id == ActivityIds.unanswered ||
          option.id == ActivityIds.other) {
        expect(record.kind, OntologyConstructKind.observationState);
      } else {
        expect(record.kind, OntologyConstructKind.practiceObservation);
      }
    }
    expect(
      OntologyRegistry.forActivity(
        OntologyActivityCatalog.salah,
        'congregationOnTime',
      )!.persistedId,
      'congregationOnTime',
    );
    expect(
      OntologyRegistry.forActivity(
        OntologyActivityCatalog.salah,
        'missedMadeUp',
      )!.persistedId,
      'missedMadeUp',
    );
  });

  test('Qur’an activity metadata does not introduce ordinal semantics', () {
    for (final record in OntologyRegistry.activities) {
      if (record.conceptualDomain !=
          ConceptualDomainId.quranRevelationEngagement) {
        continue;
      }
      expect(record.impliesOrdinalStage, isFalse);
      if (record.quranGroup != null) {
        expect(quranGroupOrdinal(record.quranGroup!), isNull);
      }
    }
    expect(
      OntologyRegistry.forActivity(
        OntologyActivityCatalog.quranConsciousApplication,
        'improvedWorship',
      )!.persistedId,
      'improvedWorship',
    );
    expect(
      OntologyRegistry.forActivity(
        OntologyActivityCatalog.quranMeaning,
        'recitedWithMeaning',
      )!.quranGroup,
      QuranConceptualGroup.understandingActivities,
    );
  });

  test('context factors are provenance, not behavioural outcomes', () {
    expect(OntologyRegistry.factors, isNotEmpty);
    for (final record in OntologyRegistry.factors) {
      expect(record.kind, OntologyConstructKind.contextProvenance);
      expect(record.isCause, isFalse);
      expect(record.isOutcome, isFalse);
      expect(record.isRecommendation, isFalse);
    }
    expect(
      OntologyRegistry.forFactor(
        catalog: OntologyFactorCatalog.salah,
        persistedId: 'salah.alarmWorked',
        polarity: 'positive',
      )?.isOutcome,
      isFalse,
    );
    expect(
      OntologyRegistry.forFactor(
        catalog: OntologyFactorCatalog.quranContext,
        persistedId: 'forgot',
      )?.status,
      OntologyNodeStatus.retired,
    );
  });

  test('factor registry covers production catalogs without duplicate ids', () {
    final ids = [
      for (final record in OntologyRegistry.factors) record.stableId,
    ];
    expect(ids.toSet().length, ids.length);

    for (final factor in ContextCatalog.positive) {
      expect(
        OntologyRegistry.forFactor(
          catalog: OntologyFactorCatalog.quranContext,
          persistedId: factor.id,
          polarity: 'positive',
        ),
        isNotNull,
      );
    }
    for (final factor in SalahFactorCatalog.support) {
      expect(
        OntologyRegistry.forFactor(
          catalog: OntologyFactorCatalog.salah,
          persistedId: factor.id,
          polarity: 'positive',
        )?.persistedId,
        factor.id,
      );
    }
    for (final factor in CharityFactorCatalog.challenge) {
      expect(
        OntologyRegistry.forFactor(
          catalog: OntologyFactorCatalog.charity,
          persistedId: factor.id,
          polarity: 'negative',
        )?.persistedId,
        factor.id,
      );
    }
  });

  test('reflective content is not classified as a scored observation', () {
    for (final record in OntologyRegistry.reflectionSubjects) {
      expect(record.isObservationScore, isFalse);
      expect(record.mayBeSemanticallyInterpreted, isFalse);
    }
    final gratitude = OntologyRegistry.forActivity(
      OntologyActivityCatalog.gratitude,
      'namedBlessing',
    )!;
    expect(gratitude.kind, OntologyConstructKind.reflectiveContent);
    expect(
      gratitude.conceptualDomain,
      ConceptualDomainId.reflectionPersonalResponse,
    );
    expect(
      OntologyRegistry.forActivity(OntologyActivityCatalog.zakat, 'due')!.kind,
      OntologyConstructKind.standingStatus,
    );
  });
}

List<HomeTraceRow> _activeCatalogRows() {
  return [
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
}

List<HomeTraceRow> _retiredCatalogRows() {
  return [
    ...familyRetiredHomeRows,
    ...akhlaqRetiredHomeRows,
    ...timeRetiredHomeRows,
    ...wealthRetiredHomeRows,
    ...ummahRetiredHomeRows,
  ];
}

class _ActivityCatalogEntry {
  const _ActivityCatalogEntry({
    required this.catalog,
    required this.options,
    required this.status,
  });

  final OntologyActivityCatalog catalog;
  final List<ActivityOption> options;
  final OntologyNodeStatus status;
}

List<_ActivityCatalogEntry> _productionActivityCatalogs() {
  return const [
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.salah,
      options: ActivityCatalog.salah,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.quranReading,
      options: ActivityCatalog.quranReading,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.quranMeaning,
      options: ActivityCatalog.quranMeaning,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.quranMemorisation,
      options: ActivityCatalog.quranMemorisation,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.quranRevision,
      options: ActivityCatalog.quranRevision,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.quranTafsir,
      options: ActivityCatalog.quranTafsir,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.quranReflection,
      options: ActivityCatalog.quranReflection,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.quranConsciousApplication,
      options: ActivityCatalog.quranConsciousApplication,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.quranLegacy,
      options: ActivityCatalog.quranLegacy,
      status: OntologyNodeStatus.retired,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.dhikr,
      options: ActivityCatalog.dhikr,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.conduct,
      options: ActivityCatalog.conduct,
      status: OntologyNodeStatus.retired,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.gratitude,
      options: ActivityCatalog.gratitude,
      status: OntologyNodeStatus.retired,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.personalReflection,
      options: ActivityCatalog.personalReflection,
      status: OntologyNodeStatus.retired,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.fasting,
      options: ActivityCatalog.fasting,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.charity,
      options: ActivityCatalog.charity,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.zakat,
      options: ActivityCatalog.zakat,
      status: OntologyNodeStatus.active,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.family,
      options: ActivityCatalog.family,
      status: OntologyNodeStatus.retired,
    ),
    _ActivityCatalogEntry(
      catalog: OntologyActivityCatalog.hadith,
      options: ActivityCatalog.hadith,
      status: OntologyNodeStatus.active,
    ),
  ];
}
