import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../debug/synthetic_check_in_seeder.dart';
import '../../debug/synthetic_check_ins.dart';
import '../../domain/copy.dart';
import 'application_reflection_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text(Copy.aboutMuhasabah),
            subtitle: const Text(Copy.applicationReflectionIntroTitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const ApplicationReflectionAboutScreen(),
                ),
              );
            },
          ),
          const Divider(),
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
