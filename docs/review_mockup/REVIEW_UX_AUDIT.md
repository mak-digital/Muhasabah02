# Review UX audit (Phase R0)

Status: design only. Production Flutter is unchanged.

## Surfaces inspected

- `lib/presentation/review/review_screen.dart` — Review tab
- `lib/presentation/home/home_screen.dart` — `AppShell` four-item `NavigationBar`
- `lib/presentation/history/history_screen.dart` — History tab
- `lib/presentation/response/response_list_screen.dart` — My Response tab
- `lib/presentation/recorded_days/recorded_days_screen.dart` — Historical Reflection (Look closer)
- `lib/presentation/recognition/recognition_screen.dart` — Recognition (30/90 only)
- `lib/presentation/progress/salah_progress_screen.dart` and `optional_domain_progress_screen.dart`
- `lib/domain/analytics.dart`, `review_period.dart`, `recognition.dart`
- `lib/domain/daily_check_in.dart` (Hive schema v6)
- `docs/PRODUCT_SPEC.md` §§6–8, `docs/product_guardrails.md`

Owner screenshots of the current Review page (red-marked) were used as visual reference: large period hero, date-range line, dense mosaic of domain cards that only link to Progress, then Look closer / Recognition / Ponder stacked below.

## Current information architecture

Bottom navigation today: **Home | Review | History | My Response**.

Review is a long vertical stack:

1. Guard copy (`Copy.reviewGuard`).
2. Period selector (7 / 30 / 90) and actual date range.
3. Period hero: days recorded vs days in window, plus two large share cards (Salah on-time among recorded; Qur’an reading among recorded).
4. Domain mosaic: one card per visible domain. Each card is a short coverage sentence plus a Progress chevron. Tapping opens Salah Progress or Optional Domain Progress — not an infographic on Review itself.
5. Look closer → Recorded Days (read-only week grids for the period; empty cells shown; day evidence; add response).
6. Recognition → pattern list (blocked on 7-day; coverage + subjects on 30/90).
7. Ponder → `narrativeCopy(PeriodNarrative)` from `analytics.dart` (Salah share vs prior window; 90-day uses three 30-day blocks).
8. Also recorded: situations, gratitude/reflection counts, Hajj standing pointer, Productivity pointer.
9. Add a response (period provenance).

History is a **different** job: all saved check-ins (or 30/90 filter), week groups, **edit** (`CheckInScreen(date:)`), **remove with confirm**. Empty days are omitted.

Recorded Days is **not** History: it shows every civil day in the Review window, marks presence vs absence, and is read-only (day evidence). Editing is not on that screen.

My Response is an independent `PersonalResponse` list (active / archived, editor, provenance). It is not a day’s check-in.

## Unique functions that must be preserved

These are not redundant even if the current layout is weak:

| Function | Why it is unique |
|---|---|
| 7 / 30 / 90 period + prior comparable window | Shared by Review, Recorded Days, Recognition, analytics adequacy |
| `salahShare` / `readingShare` with **recorded-only denominator** | Unanswered never becomes missed |
| Adequacy gates (`hasAdequacy`: 4/7, 15/30; 90-day uses block classification, not 7/30 delta) | Prevents fake trends |
| Per-domain Progress screens | Date-level lists, filters, Hajj/Productivity special cases |
| Recorded Days / day evidence | Empty-as-empty calendar; read-only inspection |
| RecognitionEngine | 30/90 pattern language, not a score |
| Period narrative copy | Descriptive, “among recorded observations” |
| History edit-in-place | Same `dateKey` document; no duplicate insert |
| History remove + confirm | Destructive, must stay explicit |
| History All-time filter | Review windows cannot replace “every saved day” |
| My Response store | Separate Hive; provenance; archive |
| Add response from Review / Recorded Days | Provenance attachment |
| Situation / gratitude / reflection counts | Presence only; **never print private text** |
| Hajj standing pointer | Hajj stays on its own dashboard (dormancy unchanged) |
| Productivity pointer | Productivity development must not be interrupted |
| Personalisation / visible domains | Mosaic already respects mix |

## Current UI weaknesses (including red-marked areas)

1. **Period hero is oversized** relative to what it teaches. Days-recorded vs days-in-window is useful; two large percentage-like share cards repeat what domain tiles already say and read like grades even with “missing excluded” footnotes.
2. **Domain mosaic is not visual.** Cards are prose + Progress links. There is no domain-specific chart, no distinction of “no check-in” vs “explicitly recorded non-participation” on Review itself.
3. **Same card pattern for every domain.** Fasting, Charity, Ummah, and Salah are presented as “N days with a mark / period days”, which invites daily-fasting and merit-percentage readings.
4. **Four-tab navigation splits one job.** Review (trends) vs History (mutate records) vs Recorded Days (empty-aware calendar) vs My Response (notes) is coherent in data, but users must leave Review to correct a day they just noticed.
5. **Look closer / Recognition / Ponder are stacked destinations**, not progressive disclosure on the dashboard. Ponder is Salah-centric even when other domains have more marks.
6. **No interactive date on Review.** Selecting a day lives on History or Recorded Days.
7. **Progress screens are the only place** for category breakdown; they are full-page, not expandable cards.
8. **Recognition is invisible on 7-day** except as an explanation — easy to read as “the app has nothing to say about you this week.”
9. **Also recorded** dumps leftover counts after the mosaic, so gratitude/reflection/Hajj/Productivity feel like afterthoughts.

## What is already sound (do not discard)

- Guard language: record ≠ ruling; unanswered ≠ missed.
- Share math excludes unanswered.
- History edit opens the existing `DailyCheckIn` for that `dateKey`.
- Recorded Days shows empty cells.
- Responses never log private body text in analytics.
- Domain colour washes already exist (`MuhasabahColors`).
- Period keys are civil `YYYY-MM-DD` via `periodDateKeys`.

## Navigation proposal (evaluation, not a production change)

**Home | Review** can work if:

- Home keeps daily recording, week grids, Quick tap, Hajj/Productivity entry.
- Review hosts the calendar/timeline, View/Edit record, domain expand, and a Response list entry.
- History All-time remains reachable (filter on the in-Review calendar, or a “All saved days” control).
- Routes `/history` and Response screens stay until the new nav is approved and tested.

Trade-off: losing a dedicated History tab makes All-time plus remove slightly less discoverable. Mitigation: keep an explicit “All saved days” mode and keep confirm-remove on the day sheet.

Do **not** remove IndexedStack destinations in this phase.
