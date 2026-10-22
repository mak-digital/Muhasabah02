import 'dart:async';

import 'hajj_online_assist.dart';
import 'hajj_online_contracts.dart';
import 'hajj_planning.dart';
import 'hajj_worker_limits.dart';

String hajjSanitizePublicBody(String body, int maxBytes) {
  final stripped = body
      .replaceAll(
        RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
        ' ',
      )
      .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ');
  if (stripped.length <= maxBytes) return stripped;
  return stripped.substring(0, maxBytes);
}

const kHajjLiveContractVersion = 'v1';
const kHajjLiveCacheTtl = Duration(hours: 24);
const kHajjLiveRateLimit = 5;
const kHajjLiveRateWindow = Duration(minutes: 1);
const kHajjLiveNotVerified =
    'A successful HTTP response is not official verification. Confirm on the source page.';

const kHajjAllowedLiveHosts = {
  'www.haj.gov.sa',
  'haj.gov.sa',
  'www.nusuk.sa',
  'nusuk.sa',
  'www.gov.uk',
};

const kHajjForbiddenLiveKeys = {
  'url',
  'uri',
  'href',
  'html',
  'body',
  'passport',
  'passportNumber',
  'scan',
  'reflection',
  'health',
  'displayName',
  'family',
  'notes',
  'name',
};

class HajjLiveAdapter {
  const HajjLiveAdapter({
    required this.id,
    required this.authorityName,
    required this.officialUrl,
    required this.host,
    required this.path,
    required this.jurisdictionCountry,
    this.nationalityCodes = const [],
    this.alwaysInclude = false,
  });

  final String id;
  final String authorityName;
  final String officialUrl;
  final String host;
  final String path;
  final String jurisdictionCountry;
  final List<String> nationalityCodes;
  final bool alwaysInclude;
}

const kHajjLivePilotAdapters = <HajjLiveAdapter>[
  HajjLiveAdapter(
    id: 'reg.sa.hajj.ministry',
    authorityName: 'Ministry of Hajj and Umrah',
    officialUrl: 'https://www.haj.gov.sa/',
    host: 'www.haj.gov.sa',
    path: '/',
    jurisdictionCountry: 'SA',
    alwaysInclude: true,
  ),
  HajjLiveAdapter(
    id: 'reg.sa.nusuk',
    authorityName: 'Nusuk',
    officialUrl: 'https://www.nusuk.sa/',
    host: 'www.nusuk.sa',
    path: '/',
    jurisdictionCountry: 'SA',
    alwaysInclude: true,
  ),
  HajjLiveAdapter(
    id: 'reg.gb.fcdo.pilgrimage',
    authorityName: 'UK FCDO pilgrimage advice',
    officialUrl:
        'https://www.gov.uk/foreign-travel-advice/saudi-arabia/pilgrimage',
    host: 'www.gov.uk',
    path: '/foreign-travel-advice/saudi-arabia/pilgrimage',
    jurisdictionCountry: 'GB',
    nationalityCodes: ['GB'],
  ),
];

class HajjWorkerException implements Exception {
  HajjWorkerException(this.status, this.message);
  final int status;
  final String message;
}

class HajjCacheEntry {
  HajjCacheEntry({
    required this.body,
    required this.storedAt,
    required this.expiresAt,
  });

  final String body;
  final DateTime storedAt;
  final DateTime expiresAt;
}

class HajjMemoryKv {
  HajjMemoryKv();

  final Map<String, HajjCacheEntry> _entries = {};

  HajjCacheEntry? get(String key) => _entries[key];

  void set(String key, HajjCacheEntry entry) => _entries[key] = entry;
}

class HajjDailyQuotaStore {
  HajjDailyQuotaStore();

  final Map<String, int> _counts = {};

  int get(String key) => _counts[key] ?? 0;

  int increment(String key) {
    final next = get(key) + 1;
    _counts[key] = next;
    return next;
  }
}

typedef HajjAllowlistedGet = Future<({int status, String body})> Function(
  Uri uri,
);

class HajjSourceWorker {
  HajjSourceWorker({
    required this.fetch,
    HajjMemoryKv? cache,
    Map<String, List<DateTime>>? rateBuckets,
    HajjDailyQuotaStore? quotas,
    this.limits = HajjWorkerQuotaConfig.freePlanDefaults,
  }) : cache = cache ?? HajjMemoryKv(),
       rateBuckets = rateBuckets ?? <String, List<DateTime>>{},
       quotas = quotas ?? HajjDailyQuotaStore();

  final HajjAllowlistedGet fetch;
  final HajjMemoryKv cache;
  final Map<String, List<DateTime>> rateBuckets;
  final HajjDailyQuotaStore quotas;
  final HajjWorkerQuotaConfig limits;
  final Map<String, Future<({int status, String body})>> _originInFlight = {};

  Map<String, Object?> privacyLog({
    required int status,
    required List<String> sourceIds,
    required List<String> countryCodes,
    required bool cacheHit,
  }) {
    return {
      'status': status,
      'sourceIds': sourceIds,
      'countryCodes': countryCodes,
      'cacheHit': cacheHit,
    };
  }

  Future<Map<String, Object?>> handle({
    required Map<String, Object?> body,
    required String clientKey,
    required DateTime now,
  }) async {
    _noteIncoming(now);
    _validate(body);
    _rateLimit(clientKey, now);
    _consumeDailyQuota(clientKey, now);
    final season = body['season'] as String?;
    final countries = _countries(body);
    final adapters = [
      for (final adapter in kHajjLivePilotAdapters)
        if (adapter.alwaysInclude ||
            countries.any(adapter.nationalityCodes.contains))
          adapter,
    ];
    if (adapters.isEmpty) {
      throw HajjWorkerException(
        422,
        'No official-source adapter for the recorded countries. Requirements are unknown.',
      );
    }
    var cacheHit = false;
    final sources = <Map<String, Object?>>[];
    for (final adapter in adapters) {
      final result = await _retrieve(adapter, now: now);
      cacheHit = cacheHit || result.cacheHit;
      sources.add(_sourceJson(adapter, result, season: season, now: now));
    }
    final conflicts = _conflicts(sources);
    return {
      'contractVersion': kHajjLiveContractVersion,
      'channel': 'live',
      'unavailable': sources.every(
        (item) =>
            item['retrievalMode'] == HajjSourceRetrievalMode.unavailable.name,
      ),
      'conflicts': conflicts,
      'sources': sources,
      'providers': const [],
      'message': kHajjLiveNotVerified,
      'log': privacyLog(
        status: 200,
        sourceIds: [for (final adapter in adapters) adapter.id],
        countryCodes: countries,
        cacheHit: cacheHit,
      ),
    };
  }

  void _rateLimit(String clientKey, DateTime now) {
    final bucket = rateBuckets.putIfAbsent(clientKey, () => <DateTime>[]);
    bucket.removeWhere((stamp) => now.difference(stamp) > kHajjLiveRateWindow);
    if (bucket.length >= limits.burstPerMinute) {
      throw HajjWorkerException(429, kHajjQuotaBurstMessage);
    }
    bucket.add(now);
  }

  void _validate(Map<String, Object?> body) {
    if (body.isEmpty) {
      throw HajjWorkerException(400, 'Request was empty.');
    }
    for (final key in body.keys) {
      if (kHajjForbiddenLiveKeys.contains(key)) {
        throw HajjWorkerException(400, 'Request contained a forbidden field.');
      }
      if (!kHajjAllowedPayloadKeys.contains(key)) {
        throw HajjWorkerException(400, 'Request contained an unknown field.');
      }
    }
    if (!hajjOnlinePayloadIsSafe(body)) {
      throw HajjWorkerException(400, 'Request contained private fields.');
    }
  }

  void _noteIncoming(DateTime now) {
    final day = now.toUtc().toIso8601String().substring(0, 10);
    final key = 'incoming:$day';
    if (quotas.get(key) >= limits.globalIncomingDaily) {
      throw HajjWorkerException(429, kHajjQuotaGlobalMessage);
    }
    quotas.increment(key);
  }

  void _consumeDailyQuota(String clientKey, DateTime now) {
    final day = now.toUtc().toIso8601String().substring(0, 10);
    final globalKey = 'accepted:$day';
    final installKey = 'install:$clientKey:$day';
    if (quotas.get(globalKey) >= limits.globalAcceptedDaily) {
      throw HajjWorkerException(429, kHajjQuotaGlobalMessage);
    }
    if (quotas.get(installKey) >= limits.perInstallDaily) {
      throw HajjWorkerException(429, kHajjQuotaUserMessage);
    }
    quotas.increment(globalKey);
    quotas.increment(installKey);
  }

  List<String> _countries(Map<String, Object?> body) {
    final values = <String>{
      if (body['nationalityCountry'] is String)
        (body['nationalityCountry'] as String).trim().toUpperCase(),
      if (body['residenceCountry'] is String)
        (body['residenceCountry'] as String).trim().toUpperCase(),
      if (body['departureCountry'] is String)
        (body['departureCountry'] as String).trim().toUpperCase(),
      if (body['returnCountry'] is String)
        (body['returnCountry'] as String).trim().toUpperCase(),
      ..._stringList(body['nationalityCountries']),
      ..._stringList(body['residenceCountries']),
      ..._stringList(body['citizenships']),
    }.difference({''});
    return values.toList()..sort();
  }

  Future<({HajjSourceRetrievalMode mode, String? body, bool cacheHit})>
  _retrieve(HajjLiveAdapter adapter, {required DateTime now}) async {
    final uri = Uri.parse(adapter.officialUrl);
    if (!_allowlisted(uri, adapter)) {
      return (
        mode: HajjSourceRetrievalMode.unavailable,
        body: null,
        cacheHit: false,
      );
    }
    final cached = cache.get(adapter.id);
    if (cached != null && cached.expiresAt.isAfter(now)) {
      return (
        mode: HajjSourceRetrievalMode.liveHttp,
        body: cached.body,
        cacheHit: true,
      );
    }
    try {
      final response = await _coalescedOrigin(adapter.id, uri, now);
      if (response.status == 0 || response.status == 599) {
        if (cached != null) {
          return (
            mode: HajjSourceRetrievalMode.liveHttp,
            body: cached.body,
            cacheHit: true,
          );
        }
        return (
          mode: HajjSourceRetrievalMode.manualLink,
          body: null,
          cacheHit: false,
        );
      }
      if (response.status == 200 && response.body.trim().isNotEmpty) {
        if (_looksLikeScript(response.body)) {
          return (
            mode: HajjSourceRetrievalMode.unavailable,
            body: null,
            cacheHit: false,
          );
        }
        final trimmed = hajjSanitizePublicBody(
          response.body,
          limits.maxBodyBytes,
        );
        cache.set(
          adapter.id,
          HajjCacheEntry(
            body: trimmed,
            storedAt: now,
            expiresAt: now.add(limits.cacheTtl),
          ),
        );
        return (
          mode: HajjSourceRetrievalMode.liveHttp,
          body: trimmed,
          cacheHit: false,
        );
      }
      if (cached != null) {
        return (
          mode: HajjSourceRetrievalMode.liveHttp,
          body: cached.body,
          cacheHit: true,
        );
      }
      if (response.status == 401 ||
          response.status == 403 ||
          response.status == 429) {
        return (
          mode: HajjSourceRetrievalMode.manualLink,
          body: null,
          cacheHit: false,
        );
      }
      return (
        mode: HajjSourceRetrievalMode.unavailable,
        body: null,
        cacheHit: false,
      );
    } catch (_) {
      if (cached != null) {
        return (
          mode: HajjSourceRetrievalMode.liveHttp,
          body: cached.body,
          cacheHit: true,
        );
      }
      return (
        mode: HajjSourceRetrievalMode.manualLink,
        body: null,
        cacheHit: false,
      );
    }
  }

  Future<({int status, String body})> _coalescedOrigin(
    String adapterId,
    Uri uri,
    DateTime now,
  ) {
    final existing = _originInFlight[adapterId];
    if (existing != null) return existing;
    final pending = () async {
      if (!_reserveOrigin(adapterId, now)) {
        return (status: 0, body: '');
      }
      try {
        return await fetch(uri).timeout(limits.fetchTimeout);
      } catch (_) {
        return (status: 599, body: '');
      }
    }();
    _originInFlight[adapterId] = pending;
    pending.whenComplete(() => _originInFlight.remove(adapterId));
    return pending;
  }

  bool _reserveOrigin(String adapterId, DateTime now) {
    final day = now.toUtc().toIso8601String().substring(0, 10);
    if (quotas.get('origin:$day') >= limits.originGetsGlobalDaily) {
      return false;
    }
    if (quotas.get('origin:$adapterId:$day') >=
        limits.originGetsPerAdapterDaily) {
      return false;
    }
    quotas.increment('origin:$day');
    quotas.increment('origin:$adapterId:$day');
    return true;
  }

  bool _looksLikeScript(String body) {
    final text = body.trimLeft().toLowerCase();
    return text.startsWith('function') ||
        text.startsWith('import ') ||
        text.startsWith('<script');
  }

  bool _allowlisted(Uri uri, HajjLiveAdapter adapter) {
    if (uri.scheme != 'https') return false;
    if (!kHajjAllowedLiveHosts.contains(uri.host)) return false;
    if (uri.host != adapter.host &&
        uri.host != adapter.host.replaceFirst('www.', '')) {
      return false;
    }
    final path = uri.path.isEmpty ? '/' : uri.path;
    if (path.contains('/api/') || path.contains('login')) return false;
    final expected = adapter.path.endsWith('/') && adapter.path != '/'
        ? adapter.path.substring(0, adapter.path.length - 1)
        : adapter.path;
    return path == expected ||
        path == '$expected/' ||
        (expected == '/' && (path == '/' || path.isEmpty));
  }

  Map<String, Object?> _sourceJson(
    HajjLiveAdapter adapter,
    ({HajjSourceRetrievalMode mode, String? body, bool cacheHit}) result, {
    required String? season,
    required DateTime now,
  }) {
    final retrieved = now.toIso8601String().substring(0, 10);
    final excerpt = _excerpt(adapter, result.body);
    return {
      'id': 'src.live.${adapter.id}',
      'title': adapter.authorityName,
      'uri': adapter.officialUrl,
      'issuingAuthority': adapter.authorityName,
      'jurisdictionCountry': adapter.jurisdictionCountry,
      'applicableSeason': season,
      'retrievedAt': retrieved,
      'requirementText': excerpt,
      'verificationStatus': HajjVerificationStatus.unverified.name,
      'origin': HajjSourceOrigin.liveWorker.name,
      'provenance': HajjProvenanceKind.liveRetrieval.name,
      'demonstration': false,
      'retrievalMode': result.mode.name,
      'authenticityStatus': 'officialPortalBookmark',
      'freshnessStatus':
          result.cacheHit &&
              (cache.get(adapter.id)?.expiresAt.isBefore(now) ?? false)
          ? 'stale'
          : result.mode == HajjSourceRetrievalMode.liveHttp
          ? 'retrieved'
          : 'unknown',
      'applicabilityStatus': 'possiblyRelevant',
      'limitations': kHajjLiveNotVerified,
      'deadline': null,
    };
  }

  String _excerpt(HajjLiveAdapter adapter, String? body) {
    if (body == null || body.trim().isEmpty) {
      return 'Open ${adapter.officialUrl} and confirm current requirements. Automated retrieval did not produce a usable page.';
    }
    if (adapter.id == 'reg.gb.fcdo.pilgrimage' &&
        body.toLowerCase().contains('nusuk')) {
      return 'GOV.UK pilgrimage advice mentions booking Hajj through the official Nusuk platform. Confirm on the page. This is not a Saudi ruling.';
    }
    if (adapter.id == 'reg.sa.nusuk') {
      return 'Nusuk public homepage was retrieved. Confirm current Hajj procedures on the official site. This app does not book.';
    }
    return 'Official homepage was retrieved. Confirm current requirements on the source page.';
  }

  List<String> _conflicts(List<Map<String, Object?>> sources) {
    final texts = {
      for (final source in sources)
        if (source['requirementText'] is String)
          source['requirementText'] as String,
    };
    if (texts.length <= 1) return const [];
    return [
      'Official-source wording differs. Keep both as unverified. The app does not choose.',
    ];
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is String && item.trim().isNotEmpty) item.trim().toUpperCase(),
  ];
}
