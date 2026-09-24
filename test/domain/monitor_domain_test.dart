import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/domain/home_traces.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/quran.dart';

void main() {
  test('unset stored domains use the Salah, Qur’an & Dhikr preset', () {
    expect(decodeVisibleDomains(null), kBasicDhikrVisibleDomains);
    expect(
      visibleDomainsSummary(decodeVisibleDomains(null)),
      'Salah, Qur’an & Dhikr',
    );
  });

  test('empty stored domains show none', () {
    expect(decodeVisibleDomains(''), isEmpty);
    expect(visibleDomainsSummary(const {}), 'None shown');
  });

  test(
    'working prefs migrate the previous named preset; custom decode does not',
    () {
      const previous = 'salah,quran,hadith,akhlaq,huquq,charity';
      expect(decodeVisibleDomains(previous), kLegacyBasicAkhlaqVisibleDomains);
      expect(
        decodeVisibleDomains(previous, migrateNamedPreset: true),
        kBasicDhikrVisibleDomains,
      );
      expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.akhlaq), isFalse);
      expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.dhikr), isTrue);
    },
  );

  test('stored ids round-trip in canonical order', () {
    final stored = encodeVisibleDomains({
      MonitorDomain.hadith,
      MonitorDomain.salah,
    });
    expect(stored, 'salah,hadith');
    expect(decodeVisibleDomains(stored), {
      MonitorDomain.salah,
      MonitorDomain.hadith,
    });
    expect(
      visibleDomainsSummary(decodeVisibleDomains(stored)),
      'Salah & Prayer Quality, Hadith & Living Sunnah',
    );
  });

  test('Dhikr domain names the remembrance focus without scoring it', () {
    expect(MonitorDomain.dhikr.label, 'Dhikr & Dua');
    expect(
      MonitorDomain.dhikr.focusQuestion,
      'Did I remember Allah outside of prayer?',
    );
    expect(MonitorDomain.dhikr.id, 'dhikr');
  });

  test('Akhlaq domain is observational and not a character grade', () {
    expect(MonitorDomain.akhlaq.label, 'Character & Morals (Akhlaq)');
    expect(
      MonitorDomain.akhlaq.focusQuestion,
      'Did my behavior today invite people toward goodness?',
    );
    expect(MonitorDomain.akhlaq.id, 'akhlaq');
    expect(
      traceOutcomeLabel('akhlaq.patience', TernaryOutcome.positive),
      'I noticed this in myself — Patience',
    );
    expect(
      traceOutcomeLabel('akhlaq.patience', TernaryOutcome.negative),
      'I did not notice this today — Patience',
    );
    expect(akhlaqHomeRows.map((row) => row.storageKey), [
      'akhlaq.patience',
      'akhlaq.humility',
      'akhlaq.truthfulness',
      'akhlaq.gentleness',
      'akhlaq.courage',
      'akhlaq.gratitude',
      'akhlaq.contentment',
      'akhlaq.pausedBeforeReacting',
      'akhlaq.honestyInSmallMatters',
      'akhlaq.letGoOfGrudge',
      'akhlaq.modestSpeech',
      'akhlaq.modestDress',
      'akhlaq.modestGaze',
      'akhlaq.walkedAwayFromArgument',
      'akhlaq.heldBackFromAHabit',
    ]);
    expect(
      homeTraceRowByKey('akhlaq.gratitude')?.label,
      'Thankfulness in how I acted',
    );
    expect(
      homeTraceRowByKey('akhlaq.modestSpeech')?.label,
      'Guarded how I spoke (tone)',
    );
    expect(homeTraceRowByKey('akhlaq.modestGaze')?.label, 'Guarded my gaze');
    expect(
      homeTraceRowByKey('akhlaq.heldBackFromAHabit')?.label,
      'Held back from a habit I am trying to leave',
    );
    expect(
      akhlaqHomeRows.map((row) => row.storageKey),
      isNot(contains('akhlaq.guardedMyGlance')),
    );
    expect(
      homeTraceRowByKey('akhlaq.guardedMyGlance')?.label,
      'Guarded my glance',
    );
    expect(hidesHomeTraceFactors('akhlaq.heldBackFromAHabit'), isTrue);
    expect(
      visibleDomainsSummary(
        decodeVisibleDomains('salah,quran,dhikr,fasting,family,charity,hadith'),
      ),
      'All domains',
    );
  });

  test('basic Dhikr preset includes Hadith after Qur’an', () {
    expect(
      visibleDomainsSummary(kBasicDhikrVisibleDomains),
      'Salah, Qur’an & Dhikr',
    );
    expect(kBasicDhikrVisibleDomains, {
      MonitorDomain.salah,
      MonitorDomain.quran,
      MonitorDomain.hadith,
      MonitorDomain.dhikr,
      MonitorDomain.huquq,
      MonitorDomain.charity,
    });
    expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.akhlaq), isFalse);
    expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.dhikr), isTrue);
    expect(
      kBasicDhikrVisibleDomains.contains(MonitorDomain.knowledge),
      isFalse,
    );
    expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.time), isFalse);
    expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.health), isFalse);
    expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.wealth), isFalse);
    expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.ummah), isFalse);
    expect(
      MonitorDomain.values.indexOf(MonitorDomain.hadith),
      MonitorDomain.values.indexOf(MonitorDomain.quran) + 1,
    );
  });

  test('shown domains use a full Home week', () {
    expect(usesCompactHomeWeek(MonitorDomain.salah), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.quran), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.hadith), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.akhlaq), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.huquq), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.charity), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.dhikr), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.knowledge), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.time), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.health), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.wealth), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.ummah), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.fasting), isFalse);
    expect(usesCompactHomeWeek(MonitorDomain.hajj), isFalse);
    expect(kBasicDhikrVisibleDomains.contains(MonitorDomain.hajj), isFalse);
    expect(MonitorDomain.salah.shortLabel, 'Salah');
    expect(MonitorDomain.quran.shortLabel, 'Qur’an');
    expect(MonitorDomain.akhlaq.shortLabel, 'Character');
    expect(MonitorDomain.huquq.shortLabel, 'Rights');
    expect(
      homeDomainStageIndex([
        MonitorDomain.salah,
        MonitorDomain.quran,
      ], MonitorDomain.quran),
      1,
    );
    expect(
      homeDomainStageIndex(const [MonitorDomain.salah], MonitorDomain.charity),
      0,
    );
  });

  test('Hadith & Living Sunnah is observational and not a revival score', () {
    expect(MonitorDomain.hadith.label, 'Hadith & Living Sunnah');
    expect(
      MonitorDomain.hadith.focusQuestion,
      'Did a teaching of the Prophet ﷺ reach my day?',
    );
    expect(MonitorDomain.hadith.id, 'hadith');
    expect(hadithHomeRows.map((row) => row.storageKey), [
      'hadith.reading',
      'hadith.listening',
      'hadith.memorisation',
      'hadith.revision',
      'hadith.studyCircle',
      'hadith.teachingDiscussion',
      'hadith.reflection',
      'hadith.livedSunnah',
    ]);
    expect(
      homeTraceRowByKey('hadith.livedSunnah')?.label,
      'Noticed a sunnah in how I lived today',
    );
    expect(hidesHomeTraceFactors('hadith.livedSunnah'), isTrue);
    expect(hidesHomeTraceFactors('hadith.reading'), isFalse);
    expect(
      traceOutcomeLabel('hadith.livedSunnah', TernaryOutcome.positive),
      'I noticed this in myself — Noticed a sunnah in how I lived today',
    );
    expect(
      traceOutcomeLabel('hadith.livedSunnah', TernaryOutcome.negative),
      'I did not notice this today — Noticed a sunnah in how I lived today',
    );
  });

  test('Knowledge domain is observational and not a learnedness grade', () {
    expect(MonitorDomain.knowledge.label, 'Knowledge & Beneficial Speech');
    expect(
      MonitorDomain.knowledge.focusQuestion,
      'Did I learn something true, and did I speak only what was beneficial?',
    );
    expect(MonitorDomain.knowledge.id, 'knowledge');
    expect(
      traceOutcomeLabel(
        'knowledge.learnedSomethingTrue',
        TernaryOutcome.positive,
      ),
      'I noticed this in myself — Learned something true',
    );
    expect(
      homeTraceRowByKey('knowledge.beneficialReading')?.label,
      'Beneficial reading (not Qur’an or Hadith)',
    );
    expect(
      monitorDomainForStorageKey('knowledge.taughtSomeone'),
      MonitorDomain.knowledge,
    );
  });

  test('Time & Barakah is observational and not a productivity score', () {
    expect(MonitorDomain.time.label, 'Time & Barakah');
    expect(
      MonitorDomain.time.focusQuestion,
      'Did I treat my time as a trust from Allah?',
    );
    expect(MonitorDomain.time.id, 'time');
    expect(hidesHomeTraceFactors('time.presentInWhatIWasDoing'), isTrue);
    expect(
      monitorDomainForStorageKey('time.didWhatIDelayed'),
      MonitorDomain.time,
    );
    expect(timeHomeRows.map((row) => row.storageKey), [
      'time.presentInWhatIWasDoing',
      'time.didWhatIDelayed',
      'time.steppedAwayFromIdleTime',
      'time.restedAsNeeded',
      'time.beganWithIntention',
    ]);
    expect(
      homeTraceRowByKey('time.restedAsNeeded')?.label,
      'Rested from work as needed',
    );
    expect(
      timeHomeRows.map((row) => row.storageKey),
      isNot(contains('time.guardedPrayerWindow')),
    );
    expect(
      homeTraceRowByKey('time.guardedPrayerWindow')?.label,
      'Guarded a prayer window from waste',
    );
  });

  test('Physical Health is observational and not a fitness grade', () {
    expect(MonitorDomain.health.label, 'Physical Health & Energy');
    expect(
      MonitorDomain.health.focusQuestion,
      'Did I care for the body Allah entrusted to me?',
    );
    expect(MonitorDomain.health.id, 'health');
    expect(hidesHomeTraceFactors('health.sleepQuality'), isTrue);
    expect(
      monitorDomainForStorageKey('health.illnessCare'),
      MonitorDomain.health,
    );
  });

  test('Wealth & Stewardship is observational and not a money score', () {
    expect(MonitorDomain.wealth.label, 'Wealth & Stewardship');
    expect(
      MonitorDomain.wealth.focusQuestion,
      'Did my spending and earning please Allah?',
    );
    expect(MonitorDomain.wealth.id, 'wealth');
    expect(hidesHomeTraceFactors('wealth.gaveSadaqah'), isTrue);
    expect(
      monitorDomainForStorageKey('wealth.avoidedRiba'),
      MonitorDomain.wealth,
    );
    expect(wealthHomeRows.map((row) => row.storageKey), [
      'wealth.halalEarning',
      'wealth.avoidedRiba',
      'wealth.avoidedWaste',
    ]);
    expect(homeTraceRowByKey('wealth.gaveSadaqah')?.label, 'Gave sadaqah');
  });

  test('Ummah is observational and not a social grade', () {
    expect(MonitorDomain.ummah.label, 'Ummah');
    expect(
      MonitorDomain.ummah.focusQuestion,
      'Did I serve anyone beyond myself today?',
    );
    expect(MonitorDomain.ummah.id, 'ummah');
    expect(hidesHomeTraceFactors('ummah.masjidAttendance'), isTrue);
    expect(
      monitorDomainForStorageKey('ummah.prayedForUmmah'),
      MonitorDomain.ummah,
    );
    expect(ummahHomeRows.map((row) => row.storageKey), [
      'ummah.masjidAttendance',
      'ummah.dawahByCharacter',
      'ummah.supportedOppressed',
      'ummah.unityEfforts',
      'ummah.prayedForUmmah',
      'ummah.earthCare',
    ]);
    expect(
      ummahHomeRows.first.label,
      'Masjid class or gathering (not the fard)',
    );
    expect(
      homeTraceRowByKey('ummah.communityService')?.label,
      'Served beyond myself',
    );
  });

  test('Rights of Others is obligation-only and not a relationship score', () {
    expect(MonitorDomain.huquq.label, 'Rights of Others (Huquq al-Ibad)');
    expect(
      MonitorDomain.huquq.focusQuestion,
      'Did I fulfill, harm, or neglect anyone’s right over me?',
    );
    expect(MonitorDomain.huquq.id, 'huquq');
    expect(
      traceOutcomeLabel('huquq.parents', TernaryOutcome.positive),
      'I attended to a right I owe — Parents',
    );
    expect(
      traceOutcomeLabel('huquq.parents', TernaryOutcome.negative),
      'I neglected a right I owe — Parents',
    );
    expect(hidesHomeTraceFactors('huquq.spouse'), isTrue);
    expect(hidesHomeTraceFactors('huquq.sickVisit'), isTrue);
    expect(hidesHomeTraceFactors('family.parentsContact'), isFalse);
    expect(monitorDomainForStorageKey('huquq.parents'), MonitorDomain.huquq);
    expect(monitorDomainForStorageKey('huquq.siblings'), MonitorDomain.huquq);
    expect(
      monitorDomainForStorageKey('huquq.grandparents'),
      MonitorDomain.huquq,
    );
    expect(
      monitorDomainForStorageKey('huquq.otherRelatives'),
      MonitorDomain.huquq,
    );
  });

  test('trace keys map to monitor domains', () {
    expect(monitorDomainForStorageKey('akhlaq.patience'), MonitorDomain.akhlaq);
    expect(
      monitorDomainForStorageKey('fasting.weeklySunnah'),
      MonitorDomain.fasting,
    );
    expect(monitorDomainForStorageKey('hajj.preparation'), MonitorDomain.hajj);
    expect(monitorDomainForStorageKey('family.parentsContact'), isNull);
    expect(monitorDomainForStorageKey('unknown'), isNull);
  });

  test('Hajj is observational standing status and not a due-date engine', () {
    expect(MonitorDomain.hajj.label, 'Hajj');
    expect(MonitorDomain.hajj.id, 'hajj');
    expect(
      MonitorDomain.hajj.focusQuestion,
      'Have I named how Hajj stands with me — as I see it, not as the app decides?',
    );
    expect(hajjHomeRows.map((row) => row.storageKey), [kHajjPreparationKey]);
    expect(HajjStatus.unanswered.showsPreparation, isFalse);
    expect(HajjStatus.due.showsPreparation, isTrue);
    expect(HajjStatus.preparing.showsPreparation, isTrue);
    expect(HajjStatus.performed.showsPreparation, isFalse);
    expect(hidesHomeTraceFactors(kHajjPreparationKey), isTrue);
  });

  test('Huquq hardship care replaced the Family domain', () {
    expect(
      huquqHomeRows
          .where((row) => row.band == 'Care in hardship')
          .map((row) => row.storageKey),
      ['huquq.sickVisit', 'huquq.sickContact', 'huquq.supportUnderStress'],
    );
    expect(
      familyRetiredHomeRows.map((row) => row.storageKey),
      containsAll([
        'family.parentsContact',
        'family.sickVisit',
        'family.supportUnderStress',
      ]),
    );
    expect(homeTraceRowByKey('family.parentsContact')?.label, 'Parent Contact');
    expect(homeTraceRowByKey('huquq.sickVisit')?.label, 'Sick Visit');
    expect(bandsFor(huquqHomeRows).last, 'Care in hardship');
  });

  test('trace dropdown names the row so a band title cannot mislead', () {
    expect(
      traceOutcomeLabel('akhlaq.pausedBeforeReacting', TernaryOutcome.negative),
      'I did not notice this today — Paused before reacting',
    );
    for (final row in allHomeTraceRows) {
      final positive = traceOutcomeLabel(
        row.storageKey,
        TernaryOutcome.positive,
      );
      final negative = traceOutcomeLabel(
        row.storageKey,
        TernaryOutcome.negative,
      );
      final unanswered = traceOutcomeLabel(
        row.storageKey,
        TernaryOutcome.unanswered,
      );
      expect(positive, contains(row.label));
      expect(negative, contains(row.label));
      expect(unanswered, contains(row.label));
      expect(positive, isNot(equals(negative)));
    }
  });
}
