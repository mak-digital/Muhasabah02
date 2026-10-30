# Hajj Phase 3A — offline planning engine

Schema remains **version 1**. New JSON objects are optional: `planning` on a journey, richer `returnPlan`, traveler `healthPreparationNote` / `confirmedPathwayIds`, milestone `templateId`.

## Assumptions

- Pathway families are planning categories. They are never legal eligibility.
- A route is unused until the person taps **Confirm planning route**.
- Template dates are conservative lead times from intended departure (or Hajj period start). They are labelled planning estimates.
- Official deadlines are never invented or overwritten.
- Unused package services are never treated as refundable unless a confirmed refund amount is typed.
- Early return never suggests omitting required Hajj rites.
- Missing passport dates are “needs a record”, not neglect.

## Phase 3B

Implemented as optional on-device demonstration assistance. See `docs/hajj/PHASE_3B.md`. Offline planning in this document is unchanged.
