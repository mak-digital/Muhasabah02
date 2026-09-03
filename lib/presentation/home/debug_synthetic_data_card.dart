import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../debug/synthetic_check_in_seeder.dart';

class DebugSyntheticDataCard extends ConsumerStatefulWidget {
  const DebugSyntheticDataCard({super.key});

  @override
  ConsumerState<DebugSyntheticDataCard> createState() =>
      _DebugSyntheticDataCardState();
}

class _DebugSyntheticDataCardState
    extends ConsumerState<DebugSyntheticDataCard> {
  var _busy = false;
  String? _status;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Debug data', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Generate 100 days of synthetic check-ins, including missing days and unanswered fields. This control is not shown in release builds.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_status != null) ...[
              const SizedBox(height: 8),
              Text(_status!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : _generate,
                  child: const Text('Generate 100 days'),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : _clear,
                  child: const Text('Clear generated data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      final result = await const SyntheticCheckInSeeder().generateInto(
        ref.read(checkInRepositoryProvider),
        now: ref.read(nowProvider),
      );
      await ref.read(checkInsProvider.notifier).reload();
      if (!mounted) return;
      setState(() {
        _status =
            'Wrote ${result.written} days, left ${result.missingDays} missing, skipped ${result.skippedUserOwned} user-owned.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    setState(() => _busy = true);
    try {
      final removed = await const SyntheticCheckInSeeder().clearFrom(
        ref.read(checkInRepositoryProvider),
      );
      await ref.read(checkInsProvider.notifier).reload();
      if (!mounted) return;
      setState(() => _status = 'Cleared $removed generated days.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
