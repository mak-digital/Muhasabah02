import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/copy.dart';

class EvidenceBand extends StatelessWidget {
  const EvidenceBand({
    super.key,
    required this.title,
    required this.color,
    required this.children,
  });

  final String title;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 20,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.45,
                    ),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EvidenceRow extends StatelessWidget {
  const EvidenceRow({
    super.key,
    required this.name,
    required this.value,
    this.quiet = false,
    this.note,
  });

  final String name;
  final String value;
  final bool quiet;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = quiet
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: quiet ? FontWeight.w600 : FontWeight.w700,
            color: titleColor,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        if (note != null && note!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

class EvidenceGuard extends StatelessWidget {
  const EvidenceGuard(this.text, {super.key, this.sample = false});

  final String text;
  final bool sample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              height: 1.35,
            ),
          ),
          if (sample)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: MuhasabahColors.wash(
                  MuhasabahColors.sampleBannerWash,
                  MuhasabahColors.sampleBannerWashDark,
                  Theme.of(context).brightness,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                Copy.sampleRecordPill,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
