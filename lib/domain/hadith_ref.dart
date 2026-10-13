/// Collection and number a person can bring into Hadith Learn.
///
/// Built-in catalog entries are not rewritten. Identity is slug:number.
class HadithRef {
  const HadithRef({required this.slug, required this.number});

  final String slug;
  final int number;

  String get hadithKey => '$slug:$number';

  String get catalogId => 'uh.$slug.$number';

  String get citation {
    final name = hadithCollectionCitationName(slug);
    return name == null ? '$slug $number' : '$name $number';
  }

  @override
  bool operator ==(Object other) {
    return other is HadithRef && other.slug == slug && other.number == number;
  }

  @override
  int get hashCode => Object.hash(slug, number);
}

enum HadithParseStatus { empty, ok, invalid }

class HadithParseResult {
  const HadithParseResult._(this.status, [this.ref]);

  const HadithParseResult.ok(HadithRef ref)
    : this._(HadithParseStatus.ok, ref);

  const HadithParseResult.empty() : this._(HadithParseStatus.empty);

  const HadithParseResult.invalid() : this._(HadithParseStatus.invalid);

  final HadithParseStatus status;
  final HadithRef? ref;
}

String? hadithCollectionSlug(String part) {
  if (part.contains('Adab')) return 'adab';
  if (part.contains('Bukhārī') || part.contains('Bukhari')) return 'bukhari';
  if (part.contains('Muslim')) return 'muslim';
  if (part.contains('Dāwūd') || part.contains('Dawud')) return 'abudawud';
  if (part.contains('Tirmidh')) return 'tirmidhi';
  if (part.contains('Nasā') || part.contains('Nasa')) return 'nasai';
  if (part.contains('Mājah') || part.contains('Majah')) return 'ibnmajah';
  if (part.contains('Mālik') || part.contains('Malik')) return 'malik';
  if (part.contains('Aḥmad') || part.contains('Ahmad')) return 'ahmad';
  final lower = part.toLowerCase().trim();
  return switch (lower) {
    'bukhari' || 'adab' || 'muslim' || 'abudawud' || 'tirmidhi' || 'nasai' ||
    'ibnmajah' || 'malik' || 'ahmad' => lower,
    _ => null,
  };
}

String? hadithCollectionCitationName(String slug) {
  return switch (slug) {
    'bukhari' => 'Ṣaḥīḥ al-Bukhārī',
    'muslim' => 'Ṣaḥīḥ Muslim',
    'abudawud' => 'Sunan Abī Dāwūd',
    'tirmidhi' => 'Jāmiʿ al-Tirmidhī',
    'nasai' => 'Sunan al-Nasāʾī',
    'ibnmajah' => 'Sunan Ibn Mājah',
    'malik' => 'Muwaṭṭaʾ Mālik',
    'ahmad' => 'Musnad Aḥmad',
    'adab' => 'Al-Adab al-Mufrad',
    _ => null,
  };
}

/// Edition path used by the public hadith JSON API (not sunnah.com scrape).
String hadithApiEdition(String slug) {
  return slug == 'adab' ? 'bukhariadab' : slug;
}

HadithParseResult parseHadithInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return const HadithParseResult.empty();
  final fromUri = parseSunnahComUri(_sunnahUriFromInput(trimmed));
  if (fromUri != null) return fromUri;
  return parseHadithCitation(trimmed);
}

HadithParseResult parseHadithCitation(String source) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) return const HadithParseResult.empty();
  final compact = RegExp(
    r'^([a-z]+)\s*:\s*(\d+)$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (compact != null) {
    return _refFromParts(compact.group(1), compact.group(2));
  }
  final numbered = RegExp(r'^(.*?)(\d+)\s*$').firstMatch(trimmed);
  if (numbered == null) return const HadithParseResult.invalid();
  return _refFromParts(numbered.group(1), numbered.group(2));
}

HadithParseResult? parseSunnahComUri(Uri? uri) {
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  if (host != 'sunnah.com' &&
      host != 'www.sunnah.com' &&
      host != 'm.sunnah.com') {
    return null;
  }
  final segs = [
    for (final seg in uri.pathSegments)
      if (seg.isNotEmpty) seg,
  ];
  if (segs.isEmpty) return const HadithParseResult.invalid();
  if (segs.length >= 3) return const HadithParseResult.invalid();
  if (segs.length == 1) {
    final colon = segs.first.split(':');
    if (colon.length != 2) return const HadithParseResult.invalid();
    return _refFromParts(colon[0], colon[1]);
  }
  return _refFromParts(segs[0], segs[1]);
}

Set<String> hadithKeysFromSource(String source) {
  return {
    for (final part in source.split(';'))
      if (parseHadithCitation(part.trim()).ref != null)
        parseHadithCitation(part.trim()).ref!.hadithKey,
  };
}

bool hadithKeyTaken({
  required String hadithKey,
  required Iterable<String> catalogSources,
  required Iterable<String> shelfKeys,
}) {
  if (shelfKeys.contains(hadithKey)) return true;
  for (final source in catalogSources) {
    if (hadithKeysFromSource(source).contains(hadithKey)) return true;
  }
  return false;
}

HadithParseResult _refFromParts(String? slugRaw, String? numberRaw) {
  final slug = hadithCollectionSlug(slugRaw ?? '');
  final number = int.tryParse(numberRaw ?? '');
  if (slug == null || number == null || number < 1) {
    return const HadithParseResult.invalid();
  }
  return HadithParseResult.ok(HadithRef(slug: slug, number: number));
}

Uri? _sunnahUriFromInput(String raw) {
  if (!raw.toLowerCase().contains('sunnah.com')) return null;
  final withScheme = raw.contains('://') ? raw : 'https://$raw';
  return Uri.tryParse(withScheme);
}
