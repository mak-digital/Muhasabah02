import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/home_traces.dart';
import '../../domain/hajj_planning.dart';
import '../../domain/fasting_practices.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_mix.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/review_period.dart';
import '../progress/optional_domain_progress_screen.dart';
import '../progress/salah_progress_screen.dart';
import '../shared/domain_line_icon.dart';
import '../shared/domain_visual.dart';
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
    final snapshot = ref.watch(reviewPeriodSnapshotProvider);
    ref.watch(hajjStoreTickProvider);
    ref.watch(productivityStoreTickProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.reviewTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: Copy.reviewTitle,
          message: 'Period summary could not be built from stored records.',
        ),
        data: (_) {
          if (snapshot == null) {
            return const Center(child: CircularProgressIndicator());
          }
          ref.watch(prefsTickProvider);
          final mix = ref.watch(appPrefsProvider).personalMix;
          final resolver = PersonalisationResolver(
            visibleDomains: ref.watch(appPrefsProvider).visibleDomains,
            mix: mix,
          );
          final calendar = ref.watch(appPrefsProvider).displayCalendar;
          final brightness = Theme.of(context).brightness;
          final summary = snapshot;
          final keys = summary.keys;
          final inPeriod = summary.inPeriod;
          final salah = summary.salah;
          final reading = summary.reading;
          final hadithDays = summary.recordedDays(MonitorDomain.hadith);
          final dhikrDays = summary.recordedDays(MonitorDomain.dhikr);
          final fastingDays = summary.recordedDays(MonitorDomain.fasting);
          final akhlaqDays = summary.recordedDays(MonitorDomain.akhlaq);
          final huquqDays = summary.recordedDays(MonitorDomain.huquq);
          final knowledgeDays = summary.recordedDays(MonitorDomain.knowledge);
          final timeDays = summary.recordedDays(MonitorDomain.time);
          final healthDays = summary.recordedDays(MonitorDomain.health);
          final wealthDays = summary.recordedDays(MonitorDomain.wealth);
          final ummahDays = summary.recordedDays(MonitorDomain.ummah);
          final charityDays = summary.recordedDays(MonitorDomain.charity);
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
                  context,
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
                  context,
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
                  context,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.hadith.label,
                  focusQuestion: MonitorDomain.hadith.focusQuestion,
                  note: Copy.hadithObservationNote,
                  rows: rowsFor(MonitorDomain.hadith, hadithHomeRows),
                  family: MuhasabahColors.hadithFamily,
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
                  context,
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
            if (shows(MonitorDomain.fasting))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-fasting'),
                title: MonitorDomain.fasting.label,
                progressLabel: '${MonitorDomain.fasting.label} Progress',
                line:
                    '$fastingDays days with a recorded observation. White Days are orientation only.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.fastingWash,
                  MuhasabahColors.fastingWashDark,
                  brightness,
                  context,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.fasting.label,
                  focusQuestion: MonitorDomain.fasting.focusQuestion,
                  note: Copy.fastingObservationNote,
                  rows: gatedFastingHomeRows(
                    rowsFor(MonitorDomain.fasting, fastingHomeRows),
                    date: now,
                    offsetDays: ref
                        .watch(appPrefsProvider)
                        .ramadanCalendarOffsetDays,
                    showHistory: ref
                        .watch(appPrefsProvider)
                        .showFastingRamadanHistory,
                    records: inPeriod,
                  ),
                  family: MuhasabahColors.fastingFamily,
                  highlightLunarWhiteDays: true,
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
                  context,
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
                  context,
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
                  context,
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
                  context,
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
                  context,
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
                  context,
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
                  context,
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
            if (shows(MonitorDomain.productivity))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-productivity'),
                title: MonitorDomain.productivity.label,
                progressLabel: '${MonitorDomain.productivity.label} Progress',
                line:
                    '${ref.watch(productivityStoreRepositoryProvider).store.masterList.length} stored action(s). Effort vs plan is not a grade.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.productivityWash,
                  MuhasabahColors.productivityWashDark,
                  brightness,
                  context,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: MonitorDomain.productivity.label,
                  focusQuestion: MonitorDomain.productivity.focusQuestion,
                  note: Copy.productivityObservationNote,
                  rows: rowsFor(
                    MonitorDomain.productivity,
                    productivityHomeRows,
                  ),
                  family: MuhasabahColors.productivityFamily,
                ),
              ),
            if (shows(MonitorDomain.hajj))
              _ReviewDomainTile(
                tileKey: const Key('review-domain-hajj'),
                title: MonitorDomain.hajj.label,
                progressLabel: '${MonitorDomain.hajj.label} Progress',
                line:
                    'Standing: ${ref.watch(hajjStoreRepositoryProvider).store.standing.kind.label}. ${ref.watch(hajjStoreRepositoryProvider).store.journeys.length} stored journey(s). Learn & Practice is independent.',
                color: MuhasabahColors.wash(
                  MuhasabahColors.hajjWash,
                  MuhasabahColors.hajjWashDark,
                  brightness,
                  context,
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
                  context,
                ),
                onTap: () => _openTraceProgress(
                  context,
                  title: 'Charity',
                  note: Copy.charityObservationNote,
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
              if (tiles.isNotEmpty) ...[
                const _ReviewSectionLabel(Copy.reviewDomainsTap),
                _DomainMosaic(tiles: tiles),
              ],
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
    final domain = domainForTitle(title);
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (domain != null) ...[
                        DomainLineIcon(
                          domain,
                          size: 18,
                          color: domainColorIdentity(domain).family,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
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
