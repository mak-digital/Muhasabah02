# Owner-only Hajj Worker pilot (Workers Free)

**Do not run these steps until the owner explicitly approves a deploy.**  
This file is a checklist. It does not deploy anything.

The production Flutter app must **keep `HAJJ_LIVE_BASE_URL` unset**. Live lookup stays off in store builds until a later approval.

`PILOT_GATE` is a **convenience barrier** (a shared header). It is not login, not per-user authentication, and not a spending cap.

## 1. Verify the Cloudflare account is Free

Log in at https://dash.cloudflare.com (this development machine is **not** logged in).

1. Open **Workers & Pages** → **Plans** (or Billing → Workers).
2. Confirm **Workers Free** is active and **Workers Paid is off**. Paid is a **USD 5 / month** floor plus usage.
3. Open **Billing** → **Billable Usage**. Confirm there is no Workers Paid, Workers AI, R2, Durable Objects, Queues, or Hyperdrive charge.
4. Open **Notifications**. A **USD 10 budget alert** (if present) is **email only**. It does **not** pause usage or cap invoices.
5. Confirm there is **no hard spending cap** on ordinary Pay-as-you-go accounts.

If any Paid/AI/R2/DO product is on, **stop**. Do not deploy this Worker onto that account.

## 2. Rate Limiting binding on Free

Cloudflare documents the Workers `ratelimits` binding as available **without Workers Paid** (GA, 2025–2026 docs). Limits are **per Cloudflare location**, periods **10 or 60 seconds only**.

This repo’s production template uses:

- `INCOMING_LIMITER` — 40 calls / 60s
- `ORIGIN_LIMITER` — 6 calls / 60s

That is **not** a worldwide daily quota. Daily caps in `[vars]` are isolate memory plus these location windows.

Local `wrangler dev` showed both bindings in **local** mode. After a future deploy, confirm the same two bindings on the Worker’s Settings page.

## 3. Bindings this Worker may use

| Binding / product | Pilot |
| --- | --- |
| Worker script | Yes (Free) |
| `ratelimits` | Yes (Free, per location) |
| KV `HAJJ_SOURCE_CACHE` | Optional page cache only. Skip on the first pilot if unused. |
| Workers AI | **No** |
| R2, Durable Objects, Queues, Cron, Hyperdrive | **No** |

## 4. First deploy shape (only after approval)

1. Copy `backend/hajj-worker/wrangler.toml.example` to a **local** `wrangler.toml` (gitignored).
2. Leave `ENVIRONMENT = "production"`. Do **not** set `HAJJ_MOCK_ORIGIN`.
3. Leave `PILOT_GATE = ""` in git. After deploy, set a long random value in the **dashboard Variables**, not in the repo.
4. `npx wrangler deploy` from `backend/hajj-worker` **only when approved**.
5. Call `GET https://<worker>/health` and confirm `ai: false`, `mockOrigin: false`, `environment: production`.
6. Do **not** add `--dart-define=HAJJ_LIVE_BASE_URL=...` to a Play Store or production APK.

Optional tester APK (separate later approval): HTTPS Worker URL + `--dart-define=HAJJ_LIVE_GATE=<same as dashboard>`.

## 5. Quick disable (if abuse or odd behaviour)

Any one of these stops live assist. Offline Hajj is unchanged.

1. **App (strongest for users):** ship or install a build **without** `HAJJ_LIVE_BASE_URL` (current default).
2. **Gate:** change `PILOT_GATE` in the dashboard to a new unused value. Existing tester APKs get 403.
3. **Unroute / disable** the Worker in Workers & Pages (pause or delete the route).
4. **Do not** turn on Paid to “raise limits.” Fail closed instead.

## 6. Expected pilot load

Owner + at most five testers. Production template: 200 accepted lookups / UTC day, 5 / installation, 8 origin GETs / isolate / day. Testers confirm official pages by hand. HTTP 200 is not verification.
