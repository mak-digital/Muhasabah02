import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personalisation_resolver.dart';
import '../../domain/today_workspace.dart';
import '../shared/domain_visual.dart';
import '../shared/progress_calendar.dart';
import '../shared/state_marker.dart';
import '../shared/system_insets.dart';
import 'today_row_record.dart';

void openTodayDomainWorkspace(BuildContext context, MonitorDomain domain) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TodayDomainWorkspacePage(domain: domain),
    ),
  );
}

class TodayDomainWorkspacePage extends ConsumerWidget {
  const TodayDomainWorkspacePage({super.key, required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider);
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final key = dateKey(now);
    final records = ref.watch(checkInsProvider).value ?? const <DailyCheckIn>[];
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
      hajjStatus: prefs.hajjStatus,
    );
    TodayDomain? group;
    for (final item in workspace.domains) {
      if (item.domain == domain) {
        group = item;
        break;
      }
    }
    final identity = domainColorIdentity(domain);
    final title = todayDomainLabel(domain);
    final weekday = weekdayNameForDate(workspace.dateKey);
    final dateLine = formatDayMonthYear(now, prefs.displayCalendar);
    final theme = Theme.of(context);
    final wash = identity.washFor(theme.brightness);
    return Scaffold(
      key: Key('today-workspace-${domain.id}'),
      appBar: AppBar(title: const SizedBox.shrink()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: wash,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  ColoredBox(
                    color: identity.family,
                    child: const SizedBox(width: 4, height: 36),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          namesRoute: true,
                          child: Text(
                            title,
                            key: Key('today-workspace-title-${domain.id}'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '$weekday · $dateLine',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: group == null || group.rows.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      Copy.todayDomainEmpty,
                      key: const Key('today-workspace-empty'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      contentBottomInset(context),
                    ),
                    children: _workspaceListChildren(
                      context: context,
                      ref: ref,
                      group: group,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _workspaceListChildren({
  required BuildContext context,
  required WidgetRef ref,
  required TodayDomain group,
}) {
  final noResponse = group.noResponseRows;
  final recorded = group.recordedRows;
  final children = <Widget>[];

  void addRow(TodayRow row, {required bool compact}) {
    children.add(
      _TodayWorkspaceRow(
        row: row,
        compact: compact,
        onTap: () {
          refreshNowIfLocalDateChanged(ref);
          final key = dateKey(ref.read(nowProvider));
          DailyCheckIn? record;
          for (final item
              in ref.read(checkInsProvider).value ?? const <DailyCheckIn>[]) {
            if (item.dateKey == key) {
              record = item;
              break;
            }
          }
          showTodayRowRecordSheet(
            context: context,
            ref: ref,
            row: row,
            dateKey: key,
            record: record,
          );
        },
      ),
    );
  }

  for (var i = 0; i < noResponse.length; i++) {
    if (i > 0) children.add(const SizedBox(height: 8));
    addRow(noResponse[i], compact: false);
  }

  if (recorded.isEmpty) return children;

  if (noResponse.isNotEmpty) children.add(const SizedBox(height: 16));
  final heading = noResponse.isEmpty
      ? Copy.todayRecordedForToday
      : Copy.todayRecordedToday;
  children.add(
    Padding(
      key: const Key('today-recorded-section'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        heading,
        key: const Key('today-recorded-heading'),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
  for (var i = 0; i < recorded.length; i++) {
    if (i > 0) children.add(const SizedBox(height: 6));
    addRow(recorded[i], compact: true);
  }
  return children;
}

class _TodayWorkspaceRow extends StatelessWidget {
  const _TodayWorkspaceRow({
    required this.row,
    required this.compact,
    required this.onTap,
  });

  final TodayRow row;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = todayRowLabel(row);
    final caption = compact ? Copy.todayRecorded : Copy.todayNoResponseYet;
    final identity = domainColorIdentity(row.domain);
    final spoken = compact
        ? '$label, response recorded'
        : '$label, no response yet';
    return Semantics(
      key: Key('today-row-${row.mixId}'),
      button: true,
      label: spoken,
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: compact ? 48 : 56),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: compact ? 8 : 10,
              ),
              child: compact
                  ? Row(
                      children: [
                        ExcludeSemantics(
                          child: RecordedStateMarker(
                            key: Key('today-row-marker-${row.mixId}'),
                            color: identity.family,
                            kind: MarkerKind.filled,
                            semanticLabel: caption,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          caption,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                caption,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ExcludeSemantics(
                          child: RecordedStateMarker(
                            key: Key('today-row-marker-${row.mixId}'),
                            color: identity.family,
                            kind: MarkerKind.outlined,
                            semanticLabel: caption,
                            size: 18,
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
