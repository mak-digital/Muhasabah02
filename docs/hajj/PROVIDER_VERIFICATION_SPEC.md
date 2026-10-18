# Provider verification specification

Phase 3B-2A does **not** ship a provider directory of named operators.

`EmptyHajjProviderDirectoryGateway` returns no rows. The bundled registry may include an official **register URL** (for example Nusuk licensed services) without operator names.

## Required fields when a real directory exists (later)

| Field | Rule |
| --- | --- |
| Name and jurisdiction | As published by the authority |
| Official licence / authorisation source | URL + retrieval date + season |
| Contact | From that source, not invented |
| Package information | Quoted from the source; currency and price date required if a price is shown |
| Conditions / exclusions | Copied, not summarised as a guarantee |
| Independent reviews | Separate field; never mixed into authorisation |
| Verification status | Unverified until evidence is current |

## Authorisation rule (already enforced)

`hajjProviderMayBeCalledAuthorized` is true only when:

- `officiallyAuthorized` is true, **and**
- `authorizationEvidence` is non-empty, **and**
- `demonstration` is false

Otherwise the UI says **Not labelled officially authorized**.

## Forbidden

- Invented operators, ratings, or prices
- AI endorsements
- Payments, bookings, affiliate links
- Treating a search result as a licence
