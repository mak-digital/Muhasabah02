import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/hajj_pathway.dart';
import 'package:muhasabah02/domain/hajj_planning_windows.dart';

void main() {
  test('upcoming Hajj year stays on current Dhul-Hijjah until 13th', () {
    expect(upcomingHajjHijriYear(DateTime(2026, 5, 1)), 1447);
    expect(upcomingHajjHijriYear(DateTime(2026, 10, 17)), 1448);
  });

  test('rites window is civil 8 to 13 Dhul-Hijjah', () {
    final window = hajjRitesPlanningWindow(1447);
    expect(window.start.hijri.year, 1447);
    expect(window.start.hijri.month, 12);
    expect(window.start.hijri.day, 8);
    expect(window.end.hijri.day, 13);
    expect(window.contains(window.start.gregorian), isTrue);
    expect(window.contains(window.end.gregorian), isTrue);
  });

  test('national mission estimate is earlier than domestic', () {
    final mission = hajjRegistrationEstimate(
      family: HajjPathwayFamily.nationalMission,
      hijriYear: 1447,
    );
    final domestic = hajjRegistrationEstimate(
      family: HajjPathwayFamily.saudiDomestic,
      hijriYear: 1447,
    );
    expect(
      mission.typicalWindow.start.dateKeyValue.compareTo(
        domestic.typicalWindow.start.dateKeyValue,
      ),
      lessThan(0),
    );
    expect(mission.suggestedOpen.hijri.month, 7);
    expect(domestic.suggestedOpen.hijri.month, 11);
  });

  test('authority text maps onto a planning family', () {
    expect(
      hajjPathwayFamilyFromAuthority('Nusuk'),
      HajjPathwayFamily.officialDirect,
    );
    expect(
      hajjPathwayFamilyFromAuthority(HajjPathwayFamily.licensedOperator.label),
      HajjPathwayFamily.licensedOperator,
    );
    expect(hajjPathwayFamilyFromAuthority(''), isNull);
  });
}
