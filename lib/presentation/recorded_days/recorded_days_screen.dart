import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/personal_response.dart';
import '../../domain/review_period.dart';
import '../../domain/weekly_calendar.dart';
import '../shared/add_response_button.dart';
import '../shared/ui_bits.dart';
import 'day_evidence_screen.dart';

class RecordedDaysScreen extends ConsumerWidget {
  const RecordedDaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reviewPeriodProvider);
    final now = ref.watch(nowProvider);
    final async = ref.watch(checkInsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.recordedDaysTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          title: Copy.recordedDaysTitle,
          message: 'Recorded days could not be listed.',
        ),
        data: (records) {
          final keys = periodDateKeys(period.days, now: now).reversed.toList();
          final present = {for (final record in records) record.dateKey};
          ref.watch(prefsTickProvider);
          final firstDay = ref
              .read(appPrefsProvider)
              .firstDayOfWeek
              .sundayBasedIndex(
                MaterialLocalizations.of(context).firstDayOfWeekIndex,
              );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${Copy.historicalReflectionTitle} is read-only. To edit a day, use Manage past check-ins.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              PeriodSelector(
                days: period.days,
                onChanged: (days) {
                  ref
                      .read(reviewPeriodProvider.notifier)
                      .state = switch (days) {
                    30 => ReviewPeriod.days30,
                    90 => ReviewPeriod.days90,
                    _ => ReviewPeriod.days7,
                  };
                },
              ),
              const SizedBox(height: 12),
              ..._groupedDayTiles(context, keys, present, firstDay),
              AddResponseButton(
                provenance: ResponseProvenance(
                  originType: ProvenanceOrigin.historicalReflection,
                  periodDays: period.days,
                  labelSnapshot: 'Recorded days (${period.shortLabel})',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _groupedDayTiles(
    BuildContext context,
    List<String> keys,
    Set<String> present,
    int firstDay,
  ) {
    final widgets = <Widget>[];
    String? lastWeekKey;
    for (final key in keys) {
      final start = weekStartForKey(key, firstDayOfWeekIndex: firstDay);
      final weekKey = '${start.year}-${start.month}-${start.day}';
      if (weekKey != lastWeekKey) {
        lastWeekKey = weekKey;
        widgets.add(SectionHeader(weekRangeLabel(start)));
      }
      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(key),
            subtitle: Text(
              present.contains(key) ? 'Check-in saved' : 'No check-in saved',
            ),
            enabled: present.contains(key),
            onTap: present.contains(key)
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => DayEvidenceScreen(dateKey: key),
                      ),
                    );
                  }
                : null,
          ),
        ),
      );
    }
    return widgets;
  }
}
