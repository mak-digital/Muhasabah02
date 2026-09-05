class SituationNote {
  const SituationNote({required this.id, required this.label});

  final String id;
  final String label;
}

class SituationNoteCatalog {
  static const options = [
    SituationNote(id: 'travel', label: 'Travel'),
    SituationNote(id: 'illness', label: 'Illness'),
    SituationNote(id: 'ramadan', label: 'Ramadan'),
    SituationNote(id: 'exams', label: 'Exams'),
    SituationNote(id: 'newJob', label: 'New Job'),
    SituationNote(id: 'marriage', label: 'Marriage'),
    SituationNote(id: 'familyEvent', label: 'Family Event'),
    SituationNote(id: 'bereavement', label: 'Bereavement'),
    SituationNote(id: 'custom', label: 'Custom'),
  ];

  static String labelFor(String id) {
    for (final option in options) {
      if (option.id == id) return option.label;
    }
    return id;
  }
}

class SituationNotes {
  const SituationNotes({this.ids = const [], this.customText});

  final List<String> ids;
  final String? customText;

  bool get isEmpty =>
      ids.isEmpty && (customText == null || customText!.trim().isEmpty);

  Map<String, dynamic> toJson() => {
    if (ids.isNotEmpty) 'ids': ids,
    if (customText != null && customText!.trim().isNotEmpty)
      'custom': customText!.trim(),
  };

  static SituationNotes fromJson(Object? json) {
    if (json is! Map) return const SituationNotes();
    final rawIds = json['ids'];
    final ids = <String>[];
    if (rawIds is List) {
      for (final item in rawIds) {
        if (item is String && item.isNotEmpty) ids.add(item);
      }
    }
    final custom = json['custom'];
    return SituationNotes(
      ids: ids,
      customText: custom is String && custom.trim().isNotEmpty
          ? custom.trim()
          : null,
    );
  }

  List<String> get displayLabels {
    final labels = [
      for (final id in ids)
        if (id != 'custom') SituationNoteCatalog.labelFor(id),
    ];
    if (customText != null && customText!.trim().isNotEmpty) {
      labels.add(customText!.trim());
    }
    return labels;
  }
}
