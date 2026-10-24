import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/hadith_archive.dart';
import '../../domain/reflection_source.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/quotation_cadence.dart';
import '../../domain/patterns_noticed.dart';
import '../../domain/personal_response.dart';
import '../../domain/weekly_calendar.dart';
import '../../domain/weekly_quotes.dart';
import '../response/response_editor_screen.dart';
import '../recorded_days/day_evidence_screen.dart';
import 'citation_reader_screen.dart';

Future<void> showReflectionSource(
  BuildContext context,
  WidgetRef ref,
  ReflectionQuote quote,
) {
  final canOpen = reflectionSourceUris(quote.source).isNotEmpty;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              quote.source,
              style: Theme.of(sheetContext).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text('${quote.sourceDetail}\n\n${Copy.reflectionSourceNote}'),
            const SizedBox(height: 12),
            if (canOpen)
              FilledButton(
                key: const Key('reflection-open-citation'),
                onPressed: () {
                  final pages = reflectionSourcePages(quote.source);
                  Navigator.pop(sheetContext);
                  if (!context.mounted) return;
                  if (pages.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(Copy.reflectionSourceCouldNotOpen),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ref.read(citationPageBuilderProvider)(
                        pages: pages,
                        title: quote.source,
                      ),
                    ),
                  );
                },
                child: const Text(Copy.openReflectionSource),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ReflectionOfTheWeekCard extends ConsumerWidget {
  const ReflectionOfTheWeekCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final cadence = prefs.quotationCadence;
    final now = ref.watch(nowProvider);
    final skipHadithKeys = archivedHadithCitationKeys(
      records: ref.watch(practiceHadithProvider).value ?? const [],
      archivedCatalogIds: prefs.archivedPracticeHadithCatalogIds,
    );
    final quote = quoteFor(
      now: now,
      cadence: cadence,
      holdPeriod: prefs.reflectionHoldPeriod,
      holdIndex: prefs.reflectionHoldIndex,
      skipHadithKeys: skipHadithKeys,
    );
    if (quote == null) return const SizedBox.shrink();
    final title = cadence == QuotationCadence.daily
        ? Copy.reflectionOfTheDay
        : Copy.reflectionOfTheWeek;
    final compactButtons = ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(32)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
    Future<void> step(int delta) async {
      final nextIndex = stepReflectionCatalogSkipping(
        reflectionCatalogIndex(quote),
        delta,
        skipHadithKeys: skipHadithKeys,
      );
      await prefs.setReflectionHold(
        period: reflectionPeriodKey(now, cadence),
        index: nextIndex,
      );
      ref.read(prefsTickProvider.notifier).state++;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('reflection-previous'),
                  tooltip: Copy.previousReflection,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () => step(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: const Key('reflection-next'),
                  tooltip: Copy.nextReflection,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () => step(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              quote.domain.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(quote.text),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('reflection-source-link'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () => showReflectionSource(context, ref, quote),
                child: Text(
                  quote.source,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('reflection-view-source'),
                    style: compactButtons,
                    onPressed: () => showReflectionSource(context, ref, quote),
                    child: const Text(
                      Copy.viewSource,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    key: const Key('reflection-save-response'),
                    style: compactButtons,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ResponseEditorScreen(
                            initialText: '${quote.text}\n\n— ${quote.source}',
                            provenance: ResponseProvenance(
                              originType:
                                  ProvenanceOrigin.weeklyReflectionQuote,
                              domain: quote.domain.name,
                              labelSnapshot: '$title · ${quote.source}',
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      Copy.saveQuoteToResponse,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class PatternEvidenceScreen extends StatelessWidget {
  const PatternEvidenceScreen({super.key, required this.pattern});

  final NoticedPattern pattern;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.viewEvidence)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(pattern.sentence),
          const SizedBox(height: 8),
          Text(
            'Dates where ${pattern.subjectLabel} was recorded as engagement. This list is evidence of records, not a cause or a score.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (final key in pattern.dateKeys)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(key),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DayEvidenceScreen(dateKey: key),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class WeeklyJournalCard extends ConsumerStatefulWidget {
  const WeeklyJournalCard({super.key});

  @override
  ConsumerState<WeeklyJournalCard> createState() => _WeeklyJournalCardState();
}

class _WeeklyJournalCardState extends ConsumerState<WeeklyJournalCard> {
  late final TextEditingController _controller;
  late String _weekKey = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final now = ref.watch(nowProvider);
    final firstDay = prefs.firstDayOfWeek.sundayBasedIndex(
      MaterialLocalizations.of(context).firstDayOfWeekIndex,
    );
    final weekKey = weekDateKeys(
      startOfWeek(now, firstDayOfWeekIndex: firstDay),
    ).first;
    if (_weekKey != weekKey) {
      _weekKey = weekKey;
      _controller.text = prefs.weeklyJournal(weekKey);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Copy.weeklyJournalTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              Copy.weeklyJournalNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Optional note for this week only.',
              ),
              onChanged: (value) async {
                await prefs.setWeeklyJournal(weekKey, value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
