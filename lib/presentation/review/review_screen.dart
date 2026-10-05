import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/analytics.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/home_traces.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/other_domains.dart';
import '../../domain/personal_mix.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/personal_response.dart';
import '../../domain/quran.dart';
import '../../domain/review_period.dart';
import '../progress/optional_domain_progress_screen.dart';
import '../progress/salah_progress_screen.dart';
import '../recognition/recognition_screen.dart';
import '../recorded_days/recorded_days_screen.dart';
import '../shared/add_response_button.dart';
import '../shared/system_insets.dart';
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
          ref.watch(prefsTickProvider);
          final mix = ref.watch(appPrefsProvider).personalMix;
          final resolver = PersonalisationResolver(
            visibleDomains: ref.watch(appPrefsProvider).visibleDomains,
            mix: mix,
          );
          final calendar = ref.watch(appPrefsProvider).displayCalendar;
          final brightness = Theme.of(context).brightness;
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
          var akhlaqDays = 0;
          var huquqDays = 0;
          var knowledgeDays = 0;
          var timeDays = 0;
          var healthDays = 0;
          var wealthDays = 0;
          var ummahDays = 0;
          var fastingDays = 0;
          var hajjDays = 0;
          var charityDays = 0;
          var hadithDays = 0;
          var conductDays = 0;
          var gratitudeEntries = 0;
          var reflectionEntries = 0;
          for (final record in inPeriod) {
            if (record.dhikr.isRecorded ||
                _hasRecordedTrace(record, dhikrHomeRows)) {
              dhikrDays++;
            }
            if (_hasRecordedTrace(record, akhlaqAllHomeRows) ||
                (record.akhlaqStruggleNote != null &&
                    record.akhlaqStruggleNote!.trim().isNotEmpty)) {
              akhlaqDays++;
            }
            if (_hasRecordedTrace(record, huquqHomeRows)) {
              huquqDays++;
            }
            if (_hasRecordedTrace(record, knowledgeHomeRows)) {
              knowledgeDays++;
            }
            if (_hasRecordedTrace(record, timeAllHomeRows)) {
              timeDays++;
            }
            if (_hasRecordedTrace(record, healthHomeRows)) {
              healthDays++;
            }
            if (_hasRecordedTrace(record, wealthAllHomeRows)) {
              wealthDays++;
            }
            if (_hasRecordedTrace(record, ummahAllHomeRows)) {
              ummahDays++;
            }
            if (record.fasting.isRecorded ||
                _hasRecordedTrace(record, fastingHomeRows)) {
              fastingDays++;
            }
            if (_hasRecordedTrace(record, hajjHomeRows)) {
              hajjDays++;
            }
            if (record.charity.isRecorded ||
                _hasRecordedTrace(record, charityHomeRows)) {
              charityDays++;
            }
            if (record.hadith.isRecorded ||
                _hasRecordedTrace(record, hadithHomeRows)) {
              hadithDays++;
            }
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
          final situationLabels = <String>{};
          for (final record in inPeriod) {
            situationLabels.addAll(record.situationNotes.displayLabels);
          }
          final mixKeys = resolver.effectiveRowIds;
          List<HomeTraceRow> rowsFor(
            MonitorDomain domain,
            List<HomeTraceRow> all,
          ) {
            if (mix.kind == PersonalMixKind.sameAsDomains) return all;
            return mixTraceRows(domain, mixKeys);
          }

          bool shows(MonitorDomain domain) =>
              resolver.reviewDomains.contains(domain);
          final builtTiles = <_ReviewDomainTile>[
            if (shows(MonitorDomain.salah))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-salah'),
                title: MonitorDomain.salah.label,
                progressLabel: '${MonitorDomain.salah.label} Progress',
                line:
                    '${salah.desirable} on time among ${salah.recorded} recorded. Missing excluded.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.salahWash,
                  MuhasabahColors.salahWashDark,
                  brightness,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SalahProgressScreen(),
                  ),
                ),
              ),
            if (shows(MonitorDomain.quran))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-quran'),
                title: MonitorDomain.quran.label,
                progressLabel: '${MonitorDomain.quran.label} Progress',
                line:
                    '${reading.desirable} read-or-listened among ${reading.recorded} recorded days.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.quranWash,
                  MuhasabahColors.quranWashDark,
                  brightness,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const QuranProgressScreen(),
                  ),
                ),
              ),
            if (shows(MonitorDomain.hadith))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-hadith'),
                title: MonitorDomain.hadith.label,
                progressLabel: '${MonitorDomain.hadith.label} Progress',
                line: '$hadithDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.hadithWash,
                  MuhasabahColors.hadithWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.hadith.label,
                  focusQuestion: MonitorDomain.hadith.focusQuestion,
                  note: Copy.hadithObservationNote,
                  rows: rowsFor(MonitorDomain.hadith, hadithHomeRows),
                  family: MuhasabahColors.hadithFamily,
                  includeHadithFocus: true,
                  itemRowsOn7Days: true,
                ),
              ),
            if (shows(MonitorDomain.dhikr))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-dhikr'),
                title: MonitorDomain.dhikr.label,
                progressLabel: '${MonitorDomain.dhikr.label} Progress',
                line: '$dhikrDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.dhikrWash,
                  MuhasabahColors.dhikrWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.dhikr.label,
                  focusQuestion: MonitorDomain.dhikr.focusQuestion,
                  rows: rowsFor(MonitorDomain.dhikr, dhikrHomeRows),
                  family: MuhasabahColors.dhikrFamily,
                  itemRowsOn7Days: true,
                ),
              ),
            if (shows(MonitorDomain.akhlaq))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-akhlaq'),
                title: MonitorDomain.akhlaq.label,
                progressLabel: '${MonitorDomain.akhlaq.label} Progress',
                line: '$akhlaqDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.akhlaqWash,
                  MuhasabahColors.akhlaqWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.akhlaq.label,
                  focusQuestion: MonitorDomain.akhlaq.focusQuestion,
                  note: Copy.akhlaqObservationNote,
                  rows: rowsFor(MonitorDomain.akhlaq, akhlaqHomeRows),
                  family: MuhasabahColors.akhlaqFamily,
                  includeStruggleNote: true,
                  itemRowsOn7Days: true,
                ),
              ),
            if (shows(MonitorDomain.huquq))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-huquq'),
                title: MonitorDomain.huquq.label,
                progressLabel: '${MonitorDomain.huquq.label} Progress',
                line: '$huquqDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.huquqWash,
                  MuhasabahColors.huquqWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.huquq.label,
                  focusQuestion: MonitorDomain.huquq.focusQuestion,
                  note: Copy.huquqObservationNote,
                  rows: rowsFor(MonitorDomain.huquq, huquqHomeRows),
                  family: MuhasabahColors.huquqFamily,
                  itemRowsOn7Days: true,
                ),
              ),
            if (shows(MonitorDomain.knowledge))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-knowledge'),
                title: MonitorDomain.knowledge.label,
                progressLabel: '${MonitorDomain.knowledge.label} Progress',
                line: '$knowledgeDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.knowledgeWash,
                  MuhasabahColors.knowledgeWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.knowledge.label,
                  focusQuestion: MonitorDomain.knowledge.focusQuestion,
                  note: Copy.knowledgeObservationNote,
                  rows: rowsFor(MonitorDomain.knowledge, knowledgeHomeRows),
                  family: MuhasabahColors.knowledgeFamily,
                  itemRowsOn7Days: true,
                ),
              ),
            if (shows(MonitorDomain.time))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-time'),
                title: MonitorDomain.time.label,
                progressLabel: '${MonitorDomain.time.label} Progress',
                line: '$timeDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.timeWash,
                  MuhasabahColors.timeWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.time.label,
                  focusQuestion: MonitorDomain.time.focusQuestion,
                  note: Copy.timeObservationNote,
                  rows: rowsFor(MonitorDomain.time, timeHomeRows),
                  family: MuhasabahColors.timeFamily,
                ),
              ),
            if (shows(MonitorDomain.health))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-health'),
                title: MonitorDomain.health.label,
                progressLabel: '${MonitorDomain.health.label} Progress',
                line: '$healthDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.healthWash,
                  MuhasabahColors.healthWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.health.label,
                  focusQuestion: MonitorDomain.health.focusQuestion,
                  note: Copy.healthObservationNote,
                  rows: rowsFor(MonitorDomain.health, healthHomeRows),
                  family: MuhasabahColors.healthFamily,
                ),
              ),
            if (shows(MonitorDomain.wealth))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-wealth'),
                title: MonitorDomain.wealth.label,
                progressLabel: '${MonitorDomain.wealth.label} Progress',
                line: '$wealthDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.wealthWash,
                  MuhasabahColors.wealthWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.wealth.label,
                  focusQuestion: MonitorDomain.wealth.focusQuestion,
                  note: Copy.wealthObservationNote,
                  rows: rowsFor(MonitorDomain.wealth, wealthHomeRows),
                  family: MuhasabahColors.wealthFamily,
                ),
              ),
            if (shows(MonitorDomain.ummah))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-ummah'),
                title: MonitorDomain.ummah.label,
                progressLabel: '${MonitorDomain.ummah.label} Progress',
                line: '$ummahDays days with a recorded observation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.ummahWash,
                  MuhasabahColors.ummahWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.ummah.label,
                  focusQuestion: MonitorDomain.ummah.focusQuestion,
                  note: Copy.ummahObservationNote,
                  rows: rowsFor(MonitorDomain.ummah, ummahHomeRows),
                  family: MuhasabahColors.ummahFamily,
                ),
              ),
            if (shows(MonitorDomain.fasting))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-fasting'),
                title: 'Fasting',
                progressLabel: 'Fasting Progress',
                line:
                    '$fastingDays days with a recorded observation. White Days are orientation only.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.fastingWash,
                  MuhasabahColors.fastingWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: 'Fasting',
                  rows: rowsFor(MonitorDomain.fasting, fastingHomeRows),
                  family: MuhasabahColors.fastingFamily,
                  highlightLunarWhiteDays: true,
                ),
              ),
            if (shows(MonitorDomain.hajj))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-hajj'),
                title: MonitorDomain.hajj.label,
                progressLabel: '${MonitorDomain.hajj.label} Progress',
                line:
                    'Standing status: ${ref.watch(appPrefsProvider).hajjStatus.label}. $hajjDays days with noticed preparation.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.hajjWash,
                  MuhasabahColors.hajjWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.hajj.label,
                  focusQuestion: MonitorDomain.hajj.focusQuestion,
                  note: Copy.hajjObservationNote,
                  rows: rowsFor(MonitorDomain.hajj, hajjHomeRows),
                  family: MuhasabahColors.hajjFamily,
                  includeHajjStatus: true,
                ),
              ),
            if (shows(MonitorDomain.charity))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-charity'),
                title: 'Charity',
                progressLabel: 'Charity Progress',
                line:
                    '$charityDays days with a recorded observation. Zakat is on Progress.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.charityWash,
                  MuhasabahColors.charityWashDark,
                  brightness,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: 'Charity',
                  rows: rowsFor(MonitorDomain.charity, charityHomeRows),
                  family: MuhasabahColors.charityFamily,
                  includeZakat:
                      mix.kind == PersonalMixKind.sameAsDomains ||
                      mixIncludesZakat(mixKeys),
                ),
              ),
          ];
          final tiles = [
            for (final domain in resolver.reviewDomains)
              for (final tile in builtTiles)
                if (tile.tileKey == Key('review-domain-${domain.id}')) tile,
          ];
          return ListView(
            primary: false,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: pageListPadding(context),
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
                '${formatDayMonth(parseDateKey(keys.first), calendar)} – ${formatDayMonthYear(parseDateKey(keys.last), calendar)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Copy.reviewGuard,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _PeriodHero(
                daysRecorded: daysRecorded,
                periodDays: period.days,
                contextNotes: situationLabels.isEmpty
                    ? Copy.reviewNoneRecorded
                    : situationLabels.join(', '),
              ),
              if (tiles.isNotEmpty) ...[
                const _ReviewSectionLabel(Copy.reviewDomainsTap),
                _DomainMosaic(tiles: tiles),
              ],
              const _ReviewSectionLabel(Copy.reviewLookCloser),
              _LookCloserCard(
                icon: Icons.calendar_view_month_outlined,
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
              if (shows(MonitorDomain.quran))
                _LookCloserCard(
                  icon: Icons.pattern_outlined,
                  title: 'Recognition',
                  body: period.days >= 30
                      ? '${period.shortLabel} view is available for this window.'
                      : Copy.reviewRecognitionBody,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const RecognitionScreen(),
                    ),
                  ),
                ),
              if (shows(MonitorDomain.salah)) ...[
                const _ReviewSectionLabel(Copy.reviewPonder),
                _PonderCard(text: narrativeCopy(narrative)),
              ],
              const SizedBox(height: 8),
              _AlsoRecordedCard(
                conductDays: conductDays,
                gratitudeEntries: gratitudeEntries,
                reflectionEntries: reflectionEntries,
                situationNote: situationLabels.isEmpty
                    ? null
                    : Copy.situationNotesNote,
              ),
              const SizedBox(height: 8),
              AddResponseButton(
                filled: true,
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

  void _openTraceProgress(
    BuildContext context, {
    required String title,
    required List<HomeTraceRow> rows,
    required Color family,
    String? focusQuestion,
    String? note,
    bool includeZakat = false,
    bool includeHadithFocus = false,
    bool includeHajjStatus = false,
    bool highlightLunarWhiteDays = false,
    bool includeStruggleNote = false,
    bool itemRowsOn7Days = true,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => OptionalDomainProgressScreen(
          title: title,
          focusQuestion: focusQuestion,
          note: note,
          rows: rows,
          family: family,
          includeZakat: includeZakat,
          includeHadithFocus: includeHadithFocus,
          includeHajjStatus: includeHajjStatus,
          highlightLunarWhiteDays: highlightLunarWhiteDays,
          includeStruggleNote: includeStruggleNote,
          itemRowsOn7Days: itemRowsOn7Days,
        ),
      ),
    );
  }
}

class _PeriodHero extends StatelessWidget {
  const _PeriodHero({
    required this.daysRecorded,
    required this.periodDays,
    required this.contextNotes,
  });

  final int daysRecorded;
  final int periodDays;
  final String contextNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Copy.reviewThisPeriod, style: muted),
            const SizedBox(height: 2),
            Text(
              '$daysRecorded of $periodDays days have a record',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _HeroMeter(
                    label: Copy.reviewUnansweredDays,
                    value: '${periodDays - daysRecorded} of $periodDays',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeroMeter(
                    label: Copy.situationNotesTitle,
                    value: contextNotes,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMeter extends StatelessWidget {
  const _HeroMeter({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return WashPanel(
      color: MuhasabahColors.wash(
        MuhasabahColors.summaryWash,
        MuhasabahColors.summaryWashDark,
        brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _ReviewSectionLabel extends StatelessWidget {
  const _ReviewSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DomainMosaic extends StatelessWidget {
  const _DomainMosaic({required this.tiles});

  final List<_ReviewDomainTile> tiles;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      if (i + 1 >= tiles.length) {
        rows.add(tiles[i]);
      } else {
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: tiles[i]),
              const SizedBox(width: 8),
              Expanded(child: tiles[i + 1]),
            ],
          ),
        );
      }
    }
    return Column(children: rows);
  }
}

class _ReviewDomainTile extends StatelessWidget {
  const _ReviewDomainTile({
    required this.tileKey,
    required this.title,
    required this.progressLabel,
    required this.line,
    required this.color,
    required this.onTap,
  });

  final Key tileKey;
  final String title;
  final String progressLabel;
  final String line;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: progressLabel,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: tileKey,
          onTap: onTap,
          child: SizedBox(
            height: 118,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      line,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    Copy.reviewOpenProgress,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LookCloserCard extends StatelessWidget {
  const _LookCloserCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: MuhasabahColors.wash(
                    MuhasabahColors.summaryWash,
                    MuhasabahColors.summaryWashDark,
                    Theme.of(context).brightness,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PonderCard extends StatelessWidget {
  const _PonderCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return WashPanel(
      color: MuhasabahColors.wash(
        MuhasabahColors.sampleBannerWash,
        MuhasabahColors.sampleBannerWashDark,
        Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copy.reviewWhatRecordsShow.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AlsoRecordedCard extends StatelessWidget {
  const _AlsoRecordedCard({
    required this.conductDays,
    required this.gratitudeEntries,
    required this.reflectionEntries,
    this.situationNote,
  });

  final int conductDays;
  final int gratitudeEntries;
  final int reflectionEntries;
  final String? situationNote;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Copy.reviewYouAlsoRecorded,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('• Character observations: $conductDays days'),
            Text('• Gratitude entries: $gratitudeEntries'),
            Text('• Personal-reflection entries: $reflectionEntries'),
            if (situationNote != null) ...[
              const SizedBox(height: 8),
              Text(
                situationNote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

bool _hasRecordedTrace(DailyCheckIn record, List<HomeTraceRow> rows) {
  for (final row in rows) {
    if (record.homeTrace(row.storageKey).isRecorded) return true;
  }
  return false;
}
