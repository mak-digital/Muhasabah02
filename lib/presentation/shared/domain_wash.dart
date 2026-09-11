import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/monitor_domain.dart';

(Color, Color) domainWashPair(MonitorDomain domain) {
  return switch (domain) {
    MonitorDomain.salah => (
      MuhasabahColors.salahWash,
      MuhasabahColors.salahWashDark,
    ),
    MonitorDomain.quran => (
      MuhasabahColors.quranWash,
      MuhasabahColors.quranWashDark,
    ),
    MonitorDomain.hadith => (
      MuhasabahColors.hadithWash,
      MuhasabahColors.hadithWashDark,
    ),
    MonitorDomain.dhikr => (
      MuhasabahColors.dhikrWash,
      MuhasabahColors.dhikrWashDark,
    ),
    MonitorDomain.akhlaq => (
      MuhasabahColors.akhlaqWash,
      MuhasabahColors.akhlaqWashDark,
    ),
    MonitorDomain.huquq => (
      MuhasabahColors.huquqWash,
      MuhasabahColors.huquqWashDark,
    ),
    MonitorDomain.knowledge => (
      MuhasabahColors.knowledgeWash,
      MuhasabahColors.knowledgeWashDark,
    ),
    MonitorDomain.time => (
      MuhasabahColors.timeWash,
      MuhasabahColors.timeWashDark,
    ),
    MonitorDomain.health => (
      MuhasabahColors.healthWash,
      MuhasabahColors.healthWashDark,
    ),
    MonitorDomain.wealth => (
      MuhasabahColors.wealthWash,
      MuhasabahColors.wealthWashDark,
    ),
    MonitorDomain.ummah => (
      MuhasabahColors.ummahWash,
      MuhasabahColors.ummahWashDark,
    ),
    MonitorDomain.fasting => (
      MuhasabahColors.fastingWash,
      MuhasabahColors.fastingWashDark,
    ),
    MonitorDomain.hajj => (
      MuhasabahColors.hajjWash,
      MuhasabahColors.hajjWashDark,
    ),
    MonitorDomain.charity => (
      MuhasabahColors.charityWash,
      MuhasabahColors.charityWashDark,
    ),
  };
}

Color domainWashColor(BuildContext context, MonitorDomain domain) {
  final pair = domainWashPair(domain);
  return MuhasabahColors.wash(pair.$1, pair.$2, Theme.of(context).brightness);
}
