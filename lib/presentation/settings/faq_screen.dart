import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../../domain/faq.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.faqTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(Copy.faqNote, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          for (var index = 0; index < faqEntries.length; index++)
            Card(
              child: ListTileTheme(
                data: ListTileThemeData(
                  titleTextStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                child: ExpansionTile(
                  title: Text(
                    '${faqItemNumber(index)}. ${faqEntries[index].question}',
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      faqEntries[index].answer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (faqEntries[index].compare != null) ...[
                      const SizedBox(height: 12),
                      _FaqCompare(table: faqEntries[index].compare!),
                    ],
                  ],
                ),
              ),
            ),
        ],
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
              child: Text(table.leftHeader, style: headerStyle),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(table.rightHeader, style: headerStyle),
            ),
          ],
        ),
        for (final row in table.rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(row.label, style: labelStyle),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(row.left, style: cellStyle),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(row.right, style: cellStyle),
              ),
            ],
          ),
      ],
    );
  }
}
