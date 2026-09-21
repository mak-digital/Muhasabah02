# Qur’an card — final refinement package (review only)

**Historical / proposal only.** Labels such as Applied / Transformation in this file are not current product copy. Current Journey groups are Practical relevance, Reflection, Understanding, and Engagement. See `docs/accepted_product_state.md`.

**Status:** mockups and product proposals only. Application code was not changed. Dhikr, Family, Charity, Fasting, and Hadith Home cards remain out of scope.

Authority read: `docs/accepted_product_state.md`, `docs/PRODUCT_SPEC.md`, `docs/product_guardrails.md`, `docs/AGENTS.md`, `docs/AUTONOMOUS_BUILD_PROMPT.md`.

Open the card: `docs/visual_review/quran_card.html` (revision 2).

Stop here until this package is approved. Do not implement until then.

---

## 1. Dependency matrix

Layer 1 states: **Recorded engagement** · **Recorded as not done** · **Unanswered**. Unanswered is never treated as missed.

### 1.1 Legend for cells

| Mark | Meaning |
| --- | --- |
| **Auto (pending this approval)** | If the source cell is Recorded engagement, the target cell on the **same date** becomes Recorded engagement. This is the only automatic write proposed. |
| Propose — do not auto | A logical relationship worth discussing. **Do not implement** unless explicitly approved. |
| Independent | No write from one row to another. Distinctions stay meaningful. |
| Contradiction blocked | Combination must not remain saved. Prefer blocking or explaining, not silent invention of “missed”. |

### 1.2 Same-day matrix (source → target)

Rows are the dimension the user just set. Columns are other dimensions on that date.

| If this is Recorded engagement → | Recitation | Recitation with Meaning | Memorisation | Revision | Tafsir | Qur’anic Reflection | Conscious Application |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Recitation | — | Independent | Independent | Independent | Independent | Independent | Independent |
| Recitation with Meaning | **Auto (implemented)** | — | Independent | Independent | Independent | Independent | Independent | Independent |
| Memorisation | Independent | Independent | — | Independent | Independent | Independent | Independent |
| Revision | Independent | Independent | Independent | — | Independent | Independent | Independent |
| Tafsir | Independent | Independent | Independent | Independent | — | Independent | Independent |
| Qur’anic Reflection | Independent | Independent | Independent | Independent | Independent | — | Independent |
| Conscious Application | Independent | Independent | Independent | Independent | Independent | Independent | — |

Application Reflection is **not** in this matrix. It is not a tracked daily dimension.

### 1.3 Approved-to-propose rule (minimum)

**If Recitation with Meaning = Recorded engagement, then Recitation = Recorded engagement on the same date.**

Rationale: meaningful recitation includes recitation. A day must not show Recitation as unanswered or recorded as not done while Recitation with Meaning shows engagement.

When the user records Recitation with Meaning as engagement:

1. Recitation on that date is written to Recorded engagement if it was unanswered or recorded as not done.
2. Existing Recitation recorded factors are left unchanged.
3. Recitation Layer 1 is not scored and is not marked missed.
4. The user can still open Recitation and see it as recorded engagement (visible, not hidden).

**Reverse is not automatic.** Recitation = Recorded engagement does **not** set Recitation with Meaning. Reciting without attending to meaning remains a valid distinction.

### 1.4 Contradiction handling (propose — do not auto until approved)

| Attempt | Proposed behaviour |
| --- | --- |
| Set Meaning = engagement while Recitation is unanswered or not done | Apply the approved fill: Recitation becomes engagement. |
| Set Recitation = not done while Meaning is already engagement | **Block** with a short notice: Recitation with Meaning is already recorded as engagement today. Do not invent missed. Offer to change Meaning first. |
| Set Recitation = unanswered while Meaning is engagement | **Block** the same way. Unanswered must not reappear under an engagement Meaning cell. |
| Set Meaning = not done | Recitation **unchanged**. Reciting without meaning is allowed. |
| Set Meaning = unanswered | Recitation **unchanged**. Do not clear Recitation. |

### 1.5 Other relationships reviewed — **not** automatic

| Relationship | Verdict | Why |
| --- | --- | --- |
| Recitation → Recitation with Meaning | Independent | Recitation without meaning is a real distinction. |
| Memorisation ↔ Revision | Independent | Revising memorised Qur’an does not require a memorisation session that day, and practising memorisation does not imply revision. |
| Tafsir → Recitation with Meaning | Independent | Formal explanation study is not the same observation as reciting with meaning. Do not collapse them. |
| Tafsir → Qur’anic Reflection | Independent | Studying tafsir may prompt reflection, but recording tafsir must not invent Qur’anic Reflection. |
| Qur’anic Reflection → Recitation | Independent | Contemplating a known ayah does not require recitation recorded today. |
| Qur’anic Reflection → Conscious Application | Independent | Noticing verses/lessons is not the same as noticing possible practical relevance. |
| Conscious Application → any recitation/retention/study row | Independent | Conscious Application is not evidence of recitation, study, action, or Response completion. |
| Any Home row → Application Reflection | Forbidden | Application Reflection is Settings → About only. |
| Recorded as not done on A → recorded as not done on B | Never auto | That would treat unanswered/not-done as missed-by-implication. |
| Unanswered on A → unanswered on B | Never auto | Missing stays missing. |

No other automatic dependency is requested in this package.

---

## 2. Terminology map

Replace standalone **Reflection** (Qur’an dimension) with **Qur’anic Reflection** everywhere a person can see or search it.

| Term | Meaning | Where it lives | Must never be labelled as |
| --- | --- | --- | --- |
| **Qur’anic Reflection** | Reflection on verses, meanings, tafsir, lessons noticed and contemplated. Daily Home / Progress / check-in / evidence / Recognition subject. | Qur’an card row; check-in; Qur’an Progress; day evidence; History field labels; Recognition `subject`; docs | Application Reflection; Personal reflection; “App Reflection” |
| **Application Reflection** | First-install acknowledgement and About copy. Reflection on possible practical relevance **as product framing**, not a recurring tracked domain. Not evidence of action, obedience, implementation, or Response completion. | Settings → About Muhasabah; first-install intro only | Qur’anic Reflection; Conscious Application; a Home row; a Progress row; a check-in field |
| **Conscious Application** | Daily observation that you noticed a possible practical relevance. Not proof of doing it. | Qur’an card Study and notice row | Application Reflection; implementation; completed Response |
| **Personal reflection** | Optional private journal-style field on the daily check-in (existing `personalReflection`). | Check-in; History; day evidence | Qur’anic Reflection; Application Reflection |
| **Historical Reflection** | Read-only recorded-days surface. | Review → Recorded days | Qur’anic Reflection |
| **App Reflection** | Do not use this phrase in UI or docs. | — | — |

### 2.1 Proposed display labels (after approval)

| Data key (keep stable unless a later schema task says otherwise) | UI label |
| --- | --- |
| `reading` | Recitation |
| `meaning` | Recitation with Meaning |
| `memorisation` | Memorisation |
| `revision` | Revision |
| `tafsir` | Tafsir |
| `reflection` | Qur’anic Reflection |
| `applicationReflection` | Not shown on Home, Progress, check-in, or Recognition. About page only. |

Recognition identity may keep `subject: reflection` internally if that avoids a schema bump; the **visible** factor and pattern copy must say Qur’anic Reflection.

---

## 3. Card structure (unchanged grouping)

**Recitation**

- Recitation
- Recitation with Meaning

**Retention**

- Memorisation
- Revision

**Study and notice**

- Tafsir
- Qur’anic Reflection
- Conscious Application

Preserved from the Salah model: previous week, next week, This week, first day of week, clickable cells, 14px marks, Qur’an colour family, no scores / ranks / streaks.

---

## 4. Layer 1 — What happened?

Same three states as the current Qur’an proposal, mapped to the Salah marker system without introducing a fourth Qur’an-only mark:

| Layer 1 | Marker | Salah analogue | Guardrail |
| --- | --- | --- | --- |
| Recorded engagement | Filled | On time / performed | Visibility, not judgment |
| Recorded as not done | Outline | Late / not performed | Explicit record, not inferred |
| Unanswered | Dotted | Unanswered | Missing ≠ missed |

Missed slash remains Salah fard-only.

Layer 1 never completes a Response and never writes Application Reflection.

---

## 5. Layer 2 — Factors you noticed

**UI title:** Factors you noticed  
**Secondary phrase:** Recorded factors  
**Do not use:** Contributing factors; causes; reasons; risk factors.

These are things the user **noticed**. They are provenance for later review and Recognition. They are not causes, scores, or recommendations.

- Optional. Skipping changes nothing about Layer 1 or check-in completeness.
- Copy: “You recorded…” / “You noticed…” — never “this caused”, “because”, “led to”, “you should”.
- Structured IDs + optional Other text. Other is still not a cause.
- Eligible on every Qur’an Home row including Recitation and Conscious Application.
- Not eligible on Application Reflection (that surface has no daily record).

### 5.1 Support (noticed)

Time available · Quiet space · Reminder or cue · Translation available · Tafsir available · Community programme · Study circle · Teacher guidance · Family participation · Friend participation · Existing routine · Dedicated study session · Travel opportunity · Other

### 5.2 Challenge (noticed)

Limited time · Fatigue · Work commitments · Family commitments · Travel · Health · Social media distraction · Device distraction · Lack of routine · Competing priorities · Unexpected interruption · Other

Prefixed IDs at implementation time (e.g. `quran.timeAvailable`) so they do not collide with Salah factor IDs.

---

## 6. Example day-record flow

Date: Thursday 27 Aug. First day of week = Monday.

1. User opens Home → Qur’an → cell **Recitation with Meaning** for 27 Aug.
2. Layer 1: selects **Recorded engagement**.
3. Recitation for 27 Aug was unanswered. The approved dependency writes Recitation = Recorded engagement. Both cells show filled. Neither is missed.
4. Layer 2: user may skip. They pick **Translation available** and **Quiet space** under Factors you noticed. Copy: “You recorded quiet space. You recorded translation available.”
5. They do not open Tafsir or Qur’anic Reflection. Those stay unanswered (dotted). Not missed. Not inferred from Meaning.
6. Conscious Application stays unanswered. Not treated as implementation.
7. SEE → evidence for that date; PONDER remains the static Qur’an prompt; EXPLORE → optional Response with provenance to this cell — never a completion tick.

Valid contrast the next day: Recitation = engagement, Recitation with Meaning = unanswered. No auto-fill of Meaning.

---

## 7. Example Recognition wording (PROVENANCE ≠ CAUSALITY)

Allowed (descriptive, inspectable dates):

> Context was recorded for 8 of 12 observations where you recorded Recitation with Meaning as not done.
>
> Among those 8 observations, “Limited time” appeared on 5.
>
> You recorded “Limited time” on these dates: 3 Aug, 10 Aug, 12 Aug, 19 Aug, 24 Aug.

Allowed for a support factor:

> You recorded “Study circle” on 4 of 6 observations where Qur’anic Reflection was recorded as engagement.

Prohibited:

- Limited time caused you not to engage with meaning.
- Fatigue is linked to weaker recitation.
- Because you recorded travel, you should revise more.
- Application Reflection shows you applied the Qur’an.
- Qur’anic Reflection improved your iman.

Recognition still: 30D/90D only; no 7-day Recognition; no scores; supporting dates remain openable.
