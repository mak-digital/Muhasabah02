import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import '../shared/app_language_scope.dart';
import '../shared/system_insets.dart';
import '../shared/ui_bits.dart';

/// Lets a Progress cell collapse the Review marks tile without wiring each tap.
class ProgressChromeScope extends InheritedWidget {
  const ProgressChromeScope({
    super.key,
    required this.collapseMarks,
    required super.child,
  });

  final VoidCallback collapseMarks;

  static void collapseMarksOf(BuildContext context) {
    context
        .getInheritedWidgetOfExactType<ProgressChromeScope>()
        ?.collapseMarks();
  }

  @override
  bool updateShouldNotify(ProgressChromeScope oldWidget) =>
      collapseMarks != oldWidget.collapseMarks;
}

PreferredSizeWidget progressAppBar(BuildContext context, String title) {
  return AppBar(
    toolbarHeight: 48,
    titleSpacing: 0,
    title: Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700, height: 1.15),
    ),
  );
}

/// Pins the focus question and 7/30/90 selector while calendars scroll.
class ProgressReviewFrame extends StatefulWidget {
  const ProgressReviewFrame({
    super.key,
    this.focusQuestion,
    required this.days,
    required this.onPeriodChanged,
    this.marksTitle = Copy.progressMarksTitle,
    required this.marks,
    required this.children,
  });

  final String? focusQuestion;
  final int days;
  final ValueChanged<int> onPeriodChanged;
  final String marksTitle;
  final Widget marks;
  final List<Widget> children;

  @override
  State<ProgressReviewFrame> createState() => _ProgressReviewFrameState();
}

class _ProgressReviewFrameState extends State<ProgressReviewFrame> {
  var _marksOpen = true;

  void _collapseMarks() {
    if (!_marksOpen) return;
    setState(() => _marksOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final pad = pageListPadding(context, recoverSystemBottom: true);
    final question = widget.focusQuestion;
    final theme = Theme.of(context);
    return ProgressChromeScope(
      collapseMarks: _collapseMarks,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad.left, 4, pad.right, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (question != null && question.isNotEmpty) ...[
                    Text(
                      uiText(context, question),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  PeriodSelector(
                    days: widget.days,
                    onChanged: (days) {
                      _collapseMarks();
                      widget.onPeriodChanged(days);
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad.left, 0, pad.right, pad.bottom),
              children: [
                CollapsingNoteTile(
                  title: widget.marksTitle,
                  expanded: _marksOpen,
                  onExpansionChanged: (open) {
                    if (open == _marksOpen) return;
                    setState(() => _marksOpen = open);
                  },
                  child: widget.marks,
                ),
                const SizedBox(height: 8),
                ...widget.children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
