import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dimensions.dart';
import '../../application/providers.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/weekly_calendar.dart';
import '../../domain/thirty_day_trend.dart';
import 'today_mark_halo.dart';
import 'lunar_white_day_highlight.dart';
import 'thirty_day_trend_chart.dart';
import 'ui_bits.dart';

Color monthDayCellWash({
  required Color family,
  required Color surface,
  required int band,
}) {
  if (band.isEven) {
    return Color.alphaBlend(family.withValues(alpha: 0.34), surface);
  }
  return Color.alphaBlend(family.withValues(alpha: 0.08), surface);
}

class ProgressCalendarGrid extends ConsumerWidget {
  const ProgressCalendarGrid({
    super.key,
    required this.dateKeys,
    required this.cellBuilder,
    this.firstDayOfWeekIndex,
    this.expandToWidth = false,
    this.showMonthLabels = false,
    this.bandFamily,
    this.highlightLunarWhiteDays = false,
  });

  final List<String> dateKeys;
  final Widget Function(BuildContext context, String dateKey) cellBuilder;
  final int? firstDayOfWeekIndex;
  final bool expandToWidth;
  final bool showMonthLabels;
  final Color? bandFamily;
  final bool highlightLunarWhiteDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final localizations = MaterialLocalizations.of(context);
    final firstDay =
        firstDayOfWeekIndex ??
        ref
            .read(appPrefsProvider)
            .firstDayOfWeek
            .sundayBasedIndex(localizations.firstDayOfWeekIndex);
    final calendar = ref.read(appPrefsProvider).displayCalendar;
    final layout = weeklyCalendarLayout(
      periodKeys: dateKeys,
      firstDayOfWeekIndex: firstDay,
    );
    if (layout.weekCount == 0) return const SizedBox.shrink();

    const stride = AppDimensions.progressCalendarStride;
    final gridWidth =
        AppDimensions.progressWeekdayLabelWidth + layout.weekCount * stride;
    return Semantics(
      container: true,
      label: 'Weekly calendar. Rows are weekdays. Columns are weeks.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fill =
              expandToWidth &&
              constraints.hasBoundedWidth &&
              constraints.maxWidth.isFinite;
          final grid = _grid(
            context,
            localizations,
            firstDay,
            layout,
            now: now,
            calendar: calendar,
            fill: fill,
            stride: stride,
          );
          if (fill ||
              !constraints.hasBoundedWidth ||
              gridWidth <= constraints.maxWidth) {
            return grid;
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: gridWidth, child: grid),
          );
        },
      ),
    );
  }

  Widget _grid(
    BuildContext context,
    MaterialLocalizations localizations,
    int firstDay,
    WeeklyCalendarLayout layout, {
    required DateTime now,
    required DisplayCalendar calendar,
    required bool fill,
    required double stride,
  }) {
    final monthSpans = weekStartMonthSpans(
      layout.weekStarts,
      calendar: calendar,
    );
    final periodStart = dateKeys.first;
    final surface = Theme.of(context).colorScheme.surface;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final rowHeight = fill
        ? 22.0
        : (stride < AppDimensions.todayMarkHalo
              ? AppDimensions.todayMarkHalo
              : stride);

    Widget weekSlot({
      required int flex,
      required Widget child,
      double? height,
    }) {
      final box = SizedBox(height: height ?? rowHeight, child: child);
      if (fill) {
        return Expanded(flex: flex, child: box);
      }
      return SizedBox(width: stride * flex, child: box);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showMonthLabels)
          Row(
            children: [
              SizedBox(
                width: AppDimensions.progressWeekdayLabelWidth,
                height: AppDimensions.progressCalendarHeaderHeight,
              ),
              for (final span in monthSpans)
                weekSlot(
                  flex: span.span,
                  height: AppDimensions.progressCalendarHeaderHeight,
                  child: Text(
                    span.label,
                    textAlign: TextAlign.center,
                    style: labelStyle?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        Row(
          children: [
            SizedBox(
              width: AppDimensions.progressWeekdayLabelWidth,
              height: AppDimensions.progressCalendarHeaderHeight,
            ),
            for (var week = 0; week < layout.weekCount; week++)
              weekSlot(
                flex: 1,
                height: AppDimensions.progressCalendarHeaderHeight,
                child: Text(
                  '${displayParts(layout.weekStarts[week], calendar).day}',
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
          ],
        ),
        for (var row = 0; row < kCalendarWeekdayCount; row++)
          Row(
            children: [
              SizedBox(
                width: AppDimensions.progressWeekdayLabelWidth,
                height: rowHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localizations.narrowWeekdays[(firstDay + row) % 7],
                    key: Key('calendar-weekday-row-$row'),
                    style: labelStyle,
                  ),
                ),
              ),
              for (var week = 0; week < layout.weekCount; week++)
                weekSlot(
                  flex: 1,
                  child: _shadedCell(
                    context,
                    layout.keyAt(row: row, week: week),
                    periodStart: periodStart,
                    surface: surface,
                    now: now,
                    calendar: calendar,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _shadedCell(
    BuildContext context,
    String? key, {
    required String periodStart,
    required Color surface,
    required DateTime now,
    required DisplayCalendar calendar,
  }) {
    final marker = _cell(context, key, now);
    final whiteDay =
        key != null && highlightLunarWhiteDays && isLunarWhiteDayKey(key);
    Widget child = Align(alignment: Alignment.center, child: marker);
    if (whiteDay) {
      child = LunarWhiteDayHighlight(
        key: Key('lunar-white-$key'),
        dense: true,
        child: child,
      );
    } else if (key != null && bandFamily != null) {
      child = ColoredBox(
        color: monthDayCellWash(
          family: bandFamily!,
          surface: surface,
          band: monthBandIndex(key, periodStart, calendar: calendar),
        ),
        child: child,
      );
    }
    return child;
  }

  Widget _cell(BuildContext context, String? key, DateTime now) {
    if (key == null) {
      return const ExcludeSemantics(
        child: SizedBox(
          width: AppDimensions.progressMarker,
          height: AppDimensions.progressMarker,
        ),
      );
    }
    final kind = dateCellKind(key, now);
    var child = cellBuilder(context, key);
    if (kind == DateCellKind.today) {
      child = TodayMarkHalo(key: Key('calendar-today-$key'), child: child);
    }
    return child;
  }
}

class ProgressCalendarSection extends ConsumerStatefulWidget {
  const ProgressCalendarSection({
    super.key,
    required this.title,
    required this.periodDays,
    required this.cellBuilder,
    this.sectionId,
    this.subtitle,
    this.belowTitle,
    this.summaryLines = const [],
    this.trend,
    this.family,
    this.highlightLunarWhiteDays = false,
  });

  final String title;
  final String? sectionId;
  final String? subtitle;
  final Widget? belowTitle;
  final List<String> summaryLines;
  final ThirtyDayTrendSeries? trend;
  final int periodDays;
  final Color? family;
  final bool highlightLunarWhiteDays;
  final Widget Function(BuildContext context, String dateKey) cellBuilder;

  @override
  ConsumerState<ProgressCalendarSection> createState() =>
      _ProgressCalendarSectionState();
}

class _ProgressCalendarSectionState
    extends ConsumerState<ProgressCalendarSection> {
  var _periodsBack = 0;
  final _boardKey = GlobalKey();
  final _washKey = GlobalKey();
  final _washLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final calendar = ref.read(appPrefsProvider).displayCalendar;
    final keys = shiftedPeriodDateKeys(
      widget.periodDays,
      now: now,
      periodsBack: _periodsBack,
    );
    final navId = widget.sectionId ?? widget.title;
    final long = widget.periodDays >= 90;
    final theme = Theme.of(context);
    final range =
        '(for ${formatDayMonthYear(parseDateKey(keys.first), calendar)} – ${formatDayMonthYear(parseDateKey(keys.last), calendar)})';
    final showThirtySummary =
        widget.periodDays == 30 &&
        (widget.summaryLines.isNotEmpty ||
            widget.belowTitle != null ||
            widget.trend != null);
    final localizations = MaterialLocalizations.of(context);
    final firstDay = ref
        .read(appPrefsProvider)
        .firstDayOfWeek
        .sundayBasedIndex(localizations.firstDayOfWeekIndex);
    final layout = weeklyCalendarLayout(
      periodKeys: keys,
      firstDayOfWeekIndex: firstDay,
    );
    final gridWidth =
        AppDimensions.progressWeekdayLabelWidth +
        layout.weekCount * AppDimensions.progressCalendarStride;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: Key('calendar-prev-$navId'),
              tooltip: 'Previous period',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _periodsBack++),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    range,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            IconButton(
              key: Key('calendar-next-$navId'),
              tooltip: 'Next period',
              visualDensity: VisualDensity.compact,
              onPressed: _periodsBack > 0
                  ? () => setState(() => _periodsBack--)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (long && widget.belowTitle != null) ...[
          const SizedBox(height: 4),
          widget.belowTitle!,
        ],
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final grid = ProgressCalendarGrid(
              key: const Key('calendar-chunk-0'),
              dateKeys: keys,
              cellBuilder: widget.cellBuilder,
              expandToWidth: long,
              showMonthLabels: long,
              bandFamily: long ? widget.family : null,
              highlightLunarWhiteDays: widget.highlightLunarWhiteDays,
            );
            if (!showThirtySummary) return grid;
            final cap = constraints.maxWidth * 0.62;
            final thirtyWidth = !cap.isFinite || gridWidth < cap
                ? gridWidth
                : cap;
            const stride = AppDimensions.progressCalendarStride;
            final rowHeight = stride < AppDimensions.todayMarkHalo
                ? AppDimensions.todayMarkHalo
                : stride;
            final boardHeight =
                AppDimensions.progressCalendarHeaderHeight +
                kCalendarWeekdayCount * rowHeight;
            return SizedBox(
              key: _boardKey,
              height: boardHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: thirtyWidth, child: grid),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.progressCalendarHeaderHeight,
                      ),
                      child: _summaryWash(theme, now),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (!long &&
            widget.periodDays == 30 &&
            widget.trend != null &&
            widget.belowTitle != null) ...[
          const SizedBox(height: 6),
          KeyedSubtree(
            key: const Key('progress-below-title'),
            child: widget.belowTitle!,
          ),
        ],
      ],
    );
  }

  Widget _summaryWash(ThemeData theme, DateTime now) {
    final ink = theme.textTheme.bodySmall?.copyWith(fontSize: 11, height: 1.35);
    final trend = widget.periodDays == 30 ? widget.trend : null;
    Widget child;
    if (trend != null && trend.catalog.isNotEmpty) {
      final todayKey = dateKey(now);
      final windows = [
        measureTrendWindow(
          keys: shiftedPeriodDateKeys(
            30,
            now: now,
            periodsBack: _periodsBack + 2,
          ),
          todayKey: todayKey,
          idForDate: trend.idForDate,
          optionIds: trend.optionIds,
        ),
        measureTrendWindow(
          keys: shiftedPeriodDateKeys(
            30,
            now: now,
            periodsBack: _periodsBack + 1,
          ),
          todayKey: todayKey,
          idForDate: trend.idForDate,
          optionIds: trend.optionIds,
        ),
        measureTrendWindow(
          keys: shiftedPeriodDateKeys(30, now: now, periodsBack: _periodsBack),
          todayKey: todayKey,
          idForDate: trend.idForDate,
          optionIds: trend.optionIds,
        ),
      ];
      final selected = selectFiveTrendOptionIds(
        optionIds: trend.optionIds,
        windows: windows,
      );
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ThirtyDayTrendChart(
              series: trend,
              windows: windows,
              selectedIds: selected,
              calendar: ref.read(appPrefsProvider).displayCalendar,
              anchorKey: _washKey,
              washLink: _washLink,
            ),
          ),
        ],
      );
    } else {
      child = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in widget.summaryLines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ', style: ink),
                    Expanded(child: Text(line, style: ink)),
                  ],
                ),
              ),
            if (widget.belowTitle != null) widget.belowTitle!,
          ],
        ),
      );
    }
    return KeyedSubtree(
      key: const Key('progress-thirty-summary'),
      child: CompositedTransformTarget(
        link: _washLink,
        child: WashPanel(
          key: _washKey,
          color: Color.alphaBlend(
            (widget.family ?? theme.colorScheme.primary).withValues(
              alpha: 0.12,
            ),
            theme.colorScheme.surface,
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          clipBehavior: trend != null ? Clip.none : Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}

List<String> progressThirtyDaySummary({
  required int periodDays,
  required int recordedDays,
  required int activityDays,
  required int notDoneDays,
}) {
  if (periodDays != 30) return const [];
  return [
    'Recorded on $recordedDays of $periodDays days',
    'Activity days $activityDays',
    'Recorded as not done $notDoneDays',
  ];
}

String weekdayNameForDate(String key) {
  return switch (parseDateKey(key).weekday) {
    DateTime.monday => 'Monday',
    DateTime.tuesday => 'Tuesday',
    DateTime.wednesday => 'Wednesday',
    DateTime.thursday => 'Thursday',
    DateTime.friday => 'Friday',
    DateTime.saturday => 'Saturday',
    _ => 'Sunday',
  };
}
