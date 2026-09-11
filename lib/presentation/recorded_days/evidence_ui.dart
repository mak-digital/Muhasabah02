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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.w700),
              ),
              ...children,
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
    final color = quiet
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: quiet ? FontWeight.w400 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
          if (note != null && note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                note!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EvidenceGuard extends StatelessWidget {
  const EvidenceGuard(this.text, {super.key, this.sample = false});

  final String text;
  final bool sample;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (sample)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.3),
              ),
            ),
        ],
      ),
    );
  }
}
