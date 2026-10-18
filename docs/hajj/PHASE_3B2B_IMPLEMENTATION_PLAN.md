# Phase 3B-2B implementation plan (not started)

Do not begin until the owner explicitly approves. 3B-2B is live integration behind the contracts already injected.

## Suggested slices

1. **Worker skeleton** — health check, allowlisted GET of one Saudi portal, cache in KV, return unverified bookmarks. No AI. Spend cap.
2. **App client** — HTTPS client implementing `HajjOfficialSourceGateway`, still gated by lookup consent. Keep `DemoHajjOnlineAssistGateway` for tests and offline fallback.
3. **Provenance UI** — retrieval time, authenticity/freshness/applicability labels, conflict list. Banner remains until the person marks a source.
4. **Provider register fetch** — parse only an official register page if legally and technically reliable; otherwise keep empty.
5. **Optional AI** — separate consent, excerpts only, uncertainty required, Accept/Reject unchanged. Cost cap.
6. **Ops** — rate limits, log redaction, secret rotation, documented rollback to demo gateway.

## Explicit non-goals

- Booking, payments, eligibility engine, religious rulings
- Embedding API keys in Flutter
- Uploading the Hajj store
- Analytics / advertising identifiers

## Exit criteria for 3B-2B

- Offline Hajj Home works with the Worker unreachable
- Dual consent still independent
- No sensitive fields in captured logs
- Analyzer + full test suite green with mock Worker
- Owner has approved hosting spend

## Outstanding decisions for the owner

1. Approve Cloudflare Worker (recommended) vs Cloud Run.
2. Approve **Workers Free only** (USD 0). Cloudflare has no hard spending cap; a USD 10 alert does not limit liability. AI remains USD 0. See `docs/hajj/CLOUDFLARE_COST_CONTROL.md`.
3. Whether 3B-2B includes AI at all.
4. Git commit sequence for the currently uncommitted Hajj/Fasting tree.
