import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/app.dart';
import 'package:muhasabah02/application/device_unlock.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/application/reflection_source_launch.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/presentation/home/citation_reader_screen.dart';
import 'package:muhasabah02/presentation/home/hadith_map_sheet.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/data/repositories.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/display_calendar.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/hadith_fetch.dart';
import 'package:muhasabah02/domain/hadith_ref.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/quran_verse_fetch.dart';
import 'package:muhasabah02/domain/quran_verse_ref.dart';
import 'package:muhasabah02/domain/reflection_source.dart';
import 'package:muhasabah02/presentation/home/bring_hadith_sheet.dart';
import 'package:muhasabah02/presentation/home/bring_quran_verse_sheet.dart';

import 'fake_device_unlock.dart';

Set<MonitorDomain> allVisibleDomains() =>
    Set<MonitorDomain>.from(MonitorDomain.values);

Widget testApp({
  MemoryCheckInRepository? checkIns,
  CheckInRepository? checkInRepository,
  MemoryResponseRepository? responses,
  ResponseRepository? responseRepository,
  MemoryDomainActionRepository? domainActions,
  DomainActionRepository? domainActionRepository,
  MemoryDevFeedbackRepository? devFeedback,
  DevFeedbackRepository? devFeedbackRepository,
  MemoryPracticeHadithRepository? practiceHadith,
  PracticeHadithRepository? practiceHadithRepository,
  MemoryPersonalQuranVerseRepository? personalQuran,
  PersonalQuranVerseRepository? personalQuranVerseRepository,
  QuranVerseFetch? quranVerseFetch,
  MemoryPersonalHadithRepository? personalHadith,
  PersonalHadithRepository? personalHadithRepository,
  HadithFetch? hadithFetch,
  MemoryAppPrefs? prefs,
  MemoryHajjStoreRepository? hajjStore,
  MemoryProductivityStoreRepository? productivityStore,
  DateTime? now,
  DateTime Function()? clock,
  FirstDayOfWeekPref firstDayOfWeek = FirstDayOfWeekPref.monday,
  DisplayCalendar displayCalendar = DisplayCalendar.gregorian,
  Set<MonitorDomain>? visibleDomains,
  PersonalMix? personalMix,
  bool applicationReflectionAcknowledged = true,
  bool appLockEnabled = false,
  bool salahActivityColours = false,
  DeviceUnlock? deviceUnlock,
  ReflectionUrlLaunch? reflectionUrlLaunch,
  CitationPageBuilder? citationPageBuilder,
  HadithTextShare? hadithTextShare,
  HadithSpeech? hadithSpeech,
}) {
  return ProviderScope(
    overrides: [
      checkInRepositoryProvider.overrideWithValue(
        checkInRepository ?? checkIns ?? MemoryCheckInRepository(),
      ),
      responseRepositoryProvider.overrideWithValue(
        responseRepository ?? responses ?? MemoryResponseRepository(),
      ),
      domainActionRepositoryProvider.overrideWithValue(
        domainActionRepository ??
            domainActions ??
            MemoryDomainActionRepository(),
      ),
      devFeedbackRepositoryProvider.overrideWithValue(
        devFeedbackRepository ?? devFeedback ?? MemoryDevFeedbackRepository(),
      ),
      practiceHadithRepositoryProvider.overrideWithValue(
        practiceHadithRepository ??
            practiceHadith ??
            MemoryPracticeHadithRepository(),
      ),
      personalQuranVerseRepositoryProvider.overrideWithValue(
        personalQuranVerseRepository ??
            personalQuran ??
            MemoryPersonalQuranVerseRepository(),
      ),
      quranVerseFetchProvider.overrideWithValue(
        quranVerseFetch ?? const FailingQuranVerseFetch(),
      ),
      personalHadithRepositoryProvider.overrideWithValue(
        personalHadithRepository ??
            personalHadith ??
            MemoryPersonalHadithRepository(),
      ),
      hadithFetchProvider.overrideWithValue(
        hadithFetch ?? const FailingHadithFetch(),
      ),
      deviceUnlockProvider.overrideWithValue(
        deviceUnlock ?? FakeDeviceUnlock(),
      ),
      appPrefsProvider.overrideWithValue(
        prefs ??
            MemoryAppPrefs(
              applicationReflectionAcknowledged:
                  applicationReflectionAcknowledged,
              firstDayOfWeek: firstDayOfWeek,
              displayCalendar: displayCalendar,
              visibleDomains: visibleDomains,
              personalMix: personalMix,
              appLockEnabled: appLockEnabled,
              salahActivityColours: salahActivityColours,
            ),
      ),
      hajjStoreRepositoryProvider.overrideWithValue(
        hajjStore ?? MemoryHajjStoreRepository(),
      ),
      productivityStoreRepositoryProvider.overrideWithValue(
        productivityStore ?? MemoryProductivityStoreRepository(),
      ),
      if (clock != null) nowClockProvider.overrideWithValue(clock),
      if (now != null) nowClockProvider.overrideWithValue(() => now),
      if (now != null) nowProvider.overrideWithValue(now),
      if (reflectionUrlLaunch != null)
        reflectionUrlLaunchProvider.overrideWithValue(reflectionUrlLaunch),
      citationPageBuilderProvider.overrideWithValue(
        citationPageBuilder ?? fakeCitationPage,
      ),
      if (hadithTextShare != null)
        hadithTextShareProvider.overrideWithValue(hadithTextShare),
      hadithSpeechProvider.overrideWithValue(hadithSpeech ?? HadithSpeech()),
    ],
    child: const MuhasabahApp(),
  );
}

Widget fakeCitationPage({
  required List<ReflectionSourcePage> pages,
  required String title,
}) {
  return _FakeCitationPage(pages: pages, title: title);
}

Future<void> openRegistryTab(WidgetTester tester, {required Key tab}) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(Copy.registryTab),
    ),
  );
  await tester.pumpAndSettle();
  final finder = find.byKey(tab);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class FailingQuranVerseFetch implements QuranVerseFetch {
  const FailingQuranVerseFetch();

  @override
  Future<FetchedQuranPassage> load(QuranVerseRange range) {
    throw const QuranVerseFetchException();
  }
}

class FailingHadithFetch implements HadithFetch {
  const FailingHadithFetch();

  @override
  Future<FetchedHadith> load(HadithRef ref) {
    throw const HadithFetchException();
  }
}

class FakeHadithFetch implements HadithFetch {
  const FakeHadithFetch({
    this.arabic = 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
    this.translation = 'Actions are but by intentions.',
  });

  final String arabic;
  final String translation;

  @override
  Future<FetchedHadith> load(HadithRef ref) async {
    return FetchedHadith(arabic: arabic, translation: translation);
  }
}

class FakeQuranVerseFetch implements QuranVerseFetch {
  const FakeQuranVerseFetch({
    this.arabic = 'قُلْ هُوَ اللَّهُ أَحَدٌ',
    this.translation = 'Say: He is Allah, One.',
  });

  final String arabic;
  final String translation;

  @override
  Future<FetchedQuranPassage> load(QuranVerseRange range) async {
    return FetchedQuranPassage(arabic: arabic, translation: translation);
  }
}

class _FakeCitationPage extends ConsumerStatefulWidget {
  const _FakeCitationPage({required this.pages, required this.title});

  final List<ReflectionSourcePage> pages;
  final String title;

  @override
  ConsumerState<_FakeCitationPage> createState() => _FakeCitationPageState();
}

class _FakeCitationPageState extends ConsumerState<_FakeCitationPage> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final page = widget.pages[_index];
    final hasPager = widget.pages.length > 1;
    final bringRange = parseQuranComUri(page.uri)?.range;
    final bringHadith = parseSunnahComUri(page.uri)?.ref;
    return Scaffold(
      key: const Key('citation-reader'),
      appBar: AppBar(
        title: Text(hasPager ? page.label : widget.title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              key: const Key('citation-close'),
              tooltip: Copy.citationClose,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).maybePop(),
            );
          },
        ),
        actions: [
          IconButton(
            key: const Key('citation-share'),
            tooltip: Copy.shareCitation,
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Text(page.uri.toString(), key: const Key('citation-uri')),
          if (bringRange != null)
            TextButton(
              key: const Key('citation-bring-quran'),
              onPressed: () => showBringQuranVerseSheet(
                context,
                initial: bringRange.verseKey,
              ),
              child: const Text(Copy.bringThisVerseIntoLearn),
            ),
          if (bringHadith != null)
            TextButton(
              key: const Key('citation-bring-hadith'),
              onPressed: () =>
                  showBringHadithSheet(context, initial: bringHadith.hadithKey),
              child: const Text(Copy.bringThisHadithIntoLearn),
            ),
          if (hasPager)
            Row(
              children: [
                IconButton(
                  key: const Key('citation-prev-page'),
                  tooltip: Copy.previousCitationPage,
                  onPressed: _index == 0
                      ? null
                      : () => setState(() => _index--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    Copy.citationPageIndex(_index + 1, widget.pages.length),
                    key: const Key('citation-page-index'),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  key: const Key('citation-next-page'),
                  tooltip: Copy.nextCitationPage,
                  onPressed: _index >= widget.pages.length - 1
                      ? null
                      : () => setState(() => _index++),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

DailyCheckIn sampleDay(String dateKey) {
  return DailyCheckIn.empty(dateKey)
      .withPrayer(PrayerId.fajr, PrayerStatus.onTime)
      .withPrayer(PrayerId.dhuhr, PrayerStatus.late)
      .withPrayer(PrayerId.asr, PrayerStatus.missed)
      .withQuran(QuranDimension.reading, TernaryOutcome.positive)
      .withQuran(QuranDimension.applicationReflection, TernaryOutcome.positive);
}
