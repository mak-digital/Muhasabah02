import 'package:hive_flutter/hive_flutter.dart';

import '../data/app_prefs.dart';
import '../domain/daily_check_in.dart';
import '../domain/display_calendar.dart';
import '../domain/first_day_of_week.dart';
import '../domain/home_traces.dart';
import '../domain/monitor_domain.dart';
import '../domain/personal_aspiration.dart';
import '../domain/personal_baseline.dart';
import '../domain/personal_mix.dart';
import '../domain/personal_response.dart';
import '../domain/quotation_cadence.dart';
import 'codecs.dart';
import 'repositories.dart';

const checkInsBoxName = 'muhasabah_checkins_v5';
const responsesBoxName = 'muhasabah_responses_v1';
const prefsBoxName = 'muhasabah_prefs_v1';

class HiveCheckInRepository implements CheckInRepository {
  HiveCheckInRepository(this._box);

  final Box<String> _box;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<DailyCheckIn>> allHealthy() async {
    _corrupt.clear();
    final healthy = <DailyCheckIn>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final parsed = decodeCheckIn(raw);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add('$key');
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return healthy;
  }

  @override
  Future<DailyCheckIn?> getByDate(String dateKey) async {
    final raw = _box.get(dateKey);
    if (raw == null) return null;
    final parsed = decodeCheckIn(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(dateKey)) _corrupt.add(dateKey);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(DailyCheckIn record) async {
    final previous = _box.get(record.dateKey);
    try {
      await _box.put(
        record.dateKey,
        encodeCheckIn(record.copyWith(savedAt: DateTime.now())),
      );
      _corrupt.remove(record.dateKey);
    } catch (_) {
      if (previous != null) {
        await _box.put(record.dateKey, previous);
      }
      rethrow;
    }
  }

  @override
  Future<bool> delete(String dateKey) async {
    final previous = _box.get(dateKey);
    if (previous == null) return true;
    try {
      await _box.delete(dateKey);
      _corrupt.remove(dateKey);
      return true;
    } catch (_) {
      if (!_box.containsKey(dateKey) && previous.isNotEmpty) {
        await _box.put(dateKey, previous);
      }
      return false;
    }
  }
}

class HiveResponseRepository implements ResponseRepository {
  HiveResponseRepository(this._box);

  final Box<String> _box;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<PersonalResponse>> allHealthy() async {
    _corrupt.clear();
    final healthy = <PersonalResponse>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final parsed = decodeResponse(raw);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add('$key');
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return healthy;
  }

  @override
  Future<PersonalResponse?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    final parsed = decodeResponse(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(PersonalResponse record) async {
    final previous = _box.get(record.id);
    try {
      await _box.put(record.id, encodeResponse(record));
      _corrupt.remove(record.id);
    } catch (_) {
      if (previous != null) {
        await _box.put(record.id, previous);
      }
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    final previous = _box.get(id);
    if (previous == null) return true;
    try {
      await _box.delete(id);
      _corrupt.remove(id);
      return true;
    } catch (_) {
      if (!_box.containsKey(id) && previous.isNotEmpty) {
        await _box.put(id, previous);
      }
      return false;
    }
  }
}

class HiveAppPrefs implements AppPrefs {
  HiveAppPrefs(this._box);

  final Box<String> _box;

  static const _sampleSeeded = 'sample_seeded';
  static const _sampleRemoved = 'sample_removed_by_user';
  static const _archiveDismissed = 'archive_prompt_dismissed';
  static const _applicationAck = 'application_reflection_ack';
  static const _firstDayOfWeek = 'first_day_of_week';
  static const _displayCalendar = 'display_calendar';
  static const _visibleDomains = 'visible_domains';
  static const _personalMix = 'personal_mix';
  static const _quotationCadence = 'quotation_cadence';
  static const _baselines = 'personal_baselines';
  static const _aspirations = 'personal_aspirations';
  static const _weeklyJournals = 'weekly_journals';
  static const _hadithFocus = 'hadith_memorisation_focus';
  static const _hajjStatus = 'hajj_status';
  static const _mixHiddenHint = 'mix_hidden_domain_hint';
  static const _appLock = 'app_lock_enabled';

  bool _flag(String key) => _box.get(key) == 'true';

  Future<void> _setFlag(String key, bool value) =>
      _box.put(key, value ? 'true' : 'false');

  @override
  bool get sampleSeeded => _flag(_sampleSeeded);

  @override
  bool get sampleRemovedByUser => _flag(_sampleRemoved);

  @override
  bool get archivePromptDismissed => _flag(_archiveDismissed);

  @override
  bool get applicationReflectionAcknowledged => _flag(_applicationAck);

  @override
  FirstDayOfWeekPref get firstDayOfWeek =>
      FirstDayOfWeekPrefX.fromId(_box.get(_firstDayOfWeek));

  @override
  DisplayCalendar get displayCalendar =>
      DisplayCalendarX.fromId(_box.get(_displayCalendar));

  @override
  Set<MonitorDomain> get visibleDomains =>
      decodeVisibleDomains(_box.get(_visibleDomains));

  @override
  PersonalMix get personalMix => decodePersonalMix(_box.get(_personalMix));

  @override
  Future<void> setSampleSeeded(bool value) => _setFlag(_sampleSeeded, value);

  @override
  Future<void> setSampleRemovedByUser(bool value) =>
      _setFlag(_sampleRemoved, value);

  @override
  Future<void> setArchivePromptDismissed(bool value) =>
      _setFlag(_archiveDismissed, value);

  @override
  Future<void> setApplicationReflectionAcknowledged(bool value) =>
      _setFlag(_applicationAck, value);

  @override
  Future<void> setFirstDayOfWeek(FirstDayOfWeekPref value) =>
      _box.put(_firstDayOfWeek, value.id);

  @override
  Future<void> setDisplayCalendar(DisplayCalendar value) =>
      _box.put(_displayCalendar, value.id);

  @override
  Future<void> setVisibleDomains(Set<MonitorDomain> value) =>
      _box.put(_visibleDomains, encodeVisibleDomains(value));

  @override
  Future<void> setPersonalMix(PersonalMix value) =>
      _box.put(_personalMix, encodePersonalMix(value));

  @override
  QuotationCadence get quotationCadence =>
      QuotationCadenceX.fromId(_box.get(_quotationCadence));

  @override
  List<PersonalBaseline> get baselines => decodeBaselines(_box.get(_baselines));

  @override
  List<PersonalAspiration> get aspirations =>
      decodeAspirations(_box.get(_aspirations));

  @override
  String weeklyJournal(String weekKey) =>
      decodeJournals(_box.get(_weeklyJournals))[weekKey] ?? '';

  @override
  Future<void> setQuotationCadence(QuotationCadence value) =>
      _box.put(_quotationCadence, value.id);

  @override
  Future<void> setBaselines(List<PersonalBaseline> value) =>
      _box.put(_baselines, encodeBaselines(value));

  @override
  Future<void> setAspirations(List<PersonalAspiration> value) =>
      _box.put(_aspirations, encodeAspirations(value));

  @override
  Future<void> setWeeklyJournal(String weekKey, String text) async {
    final next = decodeJournals(_box.get(_weeklyJournals));
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      next.remove(weekKey);
    } else {
      next[weekKey] = text;
    }
    await _box.put(_weeklyJournals, encodeJournals(next));
  }

  @override
  HadithMemorisationFocus get hadithMemorisationFocus =>
      HadithMemorisationFocusX.fromId(_box.get(_hadithFocus));

  @override
  Future<void> setHadithMemorisationFocus(HadithMemorisationFocus value) =>
      _box.put(_hadithFocus, value.name);

  @override
  HajjStatus get hajjStatus => HajjStatusX.fromId(_box.get(_hajjStatus));

  @override
  Future<void> setHajjStatus(HajjStatus value) =>
      _box.put(_hajjStatus, value.name);

  @override
  bool get mixHiddenDomainHintShown => _flag(_mixHiddenHint);

  @override
  Future<void> setMixHiddenDomainHintShown(bool value) =>
      _setFlag(_mixHiddenHint, value);

  @override
  bool get appLockEnabled => _flag(_appLock);

  @override
  Future<void> setAppLockEnabled(bool value) => _setFlag(_appLock, value);
}

Future<
  ({
    HiveCheckInRepository checkIns,
    HiveResponseRepository responses,
    HiveAppPrefs prefs,
  })
>
openHiveRepositories() async {
  await Hive.initFlutter();
  final checkIns = await Hive.openBox<String>(checkInsBoxName);
  final responses = await Hive.openBox<String>(responsesBoxName);
  final prefs = await Hive.openBox<String>(prefsBoxName);
  return (
    checkIns: HiveCheckInRepository(checkIns),
    responses: HiveResponseRepository(responses),
    prefs: HiveAppPrefs(prefs),
  );
}
