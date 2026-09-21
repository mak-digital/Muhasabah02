# Private Muhasabah — Product Specification

## 1. Product purpose

**Private Muhasabah** (*Your record, not a ruling. Notice your day to improve. Keep it yours.*) is a private, local-first Islamic self-reflection application. The visible title is distinct from other store apps named only Muhasabah. Its purpose is to help a user understand their own recorded practice without assigning spiritual rank, issuing religious prescriptions, or turning worship into a gamified performance system.

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
- Date keys remain Gregorian `YYYY-MM-DD`. Settings → Application → Calendar may show Gregorian or civil Islamic (Hijri) dates without rewriting records.
- Settings → Application → **Domains** may hide domains from Home, Review, and today’s check-in without deleting stored records. The first look is **Salah, Qur’an & Akhlaq**: Salah & Prayer Quality, Qur’an Engagement, Hadith & Living Sunnah, Character & Morals (Akhlaq), Rights of Others (Huquq al-Ibad), and Charity. Knowledge & Beneficial Speech, Time & Barakah, Physical Health & Energy, Wealth & Stewardship, Ummah, Dhikr & Dua, Fasting, and Hajj stay available in Domains; they are not on that preset. Stored All or custom sets are not rewritten. Sick visit, sick contact, and support under stress sit on Rights of Others as Care in hardship. Opt-in domains stay off that preset. When shown, they use the same full week matrices as the other domains (Hajj preparation only while due or preparing). Check-in later bands start closed. The same screen holds **this season’s mix**: one saved set of domains, bands, and rows to notice. It is not a score, a programme, or a second hide-list. Named starting points copy a set; Custom is the same mix after editing; Same as Domains follows visibility. Completing the first door sets **First season** (obligatory Salah, Qur’an Journey dimensions, one Hadith row, two Akhlaq rows, Parents, Zakat, and one giving row). Unset stored mix remains Same as Domains. Mix rows on a hidden domain are kept and appear on Home only when that domain is shown. The mix does not rewrite records. Unanswered mix rows are not missed. The first screen is a three-sentence door (private recorder; empty is not missed; short first season). Application Reflection stays in Settings → About. Sample days are not auto-seeded; the door asks once (quiet week or sample days).
- Prefer feature-oriented layers such as `domain/`, `data/`, `application/`, `presentation/` when compatible with the codebase.
- Avoid new dependencies unless they materially reduce risk or complexity.

---

## 3. Information architecture

Recommended primary navigation:

```text
HOME
├── Start today’s check-in
├── Quick tap (busy day)
├── Review recorded experience
└── Manage past check-ins

REVIEW
├── Period summary
│   ├── 7 days
│   ├── 30 days
│   └── 90 days
├── Progress details
│   ├── Salah & Prayer Quality
│   └── Qur’an Engagement
├── Recorded days
└── My Response
```

Evidence exploration may lead to Recorded Context, Recognition, supporting dates, Historical Reflection, and optional Response creation.

Home should remain simple. Do not turn it into a dense analytics dashboard. Home shows one domain week at a time (fixed previous/next chevrons, current short name centred); check-in, **Quick tap** (busy-day tiles for this season’s mix on shown domains; each tap steps the same check-in dropdown for that row, skipping Other; Jumu‘ah is Friday only; Hajj standing status stays in Settings; tiles start unanswered and are never inferred; after unanswered the person’s most recorded choice is next; not a dhikr target or khushu’ score), Reflection of the Week, the week card, the weekly journal, and Add a response stay on the same page. Recognition, Ponder, Recorded days, Noticed This Week, and Patterns Noticed live on Review or Progress. Today’s full check-in shows one domain form at a time the same way; Other and context notes stay on that page.

---

## 4. RECORD — daily check-in

### 4.1 Salah & Prayer Quality

Core question (orientation only; not scored and not a spiritual grade):

**Was my heart present when I stood before Allah?**

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
- excused (recorded; never treated as missed)
- other (recorded observation; not late)

Never infer `missed` from absence.

Salah check-in uses a fixed activity list (congregation on time, joined congregation late, small congregation, alone on time, excused, prayed late, missed then made up, missed, no answer recorded, other). Settings → Application → **Activities** may colour Salah marks by that recorded choice. Shared mark colour remains the default. Colour names the choice; it does not rank spirituality or prescribe a next step.

Do not record or score presence of heart as a grade.

Do not create a combined spiritual score.

**7-day Progress** shows Obligatory Salah, Friday Prayer, and Voluntary Prayers with prayer names as rows and weekday letter + date as columns. Jumu‘ah is Friday-only (other days blank, not unanswered). **30-day and 90-day** stay one calendar per prayer, including Jumu‘ah, Tahajjud, and Ishraq. Jumu‘ah remains Friday-only.

### 4.2 Qur’an Engagement

Core question (orientation only; not scored and not a spiritual grade):

**Did I let the Qur’an speak to me today?**

Provide seven independent stored dimensions (not a Home matrix of seven rows):

1. Recitation (reading/listening)
2. Recitation with Meaning
3. Memorisation
4. Revision
5. Tafsir
6. Qur’anic Reflection
7. Conscious Application

**Home week** shows a Qur’an Journey matrix: Applied (Transformation), Reflected (Internalization), Understood (Comprehension), Engaged (Contact with Qur’an). Each day cell is independent. Colour names the L1 stage. A letter names the L2 activity. Tap a cell to record that row: L1 is that stage, None, or No answer recorded (clears every stored item in that row); L2 is the short list for that stage, plus No activity (recorded as not done) and No answer recorded (unanswered). Unanswered is empty, not missed. Duration is not stored in this version.

**Check-in** groups the same stored rows into L2 bands: Engagement (Recitation, Listening as a Recitation activity, Memorisation, Revision), Understanding (Read Translation, Recitation with Meaning, Tafsir Study), Reflection (Brief Reflection, Deep Reflection (Tadabbur), Personal Insight), Application (Improved Worship, Character, Relationship, Avoided a Sin, Performed a Good Deed, Other Application). Listening is not a new stored dimension.

Reading/listening remains the primary daily Qur’an engagement item. The other dimensions are independent observations except the approved Recitation with Meaning fill.

Do not record or score whether the Qur’an “spoke” as a grade.

**7-day Progress** shows one Qur’an Journey board: Applied, Reflected, Understood, and Engaged as rows and weekday letter + date as columns (same marks and cell sheet as Home). **30-day and 90-day Progress** keep seven peer calendars for the stored dimensions, titled with the same Home Journey stages (Applied, Reflected, Understood, Engaged) and purpose; stages with more than one stored row also name that row (Recitation, Meaning, Memorisation, Revision, Tafsir).

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

### 4.3 Hadith & Living Sunnah

Core question (orientation only; not scored and not a spiritual grade):

**Did a teaching of the Prophet ﷺ reach my day?**

Place this domain immediately after Qur’an Engagement on Home, check-in, and Review. Storage id stays `hadith`. Include it on the Salah, Qur’an & Akhlaq preset.

Retain factual recording for existing Hadith rows (reading, listening, memorisation, revision, study circle, teaching/discussion, Hadith reflection). Add one application observation: **Noticed a sunnah in how I lived today** (`hadith.livedSunnah`). Unanswered is not a failed revival.

Home and **7-day Progress** show those items as rows and weekdays as columns (same orientation as Dhikr and Akhlaq). 30-day and 90-day stay one calendar per row. Current Memorisation Focus stays an AppPrefs value, not a daily grade.

Do not:

- Title the domain as a revival campaign
- Add a sunnah checklist, revival score, or streak
- Auto-fill Living Sunnah from Character & Morals
- Treat this card as a second Qur’an log

These traces do not increase `recordableFieldCount`.

### 4.4 Dhikr & Dua

Core question (orientation only; not scored and not a spiritual grade):

**Did I remember Allah outside of prayer?**

Retain factual recording for existing Dhikr rows (post-fard adhkar, morning and evening, other remembrance). Home and 7-day Progress show those items as rows and weekdays as columns (same orientation as Akhlaq): one week of columns, stacked Home bands, and the day-of-month only under each weekday letter. Do not score remembrance.

### 4.5 Character & Morals (Akhlaq)

Core question (orientation only; not scored and not a spiritual grade):

**Did my behavior today invite people toward goodness?**

Record self-focused observations only:

- Virtues noticed: patience, humility, truthfulness, gentleness, courage, thankfulness in how I acted, contentment
- Paused before reacting
- Honesty in small matters
- Let go of a grudge
- Guarded how I spoke (tone); modest dress; guarded my gaze
- Walked away from an argument; held back from a habit I am trying to leave
- Optional struggle note (for example: I was impatient today, but I caught myself)

Do not:

- Let the user rate themselves as a good or bad person
- Create a character score or personality grade
- Suggest perfection is expected
- Allow logging someone else’s flaw
- Present the domain as a performance review
- Treat patience as only silence; it may also be firmness
- Name vices, keep a days-clean streak, or infer unanswered as a relapse or a sin
- Auto-fill from Gratitude Dhikr or Knowledge’s held-back speech

Unanswered is not a failing. Marks mean “I noticed this in myself” or “I did not notice this today”, not a moral verdict. Check-in and Quick tap always name the row in the selected phrase (for example “I did not notice this today — Paused before reacting”) so the closed dropdown cannot be read against the band title alone (Anger, honesty, forgiveness). The habit on the self-control row is not named in the app. Optional struggle notes are text and do not count toward `recordableFieldCount`. Older `akhlaq.guardedMyGlance` marks stay stored and still appear on Historical Reflection.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names (Patience, Guarded my gaze, and so on).

### 4.6 Rights of Others (Huquq al-Ibad)

Core question (orientation only; not scored and not a spiritual grade):

**Did I fulfill, harm, or neglect anyone’s right over me?**

Record the user’s own obligations toward people Allah placed in their life, framed as investment, not a chore list:

- Household: parents, grandparents, spouse, children, siblings
- Extended family: other relatives
- Neighbours and work: neighbours, colleagues and friends
- The people: fellow Muslims, non-Muslims
- Repair: a step toward reconciliation; turning back over a neglected right
- Care in hardship: sick visit; sick contact; support under stress

Examples of attending to a right (orientation only):

- Parents — kind speech, presence, service, dua
- Grandparents — honouring
- Spouse — patience, kind words, one’s own obligations, presence
- Children — teaching, presence in play, fairness, guarded speech
- Siblings — keeping ties
- Other relatives — keeping ties
- Neighbour — a check-in, a gift, not harming, helping
- Colleagues and friends — trustworthiness, keeping a confidence, sincere advice, not backbiting
- Fellow Muslims — salaam, help in need, dua
- Non-Muslims — justice, kindness, good neighbourliness, character
- Care in hardship — sick visit, sick contact, or support under stress (a right of brotherhood, not a sadaqah channel)

Check-in, Marks Guide, and 7-day Progress show this briefing as short paragraphs plus those bullets.

Do not:

- Let the user log what others owe them
- Create relationship scores for family members or anyone else
- Provide a venting field about other people
- Shame family conflict
- Treat patience as required in harm or abuse; safety and justice come first
- Present the domain as a to-do list

Unanswered is not neglect. Marks mean “I attended to a right I owe” or “I neglected a right I owe”, not a grade of a relationship. The selected check-in phrase names the row (for example “I neglected a right I owe — Parents”). Reconciliation and turning back are optional observations. The app does not prescribe tawbah or sulh, and does not complete them. Care in hardship (sick visit, sick contact, support under stress) is a right of brotherhood on this domain, not a sadaqah channel. These traces do not increase `recordableFieldCount`.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names (Parents, Other relatives, Sick Visit, and so on).

### 4.7 Knowledge & Beneficial Speech

Core question (orientation only; not scored and not a spiritual grade):

**Did I learn something true, and did I speak only what was beneficial?**

Record self-focused observations. A single new fact is enough. The user does not need to be a scholar.

- Seeking truth: learned something true (Islamic or beneficial worldly knowledge that is not logged on Qur’an or Hadith); beneficial reading (not Qur’an or Hadith; book, article, or lecture); asked to remove ignorance
- Sharing: taught someone (even one fact to a child or colleague); sincere advice; wrote or created something beneficial
- Beneficial speech: held back useless speech (gossip, argument, or excessive joking)

Qur’an Engagement and Hadith & Living Sunnah have their own cards. This domain is residual learning and speech. That is orientation, not a rank.

Do not:

- Track hours studied or treat study time as a badge
- Log controversial or divisive content consumption
- Treat debate or argument as knowledge engagement
- Suggest only scholars belong here
- Congratulate the user for being learned
- Treat all knowledge as equal

Unanswered is not ignorance. Marks mean “I noticed this in myself” or “I did not notice this today”. These traces do not increase `recordableFieldCount`.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names (Learned something true, Held back useless speech, and so on).

### 4.8 Time & Barakah

Core question (orientation only; not scored and not a spiritual grade):

**Did I treat my time as a trust from Allah?**

Record self-focused observations of presence, trust, and rest — not hours:

- Presence: present in what I was doing
- Trust: did something I had delayed; stepped away from idle time
- Rest: rested from work as needed; began with intention

The fard stays on Salah. Sleep stays on Physical Health. Do not auto-fill Time from Salah or Health.

Do not:

- Track hours or treat clocked time as a badge
- Create a productivity score or hustle rank
- Shame an unanswered day as wasted
- Congratulate the user for being productive
- Prescribe a daily schedule
- Treat rest as failure
- Record a second prayer-window log on this domain

Unanswered is not wasted time. Marks mean “I noticed this in myself” or “I did not notice this today”. These traces do not increase `recordableFieldCount`. Older `time.guardedPrayerWindow` marks stay stored and still appear on Historical Reflection.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names.

### 4.9 Physical Health & Energy

Core question (orientation only; not scored and not a spiritual grade):

**Did I care for the body Allah entrusted to me?**

Record self-focused care of the body as a trust, not fitness performance:

- Sleep: quality; amount (observation, not an hour badge, and not Time’s rest from work)
- Strength: movement for worship and service; energy for ibadah
- Sustenance: nutrition (halal, healthy, moderation); simple hydration
- Illness and harm: sought care in illness; avoided a harm to the body

Do not:

- Import fitness culture: calorie counting, body-shaming, or “gains”
- Treat physical beauty as a spiritual goal
- Track weight or other body metrics
- Shame illness or disability
- Encourage extreme fasting outside Ramadan
- Ignore that physical and mental health are intertwined
- Auto-fill sleep from Time’s rest, or Time from sleep

Unanswered is not a failing of the body. Marks mean “I noticed this in myself” or “I did not notice this today”. These traces do not increase `recordableFieldCount`.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names.

### 4.10 Wealth & Stewardship

Core question (orientation only; not scored and not a spiritual grade):

**Did my spending and earning please Allah?**

Record self-focused stewardship of wealth as a trust, not net worth:

- Earning: earned from a halal source; stayed clear of riba
- Restraint: avoided waste

Giving (sadaqah, family support, community and care channels) and zakat due / planned / paid stay on Charity, without amounts. A smile is sadaqah. Giving rows formerly on Wealth are not shown on Home, check-in, or Progress; stored `wealth.*` giving marks are kept for Historical Reflection.

Do not:

- Track net worth or savings as a spiritual metric
- Show charity leaderboards or “most generous” badges
- Require amounts
- Shame poverty or debt
- Treat wealth as a sign of Allah’s pleasure
- Ignore that some people cannot give money
- Duplicate Charity giving or zakat on this domain

Unanswered is not a failing of provision. Marks mean “I noticed this in myself” or “I did not notice this today”. These traces do not increase `recordableFieldCount`.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names.

### 4.11 Ummah

Core question (orientation only; not scored and not a spiritual grade):

**Did I serve anyone beyond myself today?**

Record self-focused service beyond the household that is not a salah status and not a sadaqah channel, privately:

- Masjid: class or gathering (not the fard). Jumu‘ah and the five prayers stay on Salah
- Witness: da’wah by character (not argument; not Character & Morals’ virtue list)
- Solidarity: supported the oppressed (dua, awareness, or material help); worked for unity; prayed for the Ummah
- Earth: cared for the earth as a trust

Help to a neighbour, community giving, and sick care stay on Rights of Others and Charity. Charity Family Support is a gift or extra support, not ordinary household nafaqa. “Served beyond myself” is not shown on Home, check-in, or Progress; stored `ummah.communityService` marks are kept for Historical Reflection. Masjid marks here are not a public check-in.

Do not:

- Make masjid attendance visible to others
- Duplicate the fard or Jumu‘ah on this domain
- Log political rants or sectarian arguments
- Treat only organized volunteering as valid
- Shame social anxiety or introversion
- Ignore isolation (including converts and new immigrants)
- Conflate community with an ethnic group — the Ummah is global

Unanswered is not isolation or neglect of the Ummah. Marks mean “I noticed this in myself” or “I did not notice this today”. These traces do not increase `recordableFieldCount`.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names.

### 4.12 Other established domains

If present in an existing implementation, retain factual recording for domains such as:

- gratitude
- personal reflection

Do not remove valid established domains merely because Progress emphasizes Salah and Qur’an.

### 4.13 Persistence boundary

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

Stable structured factor IDs should be used. Existing accepted factor catalogs in a repository are authoritative. Charity Giving and Care traces share one helping/distracting catalog (values, relationships, responsibility, influence, capacity; constraints, trust, conflict, organisation, competing priorities). It is not the Qur’an context list and not a per-row survey. Those factors remain optional provenance and never cause an outcome or score giving. Zakat stays a status, not a second factor list.

---

## 6. History

Keep these concepts distinct when both exist:

### Manage past check-ins

- compact week groups of saved days only; tap to edit; ⋮ or long-press to remove
- All / 30 / 90 is a view filter only; field counts are not shown

### Recorded days / Historical Reflection

- compact week grid of saved vs empty days; empty days are visible and not treated as missed
- tapping a saved day opens a compact, read-only day view grouped by domain washes
- one Add a response control per page, not per field

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

### 8.1 Salah & Prayer Quality Progress

Support 7D / 30D / 90D.

Use stable prayer identity colours for Fajr, Dhuhr, Asr, Maghrib, and Isha, with equal visual status.

Suitable state grammar:

- recorded desired outcome: solid/filled marker
- explicit alternative outcome: outlined marker with distinct internal symbol
- unanswered: faint/dotted/broken outline
- selected: focus ring / selection treatment

A 30-day Salah heatmap is acceptable if readable and already established.

Do not use daily red/green success/failure grading.

### 8.2 Qur’an Engagement Progress

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

- 7D: Qur’an Journey matrix (stage rows × weekday columns); tap a cell to record that row
- 30D: compact weekly calendar per stored dimension, titled as Home Journey stages
- 90D: one full-width weekly calendar for the last 90 days (today’s week rightmost), with month labels, two alternating shades of the domain colour on day cells only, a pale yellow halo on today’s mark, and period arrows to move to earlier or later 90-day windows; titles match Home Journey stages

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

Optional Unlock with this device may use the phone PIN, pattern, or biometrics before the app is shown. That is not encryption-at-rest.

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
