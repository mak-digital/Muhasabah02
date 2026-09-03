import 'dart:math';

import '../domain/context_catalog.dart';
import '../domain/daily_check_in.dart';
import '../domain/date_key.dart';
import '../domain/other_domains.dart';
import '../domain/prayer.dart';
import '../domain/quran.dart';
import '../domain/recorded_context.dart';

const int kSyntheticWindowDays = 100;

class SyntheticCheckInPlan {
  const SyntheticCheckInPlan({
    required this.records,
    required this.missingDateKeys,
  });

  final List<DailyCheckIn> records;
  final List<String> missingDateKeys;

  int get savedDays => records.length;
  int get missingDays => missingDateKeys.length;
}

SyntheticCheckInPlan generateSyntheticCheckIns({
  required DateTime now,
  int windowDays = kSyntheticWindowDays,
  int seed = 20260903,
}) {
  final random = Random(seed);
  final keys = periodDateKeys(windowDays, now: now);
  final missing = <String>{};

  while (missing.length < 12) {
    missing.add(keys[random.nextInt(keys.length)]);
  }
  for (final key in keys) {
    if (missing.length >= 20) break;
    if (random.nextDouble() < 0.08) missing.add(key);
  }

  final records = <DailyCheckIn>[];
  for (final key in keys) {
    if (missing.contains(key)) continue;
    records.add(_day(key, parseDateKey(key), random));
  }
  return SyntheticCheckInPlan(
    records: records,
    missingDateKeys: missing.toList()..sort(),
  );
}

DailyCheckIn _day(String key, DateTime date, Random random) {
  final weekend =
      date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
  final salah = <PrayerId, PrayerStatus>{
    for (final id in PrayerId.values) id: _salah(id, weekend, random),
  };
  if (salah.values.every((status) => status == PrayerStatus.onTime)) {
    salah[PrayerId.isha] = PrayerStatus.unanswered;
  }

  final quran = <QuranDimension, TernaryOutcome>{
    for (final dimension in QuranDimension.values)
      dimension: _quran(dimension, random),
  };
  if (quran.values.every((outcome) => outcome == TernaryOutcome.positive)) {
    quran[QuranDimension.applicationReflection] = TernaryOutcome.unanswered;
  }

  var record = DailyCheckIn(
    dateKey: key,
    salah: salah,
    quran: quran,
    dhikr: _pick(random, [
      (0.22, DhikrStatus.unanswered),
      (0.55, DhikrStatus.practised),
      (1.0, DhikrStatus.didNot),
    ]),
    conduct: _pick(random, [
      (0.35, ConductStatus.unanswered),
      (0.70, ConductStatus.noted),
      (1.0, ConductStatus.didNot),
    ]),
    gratitudeStatus: _pick(random, [
      (0.40, EntryStatus.unanswered),
      (0.70, EntryStatus.noneToday),
      (1.0, EntryStatus.recorded),
    ]),
    personalReflectionStatus: _pick(random, [
      (0.50, EntryStatus.unanswered),
      (0.78, EntryStatus.noneToday),
      (1.0, EntryStatus.recorded),
    ]),
    synthetic: true,
  );

  for (final dimension in QuranDimension.values) {
    final outcome = record.quranOutcome(dimension);
    if (!contextAllowed(dimension, outcome)) continue;
    if (random.nextDouble() > 0.42) continue;
    final polarity = outcome == TernaryOutcome.positive
        ? 'positive'
        : 'negative';
    final catalog = ContextCatalog.forPolarity(polarity);
    final factor = catalog[random.nextInt(catalog.length)];
    record = record.withContext(
      RecordedContext(
        subject: dimension,
        polarity: polarity,
        factorIds: [factor.id],
      ),
    );
  }
  return record;
}

PrayerStatus _salah(PrayerId id, bool weekend, Random random) {
  final roll = random.nextDouble() + (weekend ? 0.04 : 0);
  return switch (id) {
    PrayerId.fajr => _band(roll, unanswered: 0.20, onTime: 0.42, late: 0.78),
    PrayerId.dhuhr => _band(roll, unanswered: 0.12, onTime: 0.68, late: 0.88),
    PrayerId.asr => _band(roll, unanswered: 0.16, onTime: 0.58, late: 0.84),
    PrayerId.maghrib => _band(roll, unanswered: 0.10, onTime: 0.72, late: 0.90),
    PrayerId.isha => _band(roll, unanswered: 0.18, onTime: 0.55, late: 0.82),
  };
}

PrayerStatus _band(
  double roll, {
  required double unanswered,
  required double onTime,
  required double late,
}) {
  if (roll < unanswered) return PrayerStatus.unanswered;
  if (roll < onTime) return PrayerStatus.onTime;
  if (roll < late) return PrayerStatus.late;
  return PrayerStatus.missed;
}

TernaryOutcome _quran(QuranDimension dimension, Random random) {
  final roll = random.nextDouble();
  return switch (dimension) {
    QuranDimension.reading => _ternary(roll, unanswered: 0.16, positive: 0.70),
    QuranDimension.meaning => _ternary(roll, unanswered: 0.32, positive: 0.68),
    QuranDimension.memorisation => _ternary(
      roll,
      unanswered: 0.48,
      positive: 0.70,
    ),
    QuranDimension.revision => _ternary(roll, unanswered: 0.44, positive: 0.72),
    QuranDimension.tafsir => _ternary(roll, unanswered: 0.50, positive: 0.74),
    QuranDimension.reflection => _ternary(
      roll,
      unanswered: 0.38,
      positive: 0.72,
    ),
    QuranDimension.applicationReflection => _ternary(
      roll,
      unanswered: 0.46,
      positive: 0.76,
    ),
  };
}

TernaryOutcome _ternary(
  double roll, {
  required double unanswered,
  required double positive,
}) {
  if (roll < unanswered) return TernaryOutcome.unanswered;
  if (roll < positive) return TernaryOutcome.positive;
  return TernaryOutcome.negative;
}

T _pick<T>(Random random, List<(double, T)> table) {
  final roll = random.nextDouble();
  for (final entry in table) {
    if (roll < entry.$1) return entry.$2;
  }
  return table.last.$2;
}
