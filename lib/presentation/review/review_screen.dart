import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/analytics.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/other_domains.dart';
import '../../domain/personal_response.dart';
import '../../domain/review_period.dart';
import '../home/dashboard_cards.dart';
import '../progress/salah_progress_screen.dart';
import '../recognition/recognition_screen.dart';
import '../recorded_days/recorded_days_screen.dart';
import '../shared/add_response_button.dart';
import '../shared/ui_bits.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  static const routeName = '/review';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reviewPeriodProvider);
    final now = ref.watch(nowProvider);
    final async = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.reviewTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: Copy.reviewTitle,
          message: 'Period summary could not be built from stored records.',
        ),
        data: (records) {
          final keys = periodDateKeys(period.days, now: now);
          final index = indexByDate(records);
          var daysRecorded = 0;
          for (final key in keys) {
            if (index.containsKey(key)) daysRecorded++;
          }
          final inPeriod = recordsForKeys(index, keys);
          final salah = salahShare(inPeriod, null);
          final reading = readingShare(inPeriod);
          var dhikrDays = 0;
          var conductDays = 0;
          var gratitudeEntries = 0;
          var reflectionEntries = 0;
          for (final record in inPeriod) {
            if (record.dhikr.isRecorded) dhikrDays++;
            if (record.conduct.isRecorded) conductDays++;
            if (record.gratitudeStatus.hasTextEntry) gratitudeEntries++;
            if (record.personalReflectionStatus.hasTextEntry) {
              reflectionEntries++;
            }
          }
          final priorKeys = priorPeriodDateKeys(period.days, now: now);
          final priorSalah = salahShare(recordsForKeys(index, priorKeys), null);
          final narrative = period == ReviewPeriod.days90
              ? classify90DaySalahOrReading(
                  index: index,
                  now: now,
                  shareOf: (items) => salahShare(items, null),
                )
              : directionFromShares(
                  period: period,
                  current: salah,
                  prior: priorSalah,
                );
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
              const SizedBox(height: 16),
              Text(
                'Period summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'A private place to understand what you previously recorded. This screen does not change records or prescribe what to do next.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              DashboardNavCard(
                title: 'Salah Progress',
                body: 'Independent prayer traces for ${period.shortLabel}',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SalahProgressScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DashboardNavCard(
                title: 'Qur’an Progress',
                body: 'Independent Qur’an dimensions for this period',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const QuranProgressScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DashboardNavCard(
                title: Copy.recordedDaysTitle,
                body: Copy.historicalReflectionTitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const RecordedDaysScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DashboardNavCard(
                title: 'Recognition',
                body: 'Descriptive context patterns in 30- and 90-day views',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const RecognitionScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _fact(
                    context,
                    Copy.recordedDays,
                    '$daysRecorded of ${period.days}',
                  ),
                  _fact(
                    context,
                    Copy.missingDays,
                    '${period.days - daysRecorded} of ${period.days}',
                  ),
                  _fact(
                    context,
                    'Salah recorded observations',
                    '${salah.desirable} on time among ${salah.recorded} recorded (missing excluded)',
                  ),
                  _fact(
                    context,
                    'Qur’an reading/listening',
                    '${reading.desirable} read-or-listened among ${reading.recorded} recorded',
                  ),
                  _fact(context, 'Dhikr observations', '$dhikrDays days'),
                  _fact(context, 'Character observations', '$conductDays days'),
                  _fact(context, 'Gratitude entries', '$gratitudeEntries'),
                  _fact(
                    context,
                    'Personal-reflection entries',
                    '$reflectionEntries',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _situationNotesInPeriod(context, inPeriod),
              const SizedBox(height: 8),
              Text(
                narrativeCopy(narrative),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              AddResponseButton(
                provenance: ResponseProvenance(
                  originType: ProvenanceOrigin.periodSummary,
                  periodDays: period.days,
                  labelSnapshot: 'Period summary (${period.shortLabel})',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _situationNotesInPeriod(
    BuildContext context,
    List<DailyCheckIn> inPeriod,
  ) {
    final labels = <String>{};
    for (final record in inPeriod) {
      labels.addAll(record.situationNotes.displayLabels);
    }
    if (labels.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Copy.situationNotesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              Copy.situationNotesNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            const Text(Copy.youRecordedColon),
            for (final label in labels)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $label'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fact(BuildContext context, String label, String value) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      width: 160,
      child: WashPanel(
        color: MuhasabahColors.wash(
          MuhasabahColors.summaryWash,
          MuhasabahColors.summaryWashDark,
          brightness,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
