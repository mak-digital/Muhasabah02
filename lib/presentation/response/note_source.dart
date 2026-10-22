import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/personal_response.dart';
import '../home/home_screen.dart';
import '../progress/salah_progress_screen.dart';
import '../recorded_days/day_evidence_screen.dart';
import '../recognition/recognition_screen.dart';

bool noteHasOpenableSource(PersonalResponse item) {
  final provenance = item.provenance;
  if (provenance == null) return false;
  if (provenance.dateKey != null && provenance.dateKey!.isNotEmpty) {
    return true;
  }
  switch (provenance.originType) {
    case ProvenanceOrigin.quranPonder:
    case ProvenanceOrigin.progressDimension:
    case ProvenanceOrigin.periodSummary:
    case ProvenanceOrigin.recognitionPattern:
    case ProvenanceOrigin.recognitionSupportingDate:
      return true;
    case ProvenanceOrigin.progressDate:
    case ProvenanceOrigin.recordedContext:
    case ProvenanceOrigin.historicalReflection:
    case ProvenanceOrigin.completedCheckIn:
    case ProvenanceOrigin.weeklyReflectionQuote:
      return provenance.dateKey != null && provenance.dateKey!.isNotEmpty;
  }
}

Future<void> openNoteSource(BuildContext context, PersonalResponse item) async {
  final provenance = item.provenance;
  if (provenance == null) return;
  final dateKey = provenance.dateKey;
  if (dateKey != null && dateKey.isNotEmpty) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DayEvidenceScreen(dateKey: dateKey),
      ),
    );
    return;
  }
  switch (provenance.originType) {
    case ProvenanceOrigin.quranPonder:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const QuranProgressScreen()),
      );
      return;
    case ProvenanceOrigin.progressDimension:
      final domain = noteMonitorDomain(item);
      if (domain == MonitorDomain.quran) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const QuranProgressScreen()),
        );
        return;
      }
      if (domain == MonitorDomain.salah) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SalahProgressScreen()),
        );
        return;
      }
      context.findAncestorStateOfType<AppShellState>()?.select(1);
      return;
    case ProvenanceOrigin.periodSummary:
      context.findAncestorStateOfType<AppShellState>()?.select(1);
      return;
    case ProvenanceOrigin.recognitionPattern:
    case ProvenanceOrigin.recognitionSupportingDate:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const RecognitionScreen()),
      );
      return;
    case ProvenanceOrigin.progressDate:
    case ProvenanceOrigin.recordedContext:
    case ProvenanceOrigin.historicalReflection:
    case ProvenanceOrigin.completedCheckIn:
    case ProvenanceOrigin.weeklyReflectionQuote:
      break;
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text(Copy.evidenceUnavailable)));
}
