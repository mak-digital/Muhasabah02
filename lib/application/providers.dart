import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/app_prefs.dart';
import '../data/memory_repositories.dart';
import '../data/quran_verse_http.dart';
import '../data/repositories.dart';
import '../domain/daily_check_in.dart';
import '../domain/date_key.dart';
import '../domain/dev_feedback.dart';
import '../domain/domain_action.dart';
import '../domain/monitor_domain.dart';
import '../domain/hadith_fetch.dart';
import '../domain/personal_hadith.dart';
import '../domain/personal_quran_verse.dart';
import '../domain/personal_response.dart';
import '../domain/practice_hadith.dart';
import '../domain/quran_verse_fetch.dart';
import '../domain/review_period.dart';

final appPrefsProvider = Provider<AppPrefs>((ref) => MemoryAppPrefs());

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (ref) => MemoryCheckInRepository(),
);

final responseRepositoryProvider = Provider<ResponseRepository>(
  (ref) => MemoryResponseRepository(),
);

final domainActionRepositoryProvider = Provider<DomainActionRepository>(
  (ref) => MemoryDomainActionRepository(),
);

final devFeedbackRepositoryProvider = Provider<DevFeedbackRepository>(
  (ref) => MemoryDevFeedbackRepository(),
);

final practiceHadithRepositoryProvider = Provider<PracticeHadithRepository>(
  (ref) => MemoryPracticeHadithRepository(),
);

final personalQuranVerseRepositoryProvider =
    Provider<PersonalQuranVerseRepository>(
      (ref) => MemoryPersonalQuranVerseRepository(),
    );

final quranVerseFetchProvider = Provider<QuranVerseFetch>(
  (ref) => QuranComVerseFetch(get: quranVerseHttpGet),
);

final personalHadithRepositoryProvider = Provider<PersonalHadithRepository>(
  (ref) => MemoryPersonalHadithRepository(),
);

final hadithFetchProvider = Provider<HadithFetch>(
  (ref) => PublicHadithFetch(get: quranVerseHttpGet),
);

/// Source of "now". Tests override this (or [nowProvider]) for a fixed clock.
typedef NowClock = DateTime Function();

final nowClockProvider = Provider<NowClock>((ref) => DateTime.now);

final nowProvider = Provider<DateTime>((ref) => ref.watch(nowClockProvider)());

/// True when [cached] and [current] fall on different local Gregorian dates.
bool localCalendarDateChanged(DateTime cached, DateTime current) {
  return dateKey(cached) != dateKey(current);
}

/// Invalidates [nowProvider] when the local calendar date has moved.
///
/// Same-date resumes leave the cached value in place. Returns whether
/// [nowProvider] was invalidated. Does not create or save a check-in.
bool refreshNowIfLocalDateChanged(WidgetRef ref) {
  final current = ref.read(nowClockProvider)();
  final cached = ref.read(nowProvider);
  if (!localCalendarDateChanged(cached, current)) return false;
  ref.invalidate(nowProvider);
  return true;
}

/// Tap handler that refreshes the cached date, then opens [onOpen] only when
/// [dateKey] is today or historical. Future cells stay non-navigable.
///
/// Does not redirect a historical cell to today.
VoidCallback recoverableDateCellOnTap({
  required WidgetRef ref,
  required String dateKey,
  required VoidCallback onOpen,
}) {
  return () {
    refreshNowIfLocalDateChanged(ref);
    if (dateCellKind(dateKey, ref.read(nowProvider)) == DateCellKind.future) {
      return;
    }
    onOpen();
  };
}

final reviewPeriodProvider = StateProvider<ReviewPeriod>(
  (ref) => ReviewPeriod.days7,
);

final prefsTickProvider = StateProvider<int>((ref) => 0);

/// Last Home domain shown in this app session. Not stored. Not a score.
final homeDomainStageProvider = StateProvider<MonitorDomain?>((ref) => null);

/// Last full-check-in domain shown in this app session. Not stored. Not a score.
final checkInDomainStageProvider = StateProvider<MonitorDomain?>((ref) => null);

final themeModePrefProvider = StateProvider<int>((ref) => 0);

class CheckInsController extends AsyncNotifier<List<DailyCheckIn>> {
  @override
  Future<List<DailyCheckIn>> build() {
    return ref.read(checkInRepositoryProvider).allHealthy();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(checkInRepositoryProvider).allHealthy(),
    );
  }

  Future<void> save(DailyCheckIn record) async {
    await ref.read(checkInRepositoryProvider).save(record);
    await reload();
  }

  Future<bool> delete(String dateKey) async {
    final ok = await ref.read(checkInRepositoryProvider).delete(dateKey);
    await reload();
    return ok;
  }
}

final checkInsProvider =
    AsyncNotifierProvider<CheckInsController, List<DailyCheckIn>>(
      CheckInsController.new,
    );

class ResponsesController extends AsyncNotifier<List<PersonalResponse>> {
  @override
  Future<List<PersonalResponse>> build() {
    return ref.read(responseRepositoryProvider).allHealthy();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(responseRepositoryProvider).allHealthy(),
    );
  }

  Future<void> save(PersonalResponse record) async {
    await ref.read(responseRepositoryProvider).save(record);
    await reload();
  }

  Future<bool> delete(String id) async {
    final ok = await ref.read(responseRepositoryProvider).delete(id);
    await reload();
    return ok;
  }
}

final responsesProvider =
    AsyncNotifierProvider<ResponsesController, List<PersonalResponse>>(
      ResponsesController.new,
    );

class DomainActionsController extends AsyncNotifier<List<DomainAction>> {
  @override
  Future<List<DomainAction>> build() {
    return ref.read(domainActionRepositoryProvider).allHealthy();
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(
      () => ref.read(domainActionRepositoryProvider).allHealthy(),
    );
  }

  Future<void> save(DomainAction record) async {
    await ref.read(domainActionRepositoryProvider).save(record);
    await reload();
  }

  Future<bool> delete(String id) async {
    final ok = await ref.read(domainActionRepositoryProvider).delete(id);
    await reload();
    return ok;
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    final repo = ref.read(domainActionRepositoryProvider);
    for (final id in ids) {
      await repo.delete(id);
    }
    await reload();
  }
}

final domainActionsProvider =
    AsyncNotifierProvider<DomainActionsController, List<DomainAction>>(
      DomainActionsController.new,
    );

class DevFeedbackController extends AsyncNotifier<List<DevFeedback>> {
  @override
  Future<List<DevFeedback>> build() {
    return ref.read(devFeedbackRepositoryProvider).allHealthy();
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(
      () => ref.read(devFeedbackRepositoryProvider).allHealthy(),
    );
  }

  Future<void> save(DevFeedback record) async {
    await ref.read(devFeedbackRepositoryProvider).save(record);
    await reload();
  }

  Future<int> nextSerial() {
    return ref.read(devFeedbackRepositoryProvider).nextSerial();
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    final repo = ref.read(devFeedbackRepositoryProvider);
    for (final id in ids) {
      await repo.delete(id);
    }
    await reload();
  }
}

final devFeedbackProvider =
    AsyncNotifierProvider<DevFeedbackController, List<DevFeedback>>(
      DevFeedbackController.new,
    );

class PracticeHadithController extends AsyncNotifier<List<PracticeHadithRecord>> {
  @override
  Future<List<PracticeHadithRecord>> build() {
    return ref.read(practiceHadithRepositoryProvider).allHealthy();
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(
      () => ref.read(practiceHadithRepositoryProvider).allHealthy(),
    );
  }

  Future<void> save(PracticeHadithRecord record) async {
    await ref.read(practiceHadithRepositoryProvider).save(record);
    await reload();
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    final repo = ref.read(practiceHadithRepositoryProvider);
    for (final id in ids) {
      await repo.delete(id);
    }
    await reload();
  }
}

final practiceHadithProvider =
    AsyncNotifierProvider<PracticeHadithController, List<PracticeHadithRecord>>(
      PracticeHadithController.new,
    );

class PersonalQuranVerseController
    extends AsyncNotifier<List<PersonalQuranVerse>> {
  @override
  Future<List<PersonalQuranVerse>> build() {
    return ref.read(personalQuranVerseRepositoryProvider).allHealthy();
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(
      () => ref.read(personalQuranVerseRepositoryProvider).allHealthy(),
    );
  }

  Future<void> save(PersonalQuranVerse record) async {
    await ref.read(personalQuranVerseRepositoryProvider).save(record);
    await reload();
  }
}

final personalQuranVerseProvider =
    AsyncNotifierProvider<
      PersonalQuranVerseController,
      List<PersonalQuranVerse>
    >(PersonalQuranVerseController.new);

class PersonalHadithController extends AsyncNotifier<List<PersonalHadith>> {
  @override
  Future<List<PersonalHadith>> build() {
    return ref.read(personalHadithRepositoryProvider).allHealthy();
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(
      () => ref.read(personalHadithRepositoryProvider).allHealthy(),
    );
  }

  Future<void> save(PersonalHadith record) async {
    await ref.read(personalHadithRepositoryProvider).save(record);
    await reload();
  }
}

final personalHadithProvider =
    AsyncNotifierProvider<PersonalHadithController, List<PersonalHadith>>(
      PersonalHadithController.new,
    );
