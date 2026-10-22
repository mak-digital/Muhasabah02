# Dhikr context catalogue

Dhikr check-in rows keep their Home keys and labels. Each row opens a performed list instead of a generic noticed / not-noticed or remembrance-level dropdown.

Morning, evening, and post-fard lists are generated from the verified Learn & Practice catalogue for that group.

| Row key | Label | Band | Source |
| --- | --- | --- | --- |
| `dhikr.postFardFajr` … `dhikr.postFardIsha` | Fajr … Isha | Post-fard Salah Adhkar | Post-fard Learn & Practice set |
| `dhikr.morningAdhkar` | Morning Adhkar | Morning and evening | Morning Learn & Practice set |
| `dhikr.eveningAdhkar` | Evening Adhkar | Morning and evening | Evening Learn & Practice set |
| `dhikr.generalDhikr` | General Dhikr | Other remembrance | 10 |
| `dhikr.gratitudeDhikr` | Gratitude Dhikr | Other remembrance | 6 |
| `dhikr.travelDhikr` | Travel Remembrance | Other remembrance | 7 |
| `dhikr.personalDhikr` | Personal | Other remembrance | 10 |
| `dhikr.otherAdhkar` | Other Adhkars | Other remembrance | 10 |

Stable activity IDs live in `lib/domain/dhikr_context.dart`. Visible labels are not persistence keys.

Activity descriptions (tasbih, travel topic, personal topic, and so on) are not treated as prescribed formulas. A **Verified wording available** link opens that item’s own sourced formula. A **Related wording available** link opens a nearby Learn & Practice item for the topic; it is not a required wording. Istikhara stays a personal topic in this release; its transmitted wording is pending editorial review.

See `DHIKR_SOURCE_REGISTRY.md` for citations and verification status.
