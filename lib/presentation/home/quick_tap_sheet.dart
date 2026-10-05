import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/quick_tap.dart';
import '../../domain/salah_extras.dart';
import '../shared/domain_action_frame.dart';
import '../shared/domain_visual.dart';
import '../shared/progress_calendar.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';
import '../shared/system_insets.dart';
import '../shared/week_nav_strip.dart';

IconData _iconFor(String name) => switch (name) {
  'wb_twilight' => Icons.wb_twilight,
  'menu_book' => Icons.menu_book_outlined,
  'self_improvement' => Icons.self_improvement,
  'call' => Icons.call_outlined,
  'volunteer_activism' => Icons.volunteer_activism_outlined,
  'favorite_outline' => Icons.favorite_border,
  'record_voice_over' => Icons.record_voice_over_outlined,
  _ => Icons.circle_outlined,
};

Future<void> showQuickTapSheet(BuildContext context, WidgetRef ref) {
  refreshNowIfLocalDateChanged(ref);
  final sessionDateKey = dateKey(ref.read(nowProvider));
  final systemBottom = presentingSystemBottom(context);
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
  });

  final String dateKey;
  final double systemBottom;

  @override
  ConsumerState<QuickTapSheet> createState() => _QuickTapSheetState();
}

class _QuickTapSheetState extends ConsumerState<QuickTapSheet> {
  final Set<String> _expandedDomainIds = {};
  bool _seededExpansion = false;
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
    if (sections.length == 1) {
      _expandedDomainIds.add(sections.single.$1.id);
    }
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
                  padding: const EdgeInsets.fromLTRB(10, 6, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          Copy.quickTapTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            fontSize: 16,
                            color: family,
                          ),
                        ),
                      ),
                      InkWell(
                        key: const Key('quick-tap-note-toggle'),
                        onTap: () => setState(() => _noteOpen = !_noteOpen),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Copy.quickTapNoteTitle,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  color: family,
                                ),
                              ),
                              Icon(
                                _noteOpen
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 18,
                                color: family,
                              ),
                            ],
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
          const SizedBox(height: 12),
          Expanded(
            child: sections.isEmpty
                ? Text(
                    Copy.quickTapEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      for (final section in sections)
                        SliverToBoxAdapter(
                          child: _QuickTapDomainPanel(
                            domain: section.$1,
                            items: section.$2,
                            today: day,
                            records: records,
                            expanded: _expandedDomainIds.contains(
                              section.$1.id,
                            ),
                            onToggle: () {
                              setState(() {
                                final id = section.$1.id;
                                if (!_expandedDomainIds.add(id)) {
                                  _expandedDomainIds.remove(id);
                                }
                              });
                            },
                            onTap: (item) async {
                              final next = nextQuickTapChoice(
                                day,
                                item,
                                history: records,
                              );
                              await ref.read(checkInsProvider.notifier).save(
                                applyQuickTapChoice(day, item, next),
                              );
                            },
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
  List<DailyCheckIn> records,
) {
  final current = readQuickTapChoice(today, item, history: records);
  if (current.mark != QuickTapMark.unanswered) return null;
  final next = nextQuickTapChoice(today, item, history: records);
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
    required this.domain,
    required this.items,
    required this.today,
    required this.records,
    required this.expanded,
    required this.onToggle,
    required this.onTap,
  });

  final MonitorDomain domain;
  final List<QuickTapItem> items;
  final DailyCheckIn today;
  final List<DailyCheckIn> records;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<QuickTapItem> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identity = domainColorIdentity(domain);
    final wash = identity.washFor(theme.brightness);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        key: Key('quick-tap-domain-${domain.id}'),
        color: wash,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              key: Key('quick-tap-domain-toggle-${domain.id}'),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        domain.shortLabel.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w800,
                          color: identity.family,
                        ),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: identity.family,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 8.0;
                    final width = (constraints.maxWidth - gap) / 2;
                    final height = width * 0.78;
                    return Wrap(
                      key: Key('quick-tap-domain-tiles-${domain.id}'),
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final item in items)
                          SizedBox(
                            width: width,
                            height: height,
                            child: _QuickTapTile(
                              item: item,
                              choice: readQuickTapChoice(
                                today,
                                item,
                                history: records,
                              ),
                              often: _oftenHint(today, item, records),
                              onTap: () => onTap(item),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
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
    final wash = identity.washFor(theme.brightness);
    final unanswered = choice.mark == QuickTapMark.unanswered;
    final fill = unanswered
        ? Color.alphaBlend(scheme.surface.withValues(alpha: 0.45), wash)
        : Color.alphaBlend(identity.family.withValues(alpha: 0.28), wash);
    final kind = switch (choice.mark) {
      QuickTapMark.unanswered => MarkerKind.unanswered,
      QuickTapMark.noticed => MarkerKind.filled,
      QuickTapMark.slip => MarkerKind.missed,
    };
    final markColor = _markColor(identity);
    final caption = unanswered ? 'Not recorded' : choice.label;
    final oftenHint = often;
    return DomainActionFrame(
      key: Key('quick-tap-${item.id}'),
      semanticLabel: '${item.label}. $caption',
      excludeChildSemantics: true,
      color: fill,
      radius: 14,
      outlined: true,
      minHeight: 44,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFor(item.iconName), size: 16, color: identity.family),
                const Spacer(),
                RecordedStateMarker(
                  color: markColor,
                  kind: kind,
                  semanticLabel: caption,
                  size: 14,
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: identity.family,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: unanswered ? scheme.onSurfaceVariant : markColor,
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

  Color _markColor(DomainColorIdentity identity) {
    if (choice.mark == QuickTapMark.unanswered) {
      return identity.family.withValues(alpha: 0.4);
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
      case QuickTapKind.trace:
        return choice.mark == QuickTapMark.slip
            ? MuhasabahColors.missedEarth
            : identity.family;
      case QuickTapKind.zakat:
        return identity.family;
    }
  }
}
