# Remediation audit — before Enhancement 5 (dashboard revision)

**Status:** visual review only. Application code was not changed. Working RECORD / REVIEW / Recognition / Response behaviour is left as-is until this package is approved.

Authority read: `docs/accepted_product_state.md`, `docs/PRODUCT_SPEC.md`, `docs/product_guardrails.md`, `docs/AGENTS.md`, `docs/AUTONOMOUS_BUILD_PROMPT.md`.

Open mockups: `docs/visual_review/remediation.html` (mobile width ~390px).

---

## 1. Defect audit

### Issue 1 — Domain activity catalogs

**Finding:** Source catalogs in `lib/domain/activities.dart` are **not** copies of the Salah list. Check-in already passes `ActivityCatalog.dhikr`, `.family`, `.charity`, and `.fasting` independently.

**What is still wrong**

- Labels do not match the approved domain lists (missing items such as Family remembrance, Checked on family member, Food support, Voluntary fast completed / partially completed).
- Shared IDs (`unanswered`, `noActivity`, `other`, and `familySupport` on both Family and Charity) make domains look interchangeable and collide in Recognition/analytics keys.
- Salah **mixes status into activity chips** (`Prayed alone on time`, `Prayed late`, `Missed`). The intended model is status first (on time / late / missed / unanswered), then optional factors — not salah-shaped chips reused as “activities” elsewhere.
- Check-in presents every domain as the same ChoiceChip wrap, so even distinct catalogs feel like one Salah-style picker.

**Guardrail:** no domain may reuse Salah activities. After approval, each catalog must have domain-prefixed IDs.

### Issue 2 — Second-level factor model

**Finding:** Optional contributing factors exist only as Qur’an `RecordedContext` (`lib/domain/recorded_context.dart`, `lib/domain/context_catalog.dart`). Eligibility is limited to Meaning / Memorisation / Revision (positive and negative) and Tafsir / Reflection (positive only). Application Reflection has no context (spec V1).

**Gaps**

- No factor capture for Salah, Dhikr, Family, Charity, Fasting, Gratitude, Conduct, or personal Reflection.
- `ContextCatalog` is one generic positive/negative list, not the domain examples (slept early, overslept, work commitment, …).
- `RecognitionEngine` only iterates Qur’an peer dimensions (`domain = 'quran'`). Factors on other domains cannot surface in Recognition today.
- PRODUCT_SPEC §5 remains authoritative for Qur’an prompts; extending factors to other domains must stay optional, unanswered-allowed, non-scoring, non-prescriptive, and **PROVENANCE ≠ CAUSALITY**.

**History:** schema v6 still stores `contexts` as Qur’an-subject keyed documents. Restoration should extend that structure (or a parallel `factors` map keyed by domain/subject) without turning unanswered into missed.

### Issue 3 — Settings UX

**Finding:** `SettingsScreen` is a flat `ListTile` list (About, then recreate/remove/restore sample data). No section headers, icons, cards, Account & Data, Application, or Privacy grouping.

### Issue 4 — Home dashboard (not to implement yet)

**Finding:** Home already ships **textual** domain cards (`recentLine` / `periodLine` / `unansweredLine`). Enhancement 5 revision requires compact **7-day visual grids** (Salah: prayer rows × weekday columns; equivalent for Qur’an, Dhikr, Family, Charity, Fasting, Hadith). Cells must open evidence / reflection / response. Current Home must not be rewritten until these mockups are approved.

PRODUCT_SPEC § Home still says keep Home simple and not a dense analytics dashboard. The proposed cards are compact traces, not scores.

---

## 2. Affected files (when implementation is approved)

No files below were edited in this pass.

| Area | Files |
| --- | --- |
| Catalogs | `lib/domain/activities.dart`, `test/domain/activities_test.dart`, `lib/debug/synthetic_check_ins.dart` |
| Factors | `lib/domain/context_catalog.dart` (or new `lib/domain/factor_catalog.dart`), `lib/domain/recorded_context.dart`, `lib/domain/daily_check_in.dart`, `lib/domain/recognition.dart`, `lib/presentation/checkin/check_in_screen.dart` |
| Settings | `lib/presentation/settings/settings_screen.dart` |
| Dashboard (later) | `lib/presentation/home/home_screen.dart`, `lib/presentation/home/dashboard_cards.dart`, `lib/domain/dashboard_summary.dart`, `test/widget/dashboard_home_test.dart` |
| Docs | `docs/accepted_product_state.md`, `docs/architecture.md` |

---

## 3. Proposed changes (not applied)

1. **Catalogs:** Replace Dhikr / Family / Charity / Fasting option labels with the lists in this package. Prefix IDs (`dhikr.morningAdhkar`, `family.contactedParents`, …). Keep unanswered and Other. Do not attach `PrayerStatus` to non-Salah options.
2. **Salah RECORD:** Status chips (on time / late / missed / unanswered) independent of optional factor chips. Activity-of-congregation can remain a separate optional note if still wanted, but must not replace status.
3. **Factors:** Optional positive / challenge catalogs per domain. Store structured IDs + optional free text. Never complete a check-in from factors. Recognition keys: `domain + subject + outcome + question + factorId`. Copy: “You recorded…” never “This caused…”.
4. **Settings:** Five Material 3 sections — Account & Data, Developer & Sample Data, Application, Privacy, About Muhasabah — with icons, cards, and the existing sample recreate/remove/restore actions moved under Developer.
5. **Home (Enhancement 5, later):** Replace paragraph summaries with compact 7-day marker grids; cell tap → evidence, then optional reflect/response. Colour = domain identity. Dotted = unanswered ≠ missed.

---

## 4. Visual review package

| Mockup | Location |
| --- | --- |
| Home dashboard (grid) | `remediation.html` #dashboard |
| Salah card | #salah-card |
| Qur’an card | #quran-card |
| Family card | #family-card |
| Cell click → paths | #click-behaviour |
| Factor capture | #factors |
| Settings | #settings |

Stop here. Do not implement until visual review is approved.

---

## Salah Home card (follow-up)

Salah-only mockups: `docs/visual_review/salah_card.html`.

Not coded. Other Home domain cards remain out of scope.

Agreed direction for Salah when approved: week controls on the card; rows Fajr–Isha plus Jumu‘ah, Tahajjud, Ishraq; Dhuhr kept on Friday; star inside the same 14px Dhuhr marker when Friday congregation was attended; Jumu‘ah Friday-only; Tahajjud/Ishraq performed / not performed / unanswered; optional two-layer factors with PROVENANCE ≠ CAUSALITY.

---

## Qur’an Home card (follow-up)

Qur’an-only review: `docs/visual_review/quran_card.html` (revision 2) and `docs/visual_review/quran_card_review.md`.

Not coded. Other Home domain cards remain out of scope.

Implemented: Recitation with Meaning → Recitation engagement auto-fill (same date); reverse contradiction blocked; all other Qur’an rows stay independent; UI label Qur’anic Reflection ≠ Application Reflection; Layer 2 = Factors you noticed (PROVENANCE ≠ CAUSALITY).

---

## Home shared symbols (follow-up)

Mockup: `docs/visual_review/home_symbols.html`.

Not coded. Remove persistent legends from all Home domain cards. One Home header control (ⓘ Symbols) opens a sheet with Salah, Qur’an, and general rules. Marker semantics, domain colour, and accessibility labels are unchanged.
