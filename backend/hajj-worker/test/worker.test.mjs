import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';
import {
  consumeAccepted,
  contentTypeAllowed,
  fetchAllowlisted,
  handleRequest,
  isolateQuota,
  liveGateRequired,
  mockOriginMode,
  noteIncoming,
  resetIsolateQuota,
  sanitizePublicBody,
  unsafeKvReadModifyWrite,
  validate,
} from '../src/logic.js';

const env = {
  ENVIRONMENT: 'test',
  PER_INSTALL_DAILY: '5',
  GLOBAL_ACCEPTED_DAILY: '800',
  GLOBAL_INCOMING_DAILY: '20000',
  BURST_PER_MINUTE: '50',
  FETCH_TIMEOUT_MS: '50',
  CACHE_TTL_SECONDS: '86400',
  ORIGIN_GETS_PER_ADAPTER_DAILY: '2',
  ORIGIN_GETS_GLOBAL_DAILY: '8',
  HAJJ_MOCK_ORIGIN: 'ok',
};

afterEach(() => {
  resetIsolateQuota();
});

function request(body, headers = {}, path = '/v1/hajj/sources', method = 'POST') {
  return new Request(`https://hajj.local${path}`, {
    method,
    headers: { 'content-type': 'application/json', ...headers },
    body: method === 'POST' ? JSON.stringify(body) : undefined,
  });
}

test('health does not consume quota and advertises no auth users', async () => {
  const res = await handleRequest(
    new Request('https://hajj.local/health'),
    env,
    globalThis.fetch,
  );
  assert.equal(res.status, 200);
  const json = await res.json();
  assert.equal(json.ai, false);
  assert.equal(json.authenticatedUsers, false);
  assert.equal(json.mockOrigin, true);
  assert.equal(json.gateRequired, false);
  assert.equal(json.pilotGateConfigured, false);
  assert.match(json.quota, /location-ratelimit/);
  assert.equal(isolateQuota.incoming, 0);
});

test('allowlist rejects client URLs and private fields', async () => {
  const urlRes = await handleRequest(
    request({ url: 'https://evil.example', season: '1448' }),
    env,
    globalThis.fetch,
  );
  assert.equal(urlRes.status, 400);
  const nameRes = await handleRequest(
    request({ displayName: 'Aisha', season: '1448' }),
    env,
    globalThis.fetch,
  );
  assert.equal(nameRes.status, 400);
  assert.equal(isolateQuota.incoming, 2);
  assert.equal(isolateQuota.accepted, 0);
});

test('consent fields are unknown to the Worker', () => {
  assert.throws(() => validate({ lookupConsented: true, season: '1448' }));
});

test('rejected traffic counts as incoming, not accepted', async () => {
  for (let i = 0; i < 12; i += 1) {
    const res = await handleRequest(request({}), env, globalThis.fetch);
    assert.equal(res.status, 400);
  }
  assert.equal(isolateQuota.incoming, 12);
  assert.equal(isolateQuota.accepted, 0);
});

test('installation daily quota is not an authenticated user quota', async () => {
  const tight = { ...env, PER_INSTALL_DAILY: '1', BURST_PER_MINUTE: '20' };
  const first = await handleRequest(
    request({ season: '1448' }, { 'X-Muhasabah-Install': 'phone-a' }),
    tight,
    globalThis.fetch,
  );
  assert.equal(first.status, 200);
  const second = await handleRequest(
    request({ season: '1448' }, { 'X-Muhasabah-Install': 'phone-a' }),
    tight,
    globalThis.fetch,
  );
  assert.equal(second.status, 429);
  const body = await second.json();
  assert.match(body.error, /installation/);
  const other = await handleRequest(
    request({ season: '1448' }, { 'X-Muhasabah-Install': 'phone-b' }),
    tight,
    globalThis.fetch,
  );
  assert.equal(other.status, 200);
});

test('isolate accepted quota is exact under concurrent load', async () => {
  const tight = {
    ...env,
    GLOBAL_ACCEPTED_DAILY: '10',
    PER_INSTALL_DAILY: '50',
    BURST_PER_MINUTE: '50',
  };
  const results = await Promise.all(
    Array.from({ length: 40 }, (_, i) =>
      handleRequest(
        request({ season: '1448' }, { 'X-Muhasabah-Install': `n-${i}` }),
        tight,
        globalThis.fetch,
      ),
    ),
  );
  const ok = results.filter((item) => item.status === 200).length;
  const limited = results.filter((item) => item.status === 429).length;
  assert.equal(ok, 10);
  assert.equal(limited, 30);
  assert.equal(isolateQuota.accepted, 10);
  assert.equal(isolateQuota.incoming, 40);
});

test('incoming cap includes failed requests', async () => {
  const tight = { ...env, GLOBAL_INCOMING_DAILY: '5' };
  const statuses = [];
  for (let i = 0; i < 8; i += 1) {
    const res = await handleRequest(request({}), tight, globalThis.fetch);
    statuses.push(res.status);
  }
  assert.deepEqual(statuses.slice(0, 5), [400, 400, 400, 400, 400]);
  assert.equal(statuses[5], 429);
  assert.equal(isolateQuota.incoming, 5);
});

test('KV read-modify-write is not a hard quota', async () => {
  const lost = await unsafeKvReadModifyWrite({ g: 0 }, 25);
  assert.notEqual(lost, 25);
});

test('isolate increment is a hard quota on one thread', () => {
  const local = { PER_INSTALL_DAILY: '100', GLOBAL_ACCEPTED_DAILY: '8', BURST_PER_MINUTE: '100' };
  let accepted = 0;
  let rejected = 0;
  for (let i = 0; i < 20; i += 1) {
    try {
      consumeAccepted(local, `k-${i}`);
      accepted += 1;
    } catch {
      rejected += 1;
    }
  }
  assert.equal(accepted, 8);
  assert.equal(rejected, 12);
  assert.equal(isolateQuota.accepted, 8);
});

test('timeout uses one attempt and falls back without retry', async () => {
  let calls = 0;
  const outbound = async () => {
    calls += 1;
    throw new Error('timeout');
  };
  const res = await handleRequest(
    request({ season: '1448' }),
    { ...env, HAJJ_MOCK_ORIGIN: '' },
    outbound,
  );
  assert.equal(res.status, 200);
  const json = await res.json();
  assert.equal(calls, 2);
  assert.ok(
    json.sources.every((item) => item.retrievalMode === 'manualLink'),
  );
  const again = await handleRequest(
    request({ season: '1448' }),
    { ...env, HAJJ_MOCK_ORIGIN: '' },
    outbound,
  );
  await again.json();
  assert.equal(calls, 4);
});

test('fresh mock cache avoids a second origin fetch', async () => {
  let calls = 0;
  const outbound = async () => {
    calls += 1;
    return new Response('cached-body nusuk', { status: 200 });
  };
  const first = await handleRequest(
    request({ season: '1448' }),
    { ...env, HAJJ_MOCK_ORIGIN: '' },
    outbound,
  );
  assert.equal(first.status, 200);
  const second = await handleRequest(
    request({ season: '1448' }),
    { ...env, HAJJ_MOCK_ORIGIN: '' },
    outbound,
  );
  assert.equal(second.status, 200);
  assert.equal(calls, 2);
});

test('noteIncoming is counted before validation', () => {
  noteIncoming({ GLOBAL_INCOMING_DAILY: '3' });
  noteIncoming({ GLOBAL_INCOMING_DAILY: '3' });
  noteIncoming({ GLOBAL_INCOMING_DAILY: '3' });
  assert.throws(() => noteIncoming({ GLOBAL_INCOMING_DAILY: '3' }));
  assert.equal(isolateQuota.incoming, 3);
});

test('production and staging ignore HAJJ_MOCK_ORIGIN', () => {
  assert.equal(mockOriginMode({ ENVIRONMENT: 'production', HAJJ_MOCK_ORIGIN: 'ok' }), '');
  assert.equal(mockOriginMode({ ENVIRONMENT: 'staging', HAJJ_MOCK_ORIGIN: 'ok' }), '');
  assert.equal(mockOriginMode({ ENVIRONMENT: 'local', HAJJ_MOCK_ORIGIN: 'ok' }), 'ok');
  assert.equal(liveGateRequired({ ENVIRONMENT: 'staging' }), true);
  assert.equal(liveGateRequired({ ENVIRONMENT: 'production' }), true);
  assert.equal(liveGateRequired({ ENVIRONMENT: 'test' }), false);
});

test('off-allowlist redirects are not followed', async () => {
  const outbound = async (url, init) => {
    assert.equal(init.redirect, 'manual');
    if (String(url).includes('nusuk.sa')) {
      return new Response(null, {
        status: 302,
        headers: { location: 'https://evil.example/phish' },
      });
    }
    throw new Error('followed unapproved host');
  };
  await assert.rejects(() => fetchAllowlisted('https://www.nusuk.sa/', outbound, 200));
});

test('allowlisted redirects may be followed', async () => {
  const outbound = async (url) => {
    if (String(url).includes('haj.gov.sa')) {
      return new Response(null, {
        status: 302,
        headers: { location: 'https://www.nusuk.sa/' },
      });
    }
    return new Response('<html>ok</html>', {
      status: 200,
      headers: { 'content-type': 'text/html' },
    });
  };
  const res = await fetchAllowlisted('https://www.haj.gov.sa/', outbound, 200);
  assert.equal(res.status, 200);
});

test('javascript content types are rejected', () => {
  assert.equal(contentTypeAllowed('application/javascript'), false);
  assert.equal(contentTypeAllowed('text/html; charset=utf-8'), true);
});

test('script tags are stripped from stored excerpts', () => {
  const clean = sanitizePublicBody('<p>Hi</p><script>alert(1)</script>', 8000);
  assert.equal(clean.includes('script'), false);
  assert.equal(clean.includes('Hi'), true);
});

test('javascript responses become unavailable, not live excerpts', async () => {
  const outbound = async () =>
    new Response('function steal(){}', {
      status: 200,
      headers: { 'content-type': 'application/javascript' },
    });
  const res = await handleRequest(
    request({ season: '1448' }),
    { ...env, HAJJ_MOCK_ORIGIN: '', ENVIRONMENT: 'test' },
    outbound,
  );
  const json = await res.json();
  assert.ok(json.sources.every((item) => item.retrievalMode === 'unavailable'));
});

test('origin gets are coalesced and capped independently of installations', async () => {
  let calls = 0;
  const outbound = async (url, init) => {
    calls += 1;
    assert.equal(init.redirect, 'manual');
    return new Response('homepage', {
      status: 200,
      headers: { 'content-type': 'text/html' },
    });
  };
  const tight = {
    ...env,
    HAJJ_MOCK_ORIGIN: '',
    ORIGIN_GETS_GLOBAL_DAILY: '1',
    ORIGIN_GETS_PER_ADAPTER_DAILY: '1',
    BURST_PER_MINUTE: '40',
  };
  const results = await Promise.all([
    handleRequest(request({ season: '1448' }, { 'X-Muhasabah-Install': 'o1' }), tight, outbound),
    handleRequest(request({ season: '1448' }, { 'X-Muhasabah-Install': 'o2' }), tight, outbound),
  ]);
  assert.ok(results.every((item) => item.status === 200));
  assert.equal(calls, 1);
  assert.equal(isolateQuota.originGlobal, 1);
});

test('pilot gate rejects callers without the header', async () => {
  const res = await handleRequest(request({ season: '1448' }), { ...env, PILOT_GATE: 'secret' }, globalThis.fetch);
  assert.equal(res.status, 403);
  const ok = await handleRequest(
    request({ season: '1448' }, { 'X-Muhasabah-Pilot': 'secret' }),
    { ...env, PILOT_GATE: 'secret' },
    globalThis.fetch,
  );
  assert.equal(ok.status, 200);
});

test('staging requires PILOT_GATE and still uses real adapters', async () => {
  const staging = {
    ...env,
    ENVIRONMENT: 'staging',
    HAJJ_MOCK_ORIGIN: 'ok',
    PILOT_GATE: '',
  };
  const health = await handleRequest(
    new Request('https://hajj.local/health'),
    staging,
    globalThis.fetch,
  );
  const healthJson = await health.json();
  assert.equal(healthJson.environment, 'staging');
  assert.equal(healthJson.mockOrigin, false);
  assert.equal(healthJson.gateRequired, true);
  assert.equal(healthJson.pilotGateConfigured, false);

  const unset = await handleRequest(request({ season: '1448' }), staging, globalThis.fetch);
  assert.equal(unset.status, 503);

  const gated = { ...staging, PILOT_GATE: 'staging-gate' };
  const denied = await handleRequest(request({ season: '1448' }), gated, globalThis.fetch);
  assert.equal(denied.status, 403);

  let originCalls = 0;
  const outbound = async (url, init) => {
    originCalls += 1;
    assert.equal(init.redirect, 'manual');
    assert.match(String(url), /haj\.gov\.sa|nusuk\.sa/);
    return new Response('<html>official</html>', {
      status: 200,
      headers: { 'content-type': 'text/html' },
    });
  };
  const allowed = await handleRequest(
    request({ season: '1448' }, { 'X-Muhasabah-Pilot': 'staging-gate' }),
    gated,
    outbound,
  );
  assert.equal(allowed.status, 200);
  assert.ok(originCalls >= 1);
  const json = await allowed.json();
  assert.ok(json.sources.every((item) => item.verificationStatus === 'unverified'));
  assert.ok(json.sources.every((item) => item.origin === 'liveWorker'));
  assert.ok(json.sources.every((item) => item.provenance === 'liveRetrieval'));
  assert.ok(json.sources.every((item) => item.uri.startsWith('https://')));
});
