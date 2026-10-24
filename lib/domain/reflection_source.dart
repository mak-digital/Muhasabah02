import 'hadith_ref.dart';

/// Maps a citation string to public pages the in-app reader can load.
///
/// Several sources in one string (split on `;`) become several pages.
/// Records stay on this device.
class ReflectionSourcePage {
  const ReflectionSourcePage({required this.label, required this.uri});

  final String label;
  final Uri uri;
}

List<Uri> reflectionSourceUris(String source) {
  return [for (final page in reflectionSourcePages(source)) page.uri];
}

List<ReflectionSourcePage> reflectionSourcePages(String source) {
  return [for (final part in source.split(';')) ..._pagesForPart(part.trim())];
}

List<ReflectionSourcePage> _pagesForPart(String part) {
  if (part.isEmpty) return const [];
  final quran = _quranUri(part);
  if (quran != null) {
    return [ReflectionSourcePage(label: part, uri: quran)];
  }
  final hadith = _hadithUri(part);
  if (hadith != null) {
    return [ReflectionSourcePage(label: part, uri: hadith)];
  }
  return const [];
}

Uri? _quranUri(String source) {
  final match = RegExp(r"Qur['’]an\s+(\d+)\s*:\s*(\d+)(?:\s*[–—-]\s*(\d+))?")
      .firstMatch(source);
  if (match == null) return null;
  final surah = match.group(1)!;
  final start = match.group(2)!;
  final end = match.group(3);
  final verse = end != null && end != start ? '$start-$end' : start;
  return Uri.https('quran.com', '/$surah/$verse');
}

Uri? _hadithUri(String part) {
  final parsed = parseHadithCitation(part);
  final ref = parsed.ref;
  if (ref == null) return null;
  return Uri.https('sunnah.com', '/${ref.slug}:${ref.number}');
}
