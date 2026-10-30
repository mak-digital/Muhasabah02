import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/app/theme.dart';
import 'package:muhasabah02/domain/app_appearance.dart';

void main() {
  test('unknown appearance id stays System', () {
    expect(AppAppearanceX.fromId(null), AppAppearance.system);
    expect(AppAppearanceX.fromId(''), AppAppearance.system);
    expect(AppAppearanceX.fromId('sepia'), AppAppearance.system);
    expect(AppAppearanceX.fromPrefIndex(-1), AppAppearance.system);
    expect(AppAppearanceX.fromPrefIndex(99), AppAppearance.system);
  });

  test('legacy 0–2 indexes stay System, Light, Dark', () {
    expect(AppAppearance.system.prefIndex, 0);
    expect(AppAppearance.light.prefIndex, 1);
    expect(AppAppearance.dark.prefIndex, 2);
    expect(AppAppearanceX.fromPrefIndex(1), AppAppearance.light);
    expect(AppAppearanceX.fromPrefIndex(2), AppAppearance.dark);
  });

  test('named looks keep light or dark slots without scoring', () {
    expect(AppAppearance.warmPaper.usesDarkSlot, isFalse);
    expect(AppAppearance.quietSlate.usesDarkSlot, isFalse);
    expect(AppAppearance.midnight.usesDarkSlot, isTrue);
    expect(AppAppearance.warmPaper.followSystem, isFalse);
    expect(
      MuhasabahPalette.lightFor(AppAppearance.warmPaper).surface,
      const Color(0xFFF6EAD6),
    );
    expect(
      MuhasabahPalette.lightFor(AppAppearance.quietSlate).surface,
      const Color(0xFFE7EEF2),
    );
    expect(
      MuhasabahPalette.darkFor(AppAppearance.midnight).surface,
      const Color(0xFF0D1524),
    );
    expect(
      MuhasabahPalette.darkFor(AppAppearance.dark).surface,
      MuhasabahPalette.dark.surface,
    );
  });
}
