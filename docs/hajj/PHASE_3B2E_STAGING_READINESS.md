# Hajj Phase 3B-2E — Staging readiness (not deployed)

**Status:** local preparation and tests. **Not deployed. Not authenticated to Cloudflare. Not pushed.**  
**Baseline:** commit `2691b536bc9540573cdc2b6aab20ff202a0a9f32` on `step-4a-ontology-rationalisation`.  
**Checked:** Cloudflare Access for Workers and Zero Trust Free plan pages, 18 October 2026.

This phase prepares an **owner-only staging Worker** on **Workers Free**. It does not authorise `wrangler login`, `wrangler deploy`, a production live URL, or APK distribution.

## Decision

`PILOT_GATE` alone is **not** owner-only access. It is a shared header. Anyone who extracts it from a debug APK, a screenshot, or a log can call the Worker.

The simplest Free-plan control that can actually keep casual public use off the Worker is:

**Cloudflare Access (Zero Trust Free, 50 users) protecting `https://muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev` (All traffic), plus a dashboard `PILOT_GATE` secret as a second check.** Access must be enabled **before** any deploy. The account subdomain is `muhasabah-dev` and must not be renamed.

Until Access is on, the staging hostname must **not** be described as private.

## Staging Worker shape

File: `backend/hajj-worker/wrangler.staging.toml.example`

| Setting | Value |
| --- | --- |
| Worker name | `muhasabah-hajj-sources-staging` |
| `ENVIRONMENT` | `staging` |
| Mock origin | **Off.** `HAJJ_MOCK_ORIGIN` is ignored unless `ENVIRONMENT` is `local` or `test`. |
| Paid products | None. No KV, Cron, AI, R2, Durable Objects. |
| Rate limits | `INCOMING_LIMITER` 20/60s, `ORIGIN_LIMITER` 6/60s per Cloudflare location |
| Accepted lookups | 50 / isolate / UTC day |
| Incoming POSTs | 500 / isolate / UTC day (includes 400/403) |
| Per-install | 3 accepted / UTC day |
| Origin GETs | 2 / adapter / day, 8 / isolate / day |
| `PILOT_GATE` in git | empty. Staging POSTs return **503** until a dashboard secret is set. |
| Preview URLs | `preview_urls = false` |
| Flutter production | `HAJJ_LIVE_BASE_URL` remains unset |

Local `wrangler.toml` stays gitignored and **mock-enabled** for tests. Do not run `wrangler dev` against the staging example during preparation: that would perform real official-site GETs.

## Flutter staging client

- Production and Play Store builds keep live lookup **off**.
- Owner-only local run uses gitignored `tool/hajj_staging.defines.json` copied from `tool/hajj_staging.defines.json.example`.
- Consent still lives on the phone. The Worker rejects names, passports, health notes, reflections, and consent fields.
- Worker failure leaves Hajj standing, milestones, and deadlines unchanged.
- AI stays disabled.

Do not install a staging APK on other phones in this phase.

## Local verification (this session)

See the completion report. Tests use synthetic data and the **local mock** Worker. Official government sites were not polled in a loop.

## What still requires owner approval

1. Cloudflare account MFA  
2. Enabling Zero Trust **Free** Access **before** any deploy (no bypass)  
3. `npx wrangler deploy --config wrangler.staging.toml`  
4. Binding `PILOT_GATE` and creating an Access service token  
5. Any Flutter run that points at `muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev`  
6. Push, merge, paid products, production `HAJJ_LIVE_BASE_URL`

Do not rename the account subdomain `muhasabah-dev`.

Companion files: `STAGING_DEPLOYMENT_RUNBOOK.md`, `STAGING_SECURITY_CHECKLIST.md`, `STAGING_COST_AND_SHUTDOWN.md`.
