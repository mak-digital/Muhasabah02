# Hajj official-source Worker

Local implementation of the Phase 3B-2B retrieval service. **Not deployed.**

Authoritative behaviour and tests: `lib/domain/hajj_source_worker.dart` and `test/domain/hajj_source_worker_test.dart`.  
This folder is the Cloudflare port (`src/worker.js` + `wrangler.toml.example`).

Quotas are **isolate memory** (hard on local `wrangler dev`). They are not authenticated per-user limits and are not a worldwide KV hard cap. See `docs/hajj/CLOUDFLARE_COST_CONTROL.md`.

Local validation uses portable Node 22 LTS and project-local Wrangler:

```
cd backend/hajj-worker
npm install
npm test
copy wrangler.local.toml.example wrangler.toml
npx wrangler dev --local --ip 127.0.0.1 --port 8787
```

Then `flutter test test/data/hajj_worker_http_integration_test.dart`. Stop wrangler when finished. Do not `wrangler deploy`.

## Do not

- Deploy, buy a domain, or enable Workers Paid, AI, R2, Cron, or other billable Cloudflare products without owner approval.
- Treat a USD 10 budget **alert** as a spending cap — it is email-only and does not stop usage.
- Fetch URLs supplied by the mobile client.
- Call AI providers (budget USD 0).
- Log request bodies, names, or reflections.
- Add retries, polling, or Cron.

Cost, Free-plan ceilings, quota behaviour, and MAU estimates: `docs/hajj/CLOUDFLARE_COST_CONTROL.md`.

## After approval

1. Confirm the account is still on **Workers Free** (Paid off).
2. Confirm Workers Free. Copy `wrangler.toml.example` only for a later approved deploy (`ENVIRONMENT=production`, no mock).
3. KV is optional (page cache). Rate-limit bindings in the example are Free-plan compatible.
4. Local: `npm run dev` uses `wrangler.local.toml.example`.
5. Production HTTPS hostname and `PILOT_GATE` need a later approval. Never commit the gate value.

## Adapters (pilot)

| Id | URL | Retrieval |
| --- | --- | --- |
| `reg.sa.hajj.ministry` | https://www.haj.gov.sa/ | GET homepage only; timeout/auth → manual link |
| `reg.sa.nusuk` | https://www.nusuk.sa/ | GET public homepage; never `/api` or login |
| `reg.gb.fcdo.pilgrimage` | https://www.gov.uk/foreign-travel-advice/saudi-arabia/pilgrimage | GET public FCDO page for GB nationality/residence/departure |

HTTP 200 is **not** official verification.
