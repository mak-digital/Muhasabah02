import 'akhlaq_practices.dart';
import 'dhikr_context.dart';
import 'home_traces.dart';
import 'huquq_practices.dart';
import 'knowledge_practices.dart';
import 'health_practices.dart';
import 'charity_practices.dart';
import 'ummah_practices.dart';
import 'wealth_practices.dart';
import 'time_practices.dart';
import 'fasting_practices.dart';
import 'other_domains.dart';
import 'prayer.dart';
import 'quran.dart';
import 'quran_duration.dart';
import 'salah_extras.dart';
import 'worship_list_gender.dart';

class ActivityIds {
  static const unanswered = 'unanswered';
  static const noActivity = 'noActivity';
  static const other = 'other';
  static const acted = 'acted';
  static const noticedNotActed = 'noticedNotActed';
  static const noSituation = 'noSituation';
}

class ActivityOption {
  const ActivityOption({
    required this.id,
    required this.label,
    this.prayerStatus,
    this.ternary,
    this.dhikr,
    this.conduct,
    this.entry,
    this.zakat,
  });

  final String id;
  final String label;
  final PrayerStatus? prayerStatus;
  final TernaryOutcome? ternary;
  final DhikrStatus? dhikr;
  final ConductStatus? conduct;
  final EntryStatus? entry;
  final ZakatStatus? zakat;

  bool get isOther => id == ActivityIds.other;
  bool get isUnanswered => id == ActivityIds.unanswered;
}

class RecordedActivity {
  const RecordedActivity({required this.id, this.customText});

  final String id;
  final String? customText;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (customText != null && customText!.trim().isNotEmpty)
        'customText': customText,
    };
  }

  static RecordedActivity fromJson(Object? json) {
    if (json is! Map) {
      return const RecordedActivity(id: ActivityIds.unanswered);
    }
    final id = json['id'];
    final custom = json['customText'];
    return RecordedActivity(
      id: id is String && id.isNotEmpty ? id : ActivityIds.unanswered,
      customText: custom is String && custom.trim().isNotEmpty ? custom : null,
    );
  }
}

class DomainObservation {
  const DomainObservation({
    this.activityId = ActivityIds.unanswered,
    this.customText,
  });

  final String activityId;
  final String? customText;

  bool get isRecorded => activityId != ActivityIds.unanswered;

  TernaryOutcome get ternary {
    if (activityId == ActivityIds.unanswered) return TernaryOutcome.unanswered;
    if (activityId == ActivityIds.noActivity) return TernaryOutcome.negative;
    return TernaryOutcome.positive;
  }

  RecordedActivity get asActivity =>
      RecordedActivity(id: activityId, customText: customText);

  DomainObservation copyWith({String? activityId, String? customText}) {
    return DomainObservation(
      activityId: activityId ?? this.activityId,
      customText: customText ?? this.customText,
    );
  }

  Map<String, dynamic> toJson() => asActivity.toJson();

  static DomainObservation fromJson(Object? json) {
    final activity = RecordedActivity.fromJson(json);
    return DomainObservation(
      activityId: activity.id,
      customText: activity.customText,
    );
  }
}

enum ZakatStatus {
  unanswered,
  due,
  planned,
  paid,
  notApplicable,
  reviewing,
  preferNot,
}

/// Display order for Zakat. Stored names stay [ZakatStatus.name].
const kZakatPickerOrder = <ZakatStatus>[
  ZakatStatus.unanswered,
  ZakatStatus.paid,
  ZakatStatus.planned,
  ZakatStatus.reviewing,
  ZakatStatus.notApplicable,
  ZakatStatus.due,
  ZakatStatus.preferNot,
];

extension ZakatStatusX on ZakatStatus {
  bool get isRecorded => this != ZakatStatus.unanswered;

  String get label => switch (this) {
    ZakatStatus.unanswered => 'Not recorded',
    ZakatStatus.paid => 'Paid Zakat due',
    ZakatStatus.planned => 'Arranged or initiated payment',
    ZakatStatus.reviewing => 'Reviewing whether Zakat is due',
    ZakatStatus.notApplicable => 'Zakat not currently due',
    ZakatStatus.due => 'Zakat due but not yet paid',
    ZakatStatus.preferNot => 'Prefer not to record',
  };
}

ZakatStatus zakatFromJson(Object? value) {
  if (value is String) {
    return ZakatStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ZakatStatus.unanswered,
    );
  }
  if (value is Map) {
    return zakatFromJson(value['id']);
  }
  return ZakatStatus.unanswered;
}

class ActivityCatalog {
  static const salah = <ActivityOption>[
    ActivityOption(
      id: 'congregationOnTime',
      label: 'Prayed on time in congregation',
      prayerStatus: PrayerStatus.onTime,
    ),
    ActivityOption(
      id: 'joinedCongregationLate',
      label: 'Joined congregation late',
      prayerStatus: PrayerStatus.late,
    ),
    ActivityOption(
      id: 'smallCongregation',
      label: 'Prayed in small congregation',
      prayerStatus: PrayerStatus.onTime,
    ),
    ActivityOption(
      id: 'aloneOnTime',
      label: 'Prayed alone on time',
      prayerStatus: PrayerStatus.onTime,
    ),
    ActivityOption(
      id: 'excused',
      label: 'Excused',
      prayerStatus: PrayerStatus.excused,
    ),
    ActivityOption(
      id: 'prayedLate',
      label: 'Prayed late',
      prayerStatus: PrayerStatus.late,
    ),
    ActivityOption(
      id: 'missedMadeUp',
      label: 'Missed then made up later',
      prayerStatus: PrayerStatus.missed,
    ),
    ActivityOption(
      id: 'missed',
      label: 'Missed',
      prayerStatus: PrayerStatus.missed,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      prayerStatus: PrayerStatus.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      prayerStatus: PrayerStatus.other,
    ),
  ];

  /// Same recorded choices as obligatory Salah, with Friday wording.
  static const jumuah = <ActivityOption>[
    ActivityOption(
      id: 'congregationOnTime',
      label: 'Prayed on time in congregation',
      prayerStatus: PrayerStatus.onTime,
    ),
    ActivityOption(
      id: 'joinedCongregationLate',
      label: 'Joined congregation late',
      prayerStatus: PrayerStatus.late,
    ),
    ActivityOption(
      id: 'smallCongregation',
      label: 'Prayed in small congregation',
      prayerStatus: PrayerStatus.onTime,
    ),
    ActivityOption(
      id: 'aloneOnTime',
      label: 'Prayed alone on time',
      prayerStatus: PrayerStatus.onTime,
    ),
    ActivityOption(
      id: 'excused',
      label: 'Excused',
      prayerStatus: PrayerStatus.excused,
    ),
    ActivityOption(
      id: 'prayedLate',
      label: 'Prayed late (alone)',
      prayerStatus: PrayerStatus.late,
    ),
    ActivityOption(
      id: 'missedMadeUp',
      label: 'Missed then made up later',
      prayerStatus: PrayerStatus.missed,
    ),
    ActivityOption(
      id: 'missed',
      label: 'Missed',
      prayerStatus: PrayerStatus.missed,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      prayerStatus: PrayerStatus.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      prayerStatus: PrayerStatus.other,
    ),
  ];

  static const salahExcusedId = 'excused';

  static List<ActivityOption> obligatorySalahOptions({
    required WorshipListGender gender,
    String? selectedId,
  }) => _withoutExcusedIfMale(salah, gender, selectedId);

  static List<ActivityOption> jumuahOptions({
    required WorshipListGender gender,
    String? selectedId,
  }) => _withoutExcusedIfMale(jumuah, gender, selectedId);

  static List<ActivityOption> _withoutExcusedIfMale(
    List<ActivityOption> catalog,
    WorshipListGender gender,
    String? selectedId,
  ) {
    if (gender.showsObligatorySalahExcused) return catalog;
    return [
      for (final option in catalog)
        if (option.id != salahExcusedId || option.id == selectedId) option,
    ];
  }

  static const tahajjudEarlyMidAndLate = 'tahajjud.earlyMidAndLate';
  static const tahajjudLaterPart = 'tahajjud.laterPart';
  static const tahajjudEarlyMid = 'tahajjud.earlyMid';
  static const tahajjudNotPrayed = 'tahajjud.notPrayed';
  static const ishraqFollowingFajr = 'ishraq.followingFajr';
  static const ishraqLaterMorning = 'ishraq.laterMorning';
  static const ishraqPrayed = 'ishraq.prayed';
  static const ishraqNotPrayed = 'ishraq.notPrayed';
  static const tawbahAfterSlip = 'tawbah.afterSlip';
  static const tawbahTwoRakahs = 'tawbah.twoRakahs';
  static const tawbahPrayed = 'tawbah.prayed';
  static const tawbahNotPrayed = 'tawbah.notPrayed';

  static const tahajjud = <ActivityOption>[
    ActivityOption(
      id: tahajjudEarlyMidAndLate,
      label: 'Prayed early/mid and late at night',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: tahajjudLaterPart,
      label: 'Prayed later part of night',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: tahajjudEarlyMid,
      label: 'Prayed early/mid night',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: tahajjudNotPrayed,
      label: 'Not Prayed',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Not recorded',
      ternary: TernaryOutcome.unanswered,
    ),
  ];

  static const ishraq = <ActivityOption>[
    ActivityOption(
      id: ishraqFollowingFajr,
      label: 'Prayed following Fajr',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ishraqLaterMorning,
      label: 'Prayed later in the morning',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ishraqPrayed,
      label: 'Prayed',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ishraqNotPrayed,
      label: 'Not Prayed',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Not recorded',
      ternary: TernaryOutcome.unanswered,
    ),
  ];

  static const tawbah = <ActivityOption>[
    ActivityOption(
      id: tawbahAfterSlip,
      label: 'Prayed after a slip I noticed',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: tawbahTwoRakahs,
      label: 'Prayed two rak‘ahs',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: tawbahPrayed,
      label: 'Prayed',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: tawbahNotPrayed,
      label: 'Not Prayed',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Not recorded',
      ternary: TernaryOutcome.unanswered,
    ),
  ];

  static List<ActivityOption> quranDuration({
    required String verb,
    required String rowName,
  }) {
    return [
      ActivityOption(
        id: QuranDurationIds.over20,
        label: '$verb more than 20 minutes — $rowName',
        ternary: TernaryOutcome.positive,
      ),
      ActivityOption(
        id: QuranDurationIds.min15to20,
        label: '$verb 15–20 minutes — $rowName',
        ternary: TernaryOutcome.positive,
      ),
      ActivityOption(
        id: QuranDurationIds.min10to15,
        label: '$verb 10–15 minutes — $rowName',
        ternary: TernaryOutcome.positive,
      ),
      ActivityOption(
        id: QuranDurationIds.min5to10,
        label: '$verb 5–10 minutes — $rowName',
        ternary: TernaryOutcome.positive,
      ),
      ActivityOption(
        id: QuranDurationIds.min3to5,
        label: '$verb 3–5 minutes — $rowName',
        ternary: TernaryOutcome.positive,
      ),
      ActivityOption(
        id: QuranDurationIds.notNoticed,
        label: 'I did not notice this today — $rowName',
        ternary: TernaryOutcome.negative,
      ),
      ActivityOption(
        id: ActivityIds.unanswered,
        label: 'No answer recorded — $rowName',
        ternary: TernaryOutcome.unanswered,
      ),
      ActivityOption(
        id: ActivityIds.other,
        label: 'Other — $rowName',
        ternary: TernaryOutcome.positive,
      ),
    ];
  }

  static final quranEngagementDuration = quranDuration(
    verb: 'Engaged',
    rowName: 'Engagement',
  );
  static final quranUnderstandingDuration = quranDuration(
    verb: 'Involved',
    rowName: 'Understanding & reflection',
  );
  static final quranRelevanceDuration = quranDuration(
    verb: 'Involved',
    rowName: 'Practical relevance',
  );

  static const quranReading = <ActivityOption>[
    ActivityOption(
      id: 'readIndependently',
      label: 'Recitation',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'listened',
      label: 'Listening',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No activity',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const quranMeaning = <ActivityOption>[
    ActivityOption(
      id: 'recitedWithMeaning',
      label: 'Recitation with Meaning',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'translation',
      label: 'Read Translation',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'Did not engage with meaning/translation',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const quranMemorisation = <ActivityOption>[
    ActivityOption(
      id: 'newPortion',
      label: 'Memorisation',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'Did not practise',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const quranRevision = <ActivityOption>[
    ActivityOption(
      id: 'privateRevision',
      label: 'Revision',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'Did not practise',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const quranTafsir = <ActivityOption>[
    ActivityOption(
      id: 'readTafsir',
      label: 'Tafsir Study',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'Did not study tafsir/explanation',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const quranReflection = <ActivityOption>[
    ActivityOption(
      id: 'privateReflection',
      label: 'Brief Reflection',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'tadabbur',
      label: 'Deep Reflection (Tadabbur)',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'personalInsight',
      label: 'Something I noticed',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'Did not spend time reflecting',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const quranConsciousApplication = <ActivityOption>[
    ActivityOption(
      id: 'improvedWorship',
      label: 'Connected to worship',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'improvedCharacter',
      label: 'Connected to character',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'improvedRelationship',
      label: 'Connected to relationships',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'avoidedSin',
      label: 'Avoided something I considered wrong',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'performedGoodDeed',
      label: 'Did something I considered good',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other connection',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'Recorded as not done',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Unanswered',
      ternary: TernaryOutcome.unanswered,
    ),
  ];

  static const quranLegacy = <ActivityOption>[
    ActivityOption(
      id: 'readWithTranslation',
      label: 'Read with translation',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'readWithCommentary',
      label: 'Read with commentary',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'studyCircle',
      label: 'Study circle participation',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'familyStudy',
      label: 'Family study session',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'wordStudy',
      label: 'Word or phrase study',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'discussion',
      label: 'Discussed meaning',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'repeatPortion',
      label: 'Repeated a portion',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'withTeacher',
      label: 'With a teacher',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'recitedToSomeone',
      label: 'Recited to someone',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'groupRevision',
      label: 'Group revision',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'listenedTafsir',
      label: 'Listened to explanation',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'classTafsir',
      label: 'Attended a class',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'journaledAyah',
      label: 'Journaled about an ayah',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'sharedReflection',
      label: 'Shared a Qur’anic Reflection',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'noticedPracticalRelevance',
      label: 'Noticed a possible practical relevance',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const dhikr = <ActivityOption>[
    ActivityOption(
      id: 'morningAdhkar',
      label: 'Morning adhkar',
      dhikr: DhikrStatus.practised,
    ),
    ActivityOption(
      id: 'eveningAdhkar',
      label: 'Evening adhkar',
      dhikr: DhikrStatus.practised,
    ),
    ActivityOption(
      id: 'dailyRemembrance',
      label: 'Daily remembrance',
      dhikr: DhikrStatus.practised,
    ),
    ActivityOption(
      id: 'travelRemembrance',
      label: 'Travel remembrance',
      dhikr: DhikrStatus.practised,
    ),
    ActivityOption(
      id: 'gratitudeRemembrance',
      label: 'Gratitude remembrance',
      dhikr: DhikrStatus.practised,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No activity',
      dhikr: DhikrStatus.didNot,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      dhikr: DhikrStatus.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      dhikr: DhikrStatus.practised,
    ),
  ];

  static const conduct = <ActivityOption>[
    ActivityOption(
      id: 'patience',
      label: 'Patience in a difficult moment',
      conduct: ConductStatus.noted,
    ),
    ActivityOption(
      id: 'truthfulness',
      label: 'Truthfulness',
      conduct: ConductStatus.noted,
    ),
    ActivityOption(
      id: 'kindness',
      label: 'Kindness or forbearance',
      conduct: ConductStatus.noted,
    ),
    ActivityOption(
      id: 'apology',
      label: 'Apology or repair',
      conduct: ConductStatus.noted,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No character observation recorded',
      conduct: ConductStatus.didNot,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      conduct: ConductStatus.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      conduct: ConductStatus.noted,
    ),
  ];

  static const gratitude = <ActivityOption>[
    ActivityOption(
      id: 'namedBlessing',
      label: 'Named a blessing',
      entry: EntryStatus.recorded,
    ),
    ActivityOption(
      id: 'thankedSomeone',
      label: 'Thanked someone',
      entry: EntryStatus.recorded,
    ),
    ActivityOption(
      id: 'quietThanks',
      label: 'Quiet thanks',
      entry: EntryStatus.recorded,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No entry today',
      entry: EntryStatus.noneToday,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      entry: EntryStatus.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      entry: EntryStatus.recorded,
    ),
  ];

  static const personalReflection = <ActivityOption>[
    ActivityOption(
      id: 'noticedPattern',
      label: 'Noticed a pattern',
      entry: EntryStatus.recorded,
    ),
    ActivityOption(
      id: 'questionToKeep',
      label: 'A question to keep',
      entry: EntryStatus.recorded,
    ),
    ActivityOption(
      id: 'privateNote',
      label: 'A private note',
      entry: EntryStatus.recorded,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No entry today',
      entry: EntryStatus.noneToday,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      entry: EntryStatus.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      entry: EntryStatus.recorded,
    ),
  ];

  static const fasting = <ActivityOption>[
    ActivityOption(
      id: 'weeklySunnah',
      label: 'Weekly Sunnah fasting',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'monthlyFasting',
      label: 'Monthly fasting',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'ramadanPreparation',
      label: 'Ramadan preparation',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'makeupFast',
      label: 'Missed fast make-up',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No fasting recorded',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other fasting',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const charity = <ActivityOption>[
    ActivityOption(
      id: 'voluntaryCharity',
      label: 'Voluntary charity',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'communitySupport',
      label: 'Community support',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'educationalSupport',
      label: 'Educational support',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'familySupport',
      label: 'Family support',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'emergencySupport',
      label: 'Emergency support',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No charity recorded',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static List<ActivityOption> get zakat => [
    for (final status in kZakatPickerOrder)
      ActivityOption(
        id: status == ZakatStatus.unanswered
            ? ActivityIds.unanswered
            : status.name,
        label: status.label,
        zakat: status,
      ),
  ];

  static const family = <ActivityOption>[
    ActivityOption(
      id: 'parentCommunication',
      label: 'Parent communication',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'parentVisit',
      label: 'Parent visit',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'familyCommunication',
      label: 'Family communication',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'relativeCommunication',
      label: 'Relative communication',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'familySupport',
      label: 'Family support',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No kinship activity recorded',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static const dhikrWithAction = 'dhikr.postFard.withAction';
  static const dhikrAttentive = 'dhikr.postFard.attentive';
  static const dhikrIntentional = 'dhikr.postFard.intentional';
  static const dhikrBrief = 'dhikr.postFard.brief';

  static const dhikrPostFard = <ActivityOption>[
    ActivityOption(
      id: dhikrWithAction,
      label: 'Attentive Remembrance',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: dhikrAttentive,
      label: 'Remembered as habit',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: dhikrIntentional,
      label: 'Intentional remembrance of the most or all',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: dhikrBrief,
      label: 'Brief remembrance of some',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'Not today',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Not recorded',
      ternary: TernaryOutcome.unanswered,
    ),
  ];

  static const hadithLivedStartedNew = 'hadithLived.startedNew';
  static const hadithLivedIntroducedFamily = 'hadithLived.introducedFamily';
  static const hadithLivedCorrectedPractice = 'hadithLived.correctedPractice';
  static const hadithLivedObservedOther = 'hadithLived.observedOther';

  static final hadithEncounterDuration = quranDuration(
    verb: 'Engaged',
    rowName: 'Read and/or Listened',
  );
  static final hadithRetentionDuration = quranDuration(
    verb: 'Involved',
    rowName: 'Memorization/Revision',
  );
  static final hadithLearningDuration = quranDuration(
    verb: 'Involved',
    rowName: 'Study Circle/Discussion',
  );
  static const hadithLivedNoticed = <ActivityOption>[
    ActivityOption(
      id: hadithLivedStartedNew,
      label: 'Started living a new Hadith',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: hadithLivedIntroducedFamily,
      label: 'Introduced living a hadith in family',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: hadithLivedCorrectedPractice,
      label: 'Corrected a practice as per hadith',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: hadithLivedObservedOther,
      label: 'Observed living a hadith by other',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'Recorded as not engaged',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'Not answered',
      ternary: TernaryOutcome.unanswered,
    ),
  ];

  static List<ActivityOption> forHomeTrace(String storageKey) {
    return switch (storageKey) {
      hadithEncounterKey => hadithEncounterDuration,
      hadithRetentionKey => hadithRetentionDuration,
      hadithLearningKey => hadithLearningDuration,
      hadithLivedNoticedKey => hadithLivedNoticed,
      _ =>
        isAkhlaqTrace(storageKey)
            ? akhlaqCatalogFor(storageKey)
            : isHuquqTrace(storageKey)
            ? huquqCatalogFor(storageKey)
            : isKnowledgeTrace(storageKey)
            ? knowledgeCatalogFor(storageKey)
            : isDhikrContextTrace(storageKey)
            ? dhikrPostFard
            : storageKey.startsWith('time.t0')
            ? timeCatalogFor(storageKey)
            : isHealthTrace(storageKey)
            ? healthCatalogFor(storageKey)
            : isWealthTrace(storageKey)
            ? wealthCatalogFor(storageKey)
            : isUmmahTrace(storageKey)
            ? ummahCatalogFor(storageKey)
            : isFastingPracticeTrace(storageKey)
            ? fastingCatalogFor(storageKey)
            : charityCatalogFor(storageKey),
    };
  }

  static bool isDhikrPostFardCatalog(List<ActivityOption> options) {
    return identical(options, dhikrPostFard);
  }

  /// Maps ticked post-fard formulas to the remembrance-level option.
  /// All → blue, majority → dark green, minority → light green, none →
  /// unanswered. Lime / Not today stay available for a manual Quick Tap cycle.
  static String postFardIdForPractised({
    required int practised,
    required int total,
  }) {
    if (total <= 0 || practised <= 0) return ActivityIds.unanswered;
    if (practised >= total) return dhikrWithAction;
    if (practised * 2 > total) return dhikrAttentive;
    return dhikrIntentional;
  }

  static bool isAkhlaqObservationCatalog(List<ActivityOption> options) {
    return options.length == 6 &&
        options.first.id == AkhlaqObservationIds.practised &&
        options[2].id == AkhlaqObservationIds.lapseRecognised;
  }

  static bool isHuquqObservationCatalog(List<ActivityOption> options) {
    return options.length == 6 &&
        options.first.id == HuquqObservationIds.practised &&
        options[1].id == HuquqObservationIds.partialEffort &&
        options[2].id == HuquqObservationIds.neglectRecognised;
  }

  static bool isKnowledgeObservationCatalog(List<ActivityOption> options) {
    return options.length == 6 &&
        options.first.id == KnowledgeObservationIds.engaged &&
        options[1].id == KnowledgeObservationIds.progress &&
        options[2].id == KnowledgeObservationIds.gapRecognised;
  }

  static bool isTimeObservationCatalog(List<ActivityOption> options) {
    return options.length == 6 &&
        options.first.id == TimeObservationIds.acted &&
        options[1].id == TimeObservationIds.partialEffort &&
        options[2].id == TimeObservationIds.lapseRecognised;
  }

  /// Shared Time & Barakah legend. Item wording lives in [timeCatalogFor].
  static List<ActivityOption> get timeObservation => timeLegendCatalog;

  static bool isHealthObservationCatalog(List<ActivityOption> options) {
    return options.length == 7 &&
        options.first.id.startsWith('health.') &&
        options[5].id == HealthObservationIds.preferNot &&
        options.last.id == ActivityIds.unanswered;
  }

  /// Shared Physical Health legend. Item wording lives in [healthCatalogFor].
  static List<ActivityOption> get healthObservation => healthLegendCatalog;

  static bool isWealthObservationCatalog(List<ActivityOption> options) {
    return options.length >= 7 &&
        options.first.id.startsWith('wealth.') &&
        options[options.length - 2].id == WealthObservationIds.preferNot &&
        options.last.id == ActivityIds.unanswered;
  }

  static bool isUmmahObservationCatalog(List<ActivityOption> options) {
    return options.length >= 6 &&
        options.first.id.startsWith('ummah.') &&
        options[options.length - 2].id == UmmahObservationIds.preferNot &&
        options.last.id == ActivityIds.unanswered;
  }

  static bool isCharityObservationCatalog(List<ActivityOption> options) {
    return options.length >= 6 &&
        options.first.id == ActivityIds.unanswered &&
        options.last.id == CharityObservationIds.preferNot &&
        options[1].id.startsWith('charity.');
  }

  static bool isFastingObservationCatalog(List<ActivityOption> options) {
    return options.length >= 6 &&
        options.first.id == ActivityIds.unanswered &&
        options.last.id == FastingObservationIds.preferNot &&
        options[1].id.startsWith('fasting.');
  }

  /// Shared Ummah legend. Item wording lives in [ummahCatalogFor].
  static List<ActivityOption> get ummahObservation => ummahLegendCatalog;

  /// Shared Charity legend. Item wording lives in [charityCatalogFor].
  static List<ActivityOption> get charityObservation => charityLegendCatalog;

  /// Shared Fasting legend. Item wording lives in [fastingCatalogFor].
  static List<ActivityOption> get fastingObservation => fastingLegendCatalog;

  /// Shared Wealth legend. Item wording lives in [wealthCatalogFor].
  static List<ActivityOption> get wealthObservation => wealthLegendCatalog;

  static const hadith = <ActivityOption>[
    ActivityOption(
      id: 'reading',
      label: 'Reading',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'listening',
      label: 'Listening',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'memorisation',
      label: 'Memorisation',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'studySession',
      label: 'Study session',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'teachingDiscussion',
      label: 'Teaching/discussion',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: 'hadithReflection',
      label: 'Reflection',
      ternary: TernaryOutcome.positive,
    ),
    ActivityOption(
      id: ActivityIds.noActivity,
      label: 'No Hadith engagement recorded',
      ternary: TernaryOutcome.negative,
    ),
    ActivityOption(
      id: ActivityIds.unanswered,
      label: 'No answer recorded',
      ternary: TernaryOutcome.unanswered,
    ),
    ActivityOption(
      id: ActivityIds.other,
      label: 'Other',
      ternary: TernaryOutcome.positive,
    ),
  ];

  static List<ActivityOption> forQuran(QuranDimension dimension) {
    return switch (dimension) {
      QuranDimension.reading => quranEngagementDuration,
      QuranDimension.meaning => quranUnderstandingDuration,
      QuranDimension.consciousApplication => quranRelevanceDuration,
      QuranDimension.memorisation => quranMemorisation,
      QuranDimension.revision => quranRevision,
      QuranDimension.tafsir => quranTafsir,
      QuranDimension.reflection => quranReflection,
      QuranDimension.applicationReflection => const [],
    };
  }

  static bool isQuranDurationCatalog(List<ActivityOption> options) {
    return identical(options, quranEngagementDuration) ||
        identical(options, quranUnderstandingDuration) ||
        identical(options, quranRelevanceDuration);
  }

  static bool isHadithDurationCatalog(List<ActivityOption> options) {
    return identical(options, hadithEncounterDuration) ||
        identical(options, hadithRetentionDuration) ||
        identical(options, hadithLearningDuration);
  }

  static bool isDurationCatalog(List<ActivityOption> options) {
    return isQuranDurationCatalog(options) || isHadithDurationCatalog(options);
  }

  static ActivityOption? find(List<ActivityOption> catalog, String id) {
    for (final option in catalog) {
      if (option.id == id) return option;
    }
    return null;
  }

  static ActivityOption? findQuran(QuranDimension dimension, String id) {
    return find(forQuran(dimension), id) ??
        find(_quranStoredCatalog(dimension), id) ??
        find(quranLegacy, id);
  }

  static List<ActivityOption> _quranStoredCatalog(QuranDimension dimension) {
    return switch (dimension) {
      QuranDimension.reading => quranReading,
      QuranDimension.meaning => quranMeaning,
      QuranDimension.memorisation => quranMemorisation,
      QuranDimension.revision => quranRevision,
      QuranDimension.tafsir => quranTafsir,
      QuranDimension.reflection => quranReflection,
      QuranDimension.consciousApplication => quranConsciousApplication,
      QuranDimension.applicationReflection => const [],
    };
  }

  static ActivityOption? findAnyQuran(String id) {
    for (final dimension in QuranDimension.values) {
      final match = findQuran(dimension, id);
      if (match != null) return match;
    }
    return null;
  }

  static bool isObligatorySalahCatalog(List<ActivityOption> options) {
    if (identical(options, salah) || identical(options, jumuah)) return true;
    if (options.isEmpty) return false;
    final allowed = {
      for (final option in [...salah, ...jumuah]) option.id,
    };
    for (final option in options) {
      if (!allowed.contains(option.id)) return false;
    }
    return options.any((option) => option.id == 'congregationOnTime');
  }

  static bool preservePickerOrder(List<ActivityOption> options) {
    if (isObligatorySalahCatalog(options) ||
        identical(options, tahajjud) ||
        identical(options, ishraq) ||
        identical(options, tawbah)) {
      return true;
    }
    for (final dimension in QuranDimension.values) {
      if (identical(options, forQuran(dimension))) return true;
    }
    if (isDurationCatalog(options) ||
        identical(options, hadithLivedNoticed) ||
        identical(options, dhikrPostFard) ||
        isAkhlaqObservationCatalog(options) ||
        isHuquqObservationCatalog(options) ||
        isKnowledgeObservationCatalog(options) ||
        isTimeObservationCatalog(options) ||
        isHealthObservationCatalog(options) ||
        isWealthObservationCatalog(options) ||
        isUmmahObservationCatalog(options) ||
        isCharityObservationCatalog(options) ||
        isFastingObservationCatalog(options)) {
      return true;
    }
    return false;
  }

  static String salahKey(PrayerId id) => 'salah.${id.name}';
  static const jumuahKey = 'salah.jumuah';
  static const tahajjudKey = 'salah.tahajjud';
  static const ishraqKey = 'salah.ishraq';
  static const tawbahKey = 'salah.tawbah';

  static List<ActivityOption> forVoluntarySalah(SalahTraceRow row) {
    return switch (row) {
      SalahTraceRow.tahajjud => tahajjud,
      SalahTraceRow.ishraq => ishraq,
      SalahTraceRow.tawbah => tawbah,
      _ => const [],
    };
  }

  static String voluntarySalahKey(SalahTraceRow row) => 'salah.${row.name}';

  static String canonicalVoluntarySalahId(
    TernaryOutcome outcome,
    SalahTraceRow row,
  ) {
    if (outcome == TernaryOutcome.unanswered) return ActivityIds.unanswered;
    if (outcome == TernaryOutcome.negative) {
      return switch (row) {
        SalahTraceRow.tahajjud => tahajjudNotPrayed,
        SalahTraceRow.ishraq => ishraqNotPrayed,
        SalahTraceRow.tawbah => tawbahNotPrayed,
        _ => ActivityIds.unanswered,
      };
    }
    return switch (row) {
      SalahTraceRow.tahajjud => tahajjudEarlyMid,
      SalahTraceRow.ishraq => ishraqPrayed,
      SalahTraceRow.tawbah => tawbahPrayed,
      _ => ActivityIds.unanswered,
    };
  }

  static String quranKey(QuranDimension dimension) => 'quran.${dimension.name}';
  static const dhikrKey = 'dhikr';
  static const conductKey = 'conduct';
  static const gratitudeKey = 'gratitude';
  static const reflectionKey = 'personalReflection';
  static const fastingKey = 'fasting';
  static const charityKey = 'charity';
  static const zakatKey = 'zakat';
  static const familyKey = 'family';
  static const hadithKey = 'hadith';

  static String canonicalSalahId(PrayerStatus status) => switch (status) {
    PrayerStatus.onTime => 'aloneOnTime',
    PrayerStatus.late => 'prayedLate',
    PrayerStatus.missed => 'missed',
    PrayerStatus.excused => 'excused',
    PrayerStatus.other => ActivityIds.other,
    PrayerStatus.unanswered => ActivityIds.unanswered,
  };

  static bool jumuahActivityMeansCongregation(String activityId) {
    return activityId == 'congregationOnTime' ||
        activityId == 'joinedCongregationLate' ||
        activityId == 'smallCongregation';
  }

  static String canonicalTernaryId(
    TernaryOutcome outcome,
    List<ActivityOption> catalog,
  ) {
    if (outcome == TernaryOutcome.unanswered) {
      return ActivityIds.unanswered;
    }
    for (final option in catalog) {
      if (option.ternary == outcome && option.id != ActivityIds.other) {
        return option.id;
      }
    }
    if (outcome == TernaryOutcome.negative) return ActivityIds.noActivity;
    return ActivityIds.other;
  }
}
