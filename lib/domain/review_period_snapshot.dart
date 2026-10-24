import 'analytics.dart';
import 'daily_check_in.dart';
import 'date_key.dart';
import 'home_traces.dart';
import 'monitor_domain.dart';
import 'other_domains.dart';
import 'quran.dart';
import 'review_period.dart';

class ReviewPeriodSnapshot {
  const ReviewPeriodSnapshot({
    required this.period,
    required this.keys,
    required this.inPeriod,
    required this.salah,
    required this.reading,
    required this.recordedDaysByDomain,
  });

  final ReviewPeriod period;
  final List<String> keys;
  final List<DailyCheckIn> inPeriod;
  final OutcomeShare salah;
  final OutcomeShare reading;
  final Map<MonitorDomain, int> recordedDaysByDomain;

  int recordedDays(MonitorDomain domain) => recordedDaysByDomain[domain] ?? 0;
}

bool checkInHasRecordedTrace(DailyCheckIn record, List<HomeTraceRow> rows) {
  for (final row in rows) {
    if (record.homeTrace(row.storageKey).isRecorded) return true;
  }
  return false;
}

ReviewPeriodSnapshot buildReviewPeriodSnapshot({
  required List<DailyCheckIn> records,
  required DateTime now,
  required ReviewPeriod period,
}) {
  final keys = periodDateKeys(period.days, now: now);
  final index = indexByDate(records);
  final inPeriod = recordsForKeys(index, keys);
  var dhikrDays = 0;
  var akhlaqDays = 0;
  var huquqDays = 0;
  var knowledgeDays = 0;
  var timeDays = 0;
  var healthDays = 0;
  var wealthDays = 0;
  var ummahDays = 0;
  var fastingDays = 0;
  var charityDays = 0;
  var hadithDays = 0;
  for (final record in inPeriod) {
    if (record.dhikr.isRecorded ||
        checkInHasRecordedTrace(record, dhikrHomeRows)) {
      dhikrDays++;
    }
    if (checkInHasRecordedTrace(record, akhlaqAllHomeRows) ||
        (record.akhlaqStruggleNote != null &&
            record.akhlaqStruggleNote!.trim().isNotEmpty)) {
      akhlaqDays++;
    }
    if (checkInHasRecordedTrace(record, huquqHomeRows)) huquqDays++;
    if (checkInHasRecordedTrace(record, knowledgeHomeRows)) {
      knowledgeDays++;
    }
    if (checkInHasRecordedTrace(record, timeHomeRows)) timeDays++;
    if (checkInHasRecordedTrace(record, healthHomeRows)) healthDays++;
    if (checkInHasRecordedTrace(record, wealthAllHomeRows)) wealthDays++;
    if (checkInHasRecordedTrace(record, ummahAllHomeRows)) ummahDays++;
    if (record.fasting.isRecorded ||
        checkInHasRecordedTrace(record, fastingHomeRows)) {
      fastingDays++;
    }
    if (record.charity.isRecorded ||
        checkInHasRecordedTrace(record, charityHomeRows)) {
      charityDays++;
    }
    if (record.hadith.isRecorded ||
        checkInHasRecordedTrace(record, hadithHomeRows)) {
      hadithDays++;
    }
  }
  return ReviewPeriodSnapshot(
    period: period,
    keys: keys,
    inPeriod: inPeriod,
    salah: salahShare(inPeriod, null),
    reading: readingShare(inPeriod),
    recordedDaysByDomain: {
      MonitorDomain.dhikr: dhikrDays,
      MonitorDomain.akhlaq: akhlaqDays,
      MonitorDomain.huquq: huquqDays,
      MonitorDomain.knowledge: knowledgeDays,
      MonitorDomain.time: timeDays,
      MonitorDomain.health: healthDays,
      MonitorDomain.wealth: wealthDays,
      MonitorDomain.ummah: ummahDays,
      MonitorDomain.fasting: fastingDays,
      MonitorDomain.charity: charityDays,
      MonitorDomain.hadith: hadithDays,
    },
  );
}
