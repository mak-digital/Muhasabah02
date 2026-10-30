import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../shared/ui_bits.dart';

class ApplicationReflectionAboutScreen extends StatelessWidget {
  const ApplicationReflectionAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.applicationReflectionIntroTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            Copy.recordReflectLoop,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            Copy.seePonderExplore,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          BalancedProse(
            Copy.lookingBackPurpose,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 16),
          BalancedProse(
            Copy.applicationReflectionNote,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 16),
          BalancedProse(
            'This page remains available in Settings. Application Reflection is not a recurring daily field and is not used in summaries or dashboards.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
