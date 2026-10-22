import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:muhasabah02/data/hive_repositories.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/hajj_planning.dart';

void main() {
  test('empty store initializes at schema version 1', () {
    const store = HajjStore();
    expect(store.schemaVersion, kHajjStoreSchemaVersion);
    expect(store.standing.kind, HajjStandingKind.unanswered);
    expect(store.journeys, isEmpty);
    expect(store.travelers, isEmpty);
    expect(store.afterHajj.isEmpty, isTrue);
  });

  test('serialization round-trips optional and unknown fields', () {
    final original = HajjStore(
      standing: const HajjStandingRecord(
        kind: HajjStandingKind.performed,
        updatedAt: '2026-10-17T00:00:00.000',
      ),
      standingHistory: const [
        HajjStandingEvent(
          kind: HajjStandingKind.performed,
          recordedAt: '2026-10-17T00:00:00.000',
        ),
      ],
      travelers: const [
        HajjTravelerProfile(
          id: 't1',
          role: HajjTravelerRole.self,
          citizenships: ['GB'],
        ),
        HajjTravelerProfile(
          id: 't2',
          role: HajjTravelerRole.spouse,
          displayName: 'Spouse',
          consentConfirmed: true,
        ),
      ],
      journeys: [
        HajjJourney(
          id: 'j1',
          lifecycle: HajjJourneyLifecycle.planning,
          targetSeason: const HajjSeason(hijriYear: 1447, datesUnknown: false),
          travelerIds: const ['t1', 't2'],
          datesUnknown: true,
          readiness: const [
            HajjReadinessPrerequisite(
              id: 'r1',
              title: 'Passport',
              status: HajjReadinessStatus.unknown,
            ),
            HajjReadinessPrerequisite(
              id: 'r2',
              title: 'Not applicable item',
              status: HajjReadinessStatus.notApplicable,
            ),
          ],
          milestones: const [
            HajjMilestone(
              id: 'm1',
              title: 'Apply',
              dependsOn: [],
              plannedDate: '2026-12-01',
              status: HajjMilestoneStatus.pending,
            ),
            HajjMilestone(
              id: 'm2',
              title: 'Travel',
              dependsOn: ['m1'],
              status: HajjMilestoneStatus.unanswered,
            ),
          ],
        ),
        const HajjJourney(
          id: 'j2',
          lifecycle: HajjJourneyLifecycle.considering,
        ),
      ],
      sources: const [
        HajjOfficialSource(
          id: 's1',
          title: 'Ministry page',
          verificationStatus: HajjVerificationStatus.unverified,
        ),
      ],
      afterHajj: const HajjAfterRecord(
        continuingPracticeIds: ['hj.prep.noticed.bukhari_1513'],
        returnIntention: HajjAfterReturnIntention.notPlanning,
      ),
    );

    final encoded = encodeHajjStore(original);
    final decoded = decodeHajjStore(encoded);
    expect(decoded.kind, HajjStoreDecodeKind.ok);
    expect(decoded.store!.standing.kind, HajjStandingKind.performed);
    expect(decoded.store!.journeys.length, 2);
    expect(decoded.store!.travelers.length, 2);
    expect(decoded.store!.journeys.first.milestones.last.dependsOn, ['m1']);
    expect(
      decoded.store!.journeys.first.readiness.last.status,
      HajjReadinessStatus.notApplicable,
    );
    expect(decoded.store!.afterHajj.reflectionText, isNull);
    expect(
      jsonDecode(encoded),
      isA<Map>().having((map) => map['schemaVersion'], 'schema', 1),
    );
  });

  test('missing and unknown JSON fields stay optional', () {
    final decoded = decodeHajjStore(
      jsonEncode({'schemaVersion': 1, 'extraFutureField': true}),
    );
    expect(decoded.kind, HajjStoreDecodeKind.ok);
    expect(decoded.store!.standing.kind, HajjStandingKind.unanswered);
    expect(decoded.store!.journeys, isEmpty);
  });

  test('schema version validation', () {
    expect(decodeHajjStore(null).kind, HajjStoreDecodeKind.missing);
    expect(decodeHajjStore('').kind, HajjStoreDecodeKind.missing);
    expect(decodeHajjStore('not-json').kind, HajjStoreDecodeKind.corrupt);
    expect(
      decodeHajjStore(jsonEncode({'schemaVersion': 99})).kind,
      HajjStoreDecodeKind.unknownVersion,
    );
    expect(
      decodeHajjStore(jsonEncode({'schemaVersion': 0})).kind,
      HajjStoreDecodeKind.corrupt,
    );
  });

  test('standing and journey lifecycles stay separate', () {
    var store = const HajjStore().withStanding(
      HajjStandingKind.performed,
      recordedAt: '2026-01-01',
    );
    expect(store.journeys, isEmpty);
    expect(store.hasActiveJourney, isFalse);
    store = store.upsertJourney(
      const HajjJourney(
        id: 'next',
        lifecycle: HajjJourneyLifecycle.considering,
      ),
    );
    expect(store.standing.kind, HajjStandingKind.performed);
    expect(store.journeys.single.lifecycle, HajjJourneyLifecycle.considering);
  });

  test('create edit delete travelers and journeys persist in memory', () async {
    final repo = MemoryHajjStoreRepository();
    await repo.initializeIfNeeded();
    final first = encodeHajjStore(repo.store);
    await repo.initializeIfNeeded();
    expect(repo.initializeCount, 2);
    expect(repo.persistedRaw, first);

    var store = repo.store.upsertTraveler(
      const HajjTravelerProfile(id: 't1', role: HajjTravelerRole.self),
    );
    store = store.upsertJourney(
      const HajjJourney(id: 'j1', travelerIds: ['t1']),
    );
    await repo.save(store);
    expect(repo.store.travelers.single.id, 't1');
    expect(repo.store.journeys.single.id, 'j1');

    store = repo.store.upsertTraveler(
      const HajjTravelerProfile(
        id: 't1',
        role: HajjTravelerRole.self,
        notes: 'edited',
      ),
    );
    await repo.save(store);
    expect(repo.store.travelers.single.notes, 'edited');

    await repo.save(repo.store.deleteJourney('j1').deleteTraveler('t1'));
    expect(repo.store.journeys, isEmpty);
    expect(repo.store.travelers, isEmpty);
  });

  test('unknown schema is not overwritten', () async {
    final repo = MemoryHajjStoreRepository(
      raw: jsonEncode({'schemaVersion': 9, 'keep': true}),
    );
    expect(repo.hasUnknownSchema, isTrue);
    await repo.initializeIfNeeded();
    await repo.save(
      const HajjStore(
        standing: HajjStandingRecord(kind: HajjStandingKind.preparing),
      ),
    );
    expect(jsonDecode(repo.persistedRaw!), containsPair('schemaVersion', 9));
  });

  test(
    'existing install discards legacy hajj_status without migrating',
    () async {
      final repo = MemoryHajjStoreRepository(legacyHajjStatusPresent: true);
      await repo.initializeIfNeeded();
      expect(repo.legacyHajjStatusPresent, isFalse);
      expect(repo.store.standing.kind, HajjStandingKind.unanswered);
    },
  );

  test('Hive Hajj store initializes once and round-trips offline', () async {
    final dir = await Directory.systemTemp.createTemp('hajj_store');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      dir.deleteSync(recursive: true);
    });

    final prefsBox = await Hive.openBox<String>('prefs');
    await prefsBox.put(kLegacyHajjStatusPrefsKey, 'due');
    final prefs = HiveAppPrefs(prefsBox);
    expect(prefs.hasLegacyHajjStatus, isTrue);
    await prefs.discardLegacyHajjStatus();
    expect(prefs.hasLegacyHajjStatus, isFalse);

    final box = await Hive.openBox<String>('hajj');
    final repo = HiveHajjStoreRepository(box);
    await repo.initializeIfNeeded();
    expect(box.keys.length, 1);
    await repo.initializeIfNeeded();
    expect(box.keys.length, 1);

    await repo.save(
      repo.store.withStanding(
        HajjStandingKind.notApplicable,
        recordedAt: '2026-10-17T00:00:00.000',
      ),
    );
    final reread = HiveHajjStoreRepository(box);
    await reread.initializeIfNeeded();
    expect(reread.store.standing.kind, HajjStandingKind.notApplicable);

    await box.put(kHajjStoreDocumentKey, jsonEncode({'schemaVersion': 12}));
    final future = HiveHajjStoreRepository(box);
    await future.initializeIfNeeded();
    expect(future.hasUnknownSchema, isTrue);
    expect(
      jsonDecode(box.get(kHajjStoreDocumentKey)!),
      containsPair('schemaVersion', 12),
    );
  });

  test('legacy live rows are reclassified without rewriting user sources', () {
    final decoded = decodeHajjStore(
      jsonEncode({
        'schemaVersion': 1,
        'standing': {'kind': 'believeDue'},
        'journeys': [
          {'id': 'j1', 'lifecycle': 'planning'},
        ],
        'activeJourneyId': 'j1',
        'sources': [
          {
            'id': 'src.live.reg.sa.nusuk',
            'verificationStatus': 'unverified',
            'provenance': 'userEntered',
            'retrievalMode': 'liveHttp',
            'demonstration': false,
          },
          {
            'id': 'src.manual.keep',
            'title': 'My bookmark',
            'verificationStatus': 'unverified',
            'provenance': 'userEntered',
          },
          {
            'id': 'src.demo.reg.sa.hajj.ministry',
            'verificationStatus': 'unverified',
            'demonstration': true,
            'provenance': 'userEntered',
          },
          {
            'id': 'src.live.reg.sa.hajj.ministry',
            'verificationStatus': 'verifiedByUser',
            'provenance': 'officialVerified',
            'retrievalMode': 'liveHttp',
          },
        ],
      }),
    );
    expect(decoded.kind, HajjStoreDecodeKind.ok);
    final store = decoded.store!;
    expect(store.schemaVersion, 1);
    expect(store.standing.kind, HajjStandingKind.believeDue);
    expect(store.journeys.single.id, 'j1');
    expect(store.sources[0].origin, HajjSourceOrigin.liveWorker);
    expect(store.sources[0].provenance, HajjProvenanceKind.liveRetrieval);
    expect(
      store.sources[0].verificationStatus,
      HajjVerificationStatus.unverified,
    );
    expect(store.sources[1].origin, HajjSourceOrigin.userEntered);
    expect(store.sources[1].provenance, HajjProvenanceKind.userEntered);
    expect(store.sources[2].origin, HajjSourceOrigin.demonstration);
    expect(store.sources[2].provenance, HajjProvenanceKind.userEntered);
    expect(store.sources[3].origin, HajjSourceOrigin.liveWorker);
    expect(store.sources[3].provenance, HajjProvenanceKind.officialVerified);
    expect(
      store.sources[3].verificationStatus,
      HajjVerificationStatus.verifiedByUser,
    );
  });

  test('Hive rewrite persists origin correction and keeps standing', () async {
    final dir = await Directory.systemTemp.createTemp('hajj_origin');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      dir.deleteSync(recursive: true);
    });
    final box = await Hive.openBox<String>('hajj_origin');
    await box.put(
      kHajjStoreDocumentKey,
      jsonEncode({
        'schemaVersion': 1,
        'standing': {'kind': 'believeDue'},
        'sources': [
          {
            'id': 'src.live.reg.sa.nusuk',
            'verificationStatus': 'unverified',
            'provenance': 'userEntered',
            'retrievalMode': 'liveHttp',
          },
        ],
      }),
    );
    final repo = HiveHajjStoreRepository(box);
    await repo.initializeIfNeeded();
    expect(repo.store.standing.kind, HajjStandingKind.believeDue);
    expect(repo.store.sources.single.origin, HajjSourceOrigin.liveWorker);
    final persisted = jsonDecode(box.get(kHajjStoreDocumentKey)!) as Map;
    expect(persisted['schemaVersion'], 1);
    expect((persisted['sources'] as List).first['origin'], 'liveWorker');
    expect((persisted['sources'] as List).first['provenance'], 'liveRetrieval');
    expect((persisted['standing'] as Map)['kind'], 'believeDue');
  });
}
