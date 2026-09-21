import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/display_calendar.dart';
import '../../domain/quran_stage.dart';
import '../shared/progress_calendar.dart';
import '../shared/quran_stage_mark.dart';

Future<void> showQuranJourneySheet({
  required BuildContext context,
  required String dateKey,
  required DisplayCalendar calendar,
  required QuranJourneyRow row,
  DailyCheckIn? record,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _QuranJourneySheet(
        dateKey: dateKey,
        calendar: calendar,
        row: row,
        record: record ?? DailyCheckIn.empty(dateKey),
      );
    },
  );
}

class _QuranJourneySheet extends ConsumerStatefulWidget {
  const _QuranJourneySheet({
    required this.dateKey,
    required this.calendar,
    required this.row,
    required this.record,
  });

  final String dateKey;
  final DisplayCalendar calendar;
  final QuranJourneyRow row;
  final DailyCheckIn record;

  @override
  ConsumerState<_QuranJourneySheet> createState() => _QuranJourneySheetState();
}

class _QuranJourneySheetState extends ConsumerState<_QuranJourneySheet> {
  late QuranJourneyCellKind _l1;

  @override
  void initState() {
    super.initState();
    _l1 = quranJourneyCell(widget.record, widget.row).kind;
  }

  Future<void> _save(DailyCheckIn next) async {
    await ref.read(checkInsProvider.notifier).save(next);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final colours = ref.watch(appPrefsProvider).salahActivityColours;
    final current = quranJourneyCell(widget.record, widget.row);
    final showL2 = _l1 == QuranJourneyCellKind.recorded;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            weekdayNameForDate(widget.dateKey),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            formatStoredDateKey(widget.dateKey, widget.calendar),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.row.label} — ${widget.row.purpose}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            Copy.quranDayLevel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          _Choice(
            key: const Key('quran-journey-l1-unanswered'),
            selected: _l1 == QuranJourneyCellKind.unanswered,
            onTap: () =>
                _save(applyQuranJourneyUnanswered(widget.record, widget.row)),
            child: Row(
              children: [
                QuranJourneyMarker(
                  row: widget.row,
                  cell: const QuranJourneyCell(
                    kind: QuranJourneyCellKind.unanswered,
                  ),
                  colours: colours,
                  semanticLabel: Copy.quranDayUnanswered,
                ),
                const SizedBox(width: 12),
                const Text(Copy.quranDayUnanswered),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _Choice(
            // Historical key name; this is the recorded-group control, not an ordinal stage.
            key: const Key('quran-journey-l1-stage'),
            selected: _l1 == QuranJourneyCellKind.recorded,
            onTap: () => setState(() => _l1 = QuranJourneyCellKind.recorded),
            child: Row(
              children: [
                QuranJourneyMarker(
                  row: widget.row,
                  cell: const QuranJourneyCell(
                    kind: QuranJourneyCellKind.recorded,
                    code: null,
                  ),
                  colours: colours,
                  semanticLabel: widget.row.label,
                ),
                const SizedBox(width: 12),
                Text(widget.row.label),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _Choice(
            key: const Key('quran-journey-l1-none'),
            selected: _l1 == QuranJourneyCellKind.none,
            onTap: () =>
                _save(applyQuranJourneyNone(widget.record, widget.row)),
            child: Row(
              children: [
                QuranJourneyMarker(
                  row: widget.row,
                  cell: const QuranJourneyCell(kind: QuranJourneyCellKind.none),
                  colours: colours,
                  semanticLabel: Copy.quranDayNone,
                ),
                const SizedBox(width: 12),
                const Text(Copy.quranDayNone),
              ],
            ),
          ),
          if (showL2) ...[
            const SizedBox(height: 16),
            Text(
              Copy.quranDayActivity,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            for (final option in widget.row.l2Options) ...[
              _Choice(
                key: Key('quran-journey-l2-${option.code}'),
                selected: current.code == option.code,
                onTap: () => _save(
                  applyQuranJourneyL2(widget.record, widget.row, option),
                ),
                child: Row(
                  children: [
                    QuranJourneyMarker(
                      row: widget.row,
                      cell: QuranJourneyCell(
                        kind: QuranJourneyCellKind.recorded,
                        code: option.code,
                      ),
                      colours: colours,
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${option.code} = ${option.label}')),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
            _Choice(
              key: const Key('quran-journey-l2-none'),
              selected: current.kind == QuranJourneyCellKind.none,
              onTap: () =>
                  _save(applyQuranJourneyNone(widget.record, widget.row)),
              child: Row(
                children: [
                  QuranJourneyMarker(
                    row: widget.row,
                    cell: const QuranJourneyCell(
                      kind: QuranJourneyCellKind.none,
                    ),
                    colours: colours,
                    semanticLabel: Copy.quranDayNoActivity,
                  ),
                  const SizedBox(width: 12),
                  const Text(Copy.quranDayNoActivity),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _Choice(
              key: const Key('quran-journey-l2-unanswered'),
              selected: current.kind == QuranJourneyCellKind.unanswered,
              onTap: () =>
                  _save(applyQuranJourneyUnanswered(widget.record, widget.row)),
              child: Row(
                children: [
                  QuranJourneyMarker(
                    row: widget.row,
                    cell: const QuranJourneyCell(
                      kind: QuranJourneyCellKind.unanswered,
                    ),
                    colours: colours,
                    semanticLabel: Copy.quranDayUnanswered,
                  ),
                  const SizedBox(width: 12),
                  const Text(Copy.quranDayUnanswered),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
