# Accepted product state

Muhasabah02 is a Flutter Android-first app. RECORD is implemented as a Daily Check-In with five independent Salah prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) and statuses prayed on time, prayed late, missed, and unanswered. Missing/unanswered is never inferred as missed. DailyCheckIn schema v5 uses `recordableFieldCount = 10` (five Salah, Qur’an reading/listening, dhikr, conduct, gratitude, personal reflection). Six additional Qur’an dimensions are independent and do not increase that denominator.

Personal Response lives in a separate Hive box, schema v1.

History (manage/edit) is distinct from Recorded days (read-only Historical Reflection). Review is a single Period Summary with in-place 7/30/90 selection. Recognition is 30D/90D only. Application Reflection is never treated as implementation or Response completion.

Debug builds can seed 100 days of synthetic DailyCheckIn data (independent Salah and Qur’an, unanswered values, missing days) and clear only those tagged synthetic records.
