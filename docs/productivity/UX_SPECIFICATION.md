# Productivity — UX specification (P0)

**Status:** Phase P0 — not approved for P1 coding.
**Precedence:** Dashboard-first amendment. Do not implement a stack of task list → detail → history screens as the main loop.

Owner sample: [`dashboard-sample.jpg`](dashboard-sample.jpg). Layout follows that sample **and** the dashboard-first amendment. The mock’s left rail is **not** a new Flutter navigator; Productivity is the Home domain body. Today / Planner / Master List / Analytics are **sections**, not four screens.

---

## 1. Entry

When Productivity is shown on Home, the person lands **directly** on `ProductivityDashboard`. No interstitial “Getting started” wizard. Empty state is the dashboard with a short invite and **Add action**.

Settings does not need a second Productivity home.

## 2. Visual language

- Domain wash (proposed: cool slate, distinct from Time’s warm paper and Hajj green). Family colour on the outlined domain mark — not a score.
- Cards: 12px corners, domain wash, titleSmall w600 titles, bodySmall meta.
- Priority: **text + colour + number 1–4** (Critical / High / Medium / Low), as on the sample. Never colour-only.
- Status: text (Not started / In progress / Needs a look / Paused / Completed). Completed uses the settled pattern, not a trophy.
- Blocked: explanatory sentence, not a red fail bar.
- Light and dark themes; contrast for body text; 1.0 / 1.3 / 1.5 text scale on a 360-wide phone with **no overflow**.
- Touch targets ≥ 44px for start/pause/complete and reorder handles.

## 3. Default dashboard order (mobile, single column)

1. **Day header** — weekday, Gregorian date, civil Hijri in the same line style as Quick tap; compact counts (focus n/5, in progress, blocked). Counts are visibility, not a grade.
2. **Next executable** — one highlighted card or empty line “Nothing queued”.
3. **Today’s five** — always visible (empty slots not shown; “Add from list” when under five).
4. **Notices** — only if carry-forward or blocked items exist; otherwise omitted.
5. **Master Action List** — collapsed `ExpansionTile`.
6. **History and trends** — collapsed.

Do not open MAL and history at once by default.

## 4. Tablet / large width (≥ 600 lp, proposed)

Three regions, same data:

| Left / secondary | Centre | Right / secondary |
| --- | --- | --- |
| MAL (scroll) | Day header, next, today’s five, notices | History/trends (collapsed sections) |

Behaviour matches mobile. No extra features on tablet.

## 5. Action card (collapsed)

Always visible:

- Title (max 2 lines, ellipsis).
- Priority chip (colour + word).
- Status word.
- Remaining effort if set (`~40 min left`).
- Target date if set (Gregorian + Hijri via existing formatter).
- Next/blocker line: `Next: start` / `Blocked by: <title>` / `Paused`.
- Compact controls: Start or Pause/Resume, Complete, remaining-effort stepper or “Update”.

## 6. Action card (expanded)

Reveals:

- Children, then grandchildren (indent, not a new screen).
- Prerequisites list with add/remove.
- Estimate vs remaining.
- Last few events (3), “More history” expands the history panel filtered to this id.
- Edit title, date, priority (inline or sheet).

## 7. Interaction rules

| Goal | Interaction |
| --- | --- |
| Most routine work | Stay on dashboard |
| Complete / priority | One or two taps on the card |
| Add | FAB or header **Add**; sheet with title + optional priority/date; Save |
| Next executable | Top of dashboard; tap scrolls to that card |
| Blocked | Card states the prerequisite; tap prerequisite expands that card |
| Carry-forward | Notice + items already in today’s five |
| History | Expand panel; no navigation |

The **90% on-dashboard** figure is a **design target**, not a published claim until a person has used a build.

## 8. Copy tone

User-owned, not prescribed.

- Use: “Today’s five”, “Carried from yesterday”, “Blocked until … is finished”, “Nothing queued”.
- Avoid: “You missed yesterday”, “Productivity score”, “Keep your streak”, “Overdue fail”.
- Target date past today: “Past the date you set” (same idea as existing listed-actions past-target), not “Failed”.

## 9. Empty and edge states

- No actions: invite + Add.
- MAL only, today’s five empty: next line points to MAL; one-tap “Use first unblocked”.
- All five blocked: next line says so; does not pick a blocked item as executable.
- Text scale 1.5: wrap meta onto extra lines; controls stay in a wrap row.

## 10. Accessibility

- Semantics labels include title + status + priority words.
- Reorder: up/down icon buttons (not drag-only).
- Don’t rely on colour for blocked vs in progress.
- Sheets: `useSafeArea`, keyboard inset, Close/Save.

## 11. What stays a sheet (not a new route)

See `DASHBOARD_DESIGN_SPEC.md` § operations. Full screens are the exception.
