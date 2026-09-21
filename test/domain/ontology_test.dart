import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/ontology.dart';
import 'package:muhasabah02/domain/quran.dart';

void main() {
  test(
    'ontology registry has an explicit version independent of schema v6',
    () {
      expect(kOntologyRegistryVersion, 1);
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
      expect(TernaryOutcome.positive.legendLabel, 'Recorded engagement');
      expect(TernaryOutcome.negative.legendLabel, 'Recorded as not done');
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
