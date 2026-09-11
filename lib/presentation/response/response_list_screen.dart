import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/personal_response.dart';
import '../shared/ui_bits.dart';
import 'response_editor_screen.dart';

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
            primary: false,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Text(
                Copy.myResponseDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              for (final item in active) _tile(context, item),
              if (archived.isNotEmpty) ...[
                const SectionHeader('Archived'),
                for (final item in archived) _tile(context, item),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, PersonalResponse item) {
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
