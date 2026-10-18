/**
 * Cloudflare Worker for Hajj official-source retrieval.
 * Dart twin: lib/domain/hajj_source_worker.dart
 *
 * Quotas live in this isolate's memory. That is concurrency-safe on one
 * isolate (local wrangler / one process). It is NOT a worldwide hard cap:
 * Cloudflare may run many isolates. KV read-modify-write is not used for
 * quotas (not atomic; Free same-key writes are 1/s).
 *
 * Installation keys are opaque headers, not authenticated users.
 * Do not deploy without owner approval. Do not fetch client-supplied URLs.
 */

export const CONTRACT_VERSION = 'v1';
export const ALLOWED_KEYS = new Set([
  'season',
  'nationalityCountry',
  'nationalityCountries',
  'residenceCountry',
  'residenceCountries',
  'departureCountry',
  'returnCountry',
  'pathwayIds',
  'citizenships',
]);
export const FORBIDDEN = [
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
];
const ALLOWED_HOSTS = new Set([
  'www.haj.gov.sa',
  'haj.gov.sa',
  'www.nusuk.sa',
  'nusuk.sa',
  'www.gov.uk',
]);
const ADAPTERS = [
  {
    id: 'reg.sa.hajj.ministry',
    authorityName: 'Ministry of Hajj and Umrah',
    officialUrl: 'https://www.haj.gov.sa/',
    host: 'www.haj.gov.sa',
    path: '/',
    jurisdictionCountry: 'SA',
    alwaysInclude: true,
    nationalityCodes: [],
  },
  {
    id: 'reg.sa.nusuk',
    authorityName: 'Nusuk',
    officialUrl: 'https://www.nusuk.sa/',
    host: 'www.nusuk.sa',
    path: '/',
    jurisdictionCountry: 'SA',
    alwaysInclude: true,
    nationalityCodes: [],
  },
  {
    id: 'reg.gb.fcdo.pilgrimage',
    authorityName: 'UK FCDO pilgrimage advice',
    officialUrl:
      'https://www.gov.uk/foreign-travel-advice/saudi-arabia/pilgrimage',
    host: 'www.gov.uk',
    path: '/foreign-travel-advice/saudi-arabia/pilgrimage',
    jurisdictionCountry: 'GB',
    alwaysInclude: false,
    nationalityCodes: ['GB'],
  },
];

/** Isolate-local counters. Hard within this process; not global in production. */
export const isolateQuota = {
  day: '',
  incoming: 0,
  accepted: 0,
  originGlobal: 0,
  install: new Map(),
  burst: new Map(),
  originByAdapter: new Map(),
};

const memoryCache = new Map();
const inFlightOrigin = new Map();

export function resetIsolateQuota() {
  isolateQuota.day = '';
  isolateQuota.incoming = 0;
  isolateQuota.accepted = 0;
  isolateQuota.originGlobal = 0;
  isolateQuota.install = new Map();
  isolateQuota.burst = new Map();
  isolateQuota.originByAdapter = new Map();
  memoryCache.clear();
  inFlightOrigin.clear();
}

export function utcDay(nowMs = Date.now()) {
  return new Date(nowMs).toISOString().slice(0, 10);
}

function rollDay(nowMs) {
  const day = utcDay(nowMs);
  if (isolateQuota.day !== day) {
    isolateQuota.day = day;
    isolateQuota.incoming = 0;
    isolateQuota.accepted = 0;
    isolateQuota.originGlobal = 0;
    isolateQuota.install = new Map();
    isolateQuota.burst = new Map();
    isolateQuota.originByAdapter = new Map();
  }
}

export function mockOriginMode(env) {
  const name = String(env.ENVIRONMENT || '').toLowerCase();
  if (name !== 'local' && name !== 'test') return '';
  return String(env.HAJJ_MOCK_ORIGIN || '');
}

/**
 * Count every Worker hit except /health. Rejected bodies still count.
 * Synchronous increment is atomic on a single-threaded isolate.
 */
export function noteIncoming(env, nowMs = Date.now()) {
  rollDay(nowMs);
  const cap = Number(env.GLOBAL_INCOMING_DAILY || 20000);
  if (isolateQuota.incoming >= cap) {
    throw publicError(
      429,
      'Live lookup has reached today’s shared incoming limit. Offline planning is unchanged.',
    );
  }
  isolateQuota.incoming += 1;
}

export function consumeAccepted(env, installKey, nowMs = Date.now()) {
  rollDay(nowMs);
  const perInstall = Number(env.PER_INSTALL_DAILY || env.PER_USER_DAILY_QUOTA || 5);
  const global = Number(env.GLOBAL_ACCEPTED_DAILY || env.GLOBAL_DAILY_QUOTA || 800);
  const burst = Number(env.BURST_PER_MINUTE || 5);
  const key = String(installKey || 'unknown').slice(0, 64);
  const minute = Math.floor(nowMs / 60000);
  const burstKey = `${key}:${minute}`;
  const burstCount = isolateQuota.burst.get(burstKey) || 0;
  if (burstCount >= burst) {
    throw publicError(
      429,
      'Live lookup is temporarily limited. Wait a minute. Offline planning is unchanged.',
    );
  }
  if (isolateQuota.accepted >= global) {
    throw publicError(
      429,
      'Live lookup has reached today’s shared limit. Try again after midnight UTC, or confirm sources by hand. Offline planning is unchanged.',
    );
  }
  const used = isolateQuota.install.get(key) || 0;
  if (used >= perInstall) {
    throw publicError(
      429,
      'Live lookup has reached today’s limit for this installation. Official pages can still be opened by hand. Offline planning is unchanged.',
    );
  }
  isolateQuota.burst.set(burstKey, burstCount + 1);
  isolateQuota.accepted += 1;
  isolateQuota.install.set(key, used + 1);
}

/** Demonstrates why KV is not used as a quota limiter. */
export async function unsafeKvReadModifyWrite(store, n) {
  const tasks = [];
  for (let i = 0; i < n; i += 1) {
    tasks.push(
      (async () => {
        const snap = store.g;
        await new Promise((resolve) => setTimeout(resolve, 5));
        store.g = snap + 1;
      })(),
    );
  }
  await Promise.all(tasks);
  return store.g;
}

export async function handleRequest(request, env, outboundFetch) {
  const url = new URL(request.url);
  if (request.method === 'GET' && url.pathname === '/health') {
    return json({
      ok: true,
      contractVersion: CONTRACT_VERSION,
      ai: false,
      quota: 'isolate-memory-plus-location-ratelimit',
      authenticatedUsers: false,
      environment: env.ENVIRONMENT || 'unspecified',
      mockOrigin: Boolean(mockOriginMode(env)),
    });
  }
  try {
    noteIncoming(env);
    if (request.method !== 'POST' || url.pathname !== '/v1/hajj/sources') {
      return json({ error: 'Not found' }, 404);
    }
    const incomingOk = await locationLimit(env, 'INCOMING_LIMITER', 'incoming');
    if (!incomingOk) {
      throw publicError(
        429,
        'Live lookup is temporarily limited. Wait a minute. Offline planning is unchanged.',
      );
    }
    const gate = String(env.PILOT_GATE || '');
    if (gate && request.headers.get('X-Muhasabah-Pilot') !== gate) {
      throw publicError(403, 'Live lookup is not enabled for this client.');
    }
    const installKey =
      request.headers.get('X-Muhasabah-Install') ||
      request.headers.get('CF-Connecting-IP') ||
      'unknown';
    const body = await request.json().catch(() => null);
    validate(body);
    consumeAccepted(env, installKey);
    const countries = collectCountries(body);
    const adapters = ADAPTERS.filter(
      (item) =>
        item.alwaysInclude ||
        countries.some((code) => item.nationalityCodes.includes(code)),
    );
    const sources = [];
    for (const adapter of adapters) {
      sources.push(await retrieve(env, adapter, body.season, outboundFetch));
    }
    return json({
      contractVersion: CONTRACT_VERSION,
      channel: 'live',
      unavailable: sources.every((item) => item.retrievalMode === 'unavailable'),
      conflicts:
        new Set(sources.map((item) => item.requirementText)).size > 1
          ? [
              'Official-source wording differs. Keep both as unverified. The app does not choose.',
            ]
          : [],
      sources,
      providers: [],
      message:
        'A successful HTTP response is not official verification. Confirm on the source page.',
      quota: {
        incoming: isolateQuota.incoming,
        accepted: isolateQuota.accepted,
        guarantee: 'isolate-memory-plus-location-ratelimit',
        originGets: isolateQuota.originGlobal,
      },
    });
  } catch (error) {
    const status = error.status || 500;
    return json(
      { error: error.publicMessage || 'Live official lookup is unavailable.' },
      status,
    );
  }
}

export function validate(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body) || Object.keys(body).length === 0) {
    throw publicError(400, 'Request was empty.');
  }
  for (const key of Object.keys(body)) {
    if (FORBIDDEN.includes(key)) {
      throw publicError(400, 'Request contained a forbidden field.');
    }
    if (!ALLOWED_KEYS.has(key)) {
      throw publicError(400, 'Request contained an unknown field.');
    }
  }
}

function collectCountries(body) {
  const values = new Set();
  for (const key of [
    'nationalityCountry',
    'residenceCountry',
    'departureCountry',
    'returnCountry',
  ]) {
    if (typeof body[key] === 'string' && body[key].trim()) {
      values.add(body[key].trim().toUpperCase());
    }
  }
  for (const key of ['nationalityCountries', 'residenceCountries', 'citizenships']) {
    if (Array.isArray(body[key])) {
      for (const item of body[key]) {
        if (typeof item === 'string' && item.trim()) values.add(item.trim().toUpperCase());
      }
    }
  }
  return [...values];
}

export function hostIsAllowed(hostname) {
  return ALLOWED_HOSTS.has(hostname);
}

export function contentTypeAllowed(contentType) {
  if (!contentType) return true;
  const value = contentType.toLowerCase();
  if (
    value.includes('javascript') ||
    value.includes('ecmascript') ||
    value.includes('wasm') ||
    value.includes('octet-stream')
  ) {
    return false;
  }
  return (
    value.includes('text/html') ||
    value.includes('xhtml') ||
    value.includes('text/plain') ||
    value.includes('xml')
  );
}

export function sanitizePublicBody(text, maxBytes) {
  return String(text || '')
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/on\w+="[^"]*"/gi, ' ')
    .slice(0, maxBytes);
}

export async function fetchAllowlisted(url, outboundFetch, timeoutMs, hops = 0) {
  const uri = new URL(url);
  if (uri.protocol !== 'https:' || !hostIsAllowed(uri.hostname)) {
    throw new Error('redirect host is not allowlisted');
  }
  if (uri.pathname.includes('/api/') || uri.pathname.toLowerCase().includes('login')) {
    throw new Error('blocked path');
  }
  const response = await outboundFetch(uri.toString(), {
    method: 'GET',
    redirect: 'manual',
    headers: { 'User-Agent': 'PrivateMuhasabah/1.0 HajjSources' },
    signal: AbortSignal.timeout(timeoutMs),
  });
  if ([301, 302, 303, 307, 308].includes(response.status)) {
    if (hops >= 2) throw new Error('too many redirects');
    const location = response.headers.get('location');
    if (!location) throw new Error('redirect missing location');
    return fetchAllowlisted(new URL(location, uri).toString(), outboundFetch, timeoutMs, hops + 1);
  }
  return response;
}

async function locationLimit(env, binding, key) {
  const limiter = env[binding];
  if (!limiter || typeof limiter.limit !== 'function') return true;
  const result = await limiter.limit({ key: String(key) });
  return result && result.success !== false;
}

function reserveOriginSlot(env, adapterId, nowMs = Date.now()) {
  rollDay(nowMs);
  const per = Number(env.ORIGIN_GETS_PER_ADAPTER_DAILY || 2);
  const glob = Number(env.ORIGIN_GETS_GLOBAL_DAILY || 8);
  if (isolateQuota.originGlobal >= glob) return false;
  const used = isolateQuota.originByAdapter.get(adapterId) || 0;
  if (used >= per) return false;
  isolateQuota.originGlobal += 1;
  isolateQuota.originByAdapter.set(adapterId, used + 1);
  return true;
}

async function retrieve(env, adapter, season, outboundFetch) {
  const uri = new URL(adapter.officialUrl);
  if (uri.protocol !== 'https:' || !hostIsAllowed(uri.hostname)) {
    return sourceRecord(adapter, season, 'unavailable', null);
  }
  if (uri.pathname.includes('/api/') || uri.pathname.includes('login')) {
    return sourceRecord(adapter, season, 'unavailable', null);
  }
  const cacheKey = adapter.id;
  const timeoutMs = Number(env.FETCH_TIMEOUT_MS || 8000);
  const ttlMs = Number(env.CACHE_TTL_SECONDS || 86400) * 1000;
  const maxBytes = Number(env.MAX_BODY_BYTES || 8000);
  const cached = await readCache(env, cacheKey);
  if (cached && cached.exp && cached.exp > Date.now()) {
    return sourceRecord(adapter, season, 'liveHttp', cached.body, 'retrieved');
  }
  try {
    const response = await coalescedOriginGet(env, adapter, outboundFetch, timeoutMs);
    if (!response) {
      if (cached && cached.body) {
        return sourceRecord(adapter, season, 'liveHttp', cached.body, 'stale');
      }
      return sourceRecord(adapter, season, 'manualLink', null);
    }
    if (response.status === 200) {
      if (!contentTypeAllowed(response.headers.get('content-type'))) {
        return sourceRecord(adapter, season, 'unavailable', null);
      }
      const text = sanitizePublicBody(await readLimitedText(response, maxBytes), maxBytes);
      await writeCache(env, cacheKey, { body: text, exp: Date.now() + ttlMs });
      return sourceRecord(adapter, season, 'liveHttp', text, 'retrieved');
    }
    if (cached && cached.body) {
      return sourceRecord(adapter, season, 'liveHttp', cached.body, 'stale');
    }
    if ([401, 403, 429].includes(response.status)) {
      return sourceRecord(adapter, season, 'manualLink', null);
    }
    return sourceRecord(adapter, season, 'unavailable', null);
  } catch (_) {
    if (cached && cached.body) {
      return sourceRecord(adapter, season, 'liveHttp', cached.body, 'stale');
    }
    return sourceRecord(adapter, season, 'manualLink', null);
  }
}

async function coalescedOriginGet(env, adapter, outboundFetch, timeoutMs) {
  const existing = inFlightOrigin.get(adapter.id);
  if (existing) return existing;
  const pending = originGet(env, adapter, outboundFetch, timeoutMs).finally(() => {
    inFlightOrigin.delete(adapter.id);
  });
  inFlightOrigin.set(adapter.id, pending);
  return pending;
}

async function originGet(env, adapter, outboundFetch, timeoutMs) {
  const mode = mockOriginMode(env);
  if (mode === 'ok') {
    return new Response('Nusuk official homepage mock', {
      status: 200,
      headers: { 'content-type': 'text/html; charset=utf-8' },
    });
  }
  if (mode === 'fail') {
    return new Response('', { status: 500 });
  }
  if (mode === 'timeout') {
    await new Promise((_, reject) => {
      setTimeout(() => reject(new Error('timeout')), timeoutMs + 50);
    });
  }
  const originOk = await locationLimit(env, 'ORIGIN_LIMITER', `origin:${adapter.id}`);
  if (!originOk) return null;
  if (!reserveOriginSlot(env, adapter.id)) return null;
  return fetchAllowlisted(adapter.officialUrl, outboundFetch, timeoutMs);
}

async function readLimitedText(response, maxBytes) {
  if (!response.body || typeof response.body.getReader !== 'function') {
    return (await response.text()).slice(0, maxBytes);
  }
  const reader = response.body.getReader();
  const chunks = [];
  let size = 0;
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    const piece = value || new Uint8Array();
    const next = size + piece.byteLength;
    if (next >= maxBytes) {
      chunks.push(piece.slice(0, Math.max(0, maxBytes - size)));
      try {
        await reader.cancel();
      } catch (_) {}
      break;
    }
    chunks.push(piece);
    size = next;
  }
  let total = 0;
  for (const chunk of chunks) total += chunk.byteLength;
  const merged = new Uint8Array(total);
  let offset = 0;
  for (const chunk of chunks) {
    merged.set(chunk, offset);
    offset += chunk.byteLength;
  }
  return new TextDecoder().decode(merged);
}

async function readCache(env, key) {
  const mem = memoryCache.get(key);
  if (mem) return mem;
  if (!env.HAJJ_SOURCE_CACHE) return null;
  const raw = await env.HAJJ_SOURCE_CACHE.get(key);
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch (_) {
    return { body: raw, exp: 0 };
  }
}

async function writeCache(env, key, entry) {
  memoryCache.set(key, entry);
  if (!env.HAJJ_SOURCE_CACHE) return;
  try {
    await env.HAJJ_SOURCE_CACHE.put(key, JSON.stringify(entry));
  } catch (_) {
    // Cache persistence is best-effort. Quotas do not use KV.
  }
}

function sourceRecord(adapter, season, mode, body, freshness) {
  const today = new Date().toISOString().slice(0, 10);
  return {
    id: `src.live.${adapter.id}`,
    title: adapter.authorityName,
    uri: adapter.officialUrl,
    issuingAuthority: adapter.authorityName,
    jurisdictionCountry: adapter.jurisdictionCountry,
    applicableSeason: season || null,
    retrievedAt: today,
    requirementText: excerpt(adapter, body),
    verificationStatus: 'unverified',
    provenance: 'userEntered',
    demonstration: false,
    retrievalMode: mode,
    authenticityStatus: 'officialPortalBookmark',
    freshnessStatus: freshness || (mode === 'liveHttp' ? 'retrieved' : 'unknown'),
    applicabilityStatus: 'possiblyRelevant',
    limitations:
      'A successful HTTP response is not official verification. Confirm on the source page.',
    deadline: null,
  };
}

function excerpt(adapter, body) {
  if (!body) {
    return `Open ${adapter.officialUrl} and confirm current requirements. Automated retrieval did not produce a usable page.`;
  }
  if (adapter.id === 'reg.gb.fcdo.pilgrimage' && body.toLowerCase().includes('nusuk')) {
    return 'GOV.UK pilgrimage advice mentions booking Hajj through the official Nusuk platform. Confirm on the page. This is not a Saudi ruling.';
  }
  if (adapter.id === 'reg.sa.nusuk') {
    return 'Nusuk public homepage was retrieved. Confirm current Hajj procedures on the official site. This app does not book.';
  }
  return 'Official homepage was retrieved. Confirm current requirements on the source page.';
}

export function publicError(status, publicMessage) {
  const error = new Error(publicMessage);
  error.status = status;
  error.publicMessage = publicMessage;
  return error;
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8' },
  });
}
