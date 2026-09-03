# Accepted product state

Muhasabah02 is a Flutter Android-first app. RECORD is a Daily Check-In with five independent Salah prayers and domain-specific activity lists (plus Other). Missing/unanswered is never inferred as missed. DailyCheckIn schema **v6** keeps `recordableFieldCount = 10`. Optional domains (fasting, charity, zakat status, family/kinship, Hadith) are independent and not scored. Application Reflection is a first-install acknowledgement and Settings → About page; it is not a recurring daily field, summary item, or dashboard metric.

Personal Response lives in a separate Hive box, schema v1, with an optional `synthetic` flag for sample notes.

History (manage/edit) is distinct from Recorded days (read-only Historical Reflection). Review is a single Period Summary with in-place 7/30/90 selection. Recognition is 30D/90D only.

First install seeds ~120 days of marked sample/demo check-ins (and sample responses) through production repositories. Sample data remains until the user removes, recreates, or restores it in Settings → Developer / Data Management. After about 21 consecutive personal days, Home may offer to archive sample records; nothing is deleted automatically.

Home is a visual Summary Dashboard after Application Reflection acknowledgement: domain colour-family cards (Salah, Qur’an, Dhikr, Family, Charity, Fasting), current review snapshot, recognition, PONDER, and Add a response. Cards are tappable. Colour identifies domains. No scores, ranks, or streaks. Check-in, Review, Progress, History, and Settings use the same wash-and-card language.
