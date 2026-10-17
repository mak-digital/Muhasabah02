import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/activities.dart';
import '../../domain/akhlaq_practices.dart';
import '../../domain/huquq_practices.dart';
import '../../domain/knowledge_practices.dart';
import '../../domain/health_practices.dart';
import '../../domain/charity_practices.dart';
import '../../domain/fasting_practices.dart';
import '../../domain/ummah_practices.dart';
import '../../domain/wealth_practices.dart';
import '../../domain/time_practices.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/home_traces.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/quran_duration.dart';
import '../../domain/salah_extras.dart';
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
    final healthKind = healthKindFor(activityId);
    if (healthKind != null) {
      return switch (healthKind) {
        HealthResponseKind.cared => congregationOnTime,
        HealthResponseKind.partial => joinedCongregationLate,
        HealthResponseKind.corrected => smallCongregation,
        HealthResponseKind.constrained ||
        HealthResponseKind.noSituation => aloneOnTime,
        HealthResponseKind.difficulty => excused,
        HealthResponseKind.lapse => prayedLate,
        HealthResponseKind.preferNot => other,
        HealthResponseKind.unanswered => unanswered,
      };
    }
    final wealthKind = wealthKindFor(activityId);
    if (wealthKind != null) {
      return switch (wealthKind) {
        WealthResponseKind.cared => congregationOnTime,
        WealthResponseKind.partial => joinedCongregationLate,
        WealthResponseKind.corrected => smallCongregation,
        WealthResponseKind.noSituation => aloneOnTime,
        WealthResponseKind.difficulty => excused,
        WealthResponseKind.preferNot => other,
        WealthResponseKind.unanswered => unanswered,
      };
    }
    final ummahKind = ummahKindFor(activityId);
    if (ummahKind != null) {
      return switch (ummahKind) {
        UmmahResponseKind.cared => congregationOnTime,
        UmmahResponseKind.partial => joinedCongregationLate,
        UmmahResponseKind.corrected => smallCongregation,
        UmmahResponseKind.noSituation => aloneOnTime,
        UmmahResponseKind.difficulty => excused,
        UmmahResponseKind.preferNot => other,
        UmmahResponseKind.unanswered => unanswered,
      };
    }
    final charityKind = charityKindFor(activityId);
    if (charityKind != null) {
      return switch (charityKind) {
        CharityResponseKind.cared => congregationOnTime,
        CharityResponseKind.partial => joinedCongregationLate,
        CharityResponseKind.noSituation => aloneOnTime,
        CharityResponseKind.difficulty => excused,
        CharityResponseKind.preferNot => other,
        CharityResponseKind.unanswered => unanswered,
      };
    }
    final fastingKind = fastingKindFor(activityId);
    if (fastingKind != null) {
      return switch (fastingKind) {
        FastingResponseKind.acted => congregationOnTime,
        FastingResponseKind.partial => joinedCongregationLate,
        FastingResponseKind.noSituation => aloneOnTime,
        FastingResponseKind.constrained => smallCongregation,
        FastingResponseKind.difficulty => excused,
        FastingResponseKind.preferNot => other,
        FastingResponseKind.unanswered => unanswered,
      };
    }
    return switch (activityId) {
      'congregationOnTime' => congregationOnTime,
      'joinedCongregationLate' => joinedCongregationLate,
      'smallCongregation' => smallCongregation,
      'aloneOnTime' => aloneOnTime,
      'excused' => excused,
      'prayedLate' => prayedLate,
      'missedMadeUp' => missedMadeUp,
      'missed' => missed,
      QuranDurationIds.over20 => congregationOnTime,
      QuranDurationIds.min15to20 => joinedCongregationLate,
      QuranDurationIds.min10to15 => smallCongregation,
      QuranDurationIds.min5to10 => aloneOnTime,
      QuranDurationIds.min3to5 => aloneOnTime,
      QuranDurationIds.notNoticed => prayedLate,
      ActivityCatalog.tahajjudEarlyMidAndLate ||
      ActivityCatalog.ishraqFollowingFajr => congregationOnTime,
      ActivityCatalog.tahajjudLaterPart ||
      ActivityCatalog.ishraqLaterMorning => joinedCongregationLate,
      ActivityCatalog.tahajjudEarlyMid ||
      ActivityCatalog.ishraqPrayed => smallCongregation,
      ActivityCatalog.tahajjudNotPrayed ||
      ActivityCatalog.ishraqNotPrayed => aloneOnTime,
      ActivityCatalog.hadithLivedStartedNew => congregationOnTime,
      ActivityCatalog.hadithLivedIntroducedFamily => joinedCongregationLate,
      ActivityCatalog.hadithLivedCorrectedPractice => smallCongregation,
      ActivityCatalog.hadithLivedObservedOther => aloneOnTime,
      ActivityCatalog.dhikrWithAction => congregationOnTime,
      ActivityCatalog.dhikrAttentive => joinedCongregationLate,
      ActivityCatalog.dhikrIntentional => smallCongregation,
      ActivityCatalog.dhikrBrief => aloneOnTime,
      AkhlaqObservationIds.practised => congregationOnTime,
      AkhlaqObservationIds.struggled => joinedCongregationLate,
      AkhlaqObservationIds.corrected => smallCongregation,
      AkhlaqObservationIds.noSituation => aloneOnTime,
      AkhlaqObservationIds.lapseRecognised => prayedLate,
      HuquqObservationIds.partialEffort => joinedCongregationLate,
      HuquqObservationIds.correctiveAction => smallCongregation,
      HuquqObservationIds.neglectRecognised => prayedLate,
      TimeObservationIds.acted => congregationOnTime,
      KnowledgeObservationIds.engaged => congregationOnTime,
      KnowledgeObservationIds.progress => joinedCongregationLate,
      KnowledgeObservationIds.gapRecognised => prayedLate,
      ActivityIds.noActivity => prayedLate,
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
    List<ActivityOption> catalog = ActivityCatalog.salah,
  }) {
    final option = ActivityCatalog.find(catalog, activityId);
    return SalahActivityMark(
      kind: kindForStatus(status, activityColours: activityColours),
      color: activityColours ? colourForId(activityId) : MuhasabahColors.mark,
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
      activityId: record?.jumuahActivityId ?? ActivityIds.unanswered,
      activityColours: activityColours,
      catalog: ActivityCatalog.jumuah,
    );
  }

  static SalahActivityMark forVoluntary({
    required DailyCheckIn? record,
    required SalahTraceRow row,
    required bool activityColours,
  }) {
    final activity = record?.activityFor(
      ActivityCatalog.voluntarySalahKey(row),
    );
    final id = activity?.id ?? ActivityIds.unanswered;
    final catalog = ActivityCatalog.forVoluntarySalah(row);
    final option = ActivityCatalog.find(catalog, id);
    final outcome =
        option?.ternary ??
        (row == SalahTraceRow.tahajjud
            ? (record?.tahajjud ?? TernaryOutcome.unanswered)
            : (record?.ishraq ?? TernaryOutcome.unanswered));
    return SalahActivityMark(
      kind: kindForVoluntaryId(id, outcome),
      color: activityColours ? colourForId(id) : MuhasabahColors.mark,
      label: option?.label ?? voluntarySalahLabel(outcome),
    );
  }

  static MarkerKind kindForVoluntaryId(
    String activityId,
    TernaryOutcome outcome,
  ) {
    if (activityId == ActivityIds.unanswered ||
        outcome == TernaryOutcome.unanswered) {
      return MarkerKind.unanswered;
    }
    if (activityId == ActivityCatalog.tahajjudNotPrayed ||
        activityId == ActivityCatalog.ishraqNotPrayed ||
        outcome == TernaryOutcome.negative) {
      return MarkerKind.outlined;
    }
    return MarkerKind.filled;
  }

  static MarkerKind quranDurationKind(
    String activityId, {
    bool activityColours = false,
  }) {
    if (activityId == ActivityIds.unanswered || activityId.isEmpty) {
      return MarkerKind.unanswered;
    }
    if (activityId == QuranDurationIds.notNoticed) {
      return MarkerKind.outlined;
    }
    if (activityColours && activityId == QuranDurationIds.min3to5) {
      return MarkerKind.outlined;
    }
    return MarkerKind.filled;
  }

  static Color quranDurationColour(String activityId, {required bool colours}) {
    if (!colours) return MuhasabahColors.mark;
    return colourForId(activityId);
  }

  static MarkerKind kindForHadithLived(String activityId) {
    if (activityId == ActivityIds.unanswered || activityId.isEmpty) {
      return MarkerKind.unanswered;
    }
    if (activityId == ActivityIds.noActivity) return MarkerKind.outlined;
    return MarkerKind.filled;
  }

  static MarkerKind kindForAkhlaq(String activityId) {
    if (activityId == ActivityIds.unanswered || activityId.isEmpty) {
      return MarkerKind.unanswered;
    }
    if (activityId == AkhlaqObservationIds.lapseRecognised ||
        activityId == HuquqObservationIds.neglectRecognised ||
        activityId == KnowledgeObservationIds.gapRecognised ||
        activityId == TimeObservationIds.lapseRecognised ||
        healthKindFor(activityId) == HealthResponseKind.lapse) {
      return MarkerKind.outlined;
    }
    return MarkerKind.filled;
  }

  static RecordedStateMarker recordedMarkerForTrace({
    required HomeTraceRow row,
    required DailyCheckIn? record,
    required bool activityColours,
    required String semanticLabel,
  }) {
    if (ActivityCatalog.forHomeTrace(row.storageKey).isNotEmpty) {
      final mark = forHadithTrace(
        record: record,
        row: row,
        activityColours: activityColours,
      );
      return RecordedStateMarker(
        kind: mark.kind,
        color: mark.color,
        semanticLabel: semanticLabel,
      );
    }
    final outcome =
        record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
    return RecordedStateMarker(
      kind: markerForRecorded(
        recorded: outcome.isRecorded,
        positive: outcome == TernaryOutcome.positive,
      ),
      semanticLabel: semanticLabel,
    );
  }

  static SalahActivityMark forHadithTrace({
    required DailyCheckIn? record,
    required HomeTraceRow row,
    required bool activityColours,
  }) {
    final id = record?.activityFor(row.storageKey).id ?? ActivityIds.unanswered;
    final option = ActivityCatalog.find(
      ActivityCatalog.forHomeTrace(row.storageKey),
      id,
    );
    final outcome =
        record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
    if (isHadithDurationTrace(row.storageKey)) {
      return SalahActivityMark(
        kind: quranDurationKind(id, activityColours: activityColours),
        color: quranDurationColour(id, colours: activityColours),
        label: option?.label ?? row.label,
      );
    }
    if (isHadithLivedTrace(row.storageKey)) {
      return SalahActivityMark(
        kind: kindForHadithLived(id),
        color: activityColours ? colourForId(id) : MuhasabahColors.mark,
        label: option?.label ?? row.label,
      );
    }
    if (isDhikrPostFardTrace(row.storageKey)) {
      return SalahActivityMark(
        kind: kindForHadithLived(id),
        color: activityColours ? colourForId(id) : MuhasabahColors.mark,
        label: option?.label ?? row.label,
      );
    }
    if (isAkhlaqTrace(row.storageKey) ||
        isHuquqTrace(row.storageKey) ||
        isKnowledgeTrace(row.storageKey) ||
        isTimeTrace(row.storageKey) ||
        isHealthTrace(row.storageKey) ||
        isWealthTrace(row.storageKey) ||
        isUmmahTrace(row.storageKey) ||
        row.storageKey.startsWith('charity.') ||
        isFastingPracticeTrace(row.storageKey)) {
      return SalahActivityMark(
        kind: kindForAkhlaq(id),
        color: activityColours ? colourForId(id) : MuhasabahColors.mark,
        label: option?.label ?? row.label,
      );
    }
    return SalahActivityMark(
      kind: markerForRecorded(
        recorded: outcome.isRecorded,
        positive: outcome == TernaryOutcome.positive,
      ),
      color: MuhasabahColors.mark,
      label: option?.label ?? row.label,
    );
  }
}
