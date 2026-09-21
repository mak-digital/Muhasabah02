import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/personalisation_resolver.dart';
import 'package:muhasabah02/domain/quran.dart';
import 'package:muhasabah02/domain/salah_extras.dart';

void main() {
  PersonalisationResolver resolver({
    Set<MonitorDomain>? visible,
    PersonalMix? mix,
  }) {
    return PersonalisationResolver(
      visibleDomains: visible ?? kBasicAkhlaqVisibleDomains,
      mix: mix ?? PersonalMix.sameAsDomains,
    );
  }

  test('explicit hidden domain stays hidden', () {
    final visible = {...kBasicAkhlaqVisibleDomains}
      ..remove(MonitorDomain.charity);
    final subject = resolver(visible: visible);
    expect(subject.isDomainVisible(MonitorDomain.charity), isFalse);
    expect(subject.homeDomains, isNot(contains(MonitorDomain.charity)));
    expect(subject.reviewDomains, isNot(contains(MonitorDomain.charity)));
    expect(subject.isRowIncluded(kZakatMixKey), isFalse);
    expect(
      subject.domainReason(MonitorDomain.charity),
      PersonalisationReason.hiddenDomain,
    );
  });

  test('explicit visible domain remains available', () {
    final subject = resolver();
    expect(subject.isDomainVisible(MonitorDomain.quran), isTrue);
    expect(subject.reviewDomains, contains(MonitorDomain.quran));
    expect(subject.homeDomains, contains(MonitorDomain.quran));
    expect(
      subject.domainReason(MonitorDomain.quran),
      PersonalisationReason.explicitDomain,
    );
  });

  test('explicit mix excludes a non-selected row', () {
    final mix = mixForKind(PersonalMixKind.firstLook);
    final subject = resolver(mix: mix);
    expect(subject.isRowIncluded('quran.tafsir'), isFalse);
    expect(
      subject.rowReason('quran.tafsir'),
      PersonalisationReason.excludedByMix,
    );
    expect(
      subject.includedQuranDimensions,
      isNot(contains(QuranDimension.tafsir)),
    );
  });

  test('selected mix row remains available when the domain is visible', () {
    final mix = mixForKind(PersonalMixKind.firstLook);
    final subject = resolver(mix: mix);
    expect(subject.isRowIncluded('quran.reading'), isTrue);
    expect(
      subject.rowReason('quran.reading'),
      PersonalisationReason.explicitMix,
    );
    expect(subject.homeDomains, contains(MonitorDomain.quran));
  });

  test('convenience order cannot override explicit exclusion', () {
    final mix = mixForKind(PersonalMixKind.firstLook);
    final subject = resolver(mix: mix);
    expect(subject.isRowIncluded('quran.tafsir'), isFalse);
    final ordered = subject.rowsPreferringConvenience([
      'quran.tafsir',
      'quran.reading',
    ]);
    expect(ordered.first, 'quran.reading');
    expect(ordered, isNot(contains('quran.tafsir')));
    expect(ordered, contains('quran.reading'));
  });

  test('resolver inputs are visibility and mix only', () {
    const subject = PersonalisationResolver(
      visibleDomains: kBasicAkhlaqVisibleDomains,
      mix: PersonalMix.sameAsDomains,
    );
    expect(subject.visibleDomains, kBasicAkhlaqVisibleDomains);
    expect(subject.mix.kind, PersonalMixKind.sameAsDomains);
    expect(subject.effectiveRowIds, isNotEmpty);
  });

  test('Application Reflection is not a recurring mix row', () {
    final same = resolver();
    final firstLook = resolver(mix: mixForKind(PersonalMixKind.firstLook));
    expect(same.includesApplicationReflection, isFalse);
    expect(firstLook.includesApplicationReflection, isFalse);
    expect(same.isRowIncluded('quran.applicationReflection'), isFalse);
    expect(
      same.rowReason('quran.applicationReflection'),
      PersonalisationReason.unknownOrRetired,
    );
    expect(
      same.includedQuranDimensions,
      containsAll([
        QuranDimension.reading,
        QuranDimension.meaning,
        QuranDimension.memorisation,
        QuranDimension.revision,
        QuranDimension.tafsir,
        QuranDimension.reflection,
        QuranDimension.consciousApplication,
      ]),
    );
    expect(
      same.includedQuranDimensions,
      isNot(contains(QuranDimension.applicationReflection)),
    );
  });

  test('retired identifiers remain excluded', () {
    final subject = resolver();
    expect(subject.isRowIncluded('family.parentsContact'), isFalse);
    expect(
      subject.rowReason('family.parentsContact'),
      PersonalisationReason.unknownOrRetired,
    );
    expect(
      subject.rowsPreferringConvenience(['family.parentsContact']),
      isNot(contains('family.parentsContact')),
    );
  });

  test('same-as-domains default matches current mix resolution', () {
    const mix = PersonalMix.sameAsDomains;
    final visible = kBasicAkhlaqVisibleDomains;
    final subject = resolver(visible: visible, mix: mix);
    expect(subject.effectiveRowIds, resolvePersonalMixKeys(mix, visible));
    expect(subject.homeDomains, homeMixDomains(visible, mix));
    expect(subject.reviewDomains, orderedVisibleDomains(visible, mix));
    expect(subject.homeDomains, orderedVisibleDomains(visible, mix));
    expect(subject.isRowIncluded('salah.fajr'), isTrue);
    expect(
      subject.rowReason('salah.fajr'),
      PersonalisationReason.sameAsDomains,
    );
  });

  test('hidden domain wins over mix keys for that domain', () {
    final mix = mixForKind(PersonalMixKind.firstLook);
    final visible = {...kBasicAkhlaqVisibleDomains}
      ..remove(MonitorDomain.quran);
    final subject = resolver(visible: visible, mix: mix);
    expect(subject.isRowIncluded('quran.reading'), isFalse);
    expect(
      subject.rowReason('quran.reading'),
      PersonalisationReason.hiddenDomain,
    );
    expect(subject.homeDomains, isNot(contains(MonitorDomain.quran)));
  });

  test('mix cannot remove obligatory Salah from the conceptual id set', () {
    final mix = PersonalMix(
      kind: PersonalMixKind.custom,
      keys: {'quran.reading'},
    );
    final subject = resolver(mix: mix);
    expect(subject.isRowIncluded('salah.fajr'), isFalse);
    expect(obligatorySalahRows, contains(SalahTraceRow.fajr));
    expect(obligatorySalahRows.length, 5);
  });

  test('Zakat mix key stays on Charity and is not a Wealth merge', () {
    final subject = resolver();
    expect(mixItemById[kZakatMixKey]?.domain, MonitorDomain.charity);
    expect(subject.isRowIncluded(kZakatMixKey), isTrue);
  });
}
