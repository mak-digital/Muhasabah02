import 'dart:convert';

import '../domain/daily_check_in.dart';
import '../domain/dev_feedback.dart';
import '../domain/domain_action.dart';
import '../domain/personal_response.dart';
import '../domain/personal_hadith.dart';
import '../domain/personal_quran_verse.dart';
import '../domain/practice_hadith.dart';

class ParsedCheckIn {
  const ParsedCheckIn._({this.record, this.corrupt = false});

  final DailyCheckIn? record;
  final bool corrupt;

  factory ParsedCheckIn.ok(DailyCheckIn record) =>
      ParsedCheckIn._(record: record);

  factory ParsedCheckIn.corrupt() => const ParsedCheckIn._(corrupt: true);
}

class ParsedResponse {
  const ParsedResponse._({this.record, this.corrupt = false});

  final PersonalResponse? record;
  final bool corrupt;

  factory ParsedResponse.ok(PersonalResponse record) =>
      ParsedResponse._(record: record);

  factory ParsedResponse.corrupt() => const ParsedResponse._(corrupt: true);
}

ParsedCheckIn decodeCheckIn(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return ParsedCheckIn.corrupt();
    final record = DailyCheckIn.fromJson(Map<String, dynamic>.from(decoded));
    return ParsedCheckIn.ok(record);
  } catch (_) {
    return ParsedCheckIn.corrupt();
  }
}

ParsedResponse decodeResponse(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return ParsedResponse.corrupt();
    final record = PersonalResponse.fromJson(
      Map<String, dynamic>.from(decoded),
    );
    return ParsedResponse.ok(record);
  } catch (_) {
    return ParsedResponse.corrupt();
  }
}

class ParsedDomainAction {
  const ParsedDomainAction._({this.record, this.corrupt = false});

  final DomainAction? record;
  final bool corrupt;

  factory ParsedDomainAction.ok(DomainAction record) =>
      ParsedDomainAction._(record: record);

  factory ParsedDomainAction.corrupt() =>
      const ParsedDomainAction._(corrupt: true);
}

class ParsedDevFeedback {
  const ParsedDevFeedback._({this.record, this.corrupt = false});

  final DevFeedback? record;
  final bool corrupt;

  factory ParsedDevFeedback.ok(DevFeedback record) =>
      ParsedDevFeedback._(record: record);

  factory ParsedDevFeedback.corrupt() =>
      const ParsedDevFeedback._(corrupt: true);
}

String encodeCheckIn(DailyCheckIn record) => jsonEncode(record.toJson());

String encodeResponse(PersonalResponse record) => jsonEncode(record.toJson());

String encodeDomainAction(DomainAction record) => jsonEncode(record.toJson());

String encodeDevFeedback(DevFeedback record) => jsonEncode(record.toJson());

class ParsedPracticeHadith {
  const ParsedPracticeHadith._({this.record, this.corrupt = false});

  final PracticeHadithRecord? record;
  final bool corrupt;

  factory ParsedPracticeHadith.ok(PracticeHadithRecord record) =>
      ParsedPracticeHadith._(record: record);

  factory ParsedPracticeHadith.corrupt() =>
      const ParsedPracticeHadith._(corrupt: true);
}

String encodePracticeHadith(PracticeHadithRecord record) =>
    jsonEncode(record.toJson());

ParsedPracticeHadith decodePracticeHadith(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return ParsedPracticeHadith.corrupt();
    final record = PracticeHadithRecord.fromJson(
      Map<String, dynamic>.from(decoded),
    );
    return ParsedPracticeHadith.ok(record);
  } catch (_) {
    return ParsedPracticeHadith.corrupt();
  }
}

class ParsedPersonalQuranVerse {
  const ParsedPersonalQuranVerse._({this.record, this.corrupt = false});

  final PersonalQuranVerse? record;
  final bool corrupt;

  factory ParsedPersonalQuranVerse.ok(PersonalQuranVerse record) =>
      ParsedPersonalQuranVerse._(record: record);

  factory ParsedPersonalQuranVerse.corrupt() =>
      const ParsedPersonalQuranVerse._(corrupt: true);
}

String encodePersonalQuranVerse(PersonalQuranVerse record) =>
    jsonEncode(record.toJson());

ParsedPersonalQuranVerse decodePersonalQuranVerse(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return ParsedPersonalQuranVerse.corrupt();
    final record = PersonalQuranVerse.fromJson(
      Map<String, dynamic>.from(decoded),
    );
    return ParsedPersonalQuranVerse.ok(record);
  } catch (_) {
    return ParsedPersonalQuranVerse.corrupt();
  }
}

class ParsedPersonalHadith {
  const ParsedPersonalHadith._({this.record, this.corrupt = false});

  final PersonalHadith? record;
  final bool corrupt;

  factory ParsedPersonalHadith.ok(PersonalHadith record) =>
      ParsedPersonalHadith._(record: record);

  factory ParsedPersonalHadith.corrupt() =>
      const ParsedPersonalHadith._(corrupt: true);
}

String encodePersonalHadith(PersonalHadith record) =>
    jsonEncode(record.toJson());

ParsedPersonalHadith decodePersonalHadith(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return ParsedPersonalHadith.corrupt();
    final record = PersonalHadith.fromJson(Map<String, dynamic>.from(decoded));
    return ParsedPersonalHadith.ok(record);
  } catch (_) {
    return ParsedPersonalHadith.corrupt();
  }
}

ParsedDomainAction decodeDomainAction(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return ParsedDomainAction.corrupt();
    final record = DomainAction.fromJson(Map<String, dynamic>.from(decoded));
    return ParsedDomainAction.ok(record);
  } catch (_) {
    return ParsedDomainAction.corrupt();
  }
}

ParsedDevFeedback decodeDevFeedback(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return ParsedDevFeedback.corrupt();
    final record = DevFeedback.fromJson(Map<String, dynamic>.from(decoded));
    return ParsedDevFeedback.ok(record);
  } catch (_) {
    return ParsedDevFeedback.corrupt();
  }
}
