import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/context_catalog.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/home_traces.dart';
import '../../domain/personal_response.dart';
import '../../domain/quran.dart';
import '../../domain/salah_factors.dart';
import '../../domain/weekly_calendar.dart';
import '../checkin/check_in_screen.dart';
import '../recorded_days/day_evidence_screen.dart';
import '../shared/add_response_button.dart';
import '../shared/state_marker.dart';

class OptionalDomainHomeCard extends ConsumerStatefulWidget {
  const OptionalDomainHomeCard({
    super.key,
    required this.records,
    required this.title,
    required this.rows,
    required this.washLight,
    required this.washDark,
    required this.family,
    this.includeZakat = false,
    this.includeHadithFocus = false,
  });

  final List<DailyCheckIn> records;
  final String title;
  final List<HomeTraceRow> rows;
  final Color washLight;
  final Color washDark;
  final Color family;
  final bool includeZakat;
  final bool includeHadithFocus;

  @override
  ConsumerState<OptionalDomainHomeCard> createState() =>
      _OptionalDomainHomeCardState();
}

class _OptionalDomainHomeCardState
    extends ConsumerState<OptionalDomainHomeCard> {
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
    final wash = MuhasabahColors.wash(
      widget.washLight,
      widget.washDark,
      Theme.of(context).brightness,
    );
    final localizations = MaterialLocalizations.of(context);
    final bands = bandsFor(widget.rows);

    return Semantics(
      container: true,
      label: '${widget.title} week',
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
                            builder: (_) => const CheckInScreen(),
                          ),
                        );
                      },
                      child: Text(
                        widget.title,
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
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              for (final band in bands) ...[
                _band(
                  band: band,
                  rows: [
                    for (final row in widget.rows)
                      if (row.band == band) row,
                  ],
                  keys: keys,
                  index: index,
                ),
                const SizedBox(height: 6),
              ],
              if (widget.includeZakat) _zakatBand(keys: keys, index: index),
              if (widget.includeHadithFocus) _hadithFocus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hadithFocus() {
    final prefs = ref.watch(appPrefsProvider);
    final current = prefs.hadithMemorisationFocus;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.family.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Copy.hadithMemorisationFocus,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in HadithMemorisationFocus.values)
                    FilterChip(
                      label: Text(option.label),
                      selected: current == option,
                      onSelected: (_) async {
                        await prefs.setHadithMemorisationFocus(option);
                        ref.read(prefsTickProvider.notifier).state++;
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _band({
    required String band,
    required List<HomeTraceRow> rows,
    required List<String> keys,
    required Map<String, DailyCheckIn> index,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.family.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              band.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            for (final row in rows)
              Padding(
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
                      Expanded(
                        child: InkWell(
                          key: Key('home-${row.storageKey}-$key'),
                          onTap: () => _openTrace(row, key, index[key]),
                          child: Center(
                            child: RecordedStateMarker(
                              color: widget.family,
                              kind: markerForRecorded(
                                recorded:
                                    (index[key]?.homeTrace(row.storageKey) ??
                                            TernaryOutcome.unanswered)
                                        .isRecorded,
                                positive:
                                    (index[key]?.homeTrace(row.storageKey) ??
                                        TernaryOutcome.unanswered) ==
                                    TernaryOutcome.positive,
                              ),
                              semanticLabel:
                                  '$key ${row.label} ${(index[key]?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered).legendLabel}',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _zakatBand({
    required List<String> keys,
    required Map<String, DailyCheckIn> index,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.family.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ZAKAT STATUS',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 86,
                  child: Text(
                    'Zakat',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                for (final key in keys)
                  Expanded(
                    child: InkWell(
                      key: Key('home-zakat-$key'),
                      onTap: () => _openZakat(key, index[key]),
                      child: Center(
                        child: ZakatStateMarker(
                          status: index[key]?.zakat ?? ZakatStatus.unanswered,
                          color: widget.family,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTrace(
    HomeTraceRow row,
    String key,
    DailyCheckIn? record,
  ) async {
    var outcome =
        record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
    var factors =
        record?.homeTraceFactors[row.storageKey] ?? const SalahFactorCapture();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${row.label} · $key',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(Copy.seePonderExplore),
                    const SizedBox(height: 8),
                    const Text('What happened?'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final option in TernaryOutcome.values)
                          FilterChip(
                            label: Text(option.legendLabel),
                            selected: outcome == option,
                            onSelected: (_) async {
                              outcome = option;
                              setSheet(() {});
                              await _saveTrace(
                                key,
                                record,
                                row.storageKey,
                                option,
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(Copy.factorsYouNoticed),
                    Text(
                      'Optional. Stored. Never causes, completion, or scores.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Positive',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final factor in ContextCatalog.positive)
                          FilterChip(
                            label: Text(factor.label),
                            selected: factors.supportIds.contains(factor.id),
                            onSelected: (selected) async {
                              final ids = [...factors.supportIds];
                              if (selected) {
                                ids.add(factor.id);
                              } else {
                                ids.remove(factor.id);
                              }
                              factors = SalahFactorCapture(
                                supportIds: ids,
                                challengeIds: factors.challengeIds,
                                otherText: factors.otherText,
                              );
                              setSheet(() {});
                              await _saveFactors(
                                key,
                                record,
                                row.storageKey,
                                factors,
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Challenges',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final factor in ContextCatalog.negative)
                          FilterChip(
                            label: Text(factor.label),
                            selected: factors.challengeIds.contains(factor.id),
                            onSelected: (selected) async {
                              final ids = [...factors.challengeIds];
                              if (selected) {
                                ids.add(factor.id);
                              } else {
                                ids.remove(factor.id);
                              }
                              factors = SalahFactorCapture(
                                supportIds: factors.supportIds,
                                challengeIds: ids,
                                otherText: factors.otherText,
                              );
                              setSheet(() {});
                              await _saveFactors(
                                key,
                                record,
                                row.storageKey,
                                factors,
                              );
                            },
                          ),
                      ],
                    ),
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
                        domain: row.storageKey.split('.').first,
                        subject: row.storageKey,
                        dateKey: key,
                        evidenceId: '$key:${row.storageKey}',
                        labelSnapshot: '${row.label} on $key',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _saveFactors(
    String key,
    DailyCheckIn? record,
    String storageKey,
    SalahFactorCapture capture,
  ) async {
    final latest = ref.read(checkInsProvider).valueOrNull;
    DailyCheckIn? current = record;
    if (latest != null) {
      for (final item in latest) {
        if (item.dateKey == key) current = item;
      }
    }
    final base = current ?? DailyCheckIn.empty(key);
    await ref
        .read(checkInsProvider.notifier)
        .save(
          base
              .copyWith(savedAt: DateTime.now())
              .withHomeTraceFactors(storageKey, capture),
        );
  }

  Future<void> _saveTrace(
    String key,
    DailyCheckIn? record,
    String storageKey,
    TernaryOutcome outcome,
  ) async {
    final base = record ?? DailyCheckIn.empty(key);
    await ref
        .read(checkInsProvider.notifier)
        .save(
          base
              .copyWith(savedAt: DateTime.now())
              .withHomeTrace(storageKey, outcome),
        );
  }

  Future<void> _openZakat(String key, DailyCheckIn? record) async {
    var status = record?.zakat ?? ZakatStatus.unanswered;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Zakat · $key',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Zakat status is not a charity score.'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final option in ZakatStatus.values)
                        FilterChip(
                          label: Text(option.label),
                          selected: status == option,
                          onSelected: (_) async {
                            status = option;
                            setSheet(() {});
                            final base = record ?? DailyCheckIn.empty(key);
                            await ref
                                .read(checkInsProvider.notifier)
                                .save(
                                  base.copyWith(
                                    savedAt: DateTime.now(),
                                    zakat: option,
                                  ),
                                );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }
}
