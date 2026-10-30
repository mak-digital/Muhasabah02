import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/app_language.dart';
import '../../domain/bangla_copy.dart';
import '../../domain/copy.dart';
import '../shared/app_language_scope.dart';
import '../shared/ui_bits.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLanguageProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(uiText(context, Copy.language))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BalancedProse(
            uiText(context, Copy.languageNote),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<AppLanguage>(
              groupValue: current,
              onChanged: (value) async {
                if (value == null) return;
                await ref.read(appPrefsProvider).setAppLanguage(value);
                ref.read(appLanguageProvider.notifier).state = value;
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  for (final language in AppLanguage.values)
                    RadioListTile<AppLanguage>(
                      title: Text(language.endonym),
                      value: language,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            uiText(context, Copy.languageReviewHeading),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          BalancedProse(
            uiText(context, Copy.languageReviewNote),
            style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 12),
          for (final entry in kBanglaByEnglish.entries)
            if (entry.key != Copy.faqPurpose)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(entry.key, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      entry.value,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
          Text(Copy.faqPurpose, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            kBanglaByEnglish[Copy.faqPurpose] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
