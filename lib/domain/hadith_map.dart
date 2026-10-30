import 'date_key.dart';
import 'personal_hadith.dart';
import 'practice_hadith.dart';
import 'practice_hadith_catalog.dart';

enum HadithMapFamily {
  prayer,
  fasting,
  dhikr,
  character,
  family,
  knowledge,
  travel,
  daily,
  charity,
}

enum HadithMapFill { recentlyFetched, notMet, learning, shared, living }

enum HadithMapPeriod { week, month }

class HadithMapMark {
  const HadithMapMark({
    required this.id,
    required this.item,
    required this.family,
    required this.fill,
    required this.fetched,
    this.addedDateKey,
  });

  final String id;
  final PracticeHadithItem item;
  final HadithMapFamily family;
  final HadithMapFill fill;
  final bool fetched;
  final String? addedDateKey;
}

class HadithMapStats {
  const HadithMapStats({
    required this.byFamily,
    required this.byFill,
    required this.periodByFill,
  });

  final Map<HadithMapFamily, int> byFamily;
  final Map<HadithMapFill, int> byFill;
  final Map<HadithMapFill, int> periodByFill;

  int get total => byFill.values.fold(0, (sum, n) => sum + n);

  int get periodTotal => periodByFill.values.fold(0, (sum, n) => sum + n);
}

const kHadithMapRecentDays = 7;
const kHadithMapMonthDays = 30;

HadithMapFamily hadithMapFamilyForTopic(String topic) {
  return switch (topic) {
    'Wudu' ||
    'Entering the mosque' ||
    'Leaving the mosque' ||
    'After prayer' ||
    'Night prayer' ||
    'After the adhan' ||
    'Ayat al-Kursi after prayer' ||
    'Istikhara' => HadithMapFamily.prayer,
    'Breaking the fast' || 'The new moon' => HadithMapFamily.fasting,
    'Morning and evening' ||
    'Seeking forgiveness' ||
    'Sending blessings' ||
    'Dhikr' ||
    'Sayyid al-istighfar' ||
    'Leaving a gathering' ||
    'When a calamity strikes' ||
    'In distress' ||
    'Protection in the day' ||
    'When relying on Allah' => HadithMapFamily.dhikr,
    'Looking in the mirror' ||
    'Anger' ||
    'The marketplace' ||
    'Hospitality' ||
    'Speech' => HadithMapFamily.character,
    'Family' ||
    'Visiting the sick' ||
    'Neighbours' ||
    'Visiting graves' ||
    'Before intimacy' => HadithMapFamily.family,
    'Qur’an in the day' || 'Beneficial knowledge' => HadithMapFamily.knowledge,
    'Leaving home' ||
    'Travel' ||
    'Returning from travel' => HadithMapFamily.travel,
    'Seeing someone in affliction' ||
    'For the one who fed you' => HadithMapFamily.charity,
    _ => HadithMapFamily.daily,
  };
}

HadithMapFill hadithMapFillForStatus(PracticeHadithStatus status) {
  return switch (status) {
    PracticeHadithStatus.learning => HadithMapFill.learning,
    PracticeHadithStatus.learnt ||
    PracticeHadithStatus.practicing => HadithMapFill.shared,
    PracticeHadithStatus.habit => HadithMapFill.living,
  };
}

HadithMapFill? hadithMapFillFromId(String? id) {
  return switch (id) {
    'recentlyFetched' => HadithMapFill.recentlyFetched,
    'notMet' => HadithMapFill.notMet,
    'learning' => HadithMapFill.learning,
    'shared' => HadithMapFill.shared,
    'living' => HadithMapFill.living,
    _ => null,
  };
}

const kHadithMapToggleFills = [
  HadithMapFill.notMet,
  HadithMapFill.learning,
  HadithMapFill.living,
  HadithMapFill.shared,
];

HadithMapFill nextHadithMapFill(
  HadithMapFill current, {
  required bool canShare,
}) {
  final start = current == HadithMapFill.recentlyFetched
      ? HadithMapFill.notMet
      : current;
  final index = kHadithMapToggleFills.indexOf(start);
  final from = index < 0 ? 0 : index;
  for (var step = 1; step <= kHadithMapToggleFills.length; step++) {
    final next =
        kHadithMapToggleFills[(from + step) % kHadithMapToggleFills.length];
    if (next == HadithMapFill.shared && !canShare) continue;
    return next;
  }
  return start;
}

PracticeHadithStatus statusForMapFill(HadithMapFill fill) {
  return switch (fill) {
    HadithMapFill.recentlyFetched ||
    HadithMapFill.notMet ||
    HadithMapFill.learning => PracticeHadithStatus.learning,
    HadithMapFill.shared => PracticeHadithStatus.learnt,
    HadithMapFill.living => PracticeHadithStatus.habit,
  };
}

String hadithSpeechText(PracticeHadithItem item, {required bool arabic}) {
  if (arabic) {
    final spoken = item.arabic.trim();
    if (spoken.isNotEmpty) return spoken;
  }
  final translation = item.translation.trim();
  if (translation.isNotEmpty) return translation;
  return item.transliteration.trim();
}

String hadithSpeechLanguageCode({required bool arabic}) =>
    arabic ? 'ar-SA' : 'en-US';

String pickHadithTtsLanguage(
  Iterable<String> installed, {
  required bool arabic,
}) {
  final wanted = arabic
      ? const ['ar-SA', 'ar_SA', 'ar']
      : const ['en-US', 'en_US', 'en-GB', 'en_GB', 'en'];
  final have = [
    for (final item in installed)
      if (item.trim().isNotEmpty) item.trim(),
  ];
  String norm(String value) => value.toLowerCase().replaceAll('_', '-');
  for (final want in wanted) {
    for (final item in have) {
      if (norm(item) == norm(want)) return item;
    }
  }
  final prefix = arabic ? 'ar' : 'en';
  for (final item in have) {
    if (norm(item).startsWith(prefix)) return item;
  }
  return have.isNotEmpty
      ? have.first
      : hadithSpeechLanguageCode(arabic: arabic);
}

String hadithMapPeriodStart(String todayKey, HadithMapPeriod period) {
  final days = period == HadithMapPeriod.week
      ? kHadithMapRecentDays
      : kHadithMapMonthDays;
  return shiftDateKey(todayKey, 1 - days);
}

bool hadithMapInPeriod(String? addedDateKey, String start, String todayKey) {
  if (addedDateKey == null || addedDateKey.isEmpty) return false;
  return addedDateKey.compareTo(start) >= 0 &&
      addedDateKey.compareTo(todayKey) <= 0;
}

PracticeHadithRecord? hadithMapRegisterFor(
  String catalogId,
  List<PracticeHadithRecord> records,
) {
  for (final record in records) {
    if (record.catalogId == catalogId && !record.isArchived) return record;
  }
  return null;
}

List<HadithMapMark> buildHadithMapMarks({
  List<PracticeHadithItem>? catalog,
  List<PracticeHadithItem> extras = const [],
  List<PracticeHadithRecord> records = const [],
  List<PersonalHadith> shelf = const [],
  required String todayKey,
}) {
  final source = catalog ?? kPracticeHadithCatalog;
  final catalogIds = {for (final item in source) item.id};
  final seen = <String>{};
  final builtIn = <HadithMapMark>[];
  final fetched = <HadithMapMark>[];
  final addedById = {for (final item in shelf) item.id: item.addedDateKey};

  void addItem(PracticeHadithItem item, {required bool extra}) {
    if (seen.contains(item.id)) return;
    seen.add(item.id);
    final record = hadithMapRegisterFor(item.id, records);
    final added = extra
        ? (addedById[item.id] ?? record?.addedDateKey)
        : record?.addedDateKey;
    final recentExtra =
        extra &&
        added != null &&
        hadithMapInPeriod(
          added,
          hadithMapPeriodStart(todayKey, HadithMapPeriod.week),
          todayKey,
        );
    var fill = HadithMapFill.notMet;
    final chosen = hadithMapFillFromId(record?.mapFillId);
    if (chosen != null) {
      fill =
          chosen == HadithMapFill.shared &&
              (record?.sharedDateKeys.isEmpty ?? true)
          ? HadithMapFill.learning
          : chosen;
    } else if (record != null) {
      fill = hadithMapFillForStatus(record.status);
      if (record.sharedDateKeys.isNotEmpty && fill != HadithMapFill.living) {
        fill = HadithMapFill.shared;
      }
    } else if (recentExtra) {
      fill = HadithMapFill.recentlyFetched;
    }
    final mark = HadithMapMark(
      id: item.id,
      item: item,
      family: hadithMapFamilyForTopic(item.topic),
      fill: fill,
      fetched: extra,
      addedDateKey: added,
    );
    if (extra) {
      fetched.add(mark);
    } else {
      builtIn.add(mark);
    }
  }

  for (final item in source) {
    addItem(item, extra: false);
  }
  for (final item in extras) {
    if (catalogIds.contains(item.id)) continue;
    addItem(item, extra: true);
  }

  final grouped = <HadithMapMark>[];
  for (final family in HadithMapFamily.values) {
    grouped.addAll([
      for (final mark in builtIn)
        if (mark.family == family) mark,
      for (final mark in fetched)
        if (mark.family == family) mark,
    ]);
  }
  return grouped;
}

HadithMapStats hadithMapStats(
  List<HadithMapMark> marks, {
  required String todayKey,
  required HadithMapPeriod period,
}) {
  final byFamily = {for (final family in HadithMapFamily.values) family: 0};
  final byFill = {for (final fill in HadithMapFill.values) fill: 0};
  final periodByFill = {for (final fill in HadithMapFill.values) fill: 0};
  final start = hadithMapPeriodStart(todayKey, period);
  for (final mark in marks) {
    byFamily[mark.family] = (byFamily[mark.family] ?? 0) + 1;
    byFill[mark.fill] = (byFill[mark.fill] ?? 0) + 1;
    if (hadithMapInPeriod(mark.addedDateKey, start, todayKey)) {
      periodByFill[mark.fill] = (periodByFill[mark.fill] ?? 0) + 1;
    }
  }
  return HadithMapStats(
    byFamily: byFamily,
    byFill: byFill,
    periodByFill: periodByFill,
  );
}
