import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context) {
    final historyItems = [
      {
        'date': '2026-09-01',
        'score': '8/10',
      },
      {
        'date': '2026-08-31',
        'score': '7/10',
      },
      {
        'date': '2026-08-30',
        'score': '9/10',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: historyItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = historyItems[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.history),
              ),
              title: Text(item['date']!),
              subtitle: Text('Muhasabah Score: ${item['score']}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}