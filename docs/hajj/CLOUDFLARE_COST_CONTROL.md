# Hajj Worker — Cloudflare Free-plan cost control

**Status:** designed and tested locally. **Not deployed. Billing not activated. Not committed.**  
**Checked:** Cloudflare Workers pricing and limits docs, 18 October 2026.

This Worker is specified for the **Workers Free** plan as the first (and currently only) deployment target.

## Do not enable without a later written approval

- Workers Paid (USD 5 / month minimum, then usage overages)
- Workers AI / any AI binding
- R2, Durable Objects, Queues, Cron Triggers, Hyperdrive
- Custom domains that require a paid Cloudflare zone add-on (if that applies to the account)
- Automatic background polling, cron refresh, or client retry loops

## Financial exposure

| Control | What it actually does | Liability if ignored |
| --- | --- | --- |
| Stay on **Workers Free**; never switch to Paid | Usage over Free limits **fails** (Worker error 1027, KV operation error). It does **not** start a bill by itself. | **USD 0** for Workers + KV operations, provided no other billable products are on. |
| Default **USD 10 budget alert** (Pay-as-you-go accounts) | Email only. Cloudflare states it is **informational**. It does **not** pause usage or cap invoices. It is processed on **prior-day** usage, so it is not real-time. Recurring plan fees (including Workers Paid’s USD 5) are **not** counted in the alert. | **Does not limit financial liability.** |
| Account-wide **hard spending cap** | **Not provided** on ordinary Pay-as-you-go accounts (docs and Cloudflare’s own notes, 2026). | There is no dashboard switch that stops charges once Paid or other usage products are on. |
| Per-Worker CPU limit | Caps CPU **per request**, not monthly dollars. | Cannot replace a spending cap. |

**Practical USD 0 control:** remain on Workers Free, bind only KV, ship no Cron/AI/R2, and keep the app quotas below Free KV writes.

A USD 10 alert must not be treated as a budget.

If Workers Paid were turned on by mistake, the floor is **USD 5 / month** plus unbounded overages (Workers USD 0.30 / million requests after 10 million; KV writes USD 5 / million after 1 million). Without this Worker’s quotas, a retry or polling bug could run that up. **Do not enable Paid.**

KV stored data on Free is **1 GB**. This design stores a few 8 KB public excerpts. Stay far below 1 GB so storage never becomes a billing question.

## Free-plan resource ceilings (account, UTC midnight reset)

From [Workers limits](https://developers.cloudflare.com/workers/platform/limits/) and [Workers pricing](https://developers.cloudflare.com/workers/platform/pricing/):

| Resource | Free ceiling | If exceeded |
| --- | --- | --- |
| Worker requests | 100,000 / day (all Workers on the account) | Error **1027**. Live lookup fails. App stays on on-device Hajj. |
| CPU per request | 10 ms (network wait excluded) | Isolate may be terminated. Adapter uses `contains()` on an 8 KB excerpt — no HTML DOM parse. |
| KV reads | 100,000 / day | Further reads fail. |
| KV writes / deletes / lists | **1,000 / day** | Further writes fail. **This is the binding constraint.** |
| Same KV key writes | **1 / second** | Extra writes to `quota:YYYY-MM-DD` can fail under burst traffic. |
| KV storage | 1 GB | Stay well under. |
| Subrequests | 50 / request | Pilot uses at most 3 origin GETs. |
| Cron | Available on Free, unused | Must remain unused. |

## Application quotas (configured)

Defaults in `HajjWorkerQuotaConfig.freePlanDefaults` / Worker `[vars]`:

| Quota | Default | Guarantee |
| --- | --- | --- |
| Per-**installation** daily accepted POSTs | **5** | Hard **on one Worker isolate** and on that phone process. **Not** an authenticated user. The header `X-Muhasabah-Install` is spoofable. |
| Global accepted POSTs / UTC day | **800** | Hard on **one isolate** (local `wrangler dev`). **Not** a worldwide hard cap: production Free can run many isolates. |
| Global **incoming** POSTs / UTC day (including 400/404) | **20,000** | Same isolate-memory caveat. Cloudflare’s own **100,000 requests/day** is the account-wide hard refusal. |
| Burst / minute | **5** (Worker vars may be higher in local mock) | Isolate memory. |
| Public cache TTL | **24 h** | Memory first; KV optional and **cache-only**. |
| Origin timeout | **8 s** | One attempt; then stale cache or manual link. |
| Body cap | **8 KB** | Keeps CPU small. |

**KV is not a quota limiter.** A shared KV key with read-modify-write is not atomic, and Free KV allows only **one write per key per second**. Concurrent tests lose counts under that pattern. Quotas are isolate memory.

Rejected requests **do** count as incoming Worker requests (and against Cloudflare’s 100k/day). They do **not** count as accepted lookups and do **not** write quota keys.

Consent is enforced **on the phone**. The Worker rejects consent fields as unknown; it cannot prove the person toggled lookup consent.

## What happens when a limit is hit

| Event | Worker / Cloudflare | App |
| --- | --- | --- |
| Personal daily quota | HTTP 429, public message, no origin fetch | Snackbar. Hajj store, standing, milestones **unchanged**. Official URLs remain tappable by hand. |
| Shared daily quota (800) | HTTP 429 | Same. Other people wait until **00:00 UTC**. |
| Burst / minute | HTTP 429 (Dart; JS relies on 1 write/s + daily cap) | Same. |
| Free Worker 100k requests | Cloudflare **1027** | Treated as unavailable. Offline Hajj continues. |
| Free KV write cap | KV put fails | Request fails closed; live lookup unavailable. Offline Hajj continues. |
| Origin timeout / 5xx / network | **One** GET, no retry | Serve **stale** 24h+ cache if present (`freshnessStatus: stale`); else manual-link / unavailable. |
| Origin 401 / 403 / 429 | No retry | Manual verification bookmark. |
| Worker process down / URL unset | No live POST | Default demo/offline gateway. `--dart-define=HAJJ_LIVE_BASE_URL` empty in this build. |
| Live HTTP client | `maxAttempts = 1`, 8 s connect, 10 s total | No automatic retry, no polling. |

HTTP 200 from an official host is still **not** verification. `aiConsented` does not call AI.

## Client and Worker anti-runaway rules

- Lookup runs only after consent **and** a user tap.
- No timers, isolates, or Cron that refresh sources.
- `hajjLiveHttpPost` refuses `maxAttempts != 1`.
- Live gateway does **not** fall back to demo records and pretend they are live.
- No `waitUntil` background work after the response.

## Operating-cost estimate (monthly)

Assumptions:

- Figures are **Hajj live-lookup users**, not all Muhasabah installs.
- Each successful live tap = 1 Worker request + 1 KV write (quota) + 1 KV read; origin GETs only on cache miss (≤ 3 / tap, then 24 h cache).
- **Recommended deploy stays on Free** with `GLOBAL_DAILY_QUOTA=800`.
- “Lookups/user/month” below is a planning intensity, not a product target.

### Recommended configuration (Free + quotas) — bill **USD 0**

Daily success cap ≈ 800 lookups. Monthly Worker requests ≈ 24,000. Monthly KV writes ≈ 24,000 + a few cache puts. All are under Free ceilings.

| MAU (Hajj live users) | If each person taps live once / month | If each person taps live once / day | What the user sees | Bill |
| --- | --- | --- | --- | --- |
| 100 | 100 requests — well under cap | 3,000 requests — still under 800/day only if not all tap the same day; worst day 100 ≪ 800 | Live usually works | **USD 0** |
| 1,000 | 1,000 / month — under cap | Up to 1,000/day; **~200** taps that day get 429 after 800 | Some people wait until next UTC day or open official sites by hand | **USD 0** |
| 10,000 | 10,000 / month — under cap if spread; a campaign day still stops at 800 | Vast majority 429 after 800/day | Live is a scarce assist; **offline Hajj is the product** | **USD 0** |
| 100,000 | Same 800/day ceiling | Same | Same | **USD 0** |

At 10k and 100k MAU, Free does **not** give every active user a daily live lookup. That is acceptable: Hajj planning remains local.

### If Workers Paid were enabled (do not) — floor USD 5 / month

Included: 10 million Worker requests / month, 1 million KV writes / month, then overage.

| MAU | 1 live tap / user / month | 1 live tap / user / day, **no app quota** | With app quota 800/day |
| --- | --- | --- | --- |
| 100 | ~USD 5 floor | ~USD 5 floor | ~USD 5 floor |
| 1,000 | ~USD 5 | ~USD 5 | ~USD 5 |
| 10,000 | ~USD 5 | ~300k requests + 300k KV writes ≈ USD 5 | ~USD 5 |
| 100,000 | ~USD 5 | **~3 million requests/day** ≈ 90 million/month: ~USD 5 + ~USD 24 request overage + **~USD 445 KV write overage** ≈ **USD 470+** | Still ~USD 5 if quotas stay |

The 100,000 MAU / daily-tap / no-quota column is why Paid + polling is rejected.

## Recommended deployment configuration (approval still required)

1. Cloudflare account remains on **Workers Free**. Confirm Workers Paid is **off**.
2. Create **one** KV namespace `HAJJ_SOURCE_CACHE`. Do not create R2.
3. Copy `backend/hajj-worker/wrangler.toml.example` → `wrangler.toml`. Keep `GLOBAL_DAILY_QUOTA=800`, `PER_USER_DAILY_QUOTA=5`, no `[triggers]`.
4. Deploy **only** after explicit owner approval. First run: `wrangler dev`, not production.
5. App production builds keep `HAJJ_LIVE_BASE_URL` empty until a later approval.
6. Optional: add an email **budget alert** for awareness only; it is not a cap.
7. After deploy, watch Workers + KV usage in the dashboard for a few days. If KV writes approach 1,000, lower `GLOBAL_DAILY_QUOTA` (for example 600).

## Owner approval checklist (not yet requested to execute)

- [ ] Confirm the Cloudflare account is Free and that the operator will not click Workers Paid / AI.
- [ ] Accept that there is **no hard USD spending cap**.
- [ ] Accept 800 successful live lookups / UTC day on Free.
- [ ] Accept Node/Wrangler must be installed on a machine before any deploy.
- [ ] Separate later approval for production hostname and `--dart-define=HAJJ_LIVE_BASE_URL`.

## Code map

- Limits and copy: `lib/domain/hajj_worker_limits.dart`
- Dart Worker twin (tested): `lib/domain/hajj_source_worker.dart`
- JS port: `backend/hajj-worker/src/worker.js`
- Single-attempt HTTP: `lib/data/hajj_live_http.dart`
