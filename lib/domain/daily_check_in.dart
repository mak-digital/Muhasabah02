import 'activities.dart';
import 'home_traces.dart';
import 'other_domains.dart';
import 'prayer.dart';
import 'quran.dart';
import 'recorded_context.dart';
import 'salah_factors.dart';
import 'situation_notes.dart';

const int kDailyCheckInSchemaVersion = 6;
const int kRecordableFieldCount = 10;

class DailyCheckIn {
  const DailyCheckIn({
    required this.dateKey,
    this.schemaVersion = kDailyCheckInSchemaVersion,
    this.savedAt,
    this.salah = const {
      PrayerId.fajr: PrayerStatus.unanswered,
      PrayerId.dhuhr: PrayerStatus.unanswered,
      PrayerId.asr: PrayerStatus.unanswered,
      PrayerId.maghrib: PrayerStatus.unanswered,
      PrayerId.isha: PrayerStatus.unanswered,
    },
    this.quran = const {
      QuranDimension.reading: TernaryOutcome.unanswered,
      QuranDimension.meaning: TernaryOutcome.unanswered,
      QuranDimension.memorisation: TernaryOutcome.unanswered,
      QuranDimension.revision: TernaryOutcome.unanswered,
      QuranDimension.tafsir: TernaryOutcome.unanswered,
      QuranDimension.reflection: TernaryOutcome.unanswered,
      QuranDimension.consciousApplication: TernaryOutcome.unanswered,
      QuranDimension.applicationReflection: TernaryOutcome.unanswered,
    },
    this.dhikr = DhikrStatus.unanswered,
    this.conduct = ConductStatus.unanswered,
    this.gratitudeStatus = EntryStatus.unanswered,
    this.gratitudeText,
    this.personalReflectionStatus = EntryStatus.unanswered,
    this.personalReflectionText,
    this.fasting = const DomainObservation(),
    this.charity = const DomainObservation(),
    this.zakat = ZakatStatus.unanswered,
    this.family = const DomainObservation(),
    this.hadith = const DomainObservation(),
    this.activities = const {},
    this.contexts = const [],
    this.jumuah = PrayerStatus.unanswered,
    this.tahajjud = TernaryOutcome.unanswered,
    this.ishraq = TernaryOutcome.unanswered,
    this.jumuahCongregation = false,
    this.salahFactors = const {},
    this.homeTraces = const {},
    this.homeTraceFactors = const {},
    this.situationNotes = const SituationNotes(),
    this.akhlaqStruggleNote,
    this.synthetic = false,
  });

  final int schemaVersion;
  final String dateKey;
  final DateTime? savedAt;
  final Map<PrayerId, PrayerStatus> salah;
  final Map<QuranDimension, TernaryOutcome> quran;
  final DhikrStatus dhikr;
  final ConductStatus conduct;
  final EntryStatus gratitudeStatus;
  final String? gratitudeText;
  final EntryStatus personalReflectionStatus;
  final String? personalReflectionText;
  final DomainObservation fasting;
  final DomainObservation charity;
  final ZakatStatus zakat;
  final DomainObservation family;
  final DomainObservation hadith;
  final Map<String, RecordedActivity> activities;
  final List<RecordedContext> contexts;
  final PrayerStatus jumuah;
  final TernaryOutcome tahajjud;
  final TernaryOutcome ishraq;
  final bool jumuahCongregation;
  final Map<String, SalahFactorCapture> salahFactors;
  final Map<String, TernaryOutcome> homeTraces;
  final Map<String, SalahFactorCapture> homeTraceFactors;
  final SituationNotes situationNotes;
  final String? akhlaqStruggleNote;
  final bool synthetic;

  TernaryOutcome homeTrace(String storageKey) =>
      homeTraces[storageKey] ?? TernaryOutcome.unanswered;

  /// Any observation that day for these rows. Not a score.
  bool homeTraceDayRecorded({
    required List<HomeTraceRow> rows,
    bool includeZakat = false,
    bool includeStruggleNote = false,
  }) {
    for (final row in rows) {
      if (homeTrace(row.storageKey).isRecorded) return true;
    }
    if (includeZakat && zakat.isRecorded) return true;
    if (includeStruggleNote &&
        akhlaqStruggleNote != null &&
        akhlaqStruggleNote!.trim().isNotEmpty) {
      return true;
    }
    final prefix = rows.isEmpty ? '' : rows.first.storageKey.split('.').first;
    return switch (prefix) {
      'dhikr' => dhikr.isRecorded,
      'fasting' => fasting.isRecorded,
      'family' => family.isRecorded,
      'charity' => charity.isRecorded,
      'hadith' => hadith.isRecorded,
      _ => false,
    };
  }

  factory DailyCheckIn.empty(String dateKey) => DailyCheckIn(dateKey: dateKey);

  PrayerStatus prayer(PrayerId id) => salah[id] ?? PrayerStatus.unanswered;

  TernaryOutcome quranOutcome(QuranDimension dimension) =>
      quran[dimension] ?? TernaryOutcome.unanswered;

  RecordedActivity activityFor(String key) {
    final stored = activities[key];
    if (stored != null) return stored;
    if (key.startsWith('salah.')) {
      final name = key.substring(6);
      final id = PrayerId.values.where((item) => item.name == name);
      if (id.isNotEmpty) {
        return RecordedActivity(
          id: ActivityCatalog.canonicalSalahId(prayer(id.first)),
        );
      }
    }
    if (key.startsWith('quran.')) {
      final name = key.substring(6);
      final dimension = QuranDimension.values.where(
        (item) => item.name == name,
      );
      if (dimension.isNotEmpty) {
        return RecordedActivity(
          id: ActivityCatalog.canonicalTernaryId(
            quranOutcome(dimension.first),
            ActivityCatalog.forQuran(dimension.first),
          ),
        );
      }
    }
    if (key == ActivityCatalog.dhikrKey) {
      return RecordedActivity(
        id: switch (dhikr) {
          DhikrStatus.unanswered => ActivityIds.unanswered,
          DhikrStatus.didNot => ActivityIds.noActivity,
          DhikrStatus.practised => 'dailyRemembrance',
        },
      );
    }
    if (key == ActivityCatalog.conductKey) {
      return RecordedActivity(
        id: switch (conduct) {
          ConductStatus.unanswered => ActivityIds.unanswered,
          ConductStatus.didNot => ActivityIds.noActivity,
          ConductStatus.noted => 'kindness',
        },
      );
    }
    if (key == ActivityCatalog.gratitudeKey) {
      return RecordedActivity(
        id: switch (gratitudeStatus) {
          EntryStatus.unanswered => ActivityIds.unanswered,
          EntryStatus.noneToday => ActivityIds.noActivity,
          EntryStatus.recorded => 'namedBlessing',
        },
      );
    }
    if (key == ActivityCatalog.reflectionKey) {
      return RecordedActivity(
        id: switch (personalReflectionStatus) {
          EntryStatus.unanswered => ActivityIds.unanswered,
          EntryStatus.noneToday => ActivityIds.noActivity,
          EntryStatus.recorded => 'privateNote',
        },
      );
    }
    return const RecordedActivity(id: ActivityIds.unanswered);
  }

  RecordedContext? contextFor(QuranDimension subject, String polarity) {
    for (final item in contexts) {
      if (item.subject == subject && item.polarity == polarity) return item;
    }
    return null;
  }

  int get answeredRecordableCount {
    var count = 0;
    for (final id in PrayerId.values) {
      if (prayer(id).isRecorded) count++;
    }
    if (quranOutcome(QuranDimension.reading).isRecorded) count++;
    if (dhikr.isRecorded) count++;
    if (conduct.isRecorded) count++;
    if (gratitudeStatus.isRecorded) count++;
    if (personalReflectionStatus.isRecorded) count++;
    return count;
  }

  bool get hasAnyRecordedEvidence {
    if (answeredRecordableCount > 0) return true;
    for (final dimension in quranDailyDimensions) {
      if (quranOutcome(dimension).isRecorded) return true;
    }
    if (fasting.isRecorded ||
        charity.isRecorded ||
        zakat.isRecorded ||
        family.isRecorded ||
        hadith.isRecorded) {
      return true;
    }
    if (jumuah.isRecorded ||
        tahajjud.isRecorded ||
        ishraq.isRecorded ||
        jumuahCongregation ||
        salahFactors.isNotEmpty) {
      return true;
    }
    if (homeTraces.values.any((outcome) => outcome.isRecorded)) {
      return true;
    }
    if (homeTraceFactors.values.any((item) => !item.isEmpty) ||
        !situationNotes.isEmpty) {
      return true;
    }
    if (akhlaqStruggleNote != null && akhlaqStruggleNote!.trim().isNotEmpty) {
      return true;
    }
    return contexts.isNotEmpty;
  }

  DailyCheckIn copyWith({
    int? schemaVersion,
    DateTime? savedAt,
    Map<PrayerId, PrayerStatus>? salah,
    Map<QuranDimension, TernaryOutcome>? quran,
    DhikrStatus? dhikr,
    ConductStatus? conduct,
    EntryStatus? gratitudeStatus,
    String? gratitudeText,
    bool clearGratitudeText = false,
    EntryStatus? personalReflectionStatus,
    String? personalReflectionText,
    bool clearPersonalReflectionText = false,
    DomainObservation? fasting,
    DomainObservation? charity,
    ZakatStatus? zakat,
    DomainObservation? family,
    DomainObservation? hadith,
    Map<String, RecordedActivity>? activities,
    List<RecordedContext>? contexts,
    PrayerStatus? jumuah,
    TernaryOutcome? tahajjud,
    TernaryOutcome? ishraq,
    bool? jumuahCongregation,
    Map<String, SalahFactorCapture>? salahFactors,
    Map<String, TernaryOutcome>? homeTraces,
    Map<String, SalahFactorCapture>? homeTraceFactors,
    SituationNotes? situationNotes,
    String? akhlaqStruggleNote,
    bool clearAkhlaqStruggleNote = false,
    bool? synthetic,
  }) {
    return DailyCheckIn(
      dateKey: dateKey,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      savedAt: savedAt ?? this.savedAt,
      salah: salah ?? this.salah,
      quran: quran ?? this.quran,
      dhikr: dhikr ?? this.dhikr,
      conduct: conduct ?? this.conduct,
      gratitudeStatus: gratitudeStatus ?? this.gratitudeStatus,
      gratitudeText: clearGratitudeText
          ? null
          : (gratitudeText ?? this.gratitudeText),
      personalReflectionStatus:
          personalReflectionStatus ?? this.personalReflectionStatus,
      personalReflectionText: clearPersonalReflectionText
          ? null
          : (personalReflectionText ?? this.personalReflectionText),
      fasting: fasting ?? this.fasting,
      charity: charity ?? this.charity,
      zakat: zakat ?? this.zakat,
      family: family ?? this.family,
      hadith: hadith ?? this.hadith,
      activities: activities ?? this.activities,
      contexts: contexts ?? this.contexts,
      jumuah: jumuah ?? this.jumuah,
      tahajjud: tahajjud ?? this.tahajjud,
      ishraq: ishraq ?? this.ishraq,
      jumuahCongregation: jumuahCongregation ?? this.jumuahCongregation,
      salahFactors: salahFactors ?? this.salahFactors,
      homeTraces: homeTraces ?? this.homeTraces,
      homeTraceFactors: homeTraceFactors ?? this.homeTraceFactors,
      situationNotes: situationNotes ?? this.situationNotes,
      akhlaqStruggleNote: clearAkhlaqStruggleNote
          ? null
          : (akhlaqStruggleNote ?? this.akhlaqStruggleNote),
      synthetic: synthetic ?? this.synthetic,
    );
  }

  DailyCheckIn withActivity(String key, RecordedActivity activity) {
    return copyWith(activities: {...activities, key: activity});
  }

  DailyCheckIn withPrayer(PrayerId id, PrayerStatus status) {
    return copyWith(
      salah: {...salah, id: status},
      activities: {
        ...activities,
        ActivityCatalog.salahKey(id): RecordedActivity(
          id: ActivityCatalog.canonicalSalahId(status),
        ),
      },
    );
  }

  DailyCheckIn withSalahActivity(PrayerId id, RecordedActivity activity) {
    final option = ActivityCatalog.find(ActivityCatalog.salah, activity.id);
    final status = option?.prayerStatus ?? PrayerStatus.unanswered;
    return copyWith(
      salah: {...salah, id: status},
      activities: {...activities, ActivityCatalog.salahKey(id): activity},
    );
  }

  DailyCheckIn withQuran(QuranDimension dimension, TernaryOutcome outcome) {
    if (!canSetQuranOutcome(
      quran: quran,
      dimension: dimension,
      outcome: outcome,
    )) {
      return this;
    }
    var nextQuran = {...quran, dimension: outcome};
    if (dimension == QuranDimension.meaning &&
        outcome == TernaryOutcome.positive) {
      nextQuran[QuranDimension.reading] = TernaryOutcome.positive;
    }
    final nextContexts = contexts.where((c) {
      final current = nextQuran[c.subject] ?? TernaryOutcome.unanswered;
      if (!contextAllowed(c.subject, current)) return false;
      if (c.polarity == 'positive') return current == TernaryOutcome.positive;
      if (c.polarity == 'negative') return current == TernaryOutcome.negative;
      return false;
    }).toList();
    final activitiesNext = {...activities};
    void writeActivity(QuranDimension dim, TernaryOutcome value) {
      final catalog = ActivityCatalog.forQuran(dim);
      final canonical = catalog.isEmpty
          ? ActivityIds.unanswered
          : ActivityCatalog.canonicalTernaryId(value, catalog);
      activitiesNext[ActivityCatalog.quranKey(dim)] = RecordedActivity(
        id: canonical,
      );
    }

    writeActivity(dimension, outcome);
    if (dimension == QuranDimension.meaning &&
        outcome == TernaryOutcome.positive) {
      writeActivity(QuranDimension.reading, TernaryOutcome.positive);
    }
    return copyWith(
      quran: nextQuran,
      contexts: nextContexts,
      activities: activitiesNext,
    );
  }

  DailyCheckIn withQuranActivity(
    QuranDimension dimension,
    RecordedActivity activity,
  ) {
    final option = ActivityCatalog.find(
      ActivityCatalog.forQuran(dimension),
      activity.id,
    );
    final outcome = option?.ternary ?? TernaryOutcome.unanswered;
    if (!canSetQuranOutcome(
      quran: quran,
      dimension: dimension,
      outcome: outcome,
    )) {
      return this;
    }
    return withQuran(
      dimension,
      outcome,
    ).withActivity(ActivityCatalog.quranKey(dimension), activity);
  }

  DailyCheckIn withSalahFactors(String subject, SalahFactorCapture capture) {
    final next = {...salahFactors};
    if (capture.isEmpty) {
      next.remove(subject);
    } else {
      next[subject] = capture;
    }
    return copyWith(salahFactors: next);
  }

  DailyCheckIn withHomeTrace(String storageKey, TernaryOutcome outcome) {
    final next = {...homeTraces};
    if (outcome == TernaryOutcome.unanswered) {
      next.remove(storageKey);
    } else {
      next[storageKey] = outcome;
    }
    return copyWith(homeTraces: next);
  }

  DailyCheckIn withHomeTraceFactors(
    String storageKey,
    SalahFactorCapture capture,
  ) {
    final next = {...homeTraceFactors};
    if (capture.isEmpty) {
      next.remove(storageKey);
    } else {
      next[storageKey] = capture;
    }
    return copyWith(homeTraceFactors: next);
  }

  DailyCheckIn withContext(RecordedContext context) {
    final outcome = quranOutcome(context.subject);
    if (!contextAllowed(context.subject, outcome)) return this;
    if (context.polarity == 'positive' && outcome != TernaryOutcome.positive) {
      return this;
    }
    if (context.polarity == 'negative' && outcome != TernaryOutcome.negative) {
      return this;
    }
    final next = [
      ...contexts.where(
        (c) =>
            !(c.subject == context.subject && c.polarity == context.polarity),
      ),
      context,
    ];
    return copyWith(contexts: next);
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'dateKey': dateKey,
      if (savedAt != null) 'savedAt': savedAt!.toIso8601String(),
      'salah': {
        for (final id in PrayerId.values) id.name: prayer(id).jsonValue,
      },
      'quran': {
        for (final dimension in QuranDimension.values)
          dimension.name: ternaryToJson(dimension, quranOutcome(dimension)),
      },
      'dhikr': dhikr.name,
      'conduct': conduct.name,
      'gratitude': {
        'status': gratitudeStatus.name,
        if (gratitudeText != null) 'text': gratitudeText,
      },
      'personalReflection': {
        'status': personalReflectionStatus.name,
        if (personalReflectionText != null) 'text': personalReflectionText,
      },
      'fasting': fasting.toJson(),
      'charity': charity.toJson(),
      'zakat': zakat.name,
      'family': family.toJson(),
      'hadith': hadith.toJson(),
      'activities': {
        for (final entry in activities.entries)
          if (entry.value.id != ActivityIds.unanswered)
            entry.key: entry.value.toJson(),
      },
      'contexts': contexts.map((c) => c.toJson()).toList(),
      if (jumuah.isRecorded ||
          tahajjud.isRecorded ||
          ishraq.isRecorded ||
          jumuahCongregation ||
          salahFactors.isNotEmpty)
        'salahTrace': {
          if (jumuah.isRecorded) 'jumuah': jumuah.jsonValue,
          if (tahajjud.isRecorded) 'tahajjud': tahajjud.name,
          if (ishraq.isRecorded) 'ishraq': ishraq.name,
          if (jumuahCongregation) 'jumuahCongregation': true,
          if (salahFactors.isNotEmpty)
            'factors': {
              for (final entry in salahFactors.entries)
                if (!entry.value.isEmpty) entry.key: entry.value.toJson(),
            },
        },
      if (tracesToJson(homeTraces).isNotEmpty)
        'homeTraces': tracesToJson(homeTraces),
      if (homeTraceFactors.values.any((item) => !item.isEmpty))
        'homeTraceFactors': {
          for (final entry in homeTraceFactors.entries)
            if (!entry.value.isEmpty) entry.key: entry.value.toJson(),
        },
      if (!situationNotes.isEmpty) 'situationNotes': situationNotes.toJson(),
      if (akhlaqStruggleNote != null && akhlaqStruggleNote!.trim().isNotEmpty)
        'akhlaqStruggleNote': akhlaqStruggleNote,
      if (synthetic) 'synthetic': true,
    };
  }

  static DailyCheckIn fromJson(Map<String, dynamic> json) {
    final date = json['dateKey'] as String?;
    if (date == null || date.isEmpty) {
      throw const FormatException('Missing dateKey');
    }
    final schema = json['schemaVersion'];
    final version = schema is int
        ? schema
        : int.tryParse('$schema') ?? kDailyCheckInSchemaVersion;

    final salahJson = json['salah'];
    final salah = <PrayerId, PrayerStatus>{};
    for (final id in PrayerId.values) {
      Object? raw;
      if (salahJson is Map) raw = salahJson[id.name];
      salah[id] = prayerStatusFromJson(raw);
    }

    final quranJson = json['quran'];
    final quran = <QuranDimension, TernaryOutcome>{};
    for (final dimension in QuranDimension.values) {
      Object? raw;
      if (quranJson is Map) raw = quranJson[dimension.name];
      quran[dimension] = ternaryFromJson(raw);
    }

    final gratitudeJson = json['gratitude'];
    EntryStatus gratitudeStatus = EntryStatus.unanswered;
    String? gratitudeText;
    if (gratitudeJson is Map) {
      gratitudeStatus = entryStatusFromJson(gratitudeJson['status']);
      final text = gratitudeJson['text'];
      if (text is String && text.trim().isNotEmpty) {
        gratitudeText = text;
        if (gratitudeStatus == EntryStatus.unanswered) {
          gratitudeStatus = EntryStatus.recorded;
        }
      }
    }

    final reflectionJson = json['personalReflection'];
    EntryStatus reflectionStatus = EntryStatus.unanswered;
    String? reflectionText;
    if (reflectionJson is Map) {
      reflectionStatus = entryStatusFromJson(reflectionJson['status']);
      final text = reflectionJson['text'];
      if (text is String && text.trim().isNotEmpty) {
        reflectionText = text;
        if (reflectionStatus == EntryStatus.unanswered) {
          reflectionStatus = EntryStatus.recorded;
        }
      }
    }

    final rawContexts = json['contexts'];
    final contexts = <RecordedContext>[];
    if (rawContexts is List) {
      for (final item in rawContexts) {
        final parsed = RecordedContext.fromJson(item);
        if (parsed != null) contexts.add(parsed);
      }
    }

    final activities = <String, RecordedActivity>{};
    final rawActivities = json['activities'];
    if (rawActivities is Map) {
      for (final entry in rawActivities.entries) {
        activities['${entry.key}'] = RecordedActivity.fromJson(entry.value);
      }
    }

    DateTime? savedAt;
    final rawSaved = json['savedAt'];
    if (rawSaved is String) {
      savedAt = DateTime.tryParse(rawSaved);
    }

    PrayerStatus jumuah = PrayerStatus.unanswered;
    TernaryOutcome tahajjud = TernaryOutcome.unanswered;
    TernaryOutcome ishraq = TernaryOutcome.unanswered;
    var jumuahCongregation = false;
    final salahFactors = <String, SalahFactorCapture>{};
    final traceJson = json['salahTrace'];
    if (traceJson is Map) {
      jumuah = prayerStatusFromJson(traceJson['jumuah']);
      tahajjud = ternaryFromJson(traceJson['tahajjud']);
      ishraq = ternaryFromJson(traceJson['ishraq']);
      jumuahCongregation = traceJson['jumuahCongregation'] == true;
      final factorsJson = traceJson['factors'];
      if (factorsJson is Map) {
        for (final entry in factorsJson.entries) {
          final parsed = SalahFactorCapture.fromJson(entry.value);
          if (parsed != null) salahFactors['${entry.key}'] = parsed;
        }
      }
    }

    return DailyCheckIn(
      dateKey: date,
      schemaVersion: version,
      savedAt: savedAt,
      salah: salah,
      quran: quran,
      dhikr: dhikrFromJson(json['dhikr']),
      conduct: conductFromJson(json['conduct']),
      gratitudeStatus: gratitudeStatus,
      gratitudeText: gratitudeText,
      personalReflectionStatus: reflectionStatus,
      personalReflectionText: reflectionText,
      fasting: DomainObservation.fromJson(json['fasting']),
      charity: DomainObservation.fromJson(json['charity']),
      zakat: zakatFromJson(json['zakat']),
      family: DomainObservation.fromJson(json['family']),
      hadith: DomainObservation.fromJson(json['hadith']),
      activities: activities,
      contexts: contexts,
      jumuah: jumuah,
      tahajjud: tahajjud,
      ishraq: ishraq,
      jumuahCongregation: jumuahCongregation,
      salahFactors: salahFactors,
      homeTraces: tracesFromJson(json['homeTraces']),
      homeTraceFactors: _factorsMap(json['homeTraceFactors']),
      situationNotes: SituationNotes.fromJson(json['situationNotes']),
      akhlaqStruggleNote: _optionalNote(json['akhlaqStruggleNote']),
      synthetic: json['synthetic'] == true,
    );
  }

  static String? _optionalNote(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static Map<String, SalahFactorCapture> _factorsMap(Object? json) {
    if (json is! Map) return const {};
    final map = <String, SalahFactorCapture>{};
    for (final entry in json.entries) {
      final parsed = SalahFactorCapture.fromJson(entry.value);
      if (parsed != null) map['${entry.key}'] = parsed;
    }
    return map;
  }
}
