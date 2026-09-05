import 'dart:convert';

import '../domain/first_day_of_week.dart';
import '../domain/home_traces.dart';
import '../domain/personal_aspiration.dart';
import '../domain/personal_baseline.dart';
import '../domain/quotation_cadence.dart';

abstract class AppPrefs {
  bool get sampleSeeded;
  bool get sampleRemovedByUser;
  bool get archivePromptDismissed;
  bool get applicationReflectionAcknowledged;
  FirstDayOfWeekPref get firstDayOfWeek;
  QuotationCadence get quotationCadence;
  List<PersonalBaseline> get baselines;
  List<PersonalAspiration> get aspirations;
  String weeklyJournal(String weekKey);
  HadithMemorisationFocus get hadithMemorisationFocus;

  Future<void> setSampleSeeded(bool value);
  Future<void> setSampleRemovedByUser(bool value);
  Future<void> setArchivePromptDismissed(bool value);
  Future<void> setApplicationReflectionAcknowledged(bool value);
  Future<void> setFirstDayOfWeek(FirstDayOfWeekPref value);
  Future<void> setQuotationCadence(QuotationCadence value);
  Future<void> setBaselines(List<PersonalBaseline> value);
  Future<void> setAspirations(List<PersonalAspiration> value);
  Future<void> setWeeklyJournal(String weekKey, String text);
  Future<void> setHadithMemorisationFocus(HadithMemorisationFocus value);
}

class MemoryAppPrefs implements AppPrefs {
  MemoryAppPrefs({
    this.sampleSeeded = false,
    this.sampleRemovedByUser = false,
    this.archivePromptDismissed = false,
    this.applicationReflectionAcknowledged = true,
    this.firstDayOfWeek = FirstDayOfWeekPref.monday,
    this.quotationCadence = QuotationCadence.weekly,
    this.hadithMemorisationFocus = HadithMemorisationFocus.unanswered,
    List<PersonalBaseline>? baselines,
    List<PersonalAspiration>? aspirations,
    Map<String, String>? weeklyJournals,
  }) : baselines = List.of(baselines ?? const []),
       aspirations = List.of(aspirations ?? const []),
       _journals = Map.of(weeklyJournals ?? const {});

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
  QuotationCadence quotationCadence;

  @override
  HadithMemorisationFocus hadithMemorisationFocus;

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
