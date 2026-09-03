import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/copy.dart';
import '../../domain/dashboard_summary.dart';

class DashboardDomainCard extends StatelessWidget {
  const DashboardDomainCard({
    super.key,
    required this.model,
    required this.color,
    required this.onTap,
  });

  final DomainCardModel model;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Semantics(
      button: true,
      label: model.title,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        model.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(model.recentLine, style: muted),
                const SizedBox(height: 4),
                Text(model.periodLine, style: muted),
                const SizedBox(height: 4),
                Text(model.unansweredLine, style: muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardNavCard extends StatelessWidget {
  const DashboardNavCard({
    super.key,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Material(
      color: MuhasabahColors.wash(
        MuhasabahColors.summaryWash,
        MuhasabahColors.summaryWashDark,
        brightness,
      ),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPonderCard extends StatelessWidget {
  const DashboardPonderCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardNavCard(
      title: 'PONDER',
      body: Copy.ponderPrompt,
      onTap: onTap,
    );
  }
}
