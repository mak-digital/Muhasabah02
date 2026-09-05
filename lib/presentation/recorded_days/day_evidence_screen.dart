import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/context_catalog.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/other_domains.dart';
import '../../domain/personal_response.dart';
import '../../domain/prayer.dart';
import '../../domain/home_traces.dart';
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
              if (record.synthetic)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('Sample/demo record'),
                ),
              const SizedBox(height: 12),
              Text('Salah', style: Theme.of(context).textTheme.titleMedium),
              for (final prayer in PrayerId.values) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(prayer.label),
                  subtitle: Text(record.prayer(prayer).label),
                ),
                if (prayer == PrayerId.dhuhr && record.jumuahCongregation)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Friday congregation'),
                    subtitle: Text('Attended'),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Jumu‘ah'),
                subtitle: Text(record.jumuah.label),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tahajjud'),
                subtitle: Text(switch (record.tahajjud) {
                  TernaryOutcome.positive => 'Performed',
                  TernaryOutcome.negative => 'Not performed',
                  TernaryOutcome.unanswered => 'Not recorded',
                }),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ishraq'),
                subtitle: Text(switch (record.ishraq) {
                  TernaryOutcome.positive => 'Performed',
                  TernaryOutcome.negative => 'Not performed',
                  TernaryOutcome.unanswered => 'Not recorded',
                }),
              ),
              const SizedBox(height: 8),
              Text('Qur’an', style: Theme.of(context).textTheme.titleMedium),
              for (final dimension in quranDailyDimensions) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(dimension.label),
                  subtitle: Text(switch (record.quranOutcome(dimension)) {
                    TernaryOutcome.positive => dimension.positiveLabel,
                    TernaryOutcome.negative => dimension.negativeLabel,
                    TernaryOutcome.unanswered => 'Not recorded',
                  }),
                ),
                if (dimension == QuranDimension.consciousApplication)
                  Text(
                    Copy.consciousApplicationNote,
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
              if (record
                  .quranOutcome(QuranDimension.applicationReflection)
                  .isRecorded) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Application Reflection'),
                  subtitle: Text(
                    record
                        .quranOutcome(QuranDimension.applicationReflection)
                        .legendLabel,
                  ),
                ),
                Text(
                  Copy.applicationReflectionNote,
                  style: Theme.of(context).textTheme.bodySmall,
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
                title: const Text(Copy.personalReflection),
                subtitle: Text(
                  record.personalReflectionStatus == EntryStatus.recorded
                      ? 'An entry was saved'
                      : record.personalReflectionStatus.labelHint,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fasting'),
                subtitle: Text(record.fasting.activityId),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Financial charity'),
                subtitle: Text(record.charity.activityId),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Zakat'),
                subtitle: Text(record.zakat.label),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Family / kinship'),
                subtitle: Text(record.family.activityId),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hadith engagement'),
                subtitle: Text(record.hadith.activityId),
              ),
              if (record.homeTraces.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Home traces',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final entry in record.homeTraces.entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      homeTraceRowByKey(entry.key)?.label ?? entry.key,
                    ),
                    subtitle: Text(switch (entry.value) {
                      TernaryOutcome.positive => 'Recorded engagement',
                      TernaryOutcome.negative => 'Recorded as not done',
                      TernaryOutcome.unanswered => 'Not recorded',
                    }),
                  ),
              ],
              if (record.homeTraceFactors.values.any(
                (item) => !item.isEmpty,
              )) ...[
                const SizedBox(height: 8),
                Text(
                  Copy.factorsYouNoticed,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'You recorded these factors. They are not causes.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                for (final entry in record.homeTraceFactors.entries)
                  if (!entry.value.isEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        homeTraceRowByKey(entry.key)?.label ?? entry.key,
                      ),
                      subtitle: Text(
                        [
                          ...entry.value.supportIds.map(
                            (id) => ContextCatalog.labelFor(id, 'positive'),
                          ),
                          ...entry.value.challengeIds.map(
                            (id) => ContextCatalog.labelFor(id, 'negative'),
                          ),
                          if (entry.value.otherText != null &&
                              entry.value.otherText!.trim().isNotEmpty)
                            entry.value.otherText!.trim(),
                        ].join(', '),
                      ),
                    ),
              ],
              if (!record.situationNotes.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  Copy.situationNotesTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  Copy.situationNotesNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(Copy.youRecorded),
                  subtitle: Text(
                    record.situationNotes.displayLabels.join(', '),
                  ),
                ),
              ],
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
