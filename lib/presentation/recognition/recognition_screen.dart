import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/date_key.dart';
import '../../domain/personal_response.dart';
import '../../domain/quran.dart';
import '../../domain/recognition.dart';
import '../../domain/review_period.dart';
import '../recorded_days/day_evidence_screen.dart';
import '../shared/add_response_button.dart';
import '../shared/ui_bits.dart';

class RecognitionScreen extends ConsumerWidget {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reviewPeriodProvider);
    final now = ref.watch(nowProvider);
    final async = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recognition')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: 'Recognition',
          message: 'Patterns could not be computed.',
        ),
        data: (records) {
          if (period == ReviewPeriod.days7) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PeriodSelector(
                  days: period.days,
                  onChanged: (days) {
                    ref.read(reviewPeriodProvider.notifier).state = days == 90
                        ? ReviewPeriod.days90
                        : ReviewPeriod.days30;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recognition is available for 30-day and 90-day views. It describes recorded context; it does not explain causes.',
                ),
              ],
            );
          }
          final keys = periodDateKeys(period.days, now: now);
          final inPeriod = [
            for (final record in records)
              if (keys.contains(record.dateKey)) record,
          ];
          final patterns = const RecognitionEngine().detect(
            records: inPeriod,
            period: period,
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
                    7 => ReviewPeriod.days7,
                    90 => ReviewPeriod.days90,
                    _ => ReviewPeriod.days30,
                  };
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'These lines describe what appeared in your recorded context. They do not say that a factor caused an outcome.',
              ),
              const SizedBox(height: 12),
              if (patterns.isEmpty)
                const EmptyState(
                  title: 'No descriptive patterns yet',
                  message: 'Patterns appear only when enough optional context is recorded across distinct dates.',
                ),
              for (final pattern in patterns)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pattern.subject.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(pattern.coverageLine),
                        const SizedBox(height: 8),
                        Text(pattern.factorLine),
                        const SizedBox(height: 8),
                        Text(
                          'Supporting dates',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final date in pattern.supportingDates)
                              ActionChip(
                                label: Text(date),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => DayEvidenceScreen(
                                        dateKey: date,
                                        limitToVisibleDomains: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                        AddResponseButton(
                          compact: true,
                          provenance: ResponseProvenance(
                            originType: ProvenanceOrigin.recognitionPattern,
                            domain: pattern.domain,
                            subject: pattern.subject.name,
                            factorId: pattern.factorId,
                            periodDays: period.days,
                            evidenceId: pattern.identity,
                            labelSnapshot:
                                '${pattern.subject.label} · ${pattern.factorLabel}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
