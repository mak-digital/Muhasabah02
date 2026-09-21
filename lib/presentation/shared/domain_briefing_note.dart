import 'package:flutter/material.dart';

import '../../domain/domain_briefing.dart';

class DomainBriefingNote extends StatelessWidget {
  const DomainBriefingNote(this.briefing, {super.key, this.compact = false});

  final DomainBriefing briefing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium;
    final label = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final groupFill = theme.colorScheme.onSurface.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < briefing.lead.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Text(briefing.lead[i], style: body?.copyWith(height: 1.45)),
        ],
        if (briefing.examplesTitle != null) ...[
          const SizedBox(height: 10),
          Text(briefing.examplesTitle!, style: label),
        ],
        for (final group in briefing.groups) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: groupFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.title, style: label?.copyWith(color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 6),
                  _bullets(group.items, body),
                ],
              ),
            ),
          ),
        ],
        if (briefing.items.isNotEmpty) ...[
          const SizedBox(height: 8),
          _bullets(briefing.items, body),
        ],
        if (briefing.bounds.isNotEmpty) ...[
          const SizedBox(height: 8),
          _bullets(briefing.bounds, body),
        ],
        for (final line in briefing.closing) ...[
          const SizedBox(height: 8),
          Text(line, style: body?.copyWith(height: 1.45)),
        ],
      ],
    );
  }

  Widget _bullets(List<String> items, TextStyle? style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: style?.copyWith(height: 1.45)),
                Expanded(child: Text(items[i], style: style?.copyWith(height: 1.45))),
              ],
            ),
          ),
      ],
    );
  }
}
