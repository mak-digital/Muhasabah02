import 'package:flutter/material.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';

class LunarWhiteDayHighlight extends StatelessWidget {
  const LunarWhiteDayHighlight({
    super.key,
    required this.child,
    this.dense = false,
  });

  final Widget child;
  final bool dense;

  static BoxDecoration decoration(
    Brightness brightness, {
    bool dense = false,
    BuildContext? context,
  }) {
    final color = MuhasabahColors.wash(
      MuhasabahColors.lunarWhiteDayWash,
      MuhasabahColors.lunarWhiteDayWashDark,
      brightness,
      context,
    );
    if (dense) {
      return BoxDecoration(color: color, shape: BoxShape.circle);
    }
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        width: 1.5,
        color: MuhasabahColors.wash(
          MuhasabahColors.lunarWhiteDayRing,
          MuhasabahColors.lunarWhiteDayRingDark,
          brightness,
          context,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (dense) {
      const size = AppDimensions.todayMarkHalo;
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IgnorePointer(
              child: DecoratedBox(
                decoration: decoration(
                  brightness,
                  dense: true,
                  context: context,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            child,
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      child: DecoratedBox(
        decoration: decoration(brightness, context: context),
        child: child,
      ),
    );
  }
}
