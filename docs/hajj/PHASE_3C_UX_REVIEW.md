# Phase 3C — Hajj Home usability audit

**Date:** 18 October 2026  
**Device:** Android emulator-5554 (already running; reused). Screenshots: `docs/hajj/phase3c_screenshots/`.  
**Text scale:** Widget coverage at 1.3 in `Family stays reachable without expanding the month list`. Emulator shots are default scale.

This is a review of the **current** UI. No layout rewrite was done in this phase.

## What the person sees first

`01_hajj_standing_journey.png`

Hajj is one Home domain among many (chevrons + dots). Above the planner: Learn & Practice, the Hajj week question, then **Hajj standing**. The week strip is empty of daily Hajj marks (correct: standing is lifetime, not a daily matrix).

The standing dropdown and explanation are clear. The first journey card is already expanded: **Season undecided · Considering · Unknown dates**. There is **no “do this next”** line (for example “Add who is travelling” or “Choose a planning route”).

## Clutter and card order

Twelve planner cards follow standing, then Hajj actions and developer notes:

1. My Hajj Journey (expanded)  
2. Journey summary (expanded)  
3. Planning pathways  
4. Readiness & Prerequisites  
5. Family & Companions  
6. Return scenarios  
7. Readiness learning  
8. After Hajj  
9. Online assistance  
10. Official sources  
11. Provider information  
12. Planning Calendar  

The **calendar is last and collapsed** (`07_hajj_calendar.png`), after online/sources/providers. Preparation time is therefore below optional network tools.

Several cards show “Opens with a plan” internally when empty, but collapsed headers still occupy a full row with counts (`0 of 10`, `0 traveler(s)`, `1 stored`).

Journey summary (`03_hajj_journey_actions.png` / mid-card shot) repeats “Planning pathway is not confirmed yet” and dumps the whole critical-path title list as one paragraph. Only the first conflict/notice is shown in code.

## Viewing vs editing

`03` shows **Edit plan**, **Another plan**, **Archive**, **Apply preparation template**, **Delete** on the default-expanded journey card.

Problems observed:

- Edit plan is a primary outlined button next to Archive/Delete — easy to tap while scrolling (confirmed in 3B-2F).
- Archive and Delete have **no confirm dialog**.
- Apply preparation template mutates milestones in place with no preview.
- Source rows toggle verification on tap (no View vs Mark reviewed split).
- Milestone rows open the editor on tap (reasonable, but mixed with “Critical ·” labelling that does not match the engine path).

## Next-action guidance

Missing as a dedicated control. The closest signals:

- Journey summary: route not confirmed; critical path titles; first document notice.
- Readiness header: `0 of 10 confirmed by you`.
- Family header: `0 traveler(s)` even after templates exist.

A practical next step (add a traveler, confirm a pathway, open the calendar) is not ranked.

## Deadlines and dependencies

Present on calendar milestone subtitles (official date, planning window, depends-on count, overdue/upcoming). Buried until the calendar is expanded. Dependencies are counts (`Depends on 2`), not named predecessors, unless the person opens the sheet.

## Empty states

- No journey: invite + Create a Hajj plan (tested).
- No sources: copy to add a bookmark or opt in (tested).
- No providers: “Discovery is demonstration-only and never books.”
- After Hajj: Optional.
- Journey with no travelers: only the count `0 traveler(s)` — weak.

## Offline vs online assistance

`04` / `06`:

- Card header: **Opted in (revocable)** when lookup consent is on.
- First line still: **Offline by default. Nothing is sent until you opt in.**
- Then **Live official-source information** twice (`Copy.hajjLiveMode` is rendered twice in `HajjOnlineAssistPanel`).
- Lookup switch title still says **demonstration catalog on this device** in a debug build that has `HAJJ_LIVE_BASE_URL`.
- Body still says **Live lookup stays off until a Worker URL is configured** while that URL is compiled in.

Consent switches and disabled **Request interpretation** are clear. **Request official bookmarks** is correctly enabled only with lookup consent (widget test).

## Worker-unavailable messages

Lookup/AI failures use `ScaffoldMessenger` **SnackBar** (`Live official lookup is unavailable.`). Default snackbars disappear quickly, sit at the bottom under Home tabs, and often have no durable semantics. Phase 3B-2F captured one dump; 3B-2G often missed it.

**Conclusion:** Worker-unavailable is **not reliably visible or accessible**. It should become a persistent, labelled banner on the Online assistance card (and remain until dismissed), without logging private text.

## Accessibility

- Many cards use ExpansionTile titles; some calendar months have `Semantics` labels.
- Source/provider `ListTile`s use dense text, `maxLines` 5, overflow ellipsis — long provenance lines truncate (`06`).
- 1.3 text-scale widget test exists for family/calendar reachability; 1.5 and narrow-width Hajj overflow were not re-run on device this phase.
- Duplicate live-mode lines hurt both clutter and screen-reader noise.

## DemoMinistry (name vs metadata)

On `06_hajj_calendar.png` / sources list:

> **DemoMinistry**  
> Unverified · **Entered by you** · Unknown retrieval · DemoMinistry

The **title** looks like a demo authority. Stored origin is **user-entered**, not demonstration catalog, not live Worker. Do not reclassify by display name. See Stage 3.

Live rows on the same screen:

> Unverified · **Retrieved by live Worker** · Live official-source information · … HTTP response is not official verification.

Demonstration bookmarks keep **Demonstration catalog**.

## Accidental Edit plan

Essential UX correction: keep a read-only journey summary; move Edit / Archive / Delete behind an explicit overflow or “Change this plan”, with confirm on Archive/Delete.

## Screenshot index

| File | Content |
| --- | --- |
| `01_hajj_standing_journey.png` | Standing + journey header |
| `02_hajj_journey_actions.png` | Same first viewport (duplicate of 01) |
| `03_hajj_mid_cards.png` | Edit/Archive/Delete cluster + Journey summary |
| `04_hajj_online_sources.png` | Online card clutter / consent |
| `05_hajj_sources_expanded.png` | Same online viewport (tap missed sources) |
| `06_hajj_calendar.png` | Sources list with origin labels (filename is historical) |
| `07_hajj_calendar.png` | Sources continued + collapsed Planning Calendar last |
