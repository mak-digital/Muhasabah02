# Staging deployment runbook (do not execute yet)

**Do not run remote commands until the owner explicitly approves Stage 2 deploy.**  
This file is an ordered checklist. Commands are documented, not executed.

Offline Hajj continues if any step is skipped or fails.

**Hard rule:** Cloudflare Access must already protect this Worker (or all Workers) **before** `wrangler deploy`. Deploying first would publish `https://muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev` on the public internet until Access and `PILOT_GATE` exist. Do not create that window.

Account `workers.dev` subdomain is **`muhasabah-dev`**. Do not register or rename it.

## 0. Preconditions (Stage 1 — must already be true)

If any item is false, **stop**. Do not deploy.

1. Cloudflare account MFA is on.
2. Workers plan is **Free**. Workers Paid, AI, R2, Durable Objects, Queues, Hyperdrive are **off**.
3. Zero Trust is **Free** (50 users). Do not choose Pay-as-you-go.
4. Access is enabled with **All traffic** for this Worker or for all Workers.
5. Allow policy: owner email only (`maka2z.pmc@gmail.com`) **and** the staging service token.
6. **No** Bypass policy (especially not Everyone).
7. Session duration is short (30 minutes).
8. Account subdomain remains `muhasabah-dev` (Workers & Pages → Your subdomain).
9. Production Flutter has **no** `HAJJ_LIVE_BASE_URL`.
10. `wrangler.staging.toml.example` still has `ENVIRONMENT = "staging"`, no `HAJJ_MOCK_ORIGIN`, no `[triggers]`, no KV.

`PILOT_GATE` cannot be set until the Worker exists (`wrangler secret put` requires a deployed script). Staging POSTs already return **503** while the secret is empty. `/health` is not gated by `PILOT_GATE`, which is why **Access must be on first**.

## 1. Staging environment file

```
cd backend/hajj-worker
copy wrangler.staging.toml.example wrangler.staging.toml
```

Do **not** copy `wrangler.local.toml.example` for deploy. That file enables mock origin.

## 2. Proposed deployment command (do not run)

```
npx wrangler deploy --config wrangler.staging.toml
```

No Paid flag. No KV. Expected hostname:

`https://muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev`

## 3. Set PILOT_GATE immediately after deploy

Create a long random value in the password manager. Never commit it.

```
npx wrangler secret put PILOT_GATE --config wrangler.staging.toml
```

Wrangler will prompt. Do not put the value on the command line.

Confirm Settings → Variables: `ENVIRONMENT=staging`, `PILOT_GATE` encrypted, `HAJJ_MOCK_ORIGIN` absent. Rate-limit bindings present. No KV.

## 4. Prove Access is already enforcing

Unauthenticated (no cookies, no service token):

```
curl -sS -o NUL -w "%{http_code}" https://muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev/health
```

Expect Cloudflare Access login/403, **not** Worker JSON. If this returns `{"ok":true,...}`, **unroute or delete the Worker immediately** — Access was not in front.

## 5. Initial authorised health check

Browser, after Access login as the owner:

```
GET https://muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev/health
```

Expect JSON: `ok: true`, `ai: false`, `environment: staging`, `mockOrigin: false`, `gateRequired: true`, `pilotGateConfigured: true`.

## 6. One authorised source lookup

After Access service token + `PILOT_GATE` are in the **shell environment** (not Git):

```
curl -sS -X POST "https://muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev/v1/hajj/sources" -H "content-type: application/json" -H "CF-Access-Client-Id: $HAJJ_ACCESS_CLIENT_ID" -H "CF-Access-Client-Secret: $HAJJ_ACCESS_CLIENT_SECRET" -H "X-Muhasabah-Pilot: $PILOT_GATE" -H "X-Muhasabah-Install: owner-staging" --data "{\"season\":\"1448\"}"
```

Expect HTTP 200, `verificationStatus: unverified`. Confirm official pages by hand. HTTP 200 is not a ruling. Do this **once**.

## 7. One unauthorised request test

```
curl -sS -o NUL -w "%{http_code}" -X POST "https://muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev/v1/hajj/sources" -H "content-type: application/json" --data "{\"season\":\"1448\"}"
```

Expect Access block (not 200). A call with Access headers but a **wrong** `X-Muhasabah-Pilot` should return Worker **403**.

## 8. Flutter staging-device connection

Copy `tool/hajj_staging.defines.json.example` to gitignored `tool/hajj_staging.defines.json` and fill secrets **locally**.

```
flutter run --dart-define-from-file=tool/hajj_staging.defines.json
```

Do not distribute that APK. Do not add the file to Git.

## 9. Consent and offline fallback

1. Lookup consent **off** → no POST.
2. Consent **on** → one tap may call the Worker.
3. Worker down → Hajj plan, standing, milestones unchanged.
4. Payload is season/country/pathway ids only.

## 10. Metrics

Workers & Pages → this Worker → Metrics. Zero Trust logs (short retention on Free). Do not log POST bodies.

## 11. Emergency disable

1. Keep Access All traffic; never add a Bypass.
2. Rotate `PILOT_GATE`.
3. Revoke the Access service token.
4. Disable the `workers.dev` route or delete the Worker. Do **not** rename `muhasabah-dev`.
5. Flutter build without dart-defines.

Do **not** enable Paid to raise limits.

## 12. Pilot closure

1. Revoke service tokens.
2. Remove Access for this Worker only if no other Worker needs it.
3. `npx wrangler delete --config wrangler.staging.toml` (only when approved).
4. Delete local gitignored config files.
5. Leave the account subdomain `muhasabah-dev` unless the owner later asks to change it.
6. Confirm billing still shows Workers Free and no Zero Trust paid plan.
