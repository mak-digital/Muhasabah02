import 'package:flutter/material.dart';

import '../../domain/copy.dart';

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
