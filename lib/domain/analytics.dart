import 'daily_check_in.dart';
import 'date_key.dart';
import 'prayer.dart';
import 'quran.dart';
import 'review_period.dart';

class OutcomeShare {
  const OutcomeShare({required this.recorded, required this.desirable});

  final int recorded;
  final int desirable;

  double get ratio => recorded == 0 ? 0 : desirable / recorded;

  int get percentagePoints => recorded == 0 ? 0 : ((ratio * 100).round());
}

enum PeriodNarrative {
  insufficientEvidence,
  recentDeterioration,
  establishedConsistency,
  improvement,
  steady,
  deterioration,
}

class PeriodAnalytics {
  const PeriodAnalytics({
    required this.period,
    required this.share,
    required this.priorShare,
    required this.narrative,
  });

  final ReviewPeriod period;
  final OutcomeShare share;
  final OutcomeShare priorShare;
  final PeriodNarrative narrative;
}

bool hasAdequacy(ReviewPeriod period, int currentRecorded, int priorRecorded) {
  return switch (period) {
    ReviewPeriod.days7 => currentRecorded >= 4 && priorRecorded >= 4,
    ReviewPeriod.days30 => currentRecorded >= 15 && priorRecorded >= 15,
    ReviewPeriod.days90 => false,
  };
}

PeriodNarrative directionFromShares({
  required ReviewPeriod period,
  required OutcomeShare current,
  required OutcomeShare prior,
}) {
  if (period == ReviewPeriod.days90) {
    return PeriodNarrative.insufficientEvidence;
  }
  if (!hasAdequacy(period, current.recorded, prior.recorded)) {
    return PeriodNarrative.insufficientEvidence;
  }
  final delta = current.percentagePoints - prior.percentagePoints;
  if (delta >= 10) return PeriodNarrative.improvement;
  if (delta <= -10) return PeriodNarrative.deterioration;
  return PeriodNarrative.steady;
}

OutcomeShare salahShare(Iterable<DailyCheckIn> records, PrayerId? prayer) {
  var recorded = 0;
  var desirable = 0;
  for (final record in records) {
    if (prayer == null) {
      for (final id in PrayerId.values) {
        final status = record.prayer(id);
        if (!status.isRecorded) continue;
        recorded++;
        if (status.isDesirable) desirable++;
      }
    } else {
      final status = record.prayer(prayer);
      if (!status.isRecorded) continue;
      recorded++;
      if (status.isDesirable) desirable++;
    }
  }
  return OutcomeShare(recorded: recorded, desirable: desirable);
}

OutcomeShare readingShare(Iterable<DailyCheckIn> records) {
  var recorded = 0;
  var desirable = 0;
  for (final record in records) {
    final outcome = record.quranOutcome(QuranDimension.reading);
    if (!outcome.isRecorded) continue;
    recorded++;
    if (outcome == TernaryOutcome.positive) desirable++;
  }
  return OutcomeShare(recorded: recorded, desirable: desirable);
}

Map<String, DailyCheckIn> indexByDate(Iterable<DailyCheckIn> records) {
  return {for (final record in records) record.dateKey: record};
}

List<DailyCheckIn> recordsForKeys(
  Map<String, DailyCheckIn> index,
  Iterable<String> keys,
) {
  return [
    for (final key in keys)
      if (index.containsKey(key)) index[key]!,
  ];
}

PeriodNarrative classify90DaySalahOrReading({
  required Map<String, DailyCheckIn> index,
  required DateTime now,
  required OutcomeShare Function(Iterable<DailyCheckIn> records) shareOf,
}) {
  final keys = periodDateKeys(90, now: now);
  final earlier = keys.sublist(0, 30);
  final middle = keys.sublist(30, 60);
  final recent = keys.sublist(60, 90);
  final earlierShare = shareOf(recordsForKeys(index, earlier));
  final middleShare = shareOf(recordsForKeys(index, middle));
  final recentShare = shareOf(recordsForKeys(index, recent));
  final totalRecorded =
      earlierShare.recorded + middleShare.recorded + recentShare.recorded;
  final overallDesirable =
      earlierShare.desirable + middleShare.desirable + recentShare.desirable;
  final overall = OutcomeShare(
    recorded: totalRecorded,
    desirable: overallDesirable,
  );

  final eachBlockAdequate =
      earlierShare.recorded >= 12 &&
      middleShare.recorded >= 12 &&
      recentShare.recorded >= 12;
  if (totalRecorded < 45 || !eachBlockAdequate) {
    return PeriodNarrative.insufficientEvidence;
  }

  final recentMinusMiddle =
      recentShare.percentagePoints - middleShare.percentagePoints;
  if (recentMinusMiddle < -10) {
    return PeriodNarrative.recentDeterioration;
  }

  final noBlockBelow80 =
      _pct(earlierShare) >= 80 &&
      _pct(middleShare) >= 80 &&
      _pct(recentShare) >= 80;
  if (overall.percentagePoints >= 85 && noBlockBelow80) {
    return PeriodNarrative.establishedConsistency;
  }
  if (recentMinusMiddle >= 10) {
    return PeriodNarrative.improvement;
  }
  return PeriodNarrative.steady;
}

int _pct(OutcomeShare share) => share.percentagePoints;

String narrativeCopy(PeriodNarrative narrative) {
  return switch (narrative) {
    PeriodNarrative.insufficientEvidence => 'There is not enough recorded evidence in this comparison to describe a change.',
    PeriodNarrative.recentDeterioration => 'Among recorded observations, the most recent 30 days show a lower on-time or reading share than the middle 30 days.',
    PeriodNarrative.establishedConsistency => 'Across the recorded 90-day observations, the on-time or reading share stayed high in each 30-day block.',
    PeriodNarrative.improvement => 'Among recorded observations, the more recent period has a higher share of the recorded desired outcome.',
    PeriodNarrative.steady => 'Among recorded observations, the share of the recorded desired outcome is similar across the compared periods.',
    PeriodNarrative.deterioration => 'Among recorded observations, the more recent period has a lower share of the recorded desired outcome.',
  };
}
