import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/salah_extras.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/check_in_screen.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';

class SalahHomeCard extends ConsumerStatefulWidget {
  const SalahHomeCard({
    super.key,
    required this.records,
    this.compactWeek = false,
    this.displayRows,
  });

  final List<DailyCheckIn> records;
  final bool compactWeek;
  final List<SalahTraceRow>? displayRows;

  @override
  ConsumerState<SalahHomeCard> createState() => _SalahHomeCardState();
}

class _SalahHomeCardState extends ConsumerState<SalahHomeCard> {
  var _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final firstDay = ref
        .read(appPrefsProvider)
        .firstDayOfWeek
        .sundayBasedIndex(
          MaterialLocalizations.of(context).firstDayOfWeekIndex,
        );
    final calendar = ref.read(appPrefsProvider).displayCalendar;
    final thisWeekStart = startOfWeek(now, firstDayOfWeekIndex: firstDay);
    final weekStart = addCalendarDays(thisWeekStart, _weekOffset * 7);
    final keys = weekDateKeys(weekStart);
    final index = {for (final record in widget.records) record.dateKey: record};
    final brightness = Theme.of(context).brightness;
    final wash = MuhasabahColors.wash(
      MuhasabahColors.salahWash,
      MuhasabahColors.salahWashDark,
      brightness,
    );
    final localizations = MaterialLocalizations.of(context);
    final display = widget.displayRows ?? SalahTraceRow.values;
    final obligatory = [
      for (final row in obligatorySalahRows)
        if (display.contains(row)) row,
    ];
    final friday = display.contains(SalahTraceRow.jumuah);
    final voluntary = [
      for (final row in const [SalahTraceRow.tahajjud, SalahTraceRow.ishraq])
        if (display.contains(row)) row,
    ];

    return Semantics(
      container: true,
      label: '${MonitorDomain.salah.label} week',
      child: Material(
        color: wash,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous week',
                    onPressed: () => setState(() => _weekOffset--),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        refreshNowIfLocalDateChanged(ref);
                        openFocusedCheckIn(
                          context,
                          dateKey: dateKey(ref.read(nowProvider)),
                          focus: CheckInFocus.salah,
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            MonitorDomain.salah.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (MonitorDomain.salah.focusQuestion != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              MonitorDomain.salah.focusQuestion!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(height: 1.35),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next week',
                    onPressed: _weekOffset >= 0
                        ? null
                        : () => setState(() => _weekOffset++),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      weekRangeLabel(weekStart, calendar: calendar),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: _weekOffset == 0
                        ? null
                        : () => setState(() => _weekOffset = 0),
                    child: const Text(Copy.currentWeek),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (!widget.compactWeek) const SizedBox(width: 58),
                  for (var col = 0; col < kCalendarWeekdayCount; col++)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            localizations.narrowWeekdays[(firstDay + col) % 7],
                            key: Key('salah-home-weekday-$col'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      dartWeekdayForRow(
                                            col,
                                            firstDayOfWeekIndex: firstDay,
                                          ) ==
                                          DateTime.friday
                                      ? MuhasabahColors.salahFamily
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            '${displayParts(parseDateKey(keys[col]), calendar).day}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (widget.compactWeek)
                _compactWeekRow(keys: keys, index: index, display: display)
              else ...[
                if (obligatory.isNotEmpty) ...[
                  _band(
                    brightness: brightness,
                    light: MuhasabahColors.salahObligatoryBand,
                    dark: MuhasabahColors.salahObligatoryBandDark,
                    label: 'Obligatory Salah',
                    rows: obligatory,
                    keys: keys,
                    index: index,
                  ),
                  const SizedBox(height: 6),
                ],
                if (friday) ...[
                  _band(
                    brightness: brightness,
                    light: MuhasabahColors.salahFridayBand,
                    dark: MuhasabahColors.salahFridayBandDark,
                    label: 'Friday Prayer',
                    rows: const [SalahTraceRow.jumuah],
                    keys: keys,
                    index: index,
                  ),
                  const SizedBox(height: 6),
                ],
                if (voluntary.isNotEmpty)
                  _band(
                    brightness: brightness,
                    light: MuhasabahColors.salahVoluntaryBand,
                    dark: MuhasabahColors.salahVoluntaryBandDark,
                    label: 'Voluntary Prayers',
                    rows: voluntary,
                    keys: keys,
                    index: index,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactWeekRow({
    required List<String> keys,
    required Map<String, DailyCheckIn> index,
    required List<SalahTraceRow> display,
  }) {
    return Row(
      children: [
        for (final key in keys)
          Expanded(child: _compactCell(key, index[key], display)),
      ],
    );
  }

  Widget _compactCell(
    String key,
    DailyCheckIn? record,
    List<SalahTraceRow> display,
  ) {
    final recorded = _salahDayRecorded(key, record, display);
    final marker = RecordedStateMarker(
      kind: markerForRecorded(recorded: recorded, positive: recorded),
      semanticLabel: recorded
          ? '$key ${MonitorDomain.salah.label} recorded'
          : '$key ${MonitorDomain.salah.label} not recorded',
    );
    final open =
        dateCellKind(key, ref.read(nowProvider)) != DateCellKind.future;
    return InkWell(
      key: Key('home-compact-salah-$key'),
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () => _openSalahDay(key),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: open ? marker : Opacity(opacity: 0.28, child: marker),
        ),
      ),
    );
  }

  bool _salahDayRecorded(
    String key,
    DailyCheckIn? record,
    List<SalahTraceRow> display,
  ) {
    if (record == null) return false;
    for (final row in display) {
      if (row.fridayOnly && !isFridayDateKey(key)) continue;
      if (row.isVoluntary) {
        final outcome = row == SalahTraceRow.tahajjud
            ? record.tahajjud
            : record.ishraq;
        if (outcome.isRecorded) return true;
      } else if (row == SalahTraceRow.jumuah) {
        if (record.jumuah.isRecorded || record.jumuahCongregation) return true;
      } else if (record.prayer(row.prayerId!).isRecorded) {
        return true;
      }
    }
    return false;
  }

  Widget _band({
    required Brightness brightness,
    required Color light,
    required Color dark,
    required String label,
    required List<SalahTraceRow> rows,
    required List<String> keys,
    required Map<String, DailyCheckIn> index,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MuhasabahColors.wash(light, dark, brightness),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            for (final row in rows) _row(row, keys, index),
          ],
        ),
      ),
    );
  }

  Widget _row(
    SalahTraceRow row,
    List<String> keys,
    Map<String, DailyCheckIn> index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          for (final key in keys) Expanded(child: _cell(row, key, index[key])),
        ],
      ),
    );
  }

  Widget _cell(SalahTraceRow row, String key, DailyCheckIn? record) {
    final friday = isFridayDateKey(key);
    if (row.fridayOnly && !friday) {
      return SizedBox(
        key: Key('salah-home-${row.id}-$key'),
        height: AppDimensions.progressMarker + 10,
        child: Semantics(label: '${row.label} not applicable on $key'),
      );
    }
    final kind = dateCellKind(key, ref.read(nowProvider));
    final marker = _marker(row, key, record);
    final open = kind != DateCellKind.future;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: recoverableDateCellOnTap(
          ref: ref,
          dateKey: key,
          onOpen: () => _openSalahDay(key, band: salahHomeBand(row)),
        ),
        child: SizedBox(
          height: AppDimensions.progressMarker + 10,
          width: double.infinity,
          child: Center(
            child: open ? marker : Opacity(opacity: 0.28, child: marker),
          ),
        ),
      ),
    );
  }

  Widget _marker(SalahTraceRow row, String key, DailyCheckIn? record) {
    final colours = ref.watch(appPrefsProvider).salahActivityColours;
    final friday = isFridayDateKey(key);
    final showStar =
        row == SalahTraceRow.dhuhr &&
        friday &&
        (record?.jumuahCongregation ?? false);
    late final MarkerKind kind;
    late final Color color;
    late final String stateLabel;
    if (row.isVoluntary) {
      final outcome = row == SalahTraceRow.tahajjud
          ? (record?.tahajjud ?? TernaryOutcome.unanswered)
          : (record?.ishraq ?? TernaryOutcome.unanswered);
      kind = markerForRecorded(
        recorded: outcome.isRecorded,
        positive: outcome == TernaryOutcome.positive,
      );
      color = MuhasabahColors.mark;
      stateLabel = voluntarySalahLabel(outcome);
    } else {
      final mark = row == SalahTraceRow.jumuah
          ? SalahActivityMark.forJumuah(
              record: record,
              activityColours: colours,
            )
          : SalahActivityMark.forPrayer(
              record: record,
              prayer: row.prayerId!,
              activityColours: colours,
            );
      kind = mark.kind;
      color = mark.color;
      stateLabel = mark.label;
    }
    return RecordedStateMarker(
      key: Key('salah-home-${row.id}-$key'),
      color: color,
      kind: kind,
      symbol: showStar ? Icons.star : null,
      symbolColor: Colors.white,
      symbolSize: AppDimensions.progressMarkerStar,
      semanticLabel:
          '$key ${row.label} $stateLabel${showStar ? ' Friday congregation' : ''}',
    );
  }

  void _openSalahDay(String key, {String? band}) {
    openFocusedCheckIn(
      context,
      dateKey: key,
      focus: CheckInFocus.salah,
      focusBand: band,
    );
  }
}
