import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../../domain/faq.dart';
import '../shared/app_language_scope.dart';
import '../shared/ui_bits.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = <(int, FaqEntry)>[];
    final notApplicable = <(int, FaqEntry)>[];
    for (var index = 0; index < faqEntries.length; index++) {
      final entry = faqEntries[index];
      if (entry.isCurrentVersion) {
        current.add((index, entry));
      } else {
        notApplicable.add((index, entry));
      }
    }
    FaqSection? lastSection;
    final children = <Widget>[
      BalancedProse(
        uiText(context, Copy.faqPurpose),
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      const SizedBox(height: 10),
      BalancedProse(
        uiText(context, Copy.faqNote),
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.45,
        ),
      ),
      const SizedBox(height: 16),
      BalancedProse(
        Copy.faqThisVersionHeading,
        title: true,
        style: theme.textTheme.titleMedium,
      ),
    ];
    for (final item in current) {
      final section = item.$2.section;
      if (section != null && section != lastSection) {
        children.add(const SizedBox(height: 14));
        children.add(
          BalancedProse(
            faqSectionTitle(section),
            title: true,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        children.add(const SizedBox(height: 6));
        lastSection = section;
      }
      children.add(_FaqCurrentCard(index: item.$1, entry: item.$2));
    }
    if (notApplicable.isNotEmpty) {
      children.add(const SizedBox(height: 20));
      children.add(
        BalancedProse(
          Copy.faqNotApplicableHeading,
          title: true,
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
      children.add(const SizedBox(height: 4));
      children.add(
        BalancedProse(
          Copy.faqNotApplicableNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      );
      children.add(const SizedBox(height: 8));
      for (final item in notApplicable) {
        children.add(_FaqNotApplicableCard(index: item.$1, entry: item.$2));
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.faqTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: children,
      ),
    );
  }
}

class _FaqCurrentCard extends StatelessWidget {
  const _FaqCurrentCard({required this.index, required this.entry});

  final int index;
  final FaqEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: ListTileTheme(
        data: ListTileThemeData(
          titleTextStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        child: ExpansionTile(
          title: BalancedProse(
            '${faqItemNumber(index)}. ${entry.question}',
            title: true,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              height: 1.3,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BalancedProse(
              entry.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
            if (entry.compare != null) ...[
              const SizedBox(height: 12),
              _FaqCompare(table: entry.compare!),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqNotApplicableCard extends StatelessWidget {
  const _FaqNotApplicableCard({required this.index, required this.entry});

  final int index;
  final FaqEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mutedTitle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.onSurfaceVariant,
    );
    final mutedBody = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.outline,
      fontWeight: FontWeight.w400,
    );
    return Opacity(
      opacity: 0.62,
      child: Card(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BalancedProse(
                '${faqItemNumber(index)}. ${entry.question}',
                title: true,
                style: mutedTitle?.copyWith(height: 1.3),
              ),
              const SizedBox(height: 4),
              BalancedProse(
                Copy.faqNotApplicableLabel,
                title: true,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              BalancedProse(
                entry.answer,
                style: mutedBody?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqCompare extends StatelessWidget {
  const _FaqCompare({required this.table});

  final FaqCompareTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final cellStyle = theme.textTheme.bodySmall;
    final headerStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.9),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.2),
      },
      border: TableBorder.all(
        color: theme.colorScheme.outlineVariant,
        width: 0.5,
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('', style: headerStyle),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: BalancedProse(
                table.leftHeader,
                title: true,
                style: headerStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: BalancedProse(
                table.rightHeader,
                title: true,
                style: headerStyle,
              ),
            ),
          ],
        ),
        for (final row in table.rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: BalancedProse(row.label, title: true, style: labelStyle),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: BalancedProse(row.left, title: true, style: cellStyle),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: BalancedProse(row.right, title: true, style: cellStyle),
              ),
            ],
          ),
      ],
    );
  }
}
