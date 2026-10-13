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

ReflectionQuote? quoteFor({
  required DateTime now,
  required QuotationCadence cadence,
  String? holdPeriod,
  int? holdIndex,
}) {
  if (cadence == QuotationCadence.hidden) return null;
  final period = reflectionPeriodKey(now, cadence);
  if (holdPeriod == period &&
      holdIndex != null &&
      holdIndex >= 0 &&
      holdIndex < kReflectionQuotes.length) {
    return kReflectionQuotes[holdIndex];
  }
  final day = _utcDayBucket(now);
  final bucket = cadence == QuotationCadence.daily ? day : day ~/ 7;
  final domains = MonitorDomain.values;
  final domain = domains[bucket % domains.length];
  final pool = [
    for (final quote in kReflectionQuotes)
      if (quote.domain == domain) quote,
  ];
  if (pool.isEmpty) return kReflectionQuotes[bucket % kReflectionQuotes.length];
  return pool[bucket % pool.length];
}
