import 'package:flutter/material.dart';

/// Compact presentation chrome for Home Today tiles, workspace rows, and
/// Quick Tap cards. Does not encode recording behaviour or domain logic.
class DomainActionFrame extends StatelessWidget {
  const DomainActionFrame({
    super.key,
    required this.onTap,
    required this.child,
    required this.color,
    this.radius = 12,
    this.minHeight = 48,
    this.railColor,
    this.outlined = false,
    this.semanticLabel,
    this.excludeChildSemantics = false,
  });

  final VoidCallback onTap;
  final Widget child;
  final Color color;
  final double radius;
  final double minHeight;
  final Color? railColor;
  final bool outlined;
  final String? semanticLabel;
  final bool excludeChildSemantics;

  @override
  Widget build(BuildContext context) {
    final radiusGeometry = BorderRadius.circular(radius);
    Widget body = Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radiusGeometry,
        side: outlined
            ? BorderSide(color: Theme.of(context).colorScheme.outlineVariant)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radiusGeometry,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: railColor == null
              ? child
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ColoredBox(
                        color: railColor!,
                        child: const SizedBox(width: 4),
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
        ),
      ),
    );
    if (semanticLabel == null) return body;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: excludeChildSemantics,
      child: body,
    );
  }
}
