import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/check_in_screen.dart';
import '../shared/ui_bits.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int? _windowDays;

  @override
  Widget build(BuildContext context) {
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
                  refreshNowIfLocalDateChanged(ref);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CheckInScreen(date: ref.read(nowProvider)),
                    ),
                  );
                },
                child: const Text(Copy.homeCheckIn),
              ),
            );
          }
          ref.watch(prefsTickProvider);
          final now = ref.watch(nowProvider);
          final visible = _filtered(records, now);
          return ListView(
            primary: false,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              Text(
                Copy.historyGuard,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text(Copy.historyFilterAll),
                    selected: _windowDays == null,
                    onSelected: (_) => setState(() => _windowDays = null),
                  ),
                  FilterChip(
                    label: const Text('30 days'),
                    selected: _windowDays == 30,
                    onSelected: (_) => setState(() => _windowDays = 30),
                  ),
                  FilterChip(
                    label: const Text('90 days'),
                    selected: _windowDays == 90,
                    onSelected: (_) => setState(() => _windowDays = 90),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: EmptyState(
                    title: Copy.historyTitle,
                    message: Copy.historyEmptyFilter,
                  ),
                )
              else
                ..._weekGroupedTiles(context, visible),
            ],
          );
        },
      ),
    );
  }

  List<DailyCheckIn> _filtered(List<DailyCheckIn> records, DateTime now) {
    final days = _windowDays;
    if (days == null) return records;
    final allowed = periodDateKeys(days, now: now).toSet();
    return [
      for (final record in records)
        if (allowed.contains(record.dateKey)) record,
    ];
  }

  List<Widget> _weekGroupedTiles(
    BuildContext context,
    List<DailyCheckIn> records,
  ) {
    final calendar = ref.read(appPrefsProvider).displayCalendar;
    final firstDay = ref
        .read(appPrefsProvider)
        .firstDayOfWeek
        .sundayBasedIndex(
          MaterialLocalizations.of(context).firstDayOfWeekIndex,
        );
    final widgets = <Widget>[];
    String? lastWeekKey;
    var weekRows = <DailyCheckIn>[];

    void flushWeek(DateTime start) {
      if (weekRows.isEmpty) return;
      final rows = List<DailyCheckIn>.from(weekRows);
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            weekRangeLabel(start, calendar: calendar),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.4,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
      widgets.add(
        Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _HistoryDayRow(
                  record: rows[i],
                  calendar: calendar,
                  onEdit: () => _openEditor(rows[i]),
                  onRemove: () => _confirmRemove(rows[i]),
                  onMenu: () => _openSheet(rows[i], calendar),
                ),
              ],
            ],
          ),
        ),
      );
      weekRows = [];
    }

    DateTime? currentStart;
    for (final record in records) {
      final start = weekStartForKey(
        record.dateKey,
        firstDayOfWeekIndex: firstDay,
      );
      final weekKey = '${start.year}-${start.month}-${start.day}';
      if (weekKey != lastWeekKey) {
        if (currentStart != null) flushWeek(currentStart);
        lastWeekKey = weekKey;
        currentStart = start;
      }
      weekRows.add(record);
    }
    if (currentStart != null) flushWeek(currentStart);
    return widgets;
  }

  void _openEditor(DailyCheckIn record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckInScreen(date: parseDateKey(record.dateKey)),
      ),
    );
  }

  Future<void> _openSheet(DailyCheckIn record, DisplayCalendar calendar) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  formatStoredDateKey(record.dateKey, calendar),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pop(context, 'edit'),
                  child: const Text(Copy.historyEditCheckIn),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'remove'),
                  child: const Text(Copy.historyRemoveRecord),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    if (action == 'edit') _openEditor(record);
    if (action == 'remove') await _confirmRemove(record);
  }

  Future<void> _confirmRemove(DailyCheckIn record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Copy.historyRemoveTitle),
        content: Text('${Copy.historyRemoveBody} ${record.dateKey}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(Copy.historyKeep),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(Copy.historyRemove),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(checkInsProvider.notifier).delete(record.dateKey);
    }
  }
}

class _HistoryDayRow extends StatelessWidget {
  const _HistoryDayRow({
    required this.record,
    required this.calendar,
    required this.onEdit,
    required this.onRemove,
    required this.onMenu,
  });

  final DailyCheckIn record;
  final DisplayCalendar calendar;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final date = parseDateKey(record.dateKey);
    final localizations = MaterialLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final wash = MuhasabahColors.wash(
      MuhasabahColors.salahWash,
      MuhasabahColors.salahWashDark,
      brightness,
    );
    return InkWell(
      key: Key('history-day-${record.dateKey}'),
      onTap: onEdit,
      onLongPress: onRemove,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: wash,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations.narrowWeekdays[date.weekday % 7],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MuhasabahColors.salahFamily,
                    ),
                  ),
                  Text(
                    '${displayParts(date, calendar).day}',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700, height: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatStoredDateKey(record.dateKey, calendar),
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    Copy.historyTapToEdit,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (record.synthetic) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: MuhasabahColors.wash(
                    MuhasabahColors.sampleBannerWash,
                    MuhasabahColors.sampleBannerWashDark,
                    brightness,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  Copy.sampleRecordPill,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 4),
            ],
            IconButton(
              tooltip: Copy.historyDayMenu,
              onPressed: onMenu,
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}
