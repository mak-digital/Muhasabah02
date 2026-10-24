import 'hadith_ref.dart';
import 'practice_hadith.dart';

const int kPersonalHadithSchemaVersion = 1;

const kPersonalHadithSkimDetail =
    'A hadith you brought onto this device. Citation only — not a checklist, score, or revival programme.';

const kPersonalHadithWordsPending =
    'Words will fill when you look this hadith up while online.';

const kPersonalHadithBroughtNote = 'A hadith you brought onto this device.';

/// Device-local Learn shelf. Not the built-in catalog. Not the practice register.
class PersonalHadith {
  const PersonalHadith({
    required this.id,
    required this.hadithKey,
    required this.slug,
    required this.number,
    required this.addedDateKey,
    this.arabic = '',
    this.translation = '',
    this.wordsPending = false,
    this.schemaVersion = kPersonalHadithSchemaVersion,
  });

  final String id;
  final String hadithKey;
  final String slug;
  final int number;
  final String arabic;
  final String translation;
  final bool wordsPending;
  final String addedDateKey;
  final int schemaVersion;

  HadithRef get ref => HadithRef(slug: slug, number: number);

  PracticeHadithItem toLearnItem() {
    return PracticeHadithItem(
      id: id,
      topic: ref.citation,
      text: wordsPending
          ? kPersonalHadithWordsPending
          : kPersonalHadithBroughtNote,
      arabic: arabic,
      transliteration: '',
      translation: translation,
      source: ref.citation,
      sourceDetail: kPersonalHadithSkimDetail,
    );
  }

  PersonalHadith copyWith({
    String? arabic,
    String? translation,
    bool? wordsPending,
  }) {
    return PersonalHadith(
      id: id,
      hadithKey: hadithKey,
      slug: slug,
      number: number,
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
      'hadithKey': hadithKey,
      'slug': slug,
      'number': number,
      'arabic': arabic,
      'translation': translation,
      'wordsPending': wordsPending,
      'addedDateKey': addedDateKey,
    };
  }

  static PersonalHadith fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final hadithKey = json['hadithKey'] as String?;
    final added = json['addedDateKey'] as String?;
    final slug = json['slug'] as String?;
    final number = json['number'];
    if (id == null ||
        id.isEmpty ||
        hadithKey == null ||
        added == null ||
        slug == null ||
        number is! int) {
      throw const FormatException('Malformed PersonalHadith');
    }
    return PersonalHadith(
      id: id,
      hadithKey: hadithKey,
      slug: slug,
      number: number,
      addedDateKey: added,
      arabic: json['arabic'] is String ? json['arabic'] as String : '',
      translation: json['translation'] is String
          ? json['translation'] as String
          : '',
      wordsPending: json['wordsPending'] == true,
      schemaVersion: json['schemaVersion'] is int
          ? json['schemaVersion'] as int
          : kPersonalHadithSchemaVersion,
    );
  }

  factory PersonalHadith.fromRef({
    required HadithRef ref,
    required String addedDateKey,
    String arabic = '',
    String translation = '',
    bool wordsPending = false,
  }) {
    return PersonalHadith(
      id: ref.catalogId,
      hadithKey: ref.hadithKey,
      slug: ref.slug,
      number: ref.number,
      addedDateKey: addedDateKey,
      arabic: arabic,
      translation: translation,
      wordsPending: wordsPending,
    );
  }
}

List<PracticeHadithItem> personalHadithLearnItems(
  Iterable<PersonalHadith> shelf,
) {
  final ordered = shelf.toList()
    ..sort((a, b) {
      final byDate = a.addedDateKey.compareTo(b.addedDateKey);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
  return [for (final item in ordered) item.toLearnItem()];
}
