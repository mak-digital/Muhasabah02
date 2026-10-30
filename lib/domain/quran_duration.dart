/// Shared Qur’an duration steps. Colour twins live on [SalahActivityMark].
///
/// Missed and missed-then-made-up are not used: these rows are not fard.
abstract final class QuranDurationIds {
  static const over20 = 'over20';
  static const min15to20 = 'min15to20';
  static const min10to15 = 'min10to15';
  static const min5to10 = 'min5to10';
  static const min3to5 = 'min3to5';
  static const notNoticed = 'notEngaged';

  static const ordered = <String>[
    over20,
    min15to20,
    min10to15,
    min5to10,
    min3to5,
    notNoticed,
  ];

  static bool isDurationId(String id) => ordered.contains(id);
}
