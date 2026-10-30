import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';

const staging = readFileSync(
  new URL('../wrangler.staging.toml.example', import.meta.url),
  'utf8',
);

test('staging Wrangler example is Free-plan and not mock', () => {
  assert.match(staging, /ENVIRONMENT\s*=\s*"staging"/);
  assert.doesNotMatch(staging, /HAJJ_MOCK_ORIGIN/);
  assert.doesNotMatch(staging, /\[triggers\]/);
  assert.doesNotMatch(staging, /crons\s*=/);
  assert.doesNotMatch(staging, /durable_objects/i);
  assert.doesNotMatch(staging, /r2_buckets/i);
  assert.doesNotMatch(staging, /ai\s*=/i);
  assert.doesNotMatch(staging, /HAJJ_SOURCE_CACHE/);
  assert.match(staging, /INCOMING_LIMITER/);
  assert.match(staging, /ORIGIN_LIMITER/);
  assert.match(staging, /GLOBAL_ACCEPTED_DAILY\s*=\s*"50"/);
  assert.match(staging, /GLOBAL_INCOMING_DAILY\s*=\s*"500"/);
  assert.match(staging, /PILOT_GATE\s*=\s*""/);
  assert.match(staging, /workers_dev\s*=\s*true/);
  assert.match(staging, /name\s*=\s*"muhasabah-hajj-sources-staging"/);
  assert.match(staging, /muhasabah-dev/);
  assert.match(
    staging,
    /muhasabah-hajj-sources-staging\.muhasabah-dev\.workers\.dev/,
  );
  assert.doesNotMatch(staging, /PUT .*workers\/subdomain/);
});
