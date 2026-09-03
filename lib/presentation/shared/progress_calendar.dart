import 'package:flutter/material.dart';

import '../../app/dimensions.dart';
import '../../domain/date_key.dart';
import '../../domain/weekly_calendar.dart';

class ProgressCalendarGrid extends StatelessWidget {
  const ProgressCalendarGrid({
    super.key,
    required this.dateKeys,
    required this.cellBuilder,
  });

  final List<String> dateKeys;
  final Widget Function(BuildContext context, String dateKey) cellBuilder;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDay = localizations.firstDayOfWeekIndex;
    final layout = weeklyCalendarLayout(
      periodKeys: dateKeys,
      firstDayOfWeekIndex: firstDay,
    );
    if (layout.weekCount == 0) return const SizedBox.shrink();

    const stride = AppDimensions.progressCalendarStride;
    final gridWidth =
        AppDimensions.progressWeekdayLabelWidth + layout.weekCount * stride;
    final grid = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: AppDimensions.progressWeekdayLabelWidth),
            for (var week = 0; week < layout.weekCount; week++)
              SizedBox(
                width: stride,
                height: AppDimensions.progressCalendarHeaderHeight,
                child: Text(
                  '${layout.weekStarts[week].day}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
          ],
        ),
        for (var row = 0; row < kCalendarWeekdayCount; row++)
          Row(
            children: [
              SizedBox(
                width: AppDimensions.progressWeekdayLabelWidth,
                height: stride,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localizations.narrowWeekdays[(firstDay + row) % 7],
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
              for (var week = 0; week < layout.weekCount; week++)
                SizedBox(
                  width: stride,
                  height: stride,
                  child: Align(
                    alignment: Alignment.center,
                    child: _cell(context, layout.keyAt(row: row, week: week)),
                  ),
                ),
            ],
          ),
      ],
    );
    return Semantics(
      container: true,
      label: 'Weekly calendar. Rows are weekdays. Columns are weeks.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth ||
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

  Widget _cell(BuildContext context, String? key) {
    if (key == null) {
      return const ExcludeSemantics(
        child: SizedBox(
          width: AppDimensions.progressMarker,
          height: AppDimensions.progressMarker,
        ),
      );
    }
    return SizedBox(
      width: AppDimensions.progressMarker,
      height: AppDimensions.progressMarker,
      child: cellBuilder(context, key),
    );
  }
}

class ProgressCalendarSection extends StatelessWidget {
  const ProgressCalendarSection({
    super.key,
    required this.dateKeys,
    required this.periodDays,
    required this.cellBuilder,
  });

  final List<String> dateKeys;
  final int periodDays;
  final Widget Function(BuildContext context, String dateKey) cellBuilder;

  @override
  Widget build(BuildContext context) {
    final chunks = progressCalendarChunks(dateKeys, periodDays: periodDays);
    final labels = progressCalendarChunkLabels(periodDays);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < chunks.length; i++) ...[
          if (labels.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                labels[i],
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ProgressCalendarGrid(
            key: Key('calendar-chunk-$i'),
            dateKeys: chunks[i],
            cellBuilder: cellBuilder,
          ),
        ],
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
