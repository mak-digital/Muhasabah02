import 'practice_dhikr_catalog.dart';
import 'quran.dart';

/// Per-item response on a context-specific Dhikr selection.
/// Unselected categories stay unanswered; this is never inferred from absence.
enum DhikrContextResponse { practised, notToday, preferNot }

extension DhikrContextResponseX on DhikrContextResponse {
  String get label => switch (this) {
    DhikrContextResponse.practised => 'Practised',
    DhikrContextResponse.notToday => 'Not today',
    DhikrContextResponse.preferNot => 'Prefer not to record',
  };
}

enum DhikrSourceKind { formula, activity, verse }

enum DhikrVerificationStatus { verified, pendingReview }

class DhikrContextItem {
  const DhikrContextItem({
    required this.id,
    required this.rowKey,
    required this.label,
    required this.kind,
    this.allowsRepetitions = false,
    this.personalTopic = false,
    this.sourceId,
    this.practiceCatalogId,
    this.seedCount = 1,
  });

  final String id;
  final String rowKey;
  final String label;
  final DhikrSourceKind kind;
  final bool allowsRepetitions;
  final bool personalTopic;
  final String? sourceId;
  final String? practiceCatalogId;
  final int seedCount;
}

class DhikrContextCapture {
  const DhikrContextCapture({
    required this.activityId,
    required this.response,
    this.repetitions,
    this.note,
    this.updatedAt,
  });

  final String activityId;
  final DhikrContextResponse response;
  final int? repetitions;
  final String? note;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': activityId,
      'response': response.name,
      if (repetitions != null && repetitions! > 0) 'repetitions': repetitions,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  static DhikrContextCapture? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    if (id is! String || id.isEmpty) return null;
    final raw = json['response'];
    final response = DhikrContextResponse.values
        .where((value) => value.name == raw)
        .firstOrNull;
    if (response == null) return null;
    final reps = json['repetitions'];
    final note = json['note'];
    final updated = json['updatedAt'];
    return DhikrContextCapture(
      activityId: id,
      response: response,
      repetitions: reps is int && reps > 0
          ? reps
          : reps is num && reps.toInt() > 0
          ? reps.toInt()
          : null,
      note: note is String && note.trim().isNotEmpty ? note.trim() : null,
      updatedAt: updated is String ? DateTime.tryParse(updated) : null,
    );
  }

  DhikrContextCapture copyWith({
    DhikrContextResponse? response,
    int? repetitions,
    bool clearRepetitions = false,
    String? note,
    bool clearNote = false,
    DateTime? updatedAt,
  }) {
    return DhikrContextCapture(
      activityId: activityId,
      response: response ?? this.response,
      repetitions: clearRepetitions ? null : (repetitions ?? this.repetitions),
      note: clearNote ? null : (note ?? this.note),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const kDhikrGeneralKey = 'dhikr.generalDhikr';
const kDhikrGratitudeKey = 'dhikr.gratitudeDhikr';
const kDhikrTravelKey = 'dhikr.travelDhikr';
const kDhikrPersonalKey = 'dhikr.personalDhikr';
const kDhikrOtherKey = 'dhikr.otherAdhkar';
const kDhikrMorningKey = 'dhikr.morningAdhkar';
const kDhikrEveningKey = 'dhikr.eveningAdhkar';
const kDhikrPostFardKeys = [
  'dhikr.postFardFajr',
  'dhikr.postFardDhuhr',
  'dhikr.postFardAsr',
  'dhikr.postFardMaghrib',
  'dhikr.postFardIsha',
];

const kDhikrContextRowKeys = {
  kDhikrGeneralKey,
  kDhikrGratitudeKey,
  kDhikrTravelKey,
  kDhikrPersonalKey,
  kDhikrOtherKey,
  kDhikrMorningKey,
  kDhikrEveningKey,
  ...kDhikrPostFardKeys,
};

bool isDhikrContextTrace(String storageKey) =>
    kDhikrContextRowKeys.contains(storageKey);

const _kDhikrOtherAdhkarCatalog = <DhikrContextItem>[
  DhikrContextItem(
    id: 'dhikr.general.tasbih',
    rowKey: kDhikrGeneralKey,
    label: 'SubhanAllah — Tasbih',
    kind: DhikrSourceKind.activity,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.tasbih',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.general.tahmid',
    rowKey: kDhikrGeneralKey,
    label: 'Alhamdulillah — Tahmid',
    kind: DhikrSourceKind.activity,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.tahmid',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.general.takbir',
    rowKey: kDhikrGeneralKey,
    label: 'Allahu Akbar — Takbir',
    kind: DhikrSourceKind.activity,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.takbir',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.general.tahlil',
    rowKey: kDhikrGeneralKey,
    label: 'La ilaha illallah — Tahlil',
    kind: DhikrSourceKind.activity,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.tahlil',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.general.subhanAllahiWaBihamdihi',
    rowKey: kDhikrGeneralKey,
    label: 'SubhanAllahi wa bihamdihi',
    kind: DhikrSourceKind.formula,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.subhanAllahiWaBihamdihi',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.general.pairedFormula',
    rowKey: kDhikrGeneralKey,
    label: 'SubhanAllahil-Azim and SubhanAllahi wa bihamdihi — paired formula',
    kind: DhikrSourceKind.formula,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.pairedFormula',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.general.istighfar',
    rowKey: kDhikrGeneralKey,
    label: 'Astaghfirullah / seeking forgiveness',
    kind: DhikrSourceKind.activity,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.istighfar',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.general.sayyidAlIstighfar',
    rowKey: kDhikrGeneralKey,
    label: 'Sayyid al-Istighfar',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.sayyidAlIstighfar',
    seedCount: 1,
  ),
  DhikrContextItem(
    id: 'dhikr.general.salawat',
    rowKey: kDhikrGeneralKey,
    label: 'Salawat upon the Prophet ﷺ',
    kind: DhikrSourceKind.formula,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.salawat',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.general.other',
    rowKey: kDhikrGeneralKey,
    label: 'Other general remembrance',
    kind: DhikrSourceKind.activity,
    seedCount: 1,
    practiceCatalogId: 'dh.gen.hawqala',
  ),
  DhikrContextItem(
    id: 'dhikr.gratitude.alhamdulillah',
    rowKey: kDhikrGratitudeKey,
    label: 'General Alhamdulillah',
    kind: DhikrSourceKind.formula,
    allowsRepetitions: true,
    sourceId: 'src.dhikr.alhamdulillah',
    seedCount: 33,
  ),
  DhikrContextItem(
    id: 'dhikr.gratitude.afterFood',
    rowKey: kDhikrGratitudeKey,
    label: 'Gratitude after eating or drinking',
    kind: DhikrSourceKind.activity,
    sourceId: 'src.dhikr.afterFood',
  ),
  DhikrContextItem(
    id: 'dhikr.gratitude.blessings',
    rowKey: kDhikrGratitudeKey,
    label: 'Remembering Allah\'s blessings',
    kind: DhikrSourceKind.verse,
    sourceId: 'src.dhikr.quran14_7',
  ),
  DhikrContextItem(
    id: 'dhikr.gratitude.specific',
    rowKey: kDhikrGratitudeKey,
    label: 'Gratitude for a specific blessing',
    kind: DhikrSourceKind.activity,
    practiceCatalogId: 'dh.grat.hamd',
  ),
  DhikrContextItem(
    id: 'dhikr.gratitude.easeOrDifficulty',
    rowKey: kDhikrGratitudeKey,
    label: 'Gratitude during ease or difficulty',
    kind: DhikrSourceKind.activity,
    practiceCatalogId: 'dh.grat.laka',
  ),
  DhikrContextItem(
    id: 'dhikr.gratitude.other',
    rowKey: kDhikrGratitudeKey,
    label: 'Other expression of gratitude',
    kind: DhikrSourceKind.activity,
    practiceCatalogId: 'dh.grat.hamd',
  ),
  DhikrContextItem(
    id: 'dhikr.travel.leavingHome',
    rowKey: kDhikrTravelKey,
    label: 'Leaving home',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.leavingHome',
  ),
  DhikrContextItem(
    id: 'dhikr.travel.beginningJourney',
    rowKey: kDhikrTravelKey,
    label: 'Beginning a journey',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.beginningJourney',
  ),
  DhikrContextItem(
    id: 'dhikr.travel.boarding',
    rowKey: kDhikrTravelKey,
    label: 'Boarding transport',
    kind: DhikrSourceKind.activity,
    sourceId: 'src.dhikr.beginningJourney',
  ),
  DhikrContextItem(
    id: 'dhikr.travel.stopping',
    rowKey: kDhikrTravelKey,
    label: 'Stopping at a place',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.stoppingPlace',
  ),
  DhikrContextItem(
    id: 'dhikr.travel.returning',
    rowKey: kDhikrTravelKey,
    label: 'Returning from travel',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.returningTravel',
  ),
  DhikrContextItem(
    id: 'dhikr.travel.personalDua',
    rowKey: kDhikrTravelKey,
    label: 'Personal dua for safe travel',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.travel.mount',
  ),
  DhikrContextItem(
    id: 'dhikr.travel.other',
    rowKey: kDhikrTravelKey,
    label: 'Other travel remembrance',
    kind: DhikrSourceKind.activity,
    practiceCatalogId: 'dh.travel.return',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.forgiveness',
    rowKey: kDhikrPersonalKey,
    label: 'Forgiveness',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.morn.sayyid',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.guidance',
    rowKey: kDhikrPersonalKey,
    label: 'Guidance',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.morn.hayyu',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.health',
    rowKey: kDhikrPersonalKey,
    label: 'Health and wellbeing',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.morn.afini',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.family',
    rowKey: kDhikrPersonalKey,
    label: 'Family and children',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.pers.rabbana',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.provision',
    rowKey: kDhikrPersonalKey,
    label: 'Livelihood and provision',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.post.ilmu',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.protection',
    rowKey: kDhikrPersonalKey,
    label: 'Protection from harm',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.morn.bismillah',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.knowledge',
    rowKey: kDhikrPersonalKey,
    label: 'Knowledge and understanding',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.post.ilmu',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.istikhara',
    rowKey: kDhikrPersonalKey,
    label: 'Istikhara',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    sourceId: 'src.dhikr.istikharaPending',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.rabbanaAtina',
    rowKey: kDhikrPersonalKey,
    label: 'Rabbana atina fid-dunya hasanah — Qur’an 2:201',
    kind: DhikrSourceKind.formula,
    personalTopic: true,
    sourceId: 'src.dhikr.rabbanaAtina',
  ),
  DhikrContextItem(
    id: 'dhikr.personal.other',
    rowKey: kDhikrPersonalKey,
    label: 'Other personal dua',
    kind: DhikrSourceKind.activity,
    personalTopic: true,
    practiceCatalogId: 'dh.pers.jannah',
  ),
  DhikrContextItem(
    id: 'dhikr.other.sleep',
    rowKey: kDhikrOtherKey,
    label: 'Before sleeping',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.beforeSleep',
  ),
  DhikrContextItem(
    id: 'dhikr.other.waking',
    rowKey: kDhikrOtherKey,
    label: 'Upon waking',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.waking',
  ),
  DhikrContextItem(
    id: 'dhikr.other.meals',
    rowKey: kDhikrOtherKey,
    label: 'Before or after meals',
    kind: DhikrSourceKind.activity,
    sourceId: 'src.dhikr.afterFood',
  ),
  DhikrContextItem(
    id: 'dhikr.other.home',
    rowKey: kDhikrOtherKey,
    label: 'Entering or leaving home',
    kind: DhikrSourceKind.activity,
    sourceId: 'src.dhikr.leavingHome',
  ),
  DhikrContextItem(
    id: 'dhikr.other.mosque',
    rowKey: kDhikrOtherKey,
    label: 'Entering or leaving the mosque',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.mosque',
  ),
  DhikrContextItem(
    id: 'dhikr.other.afterSalah',
    rowKey: kDhikrOtherKey,
    label: 'After obligatory Salah',
    kind: DhikrSourceKind.activity,
    sourceId: 'src.dhikr.postPrayer',
  ),
  DhikrContextItem(
    id: 'dhikr.other.protection',
    rowKey: kDhikrOtherKey,
    label: 'Seeking protection',
    kind: DhikrSourceKind.activity,
    practiceCatalogId: 'dh.morn.kalimat',
  ),
  DhikrContextItem(
    id: 'dhikr.other.distress',
    rowKey: kDhikrOtherKey,
    label: 'During distress or worry',
    kind: DhikrSourceKind.verse,
    sourceId: 'src.dhikr.distress',
  ),
  DhikrContextItem(
    id: 'dhikr.other.illness',
    rowKey: kDhikrOtherKey,
    label: 'During illness',
    kind: DhikrSourceKind.formula,
    sourceId: 'src.dhikr.illness',
  ),
  DhikrContextItem(
    id: 'dhikr.other.sunnah',
    rowKey: kDhikrOtherKey,
    label: 'Other Sunnah remembrance',
    kind: DhikrSourceKind.activity,
    practiceCatalogId: 'dh.other.majlis',
  ),
];

final kDhikrContextCatalog = <DhikrContextItem>[
  ..._kDhikrOtherAdhkarCatalog,
  ..._practiceDhikrRowCatalog(kDhikrMorningKey, kDhikrGroupMorning),
  ..._practiceDhikrRowCatalog(kDhikrEveningKey, kDhikrGroupEvening),
  for (final key in kDhikrPostFardKeys)
    ..._practiceDhikrRowCatalog(key, kDhikrGroupPost),
];

List<DhikrContextItem> _practiceDhikrRowCatalog(String rowKey, String group) {
  return [
    for (final practice in practiceDhikrPrimaryForGroup(group))
      DhikrContextItem(
        id: '$rowKey.${practice.id}',
        rowKey: rowKey,
        label: practice.topic,
        kind: DhikrSourceKind.formula,
        allowsRepetitions: true,
        practiceCatalogId: practice.id,
        seedCount: seedCountFromPractice(practice),
      ),
  ];
}

int seedCountFromPractice(PracticeDhikrItem practice) {
  final text = practice.text.toLowerCase();
  final id = practice.id.toLowerCase();
  if (text.contains('one hundred') || id.contains('100')) return 100;
  if (text.contains('thirty-three') ||
      text.contains('thirty three') ||
      RegExp(r'\b33\b').hasMatch(text) ||
      id.contains('33')) {
    return 33;
  }
  if (text.contains('ten times') || id.contains('10')) return 10;
  if (text.contains('seven times')) return 7;
  if (text.contains('three times') || id.endsWith('3')) return 3;
  return 1;
}

String dhikrPracticeSectionLabel(String rowKey) {
  if (rowKey.startsWith('dhikr.postFard')) return kDhikrGroupPost;
  if (rowKey == kDhikrMorningKey) return kDhikrGroupMorning;
  if (rowKey == kDhikrEveningKey) return kDhikrGroupEvening;
  return kDhikrGroupOther;
}

final dhikrContextItemById = {
  for (final item in kDhikrContextCatalog) item.id: item,
};

List<DhikrContextItem> dhikrContextItemsFor(String rowKey) {
  return [
    for (final item in kDhikrContextCatalog)
      if (item.rowKey == rowKey) item,
  ];
}

TernaryOutcome rollupDhikrContext(List<DhikrContextCapture> captures) {
  if (captures.isEmpty) return TernaryOutcome.unanswered;
  if (captures.any((item) => item.response == DhikrContextResponse.practised)) {
    return TernaryOutcome.positive;
  }
  return TernaryOutcome.negative;
}

Map<String, List<DhikrContextCapture>> dhikrContextFromJson(Object? json) {
  if (json is! Map) return const {};
  final result = <String, List<DhikrContextCapture>>{};
  for (final entry in json.entries) {
    final key = '${entry.key}';
    if (!isDhikrContextTrace(key)) continue;
    final raw = entry.value;
    if (raw is! List) continue;
    final items = <DhikrContextCapture>[];
    for (final item in raw) {
      final parsed = DhikrContextCapture.fromJson(item);
      if (parsed == null) continue;
      if (dhikrContextItemById[parsed.activityId]?.rowKey != key) continue;
      items.add(parsed);
    }
    if (items.isNotEmpty) result[key] = items;
  }
  return result;
}

Map<String, dynamic> dhikrContextToJson(
  Map<String, List<DhikrContextCapture>> captures,
) {
  return {
    for (final entry in captures.entries)
      if (entry.value.isNotEmpty)
        entry.key: [for (final item in entry.value) item.toJson()],
  };
}

int clampDhikrCount(int? value) {
  if (value == null || value <= 0) return 0;
  return value > 999 ? 999 : value;
}

int resolvedDhikrCount({
  required DhikrContextItem item,
  int? recorded,
  int? remembered,
}) {
  final fromRecord = clampDhikrCount(recorded);
  if (fromRecord > 0) return fromRecord;
  final fromMemory = clampDhikrCount(remembered);
  if (fromMemory > 0) return fromMemory;
  return clampDhikrCount(item.seedCount) == 0
      ? 1
      : clampDhikrCount(item.seedCount);
}

String dhikrPerformedSummary(List<DhikrContextCapture> captures) {
  final practised = captures
      .where((item) => item.response == DhikrContextResponse.practised)
      .length;
  if (practised <= 0) return 'Not recorded';
  if (practised == 1) return '1 performed';
  return '$practised performed';
}

String dhikrRowSummary(String rowKey, List<DhikrContextCapture> captures) {
  if (isDhikrContextTrace(rowKey)) return dhikrPerformedSummary(captures);
  return dhikrContextSummary(captures);
}

String dhikrContextSummary(List<DhikrContextCapture> captures) {
  if (captures.isEmpty) return 'Not recorded';
  final practised = captures
      .where((item) => item.response == DhikrContextResponse.practised)
      .length;
  final notToday = captures
      .where((item) => item.response == DhikrContextResponse.notToday)
      .length;
  final preferNot = captures
      .where((item) => item.response == DhikrContextResponse.preferNot)
      .length;
  final parts = <String>[
    if (practised > 0) '$practised practised',
    if (notToday > 0) '$notToday not today',
    if (preferNot > 0) '$preferNot prefer not',
  ];
  return parts.isEmpty ? 'Not recorded' : parts.join(' · ');
}

String dhikrContextEvidenceValue(List<DhikrContextCapture> captures) {
  if (captures.isEmpty) return 'Not recorded';
  return [
    for (final capture in captures)
      '${dhikrContextItemById[capture.activityId]?.label ?? capture.activityId} (${capture.response.label})',
  ].join('; ');
}
