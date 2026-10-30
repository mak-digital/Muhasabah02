# Hajj Phase 3B-2B — live official-source retrieval (local only)

**Status:** Local implementation and tests. **Not deployed. Not committed.**  
**AI:** disabled (USD 0). **Bookings / payments / provider directory / eligibility:** none.  
**Schema:** `schemaVersion` 1, additive source fields only.

## Architecture

Flutter stays offline-first. Default gateway remains `DemoHajjOnlineAssistGateway`.

A live Worker URL is opt-in via `--dart-define=HAJJ_LIVE_BASE_URL=...`. Empty (this build) means demonstration only.

```
Consent + user tap
  → on-device pathway match (country codes only)
  → POST /v1/hajj/sources  {season, country codes, pathwayIds}
  → Worker allowlist + adapter GET
  → unverified provenance records
  → person reviews; milestones unchanged
```

Dart twin (tested): `lib/domain/hajj_source_worker.dart`  
Cloudflare port (not executed here; Node/Wrangler absent): `backend/hajj-worker/`

## Adapter inventory (verified 2026-10-18)

| Adapter | Domain / URL | Access check | Retrieval |
| --- | --- | --- | --- |
| Ministry of Hajj and Umrah | `https://www.haj.gov.sa/` | robots.txt allows `/`, disallows `/api/` and login | GET homepage only. Session fetch **timed out** → treat timeout as **manual verification** |
| Nusuk | `https://www.nusuk.sa/` | robots.txt `Allow: /` | Public homepage GET succeeded. No login bypass. Excerpt is not verification |
| UK FCDO pilgrimage (pilot) | `https://www.gov.uk/foreign-travel-advice/saudi-arabia/pilgrimage` | Public travel advice | `gov.uk/perform-hajj-umrah` is **404**. Pilot URL updated. GET of pilgrimage page succeeded. Not a Saudi ruling |

Client-supplied URLs are rejected. Paths containing `/api/` or `login` are rejected.

## Authenticity and freshness

- Authenticity: official-portal bookmark only.
- Freshness: KV/memory cache 24 hours; UI may still show Outdated after 180 days via existing helper.
- Applicability: possibly relevant from country codes. Never eligibility.
- Verification status from the Worker is always **unverified**.
- HTTP 401/403/429 → **Source requires manual verification**.
- Other failures → **Source unavailable**.
- Differing excerpts → unresolved conflict list.

## Cost and deploy (do not run yet)

Authoritative note: [CLOUDFLARE_COST_CONTROL.md](CLOUDFLARE_COST_CONTROL.md).

- Target **Workers Free** only. Do not enable Workers Paid, AI, R2, or Cron.
- Cloudflare has **no enforceable hard USD spending cap** on ordinary accounts. A USD 10 budget alert is informational only.
- App quotas: 5 lookups / user / UTC day, **800** global / UTC day (KV write headroom under 1,000).
- No client retries or background polling. Origin GET timeout 8 s; stale cache on failure.
- Offline Hajj is unchanged if the Worker is down or quotas are exhausted.
- Owner approval is still required before `wrangler deploy`, billing changes, commit, or push.
- Pilot readiness (redirects, origin caps, config split): [PHASE_3B2D.md](PHASE_3B2D.md).

Local validation (18 Oct 2026): Node 22.20.0 portable + project Wrangler 4.151.1; `wrangler dev --local` on 127.0.0.1:8787; JS tests 12/12; wrangler HTTP concurrency (5/20 exact per installation); Flutter HTTP client against that server. **No production deploy.** KV is not used as a quota. Isolate-memory quotas are hard locally, not a worldwide authenticated-user cap. See [CLOUDFLARE_COST_CONTROL.md](CLOUDFLARE_COST_CONTROL.md).

## Emulator

Reuse emulator-5554. Live URL unset → Offline / Demo banners. Lookup still demonstration. AI remains a separate switch; live gateway refuses AI.

## Git

Hajj-only inventory is in the 3B-2B completion report. Fasting overflow files were not modified. No commit.
