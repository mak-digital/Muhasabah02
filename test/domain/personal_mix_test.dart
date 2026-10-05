import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';

void main() {
  test('mix catalog covers salah, quran, traces, and zakat', () {
    expect(mixCatalog.any((item) => item.id == 'salah.fajr'), isTrue);
    expect(mixCatalog.any((item) => item.id == 'quran.reading'), isTrue);
    expect(
      mixCatalog.any((item) => item.id == 'akhlaq.heldBackFromAHabit'),
      isTrue,
    );
    expect(mixCatalog.any((item) => item.id == kZakatMixKey), isTrue);
    expect(mixCatalog.any((item) => item.id == kHajjMixKey), isTrue);
    expect(mixCatalog.any((item) => item.id == kHajjPreparationKey), isTrue);
    expect(
      mixCatalog.any((item) => item.id == 'akhlaq.guardedMyGlance'),
      isFalse,
    );
  });

  test('first season mix is a short slice of Salah, Qur’an and Dhikr', () {
    final mix = mixForKind(PersonalMixKind.firstLook);
    expect(encodePersonalMix(mix), 'firstLook');
    expect(decodePersonalMix('firstLook').keys, kFirstLookMixKeys);
    expect(kFirstLookMixKeys, {
      'salah.fajr',
      'salah.dhuhr',
      'salah.asr',
      'salah.maghrib',
      'salah.isha',
      'quran.reading',
      'quran.meaning',
      'quran.consciousApplication',
      'dhikr.postFardFajr',
      'dhikr.morningAdhkar',
    });
    expect(homeMixDomains(kBasicDhikrVisibleDomains, mix), [
      MonitorDomain.salah,
      MonitorDomain.quran,
      MonitorDomain.dhikr,
    ]);
    expect(
      mixUsesCompactHomeWeek(
        MonitorDomain.salah,
        mix,
        kBasicDhikrVisibleDomains,
      ),
      isFalse,
    );
  });

  test('unset mix follows visible domains and is not a score', () {
    expect(decodePersonalMix(null), PersonalMix.sameAsDomains);
    expect(
      resolvePersonalMixKeys(
        PersonalMix.sameAsDomains,
        kBasicDhikrVisibleDomains,
      ).any((id) => mixItemById[id]?.domain == MonitorDomain.dhikr),
      isTrue,
    );
    expect(
      resolvePersonalMixKeys(
        PersonalMix.sameAsDomains,
        kBasicDhikrVisibleDomains,
      ).any((id) => mixItemById[id]?.domain == MonitorDomain.akhlaq),
      isFalse,
    );
    expect(
      mixUsesCompactHomeWeek(
        MonitorDomain.dhikr,
        PersonalMix.sameAsDomains,
        allVisible(),
      ),
      isFalse,
    );
    expect(
      mixUsesCompactHomeWeek(
        MonitorDomain.time,
        PersonalMix.sameAsDomains,
        allVisible(),
      ),
      isFalse,
    );
  });

  test('worship mix includes obligatory salah and post-fard dhikr', () {
    expect(kWorshipMixKeys.contains('salah.fajr'), isTrue);
    expect(kWorshipMixKeys.contains('quran.reading'), isTrue);
    expect(kWorshipMixKeys.contains('dhikr.postFardFajr'), isTrue);
    expect(kWorshipMixKeys.contains(kHajjMixKey), isTrue);
    expect(kWorshipMixKeys.contains(kHajjPreparationKey), isTrue);
    expect(kWorshipMixKeys.contains('akhlaq.patience'), isFalse);
    final mix = mixForKind(PersonalMixKind.worship);
    expect(encodePersonalMix(mix), 'worship');
    expect(decodePersonalMix('worship').keys, kWorshipMixKeys);
  });

  test('custom mix round-trips selected keys', () {
    final mix = mixForKind(
      PersonalMixKind.custom,
      customKeys: {'salah.fajr', 'akhlaq.heldBackFromAHabit'},
    );
    final raw = encodePersonalMix(mix);
    expect(decodePersonalMix(raw).kind, PersonalMixKind.custom);
    expect(decodePersonalMix(raw).keys, {
      'salah.fajr',
      'akhlaq.heldBackFromAHabit',
    });
  });

  test('worship mix Home omits domains outside the mix', () {
    final mix = mixForKind(PersonalMixKind.worship);
    final home = homeMixDomains(kBasicDhikrVisibleDomains, mix);
    expect(home, [
      MonitorDomain.salah,
      MonitorDomain.quran,
      MonitorDomain.dhikr,
    ]);
    expect(home, isNot(contains(MonitorDomain.akhlaq)));
    expect(home, isNot(contains(MonitorDomain.charity)));
  });

  test('hidden mix domains stay listed until the domain is shown', () {
    final hidden = hiddenDomainsInMix(
      mixForKind(PersonalMixKind.worship),
      kBasicDhikrVisibleDomains,
    );
    expect(hidden, {MonitorDomain.hadith, MonitorDomain.hajj});
    expect(
      domainsSettingsSubtitle(
        kBasicDhikrVisibleDomains,
        mixForKind(PersonalMixKind.worship),
      ),
      'Salah, Qur’an & Dhikr · Mix: Worship I notice',
    );
  });

  test('named mix uses a full week on Home for touched domains', () {
    final mix = mixForKind(PersonalMixKind.worship);
    expect(
      mixUsesCompactHomeWeek(MonitorDomain.salah, mix, allVisible()),
      isFalse,
    );
    expect(
      mixUsesCompactHomeWeek(MonitorDomain.dhikr, mix, allVisible()),
      isFalse,
    );
    expect(
      mixUsesCompactHomeWeek(MonitorDomain.akhlaq, mix, allVisible()),
      isTrue,
    );
  });
}

Set<MonitorDomain> allVisible() =>
    Set<MonitorDomain>.from(MonitorDomain.values);
