enum MonitorDomain {
  salah,
  quran,
  hadith,
  dhikr,
  akhlaq,
  huquq,
  knowledge,
  time,
  health,
  wealth,
  ummah,
  fasting,
  hajj,
  charity,
}

/// Salah, Qur’an, and Dhikr & Dua.
/// Other domains stay available in Settings → Domains.
const kBasicDhikrVisibleDomains = {
  MonitorDomain.salah,
  MonitorDomain.quran,
  MonitorDomain.dhikr,
};

/// Exact six-domain set stored by the previous named preset (Akhlaq on).
/// Working prefs that still hold this set are read as [kBasicDhikrVisibleDomains].
/// Saved custom slots keep the stored set.
const kLegacyBasicAkhlaqVisibleDomains = {
  MonitorDomain.salah,
  MonitorDomain.quran,
  MonitorDomain.hadith,
  MonitorDomain.akhlaq,
  MonitorDomain.huquq,
  MonitorDomain.charity,
};

/// Exact six-domain set stored after the named chip first became Dhikr.
const kLegacySixDomainDhikrPreset = {
  MonitorDomain.salah,
  MonitorDomain.quran,
  MonitorDomain.hadith,
  MonitorDomain.dhikr,
  MonitorDomain.huquq,
  MonitorDomain.charity,
};

/// Shown domain weeks use a full item×day matrix. Named mix still compact-hides domains the mix does not touch.
bool usesCompactHomeWeek(MonitorDomain domain) {
  switch (domain) {
    case MonitorDomain.salah:
    case MonitorDomain.quran:
    case MonitorDomain.hadith:
    case MonitorDomain.dhikr:
    case MonitorDomain.akhlaq:
    case MonitorDomain.huquq:
    case MonitorDomain.knowledge:
    case MonitorDomain.time:
    case MonitorDomain.health:
    case MonitorDomain.wealth:
    case MonitorDomain.ummah:
    case MonitorDomain.fasting:
    case MonitorDomain.hajj:
    case MonitorDomain.charity:
      return false;
  }
}

const kLegacyAllDomainIds = {
  'salah',
  'quran',
  'dhikr',
  'fasting',
  'family',
  'charity',
  'hadith',
};

bool sameVisibleDomains(Set<MonitorDomain> a, Set<MonitorDomain> b) {
  return a.length == b.length && a.containsAll(b);
}

extension MonitorDomainX on MonitorDomain {
  String get id => name;

  String get label => switch (this) {
    MonitorDomain.salah => 'Salah & Prayer Quality',
    MonitorDomain.quran => 'Qur’an Engagement',
    MonitorDomain.hadith => 'Hadith & Living Sunnah',
    MonitorDomain.dhikr => 'Dhikr & Dua',
    MonitorDomain.akhlaq => 'Character & Morals (Akhlaq)',
    MonitorDomain.huquq => 'Rights of Others (Huquq al-Ibad)',
    MonitorDomain.knowledge => 'Knowledge & Beneficial Speech',
    MonitorDomain.time => 'Time & Barakah',
    MonitorDomain.health => 'Physical Health & Energy',
    MonitorDomain.wealth => 'Wealth & Stewardship',
    MonitorDomain.ummah => 'Ummah',
    MonitorDomain.fasting => 'Fasting',
    MonitorDomain.hajj => 'Hajj',
    MonitorDomain.charity => 'Charity',
  };

  /// Compact Home stage label. Full [label] stays on the week card.
  String get shortLabel => switch (this) {
    MonitorDomain.salah => 'Salah',
    MonitorDomain.quran => 'Qur’an',
    MonitorDomain.hadith => 'Hadith',
    MonitorDomain.dhikr => 'Dhikr',
    MonitorDomain.akhlaq => 'Character',
    MonitorDomain.huquq => 'Rights',
    MonitorDomain.knowledge => 'Knowledge',
    MonitorDomain.time => 'Time',
    MonitorDomain.health => 'Health',
    MonitorDomain.wealth => 'Wealth',
    MonitorDomain.ummah => 'Ummah',
    MonitorDomain.fasting => 'Fasting',
    MonitorDomain.hajj => 'Hajj',
    MonitorDomain.charity => 'Charity',
  };

  /// Orientation only. Not a scored field and not a spiritual grade.
  String? get focusQuestion => switch (this) {
    MonitorDomain.salah => 'Was my heart present when I stood before Allah?',
    MonitorDomain.quran => 'Did I let the Qur’an speak to me today?',
    MonitorDomain.hadith => 'Did a teaching of the Prophet ﷺ reach my day?',
    MonitorDomain.dhikr => 'Did I remember Allah outside of prayer?',
    MonitorDomain.akhlaq =>
      'Did my behavior today invite people toward goodness?',
    MonitorDomain.huquq =>
      'Did I fulfill, harm, or neglect anyone’s right over me?',
    MonitorDomain.knowledge =>
      'Did I learn something true, and did I speak only what was beneficial?',
    MonitorDomain.time => 'Did I treat my time as a trust from Allah?',
    MonitorDomain.health => 'Did I care for the body Allah entrusted to me?',
    MonitorDomain.wealth => 'Did my spending and earning please Allah?',
    MonitorDomain.ummah => 'Did I serve anyone beyond myself today?',
    MonitorDomain.hajj => 'Have I named how Hajj stands with me — as I see it, not as the app decides?',
    _ => null,
  };
}

Set<MonitorDomain> decodeVisibleDomains(
  String? raw, {
  bool migrateNamedPreset = false,
}) {
  if (raw == null) {
    return Set<MonitorDomain>.from(kBasicDhikrVisibleDomains);
  }
  if (raw.isEmpty) return <MonitorDomain>{};
  final stored = <String>{};
  final next = <MonitorDomain>{};
  for (final part in raw.split(',')) {
    final id = part.trim();
    if (id.isEmpty) continue;
    stored.add(id);
    for (final domain in MonitorDomain.values) {
      if (domain.id == id) next.add(domain);
    }
  }
  if (stored.length == kLegacyAllDomainIds.length &&
      stored.every(kLegacyAllDomainIds.contains)) {
    return Set<MonitorDomain>.from(MonitorDomain.values);
  }
  if (migrateNamedPreset &&
      (sameVisibleDomains(next, kLegacyBasicAkhlaqVisibleDomains) ||
          sameVisibleDomains(next, kLegacySixDomainDhikrPreset))) {
    return Set<MonitorDomain>.from(kBasicDhikrVisibleDomains);
  }
  return next;
}

String encodeVisibleDomains(Set<MonitorDomain> value) {
  return [
    for (final domain in MonitorDomain.values)
      if (value.contains(domain)) domain.id,
  ].join(',');
}

String visibleDomainsSummary(Set<MonitorDomain> value) {
  if (value.length == MonitorDomain.values.length) return 'All domains';
  if (value.isEmpty) return 'None shown';
  if (sameVisibleDomains(value, kBasicDhikrVisibleDomains)) {
    return 'Salah, Qur’an & Dhikr';
  }
  return [
    for (final domain in MonitorDomain.values)
      if (value.contains(domain)) domain.label,
  ].join(', ');
}

MonitorDomain? monitorDomainForStorageKey(String key) {
  final prefix = key.split('.').first;
  return switch (prefix) {
    'dhikr' => MonitorDomain.dhikr,
    'akhlaq' => MonitorDomain.akhlaq,
    'huquq' => MonitorDomain.huquq,
    'knowledge' => MonitorDomain.knowledge,
    'time' => MonitorDomain.time,
    'health' => MonitorDomain.health,
    'wealth' => MonitorDomain.wealth,
    'ummah' => MonitorDomain.ummah,
    'fasting' => MonitorDomain.fasting,
    'hajj' => MonitorDomain.hajj,
    'charity' => MonitorDomain.charity,
    'hadith' => MonitorDomain.hadith,
    _ => null,
  };
}

bool showsMonitorDomain(Set<MonitorDomain> visible, MonitorDomain domain) {
  return visible.contains(domain);
}

/// Session Home stage. Falls back to the first mix domain if [remembered] left the set.
int homeDomainStageIndex(
  List<MonitorDomain> domains,
  MonitorDomain? remembered,
) {
  if (domains.isEmpty) return 0;
  if (remembered == null) return 0;
  final index = domains.indexOf(remembered);
  return index < 0 ? 0 : index;
}
