import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/copy.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/domain_briefing.dart';
import '../shared/domain_briefing_note.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';

Future<void> showMarksGuide(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.86;
      void close() => Navigator.of(sheetContext).pop();
      return Consumer(
        builder: (context, ref, _) {
          ref.watch(prefsTickProvider);
          final colours = ref.watch(appPrefsProvider).salahActivityColours;
          return SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Copy.marksGuideTitle,
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(onPressed: close, child: const Text('Close')),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Copy.marksGuideIntro),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.salah.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.salah.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.salah.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (colours)
                      for (final option in ActivityCatalog.salah)
                        _row(
                          context,
                          kind: MarkerKind.filled,
                          color: SalahActivityMark.colourForId(option.id),
                          label: option.label,
                        )
                    else ...[
                      _row(context, kind: MarkerKind.filled, label: 'On time'),
                      _row(context, kind: MarkerKind.outlined, label: 'Late'),
                      _row(context, kind: MarkerKind.missed, label: 'Missed'),
                      _row(
                        context,
                        kind: MarkerKind.unanswered,
                        label: 'Unanswered',
                      ),
                    ],
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      symbol: Icons.star,
                      symbolColor: Colors.white,
                      symbolSize: AppDimensions.progressMarkerStar,
                      label:
                          'Friday congregational Jumu‘ah (inside Friday Dhuhr)',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.quran.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.quran.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.quran.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      Copy.quranStageNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    if (colours)
                      for (final option in ActivityCatalog.quranEngagementDuration)
                        _row(
                          context,
                          kind: SalahActivityMark.quranDurationKind(option.id),
                          color: SalahActivityMark.colourForId(option.id),
                          label: option.label,
                        )
                    else ...[
                      _row(
                        context,
                        kind: MarkerKind.filled,
                        label: 'Recorded sitting (duration)',
                      ),
                      _row(
                        context,
                        kind: MarkerKind.outlined,
                        label: 'I did not notice this today',
                      ),
                      _row(
                        context,
                        kind: MarkerKind.unanswered,
                        label: 'Unanswered',
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.hadith.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.hadith.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.hadith.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    DomainBriefingNote(hadithBriefing, compact: true),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: 'Recorded engagement',
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: 'Recorded as not done',
                    ),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: Copy.hadithNoticed,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: Copy.hadithNotToday,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.unanswered,
                      label: 'Unanswered',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.dhikr.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.dhikr.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.dhikr.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: 'Recorded engagement',
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: 'Recorded as not done',
                    ),
                    _row(
                      context,
                      kind: MarkerKind.unanswered,
                      label: 'Unanswered',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.akhlaq.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.akhlaq.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.akhlaq.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    DomainBriefingNote(akhlaqBriefing, compact: true),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: Copy.akhlaqNoticed,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: Copy.akhlaqNotToday,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.unanswered,
                      label: 'Unanswered',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.huquq.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.huquq.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.huquq.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    DomainBriefingNote(huquqBriefing, compact: true),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: Copy.huquqAttended,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: Copy.huquqNeglected,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.unanswered,
                      label: 'Unanswered',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.knowledge.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.knowledge.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.knowledge.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    DomainBriefingNote(knowledgeBriefing, compact: true),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: Copy.knowledgeNoticed,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: Copy.knowledgeNotToday,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.unanswered,
                      label: 'Unanswered',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.time.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.time.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.time.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    DomainBriefingNote(timeBriefing, compact: true),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: Copy.timeNoticed,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: Copy.timeNotToday,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.unanswered,
                      label: 'Unanswered',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.health.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.health.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.health.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    DomainBriefingNote(healthBriefing, compact: true),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: Copy.healthNoticed,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: Copy.healthNotToday,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.unanswered,
                      label: 'Unanswered',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.wealth.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.wealth.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.wealth.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    DomainBriefingNote(wealthBriefing, compact: true),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: Copy.wealthNoticed,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: Copy.wealthNotToday,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.unanswered,
                      label: 'Unanswered',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MonitorDomain.ummah.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (MonitorDomain.ummah.focusQuestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        MonitorDomain.ummah.focusQuestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    DomainBriefingNote(ummahBriefing, compact: true),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      kind: MarkerKind.filled,
                      label: Copy.ummahNoticed,
                    ),
                    _row(
                      context,
                      kind: MarkerKind.outlined,
                      label: Copy.ummahNotToday,
                    ),
                    _row(
                      context,
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
                      'Fasting and Charity use the same engagement / not done / unanswered circles. Care in hardship on Rights of Others uses the same Huquq marks. Hajj preparation uses those circles only while the standing status is Due or Preparing.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hajj',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hajj is a standing status you set, not a daily fard mark. Not recorded is empty, not missed. Due and Preparing are your own naming. The app does not calculate ability or set a year.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Zakat',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _zakat(context, ZakatStatus.due, 'Due'),
                    _zakat(context, ZakatStatus.planned, 'Planned'),
                    _zakat(context, ZakatStatus.paid, 'Paid'),
                    _zakat(
                      context,
                      ZakatStatus.notApplicable,
                      'Not applicable',
                    ),
                    _zakat(context, ZakatStatus.unanswered, 'Unanswered'),
                    const SizedBox(height: 16),
                    Text(
                      'General rules',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Missing records are not treated as missed. Symbols indicate recorded states only. Marks share one colour unless Settings → Preferences → Activities & legend uses activity colours. Colour does not rank spirituality. The card wash identifies the domain. Factors you noticed are stored as provenance; they do not explain causes and do not change completion.',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                key: const Key('marks-guide-close'),
                onPressed: close,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
          );
        },
      );
    },
  );
}

Widget _row(
  BuildContext context, {
  required MarkerKind kind,
  required String label,
  IconData? symbol,
  Color? symbolColor,
  Color? color,
  double? symbolSize,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        RecordedStateMarker(
          kind: kind,
          color: color ?? MuhasabahColors.mark,
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
        ZakatStateMarker(status: status),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    ),
  );
}
