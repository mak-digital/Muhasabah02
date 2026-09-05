import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/personal_response.dart';
import '../../domain/quran.dart';
import '../../domain/weekly_calendar.dart';
import '../progress/salah_progress_screen.dart';
import '../recorded_days/day_evidence_screen.dart';
import '../shared/add_response_button.dart';
import '../shared/state_marker.dart';

class QuranHomeCard extends ConsumerStatefulWidget {
  const QuranHomeCard({super.key, required this.records});

  final List<DailyCheckIn> records;

  @override
  ConsumerState<QuranHomeCard> createState() => _QuranHomeCardState();
}

class _QuranHomeCardState extends ConsumerState<QuranHomeCard> {
  var _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final firstDay = ref
        .read(appPrefsProvider)
        .firstDayOfWeek
        .sundayBasedIndex(
          MaterialLocalizations.of(context).firstDayOfWeekIndex,
        );
    final thisWeekStart = startOfWeek(now, firstDayOfWeekIndex: firstDay);
    final weekStart = addCalendarDays(thisWeekStart, _weekOffset * 7);
    final keys = weekDateKeys(weekStart);
    final index = {for (final record in widget.records) record.dateKey: record};
    final brightness = Theme.of(context).brightness;
    final wash = MuhasabahColors.wash(
      MuhasabahColors.quranWash,
      MuhasabahColors.quranWashDark,
      brightness,
    );
    final localizations = MaterialLocalizations.of(context);

    return Semantics(
      container: true,
      label: 'Qur’an week',
      child: Material(
        color: wash,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous week',
                    onPressed: () => setState(() => _weekOffset--),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const QuranProgressScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Qur’an',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next week',
                    onPressed: _weekOffset >= 0
                        ? null
                        : () => setState(() => _weekOffset++),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      weekRangeLabel(weekStart),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: _weekOffset == 0
                        ? null
                        : () => setState(() => _weekOffset = 0),
                    child: const Text(Copy.currentWeek),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 86),
                  for (var col = 0; col < kCalendarWeekdayCount; col++)
                    Expanded(
                      child: Text(
                        localizations.narrowWeekdays[(firstDay + col) % 7],
                        key: Key('quran-home-weekday-$col'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              dartWeekdayForRow(
                                    col,
                                    firstDayOfWeekIndex: firstDay,
                                  ) ==
                                  DateTime.friday
                              ? MuhasabahColors.quranFamily
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              _band(
                brightness: brightness,
                light: MuhasabahColors.quranRecitationBand,
                dark: MuhasabahColors.quranRecitationBandDark,
                label: 'Recitation',
                rows: recitationHomeRows,
                keys: keys,
                index: index,
              ),
              const SizedBox(height: 6),
              _band(
                brightness: brightness,
                light: MuhasabahColors.quranRetentionBand,
                dark: MuhasabahColors.quranRetentionBandDark,
                label: 'Retention',
                rows: retentionHomeRows,
                keys: keys,
                index: index,
              ),
              const SizedBox(height: 6),
              _band(
                brightness: brightness,
                light: MuhasabahColors.quranStudyBand,
                dark: MuhasabahColors.quranStudyBandDark,
                label: 'Study & notice',
                rows: studyNoticeHomeRows,
                keys: keys,
                index: index,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _band({
    required Brightness brightness,
    required Color light,
    required Color dark,
    required String label,
    required List<QuranDimension> rows,
    required List<String> keys,
    required Map<String, DailyCheckIn> index,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MuhasabahColors.wash(light, dark, brightness),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            for (final row in rows) _row(row, keys, index),
          ],
        ),
      ),
    );
  }

  Widget _row(
    QuranDimension row,
    List<String> keys,
    Map<String, DailyCheckIn> index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          for (final key in keys)
            Expanded(child: Center(child: _cell(row, key, index[key]))),
        ],
      ),
    );
  }

  Widget _cell(QuranDimension row, String key, DailyCheckIn? record) {
    final outcome = record?.quranOutcome(row) ?? TernaryOutcome.unanswered;
    final kind = markerForRecorded(
      recorded: outcome.isRecorded,
      positive: outcome == TernaryOutcome.positive,
    );
    return ProgressDayCell(
      onTap: () => _openCell(row, key, record),
      marker: RecordedStateMarker(
        key: Key('quran-home-${row.name}-$key'),
        color: MuhasabahColors.quranFamily,
        kind: kind,
        semanticLabel: '$key ${row.label} ${outcome.legendLabel}',
      ),
    );
  }

  void _openCell(QuranDimension row, String key, DailyCheckIn? record) {
    final outcome = record?.quranOutcome(row) ?? TernaryOutcome.unanswered;
    final polarity = outcome == TernaryOutcome.positive
        ? 'positive'
        : outcome == TernaryOutcome.negative
        ? 'negative'
        : null;
    final factors = polarity == null ? null : record?.contextFor(row, polarity);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${row.label} · $key',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(Copy.seePonderExplore),
              const SizedBox(height: 8),
              Text(outcome.legendLabel),
              if (row == QuranDimension.consciousApplication)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    Copy.consciousApplicationNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (factors != null &&
                  (factors.factorIds.isNotEmpty ||
                      (factors.freeText != null &&
                          factors.freeText!.trim().isNotEmpty))) ...[
                const SizedBox(height: 8),
                Text(
                  Copy.factorsYouNoticed,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  '${Copy.youRecorded} — never a cause.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DayEvidenceScreen(dateKey: key),
                    ),
                  );
                },
                child: const Text('Open recorded evidence'),
              ),
              AddResponseButton(
                provenance: ResponseProvenance(
                  originType: ProvenanceOrigin.progressDate,
                  domain: 'quran',
                  subject: row.name,
                  dateKey: key,
                  evidenceId: '$key:quran:${row.name}',
                  labelSnapshot: '${row.label} on $key',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
