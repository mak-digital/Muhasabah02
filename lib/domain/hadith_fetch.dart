import 'dart:convert';

import 'hadith_ref.dart';

class HadithFetchException implements Exception {
  const HadithFetchException();
}

class FetchedHadith {
  const FetchedHadith({
    required this.arabic,
    required this.translation,
  });

  final String arabic;
  final String translation;
}

typedef HadithHttpGet = Future<String> Function(Uri uri);

abstract class HadithFetch {
  Future<FetchedHadith> load(HadithRef ref);
}

/// Reads Arabic and English from a public hadith JSON API (not the WebView).
class PublicHadithFetch implements HadithFetch {
  const PublicHadithFetch({this.get});

  final HadithHttpGet? get;

  @override
  Future<FetchedHadith> load(HadithRef ref) async {
    final get = this.get;
    if (get == null) throw const HadithFetchException();
    final edition = hadithApiEdition(ref.slug);
    try {
      final translation = await _textFrom(
        get,
        Uri.https(
          'cdn.jsdelivr.net',
          '/gh/fawazahmed0/hadith-api@1/editions/eng-$edition/${ref.number}.min.json',
        ),
      );
      final arabic = await _textFrom(
        get,
        Uri.https(
          'cdn.jsdelivr.net',
          '/gh/fawazahmed0/hadith-api@1/editions/ara-$edition/${ref.number}.min.json',
        ),
      );
      if (arabic.isEmpty && translation.isEmpty) {
        throw const HadithFetchException();
      }
      return FetchedHadith(arabic: arabic, translation: translation);
    } catch (_) {
      throw const HadithFetchException();
    }
  }

  Future<String> _textFrom(HadithHttpGet get, Uri uri) async {
    try {
      return parseHadithApiText(await get(uri));
    } catch (_) {
      return '';
    }
  }
}

String parseHadithApiText(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map) throw const HadithFetchException();
  final hadiths = decoded['hadiths'];
  if (hadiths is List && hadiths.isNotEmpty && hadiths.first is Map) {
    final text = Map<String, dynamic>.from(hadiths.first)['text'];
    if (text is String && text.trim().isNotEmpty) {
      return _stripHtml(text);
    }
  }
  final text = decoded['text'];
  if (text is String && text.trim().isNotEmpty) return _stripHtml(text);
  throw const HadithFetchException();
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
