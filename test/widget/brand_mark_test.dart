import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/presentation/shared/brand_mark.dart';

void main() {
  test('brand mark stays inside the circular splash safe zone', () {
    const s = 108.0;
    final g = brandMarkGeometry(s);
    final origin = const Offset(s / 2, s / 2);
    final limit = s * kBrandMarkSafeRadius + 0.05;
    final haloReach =
        (g.filledCenter - origin).distance + g.haloRadius + g.haloStroke / 2;
    expect(haloReach, lessThanOrEqualTo(limit));
    for (final dot in g.dots) {
      expect((dot - origin).distance + g.dotRadius, lessThanOrEqualTo(limit));
    }
    expect(g.dots, hasLength(20));
    expect(math.max(haloReach, 0), greaterThan(s * 0.15));
  });
}
