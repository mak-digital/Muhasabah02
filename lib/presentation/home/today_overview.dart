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
import '../shared/ui_bits.dart';

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
      hajjStatus: prefs.hajjStatus,
    );
    final weekday = weekdayNameForDate(workspace.dateKey);
    final dateLine = formatDayMonthYear(now, prefs.displayCalendar);
    final theme = Theme.of(context);
    return Column(
      key: const Key('today-overview'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(Copy.today),
        Text.rich(
          key: const Key('today-weekday-date'),
          TextSpan(
            children: [
              TextSpan(
                text: weekday,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: ' · $dateLine',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final twoCol = constraints.maxWidth >= 340;
              final width = twoCol
                  ? (constraints.maxWidth - gap) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final item in workspace.domains)
                    SizedBox(
                      width: width,
                      child: _TodayDomainTile(domain: item.domain),
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
  const _TodayDomainTile({required this.domain});

  final MonitorDomain domain;

  @override
  Widget build(BuildContext context) {
    final identity = domainColorIdentity(domain);
    final brightness = Theme.of(context).brightness;
    final wash = identity.washFor(brightness);
    final label = todayDomainLabel(domain);
    return Semantics(
      key: Key('today-domain-${domain.id}'),
      container: true,
      label: label,
      button: false,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: wash,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ColoredBox(
                      color: identity.family,
                      child: const SizedBox(width: 4),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
