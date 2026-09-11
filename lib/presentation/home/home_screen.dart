import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../debug/synthetic_check_in_seeder.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/dashboard_summary.dart';
import '../../domain/date_key.dart';
import '../../domain/home_traces.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_mix.dart';
import '../../domain/recognition.dart';
import '../../domain/review_period.dart';
import '../../domain/salah_extras.dart';
import '../../domain/sample_retirement.dart';
import '../checkin/check_in_screen.dart';
import '../history/history_screen.dart';
import '../progress/optional_domain_progress_screen.dart';
import '../progress/salah_progress_screen.dart';
import '../recognition/recognition_screen.dart';
import '../response/response_editor_screen.dart';
import '../response/response_list_screen.dart';
import '../review/review_screen.dart';
import '../settings/application_reflection_screen.dart';
import '../settings/settings_screen.dart';
import '../shared/state_marker.dart';
import 'dashboard_cards.dart';
import 'home_domain_stage.dart';
import 'home_lookback_card.dart';
import 'marks_guide_sheet.dart';
import 'optional_domain_home_card.dart';
import 'quran_home_card.dart';
import 'reflection_home_cards.dart';
import 'salah_home_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkIns = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Copy.appName),
        actions: [
          Tooltip(
            message: Copy.marksGuideTitle,
            child: TextButton(
              onPressed: () => showMarksGuide(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: RecordedStateMarker(
                      kind: MarkerKind.filled,
                      semanticLabel: '',
                    ),
                  ),
                  const SizedBox(width: 4),
                  ExcludeSemantics(
                    child: Text(
                      '/',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: MuhasabahColors.mark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ExcludeSemantics(
                    child: RecordedStateMarker(
                      kind: MarkerKind.outlined,
                      semanticLabel: '',
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(Copy.marksGuide),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: checkIns.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Saved check-ins could not be loaded. Healthy records are kept.',
          ),
        ),
        data: (records) {
          final prefs = ref.watch(appPrefsProvider);
          ref.watch(prefsTickProvider);
          final offerArchive = shouldOfferSampleArchive(
            records: records,
            now: ref.watch(nowProvider),
            dismissed: prefs.archivePromptDismissed,
          );
          return ListView(
            primary: false,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (records.any((record) => record.synthetic))
                Material(
                  color: MuhasabahColors.wash(
                    MuhasabahColors.sampleBannerWash,
                    MuhasabahColors.sampleBannerWashDark,
                    Theme.of(context).brightness,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      Copy.sampleDataNotice,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              if (offerArchive) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Copy.archiveSamplePrompt),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton(
                              onPressed: () async {
                                await const SyntheticCheckInSeeder().clearFrom(
                                  ref.read(checkInRepositoryProvider),
                                  responses: ref.read(
                                    responseRepositoryProvider,
                                  ),
                                );
                                await prefs.setSampleRemovedByUser(true);
                                await prefs.setArchivePromptDismissed(true);
                                await ref
                                    .read(checkInsProvider.notifier)
                                    .reload();
                                await ref
                                    .read(responsesProvider.notifier)
                                    .reload();
                              },
                              child: const Text('Archive sample records'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await prefs.setArchivePromptDismissed(true);
                                ref.read(prefsTickProvider.notifier).state++;
                              },
                              child: const Text('Keep sample records'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              ..._dashboard(context, records: records, ref: ref),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _dashboard(
    BuildContext context, {
    required List<DailyCheckIn> records,
    required WidgetRef ref,
  }) {
    final period = ref.watch(reviewPeriodProvider);
    final now = ref.watch(nowProvider);
    final keys = periodDateKeys(period.days, now: now);
    final inPeriod = [
      for (final record in records)
        if (keys.contains(record.dateKey)) record,
    ];
    final recognitionCount = period == ReviewPeriod.days7
        ? 0
        : const RecognitionEngine()
              .detect(records: inPeriod, period: period)
              .length;
    final snapshot = buildHomeDashboard(
      records: records,
      now: now,
      period: period,
      recognitionCount: recognitionCount,
    );
    final visible = ref.watch(appPrefsProvider).visibleDomains;
    final mix = ref.watch(appPrefsProvider).personalMix;
    final mixKeys = resolvePersonalMixKeys(mix, visible);
    final season = personalMixSeasonLine(mix, visible);
    final homeDomains = homeMixDomains(visible, mix);
    final showQuranSurfaces =
        visible.contains(MonitorDomain.quran) &&
        (mix.kind == PersonalMixKind.sameAsDomains ||
            mixIncludesQuran(mixKeys));
    final hajjStatus = ref.watch(appPrefsProvider).hajjStatus;
    final showHajjPonder =
        homeDomains.contains(MonitorDomain.hajj) && hajjStatus.showsPreparation;
    void open(Widget page) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    }

    return [
      FilledButton.icon(
        onPressed: () => open(const CheckInScreen()),
        icon: const Icon(Icons.edit_calendar_outlined),
        label: const Text(Copy.homeCheckIn),
      ),
      const SizedBox(height: 12),
      const ReflectionOfTheWeekCard(),
      const SizedBox(height: 12),
      if (season != null) ...[
        Text(
          '${Copy.personalMixSeasonPrefix} $season.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
      ],
      HomeDomainStage(
        domains: homeDomains,
        cardFor: (domain) => _homeDomainCard(
          records: records,
          domain: domain,
          mix: mix,
          mixKeys: mixKeys,
        ),
      ),
      if (homeDomains.isNotEmpty) const SizedBox(height: 10),
      HomeLookbackCard(
        records: records,
        onOpenReview: () => _switchTab(context, 1),
      ),
      const SizedBox(height: 10),
      if (showQuranSurfaces) ...[
        DashboardNavCard(
          title: 'Recognition',
          body: snapshot.recognitionLine,
          onTap: () => open(const RecognitionScreen()),
        ),
        const SizedBox(height: 10),
        DashboardPonderCard(onTap: () => open(const QuranProgressScreen())),
        const SizedBox(height: 10),
      ],
      if (showHajjPonder) ...[
        DashboardNavCard(
          title: 'PONDER',
          body: hajjStatus == HajjStatus.preparing
              ? Copy.hajjPonderPreparing
              : Copy.hajjPonderDue,
          onTap: () => open(
            OptionalDomainProgressScreen(
              title: MonitorDomain.hajj.label,
              focusQuestion: MonitorDomain.hajj.focusQuestion,
              note: Copy.hajjObservationNote,
              rows: hajjHomeRows,
              family: MuhasabahColors.hajjFamily,
              includeHajjStatus: true,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
      const WeeklyJournalCard(),
      const SizedBox(height: 10),
      FilledButton(
        onPressed: () => open(const ResponseEditorScreen()),
        child: const Text(Copy.addAResponse),
      ),
      const SizedBox(height: 16),
      Text(
        'A private place to record, review, and respond — without scores or prescriptions. The card wash identifies the domain, not spiritual rank. Marks share one colour. ${Copy.unansweredNotMissed}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  Widget _homeDomainCard({
    required List<DailyCheckIn> records,
    required MonitorDomain domain,
    required PersonalMix mix,
    required Set<String> mixKeys,
  }) {
    final inMix =
        mix.kind != PersonalMixKind.sameAsDomains &&
        mixTouchesDomain(mixKeys, domain);
    final useCompact = mix.kind == PersonalMixKind.sameAsDomains
        ? usesCompactHomeWeek(domain)
        : !inMix;
    switch (domain) {
      case MonitorDomain.salah:
        return SalahHomeCard(
          records: records,
          compactWeek: useCompact,
          displayRows: inMix ? mixSalahRows(mixKeys) : SalahTraceRow.values,
        );
      case MonitorDomain.quran:
        return QuranHomeCard(
          records: records,
          compactWeek: useCompact,
          displayDimensions: inMix ? mixQuranDimensions(mixKeys) : null,
        );
      case MonitorDomain.hadith:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : hadithHomeRows,
          progressRows: hadithHomeRows,
          washLight: MuhasabahColors.hadithWash,
          washDark: MuhasabahColors.hadithWashDark,
          family: MuhasabahColors.hadithFamily,
          includeHadithFocus: true,
          compactWeek: useCompact,
        );
      case MonitorDomain.dhikr:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : dhikrHomeRows,
          progressRows: dhikrHomeRows,
          washLight: MuhasabahColors.dhikrWash,
          washDark: MuhasabahColors.dhikrWashDark,
          family: MuhasabahColors.dhikrFamily,
          compactWeek: useCompact,
        );
      case MonitorDomain.akhlaq:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : akhlaqHomeRows,
          progressRows: akhlaqHomeRows,
          washLight: MuhasabahColors.akhlaqWash,
          washDark: MuhasabahColors.akhlaqWashDark,
          family: MuhasabahColors.akhlaqFamily,
          includeStruggleNote: true,
          compactWeek: useCompact,
        );
      case MonitorDomain.huquq:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : huquqHomeRows,
          progressRows: huquqHomeRows,
          washLight: MuhasabahColors.huquqWash,
          washDark: MuhasabahColors.huquqWashDark,
          family: MuhasabahColors.huquqFamily,
          compactWeek: useCompact,
        );
      case MonitorDomain.knowledge:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : knowledgeHomeRows,
          progressRows: knowledgeHomeRows,
          washLight: MuhasabahColors.knowledgeWash,
          washDark: MuhasabahColors.knowledgeWashDark,
          family: MuhasabahColors.knowledgeFamily,
          compactWeek: useCompact,
        );
      case MonitorDomain.time:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : timeHomeRows,
          progressRows: timeHomeRows,
          washLight: MuhasabahColors.timeWash,
          washDark: MuhasabahColors.timeWashDark,
          family: MuhasabahColors.timeFamily,
          compactWeek: useCompact,
        );
      case MonitorDomain.health:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : healthHomeRows,
          progressRows: healthHomeRows,
          washLight: MuhasabahColors.healthWash,
          washDark: MuhasabahColors.healthWashDark,
          family: MuhasabahColors.healthFamily,
          compactWeek: useCompact,
        );
      case MonitorDomain.wealth:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : wealthHomeRows,
          progressRows: wealthHomeRows,
          washLight: MuhasabahColors.wealthWash,
          washDark: MuhasabahColors.wealthWashDark,
          family: MuhasabahColors.wealthFamily,
          compactWeek: useCompact,
        );
      case MonitorDomain.ummah:
        return OptionalDomainHomeCard(
          records: records,
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : ummahHomeRows,
          progressRows: ummahHomeRows,
          washLight: MuhasabahColors.ummahWash,
          washDark: MuhasabahColors.ummahWashDark,
          family: MuhasabahColors.ummahFamily,
          compactWeek: useCompact,
        );
      case MonitorDomain.fasting:
        return OptionalDomainHomeCard(
          records: records,
          title: 'Fasting',
          rows: inMix ? mixTraceRows(domain, mixKeys) : fastingHomeRows,
          progressRows: fastingHomeRows,
          washLight: MuhasabahColors.fastingWash,
          washDark: MuhasabahColors.fastingWashDark,
          family: MuhasabahColors.fastingFamily,
          highlightLunarWhiteDays: true,
          compactWeek: useCompact,
        );
      case MonitorDomain.hajj:
        final includeHajj = !inMix || mixIncludesHajj(mixKeys);
        return OptionalDomainHomeCard(
          records: records,
          title: MonitorDomain.hajj.label,
          focus: MonitorDomain.hajj.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : hajjHomeRows,
          progressRows: hajjHomeRows,
          washLight: MuhasabahColors.hajjWash,
          washDark: MuhasabahColors.hajjWashDark,
          family: MuhasabahColors.hajjFamily,
          includeHajjStatus: includeHajj,
          compactWeek: useCompact,
        );
      case MonitorDomain.charity:
        final includeZakat = !inMix || mixIncludesZakat(mixKeys);
        return OptionalDomainHomeCard(
          records: records,
          title: 'Charity',
          rows: inMix ? mixTraceRows(domain, mixKeys) : charityHomeRows,
          progressRows: charityHomeRows,
          washLight: MuhasabahColors.charityWash,
          washDark: MuhasabahColors.charityWashDark,
          family: MuhasabahColors.charityFamily,
          includeZakat: includeZakat,
          compactWeek: useCompact,
        );
    }
  }

  void _switchTab(BuildContext context, int index) {
    final shell = context.findAncestorStateOfType<AppShellState>();
    shell?.select(index);
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => AppShellState();
}

class AppShellState extends ConsumerState<AppShell> {
  int index = 0;

  void select(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider);
    ref.watch(prefsTickProvider);
    if (!prefs.applicationReflectionAcknowledged) {
      return ApplicationReflectionIntroScreen(
        onContinue: () async {
          await prefs.setApplicationReflectionAcknowledged(true);
          ref.read(prefsTickProvider.notifier).state++;
        },
      );
    }
    final pages = const [
      HomeScreen(),
      ReviewScreen(),
      HistoryScreen(),
      ResponseListScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Review',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_history_outlined),
            selectedIcon: Icon(Icons.manage_history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: Copy.myResponse,
          ),
        ],
      ),
    );
  }
}
