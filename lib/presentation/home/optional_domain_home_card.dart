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
import '../../domain/personal_mix.dart';
import '../../domain/quran.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/check_in_screen.dart';
import '../progress/optional_domain_progress_screen.dart';
import '../shared/activity_picker.dart';
import '../shared/state_marker.dart';
import '../shared/today_mark_halo.dart';
import '../shared/week_nav_strip.dart';

class OptionalDomainHomeCard extends ConsumerStatefulWidget {
  const OptionalDomainHomeCard({
    super.key,
    required this.records,
    required this.title,
    required this.rows,
    required this.washLight,
    required this.washDark,
    required this.family,
    this.includeZakat = false,
    this.includeHadithFocus = false,
    this.includeHajjStatus = false,
    this.highlightLunarWhiteDays = false,
    this.focus,
    this.includeStruggleNote = false,
    this.compactWeek = false,
    this.progressRows,
    this.itemRowsOn7Days = true,
  });

  final List<DailyCheckIn> records;
  final String title;
  final List<HomeTraceRow> rows;
  final Color washLight;
  final Color washDark;
  final Color family;
  final bool includeZakat;
  final bool includeHadithFocus;
  final bool includeHajjStatus;
  final bool highlightLunarWhiteDays;
  final String? focus;
  final bool includeStruggleNote;
  final bool compactWeek;
  final List<HomeTraceRow>? progressRows;
  final bool itemRowsOn7Days;

  @override
  ConsumerState<OptionalDomainHomeCard> createState() =>
      _OptionalDomainHomeCardState();
}

class _OptionalDomainHomeCardState
    extends ConsumerState<OptionalDomainHomeCard> {
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
    final wash = MuhasabahColors.wash(
      widget.washLight,
      widget.washDark,
      Theme.of(context).brightness,
    );
    final localizations = MaterialLocalizations.of(context);
    final hajjStatus = ref.watch(appPrefsProvider).hajjStatus;
    final visibleRows = widget.includeHajjStatus
        ? hajjRowsForStatus(widget.rows, hajjStatus)
        : widget.rows;
    final bands = bandsFor(visibleRows);
    final question = widget.focus;
    final showWeek = visibleRows.isNotEmpty;

    return Semantics(
      container: true,
      label: '${widget.title} week',
      child: Material(
        color: wash,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeWeekChrome(
                title: widget.title,
                question: question,
                family: widget.family,
                cardWash: wash,
                weekLabel: weekRangeLabel(weekStart, calendar: calendar),
                onPreviousWeek: () => setState(() => _weekOffset--),
                onNextWeek: () => setState(() => _weekOffset++),
                nextWeekEnabled: _weekOffset < 0,
                showCurrentWeek: _weekOffset != 0,
                onCurrentWeek: () => setState(() => _weekOffset = 0),
                onTitleTap: widget.compactWeek
                    ? _openProgress
                    : () {
                        refreshNowIfLocalDateChanged(ref);
                        _openDomainDay(dateKey(ref.read(nowProvider)));
                      },
              ),
              const SizedBox(height: 4),
              if (widget.includeHajjStatus) _hajjStatus(),
              if (showWeek) ...[
                Row(
                  children: [
                    if (!widget.compactWeek) const SizedBox(width: 86),
                    for (var col = 0; col < kCalendarWeekdayCount; col++)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              localizations.narrowWeekdays[(firstDay + col) %
                                  7],
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
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
                  _compactWeekRow(keys: keys, index: index, rows: visibleRows)
                else ...[
                  for (final band in bands) ...[
                    _band(
                      band: band,
                      rows: [
                        for (final row in visibleRows)
                          if (row.band == band) row,
                      ],
                      keys: keys,
                      index: index,
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (widget.includeZakat) _zakatBand(keys: keys, index: index),
                ],
              ],
              if (widget.includeHadithFocus) _hadithFocus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hadithFocus() {
    final prefs = ref.watch(appPrefsProvider);
    final current = prefs.hadithMemorisationFocus;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.family.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CheckInRowLabel(Copy.hadithMemorisationFocus),
              CheckInSelect<HadithMemorisationFocus>(
                value: current,
                entries: [
                  for (final option in HadithMemorisationFocus.values)
                    CheckInSelectEntry(value: option, label: option.label),
                ],
                onChanged: (option) async {
                  await prefs.setHadithMemorisationFocus(option);
                  ref.read(prefsTickProvider.notifier).state++;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hajjStatus() {
    final prefs = ref.watch(appPrefsProvider);
    final current = prefs.hajjStatus;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.family.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CheckInRowLabel(Copy.hajjStatusLabel),
              CheckInSelect<HajjStatus>(
                dropdownKey: const Key('hajj-status'),
                value: current,
                entries: [
                  for (final option in HajjStatus.values)
                    CheckInSelectEntry(value: option, label: option.label),
                ],
                onChanged: (option) async {
                  await prefs.setHajjStatus(option);
                  ref.read(prefsTickProvider.notifier).state++;
                },
              ),
              const SizedBox(height: 6),
              Text(
                Copy.hajjStatusNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactWeekRow({
    required List<String> keys,
    required Map<String, DailyCheckIn> index,
    required List<HomeTraceRow> rows,
  }) {
    final domainId = rows.isEmpty
        ? (widget.includeHajjStatus ? 'hajj' : 'domain')
        : rows.first.storageKey.split('.').first;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.family.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Row(
          children: [
            for (final key in keys)
              Expanded(
                child: _compactDayCell(
                  domainId: domainId,
                  key: key,
                  record: index[key],
                  rows: rows,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _compactDayCell({
    required String domainId,
    required String key,
    required DailyCheckIn? record,
    required List<HomeTraceRow> rows,
  }) {
    final whiteDay = widget.highlightLunarWhiteDays && isLunarWhiteDayKey(key);
    final recorded =
        record?.homeTraceDayRecorded(
          rows: rows,
          includeZakat: widget.includeZakat,
          includeStruggleNote: widget.includeStruggleNote,
        ) ??
        false;
    final kind = dateCellKind(key, ref.read(nowProvider));
    final marker = RecordedStateMarker(
      kind: markerForRecorded(recorded: recorded, positive: recorded),
      semanticLabel: recorded
          ? '$key ${widget.title} recorded'
          : '$key ${widget.title} not recorded',
    );
    return InkWell(
      key: Key('home-compact-$domainId-$key'),
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () => _openDomainDay(key),
      ),
      customBorder: const CircleBorder(),
      child: Center(
        child: decorateWeekMark(
          marker: marker,
          kind: kind,
          lunarWhiteDay: whiteDay,
          todayKey: Key('home-today-$domainId-$key'),
          lunarKey: Key('home-lunar-white-$domainId-$key'),
        ),
      ),
    );
  }

  Widget _band({
    required String band,
    required List<HomeTraceRow> rows,
    required List<String> keys,
    required Map<String, DailyCheckIn> index,
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
              band.toUpperCase(),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 86,
                      height: 32,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          row.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                    for (final key in keys)
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: _homeDayCell(key: key, row: row, index: index),
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

  Widget _homeDayCell({
    required String key,
    required HomeTraceRow row,
    required Map<String, DailyCheckIn> index,
  }) {
    final whiteDay = widget.highlightLunarWhiteDays && isLunarWhiteDayKey(key);
    final outcome =
        index[key]?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
    final kind = dateCellKind(key, ref.read(nowProvider));
    final marker = RecordedStateMarker(
      kind: markerForRecorded(
        recorded: outcome.isRecorded,
        positive: outcome == TernaryOutcome.positive,
      ),
      semanticLabel: '$key ${row.label} ${outcome.legendLabel}',
    );
    return InkWell(
      key: Key('home-${row.storageKey}-$key'),
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () =>
            _openDomainDay(key, band: row.band, rowId: row.storageKey),
      ),
      customBorder: const CircleBorder(),
      child: Center(
        child: decorateWeekMark(
          marker: marker,
          kind: kind,
          lunarWhiteDay: whiteDay,
          todayKey: Key('home-today-${row.storageKey}-$key'),
          lunarKey: Key('home-lunar-white-${row.storageKey}-$key'),
        ),
      ),
    );
  }

  Widget _zakatBand({
    required List<String> keys,
    required Map<String, DailyCheckIn> index,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.family.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ZAKAT STATUS',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 86,
                  child: Text(
                    'Zakat',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                for (final key in keys)
                  Expanded(child: _zakatCell(key, index[key])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _zakatCell(String key, DailyCheckIn? record) {
    final marker = ZakatStateMarker(
      status: record?.zakat ?? ZakatStatus.unanswered,
    );
    final kind = dateCellKind(key, ref.read(nowProvider));
    return InkWell(
      key: Key('home-zakat-$key'),
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () =>
            _openDomainDay(key, band: kZakatTraceBand, rowId: kZakatMixKey),
      ),
      customBorder: const CircleBorder(),
      child: Center(
        child: decorateWeekMark(marker: marker, kind: kind),
      ),
    );
  }

  void _openProgress() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OptionalDomainProgressScreen(
          title: widget.title,
          focusQuestion: widget.focus,
          rows: widget.progressRows ?? widget.rows,
          family: widget.family,
          includeZakat: widget.includeZakat,
          includeHadithFocus: widget.includeHadithFocus,
          includeHajjStatus: widget.includeHajjStatus,
          highlightLunarWhiteDays: widget.highlightLunarWhiteDays,
          includeStruggleNote: widget.includeStruggleNote,
          itemRowsOn7Days: widget.itemRowsOn7Days,
        ),
      ),
    );
  }

  void _openDomainDay(String key, {String? band, String? rowId}) {
    openFocusedCheckIn(
      context,
      dateKey: key,
      focus: CheckInFocus.traces,
      domainTitle: widget.title,
      domainFocus: widget.focus,
      focusBand: band,
      focusRowId: rowId,
      traceRows: widget.rows,
      includeZakat: widget.includeZakat,
      includeHadithFocus: widget.includeHadithFocus,
      includeHajjStatus: widget.includeHajjStatus,
      includeStruggleNote: widget.includeStruggleNote,
      familyColor: widget.family,
    );
  }
}
