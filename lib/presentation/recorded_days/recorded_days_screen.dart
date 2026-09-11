import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/personal_response.dart';
import '../../domain/review_period.dart';
import '../../domain/weekly_calendar.dart';
import '../shared/add_response_button.dart';
import '../shared/ui_bits.dart';
import 'day_evidence_screen.dart';
import 'evidence_ui.dart';

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
          final keys = periodDateKeys(period.days, now: now);
          final present = {for (final record in records) record.dateKey};
          ref.watch(prefsTickProvider);
          final firstDay = ref
              .read(appPrefsProvider)
              .firstDayOfWeek
              .sundayBasedIndex(
                MaterialLocalizations.of(context).firstDayOfWeekIndex,
              );
          final calendar = ref.read(appPrefsProvider).displayCalendar;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const EvidenceGuard(Copy.recordedDaysGuard),
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
              const SizedBox(height: 10),
              _legend(context),
              ..._weekGrids(
                context,
                keys: keys,
                present: present,
                firstDay: firstDay,
                calendar: calendar,
              ),
              Text(
                Copy.recordedDaysEmptyNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              AddResponseButton(
                filled: true,
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

  Widget _legend(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: MuhasabahColors.salahFamily),
          const SizedBox(width: 4),
          Text(Copy.recordedDaysSavedLegend, style: muted),
          const SizedBox(width: 12),
          Icon(
            Icons.circle_outlined,
            size: 8,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(Copy.recordedDaysEmptyLegend, style: muted),
        ],
      ),
    );
  }

  List<Widget> _weekGrids(
    BuildContext context, {
    required List<String> keys,
    required Set<String> present,
    required int firstDay,
    required DisplayCalendar calendar,
  }) {
    final period = keys.toSet();
    final starts = <DateTime>[];
    for (final key in keys) {
      final start = weekStartForKey(key, firstDayOfWeekIndex: firstDay);
      if (starts.isEmpty || starts.last != start) starts.add(start);
    }
    final localizations = MaterialLocalizations.of(context);
    final widgets = <Widget>[];
    for (final start in starts.reversed) {
      final weekKeys = weekDateKeys(start);
      var saved = 0;
      var inPeriod = 0;
      for (final key in weekKeys) {
        if (!period.contains(key)) continue;
        inPeriod++;
        if (present.contains(key)) saved++;
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            '${weekRangeLabel(start, calendar: calendar)} · $saved of $inPeriod saved',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.4,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
      widgets.add(
        Row(
          children: [
            for (var col = 0; col < kCalendarWeekdayCount; col++)
              Expanded(
                child: Text(
                  localizations.narrowWeekdays[(firstDay + col) % 7],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 4));
      widgets.add(
        Row(
          children: [
            for (final key in weekKeys)
              Expanded(
                child: _dayCell(
                  context,
                  key: key,
                  inPeriod: period.contains(key),
                  saved: present.contains(key),
                  calendar: calendar,
                ),
              ),
          ],
        ),
      );
    }
    return widgets;
  }

  Widget _dayCell(
    BuildContext context, {
    required String key,
    required bool inPeriod,
    required bool saved,
    required DisplayCalendar calendar,
  }) {
    if (!inPeriod) {
      return const SizedBox(height: 56);
    }
    final day = displayParts(parseDateKey(key), calendar).day;
    final brightness = Theme.of(context).brightness;
    final wash = MuhasabahColors.wash(
      MuhasabahColors.salahWash,
      MuhasabahColors.salahWashDark,
      brightness,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: saved ? wash : Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: saved
                ? wash
                : Theme.of(context).dividerColor.withValues(alpha: 0.7),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('recorded-day-$key'),
          onTap: saved
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DayEvidenceScreen(dateKey: key),
                    ),
                  );
                }
              : null,
          child: SizedBox(
            height: 56,
            child: Opacity(
              opacity: saved ? 1 : 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    saved ? Copy.recordedDaysSaved : '—',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
