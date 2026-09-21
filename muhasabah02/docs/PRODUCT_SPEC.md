# Muhasabah — Product Specification

## 1. Product purpose

Muhasabah is a private, local-first Islamic self-reflection application. Its purpose is to help a user understand their own recorded practice without assigning spiritual rank, issuing religious prescriptions, or turning worship into a gamified performance system.

Canonical maturity model:

**RECORD → REFLECT → REVIEW → RECOGNISE → PONDER → RESPOND**

Whole-app review model:

**SEE → PONDER → EXPLORE**

Permanent principles:

- **ENGAGEMENT VISIBILITY ≠ ENGAGEMENT JUDGMENT**
- **MISSING / UNANSWERED ≠ NEGATIVE**
- **USER-OWNED ≠ APP-PRESCRIBED**
- **PROVENANCE ≠ CAUSALITY**
- Muhasabah may describe and help the user explore their recorded evidence. It does not select a remedy from that evidence.

The app is not a fatwa engine, spiritual scoring engine, religious recommendation system, habit-compliance system, or AI religious adviser.

---

## 2. Technology and deployment

Preferred stack:

- Flutter / Dart
- Riverpod
- Hive local persistence
- Android as primary deployment target

Requirements:

- Full offline usability.
- No telemetry, ads, cloud AI, or remote analytics in core functionality.
- Preserve a sound existing architecture when working in an established repository.
- Prefer feature-oriented layers such as `domain/`, `data/`, `application/`, `presentation/` when compatible with the codebase.
- Avoid new dependencies unless they materially reduce risk or complexity.

---

## 3. Information architecture

Recommended primary navigation:

```text
HOME
├── Start today’s check-in
├── Review recorded experience
└── Manage past check-ins

REVIEW
├── Period summary
│   ├── 7 days
│   ├── 30 days
│   └── 90 days
├── Progress details
│   ├── Salah
│   └── Qur’an
├── Recorded days
└── My Response
```

Evidence exploration may lead to Recorded Context, Recognition, supporting dates, Historical Reflection, and optional Response creation.

Home should remain simple. Do not turn it into a dense analytics dashboard. Home shows one domain week at a time (previous/next short names); check-in, Reflection of the Week, and the week card stay on the same page. Today’s full check-in shows one domain form at a time the same way; Other and context notes stay on that page.

---

## 4. RECORD — daily check-in

### 4.1 Salah

Track the five daily prayers independently:

- Fajr
- Dhuhr
- Asr
- Maghrib
- Isha

At minimum distinguish:

- prayed on time
- prayed late
- missed
- unanswered / not recorded

Never infer `missed` from absence.

Do not create a combined spiritual score.

### 4.2 Qur’an

Provide seven independent dimensions:

1. Reading/listening
2. Meaning
3. Memorisation
4. Revision
5. Tafsir/explanation
6. Reflection
7. Application Reflection

Reading/listening is the primary daily Qur’an engagement item. The other six are independent observations.

For optional activities, selecting the activity must not automatically mean a positive outcome. Ask for an explicit status.

Approved wording:

**Meaning**

Question: `Did you spend time engaging with the meaning or translation of Qur'an today?`

Answers:

- `Engaged with meaning/translation`
- `Did not engage with meaning/translation`

**Memorisation**

Question: `Did you spend time memorising Qur'an today?`

Answers:

- `Practised memorisation`
- `Did not practise`

**Revision**

Question: `Did you spend time revising memorised Qur'an today?`

Answers:

- `Practised revision`
- `Did not practise`

**Tafsir**

Question: `Did you spend time studying tafsir or an explanation of an ayah or passage today?`

Answers:

- `Studied tafsir/explanation`
- `Did not study tafsir/explanation`

**Reflection**

Question: `Did you spend time reflecting on the meaning of an ayah or passage today?`

Answers:

- `Spent time reflecting`
- `Did not spend time reflecting`

**Application Reflection**

Question: `Did you spend time reflecting on how something from the Qur’an might relate to your daily life?`

Answers:

- `Reflected on possible practical relevance`
- `Did not reflect on practical relevance`

Application Reflection records reflection on possible practical relevance only. It is not evidence of action, implementation, obedience, compliance, successful application, or completion of a Response.

### 4.3 Other established domains

If present in an existing implementation, retain factual recording for domains such as:

- Dhikr / Istighfar
- conduct / character reflection
- gratitude
- personal reflection

Do not remove valid established domains merely because Progress emphasizes Salah and Qur’an.

### 4.4 Persistence boundary

If the repository already uses `DailyCheckIn` schema v5 and `recordableFieldCount = 10`, preserve both unless a critical defect is proven.

Personal Response must not increase the DailyCheckIn denominator.

---

## 5. REFLECT — optional recorded context

Context is optional, self-reported, and descriptive. It is never objective causality.

Preferred wording: `You recorded...`

Avoid: `The reason was...`, `This caused...`, or equivalent causal claims.

Context does not affect check-in completion.

Eligibility for newer Qur’an dimensions:

- Meaning: positive and negative context
- Memorisation: positive and negative context
- Revision: positive and negative context
- Tafsir: positive context only
- Reflection: positive context only
- Application Reflection: no context in V1

Approved prompts:

- Meaning positive: `What supported your engagement with meaning or translation? (Optional)`
- Meaning negative: `Was there a main factor in not engaging with meaning or translation today? (Optional)`
- Memorisation positive: `What supported your memorisation practice today? (Optional)`
- Memorisation negative: `Was there a main factor in not practising memorisation today? (Optional)`
- Revision positive: `What supported your revision practice today? (Optional)`
- Revision negative: `Was there a main factor in not practising revision today? (Optional)`
- Tafsir positive: `What supported your tafsir or explanation study today? (Optional)`
- Reflection positive: `What supported or prompted your reflection today? (Optional)`

Stable structured factor IDs should be used. Existing accepted factor catalogs in a repository are authoritative.

---

## 6. History

Keep these concepts distinct when both exist:

### Manage past check-ins

- editable
- may correct/delete previously saved records

### Recorded days / Historical Reflection

- read-only evidence browsing
- shows exactly what the user recorded
- used by REVIEW and EXPLORE

The navigation and wording must make the difference obvious.

---

## 7. REVIEW — period summary

Definition:

> A private place to understand and navigate what the user previously recorded—across time, domains, exact days, and optional context—without changing records or prescribing what to do next.

Provide one Period Summary destination with a selector for:

- 7 days
- 30 days
- 90 days

Default new entry: 7 days.

Use one screen whose selected period changes in place where practical.

Period Summary may show factual information such as:

- days recorded / missing
- Salah totals
- Qur’an reading/listening
- Dhikr where available
- conduct where available
- gratitude-entry count
- personal-reflection-entry count
- accepted factual period comparisons

Do not generate recommendations.

Explicitly prohibit legacy sections such as `For the coming days` and any deterministic worship/conduct recommendation.

---

## 8. PROGRESS — visual dashboard

Progress is a major visual surface. It should feel modern, clear, engaging, and evidence-first.

Use colour to identify domains and states, not spiritual rank.

Never implement a moral traffic-light system where green means spiritually good and red means spiritually bad.

All important state differences require shape/text redundancy so the UI remains understandable without colour.

### 8.1 Salah Progress

Support 7D / 30D / 90D.

Use stable prayer identity colours for Fajr, Dhuhr, Asr, Maghrib, and Isha, with equal visual status.

Suitable state grammar:

- recorded desired outcome: solid/filled marker
- explicit alternative outcome: outlined marker with distinct internal symbol
- unanswered: faint/dotted/broken outline
- selected: focus ring / selection treatment

A 30-day Salah heatmap is acceptable if readable and already established.

Do not use daily red/green success/failure grading.

### 8.2 Qur’an Progress

Display seven peer dimensions:

- Reading/listening
- Meaning
- Memorisation
- Revision
- Tafsir
- Reflection
- Application Reflection

Use stable subdued accent colours with equal semantic weight for card washes. Marks share one colour; shape encodes the recorded state.

Recommended presentation:

- 7D: chronological seven-marker trace
- 30D: compact wrapped chronological trace
- 90D: one full-width weekly calendar for the last 90 days (today’s week rightmost), with month labels, two alternating shades of the domain colour on day cells only, a pale yellow halo on today’s mark, and period arrows to move to earlier or later 90-day windows

For the six newer neutral dimensions, display factual counts such as `Recorded on X of Y days` and positive activity-day counts.

Do not show success/failure rate, ranking, winner/loser comparison, improvement gradient, or aggregate Qur’an score for those dimensions.

Legend wording:

- `Recorded activity`
- `Recorded as not done`
- `No answer recorded`

### 8.3 PONDER

Display exactly:

`What do you notice about your recorded Qur’an engagement in this period?`

It is static and optional. Do not auto-answer it. Do not require input.

---

## 9. Accepted richer Progress analytics

Where richer Salah / reading-listening analytics exist, use these semantics:

- Missing/notRecorded is excluded from the outcome denominator.
- Salah desirable = prayedOnTime.
- Qur’an reading/listening desirable = readOrListened.
- 7D adequacy: at least 4 recorded observations in both current and prior periods.
- 30D adequacy: at least 15 recorded observations in both periods.
- Direction threshold: ±10 percentage points inclusive.

90D established consistency may use:

- at least 45 recorded total
- each 30-day block at least 12 recorded
- overall desirable at least 85%
- no block below 80%
- recent block not more than 10 percentage points below middle

90D precedence:

1. insufficient evidence
2. recent deterioration
3. established consistency
4. improvement
5. steady

Aggregate colour is aggregate-only and must not create daily moral grading.

Never create a combined spiritual score.

---

## 10. RECOGNISE — descriptive patterns

Recognition is descriptive and evidence-first.

Pattern identity:

`domain + subject + outcome + question + factor ID`

Generic thresholds:

- contextual observations C >= 5
- factor occurrences F >= 3
- F/C >= 40%
- at least 3 distinct dates
- date span >= 7 days
- only 30D and 90D

For newer Qur’an subjects additionally require contextual coverage `C/T >= 40%` where T is the relevant recorded-outcome count.

Do not retroactively alter older accepted Salah/daily-engagement rules unless required by repository authority.

Preferred wording:

`Context was recorded for C of T observations where you recorded {outcome}.`

`Among those C observations, “{factor}” appeared on F.`

Prohibited causal/advisory terms include:

- associated with
- linked to
- caused
- led to
- because
- reason
- risk factor
- predicts
- you should

Supporting dates/evidence must remain inspectable.

---

## 11. RESPOND — My Response

Personal Response is a separate domain from DailyCheckIn.

Definition:

> A Response is an optional, private, user-authored record of what the user chooses to keep in mind, revisit, question, or try after reflection. It may be linked to recorded evidence as its point of origin, without implying causality, recommendation, obligation, or completion.

Frozen V1 wording:

- Destination: `My Response`
- Description: `A private, optional place to write a note, question, or something you want to keep in mind.`
- CTA: `Add a response`
- Creation prompt: `What, if anything, would you like to note or keep in mind?`
- Empty state: `You haven’t saved any responses. Creating one is optional.`
- Save: `Save response`
- Edit: `Edit response`
- Archive: `Archive response`
- Restore: `Restore response`
- Delete: `Delete response`
- Provenance: `Created while viewing: [origin]`

Do not use system concepts such as Intention, Commitment, Next Step, Improvement, Action Plan, completion, adherence, or success/failure.

The user's own text is not restricted to these words; the app must not parse or judge it.

### 11.1 Data model

Recommended entity:

```text
PersonalResponse
- id
- text
- createdAt
- editedAt?
- archivedAt?
- provenance?
```

Use:

- separate Hive box
- independent Response schema v1
- one JSON document per Response
- opaque secure-random ID
- local-only persistence

Archive is organizational only.

Delete removes the app-managed record. Do not claim forensic secure erasure.

### 11.2 Text handling

Allow multiline, Unicode, emoji, Arabic, Bangla, and other scripts.

Reject empty/whitespace-only text.

Normalize CRLF/lone CR to LF.

Do not Unicode-normalize user religious text in a way that may alter meaningful marks.

A defensive maximum near 10,000 Unicode scalar values is acceptable.

Never classify, infer goals, detect religious intention, measure adherence, score sentiment, or generate advice from Response content.

### 11.3 Provenance

**PROVENANCE ≠ CAUSALITY**

Possible origin families:

- Period Summary
- Progress dimension
- Progress date
- Recorded Context
- Recognition pattern
- Recognition supporting date
- Historical Reflection
- Qur’an PONDER
- completed check-in

Store minimum structured identity only, such as origin type, domain, subject, date, period, contextual factor ID, stable evidence ID, and a minimal safe label snapshot.

Never persist in provenance:

- raw journal text
- gratitude text
- personal-reflection free text
- contextual free text
- recommendation text
- causal explanation
- persisted route string

If evidence becomes unavailable, the Response remains valid. A neutral message may state:

`The originating evidence is no longer available.`

### 11.4 Response entry points

Allow restrained `Add a response` entry points from approved reflective/evidence surfaces, such as:

- Qur’an PONDER
- Salah evidence/detail
- Qur’an evidence/detail
- Historical Reflection
- Recognition
- supporting dates
- Recorded Context

The editor must never open automatically.

Use the same neutral CTA for positive and negative evidence.

For Salah, prayed-on-time, late, and missed evidence must receive equivalent Response affordance.

Application Reflection may be provenance only and must never become evidence of implementation, compliance, obedience, successful application, or completion.

---

## 12. Motivation without gamification

Motivation should come from:

- seeing continuity
- noticing gaps
- seeing breadth/concentration
- comparing the user's own periods when meaningful
- exploring exact evidence
- recognizing descriptive context patterns
- writing user-owned Responses

Do not use:

- streak anxiety
- guilt/shame
- red failure states
- trophies
- leaderboards
- points
- iman/taqwa/spiritual scores
- ranks
- perfect-day grades
- arbitrary worship targets
- unsolicited reminders

---

## 13. Visual design system

The app should look production-grade rather than like a questionnaire or developer tool.

Use a coherent design system with:

- typography hierarchy
- spacing scale
- surface hierarchy
- corner-radius standards
- icon rules
- domain accents
- recorded-state styles
- selected-state styles
- light/dark theme equivalents
- consistent interaction states

Prefer:

`summary → visual trace → detail → exact evidence`

rather than displaying everything at once.

Target common phone widths around 360–411 logical px and text scales 1.0 / 1.3 / 1.5.

No RenderFlex overflow.

Use responsive wrapping/scrolling appropriately.

---

## 14. Accessibility

Critical information must not depend on colour alone.

Use useful semantics for buttons, selected states, dates, dimensions/prayers, and recorded outcomes.

Date-marker semantics should include date + dimension/prayer + exact recorded state where practical.

Requirements:

- adequate contrast
- reasonable touch targets
- scalable text
- keyboard-safe editors
- dark mode
- screen-reader labels
- no duplicate/noisy semantics

---

## 15. Privacy

Default: local-first and offline.

Do not intentionally transmit user records.

No telemetry, advertising tracking, remote analytics, or cloud AI.

Never log private text such as Response, journal, gratitude, personal reflection, contextual free text, or full serialized private records.

Use opaque IDs in errors when necessary.

Use only synthetic test data.

Preserve existing Android backup restrictions when present unless there is a documented reason to change them.

Do not claim encryption-at-rest, forensic secure deletion, or absolute confidentiality unless technically implemented and verified.

---

## 16. Failure and corruption handling

A malformed local record must not make all healthy records inaccessible.

Requirements:

- isolate corrupt records
- preserve healthy records
- do not silently manufacture missing values
- do not auto-delete corrupt data
- failed write preserves prior saved state
- failed delete leaves the item visible
- draft text should be retained where practical after failure
- unknown future schema degrades safely
- unknown Response provenance preserves the Response
- malformed route must not crash

---

## 17. Religious-integrity boundaries

Do not invent religious rulings or infer:

- divine acceptance
- iman strength
- taqwa level
- sincerity
- spiritual rank
- sin status
- reward quantity

Do not prescribe worship remedies or automatically select a religious next action.

The app records what the user says they did, helps them inspect it, and leaves meaning/action to the user.

---

## 18. Release-quality requirements

A complete release should include:

- working Flutter source
- automated tests
- clean static analysis
- successful debug build
- installable release APK where toolchain permits
- AAB where practical
- README
- architecture documentation
- privacy documentation
- test documentation
- build/install instructions
- known limitations
- exact Git status / commits
- release notes

If production signing credentials are unavailable, continue all other development and clearly state the remaining signing step. Never fabricate credentials.
