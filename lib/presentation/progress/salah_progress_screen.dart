import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/analytics.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/personal_response.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/quran_stage.dart';
import '../../domain/review_period.dart';
import '../../domain/salah_extras.dart';
import '../checkin/check_in_screen.dart';
import '../checkin/trace_record_sheets.dart';
import '../home/quran_day_sheet.dart';
import '../progress/week_trace_matrix.dart';
import '../shared/add_response_button.dart';
import '../shared/progress_calendar.dart';
import '../shared/quran_stage_mark.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';
import '../shared/ui_bits.dart';

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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (MonitorDomain.salah.focusQuestion != null) ...[
                Text(
                  MonitorDomain.salah.focusQuestion!,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontStyle: FontStyle.italic, height: 1.35),
                ),
                const SizedBox(height: 8),
              ],
              PeriodSelector(
                days: period.days,
                onChanged: (days) {
                  ref
                      .read(reviewPeriodProvider.notifier)
                      .state = switch (days) {
                    30 => ReviewPeriod.days30,
                    90 => ReviewPeriod.days90,
                    _ => ReviewPeriod.days7,
                  };
                },
              ),
              const SizedBox(height: 8),
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
                    const _Legend(kind: MarkerKind.filled, label: 'Prayed on time'),
                    const _Legend(kind: MarkerKind.outlined, label: 'Late'),
                    const _Legend(kind: MarkerKind.missed, label: 'Missed'),
                    const _Legend(
                      kind: MarkerKind.unanswered,
                      label: 'Not recorded',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (period.days == 7)
                ..._salahWeekMatrices(context, ref, now, index)
              else ...[
                for (final prayer in PrayerId.values)
                  _prayerBlock(context, ref, now, prayer, index, period),
                for (final row in const [
                  SalahTraceRow.jumuah,
                  SalahTraceRow.tahajjud,
                  SalahTraceRow.ishraq,
                ])
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
  ) {
    final brightness = Theme.of(context).brightness;
    return [
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
          for (final prayer in PrayerId.values)
            WeekMatrixColumn(
              header: prayer.label,
              cell: (context, key) => _dayMarker(
                context,
                ref,
                now,
                prayer,
                key,
                index[key],
              ),
            ),
        ],
      ),
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
          for (final row in const [
            SalahTraceRow.tahajjud,
            SalahTraceRow.ishraq,
          ])
            WeekMatrixColumn(
              header: row.label,
              cell: (context, key) => _extraMarker(
                context,
                ref,
                now,
                row,
                key,
                index[key],
              ),
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
          subtitle: salahHomeBand(row),
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
        dateKey: key,
        now: now,
        onOpen: () => openFocusedCheckIn(
          context,
          dateKey: key,
          focus: CheckInFocus.salah,
          focusBand: kSalahObligatoryBand,
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
      final outcome = row == SalahTraceRow.tahajjud
          ? (record?.tahajjud ?? TernaryOutcome.unanswered)
          : (record?.ishraq ?? TernaryOutcome.unanswered);
      kind = markerForRecorded(
        recorded: outcome.isRecorded,
        positive: outcome == TernaryOutcome.positive,
      );
      color = MuhasabahColors.mark;
      stateLabel = voluntarySalahLabel(outcome);
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
        dateKey: key,
        now: now,
        onOpen: () => openFocusedCheckIn(
          context,
          dateKey: key,
          focus: CheckInFocus.salah,
          focusBand: salahHomeBand(row),
        ),
      ),
      marker: RecordedStateMarker(
        kind: kind,
        color: color,
        semanticLabel: '$key ${weekdayNameForDate(key)} ${row.label} $stateLabel',
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
          final calendar = ref.watch(appPrefsProvider).displayCalendar;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (MonitorDomain.quran.focusQuestion != null) ...[
                Text(
                  MonitorDomain.quran.focusQuestion!,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontStyle: FontStyle.italic, height: 1.35),
                ),
                const SizedBox(height: 8),
              ],
              PeriodSelector(
                days: period.days,
                onChanged: (days) {
                  ref
                      .read(reviewPeriodProvider.notifier)
                      .state = switch (days) {
                    30 => ReviewPeriod.days30,
                    90 => ReviewPeriod.days90,
                    _ => ReviewPeriod.days7,
                  };
                },
              ),
              const SizedBox(height: 12),
              Text('PONDER', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                Copy.ponderPrompt,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              AddResponseButton(
                provenance: ResponseProvenance(
                  originType: ProvenanceOrigin.quranPonder,
                  domain: 'quran',
                  periodDays: period.days,
                  labelSnapshot: 'Qur’an PONDER (${period.shortLabel})',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                period.days == 7
                    ? 'Rows are independent Journey groups; columns are weekdays. The card wash identifies the domain, not rank. Marks share one colour. The letter is the recorded activity.'
                    : 'Titles match the Home Journey groups. Each calendar is still one stored row. Rows are weekdays; columns are weeks. The card wash identifies the row, not rank. Marks share one colour.',
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
              const SizedBox(height: 16),
              if (period.days == 7)
                _quranJourneyMatrix(context, now, calendar, colours, index)
              else
                for (final dimension in quranDailyDimensions)
                  _dimensionCard(context, dimension, keys, index, period, now),
            ],
          );
        },
      ),
    );
  }

  Widget _quranJourneyMatrix(
    BuildContext context,
    DateTime now,
    DisplayCalendar calendar,
    bool colours,
    Map<String, DailyCheckIn> index,
  ) {
    final brightness = Theme.of(context).brightness;
    return WeekMatrixBoard(
      title: Copy.quranJourney,
      family: MuhasabahColors.quranFamily,
      itemAsRows: true,
      wash: MuhasabahColors.wash(
        MuhasabahColors.quranRecitationBand,
        MuhasabahColors.quranRecitationBandDark,
        brightness,
      ),
      columns: [
        for (final row in QuranJourneyRow.values)
          WeekMatrixColumn(
            header: row.label,
            subtitle: row.purpose,
            cell: (context, key) {
              final record = index[key];
              final cell = quranJourneyCell(record, row);
              return ProgressDayCell(
                key: Key('progress-cell-quran-${row.name}-$key'),
                onTap: matrixCellOnTap(
                  dateKey: key,
                  now: now,
                  onOpen: () => showQuranJourneySheet(
                    context: context,
                    dateKey: key,
                    calendar: calendar,
                    row: row,
                    record: record,
                  ),
                ),
                marker: QuranJourneyMarker(
                  row: row,
                  cell: cell,
                  colours: colours,
                  semanticLabel:
                      '$key ${weekdayNameForDate(key)} ${row.label} ${cell.code ?? cell.kind.name}',
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _dimensionCard(
    BuildContext context,
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
              title: dimension.progressCalendarTitle,
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
                final kind = markerForRecorded(
                  recorded: outcome.isRecorded,
                  positive: outcome == TernaryOutcome.positive,
                );
                return ProgressDayCell(
                  onTap: matrixCellOnTap(
                    dateKey: key,
                    now: now,
                    onOpen: () => openFocusedCheckIn(
                      context,
                      dateKey: key,
                      focus: CheckInFocus.quran,
                      focusBand: dimension.homeBand,
                    ),
                  ),
                  marker: RecordedStateMarker(
                    kind: kind,
                    symbol: outcome == TernaryOutcome.negative
                        ? Icons.remove
                        : null,
                    semanticLabel:
                        '$key ${weekdayNameForDate(key)} ${dimension.label} ${outcome.legendLabel}',
                  ),
                );
              },
            ),
            AddResponseButton(
              compact: true,
              provenance: ResponseProvenance(
                originType: ProvenanceOrigin.progressDimension,
                domain: 'quran',
                subject: dimension.name,
                periodDays: period.days,
                labelSnapshot: '${dimension.label} (${period.shortLabel})',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
