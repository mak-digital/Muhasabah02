import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/analytics.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/date_key.dart';
import '../../domain/personal_response.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/review_period.dart';
import '../../domain/salah_extras.dart';
import '../progress/week_trace_matrix.dart';
import '../checkin/check_in_screen.dart';
import '../checkin/trace_record_sheets.dart';
import '../shared/add_response_button.dart';
import '../shared/progress_calendar.dart';
import '../shared/state_marker.dart';
import '../shared/ui_bits.dart';

class SalahProgressScreen extends ConsumerWidget {
  const SalahProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reviewPeriodProvider);
    final now = ref.watch(nowProvider);
    final async = ref.watch(checkInsProvider);
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
                'The card wash identifies the prayer, not spiritual rank. Marks share one colour. Shape encodes the recorded state. Rows are weekdays; columns are weeks.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: const [
                  _Legend(kind: MarkerKind.filled, label: 'Prayed on time'),
                  _Legend(kind: MarkerKind.outlined, label: 'Late'),
                  _Legend(kind: MarkerKind.missed, label: 'Missed'),
                  _Legend(kind: MarkerKind.unanswered, label: 'Not recorded'),
                ],
              ),
              const SizedBox(height: 16),
              if (period.days == 7)
                WeekMatrixBoard(
                  title: 'Obligatory Salah',
                  family: MuhasabahColors.salahFamily,
                  columns: [
                    for (final prayer in PrayerId.values)
                      WeekMatrixColumn(
                        header: switch (prayer) {
                          PrayerId.fajr => 'Faj',
                          PrayerId.dhuhr => 'Dhr',
                          PrayerId.asr => 'Asr',
                          PrayerId.maghrib => 'Mag',
                          PrayerId.isha => 'Isa',
                        },
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
                )
              else
                for (final prayer in PrayerId.values)
                  _prayerBlock(context, ref, now, prayer, index, period),
            ],
          );
        },
      ),
    );
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

  Widget _dayMarker(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    PrayerId prayer,
    String key,
    DailyCheckIn? record,
  ) {
    final status = record == null
        ? PrayerStatus.unanswered
        : record.prayer(prayer);
    final kind = switch (status) {
      PrayerStatus.onTime => MarkerKind.filled,
      PrayerStatus.late => MarkerKind.outlined,
      PrayerStatus.missed => MarkerKind.missed,
      PrayerStatus.unanswered => MarkerKind.unanswered,
    };
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
        kind: kind,
        semanticLabel:
            '$key ${weekdayNameForDate(key)} ${prayer.label} ${status.label}',
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.kind, required this.label, this.icon});

  final MarkerKind kind;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RecordedStateMarker(kind: kind, symbol: icon, semanticLabel: label),
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
                'Rows are weekdays; columns are weeks. The card wash identifies the dimension, not rank. Marks share one colour.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _Legend(
                    kind: MarkerKind.filled,
                    label: TernaryOutcome.positive.legendLabel,
                  ),
                  _Legend(
                    kind: MarkerKind.outlined,
                    label: TernaryOutcome.negative.legendLabel,
                    icon: Icons.remove,
                  ),
                  _Legend(
                    kind: MarkerKind.unanswered,
                    label: TernaryOutcome.unanswered.legendLabel,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (period.days == 7) ...[
                _quranWeekMatrix(
                  context,
                  ref,
                  now,
                  'Recitation',
                  recitationHomeRows,
                  index,
                ),
                _quranWeekMatrix(
                  context,
                  ref,
                  now,
                  'Retention',
                  retentionHomeRows,
                  index,
                ),
                _quranWeekMatrix(
                  context,
                  ref,
                  now,
                  'Study & notice',
                  studyNoticeHomeRows,
                  index,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    Copy.consciousApplicationNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ] else
                for (final dimension in quranDailyDimensions)
                  _dimensionCard(context, dimension, keys, index, period, now),
            ],
          );
        },
      ),
    );
  }

  Widget _quranWeekMatrix(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    String title,
    List<QuranDimension> dimensions,
    Map<String, DailyCheckIn> index,
  ) {
    return WeekMatrixBoard(
      title: title,
      family: MuhasabahColors.quranFamily,
      columns: [
        for (final dimension in dimensions)
          WeekMatrixColumn(
            header: dimension.matrixColumn,
            verticalHeader: dimension.matrixColumnVertical,
            cell: (context, key) {
              final record = index[key];
              final outcome = record == null
                  ? TernaryOutcome.unanswered
                  : record.quranOutcome(dimension);
              return ProgressDayCell(
                key: Key('progress-cell-quran-${dimension.name}-$key'),
                onTap: matrixCellOnTap(
                  dateKey: key,
                  now: now,
                  onOpen: () => openFocusedCheckIn(
                    context,
                    dateKey: key,
                    focus: CheckInFocus.quran,
                    focusBand: title,
                  ),
                ),
                marker: RecordedStateMarker(
                  kind: markerForRecorded(
                    recorded: outcome.isRecorded,
                    positive: outcome == TernaryOutcome.positive,
                  ),
                  symbol: outcome == TernaryOutcome.negative
                      ? Icons.remove
                      : null,
                  semanticLabel:
                      '$key ${weekdayNameForDate(key)} ${dimension.label} ${outcome.legendLabel}',
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
              title: dimension.label,
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
