# Staging cost and shutdown (Workers Free)

USD 10 budget **alerts** are email only. They are **not** a spending cap. There is no ordinary Pay-as-you-go hard cap. Stay on Workers Free and Zero Trust Free.

## Expected volume (one owner)

Planning numbers, not a product target:

- A few health GETs while configuring Access
- One authorised lookup during first check (2 origin GETs if cache is cold: ministry + Nusuk; UK adapter only if GB is in the payload)
- Occasional extra taps the same day, capped at **3 accepted / install** and **50 accepted / isolate**

That is far below Free ceilings if Paid products stay off.

## Free-plan limits that apply

| Resource | Free ceiling | Staging relevance |
| --- | --- | --- |
| Worker requests | 100,000 / UTC day (account) | Hard stop: Error **1027**. Includes junk if it reaches the Worker. |
| CPU | 10 ms / request (network wait excluded) | Adapter uses short string checks on ≤8 KB |
| KV | 100k reads / 1k writes / day | **Not bound** on staging |
| Rate-limit binding | Per **location**, 10s or 60s windows | 20 incoming / 60s, 6 origin / 60s |
| Isolate accepted | 50 / UTC day (config) | Not a worldwide hard quota |
| Isolate incoming | 500 / UTC day (config) | Not worldwide |
| Origin GETs | 2 / adapter, 8 / isolate / day | Protects official sites; not worldwide |
| Cron | Unused | Must remain unused |
| Zero Trust Free | 50 users, USD 0 | Owner + service token only |

## When a limit is reached

| Event | What happens | App |
| --- | --- | --- |
| Access deny | Login page / 403 at the edge | Lookup unavailable; offline Hajj unchanged |
| Wrong / missing `PILOT_GATE` | 403 / 503 | Same |
| Isolate or location limit | 429 | Same |
| Account 100k requests | Error 1027 | Same |
| Origin down / timeout | One attempt; stale or manual link | Same |
| Workers Paid accidentally enabled | **USD 5 / month floor plus usage** | Stop and revert the plan; do not keep Paid |

Isolate counters **do not** guarantee a worldwide 50 lookups/day.

## KV

**Not required** for staging. First staging deploy should omit `HAJJ_SOURCE_CACHE`. Memory cache is enough for one owner. Binding KV would consume the 1,000 write/day Free budget if used carelessly.

## How to inspect usage

1. dash.cloudflare.com → Workers & Pages → `muhasabah-hajj-sources-staging` → Metrics (requests, errors, CPU).
2. Account **Billing → Billable Usage**: must stay empty of Workers Paid / AI / R2 / DO.
3. Zero Trust → Logs (short retention on Free).
4. Do not enable Workers Logpush or paid analytics.

## How to stop staging traffic

Fastest first:

1. Revoke the Access service token.
2. Rotate `PILOT_GATE`.
3. Set Access to All traffic with no bypass (if someone opened a bypass, close it).
4. Disable the `workers.dev` route.
5. Run a Flutter build without dart-defines.

## How to remove the Worker completely

Only after owner approval:

```
cd backend/hajj-worker
npx wrangler delete --config wrangler.staging.toml
```

Then delete the Access application, revoke tokens, delete local gitignored config files, and re-check Billing.

Do not delete unrelated Workers or change the production Flutter live URL (it must remain empty).
