import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dimensions.dart';
import '../../application/providers.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/weekly_calendar.dart';
import 'today_mark_halo.dart';
import 'lunar_white_day_highlight.dart';

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
    this.subtitle,
    this.belowTitle,
    this.family,
    this.highlightLunarWhiteDays = false,
  });

  final String title;
  final String? subtitle;
  final Widget? belowTitle;
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
    final long = widget.periodDays >= 90;
    final theme = Theme.of(context);
    final range =
        '(for ${formatDayMonthYear(parseDateKey(keys.first), calendar)} – ${formatDayMonthYear(parseDateKey(keys.last), calendar)})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: Key('calendar-prev-${widget.title}'),
              tooltip: 'Previous period',
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
              key: Key('calendar-next-${widget.title}'),
              tooltip: 'Next period',
              onPressed: _periodsBack > 0
                  ? () => setState(() => _periodsBack--)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Text(
          range,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        if (widget.belowTitle != null) ...[
          const SizedBox(height: 4),
          widget.belowTitle!,
        ],
        const SizedBox(height: 8),
        ProgressCalendarGrid(
          key: const Key('calendar-chunk-0'),
          dateKeys: keys,
          cellBuilder: widget.cellBuilder,
          expandToWidth: long,
          showMonthLabels: long,
          bandFamily: long ? widget.family : null,
          highlightLunarWhiteDays: widget.highlightLunarWhiteDays,
        ),
      ],
    );
  }
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
