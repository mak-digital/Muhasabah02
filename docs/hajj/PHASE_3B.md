# Hajj Phase 3B — optional online assistance

**Status:** Implemented and verified (pre-launch). Schema remains **version 1**.

Additive store fields: `onlineAssist`, `pendingProposals`, richer `sources` and `providers`. No bookings, no eligibility engine, no live government feed, no paid AI, no private API keys in the Flutter app.

## Architecture and data flow

Two independent modes:

1. **Offline (default).** Standing, journeys, readiness, calendar, pathways, and return planning work with no network. Nothing Hajj-related is transmitted in the background.
2. **Online assistance (explicit opt-in).** The person turns on one or both consents, then taps a request. Results are stored locally for review. Accepting an AI-style proposal adds a reminder milestone only after **Accept**.

```
UI (consent switches + request buttons)
  → HajjLookupRequest (season, nationality, residence, departure, pathway ids)
  → hajjOnlinePayloadIsSafe (reject passport/scan/reflection/health/name/family/notes keys)
  → HajjOnlineAssistGateway
       DemoHajjOnlineAssistGateway (on-device catalog; default in providers)
       FailingHajjOnlineAssistGateway (tests)
  → local HajjStore.sources / .providers / .pendingProposals
  → person reviews Unverified labels, then Accept / mark verified by user
```

The entire Hajj store is never uploaded. Travelers’ names, passport dates, health notes, After Hajj reflections, and family identities are omitted from the request builder.

There is **no secure backend** in this build. Live HTTP is not called. INTERNET remains for citation pages elsewhere in the app, not for Hajj lookup.

## Consent and privacy

Before a request, the panel states:

- What may be used: season, nationality, residence, departure country, confirmed pathway labels.
- Who receives it in this build: a demonstration catalog / interpreter **on this device**.
- Why: to fetch bookmarks or a reviewable suggestion.
- AI: a demonstration interpreter only; not a live model.
- Retention: demonstration records stay on the phone; there is no live government feed and no paid AI.

Separate switches:

- `hajj-consent-lookup` — official-source bookmarks.
- `hajj-consent-ai` — AI-style interpretation.

Request buttons stay disabled until the matching switch is on. Either switch can be turned off at any time; both off records `revokedAt` and the card returns to **Offline**.

## Official-source verification

Each `HajjOfficialSource` can record issuing authority, URL, jurisdiction, season, published/retrieved dates, requirement text, deadline, pathway applicability, verification status, provenance, and a demonstration flag.

Rules:

- Search results, AI text, and commercial agent copy are never official verification.
- Demonstration bookmarks stay **Unverified** and labelled Demonstration.
- Manual sources stay **Unverified** until the person taps the row to mark **verified by you**.
- Conflicting deadlines are listed; they are not auto-resolved.
- Stale sources are labelled; they do not overwrite typed official milestone deadlines.

## Country-specific guidance

Nationality, legal residence, and departure country remain distinct inputs (traveler vs journey). Demonstration bookmarks include a Saudi Hajj authority URL and a nationality-scoped national-mission bookmark. The app does not decide eligibility or religious obligation. Unknown official requirements stay Unverified / not estimated.

## Provider discovery

`HajjProviderSlot` shows name, country/service area, season, contact, package notes, independent review (separate from authorization), source/retrieval, and evidence.

A provider is **not** labelled officially authorized unless `hajjProviderMayBeCalledAuthorized` finds current evidence. The demonstration operator is never authorized. No rankings, invented prices, payments, or bookings.

## AI-assisted interpretation

`DemoHajjOnlineAssistGateway.interpret` returns a `HajjPlanProposal` (AI interpretation provenance). Copy states it is not a government ruling, eligibility decision, or official deadline. **Accept** adds a pending reminder milestone without inventing `officialDeadline`. Denial or leaving it unaccepted leaves the plan unchanged.

Live model calls are not implemented. A future backend must sit outside the APK, with owner approval, before any paid or remote AI.

## Preliminary corrections

- Untitled legacy milestones (`title` empty or `Milestone`) are excluded from the critical path until named or deleted.
- Calendar lists untitled rows with a name-or-delete workflow (`Delete milestone`).
- Missing return costs show **Not estimated**, not zero.
- An explicit `packageCost: 0` remains **Estimate 0**.

## Tests (automated)

Mock/demo gateways only. No real personal data.

Covered: offline consent default; independent lookup vs AI; minimum payload; sensitive keys rejected; demonstration sources Unverified; providers not authorized; conflicting/stale handling; proposal accept requires confirmation; untitled critical-path skip; Not estimated vs explicit zero; failing gateway leaves the store intact (widget + domain tests).

## Emulator verification (Medium Phone, emulator-5554, 18 Oct 2026)

Existing Hajj standing **I believe it is due** and journey **Considering** persisted. Offline card showed **Offline** with request buttons gated. Dual consent turned on independently; subtitle **Opted in (revocable)**. Manual source **DemoMinistry** stored as Unverified / user-entered. Demonstration lookup added Ministry of Hajj and Umrah and national-mission bookmarks, both Unverified · Demonstration, plus a provider **Not labelled officially authorized**. AI proposal required **Accept**; after accept, reminder “Ask your mission about the registration window” appeared among milestones. Return rows showed **Not estimated**. Untitled rows listed with delete. Both consents revoked → **Offline** again. Standing, journey, readiness, and calendar remained. After Hajj reflection field was not sent. Network was not required; snackbar stated live lookup and paid AI are not enabled.

Screenshots: `docs/hajj/phase3b_screenshots/`.

## Remaining deployment prerequisites

- Owner approval before any paid or live service.
- A backend the phone can call without embedding private API keys.
- Real official feeds (if ever) must still land as Unverified until the person confirms.
- No bookings, eligibility engine, analytics, or advertising identifiers.

## Security and privacy risks

- Demonstration URLs are public bookmarks, not proof of current law.
- A person can mark a source verified by themselves; that is user judgment, not government certification.
- Future live AI must not receive reflections, passport numbers, scans, health notes, or family identities.
- INTERNET permission already exists for citations; Hajj 3B does not add tracking.

## Completion

Phase 3B implementation and verification are complete for the authorized demonstration/manual workflow. Live verification is **not** claimed.

Phase 3B-2A (contracts, registry, backend design, no live activation) is documented under `docs/hajj/PHASE_3B2A_AUDIT.md` and the companion 3B-2A files.
