import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_prefs.dart';
import '../data/memory_repositories.dart';
import '../data/repositories.dart';
import '../domain/daily_check_in.dart';
import '../domain/personal_response.dart';
import '../domain/review_period.dart';

final appPrefsProvider = Provider<AppPrefs>((ref) => MemoryAppPrefs());

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (ref) => MemoryCheckInRepository(),
);

final responseRepositoryProvider = Provider<ResponseRepository>(
  (ref) => MemoryResponseRepository(),
);

final nowProvider = Provider<DateTime>((ref) => DateTime.now());

final reviewPeriodProvider = StateProvider<ReviewPeriod>(
  (ref) => ReviewPeriod.days7,
);

final prefsTickProvider = StateProvider<int>((ref) => 0);

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
