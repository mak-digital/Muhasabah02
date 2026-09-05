import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../debug/synthetic_check_in_seeder.dart';
import '../../debug/synthetic_check_ins.dart';
import '../../domain/copy.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/quotation_cadence.dart';
import '../shared/ui_bits.dart';
import 'application_reflection_screen.dart';
import 'reflection_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final firstDay = prefs.firstDayOfWeek;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(Copy.appearancePreferences),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_view_week_outlined),
              title: const Text(Copy.firstDayOfWeek),
              subtitle: Text('${firstDay.label}\n${Copy.firstDayOfWeekNote}'),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const FirstDayOfWeekSettingsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(Copy.reflectionPreferences),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.timeline_outlined),
                  title: const Text(Copy.baselinesTitle),
                  subtitle: const Text(Copy.baselinesNote),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const BaselinesSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text(Copy.personalAspirations),
                  subtitle: const Text(Copy.aspirationsNote),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const AspirationsSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(Copy.reflectionsQuotations),
          Card(
            child: ListTile(
              leading: const Icon(Icons.format_quote_outlined),
              title: const Text(Copy.quotationCadence),
              subtitle: Text(
                '${prefs.quotationCadence.label}\n${Copy.quotationCadenceNote}',
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const QuotationsSettingsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(Copy.aboutMuhasabah),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text(Copy.applicationReflectionIntroTitle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ApplicationReflectionAboutScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(Copy.dataManagement),
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text(Copy.dataManagement),
                  subtitle: Text(kSampleDataNotice),
                ),
                ListTile(
                  title: const Text('Recreate sample data'),
                  subtitle: const Text(
                    'Replace sample records only. Your own records are left unchanged.',
                  ),
                  onTap: () => _recreate(context, ref),
                ),
                ListTile(
                  title: const Text('Remove sample data'),
                  subtitle: const Text(
                    'Removes sample check-ins and sample responses. Nothing is deleted automatically later.',
                  ),
                  onTap: () => _remove(context, ref),
                ),
                ListTile(
                  title: const Text('Restore sample data'),
                  subtitle: const Text(
                    'Bring the sample dataset back. Existing personal days are not overwritten.',
                  ),
                  onTap: () => _restore(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FirstDayOfWeekSettingsScreen extends ConsumerWidget {
  const FirstDayOfWeekSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final current = ref.watch(appPrefsProvider).firstDayOfWeek;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.firstDayOfWeek)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.firstDayOfWeekNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<FirstDayOfWeekPref>(
              groupValue: current,
              onChanged: (value) async {
                if (value == null) return;
                await ref.read(appPrefsProvider).setFirstDayOfWeek(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  for (final option in FirstDayOfWeekPref.values)
                    RadioListTile<FirstDayOfWeekPref>(
                      title: Text(
                        option == FirstDayOfWeekPref.monday
                            ? '${option.label} (default)'
                            : option.label,
                      ),
                      value: option,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _recreate(BuildContext context, WidgetRef ref) async {
  final seeder = const SyntheticCheckInSeeder();
  await seeder.clearFrom(
    ref.read(checkInRepositoryProvider),
    responses: ref.read(responseRepositoryProvider),
  );
  await seeder.generateInto(
    ref.read(checkInRepositoryProvider),
    now: ref.read(nowProvider),
    responses: ref.read(responseRepositoryProvider),
  );
  await ref.read(appPrefsProvider).setSampleSeeded(true);
  await ref.read(appPrefsProvider).setSampleRemovedByUser(false);
  await ref.read(checkInsProvider.notifier).reload();
  await ref.read(responsesProvider.notifier).reload();
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample data was recreated.')));
  }
}

Future<void> _remove(BuildContext context, WidgetRef ref) async {
  await const SyntheticCheckInSeeder().clearFrom(
    ref.read(checkInRepositoryProvider),
    responses: ref.read(responseRepositoryProvider),
  );
  await ref.read(appPrefsProvider).setSampleRemovedByUser(true);
  await ref.read(checkInsProvider.notifier).reload();
  await ref.read(responsesProvider.notifier).reload();
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample data was removed.')));
  }
}

Future<void> _restore(BuildContext context, WidgetRef ref) async {
  await ref.read(appPrefsProvider).setSampleRemovedByUser(false);
  await const SyntheticCheckInSeeder().generateInto(
    ref.read(checkInRepositoryProvider),
    now: ref.read(nowProvider),
    responses: ref.read(responseRepositoryProvider),
  );
  await ref.read(appPrefsProvider).setSampleSeeded(true);
  await ref.read(checkInsProvider.notifier).reload();
  await ref.read(responsesProvider.notifier).reload();
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample data was restored.')));
  }
}
