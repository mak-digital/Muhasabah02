import 'package:flutter_test/flutter_test.dart';
import 'package:muhasabah02/data/app_prefs.dart';
import 'package:muhasabah02/domain/custom_selection_set.dart';
import 'package:muhasabah02/domain/monitor_domain.dart';
import 'package:muhasabah02/domain/personal_mix.dart';

void main() {
  test(
    'missing and malformed saved sets fall back without using domain defaults',
    () {
      expect(decodeCustomSelectionSets(null).slots, hasLength(3));
      expect(decodeCustomSelectionSets('').slots.map((s) => s.id), [1, 2, 3]);
      expect(decodeCustomSelectionSets('{').activeSlotId, isNull);
      expect(
        decodeCustomSelectionSets('[]').slots.every((s) => s.domains.isEmpty),
        isTrue,
      );
      final recovered = decodeCustomSelectionSets(
        '{"v":1,"activeSlotId":9,"slots":[]}',
      );
      expect(recovered.activeSlotId, isNull);
      expect(recovered.slotById(1).domains, isEmpty);
    },
  );

  test(
    'empty slot domains stay empty and do not restore the six-domain preset',
    () {
      final encoded = encodeCustomSelectionSets(
        CustomSelectionSetsRecord.empty().copyWithActive(2),
      );
      final decoded = decodeCustomSelectionSets(encoded);
      expect(decoded.activeSlotId, 2);
      expect(decoded.slotById(1).domains, isEmpty);
      expect(decoded.slotById(1).domains, isNot(kBasicDhikrVisibleDomains));
      expect(encodeVisibleDomains(decoded.slotById(1).domains), '');
    },
  );

  test('saved custom slots keep the previous named preset as stored', () {
    final encoded = encodeCustomSelectionSets(
      CustomSelectionSetsRecord(
        slots: [
          const CustomSelectionSet(
            id: 1,
            name: 'Old look',
            domains: kLegacyBasicAkhlaqVisibleDomains,
          ),
          const CustomSelectionSet(id: 2),
          const CustomSelectionSet(id: 3),
        ],
      ),
    );
    expect(encoded, contains('akhlaq'));
    final decoded = decodeCustomSelectionSets(encoded);
    expect(decoded.slotById(1).domains, kLegacyBasicAkhlaqVisibleDomains);
    expect(decoded.slotById(1).domains.contains(MonitorDomain.akhlaq), isTrue);
    expect(decoded.slotById(1).domains.contains(MonitorDomain.dhikr), isFalse);
  });

  test('three slots store independent overlapping filters and names', () {
    final fajr = mixForKind(PersonalMixKind.custom, customKeys: {'salah.fajr'});
    final asr = mixForKind(
      PersonalMixKind.custom,
      customKeys: {'salah.asr', 'quran.reading'},
    );
    final record = CustomSelectionSetsRecord(
      activeSlotId: 1,
      slots: [
        const CustomSelectionSet(
          id: 1,
          name: 'Dawn',
          domains: {MonitorDomain.salah},
        ).copyWith(mix: fajr),
        CustomSelectionSet(
          id: 2,
          name: 'Dawn',
          domains: {MonitorDomain.salah, MonitorDomain.quran},
          mix: fajr,
        ),
        CustomSelectionSet(
          id: 3,
          domains: {MonitorDomain.salah, MonitorDomain.quran},
          mix: asr,
        ),
      ],
    );
    final roundTrip = decodeCustomSelectionSets(
      encodeCustomSelectionSets(record),
    );
    expect(roundTrip.slotById(1).domains, {MonitorDomain.salah});
    expect(roundTrip.slotById(2).domains, {
      MonitorDomain.salah,
      MonitorDomain.quran,
    });
    expect(roundTrip.slotById(1).mix.keys, {'salah.fajr'});
    expect(roundTrip.slotById(2).mix.keys, {'salah.fajr'});
    expect(roundTrip.slotById(3).mix.keys, {'salah.asr', 'quran.reading'});
    expect(roundTrip.slotById(1).displayTitle, 'Custom #1 (Dawn)');
    expect(roundTrip.slotById(3).displayTitle, 'Custom #3');
  });

  test('sanitizeCustomSlotName trims, strips newlines and caps length', () {
    expect(sanitizeCustomSlotName('  Ramadan\nweek  '), 'Ramadan week');
    expect(sanitizeCustomSlotName('a' * 40), 'a' * 32);
    expect(sanitizeCustomSlotName('\n\n'), '');
  });

  test(
    'workingModifiedFromActive ignores unsourced and matching working sets',
    () {
      final slot = CustomSelectionSet(
        id: 1,
        domains: {MonitorDomain.salah},
        mix: mixForKind(PersonalMixKind.custom, customKeys: {'salah.fajr'}),
      );
      final record = CustomSelectionSetsRecord(
        activeSlotId: 1,
        slots: [
          slot,
          const CustomSelectionSet(id: 2),
          const CustomSelectionSet(id: 3),
        ],
      );
      expect(
        workingModifiedFromActive(
          record: record,
          workingDomains: slot.domains,
          workingMix: slot.mix,
        ),
        isFalse,
      );
      expect(
        workingModifiedFromActive(
          record: record,
          workingDomains: {MonitorDomain.quran},
          workingMix: slot.mix,
        ),
        isTrue,
      );
      expect(
        workingModifiedFromActive(
          record: record.copyWithActive(null),
          workingDomains: {MonitorDomain.quran},
          workingMix: slot.mix,
        ),
        isFalse,
      );
    },
  );

  test(
    'custom empty mix still lists visible Home weeks via existing fallback',
    () {
      final mix = mixForKind(PersonalMixKind.custom, customKeys: {});
      expect(homeMixDomains({MonitorDomain.salah}, mix), [MonitorDomain.salah]);
      expect(resolvePersonalMixKeys(mix, {MonitorDomain.salah}), isEmpty);
    },
  );

  test('identical snapshots may occupy all three slots', () {
    final mix = mixForKind(PersonalMixKind.custom, customKeys: {'salah.fajr'});
    final domains = {MonitorDomain.salah};
    final encoded = encodeCustomSelectionSets(
      CustomSelectionSetsRecord(
        slots: [
          CustomSelectionSet(id: 1, domains: domains, mix: mix),
          CustomSelectionSet(id: 2, domains: domains, mix: mix),
          CustomSelectionSet(id: 3, domains: domains, mix: mix),
        ],
      ),
    );
    final decoded = decodeCustomSelectionSets(encoded);
    expect(decoded.slotById(1).domains, domains);
    expect(decoded.slotById(2).domains, domains);
    expect(decoded.slotById(3).domains, domains);
    expect(decoded.slotById(1).mix.keys, {'salah.fajr'});
    expect(decoded.slotById(2).mix.keys, {'salah.fajr'});
    expect(decoded.slotById(3).mix.keys, {'salah.fajr'});
  });

  test(
    'activating an empty slot does not restore the six-domain preset',
    () async {
      final prefs = MemoryAppPrefs(
        visibleDomains: kBasicDhikrVisibleDomains,
        personalMix: mixForKind(PersonalMixKind.firstLook),
      );
      await prefs.activateCustomSlot(2);
      expect(prefs.visibleDomains, isEmpty);
      expect(encodeVisibleDomains(prefs.visibleDomains), '');
      expect(
        decodeVisibleDomains(encodeVisibleDomains(prefs.visibleDomains)),
        isEmpty,
      );
      expect(prefs.personalMix, PersonalMix.sameAsDomains);
      expect(prefs.customSelectionSets.activeSlotId, 2);
      expect(prefs.visibleDomains, isNot(kBasicDhikrVisibleDomains));
    },
  );

  test(
    'clearing working selection stays empty after encode round-trip',
    () async {
      final prefs = MemoryAppPrefs(
        visibleDomains: kBasicDhikrVisibleDomains,
        personalMix: mixForKind(PersonalMixKind.firstLook),
        customSelectionSets: CustomSelectionSetsRecord(
          activeSlotId: 1,
          slots: [
            const CustomSelectionSet(id: 1, name: 'Kept'),
            const CustomSelectionSet(id: 2),
            const CustomSelectionSet(id: 3),
          ],
        ),
      );
      await prefs.clearWorkingSelection();
      expect(
        decodeVisibleDomains(encodeVisibleDomains(prefs.visibleDomains)),
        isEmpty,
      );
      expect(
        decodePersonalMix(encodePersonalMix(prefs.personalMix)).kind,
        PersonalMixKind.sameAsDomains,
      );
      expect(prefs.customSelectionSets.activeSlotId, isNull);
      expect(prefs.customSelectionSets.slotById(1).name, 'Kept');
    },
  );

  test(
    'clearing a custom slot keeps the name and empties saved domains',
    () async {
      final prefs = MemoryAppPrefs(
        visibleDomains: {MonitorDomain.salah},
        customSelectionSets: CustomSelectionSetsRecord(
          activeSlotId: 1,
          slots: [
            const CustomSelectionSet(
              id: 1,
              name: 'Dawn',
              domains: {MonitorDomain.salah},
            ),
            const CustomSelectionSet(
              id: 2,
              name: 'Kept',
              domains: {MonitorDomain.quran},
            ),
            const CustomSelectionSet(id: 3),
          ],
        ),
      );
      await prefs.clearCustomSlot(2);
      expect(prefs.customSelectionSets.slotById(2).name, 'Kept');
      expect(prefs.customSelectionSets.slotById(2).domains, isEmpty);
      expect(prefs.visibleDomains, {MonitorDomain.salah});
      expect(prefs.customSelectionSets.activeSlotId, 1);
      await prefs.clearCustomSlot(1);
      expect(prefs.customSelectionSets.slotById(1).name, 'Dawn');
      expect(prefs.customSelectionSets.slotById(1).domains, isEmpty);
      expect(prefs.visibleDomains, isEmpty);
      expect(prefs.customSelectionSets.activeSlotId, 1);
    },
  );

  test('failed working-selection write restores the previous values', () async {
    final prefs = MemoryAppPrefs(
      visibleDomains: kBasicDhikrVisibleDomains,
      personalMix: mixForKind(PersonalMixKind.firstLook),
    )..throwOnApplyWorkingSelection = true;
    final before = prefs.mutationCount;
    await expectLater(prefs.activateCustomSlot(3), throwsStateError);
    expect(prefs.visibleDomains, kBasicDhikrVisibleDomains);
    expect(prefs.personalMix.kind, PersonalMixKind.firstLook);
    expect(prefs.customSelectionSets.activeSlotId, isNull);
    expect(prefs.mutationCount, before);
  });
}
