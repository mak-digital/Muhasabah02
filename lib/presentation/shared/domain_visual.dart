import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/monitor_domain.dart';

/// Presentation-only domain identity. Color names the Domain, not performance.
class DomainColorIdentity {
  const DomainColorIdentity({
    required this.family,
    required this.washLight,
    required this.washDark,
  });

  final Color family;
  final Color washLight;
  final Color washDark;

  Color washFor(Brightness brightness) =>
      MuhasabahColors.wash(washLight, washDark, brightness);
}

/// Today overview tile name. Presentation-only; not [MonitorDomain.shortLabel].
String todayDomainLabel(MonitorDomain domain) {
  return switch (domain) {
    MonitorDomain.salah => 'Salah',
    MonitorDomain.quran => 'Qur’an',
    MonitorDomain.hadith => 'Hadith',
    MonitorDomain.dhikr => 'Dhikr',
    MonitorDomain.akhlaq => 'Akhlaq',
    MonitorDomain.huquq => 'Huquq',
    MonitorDomain.knowledge => 'Knowledge',
    MonitorDomain.time => 'Time',
    MonitorDomain.health => 'Health',
    MonitorDomain.wealth => 'Wealth',
    MonitorDomain.ummah => 'Ummah',
    MonitorDomain.fasting => 'Fasting',
    MonitorDomain.hajj => 'Hajj',
    MonitorDomain.charity => 'Charity',
  };
}

DomainColorIdentity domainColorIdentity(MonitorDomain domain) {
  return switch (domain) {
    MonitorDomain.salah => const DomainColorIdentity(
      family: MuhasabahColors.salahFamily,
      washLight: MuhasabahColors.salahWash,
      washDark: MuhasabahColors.salahWashDark,
    ),
    MonitorDomain.quran => const DomainColorIdentity(
      family: MuhasabahColors.quranFamily,
      washLight: MuhasabahColors.quranWash,
      washDark: MuhasabahColors.quranWashDark,
    ),
    MonitorDomain.hadith => const DomainColorIdentity(
      family: MuhasabahColors.hadithFamily,
      washLight: MuhasabahColors.hadithWash,
      washDark: MuhasabahColors.hadithWashDark,
    ),
    MonitorDomain.dhikr => const DomainColorIdentity(
      family: MuhasabahColors.dhikrFamily,
      washLight: MuhasabahColors.dhikrWash,
      washDark: MuhasabahColors.dhikrWashDark,
    ),
    MonitorDomain.akhlaq => const DomainColorIdentity(
      family: MuhasabahColors.akhlaqFamily,
      washLight: MuhasabahColors.akhlaqWash,
      washDark: MuhasabahColors.akhlaqWashDark,
    ),
    MonitorDomain.huquq => const DomainColorIdentity(
      family: MuhasabahColors.huquqFamily,
      washLight: MuhasabahColors.huquqWash,
      washDark: MuhasabahColors.huquqWashDark,
    ),
    MonitorDomain.knowledge => const DomainColorIdentity(
      family: MuhasabahColors.knowledgeFamily,
      washLight: MuhasabahColors.knowledgeWash,
      washDark: MuhasabahColors.knowledgeWashDark,
    ),
    MonitorDomain.time => const DomainColorIdentity(
      family: MuhasabahColors.timeFamily,
      washLight: MuhasabahColors.timeWash,
      washDark: MuhasabahColors.timeWashDark,
    ),
    MonitorDomain.health => const DomainColorIdentity(
      family: MuhasabahColors.healthFamily,
      washLight: MuhasabahColors.healthWash,
      washDark: MuhasabahColors.healthWashDark,
    ),
    MonitorDomain.wealth => const DomainColorIdentity(
      family: MuhasabahColors.wealthFamily,
      washLight: MuhasabahColors.wealthWash,
      washDark: MuhasabahColors.wealthWashDark,
    ),
    MonitorDomain.ummah => const DomainColorIdentity(
      family: MuhasabahColors.ummahFamily,
      washLight: MuhasabahColors.ummahWash,
      washDark: MuhasabahColors.ummahWashDark,
    ),
    MonitorDomain.fasting => const DomainColorIdentity(
      family: MuhasabahColors.fastingFamily,
      washLight: MuhasabahColors.fastingWash,
      washDark: MuhasabahColors.fastingWashDark,
    ),
    MonitorDomain.hajj => const DomainColorIdentity(
      family: MuhasabahColors.hajjFamily,
      washLight: MuhasabahColors.hajjWash,
      washDark: MuhasabahColors.hajjWashDark,
    ),
    MonitorDomain.charity => const DomainColorIdentity(
      family: MuhasabahColors.charityFamily,
      washLight: MuhasabahColors.charityWash,
      washDark: MuhasabahColors.charityWashDark,
    ),
  };
}
