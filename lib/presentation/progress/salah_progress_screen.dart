import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/analytics.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/personal_response.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/review_period.dart';
import '../recorded_days/day_evidence_screen.dart';
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
      appBar: AppBar(title: const Text('Salah Progress')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: 'Salah Progress',
          message: 'Could not load traces.',
        ),
        data: (records) {
          final keys = periodDateKeys(period.days, now: now);
          final index = indexByDate(records);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                'Colour identifies the prayer, not spiritual rank. Shape encodes the recorded state. Rows are weekdays; columns are weeks.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: const [
                  _Legend(kind: MarkerKind.filled, label: 'Prayed on time'),
                  _Legend(
                    kind: MarkerKind.outlined,
                    label: 'Late',
                    icon: Icons.schedule,
                  ),
                  _Legend(
                    kind: MarkerKind.outlined,
                    label: 'Missed',
                    icon: Icons.close,
                  ),
                  _Legend(kind: MarkerKind.unanswered, label: 'Not recorded'),
                ],
              ),
              const SizedBox(height: 16),
              for (final prayer in PrayerId.values)
                _prayerBlock(context, prayer, keys, index, period),
            ],
          );
        },
      ),
    );
  }

  Widget _prayerBlock(
    BuildContext context,
    PrayerId prayer,
    List<String> keys,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prayer.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ProgressCalendarSection(
              dateKeys: keys,
              periodDays: period.days,
              cellBuilder: (context, key) =>
                  _dayMarker(context, prayer, key, index[key]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayMarker(
    BuildContext context,
    PrayerId prayer,
    String key,
    DailyCheckIn? record,
  ) {
    final status = record == null
        ? PrayerStatus.unanswered
        : record.prayer(prayer);
    final kind = switch (status) {
      PrayerStatus.onTime => MarkerKind.filled,
      PrayerStatus.late || PrayerStatus.missed => MarkerKind.outlined,
      PrayerStatus.unanswered => MarkerKind.unanswered,
    };
    final icon = status == PrayerStatus.missed
        ? Icons.close
        : status == PrayerStatus.late
        ? Icons.schedule
        : null;
    return ProgressDayCell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => DayEvidenceScreen(dateKey: key),
          ),
        );
      },
      marker: RecordedStateMarker(
        color: MuhasabahColors.prayer(prayer),
        kind: kind,
        symbol: icon,
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
        RecordedStateMarker(
          color: Theme.of(context).colorScheme.primary,
          kind: kind,
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
      appBar: AppBar(title: const Text('Qur’an Progress')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: 'Qur’an Progress',
          message: 'Could not load traces.',
        ),
        data: (records) {
          final keys = periodDateKeys(period.days, now: now);
          final index = indexByDate(records);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                'Rows are weekdays; columns are weeks. Colour identifies the dimension, not rank.',
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
              for (final dimension in quranDailyDimensions)
                _dimensionCard(context, dimension, keys, index, period),
            ],
          );
        },
      ),
    );
  }

  Widget _dimensionCard(
    BuildContext context,
    QuranDimension dimension,
    List<String> keys,
    Map<String, DailyCheckIn> index,
    ReviewPeriod period,
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
            Text(
              dimension.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (dimension.isNeutralPeerDimension)
              Text(
                'Recorded on $recordedDays of ${keys.length} days · activity days $positiveDays · recorded as not done $negativeDays',
              ),
            if (dimension.isApplicationReflection)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  Copy.applicationReflectionNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            ProgressCalendarSection(
              dateKeys: keys,
              periodDays: period.days,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => DayEvidenceScreen(dateKey: key),
                      ),
                    );
                  },
                  marker: RecordedStateMarker(
                    color: MuhasabahColors.quran(dimension),
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
