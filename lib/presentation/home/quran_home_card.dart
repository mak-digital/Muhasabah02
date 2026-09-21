import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/quran.dart';
import '../../domain/quran_stage.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/check_in_screen.dart';
import '../shared/quran_stage_mark.dart';
import '../shared/state_marker.dart';
import 'quran_day_sheet.dart';

class QuranHomeCard extends ConsumerStatefulWidget {
  const QuranHomeCard({
    super.key,
    required this.records,
    this.compactWeek = false,
    this.displayDimensions,
  });

  final List<DailyCheckIn> records;
  final bool compactWeek;
  final List<QuranDimension>? displayDimensions;

  @override
  ConsumerState<QuranHomeCard> createState() => _QuranHomeCardState();
}

class _QuranHomeCardState extends ConsumerState<QuranHomeCard> {
  var _weekOffset = 0;

  List<QuranDimension> get _display =>
      widget.displayDimensions ?? quranDailyDimensions;

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    ref.watch(checkInsProvider);
    final colours = ref.watch(appPrefsProvider).salahActivityColours;
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
      MuhasabahColors.quranWash,
      MuhasabahColors.quranWashDark,
      brightness,
    );
    final localizations = MaterialLocalizations.of(context);
    final rows = quranJourneyRowsFor(_display);

    return Semantics(
      container: true,
      label: '${MonitorDomain.quran.label} week',
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
                      onTap: () => openFocusedCheckIn(
                        context,
                        dateKey: dateKey(ref.read(nowProvider)),
                        focus: CheckInFocus.quran,
                      ),
                      child: Column(
                        children: [
                          Text(
                            MonitorDomain.quran.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (MonitorDomain.quran.focusQuestion != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              MonitorDomain.quran.focusQuestion!,
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
                  if (!widget.compactWeek) const SizedBox(width: 86),
                  for (var col = 0; col < kCalendarWeekdayCount; col++)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            localizations.narrowWeekdays[(firstDay + col) % 7],
                            key: Key('quran-home-weekday-$col'),
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
                                      ? MuhasabahColors.quranFamily
                                      : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                ),
                          ),
                          Text(
                            '${displayParts(parseDateKey(keys[col]), calendar).day}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (widget.compactWeek)
                Row(
                  children: [
                    for (final key in keys)
                      Expanded(
                        child: Center(
                          child: _compactCell(key, index[key], colours),
                        ),
                      ),
                  ],
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: MuhasabahColors.wash(
                      MuhasabahColors.quranRecitationBand,
                      MuhasabahColors.quranRecitationBandDark,
                      brightness,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Copy.quranJourney.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 6),
                        for (final row in rows)
                          _journeyRow(row, keys, index, colours),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _journeyRow(
    QuranJourneyRow row,
    List<String> keys,
    Map<String, DailyCheckIn> index,
    bool colours,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.label, style: Theme.of(context).textTheme.labelSmall),
                Text(
                  row.purpose,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          for (final key in keys)
            Expanded(
              child: Center(child: _cell(row, key, index[key], colours)),
            ),
        ],
      ),
    );
  }

  Widget _cell(
    QuranJourneyRow row,
    String key,
    DailyCheckIn? record,
    bool colours,
  ) {
    final cell = quranJourneyCell(record, row);
    final marker = QuranJourneyMarker(
      key: Key('quran-home-${row.name}-$key'),
      row: row,
      cell: cell,
      colours: colours,
      semanticLabel: '$key ${row.label} ${cell.code ?? cell.kind.name}',
    );
    final open =
        dateCellKind(key, ref.read(nowProvider)) != DateCellKind.future;
    return ProgressDayCell(
      onTap: open ? () => _openRow(key, row, record) : null,
      marker: open ? marker : Opacity(opacity: 0.28, child: marker),
    );
  }

  Widget _compactCell(String key, DailyCheckIn? record, bool colours) {
    final rows = quranJourneyRowsFor(_display);
    final cell = quranVisibleJourneyOccupancy(record, rows);
    final openRow = quranVisibleJourneyOpenRow(record, rows);
    final marker = QuranJourneyMarker(
      cell: cell,
      colours: colours,
      semanticLabel: '$key ${MonitorDomain.quran.label} ${cell.kind.name}',
    );
    final open =
        dateCellKind(key, ref.read(nowProvider)) != DateCellKind.future;
    final body = ProgressDayCell(
      onTap: open ? () => _openRow(key, openRow, record) : null,
      marker: open ? marker : Opacity(opacity: 0.28, child: marker),
    );
    return KeyedSubtree(key: Key('home-compact-quran-$key'), child: body);
  }

  Future<void> _openRow(String key, QuranJourneyRow row, DailyCheckIn? record) {
    return showQuranJourneySheet(
      context: context,
      dateKey: key,
      calendar: ref.read(appPrefsProvider).displayCalendar,
      row: row,
      record: record,
    );
  }
}
