import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/hajj_planning.dart';
import 'activity_picker.dart';

class HajjStandingEditor extends ConsumerWidget {
  const HajjStandingEditor({super.key, this.bottomPadding = 8});

  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(hajjStoreTickProvider);
    final repo = ref.watch(hajjStoreRepositoryProvider);
    final current = repo.store.standing.kind;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CheckInRowLabel(Copy.hajjStatusLabel),
          CheckInSelect<HajjStandingKind>(
            dropdownKey: const Key('hajj-status'),
            value: current,
            entries: [
              for (final option in HajjStandingKind.values)
                CheckInSelectEntry(value: option, label: option.label),
            ],
            onChanged: (option) async {
              final next = repo.store.withStanding(
                option,
                recordedAt: ref.read(nowProvider).toIso8601String(),
              );
              await repo.save(next);
              ref.read(hajjStoreTickProvider.notifier).state++;
            },
          ),
          const SizedBox(height: 6),
          Text(
            Copy.hajjStatusNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
