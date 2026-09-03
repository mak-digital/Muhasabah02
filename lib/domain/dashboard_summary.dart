import 'activities.dart';
import 'analytics.dart';
import 'daily_check_in.dart';
import 'date_key.dart';
import 'other_domains.dart';
import 'prayer.dart';
import 'quran.dart';
import 'review_period.dart';

class DomainCardModel {
  const DomainCardModel({
    required this.title,
    required this.recentLine,
    required this.periodLine,
    required this.unansweredLine,
  });

  final String title;
  final String recentLine;
  final String periodLine;
  final String unansweredLine;
}

class HomeDashboardSnapshot {
  const HomeDashboardSnapshot({
    required this.salah,
    required this.quran,
    required this.dhikr,
    required this.family,
    required this.charity,
    required this.fasting,
    required this.daysRecorded,
    required this.periodDays,
    required this.reviewLine,
    required this.recognitionLine,
  });

  final DomainCardModel salah;
  final DomainCardModel quran;
  final DomainCardModel dhikr;
  final DomainCardModel family;
  final DomainCardModel charity;
  final DomainCardModel fasting;
  final int daysRecorded;
  final int periodDays;
  final String reviewLine;
  final String recognitionLine;
}

HomeDashboardSnapshot buildHomeDashboard({
  required List<DailyCheckIn> records,
  required DateTime now,
  required ReviewPeriod period,
  required int recognitionCount,
}) {
  final todayKey = dateKey(now);
  DailyCheckIn? today;
  for (final record in records) {
    if (record.dateKey == todayKey) today = record;
  }
  final keys = periodDateKeys(period.days, now: now);
  final index = indexByDate(records);
  var daysRecorded = 0;
  for (final key in keys) {
    if (index.containsKey(key)) daysRecorded++;
  }
  final inPeriod = recordsForKeys(index, keys);
  final salahShareForPeriod = salahShare(inPeriod, null);
  final reading = readingShare(inPeriod);

  return HomeDashboardSnapshot(
    salah: DomainCardModel(
      title: 'Salah',
      recentLine: _salahRecent(today),
      periodLine:
          'This period: ${salahShareForPeriod.desirable} on time among ${salahShareForPeriod.recorded} recorded (missing excluded)',
      unansweredLine: _salahUnanswered(today),
    ),
    quran: DomainCardModel(
      title: 'Qur’an',
      recentLine: _quranRecent(today),
      periodLine:
          'This period: ${reading.desirable} read-or-listened among ${reading.recorded} recorded',
      unansweredLine: _ternaryUnanswered(
        today?.quranOutcome(QuranDimension.reading),
        subject: 'Reading/listening',
      ),
    ),
    dhikr: _observationCard(
      title: 'Dhikr',
      todayLabel: today?.dhikr.label,
      recordedDays: inPeriod.where((r) => r.dhikr.isRecorded).length,
      periodDays: period.days,
      unanswered: today == null || !today.dhikr.isRecorded,
    ),
    family: _observationCard(
      title: 'Family',
      todayLabel: today == null
          ? null
          : _activityLabel(ActivityCatalog.family, today.family.activityId),
      recordedDays: inPeriod.where((r) => r.family.isRecorded).length,
      periodDays: period.days,
      unanswered: today == null || !today.family.isRecorded,
    ),
    charity: _observationCard(
      title: 'Charity',
      todayLabel: today == null
          ? null
          : _activityLabel(ActivityCatalog.charity, today.charity.activityId),
      recordedDays: inPeriod.where((r) => r.charity.isRecorded).length,
      periodDays: period.days,
      unanswered: today == null || !today.charity.isRecorded,
    ),
    fasting: _observationCard(
      title: 'Fasting',
      todayLabel: today == null
          ? null
          : _activityLabel(ActivityCatalog.fasting, today.fasting.activityId),
      recordedDays: inPeriod.where((r) => r.fasting.isRecorded).length,
      periodDays: period.days,
      unanswered: today == null || !today.fasting.isRecorded,
    ),
    daysRecorded: daysRecorded,
    periodDays: period.days,
    reviewLine:
        '${period.shortLabel} · recorded $daysRecorded of ${period.days} days · missing excluded from outcomes',
    recognitionLine: period == ReviewPeriod.days7
        ? 'Recognition is available for 30-day and 90-day views.'
        : recognitionCount == 0
        ? 'No descriptive patterns yet in this period.'
        : '$recognitionCount descriptive pattern${recognitionCount == 1 ? '' : 's'} in this period.',
  );
}

DomainCardModel _observationCard({
  required String title,
  required String? todayLabel,
  required int recordedDays,
  required int periodDays,
  required bool unanswered,
}) {
  return DomainCardModel(
    title: title,
    recentLine: todayLabel == null
        ? 'No check-in saved for today.'
        : 'Today: $todayLabel',
    periodLine: 'This period: recorded on $recordedDays of $periodDays days',
    unansweredLine: unanswered
        ? 'Unanswered today (not a negative).'
        : 'An answer is recorded for today.',
  );
}

String _salahRecent(DailyCheckIn? today) {
  if (today == null) return 'No check-in saved for today.';
  final recorded = PrayerId.values.where((id) => today.prayer(id).isRecorded);
  if (recorded.isEmpty) return 'Today: no salah answers recorded.';
  return 'Today: ${recorded.length} of 5 prayers have a recorded state.';
}

String _salahUnanswered(DailyCheckIn? today) {
  if (today == null) return 'Unanswered today (not missed).';
  final unanswered = PrayerId.values
      .where((id) => !today.prayer(id).isRecorded)
      .length;
  if (unanswered == 0) return 'Each prayer has a recorded state today.';
  return '$unanswered salah ${unanswered == 1 ? 'entry is' : 'entries are'} unanswered today.';
}

String _quranRecent(DailyCheckIn? today) {
  if (today == null) return 'No check-in saved for today.';
  final outcome = today.quranOutcome(QuranDimension.reading);
  return switch (outcome) {
    TernaryOutcome.positive => 'Today: reading/listening recorded as activity.',
    TernaryOutcome.negative => 'Today: recorded as not done.',
    TernaryOutcome.unanswered => 'Today: reading/listening not recorded.',
  };
}

String _ternaryUnanswered(TernaryOutcome? outcome, {required String subject}) {
  if (outcome == null || outcome == TernaryOutcome.unanswered) {
    return '$subject: no answer recorded (not a negative).';
  }
  return '$subject has a recorded state today.';
}

String _activityLabel(List<ActivityOption> catalog, String id) {
  final option = ActivityCatalog.find(catalog, id);
  return option?.label ?? 'Not recorded';
}
