import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/analytics.dart';
import '../../domain/copy.dart';
import '../../domain/home_traces.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/date_key.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/quran_stage.dart';
import '../../domain/review_period.dart';
import '../../domain/salah_extras.dart';
import '../checkin/check_in_screen.dart';
import '../checkin/trace_record_sheets.dart';
import '../progress/week_trace_matrix.dart';
import '../shared/progress_calendar.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';
import '../shared/ui_bits.dart';
import 'progress_review_frame.dart';

class SalahProgressScreen extends ConsumerWidget {
  const SalahProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reviewPeriodProvider);
    final now = ref.watch(nowProvider);
    final async = ref.watch(checkInsProvider);
    ref.watch(prefsTickProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${MonitorDomain.salah.label} Progress')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          title: '${MonitorDomain.salah.label} Progress',
          message: 'Could not load traces.',
        ),
        data: (records) {
          final index = indexByDate(records);
          final colours = ref.watch(appPrefsProvider).salahActivityColours;
          final prefs = ref.watch(appPrefsProvider);
          final resolver = PersonalisationResolver(
            visibleDomains: prefs.visibleDomains,
            mix: prefs.personalMix,
          );
          bool allows(String id) => resolver.mixFocusAllows(id);
          final obligatory = [
            for (final prayer in PrayerId.values)
              if (allows('salah.${prayer.name}')) prayer,
          ];
          final extras = [
            for (final row in const [
              SalahTraceRow.jumuah,
              SalahTraceRow.tahajjud,
              SalahTraceRow.ishraq,
            ])
              if (allows('salah.${row.name}')) row,
          ];
          return ProgressReviewFrame(
            focusQuestion: MonitorDomain.salah.focusQuestion,
            days: period.days,
            onPeriodChanged: (days) {
              ref.read(reviewPeriodProvider.notifier).state = switch (days) {
                30 => ReviewPeriod.days30,
                90 => ReviewPeriod.days90,
                _ => ReviewPeriod.days7,
              };
            },
            marks: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  colours
                      ? Copy.salahMarkActivityNote
                      : period.days == 7
                      ? 'The card wash identifies the band, not spiritual rank. Marks share one colour. Shape encodes the recorded state. Rows are prayers; columns are weekdays.'
                      : 'The card wash identifies the prayer, not spiritual rank. Marks share one colour. Shape encodes the recorded state. Jumu‘ah is Friday-only; other days are blank, not unanswered.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (colours)
                      for (final option in ActivityCatalog.salah)
                        _Legend(
                          kind: MarkerKind.filled,
                          color: SalahActivityMark.colourForId(option.id),
                          label: option.label,
                        )
                    else ...[
                      const _Legend(
                        kind: MarkerKind.filled,
                        label: 'Prayed on time',
                      ),
                      const _Legend(kind: MarkerKind.outlined, label: 'Late'),
                      const _Legend(kind: MarkerKind.missed, label: 'Missed'),
                      const _Legend(
                        kind: MarkerKind.unanswered,
                        label: 'Not recorded',
                      ),
                    ],
                  ],
                ),
              ],
            ),
            children: [
              if (period.days == 7)
                ..._salahWeekMatrices(context, ref, now, index, allows)
              else ...[
                for (final prayer in obligatory)
                  _prayerBlock(context, ref, now, prayer, index, period),
                for (final row in extras)
                  _extraBlock(context, ref, now, row, index, period),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _salahWeekMatrices(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    Map<String, DailyCheckIn> index,
    bool Function(String id) allows,
  ) {
    final brightness = Theme.of(context).brightness;
    final obligatory = [
      for (final prayer in PrayerId.values)
        if (allows('salah.${prayer.name}')) prayer,
    ];
    final showJumuah = allows('salah.jumuah');
    final voluntary = [
      for (final row in const [SalahTraceRow.tahajjud, SalahTraceRow.ishraq])
        if (allows('salah.${row.name}')) row,
    ];
    return [
      if (obligatory.isNotEmpty)
        WeekMatrixBoard(
          title: kSalahObligatoryBand,
          family: MuhasabahColors.salahFamily,
          itemAsRows: true,
          wash: MuhasabahColors.wash(
            MuhasabahColors.salahObligatoryBand,
            MuhasabahColors.salahObligatoryBandDark,
            brightness,
          ),
          columns: [
            for (final prayer in obligatory)
              WeekMatrixColumn(
                header: prayer.label,
                cell: (context, key) =>
                    _dayMarker(context, ref, now, prayer, key, index[key]),
              ),
          ],
        ),
      if (showJumuah)
        WeekMatrixBoard(
          title: kSalahFridayBand,
          family: MuhasabahColors.salahFamily,
          itemAsRows: true,
          wash: MuhasabahColors.wash(
            MuhasabahColors.salahFridayBand,
            MuhasabahColors.salahFridayBandDark,
            brightness,
          ),
          columns: [
            WeekMatrixColumn(
              header: SalahTraceRow.jumuah.label,
              cell: (context, key) => _extraMarker(
                context,
                ref,
                now,
                SalahTraceRow.jumuah,
                key,
                index[key],
              ),
            ),
          ],
        ),
      if (voluntary.isNotEmpty)
        WeekMatrixBoard(
          title: kSalahVoluntaryBand,
          family: MuhasabahColors.salahFamily,
          itemAsRows: true,
          wash: MuhasabahColors.wash(
            MuhasabahColors.salahVoluntaryBand,
            MuhasabahColors.salahVoluntaryBandDark,
            brightness,
          ),
          columns: [
            for (final row in voluntary)
              WeekMatrixColumn(
                header: row.label,
                cell: (context, key) =>
                    _extraMarker(context, ref, now, row, key, index[key]),
              ),
          ],
        ),
    ];
  }

  Widget _prayerBlock(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    PrayerId prayer,
    Map<String, DailyCheckIn> index,
    ReviewPeriod period,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: WashPanel(
        color: Color.alphaBlend(
          MuhasabahColors.prayer(prayer).withValues(alpha: 0.16),
          Theme.of(context).colorScheme.surface,
        ),
        child: ProgressCalendarSection(
          title: prayer.label,
          periodDays: period.days,
          family: MuhasabahColors.prayer(prayer),
          cellBuilder: (context, key) =>
              _dayMarker(context, ref, now, prayer, key, index[key]),
        ),
      ),
    );
  }

  Widget _extraBlock(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    SalahTraceRow row,
    Map<String, DailyCheckIn> index,
    ReviewPeriod period,
  ) {
    final brightness = Theme.of(context).brightness;
    final wash = row.isFridayPrayer
        ? MuhasabahColors.wash(
            MuhasabahColors.salahFridayBand,
            MuhasabahColors.salahFridayBandDark,
            brightness,
          )
        : MuhasabahColors.wash(
            MuhasabahColors.salahVoluntaryBand,
            MuhasabahColors.salahVoluntaryBandDark,
            brightness,
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: WashPanel(
        color: wash,
        child: ProgressCalendarSection(
          title: row.label,
          subtitle: displayHomeBand(salahHomeBand(row)),
          periodDays: period.days,
          family: MuhasabahColors.salahFamily,
          cellBuilder: (context, key) =>
              _extraMarker(context, ref, now, row, key, index[key]),
        ),
      ),
    );
  }

  Widget _dayMarker(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    PrayerId prayer,
    String key,
    DailyCheckIn? record,
  ) {
    final colours = ref.watch(appPrefsProvider).salahActivityColours;
    final mark = SalahActivityMark.forPrayer(
      record: record,
      prayer: prayer,
      activityColours: colours,
    );
    return ProgressDayCell(
      key: Key('progress-cell-salah-${prayer.name}-$key'),
      onTap: matrixCellOnTap(
        ref: ref,
        context: context,
        dateKey: key,
        onOpen: () => openFocusedCheckIn(
          context,
          dateKey: key,
          focus: CheckInFocus.salah,
          focusBand: kSalahObligatoryBand,
          focusRowId: 'salah.${prayer.name}',
        ),
      ),
      marker: RecordedStateMarker(
        kind: mark.kind,
        color: mark.color,
        semanticLabel:
            '$key ${weekdayNameForDate(key)} ${prayer.label} ${mark.label}',
      ),
    );
  }

  Widget _extraMarker(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    SalahTraceRow row,
    String key,
    DailyCheckIn? record,
  ) {
    if (row.fridayOnly && !isFridayDateKey(key)) {
      return SizedBox(
        key: Key('progress-cell-salah-${row.id}-$key'),
        width: AppDimensions.progressMarker,
        height: AppDimensions.progressMarker,
      );
    }
    final colours = ref.watch(appPrefsProvider).salahActivityColours;
    late final MarkerKind kind;
    late final Color color;
    late final String stateLabel;
    if (row.isVoluntary) {
      final mark = SalahActivityMark.forVoluntary(
        record: record,
        row: row,
        activityColours: colours,
      );
      kind = mark.kind;
      color = mark.color;
      stateLabel = mark.label;
    } else {
      final mark = SalahActivityMark.forJumuah(
        record: record,
        activityColours: colours,
      );
      kind = mark.kind;
      color = mark.color;
      stateLabel = mark.label;
    }
    return ProgressDayCell(
      key: Key('progress-cell-salah-${row.id}-$key'),
      onTap: matrixCellOnTap(
        ref: ref,
        context: context,
        dateKey: key,
        onOpen: () => openFocusedCheckIn(
          context,
          dateKey: key,
          focus: CheckInFocus.salah,
          focusBand: salahHomeBand(row),
          focusRowId: 'salah.${row.id}',
        ),
      ),
      marker: RecordedStateMarker(
        kind: kind,
        color: color,
        semanticLabel:
            '$key ${weekdayNameForDate(key)} ${row.label} $stateLabel',
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.kind,
    required this.label,
    this.icon,
    this.color,
  });

  final MarkerKind kind;
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RecordedStateMarker(
          kind: kind,
          color: color ?? MuhasabahColors.mark,
          symbol: icon,
          semanticLabel: label,
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class QuranProgressScreen extends ConsumerWidget {
  const QuranProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reviewPeriodProvider);
    final now = ref.watch(nowProvider);
    final async = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${MonitorDomain.quran.label} Progress')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          title: '${MonitorDomain.quran.label} Progress',
          message: 'Could not load traces.',
        ),
        data: (records) {
          final keys = periodDateKeys(period.days, now: now);
          final index = indexByDate(records);
          ref.watch(prefsTickProvider);
          final colours = ref.watch(appPrefsProvider).salahActivityColours;
          final prefs = ref.watch(appPrefsProvider);
          final resolver = PersonalisationResolver(
            visibleDomains: prefs.visibleDomains,
            mix: prefs.personalMix,
          );
          final dimensions = [
            for (final dimension in quranDailyDimensions)
              if (resolver.mixFocusAllows('quran.${dimension.name}')) dimension,
          ];
          return ProgressReviewFrame(
            focusQuestion: MonitorDomain.quran.focusQuestion,
            days: period.days,
            onPeriodChanged: (days) {
              ref.read(reviewPeriodProvider.notifier).state = switch (days) {
                30 => ReviewPeriod.days30,
                90 => ReviewPeriod.days90,
                _ => ReviewPeriod.days7,
              };
            },
            marks: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.days == 7
                      ? 'Each row is a stored Qur’an activity in this season’s mix. Columns are weekdays. Tap a cell to open that row’s check-in. Marks share one colour.'
                      : 'Each calendar is one stored row. Titles name the check-in band. Rows are weekdays; columns are weeks. The card wash identifies the row, not rank. Marks share one colour.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _Legend(
                      kind: MarkerKind.filled,
                      label: period.days == 7
                          ? 'Recorded'
                          : TernaryOutcome.positive.legendLabel,
                    ),
                    _Legend(
                      kind: MarkerKind.outlined,
                      label: period.days == 7
                          ? 'None'
                          : TernaryOutcome.negative.legendLabel,
                      icon: period.days == 7 ? null : Icons.remove,
                    ),
                    _Legend(
                      kind: MarkerKind.unanswered,
                      label: TernaryOutcome.unanswered.legendLabel,
                    ),
                  ],
                ),
              ],
            ),
            children: [
              if (period.days == 7)
                ..._quranWeekMatrices(context, ref, colours, index, dimensions)
              else
                for (final dimension in dimensions)
                  _dimensionCard(
                    context,
                    ref,
                    dimension,
                    keys,
                    index,
                    period,
                    now,
                  ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _quranWeekMatrices(
    BuildContext context,
    WidgetRef ref,
    bool colours,
    Map<String, DailyCheckIn> index,
    List<QuranDimension> dimensions,
  ) {
    final bands = quranHomeBandsFor(dimensions);
    if (bands.isEmpty) return const [];
    final brightness = Theme.of(context).brightness;
    return [
      for (final entry in bands)
        WeekMatrixBoard(
          title: entry.$1,
          family: MuhasabahColors.quranFamily,
          itemAsRows: true,
          wash: MuhasabahColors.wash(
            MuhasabahColors.quranWash,
            MuhasabahColors.quranWashDark,
            brightness,
          ),
          columns: [
            for (final dimension in entry.$2)
              WeekMatrixColumn(
                header: dimension.label,
                cell: (context, key) {
                  final record = index[key];
                  final outcome = record == null
                      ? TernaryOutcome.unanswered
                      : record.quranOutcome(dimension);
                  final id =
                      record?.activityFor(
                        ActivityCatalog.quranKey(dimension),
                      ).id ??
                      ActivityIds.unanswered;
                  return ProgressDayCell(
                    key: Key(
                      'progress-cell-quran-${dimension.name}-$key',
                    ),
                    onTap: matrixCellOnTap(
                      ref: ref,
                      context: context,
                      dateKey: key,
                      onOpen: () => openFocusedCheckIn(
                        context,
                        dateKey: key,
                        focus: CheckInFocus.quran,
                        focusBand: dimension.homeBand,
                        focusRowId: 'quran.${dimension.name}',
                      ),
                    ),
                    marker: RecordedStateMarker(
                      kind: SalahActivityMark.quranDurationKind(
                        id,
                        activityColours: colours,
                      ),
                      color: SalahActivityMark.quranDurationColour(
                        id,
                        colours: colours,
                      ),
                      semanticLabel:
                          '$key ${weekdayNameForDate(key)} ${dimension.label} ${outcome.legendLabel}',
                    ),
                  );
                },
              ),
          ],
        ),
    ];
  }

  Widget _dimensionCard(
    BuildContext context,
    WidgetRef ref,
    QuranDimension dimension,
    List<String> keys,
    Map<String, DailyCheckIn> index,
    ReviewPeriod period,
    DateTime now,
  ) {
    var recordedDays = 0;
    var positiveDays = 0;
    var negativeDays = 0;
    for (final key in keys) {
      final record = index[key];
      if (record == null) continue;
      final outcome = record.quranOutcome(dimension);
      if (!outcome.isRecorded) continue;
      recordedDays++;
      if (outcome == TernaryOutcome.positive) positiveDays++;
      if (outcome == TernaryOutcome.negative) negativeDays++;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WashPanel(
        color: Color.alphaBlend(
          MuhasabahColors.quran(dimension).withValues(alpha: 0.16),
          Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressCalendarSection(
              sectionId: dimension.name,
              title: displayHomeBand(dimension.progressCalendarTitle),
              subtitle: dimension.progressCalendarSubtitle,
              periodDays: period.days,
              family: MuhasabahColors.quran(dimension),
              belowTitle: dimension.isNeutralPeerDimension
                  ? Text(
                      'Recorded on $recordedDays of ${keys.length} days · activity days $positiveDays · recorded as not done $negativeDays',
                    )
                  : dimension == QuranDimension.consciousApplication
                  ? Text(
                      Copy.consciousApplicationNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : null,
              cellBuilder: (context, key) {
                final record = index[key];
                final outcome = record == null
                    ? TernaryOutcome.unanswered
                    : record.quranOutcome(dimension);
                final colours =
                    ref.watch(appPrefsProvider).salahActivityColours;
                final id =
                    record?.activityFor(
                      ActivityCatalog.quranKey(dimension),
                    ).id ??
                    ActivityIds.unanswered;
                return ProgressDayCell(
                  onTap: matrixCellOnTap(
                    ref: ref,
                    context: context,
                    dateKey: key,
                    onOpen: () => openFocusedCheckIn(
                      context,
                      dateKey: key,
                      focus: CheckInFocus.quran,
                      focusBand: dimension.homeBand,
                      focusRowId: 'quran.${dimension.name}',
                    ),
                  ),
                  marker: RecordedStateMarker(
                    kind: SalahActivityMark.quranDurationKind(
                      id,
                      activityColours: colours,
                    ),
                    color: SalahActivityMark.quranDurationColour(
                      id,
                      colours: colours,
                    ),
                    semanticLabel:
                        '$key ${weekdayNameForDate(key)} ${dimension.label} ${outcome.legendLabel}',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
