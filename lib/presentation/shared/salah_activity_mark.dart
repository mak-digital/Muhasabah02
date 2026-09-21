import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/activities.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/prayer.dart';
import 'state_marker.dart';

class SalahActivityMark {
  const SalahActivityMark({
    required this.kind,
    required this.color,
    required this.label,
  });

  final MarkerKind kind;
  final Color color;
  final String label;

  static const congregationOnTime = Color(0xFF1565C0);
  static const joinedCongregationLate = Color(0xFF2E7D32);
  static const smallCongregation = Color(0xFF66BB6A);
  static const aloneOnTime = Color(0xFFC0CA33);
  static const excused = Color(0xFFC0CA33);
  static const prayedLate = Color(0xFFFBC02D);
  static const missedMadeUp = Color(0xFFF57C00);
  static const missed = Color(0xFFD32F2F);
  static const unanswered = Color(0xFFBDBDBD);
  static const other = Color(0xFF616161);

  static Color colourForId(String activityId) {
    return switch (activityId) {
      'congregationOnTime' => congregationOnTime,
      'joinedCongregationLate' => joinedCongregationLate,
      'smallCongregation' => smallCongregation,
      'aloneOnTime' => aloneOnTime,
      'excused' => excused,
      'prayedLate' => prayedLate,
      'missedMadeUp' => missedMadeUp,
      'missed' => missed,
      ActivityIds.unanswered => unanswered,
      ActivityIds.other => other,
      _ => MuhasabahColors.mark,
    };
  }

  static MarkerKind kindForStatus(
    PrayerStatus status, {
    required bool activityColours,
  }) {
    if (activityColours) return MarkerKind.filled;
    return switch (status) {
      PrayerStatus.onTime ||
      PrayerStatus.excused ||
      PrayerStatus.other => MarkerKind.filled,
      PrayerStatus.late => MarkerKind.outlined,
      PrayerStatus.missed => MarkerKind.missed,
      PrayerStatus.unanswered => MarkerKind.unanswered,
    };
  }

  static SalahActivityMark resolve({
    required PrayerStatus status,
    required String activityId,
    required bool activityColours,
  }) {
    final option = ActivityCatalog.find(ActivityCatalog.salah, activityId);
    return SalahActivityMark(
      kind: kindForStatus(status, activityColours: activityColours),
      color: activityColours
          ? colourForId(activityId)
          : MuhasabahColors.mark,
      label: option?.label ?? status.label,
    );
  }

  static SalahActivityMark forPrayer({
    required DailyCheckIn? record,
    required PrayerId prayer,
    required bool activityColours,
  }) {
    final status = record?.prayer(prayer) ?? PrayerStatus.unanswered;
    final activityId =
        record?.activityFor(ActivityCatalog.salahKey(prayer)).id ??
        ActivityCatalog.canonicalSalahId(status);
    return resolve(
      status: status,
      activityId: activityId,
      activityColours: activityColours,
    );
  }

  static SalahActivityMark forJumuah({
    required DailyCheckIn? record,
    required bool activityColours,
  }) {
    final status = record?.jumuah ?? PrayerStatus.unanswered;
    return resolve(
      status: status,
      activityId: ActivityCatalog.canonicalSalahId(status),
      activityColours: activityColours,
    );
  }
}
