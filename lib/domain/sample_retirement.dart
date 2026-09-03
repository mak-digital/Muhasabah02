import 'daily_check_in.dart';
import 'date_key.dart';

const int kSampleRetirementMinDays = 21;
const int kSampleRetirementMaxDays = 28;

int consecutivePersonalDays({
  required List<DailyCheckIn> records,
  required DateTime now,
}) {
  final index = <String, DailyCheckIn>{
    for (final record in records) record.dateKey: record,
  };
  var count = 0;
  var cursor = DateTime(now.year, now.month, now.day);
  while (true) {
    final key = dateKey(cursor);
    final record = index[key];
    if (record == null || record.synthetic) break;
    count++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return count;
}

bool shouldOfferSampleArchive({
  required List<DailyCheckIn> records,
  required DateTime now,
  required bool dismissed,
}) {
  if (dismissed) return false;
  if (!records.any((record) => record.synthetic)) return false;
  final streak = consecutivePersonalDays(records: records, now: now);
  return streak >= kSampleRetirementMinDays;
}
