import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muhasabah02/app/app.dart';
import 'package:muhasabah02/application/providers.dart';
import 'package:muhasabah02/data/memory_repositories.dart';
import 'package:muhasabah02/domain/daily_check_in.dart';
import 'package:muhasabah02/domain/prayer.dart';
import 'package:muhasabah02/domain/quran.dart';

Widget testApp({
  MemoryCheckInRepository? checkIns,
  MemoryResponseRepository? responses,
  DateTime? now,
}) {
  return ProviderScope(
    overrides: [
      checkInRepositoryProvider.overrideWithValue(
        checkIns ?? MemoryCheckInRepository(),
      ),
      responseRepositoryProvider.overrideWithValue(
        responses ?? MemoryResponseRepository(),
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
