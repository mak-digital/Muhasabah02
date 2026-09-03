import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/personal_response.dart';
import '../checkin/check_in_screen.dart';
import '../history/history_screen.dart';
import '../response/response_editor_screen.dart';
import '../review/review_screen.dart';
import '../shared/ui_bits.dart';
import 'debug_synthetic_data_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkIns = ref.watch(checkInsProvider);
    final todayKey = dateKey(ref.watch(nowProvider));
    return Scaffold(
      appBar: AppBar(
        title: const Text(Copy.appName),
        actions: [
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
          Text(
            'A private place to record, review, and respond — without scores or prescriptions.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          checkIns.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text(
              'Saved check-ins could not be loaded. Healthy records are kept.',
            ),
            data: (records) {
              DailyCheckIn? today;
              for (final record in records) {
                if (record.dateKey == todayKey) today = record;
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        today == null
                            ? 'No check-in saved for $todayKey yet.'
                            : 'Saved ${today.answeredRecordableCount}/$kRecordableFieldCount recordable fields. Additional Qur’an observations are independent.',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CheckInScreen()),
              );
            },
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text(Copy.homeCheckIn),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _switchTab(context, 1),
            icon: const Icon(Icons.insights_outlined),
            label: const Text(Copy.homeReview),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _switchTab(context, 2),
            icon: const Icon(Icons.history),
            label: const Text(Copy.homeManage),
          ),
          const SizedBox(height: 24),
          const SectionHeader('How this app works'),
          const Text(
            'RECORD → REFLECT → REVIEW → RECOGNISE → PONDER → RESPOND\n\nMissing answers are not treated as missed. Responses are yours; the app does not prescribe worship.',
          ),
          const SizedBox(height: 16),
          const DebugSyntheticDataCard(),
        ],
      ),
    );
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
