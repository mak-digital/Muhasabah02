# Hajj Phase 3B-2F Stage 1 — local hostname lock (Worker not deployed)

**Status:** local configuration only. **Not deployed. Zero Trust not activated in this step. Not pushed.**  
**Date:** 18 October 2026  
**Git:** `step-4a-ontology-rationalisation` @ `2691b536bc9540573cdc2b6aab20ff202a0a9f32`

## Account hostname (owner-confirmed)

| Item | Value |
| --- | --- |
| Account `workers.dev` subdomain | `muhasabah-dev` |
| Do not | Register, rename, or PUT this subdomain via API |
| Staging Worker name | `muhasabah-hajj-sources-staging` |
| Intended staging URL | `https://muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev` |
| This URL today | **Does not exist** until a separately approved deploy |

Reuse `muhasabah-dev` for all future staging configurations.

## Still true from earlier Stage 1 checks

- Wrangler was authenticated with limited scopes (no `ai:write`).
- Owner email for a later Access allow policy: `maka2z.pmc@gmail.com`
- Access / Zero Trust: **not enabled** on last API check; this step does **not** enable it.
- Cloudflare user MFA: **off** on last API check; still recommended before any deploy.
- No Worker script has been deployed from this repo in this phase.

A later Wrangler token `401` is not treated as a reason to recreate the subdomain. The dashboard confirmation of `muhasabah-dev.workers.dev` is authoritative.

## Stage 2 order (corrected — do not run)

1. MFA on.
2. Enable Zero Trust **Free** Access **before** deploy (All traffic, owner email + service token, **no bypass**).
3. Then `npx wrangler deploy --config wrangler.staging.toml`.
4. Then `npx wrangler secret put PILOT_GATE` (POST is already 503 until the secret exists; `/health` is only private if Access was already on).

If Access is not on, **do not deploy**. See `STAGING_DEPLOYMENT_RUNBOOK.md` §0.

## Local-only remainder of this step

- Update staging Wrangler example and dart-define example to the confirmed hostname.
- Keep Fasting overflow files unstaged.
- Run local Worker/Flutter tests.
- Do not `wrangler deploy`, enable Access, activate Paid, push, or merge.
