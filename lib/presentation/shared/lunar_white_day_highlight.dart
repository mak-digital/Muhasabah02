import 'package:flutter/material.dart';

import '../../app/theme.dart';

class LunarWhiteDayHighlight extends StatelessWidget {
  const LunarWhiteDayHighlight({
    super.key,
    required this.child,
    this.dense = false,
  });

  final Widget child;
  final bool dense;

  static BoxDecoration decoration(Brightness brightness, {bool dense = false}) {
    final color = MuhasabahColors.wash(
      MuhasabahColors.lunarWhiteDayWash,
      MuhasabahColors.lunarWhiteDayWashDark,
      brightness,
    );
    if (dense) {
      return BoxDecoration(color: color);
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: decoration(Theme.of(context).brightness, dense: dense),
      child: child,
    );
    if (dense) {
      return DecoratedBox(
        decoration: decoration(Theme.of(context).brightness, dense: true),
        child: child,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      child: box,
    );
  }
}
