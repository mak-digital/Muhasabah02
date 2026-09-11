import 'package:flutter/material.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/monitor_domain.dart';
import '../shared/domain_stage.dart';

class HomeDomainStage extends StatelessWidget {
  const HomeDomainStage({
    super.key,
    required this.domains,
    required this.cardFor,
  });

  final List<MonitorDomain> domains;
  final Widget Function(MonitorDomain domain) cardFor;

  @override
  Widget build(BuildContext context) {
    return DomainStage(
      domains: domains,
      cardFor: cardFor,
      stageProvider: homeDomainStageProvider,
      keyPrefix: 'home-domain',
      pillsNote: Copy.homeDomainPillsNote,
    );
  }
}
