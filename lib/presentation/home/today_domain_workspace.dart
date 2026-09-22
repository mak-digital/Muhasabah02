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
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      contentBottomInset(context),
                    ),
                    itemCount: group.rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final row = group!.rows[index];
                      return _TodayWorkspaceRow(
                        row: row,
                        recorded: row.hasResponse,
                        onTap: () => showTodayRowRecordSheet(
                          context: context,
                          ref: ref,
                          row: row,
                          dateKey: key,
                          record: todayRecord,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TodayWorkspaceRow extends StatelessWidget {
  const _TodayWorkspaceRow({
    required this.row,
    required this.recorded,
    required this.onTap,
  });

  final TodayRow row;
  final bool recorded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = todayRowLabel(row);
    final caption = recorded ? Copy.todayRecorded : Copy.todayNoResponseYet;
    final identity = domainColorIdentity(row.domain);
    final spoken = recorded
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
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
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
                      kind: recorded ? MarkerKind.filled : MarkerKind.outlined,
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
