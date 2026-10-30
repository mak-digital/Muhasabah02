import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/productivity_planning.dart';

class ProductivitySettingsScreen extends ConsumerWidget {
  const ProductivitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(productivityStoreTickProvider);
    final store = ref.watch(productivityStoreRepositoryProvider).store;
    final cap = effectiveTodayCap(store);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.productivitySettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.productivityDailyActionsNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text(Copy.productivityDailyActions),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  key: const Key('productivity-today-slots'),
                  value: cap,
                  borderRadius: BorderRadius.circular(8),
                  items: [
                    for (var n = 1; n <= kProductivityTodayCap; n++)
                      DropdownMenuItem(
                        key: Key('productivity-today-slots-$n'),
                        value: n,
                        child: Text('$n'),
                      ),
                  ],
                  onChanged: (n) async {
                    if (n == null) return;
                    await persistProductivityStore(
                      ref,
                      (current) => setTodaySlotCount(current, n),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            key: const Key('productivity-carry-info'),
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text(Copy.productivityCarryForwardInfo),
            ),
          ),
        ],
      ),
    );
  }
}
