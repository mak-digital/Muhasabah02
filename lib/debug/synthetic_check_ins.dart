import 'dart:math';

import '../domain/activities.dart';
import '../domain/context_catalog.dart';
import '../domain/daily_check_in.dart';
import '../domain/date_key.dart';
import '../domain/home_traces.dart';
import '../domain/other_domains.dart';
import '../domain/personal_response.dart';
import '../domain/prayer.dart';
import '../domain/quran.dart';
import '../domain/recorded_context.dart';
import '../domain/salah_factors.dart';

const int kSyntheticWindowDays = 120;
const String kSampleDataNotice =
    'These records are sample/demo data. You can edit them. They stay until you remove them.';

class SyntheticCheckInPlan {
  const SyntheticCheckInPlan({
    required this.records,
    required this.missingDateKeys,
    required this.responses,
  });

  final List<DailyCheckIn> records;
  final List<String> missingDateKeys;
  final List<PersonalResponse> responses;

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

  while (missing.length < 16) {
    missing.add(keys[random.nextInt(keys.length)]);
  }
  for (final key in keys) {
    if (missing.length >= 26) break;
    if (random.nextDouble() < 0.07) missing.add(key);
  }

  final records = <DailyCheckIn>[];
  for (final key in keys) {
    if (missing.contains(key)) continue;
    records.add(_day(key, parseDateKey(key), random));
  }
  return SyntheticCheckInPlan(
    records: _withRecognitionClusters(records, now: now),
    missingDateKeys: missing.toList()..sort(),
    responses: _sampleResponses(now),
  );
}

List<PersonalResponse> _sampleResponses(DateTime now) {
  return [
    PersonalResponse(
      id: 'sample-response-ponder',
      text: 'I notice midweek reading often looks different from what I recorded on Fridays.',
      createdAt: now.subtract(const Duration(days: 12)),
      synthetic: true,
      provenance: const ResponseProvenance(
        originType: ProvenanceOrigin.quranPonder,
        domain: 'quran',
        periodDays: 30,
        labelSnapshot: 'Qur’an PONDER (sample)',
      ),
    ),
    PersonalResponse(
      id: 'sample-response-progress',
      text: 'A note to keep: Fajr and Isha were recorded independently more often than I expected.',
      createdAt: now.subtract(const Duration(days: 40)),
      synthetic: true,
      provenance: const ResponseProvenance(
        originType: ProvenanceOrigin.progressDimension,
        domain: 'salah',
        subject: 'fajr',
        periodDays: 90,
        labelSnapshot: 'Fajr (sample 90 days)',
      ),
    ),
  ];
}

List<DailyCheckIn> _withRecognitionClusters(
  List<DailyCheckIn> records, {
  required DateTime now,
}) {
  final byKey = {for (final record in records) record.dateKey: record};
  final last30 = periodDateKeys(30, now: now);
  final last90 = periodDateKeys(90, now: now);

  void cluster({
    required List<String> windowKeys,
    required QuranDimension subject,
    required TernaryOutcome outcome,
    required String factorId,
    int target = 8,
  }) {
    final saved = [
      for (final key in windowKeys)
        if (byKey.containsKey(key)) key,
    ];
    if (saved.length < 5) return;
    final chosen = _spreadKeys(saved, target.clamp(5, saved.length));
    if (chosen.length < 5) return;
    if (daysInclusiveSpan(chosen.first, chosen.last) < 7) return;
    final polarity = outcome == TernaryOutcome.positive
        ? 'positive'
        : 'negative';
    for (final key in chosen) {
      var record = byKey[key]!;
      record = record.withQuran(subject, outcome);
      record = record.withContext(
        RecordedContext(
          subject: subject,
          polarity: polarity,
          factorIds: [factorId],
        ),
      );
      byKey[key] = record;
    }
  }

  cluster(
    windowKeys: last30,
    subject: QuranDimension.meaning,
    outcome: TernaryOutcome.positive,
    factorId: 'routine',
  );
  cluster(
    windowKeys: last90,
    subject: QuranDimension.meaning,
    outcome: TernaryOutcome.positive,
    factorId: 'routine',
    target: 16,
  );
  cluster(
    windowKeys: last30,
    subject: QuranDimension.revision,
    outcome: TernaryOutcome.negative,
    factorId: 'fatigue',
  );
  cluster(
    windowKeys: last90,
    subject: QuranDimension.revision,
    outcome: TernaryOutcome.negative,
    factorId: 'fatigue',
    target: 16,
  );
  cluster(
    windowKeys: last90,
    subject: QuranDimension.tafsir,
    outcome: TernaryOutcome.positive,
    factorId: 'quran.studyCircle',
    target: 16,
  );

  return [for (final record in records) byKey[record.dateKey]!];
}

List<String> _spreadKeys(List<String> sorted, int count) {
  if (sorted.length <= count) return List<String>.from(sorted);
  final out = <String>[];
  for (var i = 0; i < count; i++) {
    final idx = (i * (sorted.length - 1) / (count - 1)).round();
    final key = sorted[idx];
    if (out.isEmpty || out.last != key) out.add(key);
  }
  return out;
}

DailyCheckIn _day(String key, DateTime date, Random random) {
  final friday = date.weekday == DateTime.friday;
  final weekend =
      date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
  final mondayThursday =
      date.weekday == DateTime.monday || date.weekday == DateTime.thursday;
  final whiteDays = date.day == 13 || date.day == 14 || date.day == 15;
  final monthEnd = date.day >= 25;

  var record = DailyCheckIn(
    dateKey: key,
    salah: {for (final id in PrayerId.values) id: PrayerStatus.unanswered},
    quran: {
      for (final dimension in QuranDimension.values)
        dimension: TernaryOutcome.unanswered,
    },
    synthetic: true,
  );

  for (final id in PrayerId.values) {
    record = record.withSalahActivity(id, _salahActivity(id, friday, random));
  }
  if (PrayerId.values.every((id) => record.prayer(id) == PrayerStatus.onTime)) {
    record = record.withSalahActivity(
      PrayerId.isha,
      const RecordedActivity(id: ActivityIds.unanswered),
    );
  }

  if (friday) {
    record = record.copyWith(
      jumuah: random.nextDouble() < 0.22
          ? PrayerStatus.unanswered
          : random.nextDouble() < 0.12
          ? PrayerStatus.missed
          : PrayerStatus.onTime,
      jumuahCongregation:
          record.prayer(PrayerId.dhuhr) == PrayerStatus.onTime &&
          random.nextDouble() < 0.7,
    );
  }
  record = record.copyWith(
    tahajjud: _pick(random, [
      (0.55, TernaryOutcome.unanswered),
      (0.82, TernaryOutcome.positive),
      (1.0, TernaryOutcome.negative),
    ]),
    ishraq: _pick(random, [
      (0.58, TernaryOutcome.unanswered),
      (0.84, TernaryOutcome.positive),
      (1.0, TernaryOutcome.negative),
    ]),
  );
  if (random.nextDouble() < 0.22) {
    record = record.withSalahFactors(
      PrayerId.fajr.name,
      SalahFactorCapture(
        supportIds: random.nextDouble() < 0.5
            ? const ['salah.alarmWorked']
            : const [],
        challengeIds: random.nextDouble() < 0.5
            ? const ['salah.overslept']
            : const [],
      ),
    );
  }

  for (final dimension in quranDailyDimensions) {
    record = record.withQuranActivity(
      dimension,
      _quranActivity(dimension, friday, random),
    );
  }

  record = record.copyWith(
    dhikr: _dhikrStatus(weekend, random),
    conduct: _conductStatus(random),
    gratitudeStatus: monthEnd
        ? EntryStatus.recorded
        : _pick(random, [
            (0.38, EntryStatus.unanswered),
            (0.68, EntryStatus.noneToday),
            (1.0, EntryStatus.recorded),
          ]),
    gratitudeText: monthEnd
        ? 'A recorded gratitude note for this sample day.'
        : null,
    personalReflectionStatus: _pick(random, [
      (0.48, EntryStatus.unanswered),
      (0.76, EntryStatus.noneToday),
      (1.0, EntryStatus.recorded),
    ]),
    fasting: DomainObservation(
      activityId: whiteDays
          ? 'monthlyFasting'
          : mondayThursday && random.nextDouble() < 0.45
          ? 'weeklySunnah'
          : random.nextDouble() < 0.12
          ? ActivityIds.noActivity
          : ActivityIds.unanswered,
    ),
    charity: DomainObservation(
      activityId: monthEnd && random.nextDouble() < 0.55
          ? 'voluntaryCharity'
          : random.nextDouble() < 0.12
          ? 'communitySupport'
          : random.nextDouble() < 0.18
          ? ActivityIds.noActivity
          : ActivityIds.unanswered,
    ),
    zakat: date.day == 1
        ? ZakatStatus.planned
        : date.month == 9 && date.day == 15
        ? ZakatStatus.due
        : random.nextDouble() < 0.04
        ? ZakatStatus.notApplicable
        : ZakatStatus.unanswered,
    family: DomainObservation(
      activityId: weekend
          ? (random.nextDouble() < 0.55
                ? 'parentCommunication'
                : 'familyCommunication')
          : random.nextDouble() < 0.18
          ? 'relativeCommunication'
          : random.nextDouble() < 0.2
          ? ActivityIds.noActivity
          : ActivityIds.unanswered,
    ),
    hadith: DomainObservation(
      activityId: friday && random.nextDouble() < 0.5
          ? 'listening'
          : random.nextDouble() < 0.22
          ? 'reading'
          : random.nextDouble() < 0.2
          ? ActivityIds.noActivity
          : ActivityIds.unanswered,
    ),
  );

  if (record.gratitudeStatus == EntryStatus.recorded &&
      (record.gratitudeText == null || record.gratitudeText!.isEmpty)) {
    record = record.copyWith(gratitudeText: 'A short sample gratitude note.');
  }
  if (record.personalReflectionStatus == EntryStatus.recorded) {
    record = record.copyWith(
      personalReflectionText: 'A short sample personal-reflection note.',
    );
  }

  record = record.withActivity(
    ActivityCatalog.dhikrKey,
    RecordedActivity(id: _dhikrActivityId(record.dhikr)),
  );
  record = record.withActivity(
    ActivityCatalog.conductKey,
    RecordedActivity(id: _conductActivityId(record.conduct)),
  );

  for (final row in allHomeTraceRows) {
    final outcome = _pick(random, [
      (0.52, TernaryOutcome.unanswered),
      (0.82, TernaryOutcome.positive),
      (1.0, TernaryOutcome.negative),
    ]);
    if (outcome != TernaryOutcome.unanswered) {
      record = record.withHomeTrace(row.storageKey, outcome);
    }
  }
  if (random.nextDouble() < 0.14) {
    record = record.copyWith(
      akhlaqStruggleNote: 'I was impatient today, but I caught myself.',
    );
  }

  for (final dimension in quranDailyDimensions) {
    final outcome = record.quranOutcome(dimension);
    if (!contextAllowed(dimension, outcome)) continue;
    if (random.nextDouble() > 0.38) continue;
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

RecordedActivity _salahActivity(PrayerId id, bool friday, Random random) {
  final roll = random.nextDouble() + (friday ? 0.06 : 0);
  if (roll < 0.14) {
    return const RecordedActivity(id: ActivityIds.unanswered);
  }
  if (friday && roll < 0.58) {
    return const RecordedActivity(id: 'congregationOnTime');
  }
  if (roll < 0.42) {
    return const RecordedActivity(id: 'aloneOnTime');
  }
  if (roll < 0.62) {
    return const RecordedActivity(id: 'prayedLate');
  }
  if (roll < 0.74) {
    return const RecordedActivity(id: 'joinedCongregationLate');
  }
  if (roll < 0.86) {
    return const RecordedActivity(id: 'smallCongregation');
  }
  if (roll < 0.93) {
    return const RecordedActivity(id: 'missedMadeUp');
  }
  return const RecordedActivity(id: 'missed');
}

RecordedActivity _quranActivity(
  QuranDimension dimension,
  bool friday,
  Random random,
) {
  final roll = random.nextDouble() + (friday ? 0.08 : 0);
  if (roll < 0.18) {
    return const RecordedActivity(id: ActivityIds.unanswered);
  }
  if (roll > 0.82) {
    return const RecordedActivity(id: ActivityIds.noActivity);
  }
  final catalog = ActivityCatalog.forQuran(dimension)
      .where(
        (option) =>
            option.ternary == TernaryOutcome.positive &&
            option.id != ActivityIds.other,
      )
      .toList();
  if (catalog.isEmpty) {
    return const RecordedActivity(id: ActivityIds.unanswered);
  }
  return RecordedActivity(id: catalog[random.nextInt(catalog.length)].id);
}

DhikrStatus _dhikrStatus(bool weekend, Random random) {
  final roll = random.nextDouble() + (weekend ? 0.05 : 0);
  if (roll < 0.20) return DhikrStatus.unanswered;
  if (roll < 0.78) return DhikrStatus.practised;
  return DhikrStatus.didNot;
}

ConductStatus _conductStatus(Random random) {
  return _pick(random, [
    (0.34, ConductStatus.unanswered),
    (0.72, ConductStatus.noted),
    (1.0, ConductStatus.didNot),
  ]);
}

String _dhikrActivityId(DhikrStatus status) => switch (status) {
  DhikrStatus.unanswered => ActivityIds.unanswered,
  DhikrStatus.didNot => ActivityIds.noActivity,
  DhikrStatus.practised => 'dailyRemembrance',
};

String _conductActivityId(ConductStatus status) => switch (status) {
  ConductStatus.unanswered => ActivityIds.unanswered,
  ConductStatus.didNot => ActivityIds.noActivity,
  ConductStatus.noted => 'kindness',
};

T _pick<T>(Random random, List<(double, T)> table) {
  final roll = random.nextDouble();
  for (final entry in table) {
    if (roll < entry.$1) return entry.$2;
  }
  return table.last.$2;
}
