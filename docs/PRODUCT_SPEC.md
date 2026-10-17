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
- Date keys remain Gregorian `YYYY-MM-DD`. Settings → Preferences → Calendar may show Gregorian or civil Islamic (Hijri) dates without rewriting records.
- Settings → Preferences → **Domains in Focus** may hide domains from Home, Review, and today’s check-in without deleting stored records. The first look is **Salah, Qur’an & Dhikr**: Salah & Prayer Quality, Qur’an Engagement, and Dhikr & Dua. Hadith & Living Sunnah, Character & Morals (Akhlaq), Rights of Others (Huquq al-Ibad), Charity, Knowledge & Beneficial Speech, Time & Barakah, Physical Health & Energy, Wealth & Stewardship, Ummah, Fasting, and Hajj stay available there; they are not on that preset. Stored All or custom sets are not rewritten. Sick visit, sick contact, and support under stress sit on Rights of Others as Care in hardship. Opt-in domains stay off that preset. When shown, they use the same full week matrices as the other domains (Hajj preparation only while due or preparing). Check-in later bands start closed. The same screen holds **this season’s mix**: one saved set of domains, bands, and rows to notice. The mix is a subset of the domains shown on that screen (bands and rows). A domain or row that does not apply can stay unselected; saved records are not rewritten. It is not a score, a programme, or a second hide-list. Named starting points copy a set; Custom is the same mix after editing; Same as Domains follows visibility. Completing the first door sets **First season** (obligatory Salah, selected Qur’an Journey dimensions, and two Dhikr rows). Unset stored mix remains Same as Domains. Mix rows on a hidden domain are kept and appear on Home, Review, Progress, check-in, and Quick Tap only when that domain is shown. The mix does not rewrite records. Unanswered mix rows are not missed. The first screen is a three-sentence door (private recorder; empty is not missed; short first season). Application Reflection stays in Settings → About. Sample days are not auto-seeded; the door asks once (quiet week or sample days).
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

Home should remain simple. Do not turn it into a dense analytics dashboard. Home shows one domain week at a time (fixed previous/next chevrons, current short name centred). After the Salah week, Home shows **Salah & Prayer Quality Learn & Practice** (Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with a private register; not a khushu’ score), then a domain-action wash (collapsed by default; at most five full-width chips; the status circle on an active chip opens Completed/Closed, In progress/Active, Edit, and Delete; Edit opens a sheet for the text, target date, and priority; Delete marks an x and keeps the row; completed and deleted chips stay on the wash until the circle is tapped or a sixth chip needs the slot, then they remain in the register as Closed or Deleted until the person selects them and deletes them from the register) and a developer-note wash (collapsed by default; + add Note and Open Note Register sit as a matching pair; Open Note Register lists notes to edit or select and delete before download; developer-note wash uses a cooler mix of the domain wash so it is distinct from the actions wash). The Qur’an, Hadith, and Dhikr weeks use the same actions and notes washes in that domain’s wash colour; listed actions stay on their own domain. Dhikr also has **Dhikr & Dua Learn & Practice**: a grouped built-in list (post-fard, morning, evening, other adhkar) the person may add to a private register. It is not a dhikr target. Character & Morals, Rights of Others, Knowledge & Beneficial Speech, Time & Barakah, Physical Health & Energy, Wealth & Stewardship, Ummah, Fasting, Hajj, and Charity use the same three washes, with Learn & Practice catalogs grouped like Home. Knowledge’s catalog is residual learning and speech (not Qur’an, Hadith, or Character’s tone). Time’s catalog encourages the eight observations and is not a timetable or barakah score. Health’s catalog is care of the body as a trust, not fitness. Wealth’s catalog is earning as a trust, not giving. Ummah’s catalog is belonging beyond the household, not the fard or Charity. Fasting’s catalog is voluntary and make-up noticing, not a Ramadan grade. Hajj’s catalog is preparation noticing, not a due-date. Charity’s catalog is giving and care, not amounts. Completion is not a salah score. The app does not send mail. Check-in, **Quick tap** (busy-day tiles for this season’s mix on shown domains; weekday with Gregorian and civil Hijri dates in a full-width wash with Quick tap at the top left and the busy-day note collapsed until opened; previous/next day arrows that do not enter the local future; each mix domain shows wash and title, with cards collapsed until opened, or open if only one mix domain is shown; each tap steps the same check-in dropdown for that row, skipping Other; Jumu‘ah is Friday only; Hajj standing status stays in Settings; tiles start unanswered and are never inferred; after unanswered the person’s most recorded choice is next; not a dhikr target or khushu’ score), Reflection of the Week (previous/next through quotes; the one you stop on stays as that day’s or week’s reflection; Open citation is an in-app reader with Close and Share), and the week card stay on the same page. Recognition, Ponder, Recorded days, Noticed This Week, and Patterns Noticed live on Review or Progress. Today’s full check-in shows one domain form at a time the same way; Other and context notes stay on that page.

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

Salah check-in uses a fixed activity list (congregation on time, joined congregation late, small congregation, alone on time, excused, prayed late, missed then made up, missed, no answer recorded, other). **Friday Prayer** is one Jumu‘ah row with that same list and Friday wording (for example prayed late (alone)); it is not a second “Friday congregation” field. **Tahajjud** and **Ishraq** use their own five-choice lists (night timing / morning timing / prayed / not prayed / not recorded), not the obligatory Salah list and not missed-red. **Not Prayed** is a solid empty circle (the activity colour as the border, no fill). Settings → Preferences → **Activities & legend** may colour Salah, Jumu‘ah, Tahajjud, and Ishraq marks by that recorded choice, starting with congregation-on-time blue for the first option. Shared mark colour remains the default. Colour names the choice; it does not rank spirituality or prescribe a next step. Voluntary rows stay off the recordable-field count. Unanswered is not missed.

Do not record or score presence of heart as a grade.

Do not create a combined spiritual score.

**7-day Progress** shows Obligatory Salah, Friday Prayer, and Voluntary Prayers with prayer names as rows and weekday letter + date as columns. Jumu‘ah is Friday-only (other days blank, not unanswered). **30-day and 90-day** stay one calendar per prayer, including Jumu‘ah, Tahajjud, and Ishraq. Jumu‘ah remains Friday-only.

Home also lists **Salah & Prayer Quality Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home (Obligatory Salah, Friday Prayer, Voluntary Prayers), collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). It is not a khushu’ score, congregation requirement, or daily grade.

### 4.2 Qur’an Engagement

Core question (orientation only; not scored and not a spiritual grade):

**Did I let the Qur’an speak to me today?**

Daily check-in, Home, Quick tap, and Progress use **three independent notice-rows** under one wash, **ENGAGEMENT with Qur’an** (like Hadith’s ENGAGED with Hadith), not seven yes/not-done dimensions. Unanswered is never inferred as not engaged. Duration is observational: not a khushu’ score, streak, percentage, complete, or spiritual grade. 3–5 minutes is still a recorded sitting. There is no live timer. Older seven-row days are not migrated.

Stored keys stay `quran.reading`, `quran.meaning`, and `quran.consciousApplication`:

1. **Engagement** (`reading`) — recitation, memorisation and/or revision
2. **Understanding & reflection** (`meaning`) — meaning and/or tafsir plus pondering
3. **Practical relevance** (`consciousApplication`) — identifying implications and/or use of learnt verses in daily life (not a deed-score)

Each row shares the same duration list. The closed dropdown names the row. Verbs: Engagement uses “Engaged”; the other two use “Involved”.

- (a) more than 20 minutes — Salah `congregationOnTime` `#1565C0`
- (b) 15–20 minutes — `joinedCongregationLate` `#2E7D32`
- (c) 10–15 minutes — `smallCongregation` `#66BB6A`
- (d) 5–10 minutes — `aloneOnTime` `#C0CA33`
- (e) 3–5 minutes — `aloneOnTime` `#C0CA33` outlined empty (same light green as 5–10; still a recorded sitting)
- (f) I did not notice this today — {row} — `prayedLate` `#FBC02D` outlined
- (g) no answer recorded — unanswered `#BDBDBD` dotted empty

Do not use Missed or Missed-then-made-up colours: these rows are not fard. Rows stay independent (no Meaning → Recitation auto-fill). Application Reflection remains Settings → About only.

Do not record or score whether the Qur’an “spoke” as a grade.

**Home week** and **7-day Progress** show those three rows under **ENGAGEMENT with Qur’an**. Marks share one colour by default; Settings → Preferences → Activities & legend may colour the duration step with those Salah twins. Tap a cell to open that day’s focused Qur’an check-in, scrolled to that row.

Home also lists **Qur’an to learn & practice**: a skimmable repository of widely used verses for daily reading and memorization (Al-Fātiḥah, openings of often-recited surahs, Āyat al-Kursī, the close of Al-Baqarah, short prayer surahs, and worship duas), with Arabic (person-chosen script face and size), transliteration, translation, citation pages, and a private register (Learning, Learnt, Practicing, Habit). Opening a Qur’an citation may Play recitation from a public audio file in this app so playback is not the page’s WebView player. It is not a khushu’ score, recitation streak, hifz programme, or Knowledge residual.

**30-day and 90-day Progress** keep one calendar per daily duration row, titled with the same bands and observational purpose.

Application Reflection records reflection on possible practical relevance only. It is not evidence of action, implementation, obedience, compliance, successful application, or completion of a Response.

### 4.3 Hadith & Living Sunnah

Core question (orientation only; not scored and not a spiritual grade):

**Did a teaching of the Prophet ﷺ reach my day?**

Place this domain immediately after Qur’an Engagement on Home, check-in, and Review. Storage id stays `hadith`. Include it on the Salah, Qur’an & Dhikr preset.

Four observational rows under one **ENGAGED with Hadith** wash. Older eight-row keys stay stored and are not migrated.

1. **Read and/or Listened** (`hadith.encounter`) — same duration list as Qur’an Engagement
2. **Memorization/Revision** (`hadith.retention`) — same duration list
3. **Study Circle/Discussion** (`hadith.learning`) — same duration list
4. **Lived /Noticed others** (`hadith.livedNoticed`) — started living a new Hadith; introduced living a hadith in family; corrected a practice as per hadith; observed living a hadith by other; recorded as not engaged; not answered

Duration rows twin Qur’an sitting marks (including 3–5 minutes as an empty light-green circle when activity colours are on). Lived / Noticed is one observation, not a revival programme. Unanswered is not a failed revival.

Home and **7-day Progress** show those items as rows and weekdays as columns (same orientation as Dhikr and Akhlaq). 30-day and 90-day stay one calendar per row. **Hadith to learn & practice** is a collapsed Home wash (same shape as listed actions): previous/next through a built-in catalog of daily-practice hadith and related supplications, + add Hadith copies the shown item into a private register (date added, source, content, topic, Learning / Learnt / Practicing / Living it, select and delete). A catalog item already in the register is shown with a different wash and cannot be added again. This is not a checklist, score, or revival programme, and it does not fill Living Sunnah.

Do not:

- Title the domain as a revival campaign
- Add a sunnah checklist, revival score, or streak
- Auto-fill Living Sunnah from Character & Morals
- Treat this card as a second Qur’an log

These traces do not increase `recordableFieldCount`.

### 4.4 Dhikr & Dua

Core question (orientation only; not scored and not a spiritual grade):

**Did I remember Allah outside of prayer?**

Retain factual recording for existing Dhikr rows (post-fard adhkar, morning and evening, other remembrance). Post-fard rows (Fajr, Dhuhr, Asr, Maghrib, Isha) use one remembrance list: Remembrance with action (beneficial response in behaviour; same blue as congregation on time when activity colours are on), Attentive remembrance, Intentional remembrance, Brief remembrance, Not today, and Unanswered. How attentive was I is an optional second dropdown (Reflected on the meaning, Aware of what I was saying, Mostly habitual recitation) — provenance, not a khushu’ score. Morning, evening, and other remembrance keep their own rows. Home and 7-day Progress show those items as rows and weekdays as columns (same orientation as Akhlaq): one week of columns, stacked Home bands, and the day-of-month only under each weekday letter. Do not score remembrance. Unanswered is empty, not missed.

### 4.5 Character & Morals (Akhlaq)

Core question (orientation only; not scored and not a spiritual grade):

**Did my behavior today invite people toward goodness?**

Record self-focused observations only, with item-specific wording on each of the 15 Home rows (four sections: Virtues I noticed; Anger, honesty, forgiveness; Modesty; Restraint). Each row stores one of: virtue demonstrated (`practised`), attempted with difficulty (`struggled`), shortcoming recognised (`lapse_recognised`), corrective action after a lapse (`corrected`), no relevant situation (`no_situation`), or unanswered. Corrective action is not equated with avoiding the original lapse. Optional follow-ups on a recorded row: where it happened, what helped or could help next time, and a private struggle note about oneself only. These are provenance, not causes or a character grade. When activity colours are on, `practised` uses the same blue as congregation on time; the remaining codes twin the other Salah activity colours. Unanswered is empty, not a relapse.

Do not:

- Let the user rate themselves as a good or bad person
- Create a character score or personality grade
- Suggest perfection is expected
- Allow logging someone else’s flaw
- Present the domain as a performance review
- Treat patience as only silence; it may also be firmness
- Name vices, keep a days-clean streak, or infer unanswered as a relapse or a sin
- Auto-fill from Gratitude Dhikr or Knowledge’s held-back speech

Unanswered is not a failing. Marks name the recorded observation, not a moral verdict. Check-in and Quick tap always name the row in the selected phrase so the closed dropdown cannot be read against the band title alone. The habit on the self-control row is not named in the app. Optional struggle notes are text and do not count toward `recordableFieldCount`. Older `akhlaq.guardedMyGlance` marks stay stored and still appear on Historical Reflection. Older ternary days (`I noticed this in myself` / `I did not notice this today`) still read; they canonicalise to `practised` and `no_situation` until edited.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names (Patience, Guarded my gaze, and so on).

### 4.6 Rights of Others (Huquq al-Ibad)

Core question (orientation only; not scored and not a spiritual grade):

**Did I fulfill, harm, or neglect anyone’s right over me?**

Record the user’s own obligations toward people Allah placed in their life, framed as investment, not a chore list. Immediate Family is the existing **Household** band. Each of the 15 Home rows uses item-specific wording for one of: appropriate positive action (`practised`), effort not fully completed (`partial_effort`), possible shortcoming or neglected right recognised (`neglect_recognised`), repair or corrective step (`corrective_action`), no applicable situation (`no_situation`), or unanswered. Default is unanswered. Corrective action is not equated with the original positive action. Optional follow-ups on a recorded row: nature of engagement, outcome observed, quantity (occasions and approximate time), and a private reflection about one’s own conduct only. These are provenance, not scores or causes. When activity colours are on, `practised` uses the same blue as congregation on time; the remaining codes twin the other Salah activity colours. Unanswered is empty, not neglect, and lack of daily contact is not neglect.

- Household (Immediate Family): parents, spouse, children, siblings, grandparents
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
- Interpret lack of daily contact as neglect
- Automatically classify a reported shortcoming as a religious violation
- Treat all rights as equal in obligation or urgency
- Score spiritual merit, sincerity, or divine acceptance
- Pressure users to reconcile where doing so would be unsafe or inappropriate

Unanswered is not neglect. Marks name the recorded observation, not a grade of a relationship or a religious verdict. The selected check-in phrase names the row (for example “Honoured my parents through care, respect, contact or du‘a — Parents”). Reconciliation and turning back are optional observations. The app does not prescribe tawbah or sulh, does not complete them, and does not pressure reconciliation where it would be unsafe or inappropriate. Review reports observed actions, identified responsibilities, and corrective steps without moral rankings. Care in hardship (sick visit, sick contact, support under stress) is a right of brotherhood on this domain, not a sadaqah channel. These traces do not increase `recordableFieldCount`. Older ternary days (`I attended to a right I owe` / `I neglected a right I owe`) still read; they canonicalise to `practised` and `neglect_recognised` until edited.

Home also lists **Rights of Others Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). It is not a relationship score, chore list, or daily grade.

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

Unanswered is not ignorance. Each of the seven Home rows has six item-specific observations (beneficial activity, partial engagement, a recognised gap, a correction, no relevant situation, unanswered). Optional type, source, verification, understanding, application, quantity, and private reflection are provenance only: they never grade knowledge, treat reading or AI-assisted learning as verified, or duplicate Qur’an, Hadith, or Akhlaq. These traces do not increase `recordableFieldCount`.

Home also lists **Knowledge & Beneficial Speech Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). It stays residual of Qur’an, Hadith, and Akhlaq tone. It is not a learnedness grade, study-hour badge, or daily grade.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names (Learned something true, Held back useless speech, and so on).

### 4.8 Time & Barakah

Core question (orientation only; not scored and not a spiritual grade):

**Did I treat my time as a trust from Allah?**

Record eight independent observations in daily-life order (intention → attention → action → balance). They are not eight compulsory daily achievements, and no practice is treated as more spiritually valuable than another:

- Intention & Priority (`time_intention`): began with a worthwhile intention (`time.t01` / `time_t01`); chose what mattered first (`time.t02`)
- Attention & Presence (`time_attention`): gave focused attention (`time.t03`); put aside a digital distraction (`time.t04`)
- Responsibility & Action (`time_action`): took a step on something delayed (`time.t05`); used time for something beneficial (`time.t06`)
- Balance & Renewal (`time_balance`): gave someone needed attention (`time.t07`); took needed rest (`time.t08`)

Each of the eight Home rows has six item-specific observations (`acted`, `partial_effort`, `lapse_recognised`, `corrected`, `no_situation`, unanswered/`null`). These are descriptive categories, not a numerical scale. Do not assume `corrected` is spiritually better or worse than `acted`. Optional activity context, challenge, what helped, observable outcome, quantity, and private reflection are provenance only: they never score barakah, rank a busy day as beneficial, treat rest as wasted time, auto-classify recreation as waste, or penalise illness, disability, caregiving, recovery, or unavoidable interruptions. A first tap is enough; secondary fields are never required to save. Unanswered is distinct from an explicit outcome. These traces do not increase `recordableFieldCount`. Older four-choice days (`acted` / `noticedNotActed` / `noSituation`) still read; they canonicalise to `acted`, `lapse_recognised`, and `no_situation` until edited.

The fard stays on Salah. Sleep stays on Physical Health. Do not auto-fill Time from Salah or Health. Record what the user reports. Do not infer intention, sincerity, laziness, psychological health, divine reward, or barakah.

Do not:

- Track hours or treat clocked time as a badge
- Create a productivity score, streak penalty, or hustle rank
- Shame an unanswered day as wasted
- Congratulate the user for being productive
- Prescribe a daily schedule
- Treat rest as failure
- Record a second prayer-window log on this domain

Unanswered is not wasted time. These traces do not increase `recordableFieldCount`. Pre-launch Presence / Trust / Rest keys (`time.presentInWhatIWasDoing`, `time.didWhatIDelayed`, `time.steppedAwayFromIdleTime`, `time.restedAsNeeded`, `time.beganWithIntention`, `time.guardedPrayerWindow`) are retired: leftover development values may remain in local Hive until that day is overwritten; they are not migrated and are not shown on Home, check-in, Review, or Historical Reflection. Unrelated domain records are left intact. DailyCheckIn schema remains **6** (`homeTraces` plus `activities` for the primary value; optional context/outcome/note in `homeTraceFactors` for that storage key).

Home also lists **Time & Barakah Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). The eight practices remain independent observations, not eight daily achievements. It is not a productivity score, schedule, streak, or estimate of barakah.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names. Weekly review may count recorded observations and selected outcomes; it must not generate scores or claims of barakah.

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

Each of the eight Home rows has item-specific observations (care taken, partial or mixed care, difficulty noticed, avoidable neglect, an adjustment, circumstances beyond control, no relevant need where that applies, prefer not to record, and unanswered/`null`). Prefer not to record is an explicit privacy choice, distinct from unanswered. These are descriptive categories, not a fitness, calorie, sleep-hour, or spiritual scale. Sleeping poorly is not classified as failure. Seeking care is not interpreted as better health than having no illness. A first tap is enough. Free-text plans stay on listed Actions, not on these rows. Unanswered is distinct from an explicit outcome. These traces do not increase `recordableFieldCount`. DailyCheckIn schema remains **6**.

Home also lists **Physical Health & Energy Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). It is not a fitness programme, calorie log, or body grade.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names.

### 4.10 Wealth & Stewardship

Core question (orientation only; not scored and not a spiritual grade):

**Did I manage earning, spending and wealth as trusts from Allah?**

Record self-focused stewardship of wealth as a trust, not net worth:

- Earning (`wealth.halalEarning`, `wealth.avoidedRiba`): earned from a halal source; stayed clear of riba
- Restraint (`wealth.avoidedWaste`): avoided waste
- Lawful wealth management (`wealth.lawfulManagement`): managed wealth responsibly and lawfully

Each Home row has item-specific observations (reported action, check or clarification, unresolved concern, no relevant activity, prefer not to record, and unanswered/`null`). Prefer not to record is an explicit privacy choice, distinct from unanswered. No relevant activity is not a failure. Unresolved concern is not a legal or scholarly ruling. A first tap is enough. Free-text plans stay on listed Actions, not on these rows. These traces do not increase `recordableFieldCount`. DailyCheckIn schema remains **6**.

Giving (sadaqah, family support, community and care channels) and zakat due / planned / paid stay on Charity, without amounts. A smile is sadaqah. Giving rows formerly on Wealth are not shown on Home, check-in, or Progress; stored `wealth.*` giving marks are kept for Historical Reflection.

Do not:

- Track net worth, balances, or savings as a spiritual metric
- Store bank details, creditor identities, or account numbers
- Show charity leaderboards or “most generous” badges
- Require amounts
- Shame poverty or debt
- Treat wealth as a sign of Allah’s pleasure
- Auto-certify a source as ḥalāl
- Ignore that some people cannot give money
- Duplicate Charity giving or zakat on this domain

Unanswered is not a failing of provision.

Home also lists **Wealth & Stewardship Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). Giving stays on Charity. It is not a money score, net-worth tracker, or zakat calculator.

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

Each of the six Home rows has item-specific observations (reported action, remote or spoken effort, an opportunity noticed without the wished action, no relevant opportunity where that applies, prefer not to record, and unanswered/`null`). Prefer not to record is an explicit privacy choice, distinct from unanswered. No relevant opportunity is not neglect. Remote masjid participation is not recorded as physical attendance. Du’a for the oppressed is distinct from practical help. “Did not recall” dua is not a moral verdict. A first tap is enough. Free-text plans stay on listed Actions. These traces do not increase `recordableFieldCount`. DailyCheckIn schema remains **6**.

Older generic noticed / not-noticed days are not rewritten into a specific new choice. Until that day is edited, the picker shows Unanswered rather than assuming attendance or neglect.

Home also lists **Ummah Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). The fard stays on Salah; neighbour and giving stay on Rights of Others and Charity. It is not a public check-in, political log, or ethnic list.

Home and **7-day Progress** show those items as rows and weekdays as columns. **30-day and 90-day Progress** keep one calendar per row, titled with the same Home names.

### 4.12 Fasting

Core question (orientation only; not scored and not a spiritual grade): noticing of voluntary and make-up fasts, not a Ramadan fard tracker.

Home rows: Weekly Sunnah Fast; White Days (Ayyam Al-Bid); Make-up Fast; Ramadan Preparation.

Do not prescribe a fast, treat unanswered as missed, encourage extreme fasting outside Ramadan, or treat Progress highlighting of civil Hijri 13–15 as a record.

Home also lists **Fasting Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). It is not a sawm score, countdown, or prescription.

### 4.13 Hajj

Hajj is a standing status the person sets. Daily Home noticing is **Noticed preparation** while due or preparing. The app does not calculate istita‘ah or set a year.

Home also lists **Hajj Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). It is not a due-date, countdown, or trophy. Umrah is not this status.

### 4.14 Charity

Record giving and care without amounts. Presentation order places Charity immediately after Rights of Others and before Knowledge & Beneficial Speech. Stored domain ids and mix selections are not rewritten.

Each of the six Home rows has item-specific observations (reported gift or support, intended or arranged effort, a recognised need without the wished action, no relevant opportunity or need, prefer not to record, and not recorded/`null`). Prefer not to record is an explicit privacy choice, distinct from not recorded. No relevant opportunity is not withheld charity. A first tap is enough. Amounts, recipient names, and financial circumstances are not collected. Ordinary household nafaqa stays on Rights of Others. A smile is sadaqah.

Zakat remains a separate standing daily status (`due`, `planned`, `paid`, `notApplicable`, plus `reviewing` and `preferNot`). Labels name those states; the app does not calculate zakat, infer liability, or treat daily nonpayment as a missed obligation. Older `due` / `planned` / `paid` / `notApplicable` / `unanswered` names still read. These traces do not increase `recordableFieldCount`. DailyCheckIn schema remains **6**.

Older generic noticed / not-noticed days are not rewritten into a specific new choice. Until that day is edited, the picker shows Not recorded rather than assuming a gift.

Home also lists **Charity Learn & Practice**: Qur’an verses and authentic hadith grouped as on Home, collapsed to title, with citation pages and a private register (Learning, Learnt, Practicing, Habit). It is not a generosity score or leaderboard.

### 4.15 Other established domains

If present in an existing implementation, retain factual recording for domains such as:

- gratitude
- personal reflection

Do not remove valid established domains merely because Progress emphasizes Salah and Qur’an.

### 4.16 Persistence boundary

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
- tapping a saved day opens a compact, read-only day view grouped by domain washes for the domains and mix currently in focus; unselected mix rows stay stored and can still be edited in Manage past check-ins
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
- Practical relevance (`consciousApplication`)

Application Reflection is Settings / About only. It is not a recurring Home, 7-day, 30-day, or 90-day calendar.

Use stable subdued accent colours with equal semantic weight for card washes. An outlined line mark names the domain (mosque, open mushaf, stacked books, beads, growth, handshake, lamp, clock, pulse, scale, globe, crescent, Kaaba, open hands). Colour still names the domain; the mark is identity, not a score. Recorded-state marks share one colour; shape encodes the recorded state.

Recommended presentation:

- 7D: mix-filtered stored-dimension week (same bands and rows as Home); tap a cell to open that row’s check-in
- 30D: compact weekly calendar per stored dimension, titled as check-in bands
- 90D: one full-width weekly calendar for the last 90 days (today’s week rightmost), with month labels, two alternating shades of the domain colour on day cells only, a pale yellow halo on today’s mark, and period arrows to move to earlier or later 90-day windows; titles match check-in bands

For the neutral peer dimensions, display factual counts such as `Recorded on X of Y days` and positive activity-day counts.

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
