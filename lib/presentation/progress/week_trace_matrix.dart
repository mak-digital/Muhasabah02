import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/copy.dart';
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
    this.subtitle,
  });

  final String header;
  final String? subtitle;
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
    this.itemAsRows = false,
    this.wash,
  });

  final String title;
  final List<WeekMatrixColumn> columns;
  final Color family;
  final bool highlightLunarWhiteDays;
  /// When true, items are rows and weekdays are columns (Home-style).
  final bool itemAsRows;
  final Color? wash;

  static const _dowWidth = 22.0;
  static const _dateWidth = 28.0;
  static const _compactMarkWidth = 48.0;
  static const _labelWidth = 86.0;

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
    final compact = !widget.itemAsRows && widget.columns.length <= 2;
    final theme = Theme.of(context);
    final table = widget.itemAsRows
        ? _itemRowTable(context, dateKeys, now, calendar)
        : Table(
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
              for (final key in dateKeys)
                _dataRow(context, key, now, calendar),
            ],
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WashPanel(
        color: widget.wash ??
            Color.alphaBlend(
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

  Table _itemRowTable(
    BuildContext context,
    List<String> dateKeys,
    DateTime now,
    DisplayCalendar calendar,
  ) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    return Table(
      columnWidths: {
        0: const FixedColumnWidth(WeekMatrixBoard._labelWidth),
        for (var i = 0; i < dateKeys.length; i++)
          i + 1: const FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            const SizedBox.shrink(),
            for (final key in dateKeys)
              _itemDayHeader(context, key, now, calendar, localizations),
          ],
        ),
        for (final column in widget.columns)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      column.header,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                    if (column.subtitle != null)
                      Text(
                        column.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              for (final key in dateKeys)
                Center(
                  child: _wrapDayDecor(
                    key,
                    _wrapCell(context, key, dateCellKind(key, now), column),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _itemDayHeader(
    BuildContext context,
    String key,
    DateTime now,
    DisplayCalendar calendar,
    MaterialLocalizations localizations,
  ) {
    final date = parseDateKey(key);
    final kind = dateCellKind(key, now);
    final whiteDay = widget.highlightLunarWhiteDays && isLunarWhiteDayKey(key);
    final dow = localizations.narrowWeekdays[date.weekday % 7];
    final style = Theme.of(context).textTheme.labelSmall;
    return _wrapDayDecor(
      key,
      Padding(
        key: kind == DateCellKind.today ? Key('week-matrix-today-$key') : null,
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          children: [
            Text(
              dow,
              style: style?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '${displayParts(date, calendar).day}',
              key: whiteDay ? Key('lunar-white-$key') : null,
              style: style?.copyWith(
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
          ],
        ),
      ),
    );
  }

  Widget _wrapDayDecor(String key, Widget child) {
    if (!(widget.highlightLunarWhiteDays && isLunarWhiteDayKey(key))) {
      return child;
    }
    return LunarWhiteDayHighlight(dense: true, child: child);
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
    this.itemAsRows = false,
  });

  final String band;
  final List<HomeTraceRow> rows;
  final Map<String, DailyCheckIn> index;
  final Color family;
  final Widget Function(BuildContext context, String dateKey, HomeTraceRow row)?
  cellBuilder;
  final bool highlightLunarWhiteDays;
  final void Function(BuildContext context, String dateKey)? onOpenDay;
  final bool itemAsRows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider);
    return WeekMatrixBoard(
      title: progressBandTitle(band),
      family: family,
      highlightLunarWhiteDays: highlightLunarWhiteDays,
      itemAsRows: itemAsRows,
      columns: [
        for (final row in rows)
          WeekMatrixColumn(
            header: itemAsRows ? row.label : row.progressColumn,
            verticalHeader: itemAsRows ? false : row.matrixColumnVertical,
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

class HomeStyleWeekMatrix extends ConsumerStatefulWidget {
  const HomeStyleWeekMatrix({
    super.key,
    required this.navId,
    required this.rows,
    required this.index,
    required this.family,
    required this.onOpenDay,
    this.highlightLunarWhiteDays = false,
    this.includeZakat = false,
  });

  final String navId;
  final List<HomeTraceRow> rows;
  final Map<String, DailyCheckIn> index;
  final Color family;
  final bool highlightLunarWhiteDays;
  final bool includeZakat;
  final void Function(BuildContext context, String dateKey, {String? band})
  onOpenDay;

  @override
  ConsumerState<HomeStyleWeekMatrix> createState() =>
      _HomeStyleWeekMatrixState();
}

class _HomeStyleWeekMatrixState extends ConsumerState<HomeStyleWeekMatrix> {
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
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = startOfWeek(now, firstDayOfWeekIndex: firstDay);
    final weekStart = addCalendarDays(thisWeekStart, _weekOffset * 7);
    final dateKeys = weekDateKeys(weekStart);
    final canGoNext = !weekStart.isAfter(today);
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final bands = bandsFor(widget.rows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: Key('week-matrix-prev-${widget.navId}'),
              tooltip: 'Previous period',
              onPressed: () => setState(() => _weekOffset--),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                weekRangeLabel(weekStart, calendar: calendar),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
            IconButton(
              key: Key('week-matrix-next-${widget.navId}'),
              tooltip: 'Next period',
              onPressed: canGoNext
                  ? () => setState(() => _weekOffset++)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _weekOffset == 0
                ? null
                : () => setState(() => _weekOffset = 0),
            child: const Text(Copy.currentWeek),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: WeekMatrixBoard._labelWidth),
            for (final key in dateKeys)
              Expanded(
                child: _dayHeader(context, key, now, calendar, localizations),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (final band in bands) ...[
          _band(
            context: context,
            band: band,
            rows: [
              for (final row in widget.rows)
                if (row.band == band) row,
            ],
            dateKeys: dateKeys,
            now: now,
          ),
          const SizedBox(height: 6),
        ],
        if (widget.includeZakat)
          _zakatBand(context: context, dateKeys: dateKeys, now: now),
      ],
    );
  }

  Widget _dayHeader(
    BuildContext context,
    String key,
    DateTime now,
    DisplayCalendar calendar,
    MaterialLocalizations localizations,
  ) {
    final date = parseDateKey(key);
    final kind = dateCellKind(key, now);
    final whiteDay =
        widget.highlightLunarWhiteDays && isLunarWhiteDayKey(key);
    final dow = localizations.narrowWeekdays[date.weekday % 7];
    final style = Theme.of(context).textTheme.labelSmall;
    final header = Column(
      children: [
        Text(
          dow,
          textAlign: TextAlign.center,
          style: style?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          '${displayParts(date, calendar).day}',
          key: whiteDay ? Key('lunar-white-$key') : null,
          textAlign: TextAlign.center,
          style: style?.copyWith(
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
      ],
    );
    final keyed = kind == DateCellKind.today
        ? KeyedSubtree(key: Key('week-matrix-today-$key'), child: header)
        : header;
    if (!whiteDay) return keyed;
    return LunarWhiteDayHighlight(dense: true, child: keyed);
  }

  Widget _band({
    required BuildContext context,
    required String band,
    required List<HomeTraceRow> rows,
    required List<String> dateKeys,
    required DateTime now,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.family.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              progressBandTitle(band).toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: WeekMatrixBoard._labelWidth,
                      child: Text(
                        row.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    for (final key in dateKeys)
                      Expanded(
                        child: Center(
                          child: _traceCell(context, now, key, row),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _zakatBand({
    required BuildContext context,
    required List<String> dateKeys,
    required DateTime now,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.family.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kZakatTraceBand.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: WeekMatrixBoard._labelWidth,
                  child: Text(
                    'Zakat',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                for (final key in dateKeys)
                  Expanded(
                    child: Center(child: _zakatCell(context, now, key)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _traceCell(
    BuildContext context,
    DateTime now,
    String key,
    HomeTraceRow row,
  ) {
    final outcome =
        widget.index[key]?.homeTrace(row.storageKey) ??
        TernaryOutcome.unanswered;
    final marker = RecordedStateMarker(
      kind: markerForRecorded(
        recorded: outcome.isRecorded,
        positive: outcome == TernaryOutcome.positive,
      ),
      semanticLabel:
          '$key ${weekdayNameForDate(key)} ${row.label} ${outcome.legendLabel}',
    );
    return ProgressDayCell(
      key: Key('progress-cell-${row.storageKey}-$key'),
      onTap: matrixCellOnTap(
        dateKey: key,
        now: now,
        onOpen: () => widget.onOpenDay(context, key, band: row.band),
      ),
      marker: marker,
    );
  }

  Widget _zakatCell(BuildContext context, DateTime now, String key) {
    final status = widget.index[key]?.zakat ?? ZakatStatus.unanswered;
    return ProgressDayCell(
      key: Key('progress-cell-zakat-$key'),
      onTap: matrixCellOnTap(
        dateKey: key,
        now: now,
        onOpen: () =>
            widget.onOpenDay(context, key, band: kZakatTraceBand),
      ),
      marker: ZakatStateMarker(status: status),
    );
  }
}
