import 'package:flutter/material.dart';

import '../../app/dimensions.dart';
import '../../app/theme.dart';

class TodayMarkHalo extends StatelessWidget {
  const TodayMarkHalo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    const size = AppDimensions.todayMarkHalo;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: MuhasabahColors.wash(
                  MuhasabahColors.todayMarkWash,
                  MuhasabahColors.todayMarkWashDark,
                  brightness,
                ),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
