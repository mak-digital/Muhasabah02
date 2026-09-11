import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/quran.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/check_in_screen.dart';
import '../shared/state_marker.dart';

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
      MuhasabahColors.quranWash,
      MuhasabahColors.quranWashDark,
      brightness,
    );
    final localizations = MaterialLocalizations.of(context);
    final display = widget.displayDimensions ?? quranDailyDimensions;
    final recitation = [
      for (final row in recitationHomeRows)
        if (display.contains(row)) row,
    ];
    final retention = [
      for (final row in retentionHomeRows)
        if (display.contains(row)) row,
    ];
    final study = [
      for (final row in studyNoticeHomeRows)
        if (display.contains(row)) row,
    ];

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
                      child: Text(
                        localizations.narrowWeekdays[(firstDay + col) % 7],
                        key: Key('quran-home-weekday-$col'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              dartWeekdayForRow(
                                    col,
                                    firstDayOfWeekIndex: firstDay,
                                  ) ==
                                  DateTime.friday
                              ? MuhasabahColors.quranFamily
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (widget.compactWeek)
                _compactWeekRow(keys: keys, index: index, display: display)
              else ...[
                if (recitation.isNotEmpty) ...[
                  _band(
                    brightness: brightness,
                    light: MuhasabahColors.quranRecitationBand,
                    dark: MuhasabahColors.quranRecitationBandDark,
                    label: 'Recitation',
                    rows: recitation,
                    keys: keys,
                    index: index,
                  ),
                  const SizedBox(height: 6),
                ],
                if (retention.isNotEmpty) ...[
                  _band(
                    brightness: brightness,
                    light: MuhasabahColors.quranRetentionBand,
                    dark: MuhasabahColors.quranRetentionBandDark,
                    label: 'Retention',
                    rows: retention,
                    keys: keys,
                    index: index,
                  ),
                  const SizedBox(height: 6),
                ],
                if (study.isNotEmpty)
                  _band(
                    brightness: brightness,
                    light: MuhasabahColors.quranStudyBand,
                    dark: MuhasabahColors.quranStudyBandDark,
                    label: 'Study & notice',
                    rows: study,
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
    required List<QuranDimension> display,
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
    List<QuranDimension> display,
  ) {
    final recorded =
        record != null &&
        display.any((row) => record.quranOutcome(row).isRecorded);
    final marker = RecordedStateMarker(
      kind: markerForRecorded(recorded: recorded, positive: recorded),
      semanticLabel: recorded
          ? '$key ${MonitorDomain.quran.label} recorded'
          : '$key ${MonitorDomain.quran.label} not recorded',
    );
    final open =
        dateCellKind(key, ref.read(nowProvider)) != DateCellKind.future;
    return InkWell(
      key: Key('home-compact-quran-$key'),
      onTap: open ? () => _openQuranDay(key) : null,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: open ? marker : Opacity(opacity: 0.28, child: marker),
        ),
      ),
    );
  }

  Widget _band({
    required Brightness brightness,
    required Color light,
    required Color dark,
    required String label,
    required List<QuranDimension> rows,
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
    QuranDimension row,
    List<String> keys,
    Map<String, DailyCheckIn> index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          for (final key in keys)
            Expanded(child: Center(child: _cell(row, key, index[key]))),
        ],
      ),
    );
  }

  Widget _cell(QuranDimension row, String key, DailyCheckIn? record) {
    final outcome = record?.quranOutcome(row) ?? TernaryOutcome.unanswered;
    final kind = markerForRecorded(
      recorded: outcome.isRecorded,
      positive: outcome == TernaryOutcome.positive,
    );
    final marker = RecordedStateMarker(
      key: Key('quran-home-${row.name}-$key'),
      color: MuhasabahColors.mark,
      kind: kind,
      semanticLabel: '$key ${row.label} ${outcome.legendLabel}',
    );
    final open =
        dateCellKind(key, ref.read(nowProvider)) != DateCellKind.future;
    return ProgressDayCell(
      onTap: open ? () => _openQuranDay(key, band: row.homeBand) : null,
      marker: open ? marker : Opacity(opacity: 0.28, child: marker),
    );
  }

  void _openQuranDay(String key, {String? band}) {
    openFocusedCheckIn(
      context,
      dateKey: key,
      focus: CheckInFocus.quran,
      focusBand: band,
    );
  }
}
