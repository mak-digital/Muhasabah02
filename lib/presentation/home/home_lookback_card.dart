import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/date_key.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/noticed_this_week.dart';
import '../../domain/patterns_noticed.dart';
import '../../domain/review_period.dart';
import '../../domain/weekly_calendar.dart';
import '../shared/domain_wash.dart';
import 'reflection_home_cards.dart';

class HomeLookbackCard extends ConsumerWidget {
  const HomeLookbackCard({
    super.key,
    required this.records,
    required this.onOpenReview,
  });

  final List<DailyCheckIn> records;
  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final now = ref.watch(nowProvider);
    final period = ref.watch(reviewPeriodProvider);
    final prefs = ref.read(appPrefsProvider);
    final firstDay = prefs.firstDayOfWeek.sundayBasedIndex(
      MaterialLocalizations.of(context).firstDayOfWeekIndex,
    );
    final weekKeys = weekDateKeys(
      startOfWeek(now, firstDayOfWeekIndex: firstDay),
    );
    final lines = noticedThisWeek(
      records: records,
      weekKeys: weekKeys,
      visibleDomains: prefs.visibleDomains,
      mix: prefs.personalMix,
    );
    final patterns = noticedPatterns(
      records: records,
      now: now,
      visibleDomains: prefs.visibleDomains,
      mix: prefs.personalMix,
    );
    final saved = {for (final record in records) record.dateKey};
    final showWeekStrip = period == ReviewPeriod.days7;
    final periodKeys = showWeekStrip
        ? periodDateKeys(period.days, now: now)
        : const <String>[];
    final brightness = Theme.of(context).brightness;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Material(
      key: const Key('home-lookback'),
      color: MuhasabahColors.wash(
        MuhasabahColors.summaryWash,
        MuhasabahColors.summaryWashDark,
        brightness,
      ),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  Copy.thisWeekLookback,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Copy.lookbackPresenceNote,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _moduleLabel(context, Copy.lookbackRecordedDays),
            _RecordedDaysRow(
              period: period,
              keys: periodKeys,
              saved: saved,
              onOpenReview: onOpenReview,
            ),
            if (lines.isEmpty && patterns.isEmpty) ...[
              const SizedBox(height: 8),
              Text(Copy.lookbackEmpty, style: muted),
            ] else ...[
              if (lines.isNotEmpty) ...[
                const SizedBox(height: 10),
                _moduleLabel(context, Copy.lookbackNoticed),
                for (var i = 0; i < lines.length; i++)
                  _NoticedRow(line: lines[i], index: i),
              ],
              if (patterns.isNotEmpty) ...[
                const SizedBox(height: 10),
                _moduleLabel(context, Copy.lookbackPatterns),
                for (var i = 0; i < patterns.length; i++)
                  _PatternRow(
                    pattern: patterns[i],
                    index: i,
                    firstDayOfWeekIndex: firstDay,
                  ),
              ],
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _moduleLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _RecordedDaysRow extends StatelessWidget {
  const _RecordedDaysRow({
    required this.period,
    required this.keys,
    required this.saved,
    required this.onOpenReview,
  });

  final ReviewPeriod period;
  final List<String> keys;
  final Set<String> saved;
  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: Copy.lookbackRecordedDaysNote,
      child: InkWell(
        key: const Key('home-lookback-recorded'),
        onTap: onOpenReview,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: keys.isEmpty
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          for (final key in keys) ...[
                            _PresenceDot(
                              recorded: saved.contains(key),
                              size: 9,
                            ),
                            const SizedBox(width: 5),
                          ],
                        ],
                      ),
              ),
              Text(
                period.shortLabel,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticedRow extends StatelessWidget {
  const _NoticedRow({required this.line, required this.index});

  final NoticedLine line;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key('home-lookback-noticed-$index'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        label: line.sentence,
        child: Row(
          children: [
            Expanded(
              child: Text(
                line.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                for (final on in line.engagementByDay) ...[
                  _PresenceDot(recorded: on, size: 7),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternRow extends StatelessWidget {
  const _PatternRow({
    required this.pattern,
    required this.index,
    required this.firstDayOfWeekIndex,
  });

  final NoticedPattern pattern;
  final int index;
  final int firstDayOfWeekIndex;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final wash = pattern.domain == null
        ? MuhasabahColors.summaryWash
        : domainWashColor(context, pattern.domain!);
    return InkWell(
      key: Key('home-lookback-pattern-$index'),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PatternEvidenceScreen(pattern: pattern),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Semantics(
          button: true,
          label: pattern.sentence,
          child: Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: wash,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pattern.subjectLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    _WeekdayCell(
                      letter: localizations
                          .narrowWeekdays[(firstDayOfWeekIndex + col) % 7],
                      highlighted: pattern.highlightedWeekdays.contains(
                        _dartWeekday((firstDayOfWeekIndex + col) % 7),
                      ),
                    ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _dartWeekday(int sundayBased) =>
      sundayBased == 0 ? DateTime.sunday : sundayBased;
}

class _WeekdayCell extends StatelessWidget {
  const _WeekdayCell({required this.letter, required this.highlighted});

  final String letter;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = SizedBox(
      width: 18,
      height: 18,
      child: Center(
        child: Text(
          letter,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            color: highlighted
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
    if (!highlighted) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MuhasabahColors.wash(
          MuhasabahColors.todayMarkWash,
          MuhasabahColors.todayMarkWashDark,
          theme.brightness,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

class _PresenceDot extends StatelessWidget {
  const _PresenceDot({required this.recorded, required this.size});

  final bool recorded;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = MuhasabahColors.mark;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: recorded ? color : null,
            border: recorded
                ? null
                : Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          ),
        ),
      ),
    );
  }
}
