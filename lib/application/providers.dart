import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/app_prefs.dart';
import '../data/memory_repositories.dart';
import '../data/repositories.dart';
import '../domain/daily_check_in.dart';
import '../domain/date_key.dart';
import '../domain/monitor_domain.dart';
import '../domain/personal_response.dart';
import '../domain/review_period.dart';

final appPrefsProvider = Provider<AppPrefs>((ref) => MemoryAppPrefs());

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (ref) => MemoryCheckInRepository(),
);

final responseRepositoryProvider = Provider<ResponseRepository>(
  (ref) => MemoryResponseRepository(),
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
