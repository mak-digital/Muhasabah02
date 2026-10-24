import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/device_unlock.dart';
import '../../application/providers.dart';
import '../../data/privacy_log.dart';
import '../../debug/synthetic_check_in_seeder.dart';
import '../../domain/arabic_script.dart';
import '../../domain/activities.dart';
import '../../domain/akhlaq_practices.dart';
import '../../domain/huquq_practices.dart';
import '../../domain/knowledge_practices.dart';
import '../../domain/health_practices.dart';
import '../../domain/charity_practices.dart';
import '../../domain/ummah_practices.dart';
import '../../domain/wealth_practices.dart';
import '../../domain/time_practices.dart';
import '../../domain/app_appearance.dart';
import '../../domain/copy.dart';
import '../../domain/display_calendar.dart';
import '../../domain/first_day_of_week.dart';
import '../../domain/worship_list_gender.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_mix.dart';
import '../../domain/quotation_cadence.dart';
import '../../domain/quran_stage.dart';
import '../registry/registry_screen.dart';
import '../shared/domain_line_icon.dart';
import '../shared/domain_visual.dart';
import '../shared/quran_stage_mark.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';
import '../shared/system_insets.dart';
import '../shared/ui_bits.dart';
import 'application_reflection_screen.dart';
import 'faq_screen.dart';
import 'custom_selection_sets_editor.dart';
import 'personal_mix_settings.dart';
import 'productivity_settings.dart';
import 'reflection_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final themeIndex = ref.watch(themeModePrefProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.settingsTitle)),
      body: ListView(
        padding: pageListPadding(context),
        children: [
          const SectionHeader(Copy.applicationSection),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text(Copy.appearance),
                  subtitle: Text(_themeLabel(themeIndex)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const AppearanceSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.text_fields_outlined),
                  title: const Text(Copy.textSize),
                  subtitle: const Text(Copy.textSizeNote),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const TextSizeSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.font_download_outlined),
                  title: const Text(Copy.arabicScript),
                  subtitle: Text(
                    '${prefs.arabicScriptFace.label} · ${prefs.arabicScriptSize.round()}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ArabicScriptSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_view_week_outlined),
                  title: const Text(Copy.firstDayOfWeek),
                  subtitle: Text(prefs.firstDayOfWeek.label),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const FirstDayOfWeekSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text(Copy.worshipListGender),
                  subtitle: Text(prefs.worshipListGender.label),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const WorshipListGenderSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text(Copy.calendar),
                  subtitle: Text(prefs.displayCalendar.label),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const CalendarSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  key: const Key('settings-productivity'),
                  leading: const Icon(Icons.task_alt_outlined),
                  title: const Text(Copy.productivitySettings),
                  subtitle: const Text(Copy.productivitySettingsNote),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ProductivitySettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.grid_view_outlined),
                  title: const Text(Copy.visibleDomains),
                  subtitle: Text(
                    domainsSettingsSubtitle(
                      prefs.visibleDomains,
                      prefs.personalMix,
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const VisibleDomainsSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: const Text(Copy.activitiesTitle),
                  subtitle: Text(
                    prefs.salahActivityColours
                        ? Copy.salahMarkActivityColours
                        : Copy.salahMarkShared,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ActivitiesSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timeline_outlined),
                  title: const Text(Copy.baselinesTitle),
                  subtitle: const Text(Copy.baselinesNote),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const BaselinesSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text(Copy.personalAspirations),
                  subtitle: const Text(Copy.aspirationsNote),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const AspirationsSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.format_quote_outlined),
                  title: const Text(Copy.quotationCadence),
                  subtitle: Text(prefs.quotationCadence.label),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const QuotationsSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(Copy.privacySection),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text(Copy.onDeviceStorage),
              subtitle: const Text(Copy.onDeviceStorageNote),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacySettingsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(Copy.aboutMuhasabah),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text(Copy.applicationReflectionIntroTitle),
                  subtitle: const Text(Copy.seePonderExplore),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const ApplicationReflectionAboutScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text(Copy.faqTitle),
                  subtitle: const Text(Copy.faqSettingsNote),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const FaqScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(Copy.accountAndData),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.manage_history_outlined),
                  title: const Text(Copy.historyTitle),
                  subtitle: const Text(Copy.manageCheckInsNote),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RegistryScreen(initialTab: 4),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note_outlined),
                  title: const Text(Copy.myResponse),
                  subtitle: const Text(Copy.myResponseSettingsNote),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RegistryScreen(initialTab: 3),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(Copy.developerSampleData),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.replay_outlined),
                  title: const Text('Recreate sample data'),
                  subtitle: const Text('Sample only; personal days kept'),
                  onTap: () => _recreate(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.backspace_outlined),
                  title: const Text('Remove sample data'),
                  subtitle: const Text('Never automatic later'),
                  onTap: () => _remove(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore_outlined),
                  title: const Text('Restore sample data'),
                  subtitle: const Text('Does not overwrite personal days'),
                  onTap: () => _restore(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _themeLabel(int index) => AppAppearanceX.fromPrefIndex(index).label;

class ActivitiesSettingsScreen extends ConsumerWidget {
  const ActivitiesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final colours = prefs.salahActivityColours;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.activitiesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.activitiesNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            Copy.salahMarkColour,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<bool>(
              groupValue: colours,
              onChanged: (value) async {
                if (value == null) return;
                await prefs.setSalahActivityColours(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: const Column(
                children: [
                  RadioListTile<bool>(
                    title: Text(Copy.salahMarkShared),
                    value: false,
                  ),
                  RadioListTile<bool>(
                    title: Text(Copy.salahMarkActivityColours),
                    value: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Copy.salahMarkActivityNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (colours) ...[
            for (final option in ActivityCatalog.salah)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: MarkerKind.filled,
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.quran.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final row in QuranJourneyRow.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: MarkerKind.filled,
                      color: QuranStageMark.colourFor(row),
                      semanticLabel: row.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${row.label} — ${row.purpose}')),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.dhikr.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.dhikrPostFardNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in ActivityCatalog.dhikrPostFard)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForHadithLived(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.akhlaq.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.akhlaqCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in akhlaqLegendCatalog)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForAkhlaq(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.huquq.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.huquqCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in huquqLegendCatalog)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForAkhlaq(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.charity.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.charityCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in charityLegendCatalog)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForAkhlaq(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.knowledge.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.knowledgeCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in knowledgeLegendCatalog)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForAkhlaq(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.time.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.timeCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in timeLegendCatalog)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForAkhlaq(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.health.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.healthCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in healthLegendCatalog)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForAkhlaq(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.wealth.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.wealthCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in wealthLegendCatalog)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForAkhlaq(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              MonitorDomain.ummah.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              Copy.ummahCheckInNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final option in ummahLegendCatalog)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    RecordedStateMarker(
                      kind: SalahActivityMark.kindForAkhlaq(option.id),
                      color: SalahActivityMark.colourForId(option.id),
                      semanticLabel: option.label,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
          ] else ...[
            const _ActivityMarkRow(kind: MarkerKind.filled, label: 'On time'),
            const _ActivityMarkRow(kind: MarkerKind.outlined, label: 'Late'),
            const _ActivityMarkRow(kind: MarkerKind.missed, label: 'Missed'),
            const _ActivityMarkRow(
              kind: MarkerKind.unanswered,
              label: 'Unanswered',
            ),
            const SizedBox(height: 12),
            for (final option in ActivityCatalog.salah)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(option.label),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityMarkRow extends StatelessWidget {
  const _ActivityMarkRow({required this.kind, required this.label});

  final MarkerKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          RecordedStateMarker(kind: kind, semanticLabel: label),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModePrefProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.appearance)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.appearanceNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<int>(
              groupValue: current,
              onChanged: (value) async {
                if (value == null) return;
                final look = AppAppearanceX.fromPrefIndex(value);
                await ref.read(appPrefsProvider).setAppearance(look);
                ref.read(themeModePrefProvider.notifier).state = look.prefIndex;
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  for (final look in AppAppearance.values)
                    RadioListTile<int>(
                      title: Text(look.label),
                      value: look.prefIndex,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextSizeSettingsScreen extends StatelessWidget {
  const TextSizeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.textSize)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.textSizeNote,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Muhasabah uses your device text size. Change it in the system accessibility settings. The app does not override or score how large text appears.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class ArabicScriptSettingsScreen extends ConsumerWidget {
  const ArabicScriptSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final size = clampArabicScriptSize(prefs.arabicScriptSize);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.arabicScript)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.arabicScriptNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<ArabicScriptFace>(
              groupValue: prefs.arabicScriptFace,
              onChanged: (value) async {
                if (value == null) return;
                await prefs.setArabicScriptFace(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  for (final face in ArabicScriptFace.values)
                    RadioListTile<ArabicScriptFace>(
                      key: Key('arabic-script-pref-${face.id}'),
                      title: Text(face.label),
                      value: face,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(Copy.textSize, style: Theme.of(context).textTheme.titleMedium),
          Slider(
            key: const Key('arabic-script-size'),
            min: 0,
            max: (kArabicScriptSizes.length - 1).toDouble(),
            divisions: kArabicScriptSizes.length - 1,
            value: kArabicScriptSizes.indexOf(size).toDouble(),
            label: '${size.round()}',
            onChanged: (value) async {
              await prefs.setArabicScriptSize(
                kArabicScriptSizes[value.round()],
              );
              ref.read(prefsTickProvider.notifier).state++;
            },
          ),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: prefs.arabicScriptFace.family,
              fontSize: size,
              height: 1.85,
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.privacySection)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.onDeviceStorage,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(Copy.onDeviceStorageNote),
          const SizedBox(height: 16),
          const Text(Copy.privacyBody),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(Copy.appLockTitle),
            subtitle: const Text(Copy.appLockNote),
            value: prefs.appLockEnabled,
            onChanged: (enabled) async {
              final unlock = ref.read(deviceUnlockProvider);
              if (enabled) {
                if (!await unlock.canAuthenticate()) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(Copy.appLockUnavailable)),
                  );
                  return;
                }
                final ok = await unlock.authenticate(
                  reason: Copy.appLockReason,
                );
                if (!ok) return;
                await prefs.setAppLockEnabled(true);
                ref.read(appSessionUnlockedProvider.notifier).state = true;
                logAppEvent('app_lock_enabled');
              } else {
                await prefs.setAppLockEnabled(false);
                logAppEvent('app_lock_disabled');
              }
              ref.read(prefsTickProvider.notifier).state++;
            },
          ),
        ],
      ),
    );
  }
}

class FirstDayOfWeekSettingsScreen extends ConsumerWidget {
  const FirstDayOfWeekSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final current = ref.watch(appPrefsProvider).firstDayOfWeek;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.firstDayOfWeek)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.firstDayOfWeekNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<FirstDayOfWeekPref>(
              groupValue: current,
              onChanged: (value) async {
                if (value == null) return;
                await ref.read(appPrefsProvider).setFirstDayOfWeek(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  for (final option in FirstDayOfWeekPref.values)
                    RadioListTile<FirstDayOfWeekPref>(
                      title: Text(
                        option == FirstDayOfWeekPref.monday
                            ? '${option.label} (default)'
                            : option.label,
                      ),
                      value: option,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorshipListGenderSettingsScreen extends ConsumerWidget {
  const WorshipListGenderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final current = ref.watch(appPrefsProvider).worshipListGender;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.worshipListGender)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.worshipListGenderNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<WorshipListGender>(
              groupValue: current,
              onChanged: (value) async {
                if (value == null) return;
                await ref.read(appPrefsProvider).setWorshipListGender(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  for (final option in WorshipListGender.values)
                    RadioListTile<WorshipListGender>(
                      title: Text(
                        option == WorshipListGender.unanswered
                            ? '${option.label} (default)'
                            : option.label,
                      ),
                      value: option,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarSettingsScreen extends ConsumerWidget {
  const CalendarSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final current = prefs.displayCalendar;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.calendar)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Copy.calendarNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<DisplayCalendar>(
              groupValue: current,
              onChanged: (value) async {
                if (value == null) return;
                await ref.read(appPrefsProvider).setDisplayCalendar(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  for (final option in DisplayCalendar.values)
                    RadioListTile<DisplayCalendar>(
                      title: Text(
                        option == DisplayCalendar.gregorian
                            ? '${option.label} (default)'
                            : option.label,
                      ),
                      value: option,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Copy.ramadanCalendarOffsetNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<int>(
              groupValue: prefs.ramadanCalendarOffsetDays,
              onChanged: (value) async {
                if (value == null) return;
                await ref
                    .read(appPrefsProvider)
                    .setRamadanCalendarOffsetDays(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
              child: Column(
                children: [
                  RadioListTile<int>(
                    title: const Text(Copy.ramadanOffsetCivil),
                    value: 0,
                  ),
                  RadioListTile<int>(
                    title: const Text(Copy.ramadanOffsetEarlier),
                    value: -1,
                  ),
                  RadioListTile<int>(
                    title: const Text(Copy.ramadanOffsetLater),
                    value: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text(Copy.showFastingRamadanHistory),
              subtitle: const Text(Copy.showFastingRamadanHistoryNote),
              value: prefs.showFastingRamadanHistory,
              onChanged: (value) async {
                await ref
                    .read(appPrefsProvider)
                    .setShowFastingRamadanHistory(value);
                ref.read(prefsTickProvider.notifier).state++;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VisibleDomainsSettingsScreen extends ConsumerWidget {
  const VisibleDomainsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prefsTickProvider);
    final current = ref.watch(appPrefsProvider).visibleDomains;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.visibleDomains)),
      body: ListView(
        padding: pageListPadding(context),
        children: [
          Text(
            Copy.shownDomainsNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                key: const Key('clear-all-selections'),
                label: const Text(Copy.clearAllSelections),
                selected: current.isEmpty,
                onSelected: (_) => confirmClearWorkingSelection(context, ref),
              ),
              FilterChip(
                label: const Text(Copy.selectAllDomains),
                selected: sameVisibleDomains(
                  current,
                  selectableMonitorDomains(),
                ),
                onSelected: (_) async {
                  await ref
                      .read(appPrefsProvider)
                      .setVisibleDomains(selectableMonitorDomains());
                  ref.read(prefsTickProvider.notifier).state++;
                },
              ),
              FilterChip(
                label: const Text(Copy.basicDhikrDomains),
                selected: sameVisibleDomains(
                  current,
                  kBasicDhikrVisibleDomains,
                ),
                onSelected: (_) async {
                  await ref
                      .read(appPrefsProvider)
                      .setVisibleDomains(
                        Set<MonitorDomain>.from(kBasicDhikrVisibleDomains),
                      );
                  ref.read(prefsTickProvider.notifier).state++;
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Copy.basicDhikrDomainsNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final domain in MonitorDomain.values)
                  CheckboxListTile(
                    key: Key('domain-visible-${domain.name}'),
                    title: Row(
                      children: [
                        DomainLineIcon(
                          domain,
                          size: 20,
                          color: domainColorIdentity(domain).family,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(domain.label)),
                      ],
                    ),
                    subtitle: isDormantMonitorDomain(domain)
                        ? const Text(Copy.dormantDomainNote)
                        : null,
                    value: isDormantMonitorDomain(domain)
                        ? false
                        : current.contains(domain),
                    onChanged: isDormantMonitorDomain(domain)
                        ? null
                        : (checked) async {
                            final next = Set<MonitorDomain>.from(current);
                            if (checked == true) {
                              next.add(domain);
                            } else {
                              next.remove(domain);
                            }
                            await ref
                                .read(appPrefsProvider)
                                .setVisibleDomains(next);
                            ref.read(prefsTickProvider.notifier).state++;
                          },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            Copy.thisSeasonsMix,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const PersonalMixEditor(),
          const SizedBox(height: 24),
          const CustomSelectionSetsEditor(),
        ],
      ),
    );
  }
}

Future<void> _recreate(BuildContext context, WidgetRef ref) async {
  final seeder = const SyntheticCheckInSeeder();
  await seeder.clearFrom(
    ref.read(checkInRepositoryProvider),
    responses: ref.read(responseRepositoryProvider),
  );
  await seeder.generateInto(
    ref.read(checkInRepositoryProvider),
    now: ref.read(nowProvider),
    responses: ref.read(responseRepositoryProvider),
  );
  await ref.read(appPrefsProvider).setSampleSeeded(true);
  await ref.read(appPrefsProvider).setSampleRemovedByUser(false);
  await ref.read(checkInsProvider.notifier).reload();
  await ref.read(responsesProvider.notifier).reload();
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample data was recreated.')));
  }
}

Future<void> _remove(BuildContext context, WidgetRef ref) async {
  await const SyntheticCheckInSeeder().clearFrom(
    ref.read(checkInRepositoryProvider),
    responses: ref.read(responseRepositoryProvider),
  );
  await ref.read(appPrefsProvider).setSampleRemovedByUser(true);
  await ref.read(checkInsProvider.notifier).reload();
  await ref.read(responsesProvider.notifier).reload();
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample data was removed.')));
  }
}

Future<void> _restore(BuildContext context, WidgetRef ref) async {
  await ref.read(appPrefsProvider).setSampleRemovedByUser(false);
  await const SyntheticCheckInSeeder().generateInto(
    ref.read(checkInRepositoryProvider),
    now: ref.read(nowProvider),
    responses: ref.read(responseRepositoryProvider),
  );
  await ref.read(appPrefsProvider).setSampleSeeded(true);
  await ref.read(checkInsProvider.notifier).reload();
  await ref.read(responsesProvider.notifier).reload();
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample data was restored.')));
  }
}
