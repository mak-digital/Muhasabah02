import 'package:flutter/material.dart';

import '../../domain/copy.dart';
import 'app_language_scope.dart';
import 'brand_mark.dart';

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  static const toolbarHeight = 76.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.2,
    );
    return Row(
      children: [
        const BrandMark(size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  uiText(context, Copy.appName),
                  maxLines: 1,
                  softWrap: false,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
              Text(
                uiText(context, Copy.appSlogan),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
              Text(
                uiText(context, Copy.appNotice),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
