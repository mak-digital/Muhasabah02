import 'package:flutter/material.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';
import '../../domain/date_key.dart';
import 'lunar_white_day_highlight.dart';

class MarkHalo extends StatelessWidget {
  const MarkHalo({
    super.key,
    required this.child,
    required this.color,
    this.size = AppDimensions.todayMarkHalo,
  });

  final Widget child;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.expand(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class TodayMarkHalo extends StatelessWidget {
  const TodayMarkHalo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return MarkHalo(
      color: MuhasabahColors.wash(
        MuhasabahColors.todayMarkWash,
        MuhasabahColors.todayMarkWashDark,
        brightness,
      ),
      child: child,
    );
  }
}

/// Today: circular halo a stroke-and-a-half larger than the mark.
/// White Days: the same circle in the White Day wash, not a cell-sized square.
Widget decorateWeekMark({
  required Widget marker,
  required DateCellKind kind,
  bool lunarWhiteDay = false,
  Key? todayKey,
  Key? lunarKey,
}) {
  var child = marker;
  if (kind == DateCellKind.today) {
    child = TodayMarkHalo(key: todayKey, child: child);
  } else if (lunarWhiteDay) {
    child = LunarWhiteDayHighlight(key: lunarKey, dense: true, child: child);
  }
  if (kind == DateCellKind.future) {
    return Opacity(opacity: 0.28, child: child);
  }
  return child;
}
