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
import '../shared/app_language_scope.dart';
import '../shared/domain_visual.dart';
import '../shared/ui_bits.dart';
import '../shared/progress_calendar.dart';
import 'quick_tap_sheet.dart';
import 'today_domain_workspace.dart';

enum TodayInputFolder { checkIn, quickTap, quickSelect }

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
        TodayInputFolders(workspace: workspace),
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
        child: BalancedProse(
          uiText(context, Copy.sampleDataNotice),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.35),
        ),
      ),
    );
  }
}

/// Folder-style Check-in / Quick tap / Quick select hub on Input.
class TodayInputFolders extends ConsumerStatefulWidget {
  const TodayInputFolders({super.key, required this.workspace});

  final TodayWorkspace workspace;

  @override
  ConsumerState<TodayInputFolders> createState() => TodayInputFoldersState();
}

class TodayInputFoldersState extends ConsumerState<TodayInputFolders> {
  TodayInputFolder _folder = TodayInputFolder.quickSelect;

  void selectFolder(TodayInputFolder folder) {
    final changed = _folder != folder;
    if (changed) setState(() => _folder = folder);
    if (!changed) {
      // Re-tap the active folder to re-open its focused input page.
      if (folder == TodayInputFolder.checkIn) {
        openTodaysCheckInFromHome(context, ref);
      } else if (folder == TodayInputFolder.quickTap) {
        showQuickTapSheet(context, ref);
      }
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (folder == TodayInputFolder.checkIn) {
        openTodaysCheckInFromHome(context, ref);
      } else if (folder == TodayInputFolder.quickTap) {
        showQuickTapSheet(context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final panel = Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.05),
      scheme.surface,
    );
    final mixNote = Copy.mixRowsRecorded(
      widget.workspace.recordedMixCount,
      widget.workspace.mixRowCount,
    );
    return Column(
      key: const Key('today-input-folders'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FolderTabStrip(
          selected: _folder,
          onSelect: selectFolder,
          panelColor: panel,
        ),
        Material(
          key: const Key('today-input-folder-panel'),
          color: panel,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            side: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.75),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: switch (_folder) {
              TodayInputFolder.checkIn => _CheckInFolderBody(
                onOpen: () => openTodaysCheckInFromHome(context, ref),
              ),
              TodayInputFolder.quickTap => _QuickTapFolderBody(
                onOpen: () => showQuickTapSheet(context, ref),
              ),
              TodayInputFolder.quickSelect => _QuickSelectFolderBody(
                workspace: widget.workspace,
                mixNote: mixNote,
              ),
            },
          ),
        ),
      ],
    );
  }
}

class _FolderTabStrip extends StatelessWidget {
  const _FolderTabStrip({
    required this.selected,
    required this.onSelect,
    required this.panelColor,
  });

  final TodayInputFolder selected;
  final ValueChanged<TodayInputFolder> onSelect;
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('today-entry-actions'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _FolderTab(
            tabKey: const Key('home-check-in'),
            folderKey: const Key('today-input-tab-check-in'),
            label: uiText(context, Copy.todayInputCheckInTab),
            icon: Icons.edit_calendar_outlined,
            selected: selected == TodayInputFolder.checkIn,
            panelColor: panelColor,
            onTap: () => onSelect(TodayInputFolder.checkIn),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _FolderTab(
            tabKey: const Key('home-quick-tap'),
            folderKey: const Key('today-input-tab-quick-tap'),
            label: uiText(context, Copy.todayInputQuickTapTab),
            icon: Icons.touch_app_outlined,
            selected: selected == TodayInputFolder.quickTap,
            panelColor: panelColor,
            onTap: () => onSelect(TodayInputFolder.quickTap),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _FolderTab(
            tabKey: const Key('home-quick-select'),
            folderKey: const Key('today-input-tab-quick-select'),
            label: uiText(context, Copy.todayInputQuickSelectTab),
            icon: Icons.grid_view_rounded,
            selected: selected == TodayInputFolder.quickSelect,
            panelColor: panelColor,
            onTap: () => onSelect(TodayInputFolder.quickSelect),
          ),
        ),
      ],
    );
  }
}

class _FolderTab extends StatelessWidget {
  const _FolderTab({
    required this.tabKey,
    required this.folderKey,
    required this.label,
    required this.icon,
    required this.selected,
    required this.panelColor,
    required this.onTap,
  });

  final Key tabKey;
  final Key folderKey;
  final String label;
  final IconData icon;
  final bool selected;
  final Color panelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    );
    final fill = selected
        ? panelColor
        : Color.alphaBlend(
            scheme.onSurface.withValues(alpha: 0.04),
            scheme.surface,
          );
    final ink = selected ? scheme.primary : scheme.onSurfaceVariant;
    final outline = selected
        ? scheme.outlineVariant.withValues(alpha: 0.75)
        : scheme.outlineVariant.withValues(alpha: 0.45);
    return Semantics(
      key: folderKey,
      button: true,
      selected: selected,
      label: label,
      child: Material(
        key: tabKey,
        color: fill,
        elevation: selected ? 0 : 0.5,
        shadowColor: scheme.shadow.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: outline),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: selected ? 44 : 38),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                8,
                selected ? 8 : 6,
                8,
                selected ? 10 : 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 15, color: ink),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        height: 1.1,
                        color: ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckInFolderBody extends StatelessWidget {
  const _CheckInFolderBody({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      key: const Key('today-input-body-check-in'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          uiText(context, Copy.checkInFolderHint),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const Key('today-input-open-check-in'),
          onPressed: onOpen,
          icon: const Icon(Icons.edit_calendar_outlined, size: 18),
          label: Text(uiText(context, Copy.homeCheckIn)),
        ),
      ],
    );
  }
}

class _QuickTapFolderBody extends StatelessWidget {
  const _QuickTapFolderBody({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      key: const Key('today-input-body-quick-tap'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          uiText(context, Copy.quickTapFolderHint),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          key: const Key('today-input-open-quick-tap'),
          onPressed: onOpen,
          icon: const Icon(Icons.touch_app_outlined, size: 18),
          label: Text(uiText(context, Copy.quickTapTitle)),
        ),
      ],
    );
  }
}

class _QuickSelectFolderBody extends ConsumerWidget {
  const _QuickSelectFolderBody({
    required this.workspace,
    required this.mixNote,
  });

  final TodayWorkspace workspace;
  final String mixNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (workspace.domains.isEmpty) {
      return BalancedProse(
        key: const Key('today-empty'),
        Copy.todayEmpty,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.4,
        ),
      );
    }
    return Column(
      key: const Key('today-active-domain-mix'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          mixNote,
          key: const Key('today-active-domain-mix-total'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.1,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          uiText(context, Copy.quickSelectHint),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: identity.familyFor(context),
                    ),
                  ),
                  Text(
                    '${Copy.mixRowsCount(item.recordedMixCount, item.mixRowCount)} · ${Copy.todayRecorded}',
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
            ),
          ],
        ),
      ),
    );
  }
}
