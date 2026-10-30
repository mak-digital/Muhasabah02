import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../home/today_overview.dart';
import '../shared/app_language_scope.dart';
import '../shared/system_insets.dart';
import '../shared/ui_bits.dart';

/// Bottom-nav page for Check-in, Quick tap, and Quick select.
class InputScreen extends ConsumerWidget {
  const InputScreen({super.key});

  static const routeName = '/input';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(uiText(context, Copy.inputTitle))),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: Copy.inputTitle,
          message: 'Today’s input could not be prepared from stored records.',
        ),
        data: (records) {
          return ListView(
            key: const Key('input-scroll'),
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              contentBottomInset(context) + 16,
            ),
            children: [TodayOverview(records: records)],
          );
        },
      ),
    );
  }
}
