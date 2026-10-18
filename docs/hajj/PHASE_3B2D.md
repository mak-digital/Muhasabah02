# Hajj Phase 3B-2D — Free-plan pilot readiness (not deployed)

**Status:** local implementation and tests. **Not deployed. Billing not activated. Not committed.**  
**Checked:** Cloudflare Workers pricing, limits, and Rate Limiting binding docs, 18 October 2026.

## 1. Abuse prevention

| Control | What it does | What it does **not** do |
| --- | --- | --- |
| Client URLs rejected | `url` / `uri` / `href` are forbidden fields. Only built-in adapter URLs are fetched. | — |
| Redirects `manual` + allowlist | Location host must be in `{haj.gov.sa, nusuk.sa, gov.uk}` (with `www`). Max 2 hops. HTTPS only. `/api/` and `login` blocked. | Cannot stop an official site from later adding an allowlisted third-party host. |
| Cache 24h + coalescing | Many lookups share one in-flight origin GET per adapter. | Cold-start thundering herd across **many Cloudflare locations**. |
| Origin caps | Default **2 GETs / adapter / UTC day** and **8 origin GETs / isolate / day**, independent of how many Flutter installs call the Worker. | Not a worldwide hard cap (isolate memory). |
| Workers `ratelimits` binding | Free-plan compatible. `ORIGIN_LIMITER` 6/60s and `INCOMING_LIMITER` 40/60s **per Cloudflare location**. | Periods are only 10s or 60s. **Not a daily global quota.** |
| Isolate incoming/accepted quotas | Hard on one isolate / local wrangler. | Not global; not authenticated users. |
| KV | Optional **page cache only**. | Not used as an atomic quota (RMW is unsafe; 1 write/key/s). |
| Durable Objects | — | **Not used** (Workers Paid). |

Official websites: worst local case is a handful of homepage GETs per isolate per day after cache/coalesce/origin caps. Production locations may each try a refresh when KV cache is cold.

## 2. Source integrity

- Stored `uri` is the **adapter official URL**, not a client URL and not an off-list redirect.
- `retrievedAt` is the UTC date; `applicableSeason` is echoed from the request.
- `verificationStatus` is always **unverified**. HTTP 200 is not a ruling.
- Content-Type must be HTML / XHTML / XML / plain text. JavaScript / wasm / octet-stream → unavailable.
- Body capped at 8 KB; `<script>` / `<style>` stripped before excerpts.
- Raw HTML is not shown as requirement text; excerpts stay generic bookmarks.

## 3. Production configuration

| File | Role |
| --- | --- |
| `wrangler.toml.example` | Production shape. `ENVIRONMENT=production`. **No** `HAJJ_MOCK_ORIGIN`. |
| `wrangler.staging.toml.example` | Tighter quotas. Mock ignored. |
| `wrangler.local.toml.example` | Local only. `ENVIRONMENT=local` + `HAJJ_MOCK_ORIGIN=ok`. |

`HAJJ_MOCK_ORIGIN=ok` is honoured **only** when `ENVIRONMENT` is `local` or `test`. A production copy that accidentally sets the mock flag still hits real allowlisted origins (or fails closed).

Flutter: HTTPS required except `127.0.0.1` / `localhost` / `::1` / `10.0.2.2` (emulator host loopback).  
Optional `--dart-define=HAJJ_LIVE_GATE=...` maps to `X-Muhasabah-Pilot` when `PILOT_GATE` is set on the Worker (dashboard secret, not git).

Payload: season, country codes, pathway ids only. No names, passports, reflections, or API keys in the APK for origin fetch.

Public `workers.dev` is crawlable. For a pilot, set `PILOT_GATE` in the dashboard and the matching dart-define. This is **not** strong authentication; it stops casual scanners. Cloudflare Access / Turnstile can be considered later (Turnstile has a free tier; Access is a separate product).

## 4. Cloudflare Free-plan validation

This machine **cannot see the owner’s Cloudflare dashboard**. Before any deploy, the owner (or an approved login) must confirm:

- Workers plan = **Free** (Workers Paid off)
- No Workers AI, R2, Queues, Durable Objects, Cron, or Hyperdrive on this Worker
- Bindings: this Worker needs **none** to start; optional KV cache; optional Free `ratelimits` bindings (no extra fee documented)
- Budget alert ≠ spending cap

Terms checked 18 Oct 2026: 100,000 Worker requests/day (Error **1027**); 10 ms CPU; KV 100k reads / **1k writes**/day if KV is bound. Over-limit operations **fail**, they do not bill, while the account stays Free.

## 5. Pilot operating procedure

**Initial users:** owner + at most **5** invited testers.  
**Lookups:** production template **200 accepted / UTC day**, **5 / installation**, **8 origin GETs / isolate / day**. Expected tester load: a few taps per person per week.

**Monitoring:** Cloudflare Workers metrics (requests, errors, CPU, KV). No logs of payload bodies. App shows snackbars; Hajj store unchanged on 429/403/failure.

**Freshness:** 24 h cache; UI can still mark sources outdated after 180 days via existing helper. Testers confirm on the official page.

**Fallback:** timeout, 401/403/429 origin, redirect off-list, origin cap → **manual link**. Offline Hajj always works if `HAJJ_LIVE_BASE_URL` is empty or the Worker is down.

**Emergency disable:**

1. Remove `HAJJ_LIVE_BASE_URL` from the next app build, **or**
2. Set `PILOT_GATE` to a new unused value, **or**
3. Unroute / disable the Worker in the dashboard (no Paid needed).

**Rollback:** keep the previous Worker version; app default remains demo/offline. Hajj schema stays version 1; local records untouched.

**Expand the pilot only if:** Error 1027 never hits; origin GETs stay tiny; no private data in logs; testers still treat bookmarks as unverified; Free plan still on.

## 6. Verification (this session)

See the completion report in chat. No `wrangler deploy`. No commit/push.
