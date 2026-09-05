enum AspirationKind {
  maintainPattern,
  reciteQuranMore,
  contactParentsMore,
  improveFajrConsistency,
  custom,
}

extension AspirationKindX on AspirationKind {
  String get label => switch (this) {
    AspirationKind.maintainPattern => 'Maintain current pattern',
    AspirationKind.reciteQuranMore => 'Read Qur’an more regularly',
    AspirationKind.contactParentsMore => 'Contact parents more regularly',
    AspirationKind.improveFajrConsistency => 'Improve consistency of Fajr',
    AspirationKind.custom => 'Custom aspiration',
  };
}

class PersonalAspiration {
  const PersonalAspiration({
    required this.id,
    required this.kind,
    this.customText,
  });

  final String id;
  final AspirationKind kind;
  final String? customText;

  String get displayLabel {
    if (kind == AspirationKind.custom) {
      final text = customText?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return kind.label;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    if (customText != null) 'customText': customText,
  };

  static PersonalAspiration? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'] as String?;
    if (id == null) return null;
    final kind = AspirationKind.values.firstWhere(
      (item) => item.name == json['kind'],
      orElse: () => AspirationKind.custom,
    );
    return PersonalAspiration(
      id: id,
      kind: kind,
      customText: json['customText'] as String?,
    );
  }
}
