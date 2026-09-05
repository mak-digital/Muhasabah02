import 'package:flutter/material.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../domain/activities.dart';
import '../../domain/copy.dart';
import '../shared/state_marker.dart';

Future<void> showMarksGuide(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final teal = MuhasabahColors.salahFamily;
      final blue = MuhasabahColors.quranFamily;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Copy.marksGuideTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(Copy.marksGuideIntro),
              const SizedBox(height: 16),
              Text('Salah', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _row(
                context,
                color: teal,
                kind: MarkerKind.filled,
                label: 'On time',
              ),
              _row(
                context,
                color: teal,
                kind: MarkerKind.outlined,
                label: 'Late',
              ),
              _row(
                context,
                color: MuhasabahColors.missedEarth,
                kind: MarkerKind.missed,
                label: 'Missed',
              ),
              _row(
                context,
                color: teal,
                kind: MarkerKind.unanswered,
                label: 'Unanswered',
              ),
              _row(
                context,
                color: teal,
                kind: MarkerKind.filled,
                symbol: Icons.star,
                symbolColor: Colors.white,
                symbolSize: AppDimensions.progressMarkerStar,
                label: 'Friday congregational Jumu‘ah (inside Friday Dhuhr)',
              ),
              const SizedBox(height: 16),
              Text('Qur’an', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _row(
                context,
                color: blue,
                kind: MarkerKind.filled,
                label: 'Recorded engagement',
              ),
              _row(
                context,
                color: blue,
                kind: MarkerKind.outlined,
                label: 'Recorded as not done',
              ),
              _row(
                context,
                color: blue,
                kind: MarkerKind.unanswered,
                label: 'Unanswered',
              ),
              const SizedBox(height: 16),
              Text(
                'Other daily rows',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Dhikr, Fasting, Family & Community Care, Charity, and Hadith use the same engagement / not done / unanswered circles in each domain colour.',
              ),
              const SizedBox(height: 16),
              Text('Zakat', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _zakat(context, ZakatStatus.due, 'Due'),
              _zakat(context, ZakatStatus.planned, 'Planned'),
              _zakat(context, ZakatStatus.paid, 'Paid'),
              _zakat(context, ZakatStatus.notApplicable, 'Not applicable'),
              _zakat(context, ZakatStatus.unanswered, 'Unanswered'),
              const SizedBox(height: 16),
              Text(
                'General rules',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Missing records are not treated as missed. Symbols indicate recorded states only. Colour identifies domains and does not represent spiritual ranking. Factors you noticed are stored as provenance; they do not explain causes and do not change completion.',
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _row(
  BuildContext context, {
  required Color color,
  required MarkerKind kind,
  required String label,
  IconData? symbol,
  Color? symbolColor,
  double? symbolSize,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        RecordedStateMarker(
          color: color,
          kind: kind,
          symbol: symbol,
          symbolColor: symbolColor,
          symbolSize: symbolSize,
          semanticLabel: label,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    ),
  );
}

Widget _zakat(BuildContext context, ZakatStatus status, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        ZakatStateMarker(status: status, color: MuhasabahColors.charityFamily),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    ),
  );
}
