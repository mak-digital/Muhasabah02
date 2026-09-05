import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/ids.dart';
import '../../domain/personal_aspiration.dart';
import '../../domain/personal_baseline.dart';
import '../../domain/quotation_cadence.dart';

class BaselinesSettingsScreen extends ConsumerWidget {
  const BaselinesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.baselinesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(Copy.baselinesNote),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _create(ref, BaselineSource.days30),
            child: const Text('Create from last 30 days'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => _create(ref, BaselineSource.days90),
            child: const Text('Create from last 90 days'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => _create(ref, BaselineSource.snapshot),
            child: const Text('Create current snapshot baseline'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _manual(context, ref),
            child: const Text('Manual baseline'),
          ),
          const SizedBox(height: 16),
          for (final baseline in prefs.baselines.reversed)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baseline.source.label),
                    Text(
                      '${baseline.windowStart} – ${baseline.windowEnd}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (baseline.manualNote != null) Text(baseline.manualNote!),
                    const SizedBox(height: 8),
                    for (final entry in baseline.counts.entries.take(12))
                      if (entry.value.engagementDays > 0)
                        Text(
                          '${entry.key}: recorded engagement on ${entry.value.engagementDays} days',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _create(WidgetRef ref, BaselineSource source) async {
    final records = await ref.read(checkInRepositoryProvider).allHealthy();
    final baseline = buildBaseline(
      id: newOpaqueId(),
      now: ref.read(nowProvider),
      source: source,
      records: records,
    );
    final prefs = ref.read(appPrefsProvider);
    await prefs.setBaselines([...prefs.baselines, baseline]);
    ref.read(prefsTickProvider.notifier).state++;
  }

  Future<void> _manual(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Manual baseline'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Describe a pattern you want to remember. Not a target score.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (saved != true) return;
    final baseline = buildBaseline(
      id: newOpaqueId(),
      now: ref.read(nowProvider),
      source: BaselineSource.manual,
      records: const [],
      manualNote: controller.text.trim(),
    );
    final prefs = ref.read(appPrefsProvider);
    await prefs.setBaselines([...prefs.baselines, baseline]);
    ref.read(prefsTickProvider.notifier).state++;
  }
}

class AspirationsSettingsScreen extends ConsumerWidget {
  const AspirationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.personalAspirations)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(Copy.aspirationsNote),
          const SizedBox(height: 12),
          for (final kind in AspirationKind.values)
            if (kind != AspirationKind.custom)
              CheckboxListTile(
                title: Text(kind.label),
                value: prefs.aspirations.any((item) => item.kind == kind),
                onChanged: (selected) async {
                  var next = List.of(prefs.aspirations);
                  if (selected == true) {
                    next.add(PersonalAspiration(id: newOpaqueId(), kind: kind));
                  } else {
                    next = [
                      for (final item in next)
                        if (item.kind != kind) item,
                    ];
                  }
                  await prefs.setAspirations(next);
                  ref.read(prefsTickProvider.notifier).state++;
                },
              ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _custom(context, ref),
            child: const Text('Add custom aspiration'),
          ),
          for (final item in prefs.aspirations)
            if (item.kind == AspirationKind.custom)
              ListTile(
                title: Text(item.displayLabel),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await prefs.setAspirations([
                      for (final other in prefs.aspirations)
                        if (other.id != item.id) other,
                    ]);
                    ref.read(prefsTickProvider.notifier).state++;
                  },
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _custom(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom aspiration'),
          content: TextField(controller: controller, maxLines: 3),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (saved != true || controller.text.trim().isEmpty) return;
    final prefs = ref.read(appPrefsProvider);
    await prefs.setAspirations([
      ...prefs.aspirations,
      PersonalAspiration(
        id: newOpaqueId(),
        kind: AspirationKind.custom,
        customText: controller.text.trim(),
      ),
    ]);
    ref.read(prefsTickProvider.notifier).state++;
  }
}

class QuotationsSettingsScreen extends ConsumerWidget {
  const QuotationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.reflectionsQuotations)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(Copy.quotationCadenceNote),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<QuotationCadence>(
              groupValue: prefs.quotationCadence,
              onChanged: (value) async {
                if (value == null) return;
                await prefs.setQuotationCadence(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  for (final option in QuotationCadence.values)
                    RadioListTile<QuotationCadence>(
                      title: Text(
                        option == QuotationCadence.weekly
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
