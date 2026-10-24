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
import '../../domain/today_workspace.dart';
import '../checkin/check_in_screen.dart';
import '../shared/domain_action_frame.dart';
import '../shared/domain_line_icon.dart';
import '../shared/domain_visual.dart';
import '../shared/progress_calendar.dart';
import 'quick_tap_sheet.dart';
import 'today_domain_workspace.dart';

class TodayOverview extends ConsumerWidget {
  const TodayOverview({super.key, required this.records});

  final List<DailyCheckIn> records;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider);
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final key = dateKey(now);
    DailyCheckIn? todayRecord;
    for (final record in records) {
      if (record.dateKey == key) {
        todayRecord = record;
        break;
      }
    }
    final workspace = deriveTodayWorkspace(
      dateKey: key,
      resolver: PersonalisationResolver(
        visibleDomains: prefs.visibleDomains,
        mix: prefs.personalMix,
      ),
      record: todayRecord,
    );
    final weekday = weekdayNameForDate(workspace.dateKey);
    final dateLine = formatDayMonthYear(now, prefs.displayCalendar);
    final theme = Theme.of(context);
    final showSampleNotice = records.any((record) => record.synthetic);
    return Column(
      key: const Key('today-overview'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Text.rich(
            key: const Key('today-weekday-date'),
            TextSpan(
              children: [
                TextSpan(
                  text: '${Copy.today} : ',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                TextSpan(
                  text: '$weekday, $dateLine',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showSampleNotice) ...[
          const _SampleDataNotice(),
          const SizedBox(height: 8),
        ],
        const TodayEntryActions(),
        const SizedBox(height: 12),
        if (workspace.domains.isEmpty)
          Text(
            Copy.todayEmpty,
            key: const Key('today-empty'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          )
        else
          _ActiveDomainMixPanel(workspace: workspace),
      ],
    );
  }
}

class _SampleDataNotice extends StatelessWidget {
  const _SampleDataNotice();

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('sample-data-notice'),
      color: MuhasabahColors.themeWash(
        context,
        MuhasabahColors.sampleBannerWash,
        MuhasabahColors.sampleBannerWashDark,
      ),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          Copy.sampleDataNotice,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.25),
        ),
      ),
    );
  }
}

class _ActiveDomainMixPanel extends ConsumerWidget {
  const _ActiveDomainMixPanel({required this.workspace});

  final TodayWorkspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mixNote = Copy.mixRowsRecorded(
      workspace.recordedMixCount,
      workspace.mixRowCount,
    );
    return Material(
      color: Color.alphaBlend(
        scheme.primary.withValues(alpha: 0.06),
        scheme.surface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const Key('today-active-domain-mix'),
          initiallyExpanded: false,
          dense: true,
          visualDensity: VisualDensity.compact,
          minTileHeight: 40,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  Copy.activeDomainAndMix,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: 0.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  mixNote,
                  key: const Key('today-active-domain-mix-total'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 8.0;
                final twoCol = constraints.maxWidth >= 340;
                final width = twoCol
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;
                return Wrap(
                  key: const Key('today-active-domain-mix-chips'),
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final item in workspace.domains)
                      SizedBox(
                        width: width,
                        child: _TodayDomainTile(item: item, ref: ref),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TodayEntryActions extends ConsumerWidget {
  const TodayEntryActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final checkInWash = Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.16),
      scheme.surface,
    );
    final quickTapWash = Color.alphaBlend(
      scheme.tertiary.withValues(alpha: 0.18),
      scheme.surface,
    );
    return Row(
      key: const Key('today-entry-actions'),
      children: [
        Expanded(
          child: _TodayEntryButton(
            buttonKey: const Key('home-check-in'),
            icon: Icons.edit_calendar_outlined,
            label: Copy.homeCheckIn,
            wash: checkInWash,
            ink: scheme.primary,
            onTap: () => openTodaysCheckInFromHome(context, ref),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TodayEntryButton(
            buttonKey: const Key('home-quick-tap'),
            icon: Icons.touch_app_outlined,
            label: Copy.quickTap,
            wash: quickTapWash,
            ink: scheme.tertiary,
            onTap: () => showQuickTapSheet(context, ref),
          ),
        ),
      ],
    );
  }
}

class _TodayEntryButton extends StatelessWidget {
  const _TodayEntryButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.wash,
    required this.ink,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final Color wash;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      key: buttonKey,
      color: wash,
      elevation: 1.5,
      shadowColor: ink.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: ink.withValues(alpha: 0.38), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: ink),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayDomainTile extends StatelessWidget {
  const _TodayDomainTile({required this.item, required this.ref});

  final TodayDomain item;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final identity = domainColorIdentity(item.domain);
    final brightness = Theme.of(context).brightness;
    final wash = identity.washFor(brightness, context);
    final label = todayDomainLabel(item.domain);
    final status = Copy.mixRowsRecorded(
      item.recordedMixCount,
      item.mixRowCount,
    );
    return DomainActionFrame(
      key: Key('today-domain-${item.domain.id}'),
      semanticLabel: '$label. $status',
      excludeChildSemantics: true,
      color: wash,
      railColor: identity.familyFor(context),
      onTap: () {
        refreshNowIfLocalDateChanged(ref);
        openTodayDomainWorkspace(context, item.domain);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: [
            DomainLineIcon(
              item.domain,
              size: 18,
              color: identity.familyFor(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: identity.familyFor(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Copy.mixRowsCount(item.recordedMixCount, item.mixRowCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: identity.familyFor(context),
                  ),
                ),
                Text(
                  Copy.todayRecorded,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: Color.alphaBlend(
                      identity.familyFor(context).withValues(alpha: 0.55),
                      Theme.of(context).colorScheme.onSurface,
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
}
