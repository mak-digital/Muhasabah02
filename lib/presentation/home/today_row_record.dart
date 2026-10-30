import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/home_traces.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/quick_tap.dart';
import '../../domain/salah_extras.dart';
import '../../domain/today_workspace.dart';
import '../shared/activity_picker.dart';

DailyCheckIn _baseRecord(
  WidgetRef ref,
  String dateKey,
  DailyCheckIn? fallback,
) {
  final latest = ref.read(checkInsProvider).value;
  if (latest != null) {
    for (final item in latest) {
      if (item.dateKey == dateKey) return item;
    }
  }
  return fallback ?? DailyCheckIn.empty(dateKey);
}

Future<void> _save(WidgetRef ref, DailyCheckIn record) {
  return ref.read(checkInsProvider.notifier).save(record);
}

bool _showSwatches(WidgetRef ref, List<ActivityOption> options) {
  return activityPickerUsesColourSwatches(options) &&
      ref.read(appPrefsProvider).salahActivityColours;
}

/// Active Domain Today rows: one tap opens the full choice list under the row.
/// Dhikr performed-list detail stays on Quick Tap legend / Home week marks.
Future<void> showTodayRowRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required TodayRow row,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  switch (row.kind) {
    case TodayRowKind.homeTrace:
      final trace = homeTraceRowByKey(row.mixId);
      if (trace == null) return Future.value();
      return _showHomeTraceMenu(
        anchorContext: context,
        ref: ref,
        row: trace,
        domain: row.domain,
        dateKey: dateKey,
        record: record,
      );
    case TodayRowKind.zakatStatus:
      return _showZakatMenu(
        anchorContext: context,
        ref: ref,
        dateKey: dateKey,
        record: record,
      );
    case TodayRowKind.quran:
      for (final dimension in quranDailyDimensions) {
        if (row.mixId != 'quran.${dimension.name}') continue;
        return _showQuranActivityMenu(
          anchorContext: context,
          ref: ref,
          dimension: dimension,
          dateKey: dateKey,
          record: record,
        );
      }
      return Future.value();
    case TodayRowKind.salah:
      for (final salah in SalahTraceRow.values) {
        if (row.mixId != 'salah.${salah.name}') continue;
        final prayer = salah.prayerId;
        if (prayer != null) {
          return _showSalahActivityMenu(
            anchorContext: context,
            ref: ref,
            prayer: prayer,
            dateKey: dateKey,
            record: record,
          );
        }
        if (salah == SalahTraceRow.jumuah) {
          return _showJumuahMenu(
            anchorContext: context,
            ref: ref,
            dateKey: dateKey,
            record: record,
          );
        }
        return _showVoluntarySalahMenu(
          anchorContext: context,
          ref: ref,
          row: salah,
          dateKey: dateKey,
          record: record,
        );
      }
      return Future.value();
  }
}

Future<void> _showSalahActivityMenu({
  required BuildContext anchorContext,
  required WidgetRef ref,
  required PrayerId prayer,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final key = ActivityCatalog.salahKey(prayer);
  final current = _baseRecord(ref, dateKey, record);
  final selected = current.activityFor(key);
  final options = ActivityCatalog.obligatorySalahOptions(
    gender: ref.read(appPrefsProvider).worshipListGender,
    selectedId: selected.id,
  );
  return showAnchoredActivityMenu(
    anchorContext: anchorContext,
    options: options,
    selectedId: selected.id,
    statusKeyPrefix: 'today-salah-${prayer.name}',
    showColourSwatches: _showSwatches(ref, options),
    onSelected: (option) async {
      await _save(
        ref,
        current.withSalahActivity(prayer, RecordedActivity(id: option.id)),
      );
    },
  );
}

Future<void> _showQuranActivityMenu({
  required BuildContext anchorContext,
  required WidgetRef ref,
  required QuranDimension dimension,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final key = ActivityCatalog.quranKey(dimension);
  final current = _baseRecord(ref, dateKey, record);
  final selected = current.activityFor(key);
  final options = ActivityCatalog.forQuran(dimension);
  return showAnchoredActivityMenu(
    anchorContext: anchorContext,
    options: options,
    selectedId: selected.id,
    statusKeyPrefix: 'today-quran-${dimension.name}',
    showColourSwatches: _showSwatches(ref, options),
    onSelected: (option) async {
      await _save(
        ref,
        current.withQuranActivity(dimension, RecordedActivity(id: option.id)),
      );
    },
  );
}

Future<void> _showZakatMenu({
  required BuildContext anchorContext,
  required WidgetRef ref,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final current = _baseRecord(ref, dateKey, record);
  final options = ActivityCatalog.zakat;
  final selectedId = current.zakat == ZakatStatus.unanswered
      ? ActivityIds.unanswered
      : current.zakat.name;
  return showAnchoredActivityMenu(
    anchorContext: anchorContext,
    options: options,
    selectedId: selectedId,
    statusKeyPrefix: 'today-zakat',
    showColourSwatches: _showSwatches(ref, options),
    onSelected: (option) async {
      final status =
          option.zakat ??
          ZakatStatus.values.firstWhere(
            (value) => value.name == option.id,
            orElse: () => ZakatStatus.unanswered,
          );
      await _save(ref, current.copyWith(zakat: status));
    },
  );
}

Future<void> _showHomeTraceMenu({
  required BuildContext anchorContext,
  required WidgetRef ref,
  required HomeTraceRow row,
  required MonitorDomain domain,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final current = _baseRecord(ref, dateKey, record);
  var options = ActivityCatalog.forHomeTrace(row.storageKey);
  final selectedId = options.isNotEmpty
      ? current.activityFor(row.storageKey).id
      : current.homeTrace(row.storageKey).name;
  if (options.isEmpty) {
    options = [
      for (final outcome in TernaryOutcome.values)
        ActivityOption(
          id: outcome.name,
          label: traceOutcomeLabel(row.storageKey, outcome),
          ternary: outcome,
        ),
    ];
  }
  final item = QuickTapItem(
    id: row.storageKey,
    kind: QuickTapKind.trace,
    domain: domain,
    label: row.label,
    iconName: 'circle',
    traceKey: row.storageKey,
  );
  return showAnchoredActivityMenu(
    anchorContext: anchorContext,
    options: options,
    selectedId: selectedId,
    statusKeyPrefix: 'today-trace-${row.storageKey}',
    showColourSwatches: _showSwatches(ref, options),
    onSelected: (option) async {
      final next = applyQuickTapChoice(
        current,
        item,
        QuickTapChoice(
          id: option.id,
          label: option.label,
          mark: QuickTapMark.noticed,
        ),
      );
      await _save(ref, next);
    },
  );
}

Future<void> _showJumuahMenu({
  required BuildContext anchorContext,
  required WidgetRef ref,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final current = _baseRecord(ref, dateKey, record);
  final options = ActivityCatalog.jumuahOptions(
    gender: ref.read(appPrefsProvider).worshipListGender,
    selectedId: current.jumuahActivityId,
  );
  return showAnchoredActivityMenu(
    anchorContext: anchorContext,
    options: options,
    selectedId: current.jumuahActivityId,
    statusKeyPrefix: 'today-salah-jumuah',
    showColourSwatches: _showSwatches(ref, options),
    onSelected: (option) async {
      await _save(
        ref,
        current.withJumuahActivity(RecordedActivity(id: option.id)),
      );
    },
  );
}

Future<void> _showVoluntarySalahMenu({
  required BuildContext anchorContext,
  required WidgetRef ref,
  required SalahTraceRow row,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final current = _baseRecord(ref, dateKey, record);
  final selected = current.activityFor(ActivityCatalog.voluntarySalahKey(row));
  final options = ActivityCatalog.forVoluntarySalah(row);
  return showAnchoredActivityMenu(
    anchorContext: anchorContext,
    options: options,
    selectedId: selected.id,
    statusKeyPrefix: 'today-salah-${row.name}',
    showColourSwatches: _showSwatches(ref, options),
    onSelected: (option) async {
      await _save(
        ref,
        current.withVoluntarySalahActivity(
          row,
          RecordedActivity(id: option.id),
        ),
      );
    },
  );
}
