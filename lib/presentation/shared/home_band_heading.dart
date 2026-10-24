import 'package:flutter/material.dart';

import '../../domain/home_traces.dart';
import 'week_nav_strip.dart';

/// Caps band title on a distinct heading wash. Colour names the domain, not rank.
class HomeBandHeading extends StatelessWidget {
  const HomeBandHeading({
    super.key,
    required this.band,
    required this.family,
    required this.baseWash,
  });

  final String band;
  final Color family;
  final Color baseWash;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bandHeadingWash(family, baseWash, context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            displayHomeBand(band),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.45,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
