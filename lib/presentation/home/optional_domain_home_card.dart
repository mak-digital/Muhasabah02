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
import '../checkin/check_in_screen.dart';
import '../progress/optional_domain_progress_screen.dart';
import '../shared/activity_picker.dart';
import '../shared/lunar_white_day_highlight.dart';
import '../shared/state_marker.dart';

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
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous week',
                    onPressed: () => setState(() => _weekOffset--),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: widget.compactWeek
                          ? _openProgress
                          : () {
                              refreshNowIfLocalDateChanged(ref);
                              _openDomainDay(dateKey(ref.read(nowProvider)));
                            },
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (question != null && question.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              question,
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
                              localizations.narrowWeekdays[(firstDay + col) % 7],
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
    final marker = RecordedStateMarker(
      kind: markerForRecorded(recorded: recorded, positive: recorded),
      semanticLabel: recorded
          ? '$key ${widget.title} recorded'
          : '$key ${widget.title} not recorded',
    );
    final open =
        dateCellKind(key, ref.read(nowProvider)) != DateCellKind.future;
    final mark = InkWell(
      key: Key('home-compact-$domainId-$key'),
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () => _openDomainDay(key),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: open ? marker : Opacity(opacity: 0.28, child: marker),
        ),
      ),
    );
    if (!whiteDay) return mark;
    return LunarWhiteDayHighlight(
      key: Key('home-lunar-white-$domainId-$key'),
      dense: true,
      child: mark,
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
    final marker = RecordedStateMarker(
      kind: markerForRecorded(
        recorded: outcome.isRecorded,
        positive: outcome == TernaryOutcome.positive,
      ),
      semanticLabel: '$key ${row.label} ${outcome.legendLabel}',
    );
    final open =
        dateCellKind(key, ref.read(nowProvider)) != DateCellKind.future;
    final mark = InkWell(
      key: Key('home-${row.storageKey}-$key'),
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () => _openDomainDay(key, band: row.band),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: open ? marker : Opacity(opacity: 0.28, child: marker),
        ),
      ),
    );
    if (!whiteDay) return mark;
    return LunarWhiteDayHighlight(
      key: Key('home-lunar-white-${row.storageKey}-$key'),
      dense: true,
      child: mark,
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
    final open =
        dateCellKind(key, ref.read(nowProvider)) != DateCellKind.future;
    return InkWell(
      key: Key('home-zakat-$key'),
      onTap: recoverableDateCellOnTap(
        ref: ref,
        dateKey: key,
        onOpen: () => _openDomainDay(key, band: kZakatTraceBand),
      ),
      child: Center(
        child: open ? marker : Opacity(opacity: 0.28, child: marker),
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

  void _openDomainDay(String key, {String? band}) {
    openFocusedCheckIn(
      context,
      dateKey: key,
      focus: CheckInFocus.traces,
      domainTitle: widget.title,
      domainFocus: widget.focus,
      focusBand: band,
      traceRows: widget.progressRows ?? widget.rows,
      includeZakat: widget.includeZakat,
      includeHadithFocus: widget.includeHadithFocus,
      includeHajjStatus: widget.includeHajjStatus,
      includeStruggleNote: widget.includeStruggleNote,
      familyColor: widget.family,
    );
  }
}
