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
import '../input/input_screen.dart';
import '../registry/registry_screen.dart';
import '../review/review_screen.dart';
import '../response/response_editor_screen.dart';
import '../settings/settings_screen.dart';
import 'first_look_door_screen.dart';
import '../shared/domain_line_icon.dart';
import '../shared/state_marker.dart';
import '../shared/app_language_scope.dart';
import '../shared/ui_bits.dart';
import 'marks_guide_sheet.dart';
import 'optional_domain_home_card.dart';
import 'quran_home_card.dart';
import 'reflection_home_cards.dart';
import 'salah_home_card.dart';
import 'salah_home_follow_on.dart';

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
        title: Text(uiText(context, Copy.appName)),
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
          final visible = prefs.visibleDomains;
          final mix = prefs.personalMix;
          final resolver = PersonalisationResolver(
            visibleDomains: visible,
            mix: mix,
          );
          final homeDomains = resolver.homeDomains;
          final shown = homeDomains.isEmpty
              ? null
              : homeDomains[homeDomainStageIndex(
                  homeDomains,
                  ref.watch(homeDomainStageProvider),
                )];
          final season = shown == null
              ? null
              : personalMixSeasonLine(mix, visible, domain: shown);
          final practice = shown == null ? null : homePracticeWash(shown);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (homeDomains.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Wrap(
                    key: const Key('home-domain-tabs'),
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final domain in homeDomains)
                        ChoiceChip(
                          key: Key('home-domain-tab-${domain.id}'),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DomainLineIcon(domain, size: 16),
                              const SizedBox(width: 6),
                              Text(uiText(context, domain.shortLabel)),
                            ],
                          ),
                          selected: domain == shown,
                          onSelected: (_) {
                            ref.read(homeDomainStageProvider.notifier).state =
                                domain;
                          },
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  key: const Key('home-scroll'),
                  primary: false,
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
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
                                      await prefs.setArchivePromptDismissed(
                                        true,
                                      );
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
                                      await prefs.setArchivePromptDismissed(
                                        true,
                                      );
                                      ref
                                          .read(prefsTickProvider.notifier)
                                          .state++;
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
                    if (season != null) ...[
                      BalancedProse(
                        '${uiText(context, Copy.personalMixSeasonPrefix)} $season.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (shown != null)
                      KeyedSubtree(
                        key: Key('home-domain-card-${shown.id}'),
                        child: _homeDomainCard(
                          records: records,
                          domain: shown,
                          mix: mix,
                          mixKeys: resolver.effectiveRowIds,
                        ),
                      ),
                    if (shown != null) ...[
                      const SizedBox(height: 10),
                      if (shown.showsHomeActionFollowOn)
                        DomainHomeFollowOn(domain: shown)
                      else if (shown != MonitorDomain.productivity) ...[
                        const WeeklyJournalCard(),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ResponseEditorScreen(),
                              ),
                            );
                          },
                          child: const Text(Copy.addAResponse),
                        ),
                      ],
                      if (practice != null) ...[
                        const SizedBox(height: 10),
                        practice,
                      ],
                    ] else ...[
                      const SizedBox(height: 10),
                      const WeeklyJournalCard(),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ResponseEditorScreen(),
                            ),
                          );
                        },
                        child: const Text(Copy.addAResponse),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const ReflectionOfTheWeekCard(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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
  static const homeTab = 0;
  static const inputTab = 1;
  static const reviewTab = 2;
  static const registryTab = 3;

  int index = homeTab;

  /// Visited tabs only. Same in debug and release; not an Impeller workaround.
  final _opened = <int>{homeTab};

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
          _tab(inputTab, const InputScreen()),
          _tab(reviewTab, const ReviewScreen()),
          _tab(registryTab, const RegistryScreen()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: uiText(context, 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.edit_note_outlined),
            selectedIcon: const Icon(Icons.edit_note),
            label: uiText(context, Copy.inputTab),
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: uiText(context, Copy.reviewTitle),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: uiText(context, Copy.registryTab),
          ),
        ],
      ),
    );
  }
}
