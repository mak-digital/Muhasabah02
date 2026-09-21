import 'activities.dart';
import 'copy.dart';
import 'daily_check_in.dart';
import 'home_traces.dart';
import 'monitor_domain.dart';
import 'other_domains.dart';
import 'personal_mix.dart';
import 'prayer.dart';
import 'quran.dart';
import 'salah_extras.dart';

enum QuickTapKind { salah, jumuah, voluntarySalah, quran, trace, zakat }

enum QuickTapMark { unanswered, noticed, slip }

class QuickTapChoice {
  const QuickTapChoice({
    required this.id,
    required this.label,
    required this.mark,
  });

  final String id;
  final String label;
  final QuickTapMark mark;
}

class QuickTapItem {
  const QuickTapItem({
    required this.id,
    required this.kind,
    required this.domain,
    required this.label,
    required this.iconName,
    this.hint,
    this.prayerId,
    this.dimension,
    this.traceKey,
  });

  final String id;
  final QuickTapKind kind;
  final MonitorDomain domain;
  final String label;
  final String iconName;
  final String? hint;
  final PrayerId? prayerId;
  final QuranDimension? dimension;
  final String? traceKey;
}

/// Busy-day tiles for mix rows on shown domains. Hajj standing status is
/// Settings, not a daily tap. Jumu‘ah is Friday only. Other (free text) is
/// skipped. Unticked stays unanswered.
List<QuickTapItem> quickTapItemsFor(
  Set<String> mixKeys, {
  bool friday = true,
}) {
  return [
    for (final mix in mixCatalog)
      if (mixKeys.contains(mix.id)) ?_itemForMix(mix, friday: friday),
  ];
}

List<(MonitorDomain, List<QuickTapItem>)> quickTapSectionsFor(
  Set<String> mixKeys, {
  bool friday = true,
}) {
  final items = quickTapItemsFor(mixKeys, friday: friday);
  final sections = <(MonitorDomain, List<QuickTapItem>)>[];
  for (final domain in MonitorDomain.values) {
    final chunk = [
      for (final item in items)
        if (item.domain == domain) item,
    ];
    if (chunk.isNotEmpty) sections.add((domain, chunk));
  }
  return sections;
}

QuickTapItem? _itemForMix(MixItem mix, {required bool friday}) {
  if (mix.id == kHajjMixKey) return null;
  if (mix.id == kZakatMixKey) {
    return QuickTapItem(
      id: mix.id,
      kind: QuickTapKind.zakat,
      domain: mix.domain,
      label: mix.label,
      iconName: _iconName(mix.domain),
    );
  }
  if (mix.domain == MonitorDomain.salah) {
    for (final row in SalahTraceRow.values) {
      if (mix.id != 'salah.${row.name}') continue;
      final prayer = row.prayerId;
      if (prayer != null) {
        return QuickTapItem(
          id: mix.id,
          kind: QuickTapKind.salah,
          domain: mix.domain,
          label: mix.label,
          iconName: _iconName(mix.domain),
          hint: prayer == PrayerId.fajr ? Copy.quickTapFajrHint : null,
          prayerId: prayer,
        );
      }
      if (row == SalahTraceRow.jumuah) {
        if (!friday) return null;
        return QuickTapItem(
          id: mix.id,
          kind: QuickTapKind.jumuah,
          domain: mix.domain,
          label: mix.label,
          iconName: _iconName(mix.domain),
          hint: 'Friday only. Other days stay blank, not unanswered.',
        );
      }
      return QuickTapItem(
        id: mix.id,
        kind: QuickTapKind.voluntarySalah,
        domain: mix.domain,
        label: mix.label,
        iconName: _iconName(mix.domain),
      );
    }
    return null;
  }
  if (mix.domain == MonitorDomain.quran) {
    for (final dimension in quranDailyDimensions) {
      if (mix.id != ActivityCatalog.quranKey(dimension)) continue;
      return QuickTapItem(
        id: mix.id,
        kind: QuickTapKind.quran,
        domain: mix.domain,
        label: mix.label,
        iconName: _iconName(mix.domain),
        dimension: dimension,
      );
    }
    return null;
  }
  if (homeTraceRowByKey(mix.id) == null) return null;
  return QuickTapItem(
    id: mix.id,
    kind: QuickTapKind.trace,
    domain: mix.domain,
    label: mix.label,
    iconName: _iconName(mix.domain),
    hint: mix.id.startsWith('dhikr.') ? 'Not a daily target.' : null,
    traceKey: mix.id,
  );
}

String _iconName(MonitorDomain domain) => switch (domain) {
  MonitorDomain.salah => 'wb_twilight',
  MonitorDomain.quran => 'menu_book',
  MonitorDomain.hadith => 'menu_book',
  MonitorDomain.dhikr => 'favorite_outline',
  MonitorDomain.akhlaq => 'self_improvement',
  MonitorDomain.huquq => 'call',
  MonitorDomain.knowledge => 'menu_book',
  MonitorDomain.time => 'wb_twilight',
  MonitorDomain.health => 'self_improvement',
  MonitorDomain.wealth => 'volunteer_activism',
  MonitorDomain.ummah => 'call',
  MonitorDomain.fasting => 'favorite_outline',
  MonitorDomain.hajj => 'self_improvement',
  MonitorDomain.charity => 'volunteer_activism',
};

List<QuickTapChoice> quickTapCatalog(QuickTapItem item) {
  switch (item.kind) {
    case QuickTapKind.salah:
      return [
        for (final option in ActivityCatalog.salah)
          if (!option.isOther) _fromActivity(option),
      ];
    case QuickTapKind.jumuah:
      return [
        for (final status in PrayerStatus.values)
          if (status != PrayerStatus.other) _fromPrayerStatus(status),
      ];
    case QuickTapKind.voluntarySalah:
      return [
        for (final outcome in TernaryOutcome.values)
          QuickTapChoice(
            id: outcome.name,
            label: voluntarySalahLabel(outcome),
            mark: switch (outcome) {
              TernaryOutcome.unanswered => QuickTapMark.unanswered,
              TernaryOutcome.positive => QuickTapMark.noticed,
              TernaryOutcome.negative => QuickTapMark.slip,
            },
          ),
      ];
    case QuickTapKind.quran:
      return [
        for (final option in ActivityCatalog.forQuran(item.dimension!))
          if (!option.isOther) _fromActivity(option),
      ];
    case QuickTapKind.trace:
      return [
        for (final outcome in TernaryOutcome.values)
          QuickTapChoice(
            id: outcome.name,
            label: traceOutcomeLabel(item.traceKey!, outcome),
            mark: switch (outcome) {
              TernaryOutcome.unanswered => QuickTapMark.unanswered,
              TernaryOutcome.positive => QuickTapMark.noticed,
              TernaryOutcome.negative => QuickTapMark.slip,
            },
          ),
      ];
    case QuickTapKind.zakat:
      return [
        for (final status in ZakatStatus.values)
          QuickTapChoice(
            id: status.name,
            label: status.label,
            mark: status == ZakatStatus.unanswered
                ? QuickTapMark.unanswered
                : QuickTapMark.noticed,
          ),
      ];
  }
}

/// Check-in options, Other omitted. Recorded choices are ordered by this
/// person's history (most frequent first), then catalog order. Unanswered
/// stays last so the stored default is empty until a tap.
List<QuickTapChoice> quickTapCycle(
  QuickTapItem item, {
  List<DailyCheckIn> history = const [],
  String? excludeDateKey,
}) {
  final catalog = quickTapCatalog(item);
  final recorded = [
    for (final choice in catalog)
      if (choice.mark != QuickTapMark.unanswered) choice,
  ];
  final unanswered = [
    for (final choice in catalog)
      if (choice.mark == QuickTapMark.unanswered) choice,
  ];
  final counts = quickTapHistoryCounts(
    item,
    history: history,
    excludeDateKey: excludeDateKey,
  );
  recorded.sort((a, b) {
    final freq = (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0);
    if (freq != 0) return freq;
    return catalog.indexOf(a).compareTo(catalog.indexOf(b));
  });
  return [...recorded, ...unanswered];
}

String readQuickTapChoiceId(DailyCheckIn record, QuickTapItem item) {
  switch (item.kind) {
    case QuickTapKind.salah:
      return record.activityFor(ActivityCatalog.salahKey(item.prayerId!)).id;
    case QuickTapKind.jumuah:
      return record.jumuah.name;
    case QuickTapKind.voluntarySalah:
      if (item.id == 'salah.tahajjud') return record.tahajjud.name;
      return record.ishraq.name;
    case QuickTapKind.quran:
      return record.activityFor(ActivityCatalog.quranKey(item.dimension!)).id;
    case QuickTapKind.trace:
      return record.homeTrace(item.traceKey!).name;
    case QuickTapKind.zakat:
      return record.zakat.name;
  }
}

QuickTapChoice readQuickTapChoice(
  DailyCheckIn record,
  QuickTapItem item, {
  List<DailyCheckIn> history = const [],
}) {
  final id = readQuickTapChoiceId(record, item);
  final cycle = quickTapCycle(
    item,
    history: history,
    excludeDateKey: record.dateKey,
  );
  for (final choice in cycle) {
    if (choice.id == id) return choice;
  }
  for (final choice in quickTapCatalog(item)) {
    if (choice.id == id) return choice;
  }
  return cycle.last;
}

Map<String, int> quickTapHistoryCounts(
  QuickTapItem item, {
  List<DailyCheckIn> history = const [],
  String? excludeDateKey,
}) {
  final counts = <String, int>{};
  for (final record in history) {
    if (record.dateKey == excludeDateKey) continue;
    final id = readQuickTapChoiceId(record, item);
    if (id == ActivityIds.unanswered || id == ActivityIds.other) continue;
    if (id == TernaryOutcome.unanswered.name) continue;
    counts[id] = (counts[id] ?? 0) + 1;
  }
  return counts;
}

QuickTapChoice nextQuickTapChoice(
  DailyCheckIn record,
  QuickTapItem item, {
  List<DailyCheckIn> history = const [],
}) {
  final cycle = quickTapCycle(
    item,
    history: history,
    excludeDateKey: record.dateKey,
  );
  final current = readQuickTapChoiceId(record, item);
  var index = cycle.indexWhere((choice) => choice.id == current);
  if (index < 0) index = cycle.length - 1;
  return cycle[(index + 1) % cycle.length];
}

DailyCheckIn applyQuickTapChoice(
  DailyCheckIn record,
  QuickTapItem item,
  QuickTapChoice choice,
) {
  switch (item.kind) {
    case QuickTapKind.salah:
      return record.withSalahActivity(
        item.prayerId!,
        RecordedActivity(id: choice.id),
      );
    case QuickTapKind.jumuah:
      final status = PrayerStatus.values.firstWhere(
        (value) => value.name == choice.id,
        orElse: () => PrayerStatus.unanswered,
      );
      return record.copyWith(jumuah: status);
    case QuickTapKind.voluntarySalah:
      final outcome = TernaryOutcome.values.firstWhere(
        (value) => value.name == choice.id,
        orElse: () => TernaryOutcome.unanswered,
      );
      if (item.id == 'salah.tahajjud') {
        return record.copyWith(tahajjud: outcome);
      }
      return record.copyWith(ishraq: outcome);
    case QuickTapKind.quran:
      return record.withQuranActivity(
        item.dimension!,
        RecordedActivity(id: choice.id),
      );
    case QuickTapKind.trace:
      final outcome = TernaryOutcome.values.firstWhere(
        (value) => value.name == choice.id,
        orElse: () => TernaryOutcome.unanswered,
      );
      return record.withHomeTrace(item.traceKey!, outcome);
    case QuickTapKind.zakat:
      final status = ZakatStatus.values.firstWhere(
        (value) => value.name == choice.id,
        orElse: () => ZakatStatus.unanswered,
      );
      return record.copyWith(zakat: status);
  }
}

QuickTapChoice _fromActivity(ActivityOption option) {
  return QuickTapChoice(
    id: option.id,
    label: option.label,
    mark: _markFor(option),
  );
}

QuickTapChoice _fromPrayerStatus(PrayerStatus status) {
  return QuickTapChoice(
    id: status.name,
    label: status.label,
    mark: switch (status) {
      PrayerStatus.unanswered => QuickTapMark.unanswered,
      PrayerStatus.missed => QuickTapMark.slip,
      _ => QuickTapMark.noticed,
    },
  );
}

QuickTapMark _markFor(ActivityOption option) {
  if (option.isUnanswered) return QuickTapMark.unanswered;
  if (option.prayerStatus == PrayerStatus.missed) return QuickTapMark.slip;
  if (option.ternary == TernaryOutcome.negative) return QuickTapMark.slip;
  if (option.dhikr == DhikrStatus.didNot) return QuickTapMark.slip;
  return QuickTapMark.noticed;
}
