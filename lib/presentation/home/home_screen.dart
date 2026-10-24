import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../debug/startup_probe.dart';
import '../../debug/synthetic_check_in_seeder.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/home_traces.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_mix.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/salah_extras.dart';
import '../../domain/sample_retirement.dart';
import '../registry/registry_screen.dart';
import '../review/review_screen.dart';
import '../response/response_editor_screen.dart';
import '../settings/settings_screen.dart';
import 'first_look_door_screen.dart';
import '../shared/brand_title.dart';
import '../shared/state_marker.dart';
import '../shared/ui_bits.dart';
import 'home_domain_stage.dart';
import 'marks_guide_sheet.dart';
import 'optional_domain_home_card.dart';
import 'quran_home_card.dart';
import 'reflection_home_cards.dart';
import 'salah_home_card.dart';
import 'salah_home_follow_on.dart';
import 'today_overview.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkIns = ref.watch(checkInsProvider);
    if (checkIns.isLoading) {
      StartupProbe.mark('home_checkins_loading');
    } else if (checkIns.hasValue) {
      StartupProbe.mark('home_checkins_ready');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        StartupProbe.mark('home_first_input_frame');
      });
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: BrandTitle.toolbarHeight,
        title: const BrandTitle(),
        actions: [
          Tooltip(
            message: Copy.marksGuideTitle,
            child: TextButton(
              onPressed: () => showMarksGuide(context),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
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
        error: (_, _) => const EmptyState(
          title: Copy.appName,
          message:
              'Saved check-ins could not be loaded. Healthy records are kept.',
        ),
        data: (records) {
          final prefs = ref.watch(appPrefsProvider);
          ref.watch(prefsTickProvider);
          final offerArchive = shouldOfferSampleArchive(
            records: records,
            now: ref.watch(nowProvider),
            dismissed: prefs.archivePromptDismissed,
          );
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (offerArchive) ...[
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
                                  await const SyntheticCheckInSeeder()
                                      .clearFrom(
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
                  const SizedBox(height: 8),
                ],
                TodayOverview(records: records),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    key: const Key('home-scroll'),
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: 28),
                    children: _dashboardScroll(
                      context,
                      records: records,
                      ref: ref,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _dashboardScroll(
    BuildContext context, {
    required List<DailyCheckIn> records,
    required WidgetRef ref,
  }) {
    final visible = ref.watch(appPrefsProvider).visibleDomains;
    final mix = ref.watch(appPrefsProvider).personalMix;
    final resolver = PersonalisationResolver(visibleDomains: visible, mix: mix);
    final mixKeys = resolver.effectiveRowIds;
    final homeDomains = resolver.homeDomains;
    void open(Widget page) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    }

    return [
      const ReflectionOfTheWeekCard(),
      const SizedBox(height: 12),
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
      ..._followOn(context, ref: ref, homeDomains: homeDomains, open: open),
    ];
  }

  List<Widget> _followOn(
    BuildContext context, {
    required WidgetRef ref,
    required List<MonitorDomain> homeDomains,
    required void Function(Widget page) open,
  }) {
    if (homeDomains.isNotEmpty) {
      final shown =
          homeDomains[homeDomainStageIndex(
            homeDomains,
            ref.watch(homeDomainStageProvider),
          )];
      if (shown.showsHomeActionFollowOn) {
        return [DomainHomeFollowOn(domain: shown)];
      }
      if (shown == MonitorDomain.productivity) {
        return const [];
      }
    }
    return [
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
          compactWeek: useCompact,
          itemRowsOn7Days: true,
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
          itemRowsOn7Days: true,
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
          itemRowsOn7Days: true,
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
          itemRowsOn7Days: true,
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
          itemRowsOn7Days: true,
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
          title: domain.label,
          focus: domain.focusQuestion,
          rows: inMix ? mixTraceRows(domain, mixKeys) : fastingHomeRows,
          progressRows: fastingHomeRows,
          washLight: MuhasabahColors.fastingWash,
          washDark: MuhasabahColors.fastingWashDark,
          family: MuhasabahColors.fastingFamily,
          highlightLunarWhiteDays: true,
          gateFastingRamadan: true,
          compactWeek: useCompact,
        );
      case MonitorDomain.productivity:
        final includeProductivity = !inMix || mixIncludesProductivity(mixKeys);
        return OptionalDomainHomeCard(
          records: records,
          title: MonitorDomain.productivity.label,
          focus: MonitorDomain.productivity.focusQuestion,
          rows: productivityHomeRows,
          progressRows: productivityHomeRows,
          washLight: MuhasabahColors.productivityWash,
          washDark: MuhasabahColors.productivityWashDark,
          family: MuhasabahColors.productivityFamily,
          includeProductivityDashboard: includeProductivity,
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
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => AppShellState();
}

class AppShellState extends ConsumerState<AppShell> {
  int index = 0;

  /// Visited tabs only. Same in debug and release; not an Impeller workaround.
  final _opened = <int>{0};

  void select(int value) {
    setState(() {
      _opened.add(value);
      index = value;
    });
  }

  Widget _tab(int slot, Widget child) {
    if (_opened.contains(slot)) return child;
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider);
    ref.watch(prefsTickProvider);
    if (!prefs.applicationReflectionAcknowledged) {
      return const FirstLookDoorScreen();
    }
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          const HomeScreen(),
          _tab(1, const ReviewScreen()),
          _tab(2, const RegistryScreen()),
        ],
      ),
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
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: Copy.registryTab,
          ),
        ],
      ),
    );
  }
}
