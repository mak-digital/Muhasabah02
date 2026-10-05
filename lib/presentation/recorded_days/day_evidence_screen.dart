import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/charity_factors.dart';
import '../../domain/context_catalog.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/display_calendar.dart';
import '../../domain/home_traces.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/other_domains.dart';
import '../../domain/personal_mix.dart';
import '../../domain/personal_response.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/salah_extras.dart';
import '../shared/add_response_button.dart';
import '../shared/system_insets.dart';
import '../shared/ui_bits.dart';
import 'evidence_ui.dart';

class DayEvidenceScreen extends ConsumerWidget {
  const DayEvidenceScreen({
    super.key,
    required this.dateKey,
  });

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final calendar = ref.read(appPrefsProvider).displayCalendar;
    final async = ref.watch(checkInsProvider);
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(title: Text(formatStoredDateKey(dateKey, calendar))),
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
          final prefs = ref.read(appPrefsProvider);
          final resolver = PersonalisationResolver(
            visibleDomains: prefs.visibleDomains,
            mix: prefs.personalMix,
          );
          bool show(MonitorDomain domain) =>
              resolver.reviewDomains.contains(domain);
          bool allows(String id) => resolver.mixFocusAllows(id);
          final sameAsDomains =
              resolver.mix.kind == PersonalMixKind.sameAsDomains;
          return ListView(
            padding: pageListPadding(context, recoverSystemBottom: true),
            children: [
              EvidenceGuard(
                Copy.historicalReflectionGuard,
                sample: record.synthetic,
              ),
              if (show(MonitorDomain.salah))
                EvidenceBand(
                  title: MonitorDomain.salah.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.salahWash,
                    MuhasabahColors.salahWashDark,
                    brightness,
                  ),
                  children: [
                    for (final prayer in PrayerId.values)
                      if (allows('salah.${prayer.name}'))
                        EvidenceRow(
                          name: prayer.label,
                          value: _prayerValue(record, prayer),
                          quiet: !record.prayer(prayer).isRecorded,
                        ),
                    if (allows('salah.${SalahTraceRow.jumuah.id}'))
                      EvidenceRow(
                        name: 'Jumu‘ah',
                        value:
                            ActivityCatalog.find(
                              ActivityCatalog.jumuah,
                              record.jumuahActivityId,
                            )?.label ??
                            record.jumuah.label,
                        quiet: !record.jumuah.isRecorded,
                      ),
                    if (allows('salah.${SalahTraceRow.tahajjud.id}'))
                      EvidenceRow(
                        name: 'Tahajjud',
                        value: _voluntary(record.tahajjud),
                        quiet: record.tahajjud == TernaryOutcome.unanswered,
                      ),
                    if (allows('salah.${SalahTraceRow.ishraq.id}'))
                      EvidenceRow(
                        name: 'Ishraq',
                        value: _voluntary(record.ishraq),
                        quiet: record.ishraq == TernaryOutcome.unanswered,
                      ),
                  ],
                ),
              if (show(MonitorDomain.quran))
                EvidenceBand(
                  title: MonitorDomain.quran.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.quranWash,
                    MuhasabahColors.quranWashDark,
                    brightness,
                  ),
                  children: [
                    for (final dimension in quranDailyDimensions)
                      if (allows('quran.${dimension.name}'))
                        EvidenceRow(
                          name: dimension.label,
                          value: switch (record.quranOutcome(dimension)) {
                            TernaryOutcome.positive => dimension.positiveLabel,
                            TernaryOutcome.negative => dimension.negativeLabel,
                            TernaryOutcome.unanswered => 'Not recorded',
                          },
                          quiet:
                              record.quranOutcome(dimension) ==
                              TernaryOutcome.unanswered,
                          note:
                              dimension ==
                                      QuranDimension.consciousApplication &&
                                  record.quranOutcome(dimension).isRecorded
                              ? Copy.consciousApplicationNote
                              : null,
                        ),
                    if (allows('quran.applicationReflection') &&
                        record
                            .quranOutcome(QuranDimension.applicationReflection)
                            .isRecorded)
                      EvidenceRow(
                        name: 'Application Reflection',
                        value: record
                            .quranOutcome(
                              QuranDimension.applicationReflection,
                            )
                            .legendLabel,
                        note: Copy.applicationReflectionNote,
                      ),
                  ],
                ),
              if (show(MonitorDomain.hadith))
                ..._traceBand(
                  context,
                  title: MonitorDomain.hadith.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.hadithWash,
                    MuhasabahColors.hadithWashDark,
                    brightness,
                  ),
                  rows: _mixRows(hadithHomeRows, allows),
                  record: record,
                  extraName: 'Hadith engagement',
                  extraValue: _observationLabel(
                    ActivityCatalog.hadith,
                    record.hadith,
                  ),
                  extraQuiet: !record.hadith.isRecorded,
                  showExtra: sameAsDomains && record.hadith.isRecorded,
                ),
              if (show(MonitorDomain.dhikr))
                ..._traceBand(
                  context,
                  title: MonitorDomain.dhikr.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.dhikrWash,
                    MuhasabahColors.dhikrWashDark,
                    brightness,
                  ),
                  rows: _mixRows(dhikrHomeRows, allows),
                  record: record,
                  extraName: 'Dhikr / Istighfar',
                  extraValue: record.dhikr.label,
                  extraQuiet: !record.dhikr.isRecorded,
                  showExtra: sameAsDomains && record.dhikr.isRecorded,
                ),
              if (show(MonitorDomain.akhlaq))
                ..._traceBand(
                  context,
                  title: MonitorDomain.akhlaq.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.akhlaqWash,
                    MuhasabahColors.akhlaqWashDark,
                    brightness,
                  ),
                  rows: _mixRows(akhlaqAllHomeRows, allows),
                  record: record,
                  extraName: Copy.akhlaqStruggleNote,
                  extraValue: record.akhlaqStruggleNote ?? '',
                  extraQuiet: false,
                  showExtra:
                      record.akhlaqStruggleNote != null &&
                      record.akhlaqStruggleNote!.trim().isNotEmpty,
                ),
              if (show(MonitorDomain.huquq))
                ..._traceBand(
                  context,
                  title: MonitorDomain.huquq.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.huquqWash,
                    MuhasabahColors.huquqWashDark,
                    brightness,
                  ),
                  rows: _mixRows(huquqHomeRows, allows),
                  record: record,
                  extraName: '',
                  extraValue: '',
                  extraQuiet: true,
                  showExtra: false,
                ),
              if (show(MonitorDomain.knowledge))
                ..._traceBand(
                  context,
                  title: MonitorDomain.knowledge.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.knowledgeWash,
                    MuhasabahColors.knowledgeWashDark,
                    brightness,
                  ),
                  rows: _mixRows(knowledgeHomeRows, allows),
                  record: record,
                  extraName: '',
                  extraValue: '',
                  extraQuiet: true,
                  showExtra: false,
                ),
              if (show(MonitorDomain.time))
                ..._traceBand(
                  context,
                  title: MonitorDomain.time.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.timeWash,
                    MuhasabahColors.timeWashDark,
                    brightness,
                  ),
                  rows: _mixRows(timeAllHomeRows, allows),
                  record: record,
                  extraName: '',
                  extraValue: '',
                  extraQuiet: true,
                  showExtra: false,
                ),
              if (show(MonitorDomain.health))
                ..._traceBand(
                  context,
                  title: MonitorDomain.health.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.healthWash,
                    MuhasabahColors.healthWashDark,
                    brightness,
                  ),
                  rows: _mixRows(healthHomeRows, allows),
                  record: record,
                  extraName: '',
                  extraValue: '',
                  extraQuiet: true,
                  showExtra: false,
                ),
              if (show(MonitorDomain.wealth))
                ..._traceBand(
                  context,
                  title: MonitorDomain.wealth.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.wealthWash,
                    MuhasabahColors.wealthWashDark,
                    brightness,
                  ),
                  rows: _mixRows(wealthAllHomeRows, allows),
                  record: record,
                  extraName: '',
                  extraValue: '',
                  extraQuiet: true,
                  showExtra: false,
                ),
              if (show(MonitorDomain.ummah))
                ..._traceBand(
                  context,
                  title: MonitorDomain.ummah.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.ummahWash,
                    MuhasabahColors.ummahWashDark,
                    brightness,
                  ),
                  rows: _mixRows(ummahAllHomeRows, allows),
                  record: record,
                  extraName: '',
                  extraValue: '',
                  extraQuiet: true,
                  showExtra: false,
                ),
              if (show(MonitorDomain.fasting))
                ..._traceBand(
                  context,
                  title: 'Fasting',
                  color: MuhasabahColors.wash(
                    MuhasabahColors.fastingWash,
                    MuhasabahColors.fastingWashDark,
                    brightness,
                  ),
                  rows: _mixRows(fastingHomeRows, allows),
                  record: record,
                  extraName: 'Fasting',
                  extraValue: _observationLabel(
                    ActivityCatalog.fasting,
                    record.fasting,
                  ),
                  extraQuiet: !record.fasting.isRecorded,
                  showExtra: sameAsDomains && record.fasting.isRecorded,
                ),
              if (show(MonitorDomain.hajj))
                ..._traceBand(
                  context,
                  title: MonitorDomain.hajj.label,
                  color: MuhasabahColors.wash(
                    MuhasabahColors.hajjWash,
                    MuhasabahColors.hajjWashDark,
                    brightness,
                  ),
                  rows: _mixRows(hajjHomeRows, allows),
                  record: record,
                  extraName: '',
                  extraValue: '',
                  extraQuiet: true,
                  showExtra: false,
                ),
              if (show(MonitorDomain.charity))
                ..._traceBand(
                  context,
                  title: 'Charity',
                  color: MuhasabahColors.wash(
                    MuhasabahColors.charityWash,
                    MuhasabahColors.charityWashDark,
                    brightness,
                  ),
                  rows: _mixRows(charityHomeRows, allows),
                  record: record,
                  extraName: 'Financial charity',
                  extraValue: _observationLabel(
                    ActivityCatalog.charity,
                    record.charity,
                  ),
                  extraQuiet: !record.charity.isRecorded,
                  showExtra: sameAsDomains && record.charity.isRecorded,
                  extraRows: [
                    if (record.zakat.isRecorded && allows(kZakatMixKey))
                      EvidenceRow(name: 'Zakat', value: record.zakat.label),
                  ],
                ),
              EvidenceBand(
                title: Copy.notesOnThisDay,
                color: MuhasabahColors.wash(
                  MuhasabahColors.summaryWash,
                  MuhasabahColors.summaryWashDark,
                  brightness,
                ),
                children: [
                  EvidenceRow(
                    name: Copy.situationNotesTitle,
                    value: record.situationNotes.isEmpty
                        ? Copy.reviewNoneRecorded
                        : record.situationNotes.displayLabels.join(', '),
                    quiet: record.situationNotes.isEmpty,
                    note: record.situationNotes.isEmpty
                        ? null
                        : Copy.situationNotesNote,
                  ),
                  if (record.conduct.isRecorded)
                    EvidenceRow(
                      name: 'Character / conduct',
                      value: record.conduct.label,
                    ),
                  EvidenceRow(
                    name: 'Gratitude',
                    value: record.gratitudeStatus == EntryStatus.recorded
                        ? 'An entry was saved'
                        : record.gratitudeStatus.labelHint,
                    quiet: record.gratitudeStatus != EntryStatus.recorded,
                  ),
                  EvidenceRow(
                    name: Copy.personalReflection,
                    value:
                        record.personalReflectionStatus == EntryStatus.recorded
                        ? 'An entry was saved'
                        : record.personalReflectionStatus.labelHint,
                    quiet:
                        record.personalReflectionStatus != EntryStatus.recorded,
                  ),
                  for (final ctx in record.contexts)
                    if (allows('quran.${ctx.subject.name}'))
                      EvidenceRow(
                        name: '${ctx.subject.label} · ${ctx.polarity}',
                        value: ctx.factorIds
                            .map(
                              (id) => ContextCatalog.labelFor(id, ctx.polarity),
                            )
                            .join(', '),
                      ),
                ],
              ),
              if (record.homeTraceFactors.entries.any(
                (entry) => allows(entry.key) && !entry.value.isEmpty,
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 14, top: 2),
                  child: Text(
                    Copy.factorsNotCauses,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              AddResponseButton(
                filled: true,
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

  List<HomeTraceRow> _mixRows(
    List<HomeTraceRow> rows,
    bool Function(String id) allows,
  ) {
    return [
      for (final row in rows)
        if (allows(row.storageKey)) row,
    ];
  }

  List<Widget> _traceBand(
    BuildContext context, {
    required String title,
    required Color color,
    required List<HomeTraceRow> rows,
    required DailyCheckIn record,
    required String extraName,
    required String extraValue,
    required bool extraQuiet,
    required bool showExtra,
    List<Widget> extraRows = const [],
  }) {
    final children = <Widget>[];
    for (final row in rows) {
      final outcome = record.homeTrace(row.storageKey);
      final factors = _factorLine(record, row.storageKey);
      if (outcome == TernaryOutcome.unanswered && factors == null) continue;
      children.add(
        EvidenceRow(
          name: row.label,
          value: traceOutcomeLabel(
            row.storageKey,
            outcome,
            includeSubject: false,
          ),
          quiet: outcome == TernaryOutcome.unanswered,
          note: factors,
        ),
      );
    }
    if (showExtra) {
      children.add(
        EvidenceRow(name: extraName, value: extraValue, quiet: extraQuiet),
      );
    }
    children.addAll(extraRows);
    if (children.isEmpty) return const [];
    return [EvidenceBand(title: title, color: color, children: children)];
  }

  String _prayerValue(DailyCheckIn record, PrayerId prayer) {
    final activity = record.activityFor(ActivityCatalog.salahKey(prayer));
    final option = ActivityCatalog.find(ActivityCatalog.salah, activity.id);
    var label = option?.label ?? record.prayer(prayer).label;
    if (activity.customText != null && activity.customText!.trim().isNotEmpty) {
      label = '$label · ${activity.customText!.trim()}';
    }
    if (prayer == PrayerId.dhuhr && record.jumuahCongregation) {
      return '$label · Friday congregation';
    }
    return label;
  }

  String _voluntary(TernaryOutcome outcome) {
    return switch (outcome) {
      TernaryOutcome.positive => 'Performed',
      TernaryOutcome.negative => 'Not performed',
      TernaryOutcome.unanswered => 'Not recorded',
    };
  }

  String _observationLabel(
    List<ActivityOption> catalog,
    DomainObservation observation,
  ) {
    if (!observation.isRecorded) return 'Not recorded';
    final option = ActivityCatalog.find(catalog, observation.activityId);
    final label = option?.label ?? observation.activityId;
    final custom = observation.customText?.trim();
    if (custom != null && custom.isNotEmpty) return '$label · $custom';
    return label;
  }

  String? _factorLine(DailyCheckIn record, String storageKey) {
    final factors = record.homeTraceFactors[storageKey];
    if (factors == null || factors.isEmpty) return null;
    final parts = [
      ...factors.supportIds.map(
        (id) => homeTraceFactorLabel(storageKey, id, helping: true),
      ),
      ...factors.challengeIds.map(
        (id) => homeTraceFactorLabel(storageKey, id, helping: false),
      ),
      if (factors.otherText != null && factors.otherText!.trim().isNotEmpty)
        factors.otherText!.trim(),
    ];
    if (parts.isEmpty) return null;
    return '${Copy.factorsYouNoticed}: ${parts.join(', ')}';
  }
}
