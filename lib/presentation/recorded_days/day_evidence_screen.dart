import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/context_catalog.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/other_domains.dart';
import '../../domain/personal_response.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../shared/add_response_button.dart';
import '../shared/ui_bits.dart';

class DayEvidenceScreen extends ConsumerWidget {
  const DayEvidenceScreen({super.key, required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(dateKey)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: Copy.historicalReflectionTitle,
          message: Copy.evidenceUnavailable,
        ),
        data: (records) {
          DailyCheckIn? found;
          for (final record in records) {
            if (record.dateKey == dateKey) found = record;
          }
          if (found == null) {
            return const EmptyState(
              title: Copy.historicalReflectionTitle,
              message: Copy.evidenceUnavailable,
            );
          }
          final record = found;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                Copy.historicalReflectionTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text('${Copy.youRecorded} the following on $dateKey.'),
              const SizedBox(height: 12),
              Text('Salah', style: Theme.of(context).textTheme.titleMedium),
              for (final prayer in PrayerId.values) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(prayer.label),
                  subtitle: Text(record.prayer(prayer).label),
                ),
                AddResponseButton(
                  compact: true,
                  provenance: ResponseProvenance(
                    originType: ProvenanceOrigin.progressDate,
                    domain: 'salah',
                    subject: prayer.name,
                    dateKey: dateKey,
                    evidenceId: '$dateKey:salah:${prayer.name}',
                    labelSnapshot: '${prayer.label} on $dateKey',
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text('Qur’an', style: Theme.of(context).textTheme.titleMedium),
              for (final dimension in QuranDimension.values) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(dimension.label),
                  subtitle: Text(switch (record.quranOutcome(dimension)) {
                    TernaryOutcome.positive => dimension.positiveLabel,
                    TernaryOutcome.negative => dimension.negativeLabel,
                    TernaryOutcome.unanswered => 'Not recorded',
                  }),
                ),
                if (dimension.isApplicationReflection)
                  Text(
                    Copy.applicationReflectionNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                AddResponseButton(
                  compact: true,
                  provenance: ResponseProvenance(
                    originType: ProvenanceOrigin.progressDate,
                    domain: 'quran',
                    subject: dimension.name,
                    dateKey: dateKey,
                    evidenceId: '$dateKey:quran:${dimension.name}',
                    labelSnapshot: '${dimension.label} on $dateKey',
                  ),
                ),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dhikr / Istighfar'),
                subtitle: Text(record.dhikr.label),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Character / conduct'),
                subtitle: Text(record.conduct.label),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Gratitude'),
                subtitle: Text(
                  record.gratitudeStatus == EntryStatus.recorded
                      ? 'An entry was saved'
                      : record.gratitudeStatus.labelHint,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Personal reflection'),
                subtitle: Text(
                  record.personalReflectionStatus == EntryStatus.recorded
                      ? 'An entry was saved'
                      : record.personalReflectionStatus.labelHint,
                ),
              ),
              if (record.contexts.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Recorded context',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final ctx in record.contexts)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${ctx.subject.label} · ${ctx.polarity}'),
                      subtitle: Text(
                        ctx.factorIds
                            .map(
                              (id) => ContextCatalog.labelFor(id, ctx.polarity),
                            )
                            .join(', '),
                      ),
                      onTap: () {},
                    ),
                  ),
                AddResponseButton(
                  provenance: ResponseProvenance(
                    originType: ProvenanceOrigin.recordedContext,
                    domain: 'quran',
                    dateKey: dateKey,
                    evidenceId: '$dateKey:context',
                    labelSnapshot: 'Recorded context on $dateKey',
                  ),
                ),
              ],
              AddResponseButton(
                provenance: ResponseProvenance(
                  originType: ProvenanceOrigin.historicalReflection,
                  dateKey: dateKey,
                  evidenceId: dateKey,
                  labelSnapshot: 'Historical Reflection $dateKey',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension on EntryStatus {
  String get labelHint => switch (this) {
    EntryStatus.unanswered => 'Not recorded',
    EntryStatus.noneToday => 'No entry today',
    EntryStatus.recorded => 'Entry saved',
  };
}
