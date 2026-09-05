import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/check_in_screen.dart';
import '../shared/ui_bits.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.historyTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: Copy.historyTitle,
          message: 'Past check-ins could not be listed.',
        ),
        data: (records) {
          if (records.isEmpty) {
            return EmptyState(
              title: Copy.historyTitle,
              message: 'No saved check-ins yet. You can start today’s check-in from Home.',
              action: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CheckInScreen(),
                    ),
                  );
                },
                child: const Text(Copy.homeCheckIn),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [..._weekGroupedTiles(context, ref, records)],
          );
        },
      ),
    );
  }

  List<Widget> _weekGroupedTiles(
    BuildContext context,
    WidgetRef ref,
    List<DailyCheckIn> records,
  ) {
    ref.watch(prefsTickProvider);
    final firstDay = ref
        .read(appPrefsProvider)
        .firstDayOfWeek
        .sundayBasedIndex(
          MaterialLocalizations.of(context).firstDayOfWeekIndex,
        );
    final widgets = <Widget>[];
    String? lastWeekKey;
    for (final record in records) {
      final start = weekStartForKey(
        record.dateKey,
        firstDayOfWeekIndex: firstDay,
      );
      final weekKey = '${start.year}-${start.month}-${start.day}';
      if (weekKey != lastWeekKey) {
        lastWeekKey = weekKey;
        widgets.add(SectionHeader(weekRangeLabel(start)));
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _tile(context, ref, record),
        ),
      );
    }
    return widgets;
  }

  Widget _tile(BuildContext context, WidgetRef ref, DailyCheckIn record) {
    return Card(
      child: ListTile(
        title: Text(record.dateKey),
        subtitle: Text(
          [
            '${record.answeredRecordableCount}/$kRecordableFieldCount recordable fields answered',
            if (record.synthetic) 'Sample/demo',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () {
          final parts = record.dateKey.split('-');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => CheckInScreen(date: date)),
          );
        },
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Remove this check-in?'),
              content: Text(
                'This removes the app-managed record for ${record.dateKey}. It does not claim forensic erasure.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Remove'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(checkInsProvider.notifier).delete(record.dateKey);
          }
        },
      ),
    );
  }
}
