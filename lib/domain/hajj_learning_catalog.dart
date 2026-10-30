/// Structured Hajj readiness-learning topics. Self-reported states only.
/// Citations are Qur’an or well-known authentic hadith already used in-app
/// or standard mushaf verses. Not a ruling and not a proficiency certificate.
class HajjLearningTopic {
  const HajjLearningTopic({
    required this.id,
    required this.title,
    required this.source,
    required this.note,
  });

  final String id;
  final String title;
  final String source;
  final String note;
}

const kHajjLearningCatalog = [
  HajjLearningTopic(
    id: 'learn.conditions',
    title: 'Conditions and significance of Hajj',
    source: 'Qur’an 3:97',
    note:
        'Learning only. The app does not calculate whether Hajj is obligatory.',
  ),
  HajjLearningTopic(
    id: 'learn.rites.sequence',
    title: 'Essential rites and their sequence',
    source: 'Qur’an 2:197',
    note: 'A reminder of well-known months. Not a ritual engine or fatwa.',
  ),
  HajjLearningTopic(
    id: 'learn.ihram',
    title: 'Ihram and restrictions',
    source: 'Qur’an 2:196',
    note: 'Complete the Hajj and the Umrah for Allah. Umrah is not this standing.',
  ),
  HajjLearningTopic(
    id: 'learn.tawaf.sai',
    title: 'Tawaf and Sa‘i',
    source: 'Qur’an 2:158',
    note:
        'Safa and Marwah are among the rites of Allah. Not a proficiency mark.',
  ),
  HajjLearningTopic(
    id: 'learn.arafat',
    title: 'Arafat, Muzdalifah and Mina',
    source: 'Qur’an 2:198',
    note: 'Remember Allah as He taught you. Not a schedule of official days.',
  ),
  HajjLearningTopic(
    id: 'learn.mistakes',
    title: 'Common practical mistakes',
    source: 'Qur’an 2:197',
    note: 'A prompt to notice care in the months of Hajj. Not a list of sins scored by the app.',
  ),
  HajjLearningTopic(
    id: 'learn.safety',
    title: 'Safety, health and travel preparation',
    source: 'Qur’an 3:97',
    note: 'Ability is yours to name. The app does not set a medical or visa rule.',
  ),
  HajjLearningTopic(
    id: 'learn.dua',
    title: 'Du‘a, remembrance and spiritual preparation',
    source: 'Ṣaḥīḥ al-Bukhārī 1521',
    note: 'Performed is a record, not a trophy. Unanswered is not missed Hajj.',
  ),
];
