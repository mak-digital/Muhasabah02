import 'dart:convert';

import 'quran_verse_ref.dart';

class QuranVerseFetchException implements Exception {
  const QuranVerseFetchException();
}

class FetchedQuranPassage {
  const FetchedQuranPassage({required this.arabic, required this.translation});

  final String arabic;
  final String translation;
}

typedef QuranVerseHttpGet = Future<String> Function(Uri uri);

abstract class QuranVerseFetch {
  Future<FetchedQuranPassage> load(QuranVerseRange range);
}

/// Reads Arabic and English from the public quran.com API (not the WebView).
class QuranComVerseFetch implements QuranVerseFetch {
  const QuranComVerseFetch({this.get});

  final QuranVerseHttpGet? get;

  @override
  Future<FetchedQuranPassage> load(QuranVerseRange range) async {
    final get = this.get;
    if (get == null) {
      throw const QuranVerseFetchException();
    }
    final uri = Uri.https(
      'api.quran.com',
      '/api/v4/verses/by_chapter/${range.surah}',
      {
        'language': 'en',
        'words': 'false',
        'translations': '20',
        'from': '${range.start}',
        'to': '${range.end}',
        'per_page': '${range.verseCount}',
        'fields': 'text_uthmani',
      },
    );
    try {
      final raw = await get(uri);
      return parseQuranComVersesResponse(raw, range);
    } catch (_) {
      throw const QuranVerseFetchException();
    }
  }
}

FetchedQuranPassage parseQuranComVersesResponse(
  String raw,
  QuranVerseRange range,
) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map) throw const QuranVerseFetchException();
  final verses = decoded['verses'];
  if (verses is! List || verses.isEmpty) {
    throw const QuranVerseFetchException();
  }
  final arabicParts = <String>[];
  final englishParts = <String>[];
  for (final item in verses) {
    if (item is! Map) continue;
    final verse = Map<String, dynamic>.from(item);
    final arabic = _arabicFromVerse(verse);
    final english = _translationFromVerse(verse);
    if (arabic.isNotEmpty) arabicParts.add(arabic);
    if (english.isNotEmpty) englishParts.add(english);
  }
  if (arabicParts.isEmpty && englishParts.isEmpty) {
    throw const QuranVerseFetchException();
  }
  if (arabicParts.length > kMaxBringQuranVerses) {
    throw const QuranVerseFetchException();
  }
  return FetchedQuranPassage(
    arabic: arabicParts.join('\n'),
    translation: englishParts.join('\n'),
  );
}

String _arabicFromVerse(Map<String, dynamic> verse) {
  for (final key in ['text_uthmani', 'text_imlaei', 'text_indopak']) {
    final value = verse[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

String _translationFromVerse(Map<String, dynamic> verse) {
  final translations = verse['translations'];
  if (translations is! List || translations.isEmpty) return '';
  final first = translations.first;
  if (first is! Map) return '';
  final text = first['text'];
  if (text is! String) return '';
  return _stripHtml(text);
}

String _stripHtml(String raw) {
  return raw
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
