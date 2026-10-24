import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/personal_response.dart';
import 'package:muhasabah02/domain/registry_scope.dart';

void main() {
  test('scope keeps mix domains that are also visible', () {
    final scope = RegistryScope.fromPrefs(
      visible: Set<MonitorDomain>.from(MonitorDomain.values),
      mix: mixForKind(PersonalMixKind.firstLook),
    );
    expect(scope.includes(MonitorDomain.salah), isTrue);
    expect(scope.includes(MonitorDomain.quran), isTrue);
    expect(scope.includes(MonitorDomain.dhikr), isTrue);
    expect(scope.includes(MonitorDomain.hadith), isFalse);
    expect(scope.includes(MonitorDomain.charity), isFalse);
    expect(scope.mix.kind.label, 'First season');
    expect(scope.domainList, contains('Salah'));
    expect(scope.domainList, isNot(contains('Hadith')));
  });

  test('GEN notes stay in scope and domain notes follow the mix', () {
    final scope = RegistryScope.fromPrefs(
      visible: Set<MonitorDomain>.from(MonitorDomain.values),
      mix: mixForKind(PersonalMixKind.firstLook),
    );
    final gen = PersonalResponse(
      id: 'g',
      text: 'general',
      createdAt: DateTime(2026, 10, 1),
    );
    final quran = PersonalResponse(
      id: 'q',
      text: 'quran note',
      createdAt: DateTime(2026, 10, 1),
      provenance: const ResponseProvenance(
        originType: ProvenanceOrigin.quranPonder,
        domain: 'quran',
        labelSnapshot: 'Qur’an',
      ),
    );
    final hadith = PersonalResponse(
      id: 'h',
      text: 'hadith note',
      createdAt: DateTime(2026, 10, 1),
      provenance: const ResponseProvenance(
        originType: ProvenanceOrigin.historicalReflection,
        domain: 'hadith',
        labelSnapshot: 'Hadith',
      ),
    );
    expect(scope.includesNote(gen), isTrue);
    expect(scope.includesNote(quran), isTrue);
    expect(scope.includesNote(hadith), isFalse);
  });
}
