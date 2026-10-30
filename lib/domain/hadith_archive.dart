import 'practice_hadith.dart';
import 'practice_hadith_catalog.dart';
import 'reflection_catalog.dart';

final _nonAlnum = RegExp(r'[^a-z0-9]+');
final _citation = RegExp(
  r'(bukhari|muslim|tirmidhi|abudawud|nasai|ibnmajah|malik)[^0-9]{0,16}(\d+)',
);

String foldHadithCitation(String raw) {
  return raw
      .toLowerCase()
      .replaceAll('ṣ', 's')
      .replaceAll('ḥ', 'h')
      .replaceAll('ā', 'a')
      .replaceAll('ī', 'i')
      .replaceAll('ū', 'u')
      .replaceAll('‘', '')
      .replaceAll('’', '')
      .replaceAll("'", '');
}

Set<String> hadithArchiveKeys({
  required String catalogId,
  required String source,
}) {
  final keys = <String>{if (catalogId.isNotEmpty) catalogId};
  final folded = foldHadithCitation(source);
  final compact = folded.replaceAll(_nonAlnum, '');
  if (compact.length >= 8) keys.add(compact);
  for (final match in _citation.allMatches(folded)) {
    keys.add('${match[1]}${match[2]}');
  }
  return keys;
}

Set<String> hadithArchiveKeysForCatalogId(String catalogId) {
  final item = practiceHadithById(catalogId);
  if (item == null) return {if (catalogId.isNotEmpty) catalogId};
  return hadithArchiveKeys(catalogId: item.id, source: item.source);
}

Set<String> archivedHadithCitationKeys({
  required List<PracticeHadithRecord> records,
  required Set<String> archivedCatalogIds,
}) {
  final keys = <String>{};
  for (final id in archivedCatalogIds) {
    keys.addAll(hadithArchiveKeysForCatalogId(id));
  }
  for (final record in records) {
    if (record.archivedAt == null &&
        !archivedCatalogIds.contains(record.catalogId)) {
      continue;
    }
    keys.addAll(
      hadithArchiveKeys(catalogId: record.catalogId, source: record.source),
    );
  }
  return keys;
}

bool reflectionHadithIsArchived(
  ReflectionQuote quote,
  Set<String> archiveKeys,
) {
  if (quote.isQuran || archiveKeys.isEmpty) return false;
  return hadithArchiveKeys(
    catalogId: '',
    source: quote.source,
  ).any(archiveKeys.contains);
}

List<ReflectionQuote> usableReflectionQuotes(Set<String> archiveKeys) {
  if (archiveKeys.isEmpty) return kReflectionQuotes;
  final filtered = [
    for (final quote in kReflectionQuotes)
      if (!reflectionHadithIsArchived(quote, archiveKeys)) quote,
  ];
  return filtered.isEmpty ? kReflectionQuotes : filtered;
}
