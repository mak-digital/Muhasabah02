import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/copy.dart';
import '../../domain/dhikr_context.dart';
import '../../domain/dhikr_source_registry.dart';
import '../../domain/practice_dhikr_catalog.dart';
import '../../domain/monitor_domain.dart';
import '../home/practice_hadith_home.dart';
import '../shared/domain_visual.dart';
import '../shared/system_insets.dart';

Future<void> openDhikrPracticeReference(
  BuildContext context, {
  required DhikrContextItem item,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => DhikrPracticeReferencePage(item: item),
    ),
  );
}

bool _hasArabic(DhikrSourceRecord? source, List<PracticeDhikrItem> practices) {
  if (source != null && source.arabic.isNotEmpty) return true;
  return practices.any((item) => item.arabic.isNotEmpty);
}

class DhikrPracticeReferencePage extends ConsumerWidget {
  const DhikrPracticeReferencePage({super.key, required this.item});

  final DhikrContextItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = item.sourceId == null
        ? null
        : dhikrSourceById[item.sourceId];
    final practices = dhikrPracticeReferencesFor(item);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Copy.practiceDhikrTitle),
        leading: IconButton(
          key: const Key('dhikr-practice-close'),
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: pageListPadding(context),
        children: [
          Text(item.label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Learn & Practice · ${dhikrPracticeSectionLabel(item.rowKey)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (_hasArabic(source, practices)) ...[
            PracticeArabicScriptBar(
              compact: true,
              faceKey: const Key('dhikr-practice-script-face'),
              smallerKey: const Key('dhikr-practice-script-smaller'),
              largerKey: const Key('dhikr-practice-script-larger'),
            ),
            const SizedBox(height: 8),
          ],
          if (practices.isEmpty && source != null) ...[
            PracticeRemembranceCore(
              contextText: '',
              arabic: source.arabic,
              transliteration: source.transliteration,
              translation: source.meaning,
              wash: domainColorIdentity(MonitorDomain.dhikr)
                  .washFor(Theme.of(context).brightness, context),
              showScriptControls: false,
            ),
            const SizedBox(height: 12),
            PracticeCitationLink(
              buttonKey: Key('dhikr-practice-citation-${item.id}'),
              domain: MonitorDomain.dhikr,
              text: source.meaning,
              source: source.citation,
              sourceDetail: source.occasion,
            ),
          ],
          for (final practice in practices) ...[
            Text(
              '${practice.group} · ${practice.subgroup}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(practice.topic, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            PracticeRemembranceCore(
              contextText: practice.text,
              arabic: practice.arabic,
              transliteration: practice.transliteration,
              translation: practice.translation,
              wash: domainColorIdentity(MonitorDomain.dhikr)
                  .washFor(Theme.of(context).brightness, context),
              showScriptControls: false,
            ),
            const SizedBox(height: 8),
            PracticeCitationLink(
              buttonKey: Key('dhikr-practice-citation-${practice.id}'),
              domain: MonitorDomain.dhikr,
              text: practice.text,
              source: practice.source,
              sourceDetail: practice.sourceDetail,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'This is not a target, score, or ruling. Close returns to the check-in you were recording.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
