import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/akhlaq_practices.dart';
import '../../domain/huquq_practices.dart';
import '../../domain/knowledge_practices.dart';
import '../../domain/health_practices.dart';
import '../../domain/charity_practices.dart';
import '../../domain/ummah_practices.dart';
import '../../domain/wealth_practices.dart';
import '../../domain/time_practices.dart';
import '../../domain/quran.dart';
import '../../domain/salah_extras.dart';
import '../../domain/copy.dart';
import '../../domain/monitor_domain.dart';
import '../../domain/domain_briefing.dart';
import '../shared/domain_briefing_note.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';
import '../shared/ui_bits.dart';

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
                        BalancedProse(
                          Copy.marksGuideIntro,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.salah.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.salah.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.salah.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
                          _row(
                            context,
                            kind: MarkerKind.filled,
                            label: 'On time',
                          ),
                          _row(
                            context,
                            kind: MarkerKind.outlined,
                            label: 'Late',
                          ),
                          _row(
                            context,
                            kind: MarkerKind.missed,
                            label: 'Missed',
                          ),
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
                          label: 'Friday congregational Jumu‘ah (inside Friday Dhuhr)',
                        ),
                        if (colours) ...[
                          for (final row in kSalahVoluntaryRows) ...[
                            const SizedBox(height: 12),
                            Text(
                              row.label,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            for (final option
                                in ActivityCatalog.forVoluntarySalah(row))
                              _row(
                                context,
                                kind: SalahActivityMark.kindForVoluntaryId(
                                  option.id,
                                  option.ternary ?? TernaryOutcome.unanswered,
                                ),
                                color: SalahActivityMark.colourForId(option.id),
                                label: option.label,
                              ),
                          ],
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.quran.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.quran.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.quran.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.quranStageNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option
                              in ActivityCatalog.quranEngagementDuration)
                            _row(
                              context,
                              kind: SalahActivityMark.quranDurationKind(
                                option.id,
                                activityColours: true,
                              ),
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DomainBriefingNote(hadithBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.hadithDurationNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours) ...[
                          for (final option
                              in ActivityCatalog.hadithEncounterDuration)
                            _row(
                              context,
                              kind: SalahActivityMark.quranDurationKind(
                                option.id,
                                activityColours: true,
                              ),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            ),
                          const SizedBox(height: 8),
                          for (final option
                              in ActivityCatalog.hadithLivedNoticed)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForHadithLived(
                                option.id,
                              ),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            ),
                        ] else ...[
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
                            kind: MarkerKind.filled,
                            label:
                                'Started / introduced / corrected / observed',
                          ),
                          _row(
                            context,
                            kind: MarkerKind.outlined,
                            label: 'Recorded as not engaged',
                          ),
                          _row(
                            context,
                            kind: MarkerKind.unanswered,
                            label: 'Unanswered',
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.dhikr.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.dhikr.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.dhikr.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.dhikrPostFardNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in ActivityCatalog.dhikrPostFard)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForHadithLived(
                                option.id,
                              ),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
                          _row(
                            context,
                            kind: MarkerKind.filled,
                            label: 'Recorded remembrance',
                          ),
                          _row(
                            context,
                            kind: MarkerKind.outlined,
                            label: 'Not today',
                          ),
                          _row(
                            context,
                            kind: MarkerKind.unanswered,
                            label: 'Unanswered',
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.akhlaq.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.akhlaq.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.akhlaq.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DomainBriefingNote(akhlaqBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.akhlaqCheckInNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in akhlaqLegendCatalog)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForAkhlaq(option.id),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
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
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.huquq.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.huquq.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.huquq.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DomainBriefingNote(huquqBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.huquqCheckInNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in huquqLegendCatalog)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForAkhlaq(option.id),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
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
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.charity.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DomainBriefingNote(charityBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.charityCheckInNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in charityLegendCatalog)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForAkhlaq(option.id),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
                          _row(
                            context,
                            kind: MarkerKind.filled,
                            label: Copy.charityNoticed,
                          ),
                          _row(
                            context,
                            kind: MarkerKind.outlined,
                            label: Copy.charityNotToday,
                          ),
                          _row(
                            context,
                            kind: MarkerKind.unanswered,
                            label: 'Not recorded',
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.knowledge.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.knowledge.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.knowledge.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DomainBriefingNote(knowledgeBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.knowledgeCheckInNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in knowledgeLegendCatalog)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForAkhlaq(option.id),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
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
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.time.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.time.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.time.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DomainBriefingNote(timeBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.timeCheckInNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in timeLegendCatalog)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForAkhlaq(option.id),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
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
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.health.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.health.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.health.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DomainBriefingNote(healthBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.healthCheckInNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in healthLegendCatalog)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForAkhlaq(option.id),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
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
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.wealth.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.wealth.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.wealth.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DomainBriefingNote(wealthBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.wealthCheckInNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in wealthLegendCatalog)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForAkhlaq(option.id),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
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
                        ],
                        const SizedBox(height: 16),
                        Text(
                          MonitorDomain.ummah.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (MonitorDomain.ummah.focusQuestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            MonitorDomain.ummah.focusQuestion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        DomainBriefingNote(ummahBriefing, compact: true),
                        const SizedBox(height: 8),
                        BalancedProse(
                          Copy.ummahCheckInNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 8),
                        if (colours)
                          for (final option in ummahLegendCatalog)
                            _row(
                              context,
                              kind: SalahActivityMark.kindForAkhlaq(option.id),
                              color: SalahActivityMark.colourForId(option.id),
                              label: option.label,
                            )
                        else ...[
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
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'Other daily rows',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fasting uses the same engagement / not done / unanswered circles. Care in hardship on Rights of Others uses the same Huquq marks. Hajj preparation uses those circles only while the standing status is Due or Preparing.',
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
                        for (final status in kZakatPickerOrder)
                          _zakat(context, status, status.label),
                        const SizedBox(height: 16),
                        Text(
                          'General rules',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        BalancedProse(
                          'Missing records are not treated as missed. Symbols indicate recorded states only. Marks share one colour unless Settings → Preferences → Activities & legend uses activity colours. Colour does not rank spirituality. The card wash identifies the domain. Factors you noticed are stored as provenance; they do not explain causes and do not change completion.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.45),
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
