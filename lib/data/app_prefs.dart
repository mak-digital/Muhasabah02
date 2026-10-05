import 'dart:convert';

import '../domain/custom_selection_set.dart';
import '../domain/display_calendar.dart';
import '../domain/first_day_of_week.dart';
import '../domain/home_traces.dart';
import '../domain/monitor_domain.dart';
import '../domain/personal_aspiration.dart';
import '../domain/personal_baseline.dart';
import '../domain/personal_mix.dart';
import '../domain/quotation_cadence.dart';

abstract class AppPrefs {
  bool get sampleSeeded;
  bool get sampleRemovedByUser;
  bool get archivePromptDismissed;
  bool get applicationReflectionAcknowledged;
  FirstDayOfWeekPref get firstDayOfWeek;
  DisplayCalendar get displayCalendar;
  Set<MonitorDomain> get visibleDomains;
  PersonalMix get personalMix;
  CustomSelectionSetsRecord get customSelectionSets;
  QuotationCadence get quotationCadence;
  List<PersonalBaseline> get baselines;
  List<PersonalAspiration> get aspirations;
  String weeklyJournal(String weekKey);
  HadithMemorisationFocus get hadithMemorisationFocus;
  HajjStatus get hajjStatus;
  bool get mixHiddenDomainHintShown;
  bool get appLockEnabled;
  bool get salahActivityColours;

  Future<void> setSampleSeeded(bool value);
  Future<void> setSampleRemovedByUser(bool value);
  Future<void> setArchivePromptDismissed(bool value);
  Future<void> setApplicationReflectionAcknowledged(bool value);
  Future<void> setFirstDayOfWeek(FirstDayOfWeekPref value);
  Future<void> setDisplayCalendar(DisplayCalendar value);
  Future<void> setVisibleDomains(Set<MonitorDomain> value);
  Future<void> setPersonalMix(PersonalMix value);
  Future<void> setCustomSelectionSets(CustomSelectionSetsRecord value);
  Future<void> applyWorkingSelection({
    required Set<MonitorDomain> domains,
    required PersonalMix mix,
    required CustomSelectionSetsRecord sets,
  });
  Future<void> activateCustomSlot(int id);
  Future<void> saveWorkingToCustomSlot(int id);
  Future<void> renameCustomSlot(int id, String name);
  Future<void> clearWorkingSelection();
  Future<void> clearCustomSlot(int id);
  Future<void> setQuotationCadence(QuotationCadence value);
  Future<void> setBaselines(List<PersonalBaseline> value);
  Future<void> setAspirations(List<PersonalAspiration> value);
  Future<void> setWeeklyJournal(String weekKey, String text);
  Future<void> setHadithMemorisationFocus(HadithMemorisationFocus value);
  Future<void> setHajjStatus(HajjStatus value);
  Future<void> setMixHiddenDomainHintShown(bool value);
  Future<void> setAppLockEnabled(bool value);
  Future<void> setSalahActivityColours(bool value);
}

class MemoryAppPrefs implements AppPrefs {
  MemoryAppPrefs({
    this.sampleSeeded = false,
    this.sampleRemovedByUser = false,
    this.archivePromptDismissed = false,
    this.applicationReflectionAcknowledged = true,
    this.firstDayOfWeek = FirstDayOfWeekPref.monday,
    this.displayCalendar = DisplayCalendar.gregorian,
    Set<MonitorDomain>? visibleDomains,
    PersonalMix? personalMix,
    CustomSelectionSetsRecord? customSelectionSets,
    this.quotationCadence = QuotationCadence.weekly,
    this.hadithMemorisationFocus = HadithMemorisationFocus.unanswered,
    this.hajjStatus = HajjStatus.unanswered,
    this.mixHiddenDomainHintShown = false,
    this.appLockEnabled = false,
    this.salahActivityColours = false,
    List<PersonalBaseline>? baselines,
    List<PersonalAspiration>? aspirations,
    Map<String, String>? weeklyJournals,
  }) : baselines = List.of(baselines ?? const []),
       aspirations = List.of(aspirations ?? const []),
       _journals = Map.of(weeklyJournals ?? const {}),
       visibleDomains = Set<MonitorDomain>.from(
         visibleDomains ?? kBasicDhikrVisibleDomains,
       ),
       personalMix = personalMix ?? PersonalMix.sameAsDomains,
       customSelectionSets =
           customSelectionSets ?? CustomSelectionSetsRecord.empty();

  @override
  bool sampleSeeded;
  @override
  bool sampleRemovedByUser;
  @override
  bool archivePromptDismissed;
  @override
  bool applicationReflectionAcknowledged;

  @override
  FirstDayOfWeekPref firstDayOfWeek;

  @override
  DisplayCalendar displayCalendar;

  @override
  Set<MonitorDomain> visibleDomains;

  @override
  PersonalMix personalMix;

  @override
  CustomSelectionSetsRecord customSelectionSets;

  int mutationCount = 0;
  bool throwOnApplyWorkingSelection = false;

  @override
  QuotationCadence quotationCadence;

  @override
  HadithMemorisationFocus hadithMemorisationFocus;

  @override
  HajjStatus hajjStatus;

  @override
  bool mixHiddenDomainHintShown;

  @override
  bool appLockEnabled;

  @override
  bool salahActivityColours;

  @override
  List<PersonalBaseline> baselines;

  @override
  List<PersonalAspiration> aspirations;

  final Map<String, String> _journals;

  @override
  String weeklyJournal(String weekKey) => _journals[weekKey] ?? '';

  @override
  Future<void> setSampleSeeded(bool value) async => sampleSeeded = value;

  @override
  Future<void> setSampleRemovedByUser(bool value) async =>
      sampleRemovedByUser = value;

  @override
  Future<void> setArchivePromptDismissed(bool value) async =>
      archivePromptDismissed = value;

  @override
  Future<void> setApplicationReflectionAcknowledged(bool value) async =>
      applicationReflectionAcknowledged = value;

  @override
  Future<void> setFirstDayOfWeek(FirstDayOfWeekPref value) async =>
      firstDayOfWeek = value;

  @override
  Future<void> setDisplayCalendar(DisplayCalendar value) async =>
      displayCalendar = value;

  @override
  Future<void> setVisibleDomains(Set<MonitorDomain> value) async {
    visibleDomains = Set<MonitorDomain>.from(value);
    mutationCount++;
  }

  @override
  Future<void> setPersonalMix(PersonalMix value) async {
    personalMix = value;
    mutationCount++;
  }

  @override
  Future<void> setCustomSelectionSets(CustomSelectionSetsRecord value) async {
    customSelectionSets = CustomSelectionSetsRecord(
      activeSlotId: value.activeSlotId,
      slots: List.of(value.slots),
    );
    mutationCount++;
  }

  @override
  Future<void> applyWorkingSelection({
    required Set<MonitorDomain> domains,
    required PersonalMix mix,
    required CustomSelectionSetsRecord sets,
  }) async {
    final previousDomains = Set<MonitorDomain>.from(visibleDomains);
    final previousMix = personalMix;
    final previousSets = CustomSelectionSetsRecord(
      activeSlotId: customSelectionSets.activeSlotId,
      slots: List.of(customSelectionSets.slots),
    );
    visibleDomains = Set<MonitorDomain>.from(domains);
    personalMix = mix;
    customSelectionSets = CustomSelectionSetsRecord(
      activeSlotId: sets.activeSlotId,
      slots: List.of(sets.slots),
    );
    if (throwOnApplyWorkingSelection) {
      visibleDomains = previousDomains;
      personalMix = previousMix;
      customSelectionSets = previousSets;
      throw StateError('prefs write failed');
    }
    mutationCount++;
  }

  @override
  Future<void> activateCustomSlot(int id) async {
    final slotId = normalizeCustomSlotId(id);
    if (slotId == null) return;
    final slot = customSelectionSets.slotById(slotId);
    await applyWorkingSelection(
      domains: slot.domains,
      mix: slot.mix,
      sets: CustomSelectionSetsRecord(
        activeSlotId: slotId,
        slots: customSelectionSets.slots,
      ),
    );
  }

  @override
  Future<void> saveWorkingToCustomSlot(int id) async {
    final slotId = normalizeCustomSlotId(id);
    if (slotId == null) return;
    final current = customSelectionSets.slotById(slotId);
    await setCustomSelectionSets(
      customSelectionSets
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
    final current = customSelectionSets.slotById(slotId);
    await setCustomSelectionSets(
      customSelectionSets.replacingSlot(
        current.copyWith(name: sanitizeCustomSlotName(name)),
      ),
    );
  }

  @override
  Future<void> clearWorkingSelection() async {
    await applyWorkingSelection(
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
  Future<void> setQuotationCadence(QuotationCadence value) async =>
      quotationCadence = value;

  @override
  Future<void> setBaselines(List<PersonalBaseline> value) async =>
      baselines = List.of(value);

  @override
  Future<void> setAspirations(List<PersonalAspiration> value) async =>
      aspirations = List.of(value);

  @override
  Future<void> setWeeklyJournal(String weekKey, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _journals.remove(weekKey);
    } else {
      _journals[weekKey] = text;
    }
  }

  @override
  Future<void> setHadithMemorisationFocus(
    HadithMemorisationFocus value,
  ) async => hadithMemorisationFocus = value;

  @override
  Future<void> setHajjStatus(HajjStatus value) async => hajjStatus = value;

  @override
  Future<void> setMixHiddenDomainHintShown(bool value) async =>
      mixHiddenDomainHintShown = value;

  @override
  Future<void> setAppLockEnabled(bool value) async => appLockEnabled = value;

  @override
  Future<void> setSalahActivityColours(bool value) async =>
      salahActivityColours = value;
}

List<PersonalBaseline> decodeBaselines(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [for (final item in decoded) ?PersonalBaseline.fromJson(item)];
  } catch (_) {
    return const [];
  }
}

String encodeBaselines(List<PersonalBaseline> value) =>
    jsonEncode([for (final item in value) item.toJson()]);

List<PersonalAspiration> decodeAspirations(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [for (final item in decoded) ?PersonalAspiration.fromJson(item)];
  } catch (_) {
    return const [];
  }
}

String encodeAspirations(List<PersonalAspiration> value) =>
    jsonEncode([for (final item in value) item.toJson()]);

Map<String, String> decodeJournals(String? raw) {
  if (raw == null || raw.isEmpty) return {};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return {
      for (final entry in decoded.entries)
        if (entry.value is String) '${entry.key}': entry.value as String,
    };
  } catch (_) {
    return {};
  }
}

String encodeJournals(Map<String, String> value) => jsonEncode(value);
