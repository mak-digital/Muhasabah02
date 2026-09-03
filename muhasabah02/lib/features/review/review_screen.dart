import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  static const routeName = '/review';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final reflections = [
      'Did I pray on time today?',
      'Was I grateful for Allah’s blessings?',
      'Did I control my speech and actions?',
      'Did I help someone today?',
      'Did I seek beneficial knowledge?',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Review')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reflections.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(reflections[index], style: theme.textTheme.bodyLarge),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}
