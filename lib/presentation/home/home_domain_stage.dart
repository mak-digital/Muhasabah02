import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_mix.dart';
import '../shared/domain_stage.dart';
import 'salah_home_follow_on.dart';

class HomeDomainStage extends ConsumerWidget {
  const HomeDomainStage({
    super.key,
    required this.domains,
    required this.cardFor,
  });

  final List<MonitorDomain> domains;
  final Widget Function(MonitorDomain domain) cardFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (domains.isEmpty) {
      return DomainStage(
        domains: domains,
        cardFor: cardFor,
        stageProvider: homeDomainStageProvider,
        keyPrefix: 'home-domain',
        pillsNote: Copy.homeDomainPillsNote,
      );
    }
    final shown =
        domains[homeDomainStageIndex(
          domains,
          ref.watch(homeDomainStageProvider),
        )];
    final practice = homePracticeWash(shown);
    final prefs = ref.watch(appPrefsProvider);
    final season = personalMixSeasonLine(
      prefs.personalMix,
      prefs.visibleDomains,
      domain: shown,
    );
    return DomainStage(
      domains: domains,
      cardFor: cardFor,
      stageProvider: homeDomainStageProvider,
      keyPrefix: 'home-domain',
      pillsNote: Copy.homeDomainPillsNote,
      aboveCard: [
        if (season != null) ...[
          Text(
            '${Copy.personalMixSeasonPrefix} $season.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (practice != null) ...[practice, const SizedBox(height: 10)],
      ],
    );
  }
}
