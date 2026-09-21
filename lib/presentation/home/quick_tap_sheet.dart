import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/quick_tap.dart';
import '../../domain/salah_extras.dart';
import '../shared/state_marker.dart';

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

Future<void> showQuickTapSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height * 0.88;
      return SizedBox(height: height, child: const QuickTapSheet());
    },
  );
}

class QuickTapSheet extends ConsumerWidget {
  const QuickTapSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final key = dateKey(now);
    final prefs = ref.watch(appPrefsProvider);
    final resolver = PersonalisationResolver(
      visibleDomains: prefs.visibleDomains,
      mix: prefs.personalMix,
    );
    final sections = quickTapSectionsFor(
      resolver.effectiveRowIds,
      friday: isFridayDateKey(key),
    );
    final records = ref.watch(checkInsProvider).value ?? const <DailyCheckIn>[];
    DailyCheckIn today = DailyCheckIn.empty(key);
    for (final record in records) {
      if (record.dateKey == key) {
        today = record;
        break;
      }
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(Copy.quickTapTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            Copy.quickTapNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
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
                      for (final section in sections) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              section.$1.shortLabel.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        SliverGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.78,
                          children: [
                            for (final item in section.$2)
                              _QuickTapTile(
                                item: item,
                                choice: readQuickTapChoice(
                                  today,
                                  item,
                                  history: records,
                                ),
                                often: _oftenHint(today, item, records),
                                onTap: () async {
                                  final next = nextQuickTapChoice(
                                    today,
                                    item,
                                    history: records,
                                  );
                                  await ref
                                      .read(checkInsProvider.notifier)
                                      .save(
                                        applyQuickTapChoice(today, item, next),
                                      );
                                },
                              ),
                          ],
                        ),
                      ],
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
    final (kind, fill) = switch (choice.mark) {
      QuickTapMark.unanswered => (MarkerKind.unanswered, scheme.surface),
      QuickTapMark.noticed => (
        MarkerKind.filled,
        MuhasabahColors.wash(
          MuhasabahColors.salahWash,
          MuhasabahColors.salahWashDark,
          theme.brightness,
        ),
      ),
      QuickTapMark.slip => (
        MarkerKind.missed,
        MuhasabahColors.missedEarth.withValues(alpha: 0.12),
      ),
    };
    final unanswered = choice.mark == QuickTapMark.unanswered;
    final caption = unanswered ? 'Not recorded' : choice.label;
    final oftenHint = often;
    return Semantics(
      button: true,
      label: '${item.label}. $caption',
      child: Material(
        key: Key('quick-tap-${item.id}'),
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_iconFor(item.iconName), color: scheme.primary),
                    const Spacer(),
                    RecordedStateMarker(
                      kind: kind,
                      semanticLabel: caption,
                      size: 18,
                    ),
                  ],
                ),
                const Spacer(),
                Text(item.label, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (oftenHint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    oftenHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ] else if (item.hint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.hint!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
