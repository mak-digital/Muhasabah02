import assert from 'node:assert/strict';
import { test } from 'node:test';

const base = process.env.HAJJ_WORKER_URL || 'http://127.0.0.1:8787';

async function workerUp() {
  for (let attempt = 0; attempt < 10; attempt += 1) {
    try {
      const res = await fetch(`${base}/health`, {
        signal: AbortSignal.timeout(2000),
      });
      if (res.ok) return true;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 500));
    }
  }
  return false;
}

test('wrangler health, allowlist, cache, burst, incoming', async (t) => {
  if (!(await workerUp())) {
    t.skip('wrangler dev is not running');
    return;
  }
  const health = await fetch(`${base}/health`);
  const healthJson = await health.json();
  assert.equal(healthJson.ai, false);
  assert.equal(healthJson.authenticatedUsers, false);

  const bad = await fetch(`${base}/v1/hajj/sources`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ url: 'https://evil.example' }),
  });
  assert.equal(bad.status, 400);

  const missing = await fetch(`${base}/nope`);
  assert.equal(missing.status, 404);

  const first = await fetch(`${base}/v1/hajj/sources`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'X-Muhasabah-Install': 'wrangler-a',
    },
    body: JSON.stringify({ season: '1448' }),
  });
  assert.equal(first.status, 200);
  const firstJson = await first.json();
  assert.match(String(firstJson.quota.guarantee), /location-ratelimit|isolate-memory/);
  assert.ok(firstJson.sources.every((item) => item.verificationStatus === 'unverified'));
  assert.ok(firstJson.sources.every((item) => item.origin === 'liveWorker'));
  assert.ok(firstJson.sources.every((item) => item.provenance === 'liveRetrieval'));

  const second = await fetch(`${base}/v1/hajj/sources`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'X-Muhasabah-Install': 'wrangler-a',
    },
    body: JSON.stringify({ season: '1448' }),
  });
  assert.equal(second.status, 200);

  const burst = await Promise.all(
    Array.from({ length: 20 }, () =>
      fetch(`${base}/v1/hajj/sources`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'X-Muhasabah-Install': 'cap-test-install',
        },
        body: JSON.stringify({ season: '1448' }),
      }),
    ),
  );
  const ok = burst.filter((item) => item.status === 200).length;
  const limited = burst.filter((item) => item.status === 429).length;
  assert.equal(ok, 5);
  assert.equal(limited, 15);

  const junk = await Promise.all(
    Array.from({ length: 10 }, () =>
      fetch(`${base}/v1/hajj/sources`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ url: 'https://evil.example' }),
      }),
    ),
  );
  assert.ok(junk.every((item) => item.status === 400));
});
