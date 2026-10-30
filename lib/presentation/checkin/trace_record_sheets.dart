import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/activities.dart';
import '../../domain/akhlaq_practices.dart';
import '../../domain/huquq_practices.dart';
import '../../domain/knowledge_practices.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/dhikr_context.dart';
import 'dhikr_context_editor.dart';
import '../../domain/date_key.dart';
import '../../domain/display_calendar.dart';
import '../../domain/factor_groups.dart';
import '../../domain/home_traces.dart';
import '../../domain/prayer.dart';
import '../../domain/quran.dart';
import '../../domain/salah_factors.dart';
import '../../domain/health_practices.dart';
import '../../domain/charity_practices.dart';
import '../../domain/fasting_practices.dart';
import '../../domain/ummah_practices.dart';
import '../../domain/wealth_practices.dart';
import '../../domain/time_practices.dart';
import '../progress/progress_review_frame.dart';
import '../recorded_days/day_evidence_screen.dart';
import '../shared/time_practice_fields.dart';
import '../shared/activity_picker.dart';
import '../shared/akhlaq_follow_up_fields.dart';
import '../shared/huquq_follow_up_fields.dart';
import '../shared/knowledge_follow_up_fields.dart';
import '../shared/system_insets.dart';

String _visibleDate(WidgetRef ref, String key) {
  return formatStoredDateKey(key, ref.read(appPrefsProvider).displayCalendar);
}

DailyCheckIn? _recordFor(WidgetRef ref, String key, DailyCheckIn? fallback) {
  final latest = ref.read(checkInsProvider).value;
  if (latest != null) {
    for (final item in latest) {
      if (item.dateKey == key) return item;
    }
  }
  return fallback;
}

Future<void> _save(WidgetRef ref, DailyCheckIn record) {
  return ref
      .read(checkInsProvider.notifier)
      .save(record.copyWith(savedAt: DateTime.now()));
}

void openDayEvidence(BuildContext context, String dateKey) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DayEvidenceScreen(dateKey: dateKey),
    ),
  );
}

VoidCallback? matrixCellOnTap({
  required WidgetRef ref,
  required BuildContext context,
  required String dateKey,
  VoidCallback? onOpen,
  VoidCallback? onPast,
  VoidCallback? onToday,
}) {
  if (onOpen == null && onPast == null && onToday == null) return null;
  return () {
    refreshNowIfLocalDateChanged(ref);
    switch (dateCellKind(dateKey, ref.read(nowProvider))) {
      case DateCellKind.future:
        return;
      case DateCellKind.today:
        ProgressChromeScope.collapseMarksOf(context);
        (onToday ?? onOpen)?.call();
      case DateCellKind.past:
        ProgressChromeScope.collapseMarksOf(context);
        (onPast ?? onOpen)?.call();
    }
  };
}

Future<void> showHomeTraceRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required HomeTraceRow row,
  required String dateKey,
  required DailyCheckIn? record,
  Key? dropdownKey,
  bool performedStartsCollapsed = false,
}) async {
  var outcome = record?.homeTrace(row.storageKey) ?? TernaryOutcome.unanswered;
  var selectedId =
      record?.activityFor(row.storageKey).id ?? ActivityIds.unanswered;
  var factors =
      record?.homeTraceFactors[row.storageKey] ?? const SalahFactorCapture();
  final catalog = ActivityCatalog.forHomeTrace(row.storageKey);
  final systemBottom = presentingSystemBottom(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
      return StatefulBuilder(
        builder: (context, setSheet) {
          return SafeArea(
            bottom: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Padding(
                padding: sheetContentPadding(
                  context,
                  systemBottom: systemBottom,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CheckInRowLabel(
                        '${row.label} · ${_visibleDate(ref, dateKey)}',
                      ),
                      const SizedBox(height: 4),
                      if (!isDhikrContextTrace(row.storageKey)) ...[
                        const Text(Copy.seePonderExplore),
                        const SizedBox(height: 8),
                        const CheckInRowLabel('What happened?'),
                      ],
                      if (isDhikrContextTrace(row.storageKey))
                        DhikrContextEditor(
                          key: Key('dhikr-context-sheet-${row.storageKey}'),
                          rowKey: row.storageKey,
                          label: row.label,
                          record:
                              _recordFor(ref, dateKey, record) ??
                              DailyCheckIn.empty(dateKey),
                          compact: true,
                          performedStartsCollapsed: performedStartsCollapsed,
                          dropdownKey: dropdownKey,
                          onChanged: (next) async {
                            await _save(ref, next);
                            setSheet(() {});
                          },
                        )
                      else if (catalog.isNotEmpty)
                        ActivityPicker(
                          statusKeyPrefix: 'trace-${row.storageKey}',
                          options: catalog,
                          selectedId: selectedId,
                          onSelected: (option) async {
                            selectedId = option.id;
                            outcome =
                                option.ternary ?? TernaryOutcome.unanswered;
                            setSheet(() {});
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            if (isTimeTrace(row.storageKey)) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeTimePractice(
                                  base,
                                  row.storageKey,
                                  const TimePracticeCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readTimePractice(
                                  base,
                                  row.storageKey,
                                );
                                next = writeTimePractice(
                                  base,
                                  row.storageKey,
                                  existing.copyWith(primaryId: option.id),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            if (isAkhlaqTrace(row.storageKey)) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeAkhlaqFollowUp(
                                  base,
                                  row.storageKey,
                                  const AkhlaqFollowUpCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readAkhlaqFollowUp(
                                  base,
                                  row.storageKey,
                                );
                                next = writeAkhlaqFollowUp(
                                  base,
                                  row.storageKey,
                                  AkhlaqFollowUpCapture(
                                    primaryId: option.id,
                                    contextId: existing.contextId,
                                    helpId: existing.helpId,
                                    note: existing.note,
                                  ),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            if (isHuquqTrace(row.storageKey)) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeHuquqFollowUp(
                                  base,
                                  row.storageKey,
                                  const HuquqFollowUpCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readHuquqFollowUp(
                                  base,
                                  row.storageKey,
                                );
                                next = writeHuquqFollowUp(
                                  base,
                                  row.storageKey,
                                  existing.copyWith(primaryId: option.id),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            if (isKnowledgeTrace(row.storageKey)) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeKnowledgeFollowUp(
                                  base,
                                  row.storageKey,
                                  const KnowledgeFollowUpCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readKnowledgeFollowUp(
                                  base,
                                  row.storageKey,
                                );
                                next = writeKnowledgeFollowUp(
                                  base,
                                  row.storageKey,
                                  existing.copyWith(primaryId: option.id),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            if (isHealthTrace(row.storageKey)) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeHealthPractice(
                                  base,
                                  row.storageKey,
                                  const HealthPracticeCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readHealthPractice(
                                  base,
                                  row.storageKey,
                                );
                                next = writeHealthPractice(
                                  base,
                                  row.storageKey,
                                  existing.copyWith(primaryId: option.id),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            if (isWealthTrace(row.storageKey)) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeWealthPractice(
                                  base,
                                  row.storageKey,
                                  const WealthPracticeCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readWealthPractice(
                                  base,
                                  row.storageKey,
                                );
                                next = writeWealthPractice(
                                  base,
                                  row.storageKey,
                                  existing.copyWith(primaryId: option.id),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            if (isUmmahTrace(row.storageKey)) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeUmmahPractice(
                                  base,
                                  row.storageKey,
                                  const UmmahPracticeCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readUmmahPractice(
                                  base,
                                  row.storageKey,
                                );
                                next = writeUmmahPractice(
                                  base,
                                  row.storageKey,
                                  existing.copyWith(primaryId: option.id),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            if (row.storageKey.startsWith('charity.')) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeCharityPractice(
                                  base,
                                  row.storageKey,
                                  const CharityPracticeCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readCharityPractice(
                                  base,
                                  row.storageKey,
                                );
                                next = writeCharityPractice(
                                  base,
                                  row.storageKey,
                                  existing.copyWith(primaryId: option.id),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            if (isFastingPracticeTrace(row.storageKey)) {
                              DailyCheckIn next;
                              if (option.id == ActivityIds.unanswered) {
                                next = writeFastingPractice(
                                  base,
                                  row.storageKey,
                                  const FastingPracticeCapture(),
                                );
                                factors = const SalahFactorCapture();
                              } else {
                                final existing = readFastingPractice(
                                  base,
                                  row.storageKey,
                                );
                                next = writeFastingPractice(
                                  base,
                                  row.storageKey,
                                  existing.copyWith(primaryId: option.id),
                                );
                                factors =
                                    next.homeTraceFactors[row.storageKey] ??
                                    const SalahFactorCapture();
                              }
                              await _save(ref, next);
                              return;
                            }
                            var next = base.withHomeTraceActivity(
                              row.storageKey,
                              RecordedActivity(id: option.id),
                            );
                            if (!hidesHomeTraceFactors(row.storageKey)) {
                              factors = nextHomeTraceFactors(
                                storageKey: row.storageKey,
                                outcome: outcome,
                                existing: factors,
                              );
                              next = next.withHomeTraceFactors(
                                row.storageKey,
                                factors,
                              );
                            }
                            await _save(ref, next);
                          },
                        )
                      else
                        CheckInSelect<TernaryOutcome>(
                          dropdownKey: dropdownKey,
                          value: outcome,
                          sortLabels: false,
                          entries: [
                            for (final option in TernaryOutcome.values)
                              CheckInSelectEntry(
                                value: option,
                                label: traceOutcomeLabel(
                                  row.storageKey,
                                  option,
                                ),
                              ),
                          ],
                          onChanged: (option) async {
                            outcome = option;
                            setSheet(() {});
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            var next = base.withHomeTrace(
                              row.storageKey,
                              option,
                            );
                            if (!hidesHomeTraceFactors(row.storageKey)) {
                              factors = nextHomeTraceFactors(
                                storageKey: row.storageKey,
                                outcome: option,
                                existing: factors,
                              );
                              next = next.withHomeTraceFactors(
                                row.storageKey,
                                factors,
                              );
                            }
                            await _save(ref, next);
                          },
                        ),
                      if (isTimeTrace(row.storageKey) &&
                          timePracticeByKey(row.storageKey) != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            timePracticeByKey(row.storageKey)!.detail,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        if (selectedId != ActivityIds.unanswered)
                          TimePracticeFields(
                            storageKey: row.storageKey,
                            contextId: readTimePractice(
                              _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey),
                              row.storageKey,
                            ).contextId,
                            challengeId: readTimePractice(
                              _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey),
                              row.storageKey,
                            ).challengeId,
                            helpId: readTimePractice(
                              _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey),
                              row.storageKey,
                            ).helpId,
                            outcomeId: readTimePractice(
                              _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey),
                              row.storageKey,
                            ).outcomeId,
                            quantityId: readTimePractice(
                              _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey),
                              row.storageKey,
                            ).quantityId,
                            quantityText: readTimePractice(
                              _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey),
                              row.storageKey,
                            ).quantityText,
                            onContextChanged: (id) async {
                              final base =
                                  _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey);
                              final next = writeTimePractice(
                                base,
                                row.storageKey,
                                readTimePractice(base, row.storageKey).copyWith(
                                  primaryId: selectedId,
                                  contextId: id,
                                ),
                              );
                              factors =
                                  next.homeTraceFactors[row.storageKey] ??
                                  const SalahFactorCapture();
                              setSheet(() {});
                              await _save(ref, next);
                            },
                            onChallengeChanged: (id) async {
                              final base =
                                  _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey);
                              final next = writeTimePractice(
                                base,
                                row.storageKey,
                                readTimePractice(base, row.storageKey).copyWith(
                                  primaryId: selectedId,
                                  challengeId: id,
                                ),
                              );
                              factors =
                                  next.homeTraceFactors[row.storageKey] ??
                                  const SalahFactorCapture();
                              setSheet(() {});
                              await _save(ref, next);
                            },
                            onHelpChanged: (id) async {
                              final base =
                                  _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey);
                              final next = writeTimePractice(
                                base,
                                row.storageKey,
                                readTimePractice(
                                  base,
                                  row.storageKey,
                                ).copyWith(primaryId: selectedId, helpId: id),
                              );
                              factors =
                                  next.homeTraceFactors[row.storageKey] ??
                                  const SalahFactorCapture();
                              setSheet(() {});
                              await _save(ref, next);
                            },
                            onOutcomeChanged: (id) async {
                              final base =
                                  _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey);
                              final next = writeTimePractice(
                                base,
                                row.storageKey,
                                readTimePractice(base, row.storageKey).copyWith(
                                  primaryId: selectedId,
                                  outcomeId: id,
                                ),
                              );
                              factors =
                                  next.homeTraceFactors[row.storageKey] ??
                                  const SalahFactorCapture();
                              setSheet(() {});
                              await _save(ref, next);
                            },
                            onQuantityChanged: (id) async {
                              final base =
                                  _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey);
                              final next = writeTimePractice(
                                base,
                                row.storageKey,
                                readTimePractice(base, row.storageKey).copyWith(
                                  primaryId: selectedId,
                                  quantityId: id,
                                ),
                              );
                              factors =
                                  next.homeTraceFactors[row.storageKey] ??
                                  const SalahFactorCapture();
                              setSheet(() {});
                              await _save(ref, next);
                            },
                            onQuantityTextChanged: (value) async {
                              final base =
                                  _recordFor(ref, dateKey, record) ??
                                  DailyCheckIn.empty(dateKey);
                              final next = writeTimePractice(
                                base,
                                row.storageKey,
                                readTimePractice(base, row.storageKey).copyWith(
                                  primaryId: selectedId,
                                  quantityText: value,
                                ),
                              );
                              factors =
                                  next.homeTraceFactors[row.storageKey] ??
                                  const SalahFactorCapture();
                              await _save(ref, next);
                            },
                          ),
                      ],
                      if (isAkhlaqTrace(row.storageKey) &&
                          selectedId != ActivityIds.unanswered)
                        AkhlaqFollowUpFields(
                          storageKey: row.storageKey,
                          contextId: selectedFactorId(factors.supportIds),
                          helpId: selectedFactorId(factors.challengeIds),
                          onContextChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeAkhlaqFollowUp(
                              base,
                              row.storageKey,
                              AkhlaqFollowUpCapture(
                                primaryId: selectedId,
                                contextId: id,
                                helpId: selectedFactorId(factors.challengeIds),
                                note: factors.otherText ?? '',
                              ),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onHelpChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeAkhlaqFollowUp(
                              base,
                              row.storageKey,
                              AkhlaqFollowUpCapture(
                                primaryId: selectedId,
                                contextId: selectedFactorId(factors.supportIds),
                                helpId: id,
                                note: factors.otherText ?? '',
                              ),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                        ),
                      if (isHuquqTrace(row.storageKey) &&
                          selectedId != ActivityIds.unanswered)
                        HuquqFollowUpFields(
                          storageKey: row.storageKey,
                          engagementId: selectedFactorId(factors.supportIds),
                          outcomeId: selectedFactorId(factors.challengeIds),
                          occasions: decodeHuquqQuantity(
                            (_recordFor(ref, dateKey, record) ??
                                    DailyCheckIn.empty(dateKey))
                                .activityFor(row.storageKey)
                                .customText,
                          ).occasions,
                          timeSpent: decodeHuquqQuantity(
                            (_recordFor(ref, dateKey, record) ??
                                    DailyCheckIn.empty(dateKey))
                                .activityFor(row.storageKey)
                                .customText,
                          ).timeSpent,
                          note: factors.otherText ?? '',
                          onEngagementChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeHuquqFollowUp(
                              base,
                              row.storageKey,
                              readHuquqFollowUp(base, row.storageKey).copyWith(
                                primaryId: selectedId,
                                engagementId: id,
                              ),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onOutcomeChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeHuquqFollowUp(
                              base,
                              row.storageKey,
                              readHuquqFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(primaryId: selectedId, outcomeId: id),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onOccasionsChanged: (value) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeHuquqFollowUp(
                              base,
                              row.storageKey,
                              readHuquqFollowUp(base, row.storageKey).copyWith(
                                primaryId: selectedId,
                                occasions: value,
                              ),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            await _save(ref, next);
                          },
                          onTimeSpentChanged: (value) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeHuquqFollowUp(
                              base,
                              row.storageKey,
                              readHuquqFollowUp(base, row.storageKey).copyWith(
                                primaryId: selectedId,
                                timeSpent: value,
                              ),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            await _save(ref, next);
                          },
                          onNoteChanged: (value) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeHuquqFollowUp(
                              base,
                              row.storageKey,
                              readHuquqFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(primaryId: selectedId, note: value),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            await _save(ref, next);
                          },
                        ),
                      if (isKnowledgeTrace(row.storageKey) &&
                          selectedId != ActivityIds.unanswered)
                        KnowledgeFollowUpFields(
                          storageKey: row.storageKey,
                          areaId: selectedFactorId(factors.supportIds),
                          sourceId: decodeKnowledgeExtras(
                            (_recordFor(ref, dateKey, record) ??
                                    DailyCheckIn.empty(dateKey))
                                .activityFor(row.storageKey)
                                .customText,
                          ).sourceId,
                          verificationId: selectedFactorId(
                            factors.challengeIds,
                          ),
                          understandingId: decodeKnowledgeExtras(
                            (_recordFor(ref, dateKey, record) ??
                                    DailyCheckIn.empty(dateKey))
                                .activityFor(row.storageKey)
                                .customText,
                          ).understandingId,
                          applicationId: decodeKnowledgeExtras(
                            (_recordFor(ref, dateKey, record) ??
                                    DailyCheckIn.empty(dateKey))
                                .activityFor(row.storageKey)
                                .customText,
                          ).applicationId,
                          quantityId: decodeKnowledgeExtras(
                            (_recordFor(ref, dateKey, record) ??
                                    DailyCheckIn.empty(dateKey))
                                .activityFor(row.storageKey)
                                .customText,
                          ).quantityId,
                          minutes: decodeKnowledgeExtras(
                            (_recordFor(ref, dateKey, record) ??
                                    DailyCheckIn.empty(dateKey))
                                .activityFor(row.storageKey)
                                .customText,
                          ).minutes,
                          note: factors.otherText ?? '',
                          onAreaChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeKnowledgeFollowUp(
                              base,
                              row.storageKey,
                              readKnowledgeFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(primaryId: selectedId, areaId: id),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onSourceChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeKnowledgeFollowUp(
                              base,
                              row.storageKey,
                              readKnowledgeFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(primaryId: selectedId, sourceId: id),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onVerificationChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeKnowledgeFollowUp(
                              base,
                              row.storageKey,
                              readKnowledgeFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(
                                primaryId: selectedId,
                                verificationId: id,
                              ),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onUnderstandingChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeKnowledgeFollowUp(
                              base,
                              row.storageKey,
                              readKnowledgeFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(
                                primaryId: selectedId,
                                understandingId: id,
                              ),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onApplicationChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeKnowledgeFollowUp(
                              base,
                              row.storageKey,
                              readKnowledgeFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(
                                primaryId: selectedId,
                                applicationId: id,
                              ),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onQuantityChanged: (id) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeKnowledgeFollowUp(
                              base,
                              row.storageKey,
                              readKnowledgeFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(primaryId: selectedId, quantityId: id),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            setSheet(() {});
                            await _save(ref, next);
                          },
                          onMinutesChanged: (value) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeKnowledgeFollowUp(
                              base,
                              row.storageKey,
                              readKnowledgeFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(primaryId: selectedId, minutes: value),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            await _save(ref, next);
                          },
                          onNoteChanged: (value) async {
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            final next = writeKnowledgeFollowUp(
                              base,
                              row.storageKey,
                              readKnowledgeFollowUp(
                                base,
                                row.storageKey,
                              ).copyWith(primaryId: selectedId, note: value),
                            );
                            factors =
                                next.homeTraceFactors[row.storageKey] ??
                                const SalahFactorCapture();
                            await _save(ref, next);
                          },
                        ),
                      if (!hidesHomeTraceFactors(row.storageKey))
                        CheckInFactorSelects.forHomeTrace(
                          storageKey: row.storageKey,
                          outcome: outcome,
                          factors: factors,
                          onHelpingChanged: (id) async {
                            factors = SalahFactorCapture(
                              supportIds: idsFromFactorChoice(id),
                              challengeIds: factors.challengeIds
                                  .take(1)
                                  .toList(),
                              otherText: factors.otherText,
                            );
                            setSheet(() {});
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            await _save(
                              ref,
                              base.withHomeTraceFactors(
                                row.storageKey,
                                factors,
                              ),
                            );
                          },
                          onDistractingChanged: (id) async {
                            factors = SalahFactorCapture(
                              supportIds: factors.supportIds.take(1).toList(),
                              challengeIds: idsFromFactorChoice(id),
                              otherText: factors.otherText,
                            );
                            setSheet(() {});
                            final base =
                                _recordFor(ref, dateKey, record) ??
                                DailyCheckIn.empty(dateKey);
                            await _save(
                              ref,
                              base.withHomeTraceFactors(
                                row.storageKey,
                                factors,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showZakatRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String dateKey,
  required DailyCheckIn? record,
}) async {
  var status = record?.zakat ?? ZakatStatus.unanswered;
  final systemBottom = presentingSystemBottom(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel('Zakat · ${_visibleDate(ref, dateKey)}'),
                const SizedBox(height: 8),
                const Text('Zakat status is not a charity score.'),
                const SizedBox(height: 8),
                CheckInSelect<ZakatStatus>(
                  value: status,
                  sortLabels: false,
                  entries: [
                    for (final option in kZakatPickerOrder)
                      CheckInSelectEntry(value: option, label: option.label),
                  ],
                  onChanged: (option) async {
                    status = option;
                    setSheet(() {});
                    final base =
                        _recordFor(ref, dateKey, record) ??
                        DailyCheckIn.empty(dateKey);
                    await _save(ref, base.copyWith(zakat: option));
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> showPrayerRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PrayerId prayer,
  required String dateKey,
  required DailyCheckIn? record,
}) async {
  var status = record?.prayer(prayer) ?? PrayerStatus.unanswered;
  final systemBottom = presentingSystemBottom(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel(
                  '${prayer.label} · ${_visibleDate(ref, dateKey)}',
                ),
                const SizedBox(height: 4),
                const Text(Copy.seePonderExplore),
                const SizedBox(height: 8),
                const Text(
                  'Marks share one colour across domains. Colour does not rank spirituality.',
                ),
                const SizedBox(height: 8),
                CheckInSelect<PrayerStatus>(
                  value: status,
                  entries: [
                    for (final option in PrayerStatus.values)
                      CheckInSelectEntry(value: option, label: option.label),
                  ],
                  onChanged: (option) async {
                    status = option;
                    setSheet(() {});
                    final base =
                        _recordFor(ref, dateKey, record) ??
                        DailyCheckIn.empty(dateKey);
                    await _save(ref, base.withPrayer(prayer, option));
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openDayEvidence(context, dateKey);
                  },
                  child: const Text('Open recorded evidence'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> showQuranDimensionRecordSheet({
  required BuildContext context,
  required WidgetRef ref,
  required QuranDimension dimension,
  required String dateKey,
  required DailyCheckIn? record,
}) async {
  var outcome = record?.quranOutcome(dimension) ?? TernaryOutcome.unanswered;
  final systemBottom = presentingSystemBottom(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: sheetContentPadding(context, systemBottom: systemBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInRowLabel(
                  '${dimension.label} · ${_visibleDate(ref, dateKey)}',
                ),
                const SizedBox(height: 4),
                const Text(Copy.seePonderExplore),
                const SizedBox(height: 8),
                CheckInSelect<TernaryOutcome>(
                  value: outcome,
                  entries: [
                    for (final option in TernaryOutcome.values)
                      CheckInSelectEntry(
                        value: option,
                        label: option.legendLabel,
                      ),
                  ],
                  onChanged: (option) async {
                    outcome = option;
                    setSheet(() {});
                    final base =
                        _recordFor(ref, dateKey, record) ??
                        DailyCheckIn.empty(dateKey);
                    await _save(ref, base.withQuran(dimension, option));
                  },
                ),
                if (dimension == QuranDimension.consciousApplication)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      Copy.consciousApplicationNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openDayEvidence(context, dateKey);
                  },
                  child: const Text('Open recorded evidence'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
