import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/display_calendar.dart';
import '../../domain/home_traces.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/salah_extras.dart';
import '../../domain/today_workspace.dart';
import '../checkin/trace_record_sheets.dart';
import '../shared/activity_picker.dart';
import '../shared/system_insets.dart';

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
      return showHomeTraceRecordSheet(
        context: context,
        ref: ref,
        row: trace,
        dateKey: dateKey,
        record: record,
        dropdownKey: Key('today-trace-${row.mixId}'),
      );
    case TodayRowKind.zakatStatus:
      return showZakatRecordSheet(
        context: context,
        ref: ref,
        dateKey: dateKey,
        record: record,
      );
    case TodayRowKind.quran:
      for (final dimension in quranDailyDimensions) {
        if (row.mixId != 'quran.${dimension.name}') continue;
        return _showQuranActivitySheet(
          context: context,
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
          return _showSalahActivitySheet(
            context: context,
            ref: ref,
            prayer: prayer,
            dateKey: dateKey,
            record: record,
          );
        }
        if (salah == SalahTraceRow.jumuah) {
          return _showJumuahSheet(
            context: context,
            ref: ref,
            dateKey: dateKey,
            record: record,
          );
        }
        return _showVoluntarySalahSheet(
          context: context,
          ref: ref,
          row: salah,
          dateKey: dateKey,
          record: record,
        );
      }
      return Future.value();
  }
}

Future<void> _showSalahActivitySheet({
  required BuildContext context,
  required WidgetRef ref,
  required PrayerId prayer,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final key = ActivityCatalog.salahKey(prayer);
  final systemBottom = presentingSystemBottom(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          final current = _baseRecord(ref, dateKey, record);
          final selected = current.activityFor(key);
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel(
                  '${prayer.label} · ${formatStoredDateKey(dateKey, ref.read(appPrefsProvider).displayCalendar)}',
                ),
                const SizedBox(height: 4),
                if (prayer == PrayerId.fajr) ...[
                  const Text(Copy.quickTapFajrHint),
                  const SizedBox(height: 8),
                ] else
                  const SizedBox(height: 8),
                ActivityPicker(
                  options: ActivityCatalog.salah,
                  selectedId: selected.id,
                  statusKeyPrefix: 'today-salah-${prayer.name}',
                  onSelected: (option) async {
                    await _save(
                      ref,
                      current.withSalahActivity(
                        prayer,
                        RecordedActivity(id: option.id),
                      ),
                    );
                    setSheet(() {});
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

Future<void> _showQuranActivitySheet({
  required BuildContext context,
  required WidgetRef ref,
  required QuranDimension dimension,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final key = ActivityCatalog.quranKey(dimension);
  final options = ActivityCatalog.forQuran(dimension);
  final systemBottom = presentingSystemBottom(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          final current = _baseRecord(ref, dateKey, record);
          final selected = current.activityFor(key);
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel(
                  '${dimension.label} · ${formatStoredDateKey(dateKey, ref.read(appPrefsProvider).displayCalendar)}',
                ),
                const SizedBox(height: 8),
                ActivityPicker(
                  options: options,
                  selectedId: selected.id,
                  statusKeyPrefix: 'today-quran-${dimension.name}',
                  onSelected: (option) async {
                    await _save(
                      ref,
                      current.withQuranActivity(
                        dimension,
                        RecordedActivity(id: option.id),
                      ),
                    );
                    setSheet(() {});
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

Future<void> _showJumuahSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final systemBottom = presentingSystemBottom(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          final current = _baseRecord(ref, dateKey, record);
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel(
                  'Jumu‘ah · ${formatStoredDateKey(dateKey, ref.read(appPrefsProvider).displayCalendar)}',
                ),
                const SizedBox(height: 8),
                CheckInSelect<PrayerStatus>(
                  dropdownKey: const Key('today-salah-jumuah'),
                  value: current.jumuah,
                  entries: [
                    for (final option in PrayerStatus.values)
                      CheckInSelectEntry(value: option, label: option.label),
                  ],
                  onChanged: (option) async {
                    await _save(ref, current.copyWith(jumuah: option));
                    setSheet(() {});
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

Future<void> _showVoluntarySalahSheet({
  required BuildContext context,
  required WidgetRef ref,
  required SalahTraceRow row,
  required String dateKey,
  required DailyCheckIn? record,
}) {
  final systemBottom = presentingSystemBottom(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          final current = _baseRecord(ref, dateKey, record);
          final outcome = row == SalahTraceRow.tahajjud
              ? current.tahajjud
              : current.ishraq;
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel(
                  '${row.label} · ${formatStoredDateKey(dateKey, ref.read(appPrefsProvider).displayCalendar)}',
                ),
                const SizedBox(height: 8),
                CheckInSelect<TernaryOutcome>(
                  dropdownKey: Key('today-salah-${row.name}'),
                  value: outcome,
                  sortLabels: false,
                  entries: [
                    for (final option in TernaryOutcome.values)
                      CheckInSelectEntry(
                        value: option,
                        label: voluntarySalahLabel(option),
                      ),
                  ],
                  onChanged: (option) async {
                    final next = row == SalahTraceRow.tahajjud
                        ? current.copyWith(tahajjud: option)
                        : current.copyWith(ishraq: option);
                    await _save(ref, next);
                    setSheet(() {});
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
