import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/copy.dart';
import '../../domain/personal_mix.dart';
import '../../domain/registry_scope.dart';
import '../history/history_screen.dart';
import '../response/response_list_screen.dart';
import 'action_register_page.dart';
import 'developer_notes_register_page.dart';
import 'hadith_register_page.dart';

class RegistryScreen extends ConsumerStatefulWidget {
  const RegistryScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends ConsumerState<RegistryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 4),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsTickProvider);
    final prefs = ref.watch(appPrefsProvider);
    final scope = RegistryScope.fromPrefs(
      visible: prefs.visibleDomains,
      mix: prefs.personalMix,
    );
    final note = Copy.registryFilterNote(
      mixLabel: scope.mix.kind.label,
      domains: scope.domainList,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(Copy.registryTitle),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
          tabs: const [
            Tab(
              key: Key('registry-tab-actions'),
              height: 40,
              text: Copy.registryTabActionsShort,
            ),
            Tab(
              key: Key('registry-tab-hadith'),
              height: 40,
              text: Copy.registryTabHadithShort,
            ),
            Tab(
              key: Key('registry-tab-developer'),
              height: 40,
              text: Copy.registryTabDeveloperShort,
            ),
            Tab(
              key: Key('registry-tab-notes'),
              height: 40,
              text: Copy.myResponse,
            ),
            Tab(
              key: Key('registry-tab-history'),
              height: 40,
              text: Copy.registryTabHistory,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          ActionRegisterPage(scope: scope, note: note),
          HadithRegisterPage(scope: scope, note: note),
          DeveloperNotesRegisterPage(scope: scope, note: note),
          ResponseListScreen(
            embedded: true,
            activeDomains: scope.domains,
            filterNote: note,
          ),
          HistoryScreen(
            embedded: true,
            filterNote: Copy.registryHistoryFilterNote,
          ),
        ],
      ),
    );
  }
}
