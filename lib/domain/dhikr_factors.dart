import 'context_catalog.dart';

/// Optional attentiveness on post-fard Dhikr rows. Provenance only —
/// not a khushu’ score, cause, or completion check.
class DhikrAttentivenessCatalog {
  static const reflectedMeaning = 'dhikr.attentiveness.reflectedMeaning';
  static const aware = 'dhikr.attentiveness.aware';
  static const habitual = 'dhikr.attentiveness.habitual';

  static const items = <ContextFactor>[
    ContextFactor(id: reflectedMeaning, label: 'Reflected on the meaning'),
    ContextFactor(id: aware, label: 'Aware of what I was saying'),
    ContextFactor(id: habitual, label: 'Mostly habitual recitation'),
  ];

  static List<ContextFactor> withExisting(Iterable<String> existingIds) {
    final next = [...items];
    for (final id in existingIds) {
      if (id.isEmpty) continue;
      if (next.any((factor) => factor.id == id)) continue;
      next.add(ContextFactor(id: id, label: labelFor(id)));
    }
    return next;
  }

  static String labelFor(String id) {
    for (final factor in items) {
      if (factor.id == id) return factor.label;
    }
    return ContextCatalog.labelFor(id, 'positive');
  }
}
