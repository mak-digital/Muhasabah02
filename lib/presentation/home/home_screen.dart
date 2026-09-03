import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../debug/synthetic_check_in_seeder.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/dashboard_summary.dart';
import '../../domain/date_key.dart';
import '../../domain/personal_response.dart';
import '../../domain/recognition.dart';
import '../../domain/review_period.dart';
import '../../domain/sample_retirement.dart';
import '../checkin/check_in_screen.dart';
import '../history/history_screen.dart';
import '../progress/salah_progress_screen.dart';
import '../recognition/recognition_screen.dart';
import '../response/response_editor_screen.dart';
import '../review/review_screen.dart';
import '../settings/application_reflection_screen.dart';
import '../settings/settings_screen.dart';
import '../shared/ui_bits.dart';
import 'dashboard_cards.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkIns = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Copy.appName),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Theme',
            onPressed: () {
              final current = ref.read(themeModePrefProvider);
              ref.read(themeModePrefProvider.notifier).state =
                  (current + 1) % 3;
            },
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          checkIns.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text(
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  ],
                  const SizedBox(height: 8),
                  ..._dashboard(context, records: records, ref: ref),
                ],
              );
            },
          ),
        ],
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
    void open(Widget page) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    }

    final brightness = Theme.of(context).brightness;
    return [
      FilledButton.icon(
        onPressed: () => open(const CheckInScreen()),
        icon: const Icon(Icons.edit_calendar_outlined),
        label: const Text(Copy.homeCheckIn),
      ),
      const SizedBox(height: 12),
      DashboardDomainCard(
        model: snapshot.salah,
        color: MuhasabahColors.wash(
          MuhasabahColors.salahWash,
          MuhasabahColors.salahWashDark,
          brightness,
        ),
        onTap: () => open(const SalahProgressScreen()),
      ),
      const SizedBox(height: 10),
      DashboardDomainCard(
        model: snapshot.quran,
        color: MuhasabahColors.wash(
          MuhasabahColors.quranWash,
          MuhasabahColors.quranWashDark,
          brightness,
        ),
        onTap: () => open(const QuranProgressScreen()),
      ),
      const SizedBox(height: 10),
      DashboardDomainCard(
        model: snapshot.dhikr,
        color: MuhasabahColors.wash(
          MuhasabahColors.dhikrWash,
          MuhasabahColors.dhikrWashDark,
          brightness,
        ),
        onTap: () => open(const CheckInScreen()),
      ),
      const SizedBox(height: 10),
      DashboardDomainCard(
        model: snapshot.family,
        color: MuhasabahColors.wash(
          MuhasabahColors.familyWash,
          MuhasabahColors.familyWashDark,
          brightness,
        ),
        onTap: () => open(const CheckInScreen()),
      ),
      const SizedBox(height: 10),
      DashboardDomainCard(
        model: snapshot.charity,
        color: MuhasabahColors.wash(
          MuhasabahColors.charityWash,
          MuhasabahColors.charityWashDark,
          brightness,
        ),
        onTap: () => open(const CheckInScreen()),
      ),
      const SizedBox(height: 10),
      DashboardDomainCard(
        model: snapshot.fasting,
        color: MuhasabahColors.wash(
          MuhasabahColors.fastingWash,
          MuhasabahColors.fastingWashDark,
          brightness,
        ),
        onTap: () => open(const CheckInScreen()),
      ),
      const SizedBox(height: 12),
      DashboardNavCard(
        title: 'Current review snapshot',
        body: snapshot.reviewLine,
        onTap: () => _switchTab(context, 1),
      ),
      const SizedBox(height: 10),
      DashboardNavCard(
        title: 'Recognition',
        body: snapshot.recognitionLine,
        onTap: () => open(const RecognitionScreen()),
      ),
      const SizedBox(height: 10),
      DashboardPonderCard(onTap: () => open(const QuranProgressScreen())),
      const SizedBox(height: 10),
      FilledButton(
        onPressed: () => open(const ResponseEditorScreen()),
        child: const Text(Copy.addAResponse),
      ),
      const SizedBox(height: 16),
      Text(
        'A private place to record, review, and respond — without scores or prescriptions. Colour identifies the domain, not spiritual rank. ${Copy.unansweredNotMissed}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
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

class ResponseListScreen extends ConsumerWidget {
  const ResponseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(responsesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.myResponse)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ResponseEditorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(Copy.addAResponse),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: Copy.myResponse,
          message: 'Saved responses could not be listed. Existing records were left unchanged.',
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              title: Copy.myResponse,
              message:
                  '${Copy.myResponseDescription}\n\n${Copy.emptyResponses}',
              action: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ResponseEditorScreen(),
                    ),
                  );
                },
                child: const Text(Copy.addAResponse),
              ),
            );
          }
          final active = items.where((item) => !item.isArchived).toList();
          final archived = items.where((item) => item.isArchived).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Text(
                Copy.myResponseDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              for (final item in active) _tile(context, ref, item),
              if (archived.isNotEmpty) ...[
                const SectionHeader('Archived'),
                for (final item in archived) _tile(context, ref, item),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, PersonalResponse item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(item.text, maxLines: 3, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          item.provenance == null
              ? 'Independent note'
              : item.provenance!.displayLine,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ResponseDetailScreen(id: item.id),
            ),
          );
        },
      ),
    );
  }
}
