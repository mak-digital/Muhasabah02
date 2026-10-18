import 'package:hive_flutter/hive_flutter.dart';

import '../data/app_prefs.dart';
import '../domain/arabic_script.dart';
import '../domain/custom_selection_set.dart';
import '../domain/daily_check_in.dart';
import '../domain/display_calendar.dart';
import '../domain/first_day_of_week.dart';
import '../domain/home_traces.dart';
import '../domain/monitor_domain.dart';
import '../domain/personal_aspiration.dart';
import '../domain/personal_baseline.dart';
import '../domain/personal_mix.dart';
import '../domain/dev_feedback.dart';
import '../domain/domain_action.dart';
import '../domain/personal_response.dart';
import '../domain/personal_hadith.dart';
import '../domain/personal_quran_verse.dart';
import '../domain/practice_hadith.dart';
import '../domain/hajj_planning.dart';
import '../domain/quotation_cadence.dart';
import 'codecs.dart';
import 'repositories.dart';

const checkInsBoxName = 'muhasabah_checkins_v5';
const responsesBoxName = 'muhasabah_responses_v1';
const prefsBoxName = 'muhasabah_prefs_v1';
const domainActionsBoxName = 'muhasabah_domain_actions_v1';
const devFeedbackBoxName = 'muhasabah_dev_feedback_v1';
const practiceHadithBoxName = 'muhasabah_practice_hadith_v1';
const personalQuranBoxName = 'muhasabah_personal_quran_v1';
const personalHadithBoxName = 'muhasabah_personal_hadith_v1';
const kDevFeedbackSerialKey = '__next_serial';

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

class HiveDomainActionRepository implements DomainActionRepository {
  HiveDomainActionRepository(this._box);

  final Box<String> _box;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<DomainAction>> allHealthy() async {
    _corrupt.clear();
    final healthy = <DomainAction>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final parsed = decodeDomainAction(raw);
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
  Future<DomainAction?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    final parsed = decodeDomainAction(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(DomainAction record) async {
    final previous = _box.get(record.id);
    try {
      await _box.put(record.id, encodeDomainAction(record));
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

class HiveDevFeedbackRepository implements DevFeedbackRepository {
  HiveDevFeedbackRepository(this._box);

  final Box<String> _box;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<DevFeedback>> allHealthy() async {
    _corrupt.clear();
    final healthy = <DevFeedback>[];
    for (final key in _box.keys) {
      if ('$key' == kDevFeedbackSerialKey) continue;
      final raw = _box.get(key);
      if (raw == null) continue;
      final parsed = decodeDevFeedback(raw);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add('$key');
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) => a.serial.compareTo(b.serial));
    return healthy;
  }

  @override
  Future<DevFeedback?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    final parsed = decodeDevFeedback(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(DevFeedback record) async {
    final previous = _box.get(record.id);
    try {
      await _box.put(record.id, encodeDevFeedback(record));
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

  @override
  Future<int> nextSerial() async {
    final raw = _box.get(kDevFeedbackSerialKey);
    final current = int.tryParse(raw ?? '') ?? 1;
    final n = current < 1 ? 1 : current;
    await _box.put(kDevFeedbackSerialKey, '${n + 1}');
    return n;
  }
}

class HivePracticeHadithRepository implements PracticeHadithRepository {
  HivePracticeHadithRepository(this._box);

  final Box<String> _box;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<PracticeHadithRecord>> allHealthy() async {
    _corrupt.clear();
    final healthy = <PracticeHadithRecord>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final parsed = decodePracticeHadith(raw);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add('$key');
      } else {
        healthy.add(parsed.record!);
      }
    }
    return orderedPracticeHadithRegister(healthy);
  }

  @override
  Future<PracticeHadithRecord?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    final parsed = decodePracticeHadith(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(PracticeHadithRecord record) async {
    final previous = _box.get(record.id);
    try {
      await _box.put(record.id, encodePracticeHadith(record));
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

class HivePersonalQuranVerseRepository implements PersonalQuranVerseRepository {
  HivePersonalQuranVerseRepository(this._box);

  final Box<String> _box;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<PersonalQuranVerse>> allHealthy() async {
    _corrupt.clear();
    final healthy = <PersonalQuranVerse>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final parsed = decodePersonalQuranVerse(raw);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add('$key');
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) {
      final byDate = a.addedDateKey.compareTo(b.addedDateKey);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
    return healthy;
  }

  @override
  Future<PersonalQuranVerse?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    final parsed = decodePersonalQuranVerse(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(PersonalQuranVerse record) async {
    final previous = _box.get(record.id);
    try {
      await _box.put(record.id, encodePersonalQuranVerse(record));
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

class HivePersonalHadithRepository implements PersonalHadithRepository {
  HivePersonalHadithRepository(this._box);

  final Box<String> _box;
  final List<String> _corrupt = [];

  @override
  List<String> get corruptKeys => List.unmodifiable(_corrupt);

  @override
  Future<List<PersonalHadith>> allHealthy() async {
    _corrupt.clear();
    final healthy = <PersonalHadith>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final parsed = decodePersonalHadith(raw);
      if (parsed.corrupt || parsed.record == null) {
        _corrupt.add('$key');
      } else {
        healthy.add(parsed.record!);
      }
    }
    healthy.sort((a, b) {
      final byDate = a.addedDateKey.compareTo(b.addedDateKey);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
    return healthy;
  }

  @override
  Future<PersonalHadith?> getById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    final parsed = decodePersonalHadith(raw);
    if (parsed.corrupt) {
      if (!_corrupt.contains(id)) _corrupt.add(id);
      return null;
    }
    return parsed.record;
  }

  @override
  Future<void> save(PersonalHadith record) async {
    final previous = _box.get(record.id);
    try {
      await _box.put(record.id, encodePersonalHadith(record));
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
  static const _customSelectionSets = 'custom_selection_sets';
  static const _quotationCadence = 'quotation_cadence';
  static const _reflectionHoldPeriod = 'reflection_hold_period';
  static const _reflectionHoldIndex = 'reflection_hold_index';
  static const _baselines = 'personal_baselines';
  static const _aspirations = 'personal_aspirations';
  static const _weeklyJournals = 'weekly_journals';
  static const _hadithFocus = 'hadith_memorisation_focus';
  static const _practiceHadithIndex = 'practice_hadith_browse_index';
  static const _practiceQuranIndex = 'practice_quran_browse_index';
  static const _ramadanOffset = 'ramadan_calendar_offset_days';
  static const _fastingRamadanHistory = 'show_fasting_ramadan_history';
  static const _mixHiddenHint = 'mix_hidden_domain_hint';
  static const _appLock = 'app_lock_enabled';
  static const _salahActivityColours = 'salah_activity_colours';
  static const _arabicScriptFace = 'arabic_script_face';
  static const _arabicScriptSize = 'arabic_script_size';

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
      decodeVisibleDomains(_box.get(_visibleDomains), migrateNamedPreset: true);

  @override
  PersonalMix get personalMix => decodePersonalMix(_box.get(_personalMix));

  @override
  CustomSelectionSetsRecord get customSelectionSets =>
      decodeCustomSelectionSets(_box.get(_customSelectionSets));

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
  Future<void> setCustomSelectionSets(CustomSelectionSetsRecord value) =>
      _box.put(_customSelectionSets, encodeCustomSelectionSets(value));

  @override
  Future<void> applyWorkingSelection({
    required Set<MonitorDomain> domains,
    required PersonalMix mix,
    required CustomSelectionSetsRecord sets,
  }) async {
    final previousDomains = _box.get(_visibleDomains);
    final previousMix = _box.get(_personalMix);
    final previousSets = _box.get(_customSelectionSets);
    try {
      await _box.putAll({
        _visibleDomains: encodeVisibleDomains(domains),
        _personalMix: encodePersonalMix(mix),
        _customSelectionSets: encodeCustomSelectionSets(sets),
      });
    } catch (_) {
      await _restorePref(_visibleDomains, previousDomains);
      await _restorePref(_personalMix, previousMix);
      await _restorePref(_customSelectionSets, previousSets);
      rethrow;
    }
  }

  Future<void> _restorePref(String key, String? previous) {
    if (previous == null) return _box.delete(key);
    return _box.put(key, previous);
  }

  @override
  Future<void> activateCustomSlot(int id) async {
    final slotId = normalizeCustomSlotId(id);
    if (slotId == null) return;
    final record = customSelectionSets;
    final slot = record.slotById(slotId);
    await applyWorkingSelection(
      domains: slot.domains,
      mix: slot.mix,
      sets: CustomSelectionSetsRecord(
        activeSlotId: slotId,
        slots: record.slots,
      ),
    );
  }

  @override
  Future<void> saveWorkingToCustomSlot(int id) async {
    final slotId = normalizeCustomSlotId(id);
    if (slotId == null) return;
    final record = customSelectionSets;
    final current = record.slotById(slotId);
    await setCustomSelectionSets(
      record
          .replacingSlot(
            current.copyWith(
              domains: Set<MonitorDomain>.from(visibleDomains),
              mix: personalMix,
            ),
          )
          .copyWithActive(slotId),
    );
  }

  @override
  Future<void> renameCustomSlot(int id, String name) async {
    final slotId = normalizeCustomSlotId(id);
    if (slotId == null) return;
    final record = customSelectionSets;
    await setCustomSelectionSets(
      record.replacingSlot(
        record.slotById(slotId).copyWith(name: sanitizeCustomSlotName(name)),
      ),
    );
  }

  @override
  Future<void> clearWorkingSelection() {
    return applyWorkingSelection(
      domains: <MonitorDomain>{},
      mix: PersonalMix.sameAsDomains,
      sets: CustomSelectionSetsRecord(
        activeSlotId: null,
        slots: customSelectionSets.slots,
      ),
    );
  }

  @override
  Future<void> clearCustomSlot(int id) async {
    final slotId = normalizeCustomSlotId(id);
    if (slotId == null) return;
    final current = customSelectionSets.slotById(slotId);
    final nextSets = customSelectionSets.replacingSlot(
      current.copyWith(
        domains: <MonitorDomain>{},
        mix: PersonalMix.sameAsDomains,
      ),
    );
    if (customSelectionSets.activeSlotId == slotId) {
      await applyWorkingSelection(
        domains: <MonitorDomain>{},
        mix: PersonalMix.sameAsDomains,
        sets: nextSets,
      );
    } else {
      await setCustomSelectionSets(nextSets);
    }
  }

  @override
  QuotationCadence get quotationCadence =>
      QuotationCadenceX.fromId(_box.get(_quotationCadence));

  @override
  String? get reflectionHoldPeriod {
    final raw = _box.get(_reflectionHoldPeriod);
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  @override
  int? get reflectionHoldIndex =>
      int.tryParse(_box.get(_reflectionHoldIndex) ?? '');

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
  Future<void> setReflectionHold({
    required String period,
    required int index,
  }) async {
    await _box.put(_reflectionHoldPeriod, period);
    await _box.put(_reflectionHoldIndex, '$index');
  }

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
  int get practiceHadithBrowseIndex =>
      int.tryParse(_box.get(_practiceHadithIndex) ?? '') ?? 0;

  @override
  Future<void> setPracticeHadithBrowseIndex(int value) =>
      _box.put(_practiceHadithIndex, '$value');

  @override
  int get practiceQuranBrowseIndex =>
      int.tryParse(_box.get(_practiceQuranIndex) ?? '') ?? 0;

  @override
  Future<void> setPracticeQuranBrowseIndex(int value) =>
      _box.put(_practiceQuranIndex, '$value');

  Future<void> discardLegacyHajjStatus() async {
    await _box.delete(kLegacyHajjStatusPrefsKey);
  }

  bool get hasLegacyHajjStatus => _box.containsKey(kLegacyHajjStatusPrefsKey);

  @override
  int get ramadanCalendarOffsetDays {
    final parsed = int.tryParse(_box.get(_ramadanOffset) ?? '') ?? 0;
    if (parsed < -1) return -1;
    if (parsed > 1) return 1;
    return parsed;
  }

  @override
  Future<void> setRamadanCalendarOffsetDays(int value) {
    final clamped = value < -1
        ? -1
        : value > 1
        ? 1
        : value;
    return _box.put(_ramadanOffset, '$clamped');
  }

  @override
  bool get showFastingRamadanHistory => _flag(_fastingRamadanHistory);

  @override
  Future<void> setShowFastingRamadanHistory(bool value) =>
      _setFlag(_fastingRamadanHistory, value);

  @override
  bool get mixHiddenDomainHintShown => _flag(_mixHiddenHint);

  @override
  Future<void> setMixHiddenDomainHintShown(bool value) =>
      _setFlag(_mixHiddenHint, value);

  @override
  bool get appLockEnabled => _flag(_appLock);

  @override
  Future<void> setAppLockEnabled(bool value) => _setFlag(_appLock, value);

  @override
  bool get salahActivityColours => _flag(_salahActivityColours);

  @override
  Future<void> setSalahActivityColours(bool value) =>
      _setFlag(_salahActivityColours, value);

  @override
  ArabicScriptFace get arabicScriptFace =>
      ArabicScriptFaceX.fromId(_box.get(_arabicScriptFace));

  @override
  Future<void> setArabicScriptFace(ArabicScriptFace value) =>
      _box.put(_arabicScriptFace, value.id);

  @override
  double get arabicScriptSize => clampArabicScriptSize(
    double.tryParse(_box.get(_arabicScriptSize) ?? '') ??
        kDefaultArabicScriptSize,
  );

  @override
  Future<void> setArabicScriptSize(double value) =>
      _box.put(_arabicScriptSize, '${clampArabicScriptSize(value)}');
}

class HiveHajjStoreRepository implements HajjStoreRepository {
  HiveHajjStoreRepository(this._box);

  final Box<String> _box;

  @override
  HajjStore store = const HajjStore();

  @override
  HajjStoreDecodeKind loadKind = HajjStoreDecodeKind.missing;

  @override
  bool get hasUnknownSchema => loadKind == HajjStoreDecodeKind.unknownVersion;

  @override
  Future<void> save(HajjStore next) async {
    if (hasUnknownSchema) return;
    final encoded = encodeHajjStore(next);
    await _box.put(kHajjStoreDocumentKey, encoded);
    store = next;
    loadKind = HajjStoreDecodeKind.ok;
  }

  @override
  Future<HajjStore> initializeIfNeeded() async {
    final raw = _box.get(kHajjStoreDocumentKey);
    final decoded = decodeHajjStore(raw);
    loadKind = decoded.kind;
    if (decoded.kind == HajjStoreDecodeKind.unknownVersion) {
      store = const HajjStore();
      return store;
    }
    if (decoded.kind == HajjStoreDecodeKind.ok && decoded.store != null) {
      store = decoded.store!;
      return store;
    }
    if (decoded.kind == HajjStoreDecodeKind.corrupt) {
      store = const HajjStore();
      return store;
    }
    store = const HajjStore();
    loadKind = HajjStoreDecodeKind.ok;
    await _box.put(kHajjStoreDocumentKey, encodeHajjStore(store));
    return store;
  }
}

Future<
  ({
    HiveCheckInRepository checkIns,
    HiveResponseRepository responses,
    HiveAppPrefs prefs,
    HiveDomainActionRepository domainActions,
    HiveDevFeedbackRepository devFeedback,
    HivePracticeHadithRepository practiceHadith,
    HivePersonalQuranVerseRepository personalQuran,
    HivePersonalHadithRepository personalHadith,
    HiveHajjStoreRepository hajj,
  })
>
openHiveRepositories() async {
  await Hive.initFlutter();
  final checkIns = await Hive.openBox<String>(checkInsBoxName);
  final responses = await Hive.openBox<String>(responsesBoxName);
  final prefs = await Hive.openBox<String>(prefsBoxName);
  final domainActions = await Hive.openBox<String>(domainActionsBoxName);
  final devFeedback = await Hive.openBox<String>(devFeedbackBoxName);
  final practiceHadith = await Hive.openBox<String>(practiceHadithBoxName);
  final personalQuran = await Hive.openBox<String>(personalQuranBoxName);
  final personalHadith = await Hive.openBox<String>(personalHadithBoxName);
  final hajjBox = await Hive.openBox<String>(hajjStoreBoxName);
  final hivePrefs = HiveAppPrefs(prefs);
  await hivePrefs.discardLegacyHajjStatus();
  final hajj = HiveHajjStoreRepository(hajjBox);
  await hajj.initializeIfNeeded();
  return (
    checkIns: HiveCheckInRepository(checkIns),
    responses: HiveResponseRepository(responses),
    prefs: hivePrefs,
    domainActions: HiveDomainActionRepository(domainActions),
    devFeedback: HiveDevFeedbackRepository(devFeedback),
    practiceHadith: HivePracticeHadithRepository(practiceHadith),
    personalQuran: HivePersonalQuranVerseRepository(personalQuran),
    personalHadith: HivePersonalHadithRepository(personalHadith),
    hajj: hajj,
  );
}
