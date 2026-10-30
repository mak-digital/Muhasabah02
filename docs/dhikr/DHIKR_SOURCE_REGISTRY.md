# Dhikr source registry

Executable copy: `lib/domain/dhikr_source_registry.dart`.

Verification rule: show Arabic as a sourced formula only when the citation is a Qur’an verse or a named hadith collection with a number that this app can open. Hisn al-Muslim collection numbers are not used as a substitute. Grades are stated only for Bukhari and Muslim (Sahih). Other collections are recorded without an extra grade.

## Verified

| ID | Category | Citation | Kind | Notes |
| --- | --- | --- | --- | --- |
| `src.dhikr.postPrayer` | Post-fard | Sahih Muslim 597 | Formula | Kept on post-fard rows, not Other Adhkars check-in |
| `src.dhikr.tasbih` | General | Sahih al-Bukhari 6405 | Activity | Count not prescribed in-app |
| `src.dhikr.tahmid` | General | Sahih Muslim 223 | Activity | Reuses Learn & Practice `dh.grat.hamd` |
| `src.dhikr.takbir` | General | Sahih Muslim 597 | Activity | Count not prescribed in-app |
| `src.dhikr.tahlil` | General | Sahih Muslim 2691 | Activity | Count not prescribed in-app |
| `src.dhikr.subhanAllahiWaBihamdihi` | General | Sahih al-Bukhari 6405 | Formula | |
| `src.dhikr.pairedFormula` | General | Sahih al-Bukhari 6406; Muslim 2694 | Formula | Reuses `dh.gen.adheem` |
| `src.dhikr.istighfar` | General | Sahih al-Bukhari 6307 | Activity | Not completed tawbah |
| `src.dhikr.sayyidAlIstighfar` | General | Sahih al-Bukhari 6306 | Formula | Not completed tawbah |
| `src.dhikr.salawat` | General | Qur’an 33:56; Muslim 408 | Formula | Reuses `dh.gen.salawat` |
| `src.dhikr.alhamdulillah` | Gratitude | Sahih Muslim 223 | Formula | Reuses `dh.grat.hamd` |
| `src.dhikr.afterFood` | Gratitude | Sahih Muslim 2734 | Activity | Praise after eating or drinking; longer meal formulas are not attached to this citation |
| `src.dhikr.quran14_7` | Gratitude | Qur’an 14:7 | Verse | |
| `src.dhikr.leavingHome` | Travel | Sunan Abi Dawud 5095 | Formula | No extra grade asserted |
| `src.dhikr.beginningJourney` | Travel | Sahih Muslim 1342 | Formula | Reuses `dh.travel.mount`; also linked from boarding |
| `src.dhikr.stoppingPlace` | Travel | Sahih Muslim 2708 | Formula | |
| `src.dhikr.returningTravel` | Travel | Bukhari 3085; Muslim 1344 | Formula | Reuses `dh.travel.return` |
| `src.dhikr.rabbanaAtina` | Personal | Qur’an 2:201; Bukhari 6389 | Formula | Reuses `dh.pers.rabbana` |
| `src.dhikr.beforeSleep` | Other Adhkars | Bukhari 2311; Qur’an 2:255 | Formula | Reuses `dh.other.sleep.kursi` |
| `src.dhikr.waking` | Other Adhkars | Sahih al-Bukhari 6312 | Formula | Upon waking |
| `src.dhikr.mosque` | Other Adhkars | Sahih Muslim 713 | Formula | Entering and leaving |
| `src.dhikr.distress` | Other Adhkars | Qur’an 21:87 | Verse | The call of Yunus; not a remedy |
| `src.dhikr.illness` | Other Adhkars | Bukhari 5742; Muslim 2191 | Formula | Not a medical instruction |

## Pending editorial review

| ID | Category | Reason |
| --- | --- | --- |
| `src.dhikr.istikharaPending` | Personal | Transmitted istikhara wording not shown until reviewed |

Seeking protection and Other Sunnah remembrance stay activity descriptions until a further citation is verified.
