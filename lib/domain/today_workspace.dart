import 'activities.dart';
import 'daily_check_in.dart';
import 'home_traces.dart';
import 'monitor_domain.dart';
import 'personal_mix.dart';
import 'personalisation_resolver.dart';
import 'prayer.dart';
import 'quran.dart';
import 'salah_extras.dart';

/// Whether an allowed Today row has an explicit stored response.
///
/// Presentation/workflow only. Not a spiritual outcome, score, or grade.
enum TodayRecordedState {
  /// No explicit response is stored for this row today.
  noResponse,

  /// An explicit valid response is stored, including negative, missed,
  /// excused, late, Other, and none-today where those exist on the row.
  recorded,
}

/// Existing mix/recorder family. Not a rank.
enum TodayRowKind { salah, quran, homeTrace, zakatStatus }

/// One mix-catalog row permitted for [dateKey], mapped to existing storage.
class TodayRow {
  const TodayRow({
    required this.mixId,
    required this.domain,
    required this.kind,
    required this.recordedState,
  });

  /// Existing Personal Mix / catalog id. Not a new persisted identifier.
  final String mixId;
  final MonitorDomain domain;
  final TodayRowKind kind;
  final TodayRecordedState recordedState;

  bool get hasResponse => recordedState == TodayRecordedState.recorded;
}

/// One Home-visible mix domain for today, with mix/catalog row order.
class TodayDomain {
  const TodayDomain({required this.domain, required this.rows});

  final MonitorDomain domain;
  final List<TodayRow> rows;

  List<TodayRow> get recordedRows => [
    for (final row in rows)
      if (row.hasResponse) row,
  ];

  List<TodayRow> get noResponseRows => [
    for (final row in rows)
      if (!row.hasResponse) row,
  ];

  int get mixRowCount => rows.length;
  int get recordedMixCount => recordedRows.length;
}

/// Derived daily workspace. Not persisted.
class TodayWorkspace {
  const TodayWorkspace({required this.dateKey, required this.domains});

  final String dateKey;
  final List<TodayDomain> domains;

  int get mixRowCount => [
    for (final domain in domains) ...domain.rows,
  ].length;

  int get recordedMixCount => [
    for (final domain in domains)
      for (final row in domain.rows)
        if (row.hasResponse) row,
  ].length;
}

/// Pure derivation of Today's domains and rows.
///
/// [record] is used only when its [DailyCheckIn.dateKey] matches [dateKey].
/// Passing null, or a record for another day, yields no-response rows and
/// does not save. Hajj standing mix id is never a daily row.
TodayWorkspace deriveTodayWorkspace({
  required String dateKey,
  required PersonalisationResolver resolver,
  DailyCheckIn? record,
  HajjStatus hajjStatus = HajjStatus.unanswered,
}) {
  final todayRecord = record != null && record.dateKey == dateKey
      ? record
      : null;
  final keys = resolver.effectiveRowIds;
  final friday = isFridayDateKey(dateKey);
  return TodayWorkspace(
    dateKey: dateKey,
    domains: [
      for (final domain in resolver.homeDomains)
        TodayDomain(
          domain: domain,
          rows: _rowsForDomain(
            domain: domain,
            keys: keys,
            friday: friday,
            hajjStatus: hajjStatus,
            record: todayRecord,
          ),
        ),
    ],
  );
}

List<TodayRow> _rowsForDomain({
  required MonitorDomain domain,
  required Set<String> keys,
  required bool friday,
  required HajjStatus hajjStatus,
  required DailyCheckIn? record,
}) {
  switch (domain) {
    case MonitorDomain.salah:
      return [
        for (final row in mixSalahRows(keys))
          if (!row.fridayOnly || friday)
            TodayRow(
              mixId: 'salah.${row.name}',
              domain: domain,
              kind: TodayRowKind.salah,
              recordedState: _salahRecorded(record, row),
            ),
      ];
    case MonitorDomain.quran:
      return [
        for (final dimension in mixQuranDimensions(keys))
          if (dimension != QuranDimension.applicationReflection)
            TodayRow(
              mixId: 'quran.${dimension.name}',
              domain: domain,
              kind: TodayRowKind.quran,
              recordedState: _quranRecorded(record, dimension),
            ),
      ];
    case MonitorDomain.charity:
      final traces = mixTraceRows(domain, keys);
      return [
        for (final row in traces)
          TodayRow(
            mixId: row.storageKey,
            domain: domain,
            kind: TodayRowKind.homeTrace,
            recordedState: _traceRecorded(record, row.storageKey),
          ),
        if (mixIncludesZakat(keys))
          TodayRow(
            mixId: kZakatMixKey,
            domain: domain,
            kind: TodayRowKind.zakatStatus,
            recordedState: _zakatRecorded(record),
          ),
      ];
    case MonitorDomain.hajj:
      final traces = hajjRowsForStatus(mixTraceRows(domain, keys), hajjStatus);
      return [
        for (final row in traces)
          if (row.storageKey != kHajjMixKey)
            TodayRow(
              mixId: row.storageKey,
              domain: domain,
              kind: TodayRowKind.homeTrace,
              recordedState: _traceRecorded(record, row.storageKey),
            ),
      ];
    case MonitorDomain.hadith:
    case MonitorDomain.dhikr:
    case MonitorDomain.akhlaq:
    case MonitorDomain.huquq:
    case MonitorDomain.knowledge:
    case MonitorDomain.time:
    case MonitorDomain.health:
    case MonitorDomain.wealth:
    case MonitorDomain.ummah:
    case MonitorDomain.fasting:
      return [
        for (final row in mixTraceRows(domain, keys))
          TodayRow(
            mixId: row.storageKey,
            domain: domain,
            kind: TodayRowKind.homeTrace,
            recordedState: _traceRecorded(record, row.storageKey),
          ),
      ];
  }
}

TodayRecordedState _salahRecorded(DailyCheckIn? record, SalahTraceRow row) {
  if (record == null) return TodayRecordedState.noResponse;
  final stored = switch (row) {
    SalahTraceRow.jumuah => record.jumuah.isRecorded,
    SalahTraceRow.tahajjud => record.tahajjud.isRecorded,
    SalahTraceRow.ishraq => record.ishraq.isRecorded,
    _ => row.prayerId != null && record.prayer(row.prayerId!).isRecorded,
  };
  return stored ? TodayRecordedState.recorded : TodayRecordedState.noResponse;
}

TodayRecordedState _quranRecorded(
  DailyCheckIn? record,
  QuranDimension dimension,
) {
  if (record == null) return TodayRecordedState.noResponse;
  if (record.quranOutcome(dimension).isRecorded) {
    return TodayRecordedState.recorded;
  }
  return TodayRecordedState.noResponse;
}

TodayRecordedState _traceRecorded(DailyCheckIn? record, String storageKey) {
  if (record == null) return TodayRecordedState.noResponse;
  return record.homeTrace(storageKey).isRecorded
      ? TodayRecordedState.recorded
      : TodayRecordedState.noResponse;
}

TodayRecordedState _zakatRecorded(DailyCheckIn? record) {
  if (record == null) return TodayRecordedState.noResponse;
  return record.zakat.isRecorded
      ? TodayRecordedState.recorded
      : TodayRecordedState.noResponse;
}
