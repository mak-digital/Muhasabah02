import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/home_traces.dart';
import '../../domain/quran.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/trace_record_sheets.dart';
import '../shared/lunar_white_day_highlight.dart';
import '../shared/progress_calendar.dart';
import '../shared/state_marker.dart';
import '../shared/today_mark_halo.dart';
import '../shared/ui_bits.dart';

class WeekMatrixColumn {
  const WeekMatrixColumn({
    required this.header,
    required this.cell,
    this.verticalHeader = false,
  });

  final String header;
  final bool verticalHeader;
  final Widget Function(BuildContext context, String dateKey) cell;
}

class WeekMatrixBoard extends ConsumerStatefulWidget {
  const WeekMatrixBoard({
    super.key,
    required this.title,
    required this.columns,
    required this.family,
    this.highlightLunarWhiteDays = false,
  });

  final String title;
  final List<WeekMatrixColumn> columns;
  final Color family;
  final bool highlightLunarWhiteDays;

  static const _dowWidth = 22.0;
  static const _dateWidth = 28.0;
  static const _compactMarkWidth = 48.0;

  @override
  ConsumerState<WeekMatrixBoard> createState() => _WeekMatrixBoardState();
}

class _WeekMatrixBoardState extends ConsumerState<WeekMatrixBoard> {
  var _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.columns.isEmpty) return const SizedBox.shrink();
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final firstDay = ref
        .read(appPrefsProvider)
        .firstDayOfWeek
        .sundayBasedIndex(
          MaterialLocalizations.of(context).firstDayOfWeekIndex,
        );
    final calendar = ref.read(appPrefsProvider).displayCalendar;
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = startOfWeek(now, firstDayOfWeekIndex: firstDay);
    final weekStart = addCalendarDays(thisWeekStart, _weekOffset * 7);
    final dateKeys = weekDateKeys(weekStart);
    final canGoNext = !weekStart.isAfter(today);
    final compact = widget.columns.length <= 2;
    final theme = Theme.of(context);
    final table = Table(
      columnWidths: {
        0: const FixedColumnWidth(WeekMatrixBoard._dowWidth),
        1: const FixedColumnWidth(WeekMatrixBoard._dateWidth),
        for (var i = 0; i < widget.columns.length; i++)
          i + 2: compact
              ? const FixedColumnWidth(WeekMatrixBoard._compactMarkWidth)
              : const FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            const SizedBox.shrink(),
            const SizedBox.shrink(),
            for (final column in widget.columns) _header(context, column),
          ],
        ),
        for (final key in dateKeys) _dataRow(context, key, now, calendar),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WashPanel(
        color: Color.alphaBlend(
          widget.family.withValues(alpha: 0.16),
          theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  key: Key('week-matrix-prev-${widget.title}'),
                  tooltip: 'Previous period',
                  onPressed: () => setState(() => _weekOffset--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: Key('week-matrix-next-${widget.title}'),
                  tooltip: 'Next period',
                  onPressed: canGoNext
                      ? () => setState(() => _weekOffset++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Text(
              '(for the week starting on ${formatDayMonthYear(weekStart, calendar)})',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (compact)
              Align(alignment: Alignment.centerLeft, child: table)
            else
              table,
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, WeekMatrixColumn column) {
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(fontWeight: FontWeight.w700);
    final child = column.verticalHeader
        ? RotatedBox(
            quarterTurns: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(column.header, style: style),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              column.header,
              textAlign: TextAlign.center,
              style: style,
            ),
          );
    return Center(child: child);
  }

  TableRow _dataRow(
    BuildContext context,
    String key,
    DateTime now,
    DisplayCalendar calendar,
  ) {
    final date = parseDateKey(key);
    final kind = dateCellKind(key, now);
    final whiteDay = widget.highlightLunarWhiteDays && isLunarWhiteDayKey(key);
    final localizations = MaterialLocalizations.of(context);
    final dow = localizations.narrowWeekdays[date.weekday % 7];
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    Widget wrap(Widget child) {
      if (!whiteDay) return child;
      return LunarWhiteDayHighlight(dense: true, child: child);
    }

    return TableRow(
      children: [
        wrap(
          Padding(
            key: kind == DateCellKind.today
                ? Key('week-matrix-today-$key')
                : null,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              dow,
              style: labelStyle?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        wrap(
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              '${displayParts(date, calendar).day}',
              key: whiteDay ? Key('lunar-white-$key') : null,
              textAlign: TextAlign.right,
              style: labelStyle?.copyWith(
                fontWeight: whiteDay ? FontWeight.w800 : FontWeight.w600,
                color: whiteDay
                    ? MuhasabahColors.wash(
                        MuhasabahColors.lunarWhiteDayInk,
                        MuhasabahColors.lunarWhiteDayInkDark,
                        Theme.of(context).brightness,
                      )
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        for (final column in widget.columns)
          wrap(Center(child: _wrapCell(context, key, kind, column))),
      ],
    );
  }

  Widget _wrapCell(
    BuildContext context,
    String key,
    DateCellKind kind,
    WeekMatrixColumn column,
  ) {
    var child = column.cell(context, key);
    if (kind == DateCellKind.today) {
      child = TodayMarkHalo(child: child);
    }
    if (kind == DateCellKind.future) {
      return IgnorePointer(child: Opacity(opacity: 0.28, child: child));
    }
    return child;
  }
}

class WeekTraceMatrix extends ConsumerWidget {
  const WeekTraceMatrix({
    super.key,
    required this.band,
    required this.rows,
    required this.index,
    required this.family,
    this.cellBuilder,
    this.highlightLunarWhiteDays = false,
    this.onOpenDay,
  });

  final String band;
  final List<HomeTraceRow> rows;
  final Map<String, DailyCheckIn> index;
  final Color family;
  final Widget Function(BuildContext context, String dateKey, HomeTraceRow row)?
  cellBuilder;
  final bool highlightLunarWhiteDays;
  final void Function(BuildContext context, String dateKey)? onOpenDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider);
    return WeekMatrixBoard(
      title: progressBandTitle(band),
      family: family,
      highlightLunarWhiteDays: highlightLunarWhiteDays,
      columns: [
        for (final row in rows)
          WeekMatrixColumn(
            header: row.progressColumn,
            verticalHeader: row.matrixColumnVertical,
            cell: (context, key) =>
                cellBuilder?.call(context, key, row) ??
                _traceCell(context, ref, now, key, row),
          ),
      ],
    );
  }

  Widget _traceCell(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    String key,
    HomeTraceRow row,
  ) {
    final outcome =
        index[key]?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
    return ProgressDayCell(
      key: Key('progress-cell-${row.storageKey}-$key'),
      onTap: matrixCellOnTap(
        dateKey: key,
        now: now,
        onOpen: onOpenDay == null ? null : () => onOpenDay!(context, key),
      ),
      marker: RecordedStateMarker(
        kind: markerForRecorded(
          recorded: outcome.isRecorded,
          positive: outcome == TernaryOutcome.positive,
        ),
        semanticLabel:
            '$key ${weekdayNameForDate(key)} ${row.label} ${outcome.legendLabel}',
      ),
    );
  }
}
