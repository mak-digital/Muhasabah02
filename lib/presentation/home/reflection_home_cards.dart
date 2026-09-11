import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/patterns_noticed.dart';
import '../../domain/personal_response.dart';
import '../../domain/weekly_calendar.dart';
import '../../domain/weekly_quotes.dart';
import '../response/response_editor_screen.dart';
import '../recorded_days/day_evidence_screen.dart';

class ReflectionOfTheWeekCard extends ConsumerWidget {
  const ReflectionOfTheWeekCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final cadence = ref.watch(appPrefsProvider).quotationCadence;
    final quote = quoteFor(now: ref.watch(nowProvider), cadence: cadence);
    if (quote == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Copy.reflectionOfTheWeek,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              quote.domain.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(quote.text),
            const SizedBox(height: 8),
            Text(quote.source, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(Copy.viewSource),
                          content: Text(
                            '${quote.source}\n\n${quote.sourceDetail}\n\nThis quotation was chosen by calendar rotation. It is not based on what you recorded.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(Copy.viewSource),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ResponseEditorScreen(
                          initialText: '${quote.text}\n\n— ${quote.source}',
                          provenance: ResponseProvenance(
                            originType: ProvenanceOrigin.weeklyReflectionQuote,
                            domain: quote.domain.name,
                            labelSnapshot:
                                '${Copy.reflectionOfTheWeek} · ${quote.source}',
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(Copy.saveQuoteToResponse),
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
                    builder: (_) => DayEvidenceScreen(
                      dateKey: key,
                      limitToVisibleDomains: true,
                    ),
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
