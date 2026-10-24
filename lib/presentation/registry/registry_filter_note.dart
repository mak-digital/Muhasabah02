import 'package:flutter/material.dart';

class RegistryFilterNote extends StatelessWidget {
  const RegistryFilterNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.35,
          fontSize: 11,
        ),
      ),
    );
  }
}
