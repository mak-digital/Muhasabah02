import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/factor_groups.dart';
import '../../domain/home_traces.dart';
import '../../domain/personal_response.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/salah_factors.dart';
import '../recorded_days/day_evidence_screen.dart';
import '../shared/activity_picker.dart';
import '../shared/add_response_button.dart';
import '../shared/system_insets.dart';

String _visibleDate(WidgetRef ref, String key) {
  return formatStoredDateKey(key, ref.read(appPrefsProvider).displayCalendar);
}

DailyCheckIn? _recordFor(WidgetRef ref, String key, DailyCheckIn? fallback) {
  final latest = ref.read(checkInsProvider).value;
  if (latest != null) {
    for (final item in latest) {
      if (item.dateKey == key) return item;
    }
  }
  return fallback;
}

Future<void> _save(WidgetRef ref, DailyCheckIn record) {
  return ref
      .read(checkInsProvider.notifier)
      .save(record.copyWith(savedAt: DateTime.now()));
}

void openDayEvidence(BuildContext context, String dateKey) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DayEvidenceScreen(dateKey: dateKey),
    ),
  );
}

VoidCallback? matrixCellOnTap({
  required WidgetRef ref,
  required String dateKey,
  VoidCallback? onOpen,
  VoidCallback? onPast,
  VoidCallback? onToday,
}) {
  if (onOpen == null && onPast == null && onToday == null) return null;
  return () {
    refreshNowIfLocalDateChanged(ref);
    switch (dateCellKind(dateKey, ref.read(nowProvider))) {
      case DateCellKind.future:
        return;
      case DateCellKind.today:
        (onToday ?? onOpen)?.call();
      case DateCellKind.past:
        (onPast ?? onOpen)?.call();
    }
  };
}

Future<void> showHomeTraceRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required HomeTraceRow row,
  required String dateKey,
  required DailyCheckIn? record,
  Key? dropdownKey,
}) async {
  var outcome = record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
  var factors =
      record?.homeTraceFactors[row.storageKey] ?? const SalahFactorCapture();
  final systemBottom = presentingSystemBottom(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
      return StatefulBuilder(
        builder: (context, setSheet) {
          return SafeArea(
            bottom: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Padding(
                padding: sheetContentPadding(
                  context,
                  systemBottom: systemBottom,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CheckInRowLabel(
                        '${row.label} · ${_visibleDate(ref, dateKey)}',
                      ),
                      const SizedBox(height: 4),
                      const Text(Copy.seePonderExplore),
                      const SizedBox(height: 8),
                      const CheckInRowLabel('What happened?'),
                      CheckInSelect<TernaryOutcome>(
                        dropdownKey: dropdownKey,
                        value: outcome,
                        sortLabels: false,
                        entries: [
                          for (final option in TernaryOutcome.values)
                            CheckInSelectEntry(
                              value: option,
                              label: traceOutcomeLabel(row.storageKey, option),
                            ),
                        ],
                        onChanged: (option) async {
                          outcome = option;
                          setSheet(() {});
                          final base =
                              _recordFor(ref, dateKey, record) ??
                              DailyCheckIn.empty(dateKey);
                          var next = base.withHomeTrace(row.storageKey, option);
                          if (!hidesHomeTraceFactors(row.storageKey)) {
                            final groups = factorGroupsForTernary(option);
                            factors = SalahFactorCapture(
                              supportIds: groups.showHelping
                                  ? factors.supportIds.take(1).toList()
                                  : const [],
                              challengeIds: groups.showDistracting
                                  ? factors.challengeIds.take(1).toList()
                                  : const [],
                              otherText: factors.otherText,
                            );
                            next = next.withHomeTraceFactors(
                              row.storageKey,
                              factors,
                            );
                          }
                          await _save(ref, next);
                        },
                      ),
                      if (!hidesHomeTraceFactors(row.storageKey))
                        CheckInFactorSelects(
                          groups: factorGroupsForTernary(outcome),
                          helping: NamedFactor.helpingForHomeTrace(
                            row.storageKey,
                            existingIds: factors.supportIds,
                          ),
                          distracting: NamedFactor.distractingForHomeTrace(
                            row.storageKey,
                            existingIds: factors.challengeIds,
                          ),
                          helpingId: selectedFactorId(factors.supportIds),
                          distractingId: selectedFactorId(factors.challengeIds),
                          onHelpingChanged: (id) async {
                            factors = SalahFactorCapture(
                              supportIds: idsFromFactorChoice(id),
                              challengeIds: factors.challengeIds
                                  .take(1)
                                  .toList(),
                              otherText: factors.otherText,
                            );
                            setSheet(() {});
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            await _save(
                              ref,
                              base.withHomeTraceFactors(
                                row.storageKey,
                                factors,
                              ),
                            );
                          },
                          onDistractingChanged: (id) async {
                            factors = SalahFactorCapture(
                              supportIds: factors.supportIds.take(1).toList(),
                              challengeIds: idsFromFactorChoice(id),
                              otherText: factors.otherText,
                            );
                            setSheet(() {});
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            await _save(
                              ref,
                              base.withHomeTraceFactors(
                                row.storageKey,
                                factors,
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          openDayEvidence(context, dateKey);
                        },
                        child: const Text('Open recorded evidence'),
                      ),
                      AddResponseButton(
                        provenance: ResponseProvenance(
                          originType: ProvenanceOrigin.progressDate,
                          domain: row.storageKey.split('.').first,
                          subject: row.storageKey,
                          dateKey: dateKey,
                          evidenceId: '$dateKey:${row.storageKey}',
                          labelSnapshot: '${row.label} on $dateKey',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showZakatRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String dateKey,
  required DailyCheckIn? record,
}) async {
  var status = record?.zakat ?? ZakatStatus.unanswered;
  final systemBottom = presentingSystemBottom(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel('Zakat · ${_visibleDate(ref, dateKey)}'),
                const SizedBox(height: 8),
                const Text('Zakat status is not a charity score.'),
                const SizedBox(height: 8),
                CheckInSelect<ZakatStatus>(
                  value: status,
                  entries: [
                    for (final option in ZakatStatus.values)
                      CheckInSelectEntry(value: option, label: option.label),
                  ],
                  onChanged: (option) async {
                    status = option;
                    setSheet(() {});
                    final base =
                        _recordFor(ref, dateKey, record) ??
                        DailyCheckIn.empty(dateKey);
                    await _save(ref, base.copyWith(zakat: option));
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> showPrayerRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PrayerId prayer,
  required String dateKey,
  required DailyCheckIn? record,
}) async {
  var status = record?.prayer(prayer) ?? PrayerStatus.unanswered;
  final systemBottom = presentingSystemBottom(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel(
                  '${prayer.label} · ${_visibleDate(ref, dateKey)}',
                ),
                const SizedBox(height: 4),
                const Text(Copy.seePonderExplore),
                const SizedBox(height: 8),
                const Text(
                  'Marks share one colour across domains. Colour does not rank spirituality.',
                ),
                const SizedBox(height: 8),
                CheckInSelect<PrayerStatus>(
                  value: status,
                  entries: [
                    for (final option in PrayerStatus.values)
                      CheckInSelectEntry(value: option, label: option.label),
                  ],
                  onChanged: (option) async {
                    status = option;
                    setSheet(() {});
                    final base =
                        _recordFor(ref, dateKey, record) ??
                        DailyCheckIn.empty(dateKey);
                    await _save(ref, base.withPrayer(prayer, option));
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openDayEvidence(context, dateKey);
                  },
                  child: const Text('Open recorded evidence'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> showQuranDimensionRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required QuranDimension dimension,
  required String dateKey,
  required DailyCheckIn? record,
}) async {
  var outcome = record?.quranOutcome(dimension) ?? TernaryOutcome.unanswered;
  final systemBottom = presentingSystemBottom(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel(
                  '${dimension.label} · ${_visibleDate(ref, dateKey)}',
                ),
                const SizedBox(height: 4),
                const Text(Copy.seePonderExplore),
                const SizedBox(height: 8),
                CheckInSelect<TernaryOutcome>(
                  value: outcome,
                  entries: [
                    for (final option in TernaryOutcome.values)
                      CheckInSelectEntry(
                        value: option,
                        label: option.legendLabel,
                      ),
                  ],
                  onChanged: (option) async {
                    outcome = option;
                    setSheet(() {});
                    final base =
                        _recordFor(ref, dateKey, record) ??
                        DailyCheckIn.empty(dateKey);
                    await _save(ref, base.withQuran(dimension, option));
                  },
                ),
                if (dimension == QuranDimension.consciousApplication)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      Copy.consciousApplicationNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openDayEvidence(context, dateKey);
                  },
                  child: const Text('Open recorded evidence'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
