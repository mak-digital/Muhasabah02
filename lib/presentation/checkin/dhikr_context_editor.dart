import 'package:flutter/material.dart';

import '../../domain/activities.dart';
import '../../domain/copy.dart';
import '../../domain/daily_check_in.dart';
import '../../domain/dhikr_context.dart';
import '../../domain/home_traces.dart';
import '../shared/activity_picker.dart';
import '../shared/salah_activity_mark.dart';
import '../shared/state_marker.dart';
import 'dhikr_performed_list.dart';

class DhikrContextEditor extends StatefulWidget {
  const DhikrContextEditor({
    super.key,
    required this.rowKey,
    required this.label,
    required this.record,
    required this.onChanged,
    this.compact = false,
    this.forceOpen = false,
    this.performedStartsCollapsed = false,
    this.dropdownKey,
  });

  final String rowKey;
  final String label;
  final DailyCheckIn record;
  final ValueChanged<DailyCheckIn> onChanged;
  final bool compact;
  final bool forceOpen;
  final bool performedStartsCollapsed;
  final Key? dropdownKey;

  @override
  State<DhikrContextEditor> createState() => _DhikrContextEditorState();
}

class _DhikrContextEditorState extends State<DhikrContextEditor> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open =
        widget.forceOpen ||
        widget.compact ||
        widget.record.dhikrContextFor(widget.rowKey).isNotEmpty;
  }

  List<DhikrContextCapture> get _captures =>
      widget.record.dhikrContextFor(widget.rowKey);

  (MarkerKind, Color)? _postFardLegend() {
    if (!isDhikrPostFardTrace(widget.rowKey)) return null;
    final id = widget.record.activityFor(widget.rowKey).id;
    if (id == ActivityIds.unanswered) {
      return (MarkerKind.unanswered, SalahActivityMark.unanswered);
    }
    if (id == ActivityIds.noActivity) {
      return (MarkerKind.missed, SalahActivityMark.missedMadeUp);
    }
    return (MarkerKind.filled, SalahActivityMark.colourForId(id));
  }

  @override
  Widget build(BuildContext context) {
    final captures = _captures;
    final legend = _postFardLegend();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        container: true,
        label: '${widget.label}. ${dhikrRowSummary(widget.rowKey, captures)}',
        child: Material(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: widget.dropdownKey,
              initiallyExpanded: _open || widget.compact,
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              onExpansionChanged: (open) => _open = open,
              title: Row(
                children: [
                  Expanded(flex: 3, child: CheckInRowLabel(widget.label)),
                  const SizedBox(width: 8),
                  if (legend != null) ...[
                    RecordedStateMarker(
                      key: Key('dhikr-summary-legend-${widget.rowKey}'),
                      color: legend.$2,
                      kind: legend.$1,
                      semanticLabel: widget.record
                          .activityFor(widget.rowKey)
                          .id,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    flex: 2,
                    child: Text(
                      dhikrRowSummary(widget.rowKey, captures),
                      key: Key('dhikr-summary-${widget.rowKey}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                Copy.dhikrPerformedHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              children: [
                DhikrPerformedList(
                  rowKey: widget.rowKey,
                  record: widget.record,
                  onChanged: widget.onChanged,
                  startExpanded: !widget.performedStartsCollapsed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
