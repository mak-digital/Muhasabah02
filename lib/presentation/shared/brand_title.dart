import 'package:flutter/material.dart';

import '../../domain/copy.dart';
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
              Text(Copy.appName, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                Copy.appSlogan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
              Text(
                Copy.appNotice,
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
