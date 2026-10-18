# Privacy and consent contract

## Two consents

| Consent | Local field | May call |
| --- | --- | --- |
| Official-source retrieval | `onlineAssist.lookupConsented` | `HajjOfficialSourceGateway` |
| AI-assisted interpretation | `onlineAssist.aiConsented` | `HajjAIInterpretationGateway` |

Neither is implied by the other. Both default **off**. Revoking both sets `revokedAt` and the UI returns to **Offline**.

`HajjConsentManager` is the only mutator used by Hajj Home.

## What may leave the device (live phase, still not enabled)

Allowed payload keys (`kHajjAllowedPayloadKeys`):

- `season`
- `nationalityCountry` / `nationalityCountries`
- `residenceCountry` / `residenceCountries`
- `departureCountry` / `returnCountry`
- `pathwayIds`
- `citizenships` (ISO country codes only)

## What must never leave the device

- Private Muhasabah reflections, journals, gratitude, After Hajj free text
- Passport **numbers** or scans
- Health notes / `healthPreparationNote`
- Family member **names** or `displayName`
- Unrelated DailyCheckIn, Response, or other Hive boxes
- The entire Hajj store JSON

`hajjOnlinePayloadIsSafe` plus `payloadKeysAllowed` enforce this in tests.

## Local-first resolution

`LocalHajjPathwayResolver` runs on-device and produces portals + questions. A future live request sends only the minimum payload above, not the question text and not traveller records.

## Revocation, cancellation, retention, deletion

| Event | Behaviour |
| --- | --- |
| Turn a switch off | No further requests of that type. Stored bookmarks remain on the phone unless the person deletes them |
| Both off | `revokedAt` set; card shows Offline |
| Cancel | There is no in-flight Hajj HTTP today. Cancel = do not tap, or revoke |
| Retention | Sources, providers, and proposals stay in `muhasabah_hajj_v1` on-device |
| Delete | Person can remove a journey; a later 3B-2B may add “clear online artifacts”. Do not auto-wipe on revoke (those bookmarks may still be wanted offline) |
| Backend retention (future) | Cache public pages by URL/day, not by user. Delete logs after a short window (propose 14 days) |

## Demo banner

Every demonstration result must show **Demo — no live verification**. It is not a government requirement.
