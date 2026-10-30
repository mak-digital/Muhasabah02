import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';
import 'package:muhasabah02/domain/personalisation_resolver.dart';
import 'package:muhasabah02/domain/practice_dhikr_catalog.dart';
import 'package:muhasabah02/domain/practice_huquq_catalog.dart';
import 'package:muhasabah02/domain/practice_learn_focus.dart';
import 'package:muhasabah02/domain/practice_salah_catalog.dart';
import 'package:muhasabah02/domain/salah_extras.dart';

void main() {
  PersonalisationResolver resolver({
    required Set<MonitorDomain> visible,
    required PersonalMix mix,
  }) {
    return PersonalisationResolver(visibleDomains: visible, mix: mix);
  }

  test(
    'post-fard Learn & Practice hides when Salah is not in Domains in Focus',
    () {
      final withoutSalah = resolver(
        visible: {MonitorDomain.quran, MonitorDomain.dhikr},
        mix: PersonalMix.sameAsDomains,
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupPost,
          topic: 'Istighfar three times',
          subgroup: kDhikrSubHighly,
          resolver: withoutSalah,
        ),
        isFalse,
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupMorning,
          topic: 'Ayat al-Kursi in the morning',
          subgroup: kDhikrSubHighly,
          resolver: withoutSalah,
        ),
        isTrue,
      );
      final withSalah = resolver(
        visible: kBasicDhikrVisibleDomains,
        mix: PersonalMix.sameAsDomains,
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupPost,
          topic: 'Istighfar three times',
          subgroup: kDhikrSubHighly,
          resolver: withSalah,
        ),
        isTrue,
      );
    },
  );

  test('same as domains keeps every Learn & Practice item', () {
    final subject = resolver(
      visible: {MonitorDomain.salah, MonitorDomain.huquq},
      mix: PersonalMix.sameAsDomains,
    );
    expect(
      focusedPracticeCatalog(
        domain: MonitorDomain.salah,
        catalog: kPracticeSalahCatalog,
        resolver: subject,
      ),
      kPracticeSalahCatalog,
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.huquq,
        group: kHuquqGroupHardship,
        topic: 'Sick Visit',
        resolver: subject,
      ),
      isTrue,
    );
  });

  test('first season mix keeps obligatory Salah and drops voluntary', () {
    final subject = resolver(
      visible: kBasicDhikrVisibleDomains,
      mix: mixForKind(PersonalMixKind.firstLook),
    );
    final catalog = focusedPracticeCatalog(
      domain: MonitorDomain.salah,
      catalog: kPracticeSalahCatalog,
      resolver: subject,
    );
    expect(catalog.any((item) => item.topic == 'Fajr'), isTrue);
    expect(catalog.any((item) => item.topic == 'Tahajjud'), isFalse);
    expect(catalog.any((item) => item.topic == 'Salat At Tawbah'), isFalse);
    expect(catalog.any((item) => item.topic == 'Jumu‘ah'), isFalse);
    expect(
      focusedPracticeGroups(groups: kPracticeSalahGroups, catalog: catalog),
      [kSalahObligatoryBand],
    );
  });

  test('first season mix keeps Fajr post-fard and morning Dhikr catalogs', () {
    final subject = resolver(
      visible: kBasicDhikrVisibleDomains,
      mix: mixForKind(PersonalMixKind.firstLook),
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.dhikr,
        group: kDhikrGroupPost,
        topic: 'Istighfar three times',
        resolver: subject,
      ),
      isTrue,
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.dhikr,
        group: kDhikrGroupMorning,
        topic: 'Ayat al-Kursi in the morning',
        resolver: subject,
      ),
      isTrue,
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.dhikr,
        group: kDhikrGroupEvening,
        topic: 'Ayat al-Kursi in the evening',
        subgroup: kDhikrSubHighly,
        resolver: subject,
      ),
      isFalse,
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.dhikr,
        group: kDhikrGroupOther,
        topic: 'La hawla wa la quwwata',
        subgroup: kDhikrSubGeneral,
        resolver: subject,
      ),
      isFalse,
    );
  });

  test(
    'post-fard Learn stays hidden without Salah even if mix names those rows',
    () {
      final subject = resolver(
        visible: {MonitorDomain.quran, MonitorDomain.dhikr},
        mix: mixForKind(
          PersonalMixKind.custom,
          customKeys: {
            'dhikr.postFardFajr',
            'dhikr.morningAdhkar',
            'dhikr.generalDhikr',
          },
        ),
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupPost,
          topic: 'Istighfar three times',
          subgroup: kDhikrSubHighly,
          resolver: subject,
        ),
        isFalse,
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupMorning,
          topic: 'Ayat al-Kursi in the morning',
          subgroup: kDhikrSubHighly,
          resolver: subject,
        ),
        isTrue,
      );
    },
  );

  test(
    'custom mix keeps General Dhikr Learn items and hides other subgroups',
    () {
      final subject = resolver(
        visible: kBasicDhikrVisibleDomains,
        mix: mixForKind(
          PersonalMixKind.custom,
          customKeys: {'dhikr.generalDhikr'},
        ),
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupOther,
          topic: 'La hawla wa la quwwata',
          subgroup: kDhikrSubGeneral,
          resolver: subject,
        ),
        isTrue,
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupOther,
          topic: 'All praise is for Allah',
          subgroup: kDhikrSubGratitude,
          resolver: subject,
        ),
        isFalse,
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupMorning,
          topic: 'Ayat al-Kursi in the morning',
          subgroup: kDhikrSubHighly,
          resolver: subject,
        ),
        isFalse,
      );
      expect(
        practiceLearnItemAllowed(
          domain: MonitorDomain.dhikr,
          group: kDhikrGroupEvening,
          topic: 'Ayat al-Kursi in the evening',
          subgroup: kDhikrSubHighly,
          resolver: subject,
        ),
        isFalse,
      );
    },
  );

  test('custom mix keeps Parents Learn items and hides Neighbours', () {
    final subject = resolver(
      visible: {MonitorDomain.salah, MonitorDomain.quran, MonitorDomain.huquq},
      mix: mixForKind(PersonalMixKind.custom, customKeys: {'huquq.parents'}),
    );
    expect(practiceLearnShowsDomain(MonitorDomain.huquq, subject), isTrue);
    expect(practiceLearnShowsDomain(MonitorDomain.salah, subject), isFalse);
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.huquq,
        group: kHuquqGroupHousehold,
        topic: 'Parents',
        resolver: subject,
      ),
      isTrue,
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.huquq,
        group: kHuquqGroupHousehold,
        topic: 'Spouse',
        resolver: subject,
      ),
      isFalse,
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.huquq,
        group: kHuquqGroupNeighbours,
        topic: 'Neighbours',
        resolver: subject,
      ),
      isFalse,
    );
  });

  test('Learn & Practice restores items when domains and mix rows return', () {
    const dhikrVisible = {MonitorDomain.quran, MonitorDomain.dhikr};
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.dhikr,
        group: kDhikrGroupPost,
        topic: 'Istighfar three times',
        subgroup: kDhikrSubHighly,
        resolver: resolver(
          visible: dhikrVisible,
          mix: PersonalMix.sameAsDomains,
        ),
      ),
      isFalse,
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.dhikr,
        group: kDhikrGroupPost,
        topic: 'Istighfar three times',
        subgroup: kDhikrSubHighly,
        resolver: resolver(
          visible: kBasicDhikrVisibleDomains,
          mix: PersonalMix.sameAsDomains,
        ),
      ),
      isTrue,
    );

    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.dhikr,
        group: kDhikrGroupOther,
        topic: 'All praise is for Allah',
        subgroup: kDhikrSubGratitude,
        resolver: resolver(
          visible: kBasicDhikrVisibleDomains,
          mix: mixForKind(
            PersonalMixKind.custom,
            customKeys: {'dhikr.generalDhikr'},
          ),
        ),
      ),
      isFalse,
    );
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.dhikr,
        group: kDhikrGroupOther,
        topic: 'All praise is for Allah',
        subgroup: kDhikrSubGratitude,
        resolver: resolver(
          visible: kBasicDhikrVisibleDomains,
          mix: mixForKind(
            PersonalMixKind.custom,
            customKeys: {'dhikr.generalDhikr', 'dhikr.gratitudeDhikr'},
          ),
        ),
      ),
      isTrue,
    );

    expect(
      practiceLearnShowsDomain(
        MonitorDomain.huquq,
        resolver(
          visible: kBasicDhikrVisibleDomains,
          mix: PersonalMix.sameAsDomains,
        ),
      ),
      isFalse,
    );
    expect(
      practiceLearnShowsDomain(
        MonitorDomain.huquq,
        resolver(
          visible: {...kBasicDhikrVisibleDomains, MonitorDomain.huquq},
          mix: PersonalMix.sameAsDomains,
        ),
      ),
      isTrue,
    );
  });

  test('hidden domain drops Learn & Practice even if mix names a row', () {
    final subject = resolver(
      visible: kBasicDhikrVisibleDomains,
      mix: mixForKind(
        PersonalMixKind.custom,
        customKeys: {'huquq.parents', 'salah.fajr'},
      ),
    );
    expect(practiceLearnShowsDomain(MonitorDomain.huquq, subject), isFalse);
    expect(
      practiceLearnItemAllowed(
        domain: MonitorDomain.huquq,
        group: kHuquqGroupHousehold,
        topic: 'Parents',
        resolver: subject,
      ),
      isFalse,
    );
  });
}
