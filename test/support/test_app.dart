import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muhasabah02/app/app.dart';
import 'package:muhasabah02/application/device_unlock.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/display_calendar.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';

import 'fake_device_unlock.dart';

Set<MonitorDomain> allVisibleDomains() =>
    Set<MonitorDomain>.from(MonitorDomain.values);

Widget testApp({
  MemoryCheckInRepository? checkIns,
  MemoryResponseRepository? responses,
  MemoryAppPrefs? prefs,
  DateTime? now,
  FirstDayOfWeekPref firstDayOfWeek = FirstDayOfWeekPref.monday,
  DisplayCalendar displayCalendar = DisplayCalendar.gregorian,
  Set<MonitorDomain>? visibleDomains,
  PersonalMix? personalMix,
  bool applicationReflectionAcknowledged = true,
  bool appLockEnabled = false,
  bool salahActivityColours = false,
  DeviceUnlock? deviceUnlock,
}) {
  return ProviderScope(
    overrides: [
      checkInRepositoryProvider.overrideWithValue(
        checkIns ?? MemoryCheckInRepository(),
      ),
      responseRepositoryProvider.overrideWithValue(
        responses ?? MemoryResponseRepository(),
      ),
      deviceUnlockProvider.overrideWithValue(
        deviceUnlock ?? FakeDeviceUnlock(),
      ),
      appPrefsProvider.overrideWithValue(
        prefs ??
            MemoryAppPrefs(
              applicationReflectionAcknowledged:
                  applicationReflectionAcknowledged,
              firstDayOfWeek: firstDayOfWeek,
              displayCalendar: displayCalendar,
              visibleDomains: visibleDomains,
              personalMix: personalMix,
              appLockEnabled: appLockEnabled,
              salahActivityColours: salahActivityColours,
            ),
      ),
      if (now != null) nowProvider.overrideWithValue(now),
    ],
    child: const MuhasabahApp(),
  );
}

DailyCheckIn sampleDay(String dateKey) {
  return DailyCheckIn.empty(dateKey)
      .withPrayer(PrayerId.fajr, PrayerStatus.onTime)
      .withPrayer(PrayerId.dhuhr, PrayerStatus.late)
      .withPrayer(PrayerId.asr, PrayerStatus.missed)
      .withQuran(QuranDimension.reading, TernaryOutcome.positive)
      .withQuran(QuranDimension.applicationReflection, TernaryOutcome.positive);
}
