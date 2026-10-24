/// Chapter and verse (or short range) a person can bring into Qur’an Learn.
///
/// Built-in catalog entries are not rewritten. Identity is the verse key.
const int kMaxBringQuranVerses = 7;

/// Uthmani verse counts for surahs 1–114.
const List<int> kQuranSurahVerseCounts = [
  7,
  286,
  200,
  176,
  120,
  165,
  206,
  75,
  129,
  109,
  123,
  111,
  43,
  52,
  99,
  128,
  111,
  110,
  98,
  135,
  112,
  78,
  118,
  64,
  77,
  227,
  93,
  88,
  69,
  60,
  34,
  30,
  73,
  54,
  45,
  83,
  182,
  88,
  75,
  85,
  54,
  53,
  89,
  59,
  37,
  35,
  38,
  29,
  18,
  45,
  60,
  49,
  62,
  55,
  78,
  96,
  29,
  22,
  24,
  13,
  14,
  11,
  11,
  18,
  12,
  12,
  30,
  52,
  52,
  44,
  28,
  28,
  20,
  56,
  40,
  31,
  50,
  40,
  46,
  42,
  29,
  19,
  36,
  25,
  22,
  17,
  19,
  26,
  30,
  20,
  15,
  21,
  11,
  8,
  8,
  19,
  5,
  8,
  8,
  11,
  11,
  8,
  3,
  9,
  5,
  4,
  7,
  3,
  6,
  3,
  5,
  4,
  5,
  6,
];

enum QuranVerseParseStatus { empty, ok, invalid, tooLong }

class QuranVerseRange {
  const QuranVerseRange({
    required this.surah,
    required this.start,
    required this.end,
  });

  final int surah;
  final int start;
  final int end;

  int get verseCount => end - start + 1;

  bool get isRange => end != start;

  String get verseKey => isRange ? '$surah:$start-$end' : '$surah:$start';

  String get catalogId =>
      isRange ? 'uq.$surah.$start-$end' : 'uq.$surah.$start';

  String get citation =>
      isRange ? 'Qur’an $surah:$start–$end' : 'Qur’an $surah:$start';

  @override
  bool operator ==(Object other) {
    return other is QuranVerseRange &&
        other.surah == surah &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(surah, start, end);
}

class QuranVerseParseResult {
  const QuranVerseParseResult._(this.status, [this.range]);

  const QuranVerseParseResult.ok(QuranVerseRange range)
    : this._(QuranVerseParseStatus.ok, range);

  const QuranVerseParseResult.empty() : this._(QuranVerseParseStatus.empty);

  const QuranVerseParseResult.invalid() : this._(QuranVerseParseStatus.invalid);

  const QuranVerseParseResult.tooLong() : this._(QuranVerseParseStatus.tooLong);

  final QuranVerseParseStatus status;
  final QuranVerseRange? range;
}

QuranVerseParseResult parseQuranVerseInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return const QuranVerseParseResult.empty();
  final fromUri = parseQuranComUri(_quranComUriFromInput(trimmed));
  if (fromUri != null) return fromUri;
  return parseQuranCitation(trimmed);
}

QuranVerseParseResult parseQuranCitation(String source) {
  var text = _asciiVerseDashes(source.trim());
  text = text.replaceFirst(RegExp(r"^Qur['’]an\s+", caseSensitive: false), '');
  final match = RegExp(r'^(\d+)\s*[:/]\s*(\d+)(?:\s*-\s*(\d+))?$')
      .firstMatch(text.trim());
  if (match == null) return const QuranVerseParseResult.invalid();
  return _rangeFromParts(match.group(1), match.group(2), match.group(3));
}

QuranVerseParseResult? parseQuranComUri(Uri? uri) {
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  if (host != 'quran.com' && host != 'www.quran.com' && host != 'm.quran.com') {
    return null;
  }
  final segs = [
    for (final seg in uri.pathSegments)
      if (seg.isNotEmpty) seg,
  ];
  if (segs.isEmpty) return const QuranVerseParseResult.invalid();
  final surahRaw = segs.first;
  if (int.tryParse(surahRaw) == null) {
    return const QuranVerseParseResult.invalid();
  }
  if (segs.length == 1) {
    final starting = uri.queryParameters['startingVerse'];
    if (starting == null || starting.isEmpty) {
      return const QuranVerseParseResult.invalid();
    }
    return _rangeFromParts(surahRaw, starting, null);
  }
  final versePart = _asciiVerseDashes(segs[1]);
  final dash = RegExp(r'^(\d+)\s*-\s*(\d+)$').firstMatch(versePart);
  if (dash != null) {
    return _rangeFromParts(surahRaw, dash.group(1), dash.group(2));
  }
  return _rangeFromParts(surahRaw, versePart, null);
}

String? quranVerseKeyFromSource(String source) {
  final parsed = parseQuranCitation(source);
  return parsed.range?.verseKey;
}

bool quranVerseKeyTaken({
  required String verseKey,
  required Iterable<String> catalogSources,
  required Iterable<String> shelfKeys,
}) {
  if (shelfKeys.contains(verseKey)) return true;
  for (final source in catalogSources) {
    if (quranVerseKeyFromSource(source) == verseKey) return true;
  }
  return false;
}

QuranVerseParseResult _rangeFromParts(
  String? surahRaw,
  String? startRaw,
  String? endRaw,
) {
  final surah = int.tryParse(surahRaw ?? '');
  final start = int.tryParse(startRaw ?? '');
  if (surah == null || start == null) {
    return const QuranVerseParseResult.invalid();
  }
  final end = endRaw == null || endRaw.isEmpty ? start : int.tryParse(endRaw);
  if (end == null) return const QuranVerseParseResult.invalid();
  if (surah < 1 || surah > kQuranSurahVerseCounts.length) {
    return const QuranVerseParseResult.invalid();
  }
  final last = kQuranSurahVerseCounts[surah - 1];
  if (start < 1 || end < start || end > last) {
    return const QuranVerseParseResult.invalid();
  }
  if (end - start + 1 > kMaxBringQuranVerses) {
    return const QuranVerseParseResult.tooLong();
  }
  return QuranVerseParseResult.ok(
    QuranVerseRange(surah: surah, start: start, end: end),
  );
}

String _asciiVerseDashes(String raw) {
  return raw.replaceAll('–', '-').replaceAll('—', '-');
}

Uri? _quranComUriFromInput(String raw) {
  if (!raw.toLowerCase().contains('quran.com')) return null;
  final withScheme = raw.contains('://') ? raw : 'https://$raw';
  return Uri.tryParse(withScheme);
}
