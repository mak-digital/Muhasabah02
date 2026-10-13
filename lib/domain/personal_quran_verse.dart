import 'practice_hadith.dart';
import 'quran_verse_ref.dart';

const int kPersonalQuranSchemaVersion = 1;

const kPersonalQuranSkimDetail =
    'A verse you brought onto this device. Citation only — not a khushu’ score, recitation streak, or Knowledge’s residual.';

const kPersonalQuranWordsPending =
    'Words will fill when you look this verse up while online.';

const kPersonalQuranBroughtNote = 'A verse you brought onto this device.';

/// Device-local Learn shelf. Not the built-in catalog. Not the practice register.
class PersonalQuranVerse {
  const PersonalQuranVerse({
    required this.id,
    required this.verseKey,
    required this.surah,
    required this.start,
    required this.end,
    required this.addedDateKey,
    this.arabic = '',
    this.translation = '',
    this.wordsPending = false,
    this.schemaVersion = kPersonalQuranSchemaVersion,
  });

  final String id;
  final String verseKey;
  final int surah;
  final int start;
  final int end;
  final String arabic;
  final String translation;
  final bool wordsPending;
  final String addedDateKey;
  final int schemaVersion;

  QuranVerseRange get range =>
      QuranVerseRange(surah: surah, start: start, end: end);

  PracticeHadithItem toLearnItem() {
    return PracticeHadithItem(
      id: id,
      topic: range.citation,
      text: wordsPending ? kPersonalQuranWordsPending : kPersonalQuranBroughtNote,
      arabic: arabic,
      transliteration: '',
      translation: translation,
      source: range.citation,
      sourceDetail: kPersonalQuranSkimDetail,
    );
  }

  PersonalQuranVerse copyWith({
    String? arabic,
    String? translation,
    bool? wordsPending,
  }) {
    return PersonalQuranVerse(
      id: id,
      verseKey: verseKey,
      surah: surah,
      start: start,
      end: end,
      addedDateKey: addedDateKey,
      arabic: arabic ?? this.arabic,
      translation: translation ?? this.translation,
      wordsPending: wordsPending ?? this.wordsPending,
      schemaVersion: schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'id': id,
      'verseKey': verseKey,
      'surah': surah,
      'start': start,
      'end': end,
      'arabic': arabic,
      'translation': translation,
      'wordsPending': wordsPending,
      'addedDateKey': addedDateKey,
    };
  }

  static PersonalQuranVerse fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final verseKey = json['verseKey'] as String?;
    final added = json['addedDateKey'] as String?;
    final surah = json['surah'];
    final start = json['start'];
    final end = json['end'];
    if (id == null ||
        id.isEmpty ||
        verseKey == null ||
        added == null ||
        surah is! int ||
        start is! int ||
        end is! int) {
      throw const FormatException('Malformed PersonalQuranVerse');
    }
    return PersonalQuranVerse(
      id: id,
      verseKey: verseKey,
      surah: surah,
      start: start,
      end: end,
      addedDateKey: added,
      arabic: json['arabic'] is String ? json['arabic'] as String : '',
      translation: json['translation'] is String
          ? json['translation'] as String
          : '',
      wordsPending: json['wordsPending'] == true,
      schemaVersion: json['schemaVersion'] is int
          ? json['schemaVersion'] as int
          : kPersonalQuranSchemaVersion,
    );
  }

  factory PersonalQuranVerse.fromRange({
    required QuranVerseRange range,
    required String addedDateKey,
    String arabic = '',
    String translation = '',
    bool wordsPending = false,
  }) {
    return PersonalQuranVerse(
      id: range.catalogId,
      verseKey: range.verseKey,
      surah: range.surah,
      start: range.start,
      end: range.end,
      addedDateKey: addedDateKey,
      arabic: arabic,
      translation: translation,
      wordsPending: wordsPending,
    );
  }
}

List<PracticeHadithItem> personalQuranLearnItems(
  Iterable<PersonalQuranVerse> shelf,
) {
  final ordered = shelf.toList()
    ..sort((a, b) {
      final byDate = a.addedDateKey.compareTo(b.addedDateKey);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
  return [for (final verse in ordered) verse.toLearnItem()];
}
