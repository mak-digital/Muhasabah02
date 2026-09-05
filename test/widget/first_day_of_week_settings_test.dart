import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/copy.dart';
import 'package:muhasabah02/domain/first_day_of_week.dart';
import 'package:muhasabah02/presentation/settings/settings_screen.dart';

import '../support/test_app.dart';

void main() {
  test('default first day of week is Monday', () {
    expect(FirstDayOfWeekPrefX.fromId(null), FirstDayOfWeekPref.monday);
    expect(FirstDayOfWeekPref.monday.sundayBasedIndex(0), 1);
    expect(FirstDayOfWeekPref.sunday.sundayBasedIndex(3), 0);
    expect(FirstDayOfWeekPref.saturday.sundayBasedIndex(0), 6);
    expect(FirstDayOfWeekPref.deviceLocale.sundayBasedIndex(0), 0);
    expect(FirstDayOfWeekPref.deviceLocale.sundayBasedIndex(1), 1);
  });

  testWidgets('settings can select each first-day option', (tester) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text(Copy.appearancePreferences), findsOneWidget);
    await tester.tap(find.text(Copy.firstDayOfWeek));
    await tester.pumpAndSettle();
    expect(find.byType(FirstDayOfWeekSettingsScreen), findsOneWidget);
    for (final option in FirstDayOfWeekPref.values) {
      final label = option == FirstDayOfWeekPref.monday
          ? '${option.label} (default)'
          : option.label;
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(find.text(Copy.firstDayOfWeekNote), findsOneWidget);
  });
}
