import 'package:flutter/material.dart';

import '../../domain/copy.dart';

class ApplicationReflectionIntroScreen extends StatelessWidget {
  const ApplicationReflectionIntroScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.applicationReflectionIntroTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            Copy.seePonderExplore,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Muhasabah helps you see what you recorded, ponder it, and explore it in your own words.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const Text(
            'RECORD → REFLECT → REVIEW → RECOGNISE → PONDER → RESPOND',
          ),
          const SizedBox(height: 16),
          Text(
            Copy.applicationReflectionNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Colour identifies domains. Missing answers are not treated as missed. The app does not score spirituality or prescribe worship.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

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
            Copy.seePonderExplore,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(Copy.applicationReflectionNote),
          const SizedBox(height: 16),
          const Text(
            'This page remains available in Settings. Application Reflection is not a recurring daily field and is not used in summaries or dashboards.',
          ),
        ],
      ),
    );
  }
}
