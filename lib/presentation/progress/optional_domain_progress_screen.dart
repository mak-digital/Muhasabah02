import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/analytics.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/home_traces.dart';
import '../../domain/hajj_planning.dart';
import '../../domain/domain_briefing.dart';
import '../../domain/quran.dart';
import '../../domain/review_period.dart';
import '../checkin/check_in_screen.dart';
import '../checkin/trace_record_sheets.dart';
import '../shared/progress_calendar.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/domain_briefing_note.dart';
import '../shared/state_marker.dart';
import '../shared/ui_bits.dart';
import 'progress_review_frame.dart';
import 'week_trace_matrix.dart';

class OptionalDomainProgressScreen extends ConsumerStatefulWidget {
  const OptionalDomainProgressScreen({
    super.key,
    required this.title,
    required this.rows,
    required this.family,
    this.includeZakat = false,
    this.includeHadithFocus = false,
    this.includeHajjStatus = false,
    this.weekMatricesOn7Days = true,
    this.highlightLunarWhiteDays = false,
    this.focusQuestion,
    this.note,
    this.includeStruggleNote = false,
    this.itemRowsOn7Days = true,
  });

  final String title;
  final String? focusQuestion;
  final String? note;
  final List<HomeTraceRow> rows;
  final Color family;
  final bool includeZakat;
  final bool includeHadithFocus;
  final bool includeHajjStatus;
  final bool weekMatricesOn7Days;
  final bool highlightLunarWhiteDays;
  final bool includeStruggleNote;
  final bool itemRowsOn7Days;

  @override
  ConsumerState<OptionalDomainProgressScreen> createState() =>
      _OptionalDomainProgressScreenState();
}

class _OptionalDomainProgressScreenState
    extends ConsumerState<OptionalDomainProgressScreen> {
  String get title => widget.title;
  String? get focusQuestion => widget.focusQuestion;
  String? get note => widget.note;
  List<HomeTraceRow> get rows => widget.rows;
  Color get family => widget.family;
  bool get includeZakat => widget.includeZakat;
  bool get includeHadithFocus => widget.includeHadithFocus;
  bool get includeHajjStatus => widget.includeHajjStatus;
  bool get weekMatricesOn7Days => widget.weekMatricesOn7Days;
  bool get highlightLunarWhiteDays => widget.highlightLunarWhiteDays;
  bool get includeStruggleNote => widget.includeStruggleNote;
  bool get itemRowsOn7Days => widget.itemRowsOn7Days;

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(reviewPeriodProvider);
    final now = ref.watch(nowProvider);
    final async = ref.watch(checkInsProvider);
    final progressTitle = '$title Progress';
    return Scaffold(
      appBar: progressAppBar(context, progressTitle),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EmptyState(title: progressTitle, message: 'Could not load traces.'),
        data: (records) {
          final index = indexByDate(records);
          ref.watch(prefsTickProvider);
          final hadithFocus = ref
              .watch(appPrefsProvider)
              .hadithMemorisationFocus;
          ref.watch(hajjStoreTickProvider);
          final hajjStanding = ref
              .watch(hajjStoreRepositoryProvider)
              .store
              .standing
              .kind;
          final briefing = briefingForLabel(title);
          return ProgressReviewFrame(
            focusQuestion: focusQuestion,
            days: period.days,
            onPeriodChanged: (days) {
              ref.read(reviewPeriodProvider.notifier).state = switch (days) {
                30 => ReviewPeriod.days30,
                90 => ReviewPeriod.days90,
                _ => ReviewPeriod.days7,
              };
            },
            marksTitle: briefing != null
                ? Copy.aboutThisDomain
                : Copy.progressMarksTitle,
            marks: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The card wash identifies the domain, not rank. Marks share one colour. Missing records are not treated as missed.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (briefing != null) ...[
                  const SizedBox(height: 8),
                  DomainBriefingNote(briefing, compact: true),
                ] else if (note != null && note!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(note!, style: Theme.of(context).textTheme.bodySmall),
                ],
                if (highlightLunarWhiteDays) ...[
                  const SizedBox(height: 8),
                  Text(
                    Copy.lunarWhiteDaysNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            children: [
              if (includeHadithFocus) ...[
                Text(
                  '${Copy.hadithMemorisationFocus}: ${hadithFocus.label}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
              ],
              if (includeHajjStatus) ...[
                Text(
                  '${Copy.hajjStatusLabel}: ${hajjStanding.label}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  Copy.hajjStatusNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
              ],
              if (weekMatricesOn7Days && period.days == 7) ...[
                if (itemRowsOn7Days)
                  HomeStyleWeekMatrix(
                    navId: title,
                    rows: rows,
                    index: index,
                    family: family,
                    highlightLunarWhiteDays: highlightLunarWhiteDays,
                    includeZakat: includeZakat,
                    onOpenDay: _openDay,
                  )
                else ...[
                  ..._weekMatrices(index),
                  if (includeZakat) _zakatWeekMatrix(context, ref, now, index),
                ],
              ] else ...[
                for (final row in rows)
                  _rowCard(context, ref, row, index, period, now),
                if (includeZakat) _zakatCard(context, ref, index, period, now),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _weekMatrices(Map<String, DailyCheckIn> index) {
    return [
      for (final band in bandsFor(rows))
        WeekTraceMatrix(
          band: band,
          rows: [
            for (final row in rows)
              if (row.band == band) row,
          ],
          index: index,
          family: family,
          highlightLunarWhiteDays: highlightLunarWhiteDays,
          itemAsRows: itemRowsOn7Days,
          onOpenDay: (context, key) => _openDay(context, key, band: band),
        ),
    ];
  }

  Widget _zakatWeekMatrix(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    Map<String, DailyCheckIn> index,
  ) {
    const row = HomeTraceRow(
      storageKey: 'zakat',
      label: 'Zakat',
      band: kZakatTraceBand,
      matrixColumn: 'Zakat',
      matrixColumnVertical: true,
    );
    return WeekTraceMatrix(
      band: row.band,
      rows: const [row],
      index: index,
      family: family,
      itemAsRows: itemRowsOn7Days,
      cellBuilder: (context, key, _) {
        final status = index[key]?.zakat ?? ZakatStatus.unanswered;
        return ProgressDayCell(
          key: Key('progress-cell-zakat-$key'),
          onTap: matrixCellOnTap(
            ref: ref,
            context: context,
            dateKey: key,
            onOpen: () =>
                _openDay(context, key, band: kZakatTraceBand, rowId: 'zakat'),
          ),
          marker: ZakatStateMarker(status: status),
        );
      },
    );
  }

  void _openDay(
    BuildContext context,
    String dateKey, {
    String? band,
    String? rowId,
  }) {
    openFocusedCheckIn(
      context,
      dateKey: dateKey,
      focus: CheckInFocus.traces,
      domainTitle: title,
      domainFocus: focusQuestion,
      focusBand: band,
      focusRowId: rowId,
      traceRows: rows,
      includeZakat: includeZakat,
      includeHadithFocus: includeHadithFocus,
      includeHajjStatus: includeHajjStatus,
      includeStruggleNote: includeStruggleNote,
      familyColor: family,
    );
  }

  Widget _rowCard(
    BuildContext context,
    WidgetRef ref,
    HomeTraceRow row,
    Map<String, DailyCheckIn> index,
    ReviewPeriod period,
    DateTime now,
  ) {
    final keys = periodDateKeys(period.days, now: now);
    var recordedDays = 0;
    var activityDays = 0;
    var notDoneDays = 0;
    for (final key in keys) {
      final outcome =
          index[key]?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
      if (!outcome.isRecorded) continue;
      recordedDays++;
      if (outcome == TernaryOutcome.positive) activityDays++;
      if (outcome == TernaryOutcome.negative) notDoneDays++;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WashPanel(
        color: Color.alphaBlend(
          family.withValues(alpha: 0.16),
          Theme.of(context).colorScheme.surface,
        ),
        child: ProgressCalendarSection(
          title: row.label,
          subtitle: displayHomeBand(row.band),
          periodDays: period.days,
          family: family,
          highlightLunarWhiteDays: highlightLunarWhiteDays,
          summaryLines: progressThirtyDaySummary(
            periodDays: period.days,
            recordedDays: recordedDays,
            activityDays: activityDays,
            notDoneDays: notDoneDays,
          ),
          cellBuilder: (context, key) {
            final record = index[key];
            final outcome =
                record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
            final colours = ref.watch(appPrefsProvider).salahActivityColours;
            return ProgressDayCell(
              onTap: matrixCellOnTap(
                ref: ref,
                context: context,
                dateKey: key,
                onOpen: () => _openDay(
                  context,
                  key,
                  band: row.band,
                  rowId: row.storageKey,
                ),
              ),
              marker: SalahActivityMark.recordedMarkerForTrace(
                row: row,
                record: record,
                activityColours: colours,
                semanticLabel:
                    '$key ${weekdayNameForDate(key)} ${row.label} ${outcome.legendLabel}',
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _zakatCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, DailyCheckIn> index,
    ReviewPeriod period,
    DateTime now,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WashPanel(
        color: Color.alphaBlend(
          family.withValues(alpha: 0.16),
          Theme.of(context).colorScheme.surface,
        ),
        child: ProgressCalendarSection(
          title: 'Zakat',
          periodDays: period.days,
          family: family,
          cellBuilder: (context, key) {
            final status = index[key]?.zakat ?? ZakatStatus.unanswered;
            return ProgressDayCell(
              onTap: matrixCellOnTap(
                ref: ref,
                context: context,
                dateKey: key,
                onOpen: () => _openDay(
                  context,
                  key,
                  band: kZakatTraceBand,
                  rowId: 'zakat',
                ),
              ),
              marker: ZakatStateMarker(status: status),
            );
          },
        ),
      ),
    );
  }
}
