import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../debug/synthetic_check_in_seeder.dart';
import '../../domain/copy.dart';
import '../../domain/personal_mix.dart';
import '../shared/brand_mark.dart';
import '../shared/brand_title.dart';

class FirstLookDoorScreen extends ConsumerStatefulWidget {
  const FirstLookDoorScreen({super.key});

  @override
  ConsumerState<FirstLookDoorScreen> createState() =>
      FirstLookDoorScreenState();
}

class FirstLookDoorScreenState extends ConsumerState<FirstLookDoorScreen> {
  bool _busy = false;

  Future<void> _finish({required bool seedSample}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final prefs = ref.read(appPrefsProvider);
    final checkIns = ref.read(checkInRepositoryProvider);
    final responses = ref.read(responseRepositoryProvider);
    final now = ref.read(nowProvider);
    const seeder = SyntheticCheckInSeeder();
    if (seedSample) {
      await seeder.generateInto(checkIns, now: now, responses: responses);
    } else {
      await seeder.clearFrom(checkIns, responses: responses);
    }
    await prefs.setSampleSeeded(true);
    await prefs.setPersonalMix(mixForKind(PersonalMixKind.firstLook));
    await prefs.setApplicationReflectionAcknowledged(true);
    if (!mounted) return;
    ref.invalidate(checkInsProvider);
    ref.invalidate(responsesProvider);
    ref.read(prefsTickProvider.notifier).state++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: BrandTitle.toolbarHeight,
        title: const BrandTitle(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: BrandMark(size: 112)),
          const SizedBox(height: 24),
          Text(
            Copy.firstLookDoorTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            Copy.appSlogan,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            Copy.appNotice,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            Copy.firstLookDoorPrivate,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            Copy.firstLookDoorEmpty,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            Copy.firstLookDoorSeason,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
              FilledButton(
                onPressed: _busy ? null : () => _finish(seedSample: false),
                child: const Text(Copy.firstLookStartBlank),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : () => _finish(seedSample: true),
                child: const Text(Copy.firstLookShowSample),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
