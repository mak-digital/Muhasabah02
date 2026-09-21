import 'package:flutter/material.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../domain/quran_stage.dart';
import 'state_marker.dart';

abstract final class QuranStageMark {
  static const application = Color(0xFF1565C0);
  static const reflection = Color(0xFF2E7D32);
  static const understanding = Color(0xFF66BB6A);
  static const engagement = Color(0xFFFBC02D);

  static Color colourFor(QuranJourneyRow row) {
    return switch (row) {
      QuranJourneyRow.applied => application,
      QuranJourneyRow.reflected => reflection,
      QuranJourneyRow.understood => understanding,
      QuranJourneyRow.engaged => engagement,
    };
  }

  static Color letterColorFor(QuranJourneyRow row, {required bool colours}) {
    if (!colours) return Colors.white;
    return row == QuranJourneyRow.engaged
        ? const Color(0xFF3E2723)
        : Colors.white;
  }

  static Color colourForCell(
    QuranJourneyRow? row,
    QuranJourneyCell cell, {
    required bool colours,
  }) {
    if (cell.kind == QuranJourneyCellKind.unanswered) {
      return MuhasabahColors.mark;
    }
    if (!colours) return MuhasabahColors.mark;
    if (row == null) return MuhasabahColors.quranFamily;
    return colourFor(row);
  }

  static MarkerKind kindForCell(QuranJourneyCell cell) {
    return switch (cell.kind) {
      QuranJourneyCellKind.unanswered => MarkerKind.unanswered,
      QuranJourneyCellKind.none => MarkerKind.outlined,
      QuranJourneyCellKind.recorded => MarkerKind.filled,
    };
  }
}

class QuranJourneyMarker extends StatelessWidget {
  const QuranJourneyMarker({
    super.key,
    this.row,
    required this.cell,
    required this.semanticLabel,
    this.colours = false,
    this.size = AppDimensions.progressMarker,
  });

  final QuranJourneyRow? row;
  final QuranJourneyCell cell;
  final String semanticLabel;
  final bool colours;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RecordedStateMarker(
      color: QuranStageMark.colourForCell(row, cell, colours: colours),
      kind: QuranStageMark.kindForCell(cell),
      letter: cell.code,
      symbolColor: row == null
          ? Colors.white
          : QuranStageMark.letterColorFor(row!, colours: colours),
      size: size,
      semanticLabel: semanticLabel,
    );
  }
}
