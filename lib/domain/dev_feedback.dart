import 'monitor_domain.dart';
import 'personal_response.dart';

const int kDevFeedbackSchemaVersion = 1;
const int kDevFeedbackMaxScalars = 4000;
const String kAppVersionLabel = '1.0.0+1';

class DevFeedback {
  const DevFeedback({
    required this.id,
    required this.serial,
    required this.domain,
    required this.dateKey,
    required this.body,
    required this.createdAt,
    this.appVersion = kAppVersionLabel,
    this.schemaVersion = kDevFeedbackSchemaVersion,
  });

  final String id;
  final int serial;
  final MonitorDomain domain;
  final String dateKey;
  final String body;
  final DateTime createdAt;
  final String appVersion;
  final int schemaVersion;

  String get serialLabel => formatFeedbackSerial(serial);

  DevFeedback copyWith({String? body}) {
    return DevFeedback(
      id: id,
      serial: serial,
      domain: domain,
      dateKey: dateKey,
      body: body ?? this.body,
      createdAt: createdAt,
      appVersion: appVersion,
      schemaVersion: schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'id': id,
      'serial': serial,
      'domain': domain.id,
      'dateKey': dateKey,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'appVersion': appVersion,
    };
  }

  static DevFeedback fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final serial = json['serial'];
    final domainName = json['domain'] as String?;
    final dateKey = json['dateKey'] as String?;
    final body = json['body'] as String?;
    final created = json['createdAt'] as String?;
    if (id == null ||
        id.isEmpty ||
        serial is! int ||
        serial < 1 ||
        domainName == null ||
        dateKey == null ||
        body == null ||
        created == null) {
      throw const FormatException('Malformed DevFeedback');
    }
    final domain = MonitorDomain.values.where((d) => d.id == domainName);
    if (domain.isEmpty) {
      throw const FormatException('Unknown DevFeedback domain');
    }
    return DevFeedback(
      id: id,
      serial: serial,
      domain: domain.first,
      dateKey: dateKey,
      body: body,
      createdAt: DateTime.parse(created),
      appVersion: (json['appVersion'] as String?) ?? kAppVersionLabel,
      schemaVersion: json['schemaVersion'] is int
          ? json['schemaVersion'] as int
          : kDevFeedbackSchemaVersion,
    );
  }
}

String formatFeedbackSerial(int serial) {
  return 'FB-${serial.toString().padLeft(5, '0')}';
}

String normalizeFeedbackBody(String input) {
  final unified = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  return unified.trim().isEmpty ? '' : unified.trim();
}

ResponseTextError? validateFeedbackBody(String raw) {
  final normalized = normalizeFeedbackBody(raw);
  if (normalized.isEmpty) return ResponseTextError.empty;
  if (unicodeScalarCount(normalized) > kDevFeedbackMaxScalars) {
    return ResponseTextError.tooLong;
  }
  return null;
}

String _tsvCell(String value) {
  return value
      .replaceAll('\t', ' ')
      .replaceAll('\r\n', ' ')
      .replaceAll('\n', ' ');
}

List<DevFeedback> registerDeveloperNotes(Iterable<DevFeedback> notes) {
  final ordered = [...notes]..sort((a, b) => a.serial.compareTo(b.serial));
  return ordered;
}

String formatDevFeedbackExport(List<DevFeedback> notes) {
  final ordered = [...notes]..sort((a, b) => a.serial.compareTo(b.serial));
  final lines = <String>[
    'serial\tdomain\tdate\tappVersion\tnote',
    for (final note in ordered)
      '${note.serialLabel}\t${note.domain.shortLabel}\t${note.dateKey}\t${note.appVersion}\t${_tsvCell(note.body)}',
  ];
  return lines.join('\n');
}
