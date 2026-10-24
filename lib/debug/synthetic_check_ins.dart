import 'dart:math';

import '../domain/activities.dart';
import '../domain/akhlaq_practices.dart';
import '../domain/context_catalog.dart';
import '../domain/daily_check_in.dart';
import '../domain/date_key.dart';
import '../domain/dhikr_context.dart';
import '../domain/fasting_practices.dart';
import '../domain/home_traces.dart';
import '../domain/huquq_practices.dart';
import '../domain/other_domains.dart';
import '../domain/personal_response.dart';
import '../domain/prayer.dart';
import '../domain/quran.dart';
import '../domain/quran_duration.dart';
import '../domain/recorded_context.dart';
import '../domain/salah_factors.dart';

const int kSyntheticWindowDays = 120;
const String kSampleDataNotice =
    'These records are sample/demo data. You can edit them. They stay until you remove them.';

enum _SampleEra { earlier, middle, recent }

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
    records.add(_day(key, parseDateKey(key), now, random));
  }
  return SyntheticCheckInPlan(
    records: _withRecognitionClusters(records, now: now),
    missingDateKeys: missing.toList()..sort(),
    responses: _sampleResponses(now),
  );
}

_SampleEra _eraFor(DateTime date, DateTime now) {
  final ago = now.difference(DateTime(date.year, date.month, date.day)).inDays;
  if (ago <= 30) return _SampleEra.recent;
  if (ago <= 75) return _SampleEra.middle;
  return _SampleEra.earlier;
}

List<PersonalResponse> _sampleResponses(DateTime now) {
  return [
    PersonalResponse(
      id: 'sample-response-ponder',
      text: 'Looking at the last 30 days, more Fajr congregation marks sit next to “alarm worked.” I may keep that cue. Empty days stay empty.',
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
      text: 'I noticed more Morning Adhkar ticks in the recent window than earlier. That is what I recorded — not a grade.',
      createdAt: now.subtract(const Duration(days: 40)),
      synthetic: true,
      provenance: const ResponseProvenance(
        originType: ProvenanceOrigin.progressDimension,
        domain: 'dhikr',
        subject: 'morningAdhkar',
        periodDays: 90,
        labelSnapshot: 'Morning Adhkar (sample 90 days)',
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
  final older90 = [
    for (final key in last90)
      if (!last30.contains(key)) key,
  ];

  void cluster({
    required List<String> windowKeys,
    required QuranDimension subject,
    required TernaryOutcome outcome,
    required String factorId,
    required String durationId,
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
      record = record.withQuranActivity(
        subject,
        RecordedActivity(id: durationId),
      );
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
    windowKeys: older90,
    subject: QuranDimension.consciousApplication,
    outcome: TernaryOutcome.positive,
    factorId: 'quran.studyCircle',
    durationId: QuranDurationIds.min10to15,
    target: 16,
  );
  cluster(
    windowKeys: last30,
    subject: QuranDimension.meaning,
    outcome: TernaryOutcome.positive,
    factorId: 'routine',
    durationId: QuranDurationIds.min15to20,
    target: 16,
  );
  cluster(
    windowKeys: last30,
    subject: QuranDimension.consciousApplication,
    outcome: TernaryOutcome.positive,
    factorId: 'routine',
    durationId: QuranDurationIds.min15to20,
    target: 12,
  );
  cluster(
    windowKeys: older90,
    subject: QuranDimension.meaning,
    outcome: TernaryOutcome.negative,
    factorId: 'fatigue',
    durationId: QuranDurationIds.notNoticed,
    target: 10,
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

DailyCheckIn _day(String key, DateTime date, DateTime now, Random random) {
  final era = _eraFor(date, now);
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
    record = record.withSalahActivity(
      id,
      _salahActivity(id, friday, era, random),
    );
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
    tahajjud: _voluntaryTernary(era, random, unansweredBias: 0.08),
    ishraq: _voluntaryTernary(era, random, unansweredBias: 0.10),
    tawbah: _voluntaryTernary(era, random, unansweredBias: 0.12),
  );
  if (_factorChance(era, random)) {
    record = record.withSalahFactors(
      PrayerId.fajr.name,
      SalahFactorCapture(
        supportIds: era == _SampleEra.recent && random.nextDouble() < 0.72
            ? const ['salah.alarmWorked']
            : era == _SampleEra.earlier
            ? const []
            : random.nextDouble() < 0.45
            ? const ['salah.alarmWorked']
            : const [],
        challengeIds: era == _SampleEra.earlier && random.nextDouble() < 0.7
            ? const ['salah.overslept']
            : era == _SampleEra.recent
            ? const []
            : random.nextDouble() < 0.4
            ? const ['salah.overslept']
            : const [],
      ),
    );
  }

  for (final dimension in quranDailyDimensions) {
    if (dimension == QuranDimension.consciousApplication) continue;
    record = record.withQuranActivity(
      dimension,
      RecordedActivity(id: _durationId(era, friday, random)),
    );
  }

  record = _withDhikrCaptures(record, era, random);

  record = record.copyWith(
    conduct: _conductStatus(era, random),
    gratitudeStatus: monthEnd
        ? EntryStatus.recorded
        : _pick(random, [
            (era == _SampleEra.recent ? 0.28 : 0.42, EntryStatus.unanswered),
            (0.70, EntryStatus.noneToday),
            (1.0, EntryStatus.recorded),
          ]),
    gratitudeText: monthEnd
        ? 'A recorded gratitude note for this sample day.'
        : null,
    personalReflectionStatus: _pick(random, [
      (era == _SampleEra.recent ? 0.38 : 0.52, EntryStatus.unanswered),
      (0.78, EntryStatus.noneToday),
      (1.0, EntryStatus.recorded),
    ]),
    zakat: date.day == 1
        ? ZakatStatus.planned
        : date.month == 9 && date.day == 15
        ? ZakatStatus.due
        : random.nextDouble() < 0.04
        ? ZakatStatus.notApplicable
        : ZakatStatus.unanswered,
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
    ActivityCatalog.conductKey,
    RecordedActivity(id: _conductActivityId(record.conduct)),
  );

  record = _withLiveHomeTraces(
    record,
    date: date,
    era: era,
    random: random,
    mondayThursday: mondayThursday,
    whiteDays: whiteDays,
    weekend: weekend,
    monthEnd: monthEnd,
  );

  if (random.nextDouble() < (era == _SampleEra.recent ? 0.08 : 0.14)) {
    record = record.copyWith(
      akhlaqStruggleNote: 'I was impatient today, but I caught myself.',
    );
  }

  for (final dimension in quranDailyDimensions) {
    final outcome = record.quranOutcome(dimension);
    if (!contextAllowed(dimension, outcome)) continue;
    if (random.nextDouble() > _contextChance(era)) continue;
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

DailyCheckIn _withDhikrCaptures(
  DailyCheckIn record,
  _SampleEra era,
  Random random,
) {
  record = _fillDhikrRow(
    record,
    kDhikrMorningKey,
    _dhikrTickCount(era, random, recentMin: 2, recentSpan: 3),
    random,
    era,
  );
  record = _fillDhikrRow(
    record,
    kDhikrEveningKey,
    _dhikrTickCount(era, random, recentMin: 2, recentSpan: 3),
    random,
    era,
  );

  final postKeys = [...kDhikrPostFardKeys]..shuffle(random);
  final postFill = switch (era) {
    _SampleEra.earlier => random.nextDouble() < 0.4 ? 1 : 0,
    _SampleEra.middle => 1 + random.nextInt(2),
    _SampleEra.recent => 3 + random.nextInt(3),
  };
  for (var i = 0; i < postFill && i < postKeys.length; i++) {
    record = _fillDhikrRow(
      record,
      postKeys[i],
      era == _SampleEra.recent ? 1 + random.nextInt(3) : 1,
      random,
      era,
    );
  }

  if (era != _SampleEra.earlier && random.nextDouble() < 0.45) {
    record = _fillDhikrRow(
      record,
      kDhikrGeneralKey,
      era == _SampleEra.recent ? 2 : 1,
      random,
      era,
    );
  }
  if (era == _SampleEra.recent && random.nextDouble() < 0.28) {
    record = _fillDhikrRow(record, kDhikrGratitudeKey, 1, random, era);
  }
  return record;
}

int _dhikrTickCount(
  _SampleEra era,
  Random random, {
  required int recentMin,
  required int recentSpan,
}) {
  return switch (era) {
    _SampleEra.earlier => random.nextDouble() < 0.38 ? 1 : 0,
    _SampleEra.middle => random.nextInt(3),
    _SampleEra.recent => recentMin + random.nextInt(recentSpan),
  };
}

DailyCheckIn _fillDhikrRow(
  DailyCheckIn record,
  String rowKey,
  int practisedCount,
  Random random,
  _SampleEra era,
) {
  final items = [...dhikrContextItemsFor(rowKey)]..shuffle(random);
  if (items.isEmpty) return record;
  if (practisedCount <= 0) {
    if (era == _SampleEra.earlier && random.nextDouble() < 0.22) {
      return record.withDhikrContextCaptures(rowKey, [
        DhikrContextCapture(
          activityId: items.first.id,
          response: DhikrContextResponse.notToday,
        ),
      ]);
    }
    return record;
  }
  final n = practisedCount.clamp(1, items.length);
  return record.withDhikrContextCaptures(rowKey, [
    for (var i = 0; i < n; i++)
      DhikrContextCapture(
        activityId: items[i].id,
        response: DhikrContextResponse.practised,
        repetitions: items[i].seedCount,
      ),
  ]);
}

DailyCheckIn _withLiveHomeTraces(
  DailyCheckIn record, {
  required DateTime date,
  required _SampleEra era,
  required Random random,
  required bool mondayThursday,
  required bool whiteDays,
  required bool weekend,
  required bool monthEnd,
}) {
  final rows = <HomeTraceRow>[
    ...akhlaqHomeRows,
    ...huquqHomeRows,
    ...charityHomeRows,
    ...hadithHomeRows,
    ...gatedFastingHomeRows(fastingHomeRows, date: date),
  ];
  for (final row in rows) {
    final catalog = ActivityCatalog.forHomeTrace(row.storageKey);
    if (catalog.isEmpty) continue;
    final id = _traceActivityId(
      row.storageKey,
      catalog: catalog,
      era: era,
      random: random,
      mondayThursday: mondayThursday,
      whiteDays: whiteDays,
      weekend: weekend,
      monthEnd: monthEnd,
    );
    if (id == null || id == ActivityIds.unanswered) continue;
    record = record.withHomeTraceActivity(
      row.storageKey,
      RecordedActivity(id: id),
    );
  }
  return record;
}

String? _traceActivityId(
  String storageKey, {
  required List<ActivityOption> catalog,
  required _SampleEra era,
  required Random random,
  required bool mondayThursday,
  required bool whiteDays,
  required bool weekend,
  required bool monthEnd,
}) {
  if (storageKey == hadithEncounterKey ||
      storageKey == hadithRetentionKey ||
      storageKey == hadithLearningKey) {
    if (random.nextDouble() < _skipChance(era, recentSkip: 0.22)) return null;
    return _durationId(era, weekend, random);
  }
  if (storageKey == hadithLivedNoticedKey) {
    return _catalogPick(
      catalog,
      _traceOutcome(era, random, recentPositive: 0.58),
    );
  }
  if (storageKey.startsWith('fasting.')) {
    final relevant =
        (storageKey == kFastingWeeklySunnahKey && mondayThursday) ||
        (storageKey == kFastingMonthlyKey && whiteDays) ||
        storageKey.startsWith('fasting.ramadan') ||
        (storageKey == kFastingMakeupKey && random.nextDouble() < 0.08);
    if (!relevant) return null;
    final outcome = relevant && era != _SampleEra.earlier
        ? _traceOutcome(era, random, recentPositive: 0.7)
        : _traceOutcome(era, random, recentPositive: 0.35);
    return _catalogPick(catalog, outcome);
  }
  if (storageKey.startsWith('charity.')) {
    if (!(monthEnd || weekend) &&
        random.nextDouble() < _skipChance(era, recentSkip: 0.55)) {
      return null;
    }
    return _catalogPick(
      catalog,
      _traceOutcome(era, random, recentPositive: 0.62),
    );
  }
  if (storageKey.startsWith('akhlaq.') || storageKey.startsWith('huquq.')) {
    if (random.nextDouble() < _skipChance(era, recentSkip: 0.38)) return null;
    final outcome = _traceOutcome(era, random, recentPositive: 0.6);
    if (outcome == TernaryOutcome.positive) {
      if (storageKey.startsWith('akhlaq.') && random.nextDouble() < 0.12) {
        return AkhlaqObservationIds.corrected;
      }
      if (storageKey.startsWith('huquq.') && random.nextDouble() < 0.12) {
        return HuquqObservationIds.correctiveAction;
      }
    }
    return _catalogPick(catalog, outcome);
  }
  return _catalogPick(catalog, _traceOutcome(era, random, recentPositive: 0.5));
}

String? _catalogPick(List<ActivityOption> catalog, TernaryOutcome outcome) {
  if (outcome == TernaryOutcome.unanswered) return null;
  final id = ActivityCatalog.canonicalTernaryId(outcome, catalog);
  if (id == ActivityIds.unanswered) return null;
  return id;
}

TernaryOutcome _traceOutcome(
  _SampleEra era,
  Random random, {
  required double recentPositive,
}) {
  return switch (era) {
    _SampleEra.earlier => _pick(random, [
      (0.58, TernaryOutcome.unanswered),
      (0.82, TernaryOutcome.negative),
      (1.0, TernaryOutcome.positive),
    ]),
    _SampleEra.middle => _pick(random, [
      (0.40, TernaryOutcome.unanswered),
      (0.62, TernaryOutcome.negative),
      (1.0, TernaryOutcome.positive),
    ]),
    _SampleEra.recent => _pick(random, [
      (1 - recentPositive - 0.16, TernaryOutcome.unanswered),
      (1 - recentPositive, TernaryOutcome.negative),
      (1.0, TernaryOutcome.positive),
    ]),
  };
}

double _skipChance(_SampleEra era, {required double recentSkip}) {
  return switch (era) {
    _SampleEra.earlier => 0.72,
    _SampleEra.middle => 0.52,
    _SampleEra.recent => recentSkip,
  };
}

RecordedActivity _salahActivity(
  PrayerId id,
  bool friday,
  _SampleEra era,
  Random random,
) {
  final roll = random.nextDouble() + (friday ? 0.05 : 0);
  switch (era) {
    case _SampleEra.earlier:
      if (roll < 0.22) {
        return const RecordedActivity(id: ActivityIds.unanswered);
      }
      if (roll < 0.40) {
        return const RecordedActivity(id: 'prayedLate');
      }
      if (roll < 0.52) {
        return const RecordedActivity(id: 'joinedCongregationLate');
      }
      if (roll < 0.64) {
        return const RecordedActivity(id: 'missedMadeUp');
      }
      if (roll < 0.74) {
        return const RecordedActivity(id: 'missed');
      }
      if (roll < 0.88) {
        return const RecordedActivity(id: 'aloneOnTime');
      }
      return const RecordedActivity(id: 'congregationOnTime');
    case _SampleEra.middle:
      if (roll < 0.14) {
        return const RecordedActivity(id: ActivityIds.unanswered);
      }
      if (friday && roll < 0.50) {
        return const RecordedActivity(id: 'congregationOnTime');
      }
      if (roll < 0.40) {
        return const RecordedActivity(id: 'aloneOnTime');
      }
      if (roll < 0.58) {
        return const RecordedActivity(id: 'prayedLate');
      }
      if (roll < 0.70) {
        return const RecordedActivity(id: 'joinedCongregationLate');
      }
      if (roll < 0.82) {
        return const RecordedActivity(id: 'smallCongregation');
      }
      if (roll < 0.92) {
        return const RecordedActivity(id: 'missedMadeUp');
      }
      return const RecordedActivity(id: 'missed');
    case _SampleEra.recent:
      if (roll < 0.10) {
        return const RecordedActivity(id: ActivityIds.unanswered);
      }
      if (friday && roll < 0.62) {
        return const RecordedActivity(id: 'congregationOnTime');
      }
      if (id == PrayerId.fajr && roll < 0.58) {
        return const RecordedActivity(id: 'congregationOnTime');
      }
      if (roll < 0.48) {
        return const RecordedActivity(id: 'congregationOnTime');
      }
      if (roll < 0.72) {
        return const RecordedActivity(id: 'aloneOnTime');
      }
      if (roll < 0.82) {
        return const RecordedActivity(id: 'smallCongregation');
      }
      if (roll < 0.92) {
        return const RecordedActivity(id: 'prayedLate');
      }
      return const RecordedActivity(id: 'missedMadeUp');
  }
}

String _durationId(_SampleEra era, bool friday, Random random) {
  final roll = random.nextDouble() + (friday ? 0.06 : 0);
  switch (era) {
    case _SampleEra.earlier:
      if (roll < 0.28) return ActivityIds.unanswered;
      if (roll < 0.52) return QuranDurationIds.notNoticed;
      if (roll < 0.78) return QuranDurationIds.min3to5;
      return QuranDurationIds.min5to10;
    case _SampleEra.middle:
      if (roll < 0.16) return ActivityIds.unanswered;
      if (roll < 0.28) return QuranDurationIds.notNoticed;
      if (roll < 0.52) return QuranDurationIds.min5to10;
      if (roll < 0.78) return QuranDurationIds.min10to15;
      return QuranDurationIds.min3to5;
    case _SampleEra.recent:
      if (roll < 0.10) return ActivityIds.unanswered;
      if (roll < 0.16) return QuranDurationIds.notNoticed;
      if (roll < 0.36) return QuranDurationIds.min10to15;
      if (roll < 0.68) return QuranDurationIds.min15to20;
      if (roll < 0.88) return QuranDurationIds.over20;
      return QuranDurationIds.min5to10;
  }
}

TernaryOutcome _voluntaryTernary(
  _SampleEra era,
  Random random, {
  required double unansweredBias,
}) {
  final unanswered = switch (era) {
    _SampleEra.earlier => 0.68 + unansweredBias,
    _SampleEra.middle => 0.55 + unansweredBias,
    _SampleEra.recent => 0.42 + unansweredBias,
  }.clamp(0.35, 0.85);
  return _pick(random, [
    (unanswered, TernaryOutcome.unanswered),
    (unanswered + 0.22, TernaryOutcome.positive),
    (1.0, TernaryOutcome.negative),
  ]);
}

bool _factorChance(_SampleEra era, Random random) {
  final p = switch (era) {
    _SampleEra.earlier => 0.18,
    _SampleEra.middle => 0.28,
    _SampleEra.recent => 0.42,
  };
  return random.nextDouble() < p;
}

double _contextChance(_SampleEra era) {
  return switch (era) {
    _SampleEra.earlier => 0.22,
    _SampleEra.middle => 0.32,
    _SampleEra.recent => 0.48,
  };
}

ConductStatus _conductStatus(_SampleEra era, Random random) {
  return switch (era) {
    _SampleEra.earlier => _pick(random, [
      (0.48, ConductStatus.unanswered),
      (0.72, ConductStatus.noted),
      (1.0, ConductStatus.didNot),
    ]),
    _SampleEra.middle => _pick(random, [
      (0.34, ConductStatus.unanswered),
      (0.74, ConductStatus.noted),
      (1.0, ConductStatus.didNot),
    ]),
    _SampleEra.recent => _pick(random, [
      (0.24, ConductStatus.unanswered),
      (0.82, ConductStatus.noted),
      (1.0, ConductStatus.didNot),
    ]),
  };
}

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
