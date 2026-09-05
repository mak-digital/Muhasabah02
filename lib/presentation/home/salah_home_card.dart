import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/personal_response.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/salah_extras.dart';
import '../../domain/salah_factors.dart';
import '../../domain/weekly_calendar.dart';
import '../progress/salah_progress_screen.dart';
import '../recorded_days/day_evidence_screen.dart';
import '../shared/add_response_button.dart';
import '../shared/state_marker.dart';

class SalahHomeCard extends ConsumerStatefulWidget {
  const SalahHomeCard({super.key, required this.records});

  final List<DailyCheckIn> records;

  @override
  ConsumerState<SalahHomeCard> createState() => _SalahHomeCardState();
}

class _SalahHomeCardState extends ConsumerState<SalahHomeCard> {
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
      MuhasabahColors.salahWash,
      MuhasabahColors.salahWashDark,
      brightness,
    );
    final localizations = MaterialLocalizations.of(context);

    return Semantics(
      container: true,
      label: 'Salah week',
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
                            builder: (_) => const SalahProgressScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Salah',
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
                  const SizedBox(width: 58),
                  for (var col = 0; col < kCalendarWeekdayCount; col++)
                    Expanded(
                      child: Text(
                        localizations.narrowWeekdays[(firstDay + col) % 7],
                        key: Key('salah-home-weekday-$col'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              dartWeekdayForRow(
                                    col,
                                    firstDayOfWeekIndex: firstDay,
                                  ) ==
                                  DateTime.friday
                              ? MuhasabahColors.salahFamily
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              _band(
                brightness: brightness,
                light: MuhasabahColors.salahObligatoryBand,
                dark: MuhasabahColors.salahObligatoryBandDark,
                label: 'Obligatory Salah',
                rows: obligatorySalahRows,
                keys: keys,
                index: index,
              ),
              const SizedBox(height: 6),
              _band(
                brightness: brightness,
                light: MuhasabahColors.salahFridayBand,
                dark: MuhasabahColors.salahFridayBandDark,
                label: 'Friday Prayer',
                rows: const [SalahTraceRow.jumuah],
                keys: keys,
                index: index,
              ),
              const SizedBox(height: 6),
              _band(
                brightness: brightness,
                light: MuhasabahColors.salahVoluntaryBand,
                dark: MuhasabahColors.salahVoluntaryBandDark,
                label: 'Voluntary Prayers',
                rows: const [SalahTraceRow.tahajjud, SalahTraceRow.ishraq],
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
    required List<SalahTraceRow> rows,
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
    SalahTraceRow row,
    List<String> keys,
    Map<String, DailyCheckIn> index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 58,
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

  Widget _cell(SalahTraceRow row, String key, DailyCheckIn? record) {
    final friday = isFridayDateKey(key);
    if (row.fridayOnly && !friday) {
      return SizedBox(
        key: Key('salah-home-${row.id}-$key'),
        width: AppDimensions.progressMarker,
        height: AppDimensions.progressMarker,
        child: Semantics(label: '${row.label} not applicable on $key'),
      );
    }
    return ProgressDayCell(
      onTap: () => _openCell(row, key, record),
      marker: _marker(row, key, record),
    );
  }

  Widget _marker(SalahTraceRow row, String key, DailyCheckIn? record) {
    final friday = isFridayDateKey(key);
    final showStar =
        row == SalahTraceRow.dhuhr &&
        friday &&
        (record?.jumuahCongregation ?? false);
    late final MarkerKind kind;
    late final Color color;
    late final String stateLabel;
    if (row.isVoluntary) {
      final outcome = row == SalahTraceRow.tahajjud
          ? (record?.tahajjud ?? TernaryOutcome.unanswered)
          : (record?.ishraq ?? TernaryOutcome.unanswered);
      kind = markerForRecorded(
        recorded: outcome.isRecorded,
        positive: outcome == TernaryOutcome.positive,
      );
      color = MuhasabahColors.salahFamily;
      stateLabel = voluntarySalahLabel(outcome);
    } else {
      final status = row == SalahTraceRow.jumuah
          ? (record?.jumuah ?? PrayerStatus.unanswered)
          : (record?.prayer(row.prayerId!) ?? PrayerStatus.unanswered);
      kind = switch (status) {
        PrayerStatus.onTime => MarkerKind.filled,
        PrayerStatus.late => MarkerKind.outlined,
        PrayerStatus.missed => MarkerKind.missed,
        PrayerStatus.unanswered => MarkerKind.unanswered,
      };
      color = status == PrayerStatus.missed
          ? MuhasabahColors.missedEarth
          : MuhasabahColors.salahFamily;
      stateLabel = status.label;
    }
    return RecordedStateMarker(
      key: Key('salah-home-${row.id}-$key'),
      color: color,
      kind: kind,
      symbol: showStar ? Icons.star : null,
      symbolColor: Colors.white,
      symbolSize: AppDimensions.progressMarkerStar,
      semanticLabel:
          '$key ${row.label} $stateLabel${showStar ? ' Friday congregation' : ''}',
    );
  }

  void _openCell(SalahTraceRow row, String key, DailyCheckIn? record) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final factors = record?.salahFactors[row.id];
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
              Text(_statusLine(row, record)),
              if (factors != null && !factors.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  Copy.youRecorded,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final id in factors.supportIds)
                      Chip(
                        label: Text(SalahFactorCatalog.find(id)?.label ?? id),
                      ),
                    for (final id in factors.challengeIds)
                      Chip(
                        label: Text(SalahFactorCatalog.find(id)?.label ?? id),
                      ),
                    if (factors.otherText != null)
                      Chip(label: Text(factors.otherText!)),
                  ],
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
                  domain: 'salah',
                  subject: row.id,
                  dateKey: key,
                  evidenceId: '$key:salah:${row.id}',
                  labelSnapshot: '${row.label} on $key',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLine(SalahTraceRow row, DailyCheckIn? record) {
    if (record == null) return 'No check-in saved. Unanswered is not missed.';
    if (row.isVoluntary) {
      final outcome = row == SalahTraceRow.tahajjud
          ? record.tahajjud
          : record.ishraq;
      return voluntarySalahLabel(outcome);
    }
    if (row == SalahTraceRow.jumuah) return record.jumuah.label;
    return record.prayer(row.prayerId!).label;
  }
}
