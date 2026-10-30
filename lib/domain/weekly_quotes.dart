import 'hadith_archive.dart';
import 'monitor_domain.dart';
import 'quotation_cadence.dart';
import 'reflection_catalog.dart';

export 'reflection_catalog.dart';

int _utcDayBucket(DateTime date) {
  final utc = DateTime.utc(date.year, date.month, date.day);
  return utc.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}

String reflectionPeriodKey(DateTime now, QuotationCadence cadence) {
  if (cadence == QuotationCadence.hidden) return '';
  final day = _utcDayBucket(now);
  return cadence == QuotationCadence.daily ? 'd:$day' : 'w:${day ~/ 7}';
}

int reflectionCatalogIndex(ReflectionQuote quote) {
  final index = kReflectionQuotes.indexWhere(
    (item) => item.text == quote.text && item.source == quote.source,
  );
  return index < 0 ? 0 : index;
}

int stepReflectionCatalog(int current, int delta) {
  final n = kReflectionQuotes.length;
  if (n == 0) return 0;
  return ((current + delta) % n + n) % n;
}

int stepReflectionCatalogSkipping(
  int current,
  int delta, {
  Set<String> skipHadithKeys = const {},
}) {
  final usable = usableReflectionQuotes(skipHadithKeys);
  if (usable.isEmpty) return stepReflectionCatalog(current, delta);
  final currentQuote = kReflectionQuotes[wrapReflectionIndex(current)];
  var start = usable.indexWhere(
    (quote) =>
        quote.text == currentQuote.text && quote.source == currentQuote.source,
  );
  if (start < 0) start = 0;
  final next = usable[(start + delta) % usable.length];
  return reflectionCatalogIndex(next);
}

int wrapReflectionIndex(int index) {
  final n = kReflectionQuotes.length;
  if (n <= 0) return 0;
  return ((index % n) + n) % n;
}

ReflectionQuote? quoteFor({
  required DateTime now,
  required QuotationCadence cadence,
  String? holdPeriod,
  int? holdIndex,
  Set<String> skipHadithKeys = const {},
}) {
  if (cadence == QuotationCadence.hidden) return null;
  final usable = usableReflectionQuotes(skipHadithKeys);
  final period = reflectionPeriodKey(now, cadence);
  if (holdPeriod == period &&
      holdIndex != null &&
      holdIndex >= 0 &&
      holdIndex < kReflectionQuotes.length) {
    final held = kReflectionQuotes[holdIndex];
    if (!reflectionHadithIsArchived(held, skipHadithKeys) ||
        usable.length == kReflectionQuotes.length) {
      return held;
    }
  }
  final day = _utcDayBucket(now);
  final bucket = cadence == QuotationCadence.daily ? day : day ~/ 7;
  final domains = MonitorDomain.values;
  final domain = domains[bucket % domains.length];
  final domainPool = [
    for (final quote in usable)
      if (quote.domain == domain) quote,
  ];
  final pool = domainPool.isEmpty ? usable : domainPool;
  if (pool.isEmpty) return kReflectionQuotes[bucket % kReflectionQuotes.length];
  return pool[bucket % pool.length];
}
