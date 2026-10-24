import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/dhikr_context.dart';
import '../../domain/display_calendar.dart';
import '../../domain/home_traces.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/quick_tap.dart';
import '../../domain/salah_extras.dart';
import '../../domain/worship_list_gender.dart';
import '../checkin/trace_record_sheets.dart';
import '../shared/domain_action_frame.dart';
import '../shared/domain_line_icon.dart';
import '../shared/domain_visual.dart';
import '../shared/progress_calendar.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';
import '../shared/system_insets.dart';
import '../shared/week_nav_strip.dart';

Future<void> showQuickTapSheet(BuildContext context, WidgetRef ref) {
  refreshNowIfLocalDateChanged(ref);
  final sessionDateKey = dateKey(ref.read(nowProvider));
  final systemBottom = presentingSystemBottom(context);
  final prefs = ref.read(appPrefsProvider);
  final domains = PersonalisationResolver(
    visibleDomains: prefs.visibleDomains,
    mix: prefs.personalMix,
  ).homeDomains;
  final focused = domains.isEmpty
      ? null
      : domains[homeDomainStageIndex(
          domains,
          ref.read(homeDomainStageProvider),
        )];
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height * 0.88;
      return SizedBox(
        height: height,
        child: QuickTapSheet(
          dateKey: sessionDateKey,
          systemBottom: systemBottom,
          focusedDomain: focused,
        ),
      );
    },
  );
}

class QuickTapSheet extends ConsumerStatefulWidget {
  const QuickTapSheet({
    super.key,
    required this.dateKey,
    this.systemBottom = 0,
    this.focusedDomain,
  });

  final String dateKey;
  final double systemBottom;
  final MonitorDomain? focusedDomain;

  @override
  ConsumerState<QuickTapSheet> createState() => _QuickTapSheetState();
}

class _QuickTapSheetState extends ConsumerState<QuickTapSheet> {
  final Set<String> _expandedDomainIds = {};
  final GlobalKey _focusedPanelKey = GlobalKey();
  bool _seededExpansion = false;
  bool _scrolledToFocus = false;
  bool _noteOpen = false;
  late String _dateKey;

  @override
  void initState() {
    super.initState();
    _dateKey = widget.dateKey;
  }

  void _seedExpansion(List<(MonitorDomain, List<QuickTapItem>)> sections) {
    if (_seededExpansion) return;
    _seededExpansion = true;
    if (sections.isEmpty) return;
    if (sections.length == 1) {
      _expandedDomainIds.add(sections.single.$1.id);
      return;
    }
    final focused = widget.focusedDomain;
    if (focused == null) return;
    for (final section in sections) {
      if (section.$1 == focused) {
        _expandedDomainIds.add(focused.id);
        return;
      }
    }
  }

  void _scrollFocusedDomainIntoView() {
    if (_scrolledToFocus) return;
    _scrolledToFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _focusedPanelKey.currentContext;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.08,
        duration: Duration.zero,
      );
    });
  }

  void _shiftDay(int days) {
    final next = shiftDateKey(_dateKey, days);
    final todayKey = dateKey(ref.read(nowProvider));
    if (days > 0 && next.compareTo(todayKey) > 0) return;
    setState(() => _dateKey = next);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final key = _dateKey;
    final todayKey = dateKey(ref.watch(nowProvider));
    final prefs = ref.watch(appPrefsProvider);
    final resolver = PersonalisationResolver(
      visibleDomains: prefs.visibleDomains,
      mix: prefs.personalMix,
    );
    final sections = quickTapSectionsFor(
      resolver.effectiveRowIds,
      friday: isFridayDateKey(key),
    );
    _seedExpansion(sections);
    _scrollFocusedDomainIntoView();
    final records = ref.watch(checkInsProvider).value ?? const <DailyCheckIn>[];
    DailyCheckIn day = DailyCheckIn.empty(key);
    for (final record in records) {
      if (record.dateKey == key) {
        day = record;
        break;
      }
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final viewed = parseDateKey(key);
    final family = scheme.tertiary;
    final wash = Color.alphaBlend(
      family.withValues(alpha: 0.18),
      scheme.surface,
    );
    return Padding(
      padding: sheetContentPadding(context, systemBottom: widget.systemBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            key: const Key('quick-tap-header'),
            color: wash,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          Copy.quickTapTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            fontSize: 14,
                            color: family,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            key: const Key('quick-tap-note-toggle'),
                            onTap: () => setState(() => _noteOpen = !_noteOpen),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 32),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      Copy.quickTapNoteTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                            fontSize: 14,
                                            color: family,
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    _noteOpen
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 20,
                                    color: family,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                WeekNavStrip(
                  label: weekdayNameForDate(key),
                  subtitle: formatGregorianAndHijri(viewed),
                  family: family,
                  wash: wash,
                  paintBackground: false,
                  compact: true,
                  subtitleMaxLines: 1,
                  onPrevious: () => _shiftDay(-1),
                  onNext: () => _shiftDay(1),
                  nextEnabled: key.compareTo(todayKey) < 0,
                  previousTooltip: Copy.previousDay,
                  nextTooltip: Copy.nextDay,
                  previousKey: const Key('quick-tap-prev-day'),
                  nextKey: const Key('quick-tap-next-day'),
                  labelKey: const Key('quick-tap-day-label'),
                  maxLines: 1,
                ),
                if (_noteOpen)
                  Padding(
                    key: const Key('quick-tap-note'),
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                    child: Text(
                      Copy.quickTapNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: sections.isEmpty
                ? Text(
                    Copy.quickTapEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  )
                : ListView(
                    children: [
                      Material(
                        key: const Key('quick-tap-domain-group'),
                        color: scheme.surface,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < sections.length; i++)
                              _QuickTapDomainPanel(
                                key: sections[i].$1 == widget.focusedDomain
                                    ? _focusedPanelKey
                                    : null,
                                domain: sections[i].$1,
                                items: sections[i].$2,
                                today: day,
                                records: records,
                                gender: prefs.worshipListGender,
                                showDivider: i > 0,
                                expanded: _expandedDomainIds.contains(
                                  sections[i].$1.id,
                                ),
                                onToggle: () {
                                  setState(() {
                                    final id = sections[i].$1.id;
                                    if (_expandedDomainIds.contains(id)) {
                                      _expandedDomainIds.remove(id);
                                    } else {
                                      _expandedDomainIds
                                        ..clear()
                                        ..add(id);
                                    }
                                  });
                                },
                                onTap: (item) async {
                                  if (item.traceKey != null &&
                                      isDhikrContextTrace(item.traceKey!)) {
                                    final row = homeTraceRowByKey(
                                      item.traceKey!,
                                    );
                                    if (row != null) {
                                      await showHomeTraceRecordSheet(
                                        context: context,
                                        ref: ref,
                                        row: row,
                                        dateKey: key,
                                        record: day,
                                      );
                                      return;
                                    }
                                  }
                                  final next = nextQuickTapChoice(
                                    day,
                                    item,
                                    history: records,
                                    gender: ref
                                        .read(appPrefsProvider)
                                        .worshipListGender,
                                  );
                                  await ref
                                      .read(checkInsProvider.notifier)
                                      .save(
                                        applyQuickTapChoice(day, item, next),
                                      );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

String? _oftenHint(
  DailyCheckIn today,
  QuickTapItem item,
  List<DailyCheckIn> records, {
  required WorshipListGender gender,
}) {
  final current = readQuickTapChoice(
    today,
    item,
    history: records,
    gender: gender,
  );
  if (current.mark != QuickTapMark.unanswered) return null;
  final next = nextQuickTapChoice(
    today,
    item,
    history: records,
    gender: gender,
  );
  final counts = quickTapHistoryCounts(
    item,
    history: records,
    excludeDateKey: today.dateKey,
  );
  if ((counts[next.id] ?? 0) == 0) return null;
  return 'Often: ${next.label}';
}

class _QuickTapDomainPanel extends StatelessWidget {
  const _QuickTapDomainPanel({
    super.key,
    required this.domain,
    required this.items,
    required this.today,
    required this.records,
    required this.gender,
    required this.showDivider,
    required this.expanded,
    required this.onToggle,
    required this.onTap,
  });

  final MonitorDomain domain;
  final List<QuickTapItem> items;
  final DailyCheckIn today;
  final List<DailyCheckIn> records;
  final WorshipListGender gender;
  final bool showDivider;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<QuickTapItem> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final identity = domainColorIdentity(domain);
    final family = identity.familyFor(context);
    final panelWash = Color.alphaBlend(
      family.withValues(alpha: 0.08),
      scheme.surface,
    );
    return KeyedSubtree(
      key: Key('quick-tap-domain-${domain.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDivider) Divider(height: 1, color: scheme.outlineVariant),
          InkWell(
            key: Key('quick-tap-domain-toggle-${domain.id}'),
            onTap: onToggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  ColoredBox(
                    key: Key('quick-tap-domain-rail-${domain.id}'),
                    color: family,
                    child: const SizedBox(width: 4, height: 44),
                  ),
                  const SizedBox(width: 8),
                  DomainLineIcon(domain, size: 16, color: identity.family),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      domain.shortLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.1,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          if (expanded)
            ColoredBox(
              color: panelWash,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 6.0;
                    final width = (constraints.maxWidth - gap) / 2;
                    return Wrap(
                      key: Key('quick-tap-domain-tiles-${domain.id}'),
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final item in items)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: width,
                              maxWidth: width,
                              minHeight: 52,
                            ),
                            child: _QuickTapTile(
                              item: item,
                              choice: readQuickTapChoice(
                                today,
                                item,
                                history: records,
                                gender: gender,
                              ),
                              often: _oftenHint(
                                today,
                                item,
                                records,
                                gender: gender,
                              ),
                              onTap: () => onTap(item),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickTapTile extends StatelessWidget {
  const _QuickTapTile({
    required this.item,
    required this.choice,
    required this.often,
    required this.onTap,
  });

  final QuickTapItem item;
  final QuickTapChoice choice;
  final String? often;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final identity = domainColorIdentity(item.domain);
    final family = identity.familyFor(context);
    final wash = identity.washFor(theme.brightness, context);
    final unanswered = choice.mark == QuickTapMark.unanswered;
    final fill = unanswered
        ? Color.alphaBlend(scheme.surface.withValues(alpha: 0.45), wash)
        : Color.alphaBlend(family.withValues(alpha: 0.28), wash);
    final kind = switch (choice.mark) {
      QuickTapMark.unanswered => MarkerKind.unanswered,
      QuickTapMark.noticed => MarkerKind.filled,
      QuickTapMark.slip => MarkerKind.missed,
    };
    final markColor = _markColor(family);
    final caption = unanswered ? 'Not recorded' : choice.label;
    final oftenHint = often;
    return DomainActionFrame(
      key: Key('quick-tap-${item.id}'),
      semanticLabel: '${item.label}. $caption',
      excludeChildSemantics: true,
      color: fill,
      radius: 10,
      outlined: true,
      minHeight: 52,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    softWrap: true,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.2,
                      color: family,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                RecordedStateMarker(
                  color: markColor,
                  kind: kind,
                  semanticLabel: caption,
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              softWrap: true,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.2,
                color: unanswered
                    ? scheme.onSurfaceVariant
                    : MuhasabahColors.recordedLabel,
              ),
            ),
            if (oftenHint != null) ...[
              const SizedBox(height: 1),
              Text(
                oftenHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ] else if (item.hint != null) ...[
              const SizedBox(height: 1),
              Text(
                item.hint!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  height: 1.1,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _markColor(Color family) {
    if (choice.mark == QuickTapMark.unanswered) {
      return family.withValues(alpha: 0.4);
    }
    switch (item.kind) {
      case QuickTapKind.salah:
      case QuickTapKind.jumuah:
        return SalahActivityMark.colourForId(choice.id);
      case QuickTapKind.quran:
        return SalahActivityMark.colourForId(choice.id) == MuhasabahColors.mark
            ? MuhasabahColors.quran(item.dimension!)
            : SalahActivityMark.colourForId(choice.id);
      case QuickTapKind.voluntarySalah:
        return SalahActivityMark.colourForId(choice.id);
      case QuickTapKind.trace:
        final colour = SalahActivityMark.colourForId(choice.id);
        if (colour != MuhasabahColors.mark) return colour;
        return choice.mark == QuickTapMark.slip
            ? MuhasabahColors.missedEarth
            : family;
      case QuickTapKind.zakat:
        return family;
    }
  }
}
