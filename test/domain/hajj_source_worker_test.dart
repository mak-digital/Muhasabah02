import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/hajj_live_gateway.dart';
import 'package:muhasabah02/domain/hajj_online_assist.dart';
import 'package:muhasabah02/domain/hajj_planning.dart';
import 'package:muhasabah02/domain/hajj_source_worker.dart';
import 'package:muhasabah02/domain/hajj_worker_limits.dart';

void main() {
  final now = DateTime.utc(2026, 10, 18, 7);

  HajjSourceWorker worker({
    HajjAllowlistedGet? fetch,
    HajjMemoryKv? cache,
    Map<String, List<DateTime>>? rates,
    HajjDailyQuotaStore? quotas,
    HajjWorkerQuotaConfig limits = HajjWorkerQuotaConfig.freePlanDefaults,
  }) {
    return HajjSourceWorker(
      fetch:
          fetch ??
          (uri) async => (status: 200, body: 'Nusuk official homepage'),
      cache: cache,
      rateBuckets: rates,
      quotas: quotas,
      limits: limits,
    );
  }

  test('allowlist rejects client-supplied URLs and unknown keys', () async {
    final subject = worker();
    expect(
      () => subject.handle(
        body: {'url': 'https://evil.example', 'season': '1448'},
        clientKey: 'a',
        now: now,
      ),
      throwsA(isA<HajjWorkerException>()),
    );
    expect(
      () => subject.handle(
        body: {'season': '1448', 'displayName': 'Aisha'},
        clientKey: 'a',
        now: now,
      ),
      throwsA(isA<HajjWorkerException>()),
    );
  });

  test('malformed empty requests are rejected', () {
    expect(
      () => worker().handle(body: const {}, clientKey: 'a', now: now),
      throwsA(
        isA<HajjWorkerException>().having(
          (error) => error.status,
          'status',
          400,
        ),
      ),
    );
  });

  test('unsupported nationality still returns Saudi portals, not GB', () async {
    final json = await worker().handle(
      body: const {'nationalityCountry': 'ZZ', 'season': '1448'},
      clientKey: 'a',
      now: now,
    );
    final ids = [
      for (final source in json['sources'] as List)
        (source as Map)['id'] as String,
    ];
    expect(ids, contains('src.live.reg.sa.hajj.ministry'));
    expect(ids, contains('src.live.reg.sa.nusuk'));
    expect(ids, isNot(contains('src.live.reg.gb.fcdo.pilgrimage')));
  });

  test('GB nationality includes the FCDO pilgrimage adapter', () async {
    final json =
        await worker(
          fetch: (uri) async {
            expect(uri.host, isIn(kHajjAllowedLiveHosts));
            expect(uri.scheme, 'https');
            if (uri.host.contains('gov.uk')) {
              expect(uri.path, contains('pilgrimage'));
              return (status: 200, body: 'Book through Nusuk Hajj platform');
            }
            return (status: 200, body: 'official');
          },
        ).handle(
          body: const {
            'nationalityCountries': ['GB'],
            'season': '1448',
          },
          clientKey: 'gb',
          now: now,
        );
    final ids = [
      for (final source in json['sources'] as List)
        (source as Map)['id'] as String,
    ];
    expect(ids, contains('src.live.reg.gb.fcdo.pilgrimage'));
    expect(json['conflicts'], isNotEmpty);
  });

  test('blocked sources become manual verification, never verified', () async {
    final json = await worker(fetch: (uri) async => (status: 403, body: ''))
        .handle(body: const {'season': '1448'}, clientKey: 'a', now: now);
    final sources = json['sources'] as List;
    expect(
      sources.every(
        (item) =>
            (item as Map)['verificationStatus'] == 'unverified' &&
            item['retrievalMode'] == 'manualLink' &&
            item['deadline'] == null,
      ),
      isTrue,
    );
  });

  test('unavailable fetch is labelled and stays unverified', () async {
    final json = await worker(fetch: (uri) async => (status: 500, body: ''))
        .handle(body: const {'season': '1448'}, clientKey: 'a', now: now);
    expect(
      (json['sources'] as List).every(
        (item) => (item as Map)['retrievalMode'] == 'unavailable',
      ),
      isTrue,
    );
  });

  test('cache expires after 24 hours', () async {
    var calls = 0;
    final cache = HajjMemoryKv();
    final subject = worker(
      cache: cache,
      fetch: (uri) async {
        calls += 1;
        return (status: 200, body: 'page $calls');
      },
    );
    await subject.handle(
      body: const {'season': '1448'},
      clientKey: 'a',
      now: now,
    );
    await subject.handle(
      body: const {'season': '1448'},
      clientKey: 'a',
      now: now.add(const Duration(hours: 1)),
    );
    expect(calls, 2);
    await subject.handle(
      body: const {'season': '1448'},
      clientKey: 'b',
      now: now.add(const Duration(hours: 25)),
    );
    expect(calls, 4);
  });

  test('rate limits repeat callers', () async {
    final rates = <String, List<DateTime>>{};
    final subject = worker(rates: rates);
    for (var i = 0; i < kHajjLiveRateLimit; i++) {
      await subject.handle(
        body: const {'season': '1448'},
        clientKey: 'same',
        now: now.add(Duration(seconds: i)),
      );
    }
    expect(
      () => subject.handle(
        body: const {'season': '1448'},
        clientKey: 'same',
        now: now.add(const Duration(seconds: 30)),
      ),
      throwsA(
        isA<HajjWorkerException>().having(
          (error) => error.status,
          'status',
          429,
        ),
      ),
    );
  });

  test('privacy log has no names, reflections or URLs from the client', () {
    final log = worker().privacyLog(
      status: 200,
      sourceIds: ['reg.sa.nusuk'],
      countryCodes: ['GB'],
      cacheHit: true,
    );
    expect(log.keys, ['status', 'sourceIds', 'countryCodes', 'cacheHit']);
    expect(log.toString(), isNot(contains('Aisha')));
    expect(log.toString(), isNot(contains('reflection')));
  });

  test('live gateway does not change standing or add milestones', () async {
    const store = HajjStore(
      standing: HajjStandingRecord(kind: HajjStandingKind.believeDue),
      journeys: [HajjJourney(id: 'j1')],
      activeJourneyId: 'j1',
    );
    final gateway = LiveHajjOnlineAssistGateway.local(worker());
    final bundle = await gateway.lookupOfficial(
      const HajjLookupRequest(season: '1448', nationalityCountry: 'GB'),
    );
    expect(bundle.sources, isNotEmpty);
    expect(
      bundle.sources.every(
        (item) =>
            item.verificationStatus == HajjVerificationStatus.unverified &&
            item.origin == HajjSourceOrigin.liveWorker &&
            item.provenance == HajjProvenanceKind.liveRetrieval &&
            item.deadline == null &&
            !item.demonstration,
      ),
      isTrue,
    );
    expect(store.selectedJourney!.milestones, isEmpty);
    expect(store.standing.kind, HajjStandingKind.believeDue);
    expect(
      () => gateway.interpret(
        request: const HajjLookupRequest(),
        todayKey: '2026-10-18',
      ),
      throwsA(
        isA<HajjOnlineAssistException>().having(
          (error) => error.message,
          'message',
          kHajjAiDisabled,
        ),
      ),
    );
  });

  test('schemaVersion 1 still decodes sources without live fields', () {
    final source = HajjOfficialSource.fromJson(const {
      'id': 'old',
      'verificationStatus': 'unverified',
      'demonstration': true,
    });
    expect(source.retrievalMode, HajjSourceRetrievalMode.unknown);
    expect(source.origin, HajjSourceOrigin.demonstration);
    const store = HajjStore();
    expect(store.schemaVersion, 1);
  });

  test('rejected requests do not consume daily quota', () async {
    final quotas = HajjDailyQuotaStore();
    expect(
      () =>
          worker(quotas: quotas)
              .handle(body: const {}, clientKey: 'a', now: now),
      throwsA(isA<HajjWorkerException>()),
    );
    expect(quotas.get('accepted:2026-10-18'), 0);
    expect(quotas.get('incoming:2026-10-18'), 1);
  });

  test(
    'per-user daily quota returns 429 without a second origin fetch',
    () async {
      var calls = 0;
      final subject = worker(
        fetch: (uri) async {
          calls += 1;
          return (status: 200, body: 'ok');
        },
        limits: const HajjWorkerQuotaConfig(
          perInstallDaily: 1,
          globalAcceptedDaily: 800,
          burstPerMinute: 20,
        ),
      );
      await subject.handle(
        body: const {'season': '1448'},
        clientKey: 'same',
        now: now,
      );
      expect(calls, 2);
      expect(
        () => subject.handle(
          body: const {'season': '1448'},
          clientKey: 'same',
          now: now.add(const Duration(seconds: 10)),
        ),
        throwsA(
          isA<HajjWorkerException>()
              .having((error) => error.status, 'status', 429)
              .having(
                (error) => error.message,
                'message',
                kHajjQuotaUserMessage,
              ),
        ),
      );
      expect(calls, 2);
    },
  );

  test('global daily quota blocks later users the same UTC day', () async {
    final quotas = HajjDailyQuotaStore();
    final subject = worker(
      quotas: quotas,
      limits: const HajjWorkerQuotaConfig(
        perInstallDaily: 5,
        globalAcceptedDaily: 1,
        burstPerMinute: 20,
      ),
    );
    await subject.handle(
      body: const {'season': '1448'},
      clientKey: 'first',
      now: now,
    );
    expect(
      () => subject.handle(
        body: const {'season': '1448'},
        clientKey: 'second',
        now: now.add(const Duration(seconds: 5)),
      ),
      throwsA(
        isA<HajjWorkerException>().having(
          (error) => error.message,
          'message',
          kHajjQuotaGlobalMessage,
        ),
      ),
    );
  });

  test('expired cache is served stale when origin fails once', () async {
    var calls = 0;
    final cache = HajjMemoryKv();
    cache.set(
      'reg.sa.hajj.ministry',
      HajjCacheEntry(
        body: 'old ministry',
        storedAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.subtract(const Duration(hours: 1)),
      ),
    );
    cache.set(
      'reg.sa.nusuk',
      HajjCacheEntry(
        body: 'old nusuk',
        storedAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.subtract(const Duration(hours: 1)),
      ),
    );
    final json = await worker(
      cache: cache,
      fetch: (uri) async {
        calls += 1;
        throw Exception('origin down');
      },
    ).handle(body: const {'season': '1448'}, clientKey: 'a', now: now);
    expect(calls, 2);
    expect(
      (json['sources'] as List).every(
        (item) =>
            (item as Map)['retrievalMode'] == 'liveHttp' &&
            item['freshnessStatus'] == 'stale',
      ),
      isTrue,
    );
  });

  test('origin fetch is not retried after timeout', () async {
    var calls = 0;
    final subject = worker(
      fetch: (uri) {
        calls += 1;
        return Completer<({int status, String body})>().future;
      },
      limits: const HajjWorkerQuotaConfig(
        fetchTimeout: Duration(milliseconds: 20),
      ),
    );
    final json = await subject.handle(
      body: const {'season': '1448'},
      clientKey: 'a',
      now: now,
    );
    expect(calls, 2);
    expect(
      (json['sources'] as List).every(
        (item) => (item as Map)['retrievalMode'] == 'manualLink',
      ),
      isTrue,
    );
  });

  test('origin fetches coalesce and ignore extra installations', () async {
    var calls = 0;
    final subject = worker(
      fetch: (uri) async {
        calls += 1;
        return (status: 200, body: '<p>ok</p><script>alert(1)</script>');
      },
      limits: const HajjWorkerQuotaConfig(
        burstPerMinute: 40,
        originGetsGlobalDaily: 1,
        originGetsPerAdapterDaily: 1,
      ),
    );
    await Future.wait([
      subject.handle(body: const {'season': '1448'}, clientKey: 'o1', now: now),
      subject.handle(body: const {'season': '1448'}, clientKey: 'o2', now: now),
    ]);
    expect(calls, 1);
  });

  test('concurrent accepted quota does not overshoot on one isolate', () async {
    final quotas = HajjDailyQuotaStore();
    final subject = worker(
      quotas: quotas,
      limits: const HajjWorkerQuotaConfig(
        perInstallDaily: 20,
        globalAcceptedDaily: 8,
        burstPerMinute: 40,
      ),
    );
    final results = await Future.wait([
      for (var i = 0; i < 24; i++)
        () async {
          try {
            await subject.handle(
              body: const {'season': '1448'},
              clientKey: 'n$i',
              now: now,
            );
            return 200;
          } on HajjWorkerException catch (error) {
            return error.status;
          }
        }(),
    ]);
    expect(results.where((code) => code == 200).length, 8);
    expect(results.where((code) => code == 429).length, 16);
    expect(quotas.get('accepted:2026-10-18'), 8);
    expect(quotas.get('incoming:2026-10-18'), 24);
  });

  test('selectable gateway stays on demo when live is absent', () async {
    const selectable = SelectableHajjOnlineAssistGateway(
      demo: DemoHajjOnlineAssistGateway(),
    );
    final bundle = await selectable.lookupOfficial(const HajjLookupRequest());
    expect(bundle.sources.every((item) => item.demonstration), isTrue);
    expect(hajjLiveLookupConfigured, isFalse);
  });
}
