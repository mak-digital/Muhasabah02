import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/quran.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/check_in_screen.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';
import '../shared/today_mark_halo.dart';
import '../shared/week_nav_strip.dart';

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
    final rows = [
      for (final band in quranHomeBandsFor(_display)) ...band.$2,
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
              HomeWeekChrome(
                title: MonitorDomain.quran.label,
                question: MonitorDomain.quran.focusQuestion,
                family: MuhasabahColors.quranFamily,
                cardWash: wash,
                weekLabel: weekRangeLabel(weekStart, calendar: calendar),
                onPreviousWeek: () => setState(() => _weekOffset--),
                onNextWeek: () => setState(() => _weekOffset++),
                nextWeekEnabled: _weekOffset < 0,
                showCurrentWeek: _weekOffset != 0,
                onCurrentWeek: () => setState(() => _weekOffset = 0),
                onTitleTap: () {
                  refreshNowIfLocalDateChanged(ref);
                  openFocusedCheckIn(
                    context,
                    dateKey: dateKey(ref.read(nowProvider)),
                    focus: CheckInFocus.quran,
                  );
                },
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (!widget.compactWeek) const SizedBox(width: 92),
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
                          child: _compactCell(key, index[key]),
                        ),
                      ),
                  ],
                )
              else
                for (final dimension in rows)
                  _row(dimension, keys, index, colours),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    QuranDimension dimension,
    List<String> keys,
    Map<String, DailyCheckIn> index,
    bool colours,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              dimension.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          for (final key in keys)
            Expanded(
              child: Center(
                child: _cell(dimension, key, index[key], colours),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(
    QuranDimension dimension,
    String key,
    DailyCheckIn? record,
    bool colours,
  ) {
    final marker = _marker(dimension, key, record, colours);
    final kind = dateCellKind(key, ref.read(nowProvider));
    return ProgressDayCell(
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () => _openDay(
          key,
          band: dimension.homeBand,
          rowId: 'quran.${dimension.name}',
        ),
      ),
      marker: decorateWeekMark(
        marker: marker,
        kind: kind,
        todayKey: Key('home-today-quran-${dimension.name}-$key'),
      ),
    );
  }

  Widget _compactCell(String key, DailyCheckIn? record) {
    var recorded = false;
    for (final dimension in _display) {
      if (record != null && record.quranOutcome(dimension).isRecorded) {
        recorded = true;
        break;
      }
    }
    final marker = RecordedStateMarker(
      kind: markerForRecorded(recorded: recorded, positive: recorded),
      semanticLabel: recorded
          ? '$key ${MonitorDomain.quran.label} recorded'
          : '$key ${MonitorDomain.quran.label} not recorded',
    );
    final kind = dateCellKind(key, ref.read(nowProvider));
    final body = ProgressDayCell(
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () => _openDay(key),
      ),
      marker: decorateWeekMark(marker: marker, kind: kind),
    );
    return KeyedSubtree(key: Key('home-compact-quran-$key'), child: body);
  }

  Widget _marker(
    QuranDimension dimension,
    String key,
    DailyCheckIn? record,
    bool colours,
  ) {
    final outcome = record == null
        ? TernaryOutcome.unanswered
        : record.quranOutcome(dimension);
    final id =
        record?.activityFor(ActivityCatalog.quranKey(dimension)).id ??
        ActivityIds.unanswered;
    return RecordedStateMarker(
      key: Key('quran-home-${dimension.name}-$key'),
      kind: SalahActivityMark.quranDurationKind(id),
      color: SalahActivityMark.quranDurationColour(id, colours: colours),
      semanticLabel: '$key ${dimension.label} ${outcome.legendLabel}',
    );
  }

  void _openDay(String key, {String? band, String? rowId}) {
    openFocusedCheckIn(
      context,
      dateKey: key,
      focus: CheckInFocus.quran,
      focusBand: band,
      focusRowId: rowId,
    );
  }
}
