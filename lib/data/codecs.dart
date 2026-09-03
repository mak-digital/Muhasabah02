import 'dart:convert';

import '../domain/daily_check_in.dart';
import '../domain/personal_response.dart';

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

String encodeCheckIn(DailyCheckIn record) => jsonEncode(record.toJson());

String encodeResponse(PersonalResponse record) => jsonEncode(record.toJson());
