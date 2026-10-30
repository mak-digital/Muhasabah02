import 'monitor_domain.dart';

class ReflectionQuote {
  const ReflectionQuote({
    required this.domain,
    required this.text,
    required this.source,
    required this.sourceDetail,
  });

  final MonitorDomain domain;
  final String text;
  final String source;
  final String sourceDetail;

  bool get isQuran => source.startsWith('Qur’an');
}

/// Qur’an verses and well-known authentic hadith for Home reflection.
/// Shown by calendar rotation or by the person’s next/previous step — not from records.
final List<ReflectionQuote> kReflectionQuotes = _buildReflectionQuotes();

ReflectionQuote _verse(
  MonitorDomain domain,
  String text,
  String source,
  String surah,
) {
  return ReflectionQuote(
    domain: domain,
    text: text,
    source: source,
    sourceDetail: surah,
  );
}

ReflectionQuote _hadith(
  MonitorDomain domain,
  String text,
  String source,
  String recorded,
) {
  return ReflectionQuote(
    domain: domain,
    text: text,
    source: source,
    sourceDetail: recorded,
  );
}

List<ReflectionQuote> _buildReflectionQuotes() {
  const s = MonitorDomain.salah;
  const q = MonitorDomain.quran;
  const h = MonitorDomain.hadith;
  const d = MonitorDomain.dhikr;
  const a = MonitorDomain.akhlaq;
  const u = MonitorDomain.huquq;
  const k = MonitorDomain.knowledge;
  const t = MonitorDomain.time;
  const p = MonitorDomain.health;
  const w = MonitorDomain.wealth;
  const m = MonitorDomain.ummah;
  const f = MonitorDomain.fasting;
  const j = MonitorDomain.hajj;
  const c = MonitorDomain.charity;

  return [
    // --- Salah ---
    _verse(
      s,
      'Establish prayer, give zakah, and bow with those who bow.',
      'Qur’an 2:43',
      'Sūrat al-Baqarah, verse 43.',
    ),
    _verse(
      s,
      'Guard the prayers, especially the middle prayer, and stand before Allah, devoutly obedient.',
      'Qur’an 2:238',
      'Sūrat al-Baqarah, verse 238.',
    ),
    _verse(
      s,
      'Indeed, prayer is a timed obligation upon the believers.',
      'Qur’an 4:103',
      'Sūrat al-Nisā’, verse 103.',
    ),
    _verse(
      s,
      'Establish prayer at the two ends of the day and in the first hours of the night. Good deeds erase bad deeds.',
      'Qur’an 11:114',
      'Sūrat Hūd, verse 114.',
    ),
    _verse(
      s,
      'Establish prayer at the decline of the sun until the darkness of the night, and the recitation of Fajr.',
      'Qur’an 17:78',
      'Sūrat al-Isrā’, verse 78.',
    ),
    _verse(
      s,
      'Establish prayer for My remembrance.',
      'Qur’an 20:14',
      'Sūrat Ṭā Hā, verse 14.',
    ),
    _verse(
      s,
      'Successful are the believers, those who are humble in their prayer.',
      'Qur’an 23:1–2',
      'Sūrat al-Mu’minūn, verses 1–2.',
    ),
    _verse(
      s,
      'Establish prayer. Indeed, prayer prohibits immorality and wrongdoing.',
      'Qur’an 29:45',
      'Sūrat al-ʿAnkabūt, verse 45. Citation only — not a score.',
    ),
    _hadith(
      s,
      'The Prophet ﷺ was asked which deed is most beloved to Allah. He said: “Prayer at its time.”',
      'Ṣaḥīḥ al-Bukhārī 527; Ṣaḥīḥ Muslim 85',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      s,
      'The Messenger of Allah ﷺ said: “The first of a servant’s deeds to be accounted for on the Day of Resurrection will be the prayer.”',
      'Sunan Abī Dāwūd 864; Jāmiʿ al-Tirmidhī 413',
      'Recorded in Sunan Abī Dāwūd and Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      s,
      'The Messenger of Allah ﷺ said: “Pray as you have seen me pray.”',
      'Ṣaḥīḥ al-Bukhārī 631',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      s,
      'The Messenger of Allah ﷺ said: “The five prayers, and Friday to Friday, are expiation for what is between them, so long as major sins are avoided.”',
      'Ṣaḥīḥ Muslim 233',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      s,
      'The Prophet ﷺ said: “If there was a river at the door of one of you in which he bathed five times a day, would any dirt remain? That is the likeness of the five prayers.”',
      'Ṣaḥīḥ al-Bukhārī 528; Ṣaḥīḥ Muslim 667',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      s,
      'The Messenger of Allah ﷺ said: “The closest that a servant is to his Lord is while he is prostrating, so make much dua then.”',
      'Ṣaḥīḥ Muslim 482',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      s,
      'The Messenger of Allah ﷺ said: “Prayer in congregation is twenty-seven times better than prayer offered alone.”',
      'Ṣaḥīḥ al-Bukhārī 645; Ṣaḥīḥ Muslim 650',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      s,
      'The Prophet ﷺ said: “Between a man and shirk and kufr is abandoning the prayer.”',
      'Ṣaḥīḥ Muslim 82',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      s,
      'The Messenger of Allah ﷺ said: “The two rak‘ahs of Fajr are better than this world and all that is in it.”',
      'Ṣaḥīḥ Muslim 725',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      s,
      'The Messenger of Allah ﷺ said: “The covenant between us and them is the prayer; whoever leaves it has committed disbelief.”',
      'Jāmiʿ al-Tirmidhī 2621; Sunan al-Nasā’ī 463',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan al-Nasā’ī.',
    ),

    // --- Qur’an ---
    _verse(
      q,
      'This is the Book about which there is no doubt, a guidance for those mindful of Allah.',
      'Qur’an 2:2',
      'Sūrat al-Baqarah, verse 2.',
    ),
    _verse(
      q,
      'Those to whom We have given the Book recite it as it should be recited. They are the ones who believe in it.',
      'Qur’an 2:121',
      'Sūrat al-Baqarah, verse 121.',
    ),
    _verse(
      q,
      'Indeed, this Qur’an guides to that which is most upright.',
      'Qur’an 17:9',
      'Sūrat al-Isrā’, verse 9.',
    ),
    _verse(
      q,
      'A blessed Book We have revealed to you, that they might reflect upon its verses.',
      'Qur’an 38:29',
      'Sūrat Ṣād, verse 29.',
    ),
    _verse(
      q,
      'Do they not reflect upon the Qur’an, or are there locks upon their hearts?',
      'Qur’an 47:24',
      'Sūrat Muḥammad, verse 24.',
    ),
    _verse(
      q,
      'We have certainly made the Qur’an easy for remembrance, so is there any who will remember?',
      'Qur’an 54:17',
      'Sūrat al-Qamar, verse 17.',
    ),
    _verse(
      q,
      'Recite the Qur’an with measured recitation.',
      'Qur’an 73:4',
      'Sūrat al-Muzzammil, verse 4.',
    ),
    _verse(
      q,
      'The Messenger will say, “My Lord, my people took this Qur’an as a thing abandoned.”',
      'Qur’an 25:30',
      'Sūrat al-Furqān, verse 30.',
    ),
    _hadith(
      q,
      'The Messenger of Allah ﷺ said: “The best of you are those who learn the Qur’an and teach it.”',
      'Ṣaḥīḥ al-Bukhārī 5027',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      q,
      'The Messenger of Allah ﷺ said: “Recite the Qur’an, for it will come on the Day of Resurrection as an intercessor for its companions.”',
      'Ṣaḥīḥ Muslim 804',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      q,
      'The Prophet ﷺ said: “The example of a believer who recites the Qur’an is that of a citron: its scent is pleasant and its taste is pleasant.”',
      'Ṣaḥīḥ al-Bukhārī 5020; Ṣaḥīḥ Muslim 797',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      q,
      'The Messenger of Allah ﷺ said: “Whoever recites a letter from the Book of Allah will have a good deed for it, and a good deed is multiplied tenfold.”',
      'Jāmiʿ al-Tirmidhī 2910',
      'Recorded in Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      q,
      'The Messenger of Allah ﷺ said: “It will be said to the companion of the Qur’an: Recite and ascend, and recite as you used to recite in the world.”',
      'Sunan Abī Dāwūd 1464; Jāmiʿ al-Tirmidhī 2914',
      'Recorded in Sunan Abī Dāwūd and Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      q,
      'The Messenger of Allah ﷺ said: “The one who is skilled in the Qur’an is with the noble, righteous scribes.”',
      'Ṣaḥīḥ al-Bukhārī 4937; Ṣaḥīḥ Muslim 798',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      q,
      'The Messenger of Allah ﷺ said: “Do not make your houses graveyards. Shaytan flees from a house in which Sūrat al-Baqarah is recited.”',
      'Ṣaḥīḥ Muslim 780',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      q,
      'The Prophet ﷺ said: “Read the Qur’an as long as your hearts agree upon it. If you differ, then leave it.”',
      'Ṣaḥīḥ al-Bukhārī 5060; Ṣaḥīḥ Muslim 2667',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      q,
      'The Messenger of Allah ﷺ said: “Envy is not justified except in two: a man whom Allah has given the Qur’an, and he recites it by night and by day.”',
      'Ṣaḥīḥ al-Bukhārī 5025; Ṣaḥīḥ Muslim 815',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      q,
      'The Messenger of Allah ﷺ said: “The Qur’an is a proof for you or against you.”',
      'Ṣaḥīḥ Muslim 223',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),

    // --- Hadith & Living Sunnah ---
    _verse(
      h,
      'Say: If you love Allah, then follow me; Allah will love you and forgive you your sins.',
      'Qur’an 3:31',
      'Sūrat Āl ʿImrān, verse 31.',
    ),
    _verse(
      h,
      'O you who believe, obey Allah and obey the Messenger and those in authority among you.',
      'Qur’an 4:59',
      'Sūrat al-Nisā’, verse 59.',
    ),
    _verse(
      h,
      'Whoever obeys the Messenger has obeyed Allah.',
      'Qur’an 4:80',
      'Sūrat al-Nisā’, verse 80.',
    ),
    _verse(
      h,
      'There has certainly been for you in the Messenger of Allah an excellent example.',
      'Qur’an 33:21',
      'Sūrat al-Aḥzāb, verse 21.',
    ),
    _verse(
      h,
      'Whatever the Messenger gives you, take it; and whatever he forbids you, refrain from it.',
      'Qur’an 59:7',
      'Sūrat al-Ḥashr, verse 7.',
    ),
    _verse(
      h,
      'Those who follow the Messenger, the unlettered prophet, whom they find written with them in the Torah and the Gospel.',
      'Qur’an 7:157',
      'Sūrat al-Aʿrāf, verse 157.',
    ),
    _verse(
      h,
      'Obey Allah and the Messenger that you may receive mercy.',
      'Qur’an 3:132',
      'Sūrat Āl ʿImrān, verse 132.',
    ),
    _verse(
      h,
      'Say: Obey Allah and obey the Messenger. If you turn away, then upon him is only what he has been charged with.',
      'Qur’an 24:54',
      'Sūrat al-Nūr, verse 54.',
    ),
    _hadith(
      h,
      'The Messenger of Allah ﷺ said: “The most beloved of deeds to Allah are those that are most consistent, even if they are small.”',
      'Ṣaḥīḥ al-Bukhārī 6464; Ṣaḥīḥ Muslim 783',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim. Shown by calendar rotation, not by your records.',
    ),
    _hadith(
      h,
      'The Prophet ﷺ said: “None of you believes until he loves for his brother what he loves for himself.”',
      'Ṣaḥīḥ al-Bukhārī 13; Ṣaḥīḥ Muslim 45',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      h,
      'The Prophet ﷺ said: “Whoever turns away from my Sunnah is not of me.”',
      'Ṣaḥīḥ al-Bukhārī 5063; Ṣaḥīḥ Muslim 1401',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      h,
      'The Prophet ﷺ said: “None of you truly believes until I am more beloved to him than his father, his child, and all people.”',
      'Ṣaḥīḥ al-Bukhārī 15; Ṣaḥīḥ Muslim 44',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      h,
      'The Messenger of Allah ﷺ said: “I have left among you that which, if you hold to it, you will never go astray: the Book of Allah.”',
      'Ṣaḥīḥ Muslim 1218',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      h,
      'The Messenger of Allah ﷺ said: “Whatever I have commanded you, do of it as much as you can.”',
      'Ṣaḥīḥ al-Bukhārī 7288; Ṣaḥīḥ Muslim 1337',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      h,
      'The Messenger of Allah ﷺ said: “The most truthful speech is the Book of Allah, and the best guidance is the guidance of Muhammad.”',
      'Ṣaḥīḥ Muslim 867',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      h,
      'The Messenger of Allah ﷺ said: “Whoever introduces into this matter of ours that which is not from it, it is rejected.”',
      'Ṣaḥīḥ al-Bukhārī 2697; Ṣaḥīḥ Muslim 1718',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      h,
      'The Messenger of Allah ﷺ said: “All of my ummah will enter Paradise except those who refuse.” They said: Who refuses? He said: “Whoever obeys me enters Paradise, and whoever disobeys me has refused.”',
      'Ṣaḥīḥ al-Bukhārī 7280',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      h,
      'The Messenger of Allah ﷺ said: “Convey from me, even if it is one verse.”',
      'Ṣaḥīḥ al-Bukhārī 3461',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),

    // --- Dhikr ---
    _verse(
      d,
      'So remember Me; I will remember you. And be grateful to Me, and do not deny Me.',
      'Qur’an 2:152',
      'Sūrat al-Baqarah, verse 152.',
    ),
    _verse(
      d,
      'Unquestionably, by the remembrance of Allah hearts find rest.',
      'Qur’an 13:28',
      'Sūrat al-Raʿd, verse 28.',
    ),
    _verse(
      d,
      'O you who believe, remember Allah with much remembrance.',
      'Qur’an 33:41',
      'Sūrat al-Aḥzāb, verse 41.',
    ),
    _verse(
      d,
      'Recite what has been revealed to you of the Book, and establish prayer. Indeed, prayer prohibits immorality and wrongdoing, and the remembrance of Allah is greater.',
      'Qur’an 29:45',
      'Sūrat al-ʿAnkabūt, verse 45.',
    ),
    _verse(
      d,
      'He who remembers the name of his Lord and prays.',
      'Qur’an 87:15',
      'Sūrat al-Aʿlā, verse 15.',
    ),
    _verse(
      d,
      'Remember the name of your Lord morning and evening.',
      'Qur’an 76:25',
      'Sūrat al-Insān, verse 25.',
    ),
    _verse(
      d,
      'Those who remember Allah while standing, sitting, and on their sides, and reflect on the creation of the heavens and the earth.',
      'Qur’an 3:191',
      'Sūrat Āl ʿImrān, verse 191.',
    ),
    _verse(
      d,
      'When you have completed the prayer, remember Allah standing, sitting, and on your sides.',
      'Qur’an 4:103',
      'Sūrat al-Nisā’, verse 103.',
    ),
    _hadith(
      d,
      'The Prophet ﷺ said: “The example of the one who remembers his Lord and the one who does not is like the living and the dead.”',
      'Ṣaḥīḥ al-Bukhārī 6407; Ṣaḥīḥ Muslim 779',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      d,
      'The Messenger of Allah ﷺ said: “Shall I not tell you of the best of your deeds, the purest with your Sovereign, and better for you than spending gold and silver? The remembrance of Allah.”',
      'Jāmiʿ al-Tirmidhī 3377; Sunan Ibn Mājah 3790',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan Ibn Mājah.',
    ),
    _hadith(
      d,
      'The Messenger of Allah ﷺ said: “Allah has angels who roam seeking the gatherings of remembrance.”',
      'Ṣaḥīḥ Muslim 2689',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      d,
      'The Messenger of Allah ﷺ said: “Two words are light on the tongue, heavy on the Scale, and beloved to the Most Merciful: Subḥān Allāhi wa biḥamdih, Subḥān Allāhil-ʿAẓīm.”',
      'Ṣaḥīḥ al-Bukhārī 6406; Ṣaḥīḥ Muslim 2694',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      d,
      'The Messenger of Allah ﷺ said: “Whoever says ‘Lā ilāha illallāh, waḥdahu lā sharīka lah…’ one hundred times a day will have the reward of freeing ten slaves.”',
      'Ṣaḥīḥ al-Bukhārī 6403; Ṣaḥīḥ Muslim 2691',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      d,
      'The Messenger of Allah ﷺ said: “The most beloved words to Allah are four: Subḥān Allāh, al-ḥamdu lillāh, lā ilāha illallāh, and Allāhu akbar.”',
      'Ṣaḥīḥ Muslim 2137',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      d,
      'The Messenger of Allah ﷺ said: “Dua is worship.”',
      'Jāmiʿ al-Tirmidhī 2969; Sunan Abī Dāwūd 1479',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan Abī Dāwūd.',
    ),
    _hadith(
      d,
      'The Messenger of Allah ﷺ said: “Keep your tongue moist with the remembrance of Allah.”',
      'Jāmiʿ al-Tirmidhī 3375',
      'Recorded in Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      d,
      'The Prophet ﷺ said: “Is any of you unable to recite a third of the Qur’an in a night? Qul huwa Allāhu aḥad is a third of the Qur’an.”',
      'Ṣaḥīḥ al-Bukhārī 5015; Ṣaḥīḥ Muslim 811',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      d,
      'The Messenger of Allah ﷺ said: “When one of you prays, let him begin with praise of Allah, then send salah upon the Prophet, then ask for whatever he wishes.”',
      'Sunan Abī Dāwūd 1481; Jāmiʿ al-Tirmidhī 3477',
      'Recorded in Sunan Abī Dāwūd and Jāmiʿ al-Tirmidhī.',
    ),

    // --- Akhlaq ---
    _verse(
      a,
      'O you who believe, let not a people ridicule another people; perhaps they are better than them.',
      'Qur’an 49:11',
      'Sūrat al-Ḥujurāt, verse 11.',
    ),
    _verse(
      a,
      'Avoid much assumption. Indeed, some assumption is sin. And do not spy, and do not backbite one another.',
      'Qur’an 49:12',
      'Sūrat al-Ḥujurāt, verse 12.',
    ),
    _verse(
      a,
      'Do not turn your cheek from people in contempt, and do not walk upon the earth in insolence.',
      'Qur’an 31:18',
      'Sūrat Luqmān, verse 18.',
    ),
    _verse(
      a,
      'The servants of the Most Merciful are those who walk upon the earth in humility, and when the ignorant address them, they say words of peace.',
      'Qur’an 25:63',
      'Sūrat al-Furqān, verse 63.',
    ),
    _verse(
      a,
      'Allah commands justice, excellence, and giving to relatives, and forbids immorality, bad conduct, and oppression.',
      'Qur’an 16:90',
      'Sūrat al-Naḥl, verse 90.',
    ),
    _verse(
      a,
      'Repel evil with that which is better. Then the one between whom and you there was enmity will become as though he was a devoted friend.',
      'Qur’an 41:34',
      'Sūrat Fuṣṣilat, verse 34.',
    ),
    _verse(
      a,
      'Those who spend in ease and in hardship, who restrain anger, and who pardon people — Allah loves those who do good.',
      'Qur’an 3:134',
      'Sūrat Āl ʿImrān, verse 134.',
    ),
    _verse(
      a,
      'And indeed, you are of a great moral character.',
      'Qur’an 68:4',
      'Sūrat al-Qalam, verse 4.',
    ),
    _hadith(
      a,
      'The Messenger of Allah ﷺ said: “I was sent only to perfect good character.”',
      'Muwaṭṭaʾ Mālik 1614; Musnad Aḥmad 8952',
      'Recorded in the Muwaṭṭaʾ of Mālik and Musnad Aḥmad.',
    ),
    _hadith(
      a,
      'The Messenger of Allah ﷺ said: “The most complete of the believers in faith are those with the best character.”',
      'Jāmiʿ al-Tirmidhī 1162; Sunan Abī Dāwūd 4682',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan Abī Dāwūd.',
    ),
    _hadith(
      a,
      'The Messenger of Allah ﷺ said: “The Muslim is the one from whose tongue and hand the Muslims are safe.”',
      'Ṣaḥīḥ al-Bukhārī 10; Ṣaḥīḥ Muslim 40',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      a,
      'The Messenger of Allah ﷺ said: “Whoever believes in Allah and the Last Day, let him speak good or remain silent.”',
      'Ṣaḥīḥ al-Bukhārī 6018; Ṣaḥīḥ Muslim 47',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      a,
      'The Prophet ﷺ said: “Modesty is part of faith.”',
      'Ṣaḥīḥ al-Bukhārī 24; Ṣaḥīḥ Muslim 36',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      a,
      'The Messenger of Allah ﷺ said: “The strong is not the one who overcomes people by strength, but the one who controls himself while angry.”',
      'Ṣaḥīḥ al-Bukhārī 6114; Ṣaḥīḥ Muslim 2609',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      a,
      'A man said to the Prophet ﷺ: Advise me. He said: “Do not get angry.” He repeated it several times: “Do not get angry.”',
      'Ṣaḥīḥ al-Bukhārī 6116',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      a,
      'The Messenger of Allah ﷺ said: “He is not a liar who seeks to reconcile between people and says something good, or conveys something good.”',
      'Ṣaḥīḥ al-Bukhārī 2692',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      a,
      'The Messenger of Allah ﷺ said: “Greet with peace those whom you know and those whom you do not know.”',
      'Ṣaḥīḥ al-Bukhārī 6236; Ṣaḥīḥ Muslim 39',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      a,
      'The Messenger of Allah ﷺ said: “Fear Allah wherever you are, follow a bad deed with a good deed to erase it, and treat people with good character.”',
      'Jāmiʿ al-Tirmidhī 1987',
      'Recorded in Jāmiʿ al-Tirmidhī.',
    ),

    // --- Huquq ---
    _verse(
      u,
      'Worship Allah and associate nothing with Him, and be good to parents, relatives, orphans, the needy, the neighbor, the companion, the traveler, and those whom your right hands possess.',
      'Qur’an 4:36',
      'Sūrat al-Nisā’, verse 36.',
    ),
    _verse(
      u,
      'Lower to them the wing of humility out of mercy and say, “My Lord, have mercy upon them as they brought me up when I was small.”',
      'Qur’an 17:24',
      'Sūrat al-Isrā’, verse 24.',
    ),
    _verse(
      u,
      'Your Lord has decreed that you worship none but Him, and that you be good to parents.',
      'Qur’an 17:23',
      'Sūrat al-Isrā’, verse 23.',
    ),
    _verse(
      u,
      'Be good to parents, relatives, orphans, and the needy, and speak to people good words.',
      'Qur’an 2:83',
      'Sūrat al-Baqarah, verse 83.',
    ),
    _verse(
      u,
      'Give the relative his right, and the needy, and the traveler, and do not spend wastefully.',
      'Qur’an 17:26',
      'Sūrat al-Isrā’, verse 26.',
    ),
    _verse(
      u,
      'O you who believe, be persistently standing firm in justice, witnesses for Allah, even if it be against yourselves or parents and relatives.',
      'Qur’an 4:135',
      'Sūrat al-Nisā’, verse 135.',
    ),
    _verse(
      u,
      'O mankind, We created you from a male and a female and made you peoples and tribes that you may know one another.',
      'Qur’an 49:13',
      'Sūrat al-Ḥujurāt, verse 13.',
    ),
    _verse(
      u,
      'Righteousness is not that you turn your faces toward the east or the west, but that one believes… and gives wealth, in spite of love for it, to relatives, orphans, the needy, the traveler, those who ask, and for freeing slaves.',
      'Qur’an 2:177',
      'Sūrat al-Baqarah, verse 177.',
    ),
    _hadith(
      u,
      'The Messenger of Allah ﷺ said: “Jibril kept advising me about the neighbor until I thought he would inherit from him.”',
      'Ṣaḥīḥ al-Bukhārī 6014; Ṣaḥīḥ Muslim 2624',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      u,
      'The Prophet ﷺ said: “By Allah, he does not believe — whose neighbor is not safe from his harm.”',
      'Ṣaḥīḥ al-Bukhārī 6016; Ṣaḥīḥ Muslim 46',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      u,
      'The Prophet ﷺ said: “Shall I not tell you of the greatest of the major sins? Associating partners with Allah, and undutifulness to parents.”',
      'Ṣaḥīḥ al-Bukhārī 5976; Ṣaḥīḥ Muslim 87',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      u,
      'A man asked: Who is most deserving of my good company? The Prophet ﷺ said: “Your mother.” He said: Then who? “Your mother.” Then who? “Your mother.” Then who? “Your father.”',
      'Ṣaḥīḥ al-Bukhārī 5971; Ṣaḥīḥ Muslim 2548',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      u,
      'The Messenger of Allah ﷺ said: “The one who severs the ties of kinship will not enter Paradise.”',
      'Ṣaḥīḥ al-Bukhārī 5984; Ṣaḥīḥ Muslim 2556',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      u,
      'The Messenger of Allah ﷺ said that Allah said: “I will be against three on the Day of Resurrection… and a man who hired a worker, got his labor, and did not give him his wage.”',
      'Ṣaḥīḥ al-Bukhārī 2270',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      u,
      'The Messenger of Allah ﷺ said: “I and the one who cares for an orphan will be in Paradise like this,” and he held two fingers together.',
      'Ṣaḥīḥ al-Bukhārī 5304',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      u,
      'The Messenger of Allah ﷺ said: “A woman was punished because of a cat she confined until it died of hunger.”',
      'Ṣaḥīḥ al-Bukhārī 3318; Ṣaḥīḥ Muslim 2619',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      u,
      'The Messenger of Allah ﷺ said: “Help your brother, whether he is an oppressor or is oppressed.”',
      'Ṣaḥīḥ al-Bukhārī 2444; Ṣaḥīḥ Muslim 2584',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      u,
      'The Messenger of Allah ﷺ said: “The Muslim is the brother of the Muslim. He does not oppress him, nor does he abandon him.”',
      'Ṣaḥīḥ al-Bukhārī 2442; Ṣaḥīḥ Muslim 2564',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),

    // --- Knowledge ---
    _verse(
      k,
      'My Lord, increase me in knowledge.',
      'Qur’an 20:114',
      'Sūrat Ṭā Hā, verse 114.',
    ),
    _verse(
      k,
      'Say: Are those who know equal to those who do not know?',
      'Qur’an 39:9',
      'Sūrat al-Zumar, verse 9.',
    ),
    _verse(
      k,
      'Read in the name of your Lord who created. He taught man what he did not know.',
      'Qur’an 96:1–5',
      'Sūrat al-ʿAlaq, verses 1–5.',
    ),
    _verse(
      k,
      'Allah will raise those who have believed among you and those who were given knowledge, in degrees.',
      'Qur’an 58:11',
      'Sūrat al-Mujādilah, verse 11.',
    ),
    _verse(
      k,
      'Invite to the way of your Lord with wisdom and good instruction, and argue with them in a way that is best.',
      'Qur’an 16:125',
      'Sūrat al-Naḥl, verse 125.',
    ),
    _verse(
      k,
      'He gives wisdom to whom He wills, and whoever has been given wisdom has certainly been given much good.',
      'Qur’an 2:269',
      'Sūrat al-Baqarah, verse 269.',
    ),
    _verse(
      k,
      'Let a group from every division remain behind to gain understanding in the religion and warn their people when they return.',
      'Qur’an 9:122',
      'Sūrat al-Tawbah, verse 122.',
    ),
    _verse(
      k,
      'If a wrongdoer comes to you with information, investigate, lest you harm a people out of ignorance.',
      'Qur’an 49:6',
      'Sūrat al-Ḥujurāt, verse 6.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “Whoever travels a path in search of knowledge, Allah will make easy for him a path to Paradise.”',
      'Ṣaḥīḥ Muslim 2699',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “When Allah wishes good for a person, He grants him understanding of the religion.”',
      'Ṣaḥīḥ al-Bukhārī 71; Ṣaḥīḥ Muslim 1037',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “The scholars are the inheritors of the prophets.”',
      'Sunan Abī Dāwūd 3641; Jāmiʿ al-Tirmidhī 2682',
      'Recorded in Sunan Abī Dāwūd and Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “Do not lie about me. Whoever lies about me, let him take his seat in the Fire.”',
      'Ṣaḥīḥ al-Bukhārī 106; Ṣaḥīḥ Muslim 1',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “Make things easy and do not make them difficult. Give glad tidings and do not drive people away.”',
      'Ṣaḥīḥ al-Bukhārī 69; Ṣaḥīḥ Muslim 1734',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “It is enough falsehood for a person to speak of all that he hears.”',
      'Ṣaḥīḥ Muslim 5',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “May Allah brighten a person who hears something from us and conveys it as he heard it.”',
      'Jāmiʿ al-Tirmidhī 2657; Sunan Abī Dāwūd 3660',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan Abī Dāwūd.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “Whoever is asked about knowledge and conceals it will be bridled with a bridle of fire on the Day of Resurrection.”',
      'Sunan Abī Dāwūd 3658; Jāmiʿ al-Tirmidhī 2649',
      'Recorded in Sunan Abī Dāwūd and Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “Allah does not take away knowledge by snatching it from the people, but by taking the scholars.”',
      'Ṣaḥīḥ al-Bukhārī 100; Ṣaḥīḥ Muslim 2673',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      k,
      'The Messenger of Allah ﷺ said: “Whoever is slowed by his deeds, his lineage will not speed him up.”',
      'Ṣaḥīḥ Muslim 2699',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),

    // --- Time ---
    _verse(
      t,
      'By time, indeed mankind is in loss, except those who believe, do righteous deeds, and counsel one another to truth and to patience.',
      'Qur’an 103:1–3',
      'Sūrat al-ʿAṣr, verses 1–3.',
    ),
    _verse(
      t,
      'O you who believe, fear Allah, and let every soul look to what it has put forth for tomorrow.',
      'Qur’an 59:18',
      'Sūrat al-Ḥashr, verse 18.',
    ),
    _verse(
      t,
      'Spend from what We have provided you before death comes to one of you and he says, “My Lord, if only You would delay me for a brief term.”',
      'Qur’an 63:10',
      'Sūrat al-Munāfiqūn, verse 10.',
    ),
    _verse(
      t,
      'Did you think that We created you uselessly and that you would not be returned to Us?',
      'Qur’an 23:115',
      'Sūrat al-Mu’minūn, verse 115.',
    ),
    _verse(
      t,
      'Closer to people is their reckoning, while they are in heedlessness, turning away.',
      'Qur’an 21:1',
      'Sūrat al-Anbiyā’, verse 1.',
    ),
    _verse(
      t,
      'Know that the life of this world is but play, amusement, adornment, boasting among you, and rivalry in wealth and children.',
      'Qur’an 57:20',
      'Sūrat al-Ḥadīd, verse 20.',
    ),
    _verse(
      t,
      'No soul knows in which land it will die. Indeed, Allah is Knowing and Aware.',
      'Qur’an 31:34',
      'Sūrat Luqmān, verse 34.',
    ),
    _verse(
      t,
      'Has there come upon man a period of time when he was not a thing worth mentioning?',
      'Qur’an 76:1',
      'Sūrat al-Insān, verse 1.',
    ),
    _hadith(
      t,
      'The Messenger of Allah ﷺ said: “Two blessings which many people squander: health and free time.”',
      'Ṣaḥīḥ al-Bukhārī 6412',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      t,
      'The Messenger of Allah ﷺ said: “Be in this world as a stranger or a traveler.”',
      'Ṣaḥīḥ al-Bukhārī 6416',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      t,
      'The Prophet ﷺ said: “Take advantage of five before five: your youth before your old age, your health before your illness, your wealth before your poverty, your free time before your occupation, and your life before your death.”',
      'Mustadrak al-Ḥākim 7846; Musnad Aḥmad 23498',
      'Recorded in al-Mustadrak and Musnad Aḥmad.',
    ),
    _hadith(
      t,
      'The Messenger of Allah ﷺ said: “The feet of the son of Adam will not move on the Day of Resurrection until he is asked about his life and how he spent it, his knowledge and what he did with it, his wealth and how he earned and spent it, and his body and how he wore it out.”',
      'Jāmiʿ al-Tirmidhī 2417',
      'Recorded in Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      t,
      'The Messenger of Allah ﷺ said: “Hasten to good deeds before trials come like pieces of a dark night.”',
      'Ṣaḥīḥ Muslim 118',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      t,
      'The Messenger of Allah ﷺ said: “If the Hour is established and one of you has a seedling in his hand, let him plant it.”',
      'Musnad Aḥmad 12902',
      'Recorded in Musnad Aḥmad.',
    ),
    _hadith(
      t,
      'The Prophet ﷺ said: “I and the Hour have been sent like these two,” and he held his two fingers together.',
      'Ṣaḥīḥ al-Bukhārī 6503; Ṣaḥīḥ Muslim 2951',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      t,
      'The Messenger of Allah ﷺ said: “The wise one is he who takes account of himself and works for what is after death. The helpless one is he who follows his desires and wishes from Allah.”',
      'Jāmiʿ al-Tirmidhī 2459',
      'Recorded in Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      t,
      'The Messenger of Allah ﷺ said: “The heart of an old man remains young in two things: love of this world and long hope.”',
      'Ṣaḥīḥ al-Bukhārī 6420; Ṣaḥīḥ Muslim 1046',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      t,
      'The Messenger of Allah ﷺ said: “Do not curse time, for Allah is time.”',
      'Ṣaḥīḥ al-Bukhārī 6181; Ṣaḥīḥ Muslim 2246',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),

    // --- Health ---
    _verse(
      p,
      'Spend in the way of Allah, and do not throw yourselves into destruction. And do good; indeed, Allah loves those who do good.',
      'Qur’an 2:195',
      'Sūrat al-Baqarah, verse 195.',
    ),
    _verse(
      p,
      'Eat and drink, but do not be excessive. Indeed, He does not like those who commit excess.',
      'Qur’an 7:31',
      'Sūrat al-Aʿrāf, verse 31.',
    ),
    _verse(
      p,
      'O mankind, eat from whatever is on earth that is lawful and good, and do not follow the footsteps of Shaytan.',
      'Qur’an 2:168',
      'Sūrat al-Baqarah, verse 168.',
    ),
    _verse(
      p,
      'From their bellies comes a drink of varying colors, in which there is healing for people.',
      'Qur’an 16:69',
      'Sūrat al-Naḥl, verse 69.',
    ),
    _verse(
      p,
      'And when I am ill, it is He who cures me.',
      'Qur’an 26:80',
      'Sūrat al-Shuʿarā’, verse 80.',
    ),
    _verse(
      p,
      'We have certainly created man in the best of stature.',
      'Qur’an 95:4',
      'Sūrat al-Tīn, verse 4.',
    ),
    _verse(
      p,
      'Eat of the good things We have provided for you, and do not wrong yourselves in that.',
      'Qur’an 2:57',
      'Sūrat al-Baqarah, verse 57.',
    ),
    _verse(
      p,
      'He has only forbidden you carrion, blood, the flesh of swine, and that which has been dedicated to other than Allah.',
      'Qur’an 2:173',
      'Sūrat al-Baqarah, verse 173.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said: “There is no disease that Allah has created except that He also has created its treatment.”',
      'Ṣaḥīḥ al-Bukhārī 5678',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said: “The son of Adam fills no vessel worse than his stomach. A few mouthfuls are sufficient to keep his back straight.”',
      'Jāmiʿ al-Tirmidhī 2380; Sunan Ibn Mājah 3349',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan Ibn Mājah.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said: “Make use of medical treatment, for Allah has not made a disease without making a remedy for it.”',
      'Sunan Abī Dāwūd 3855',
      'Recorded in Sunan Abī Dāwūd.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said: “For every disease there is a remedy. When the remedy is applied to the disease, it is cured by permission of Allah.”',
      'Ṣaḥīḥ Muslim 2204',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      p,
      'The Prophet ﷺ forbade breathing or blowing into the drinking vessel.',
      'Ṣaḥīḥ al-Bukhārī 5630; Ṣaḥīḥ Muslim 267',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said: “If you hear of a plague in a land, do not enter it. If it occurs in a land you are in, do not leave it.”',
      'Ṣaḥīḥ al-Bukhārī 5728; Ṣaḥīḥ Muslim 2218',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said: “Cupping is among the best of your remedies.”',
      'Ṣaḥīḥ al-Bukhārī 5696',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said to ʿAbd Allāh ibn ʿAmr: “Your body has a right over you, your eye has a right over you, and your wife has a right over you.”',
      'Ṣaḥīḥ al-Bukhārī 1975; Ṣaḥīḥ Muslim 1159',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said: “Use the black seed, for it is a cure for every disease except death.”',
      'Ṣaḥīḥ al-Bukhārī 5688; Ṣaḥīḥ Muslim 2215',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      p,
      'The Messenger of Allah ﷺ said: “Healing is in three: a drink of honey, cupping, and cauterization. I forbid my ummah from cauterization.”',
      'Ṣaḥīḥ al-Bukhārī 5681',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),

    // --- Wealth ---
    _verse(
      w,
      'The example of those who spend their wealth in the way of Allah is like a grain that sprouts seven ears, in every ear a hundred grains.',
      'Qur’an 2:261',
      'Sūrat al-Baqarah, verse 261.',
    ),
    _verse(
      w,
      'O you who believe, spend from the good things you have earned, and from what We have brought forth for you from the earth.',
      'Qur’an 2:267',
      'Sūrat al-Baqarah, verse 267.',
    ),
    _verse(
      w,
      'Do not spend wastefully. Indeed, the wasteful are brothers of the shayatin.',
      'Qur’an 17:26–27',
      'Sūrat al-Isrā’, verses 26–27.',
    ),
    _verse(
      w,
      'Do not consume one another’s wealth unjustly, or send it to the rulers in order to consume a portion of people’s wealth sinfully.',
      'Qur’an 2:188',
      'Sūrat al-Baqarah, verse 188.',
    ),
    _verse(
      w,
      'Those who hoard gold and silver and do not spend it in the way of Allah — give them tidings of a painful punishment.',
      'Qur’an 9:34',
      'Sūrat al-Tawbah, verse 34.',
    ),
    _verse(
      w,
      'Spend in the way of Allah. Whoever is protected from the stinginess of his soul — it is they who will be successful.',
      'Qur’an 64:16',
      'Sūrat al-Taghābun, verse 64.',
    ),
    _verse(
      w,
      'Allah has permitted trade and forbidden usury.',
      'Qur’an 2:275',
      'Sūrat al-Baqarah, verse 275.',
    ),
    _verse(
      w,
      'Let the one of ample means spend according to his means, and he whose provision is restricted, let him spend from what Allah has given him.',
      'Qur’an 65:7',
      'Sūrat al-Ṭalāq, verse 7.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “The upper hand is better than the lower hand. The upper hand is the one that gives, and the lower is the one that takes.”',
      'Ṣaḥīḥ al-Bukhārī 1427; Ṣaḥīḥ Muslim 1033',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “Wealth is not in having many possessions. True wealth is the richness of the soul.”',
      'Ṣaḥīḥ al-Bukhārī 6446; Ṣaḥīḥ Muslim 1051',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “If the son of Adam had two valleys of wealth, he would wish for a third. Nothing fills the belly of the son of Adam except dust.”',
      'Ṣaḥīḥ al-Bukhārī 6436; Ṣaḥīḥ Muslim 1048',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “The honest, trustworthy merchant will be with the prophets, the truthful, and the martyrs.”',
      'Jāmiʿ al-Tirmidhī 1209',
      'Recorded in Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “Gold for gold, silver for silver, like for like, equal for equal, hand to hand. Whoever gives more or asks for more has engaged in riba.”',
      'Ṣaḥīḥ al-Bukhārī 2177; Ṣaḥīḥ Muslim 1587',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “This wealth is green and sweet. Whoever takes it without greed is blessed in it, and whoever takes it with greed is not blessed in it.”',
      'Ṣaḥīḥ al-Bukhārī 1465; Ṣaḥīḥ Muslim 1052',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “Beware of greed, for it destroyed those who came before you.”',
      'Ṣaḥīḥ Muslim 2578',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “No one has ever eaten better food than that which his own hands have earned.”',
      'Ṣaḥīḥ al-Bukhārī 2072',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “Whoever takes people’s wealth intending to repay it, Allah will repay it for him. Whoever takes it intending to waste it, Allah will destroy him.”',
      'Ṣaḥīḥ al-Bukhārī 2387',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      w,
      'The Messenger of Allah ﷺ said: “Islam is built on five: testimony that there is no god but Allah, prayer, zakah, Hajj, and fasting Ramadan.”',
      'Ṣaḥīḥ al-Bukhārī 8; Ṣaḥīḥ Muslim 16',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),

    // --- Ummah ---
    _verse(
      m,
      'You are the best nation brought forth for mankind: you enjoin what is right, forbid what is wrong, and believe in Allah.',
      'Qur’an 3:110',
      'Sūrat Āl ʿImrān, verse 110.',
    ),
    _verse(
      m,
      'Hold firmly to the rope of Allah all together, and do not become divided.',
      'Qur’an 3:103',
      'Sūrat Āl ʿImrān, verse 103.',
    ),
    _verse(
      m,
      'The believers are but brothers, so make settlement between your brothers.',
      'Qur’an 49:10',
      'Sūrat al-Ḥujurāt, verse 10.',
    ),
    _verse(
      m,
      'This community of yours is one community, and I am your Lord, so worship Me.',
      'Qur’an 21:92',
      'Sūrat al-Anbiyā’, verse 92.',
    ),
    _verse(
      m,
      'The believing men and believing women are allies of one another. They enjoin what is right and forbid what is wrong.',
      'Qur’an 9:71',
      'Sūrat al-Tawbah, verse 71.',
    ),
    _verse(
      m,
      'Allah does not forbid you from those who do not fight you because of religion and do not expel you from your homes — from being righteous toward them and dealing justly with them.',
      'Qur’an 60:8',
      'Sūrat al-Mumtaḥanah, verse 8.',
    ),
    _verse(
      m,
      'Cooperate in righteousness and piety, and do not cooperate in sin and aggression.',
      'Qur’an 5:2',
      'Sūrat al-Mā’idah, verse 2.',
    ),
    _verse(
      m,
      'Let there be a group among you inviting to good, enjoining what is right, and forbidding what is wrong.',
      'Qur’an 3:104',
      'Sūrat Āl ʿImrān, verse 104.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “The believers in their mutual kindness, compassion, and sympathy are like one body. When any limb aches, the whole body responds with sleeplessness and fever.”',
      'Ṣaḥīḥ al-Bukhārī 6011; Ṣaḥīḥ Muslim 2586',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “Whoever relieves a believer of a distress in this world, Allah will relieve him of a distress on the Day of Resurrection.”',
      'Ṣaḥīḥ Muslim 2699',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “He who is not merciful to people, Allah will not be merciful to him.”',
      'Ṣaḥīḥ al-Bukhārī 7376; Ṣaḥīḥ Muslim 2319',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “Whoever builds a mosque for Allah, Allah builds for him a house in Paradise.”',
      'Ṣaḥīḥ al-Bukhārī 450; Ṣaḥīḥ Muslim 533',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “The believer to the believer is like a building, each part supporting the other,” and he interlaced his fingers.',
      'Ṣaḥīḥ al-Bukhārī 481; Ṣaḥīḥ Muslim 2585',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “Your blood, your wealth, and your honor are sacred, like the sanctity of this day of yours, in this month of yours, in this city of yours.”',
      'Ṣaḥīḥ al-Bukhārī 1739; Ṣaḥīḥ Muslim 1679',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “Whoever believes in Allah and the Last Day, let him honor his guest.”',
      'Ṣaḥīḥ al-Bukhārī 6018; Ṣaḥīḥ Muslim 47',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “Whoever among you sees an evil, let him change it with his hand. If he cannot, then with his tongue. If he cannot, then with his heart — and that is the weakest of faith.”',
      'Ṣaḥīḥ Muslim 49',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “A man is not a believer who fills his stomach while his neighbor goes hungry.”',
      'al-Adab al-Mufrad 112',
      'Recorded in al-Adab al-Mufrad of al-Bukhārī.',
    ),
    _hadith(
      m,
      'The Messenger of Allah ﷺ said: “The merciful are shown mercy by the Most Merciful. Be merciful to those on earth, and the One in the heaven will be merciful to you.”',
      'Jāmiʿ al-Tirmidhī 1924; Sunan Abī Dāwūd 4941',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan Abī Dāwūd.',
    ),

    // --- Fasting ---
    _verse(
      f,
      'O you who believe, fasting is prescribed for you as it was prescribed for those before you, that you may become mindful.',
      'Qur’an 2:183',
      'Sūrat al-Baqarah, verse 183.',
    ),
    _verse(
      f,
      'The month of Ramadan in which the Qur’an was revealed as guidance for people. Allah intends for you ease and does not intend for you hardship.',
      'Qur’an 2:185',
      'Sūrat al-Baqarah, verse 185.',
    ),
    _verse(
      f,
      'Eat and drink until the white thread of dawn becomes distinct from the black thread. Then complete the fast until night.',
      'Qur’an 2:187',
      'Sūrat al-Baqarah, verse 187.',
    ),
    _verse(
      f,
      'Fasting is for a limited number of days. But if any of you is ill or on a journey, then an equal number of other days.',
      'Qur’an 2:184',
      'Sūrat al-Baqarah, verse 184.',
    ),
    _verse(
      f,
      'The fasting men and fasting women… for them Allah has prepared forgiveness and a great reward.',
      'Qur’an 33:35',
      'Sūrat al-Aḥzāb, verse 35.',
    ),
    _verse(
      f,
      'When My servants ask you about Me, indeed I am near. I respond to the call of the caller when he calls upon Me.',
      'Qur’an 2:186',
      'Sūrat al-Baqarah, verse 186.',
    ),
    _verse(
      f,
      'The Night of Decree is better than a thousand months.',
      'Qur’an 97:3',
      'Sūrat al-Qadr, verse 3.',
    ),
    _verse(
      f,
      'Its expiation is the feeding of ten needy people… or fasting three days.',
      'Qur’an 5:89',
      'Sūrat al-Mā’idah, verse 89.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “Whoever fasts Ramadan out of faith and seeking reward, his previous sins will be forgiven.”',
      'Ṣaḥīḥ al-Bukhārī 38; Ṣaḥīḥ Muslim 760',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “Every deed of the son of Adam is for him except fasting. It is for Me, and I reward it.”',
      'Ṣaḥīḥ al-Bukhārī 1904; Ṣaḥīḥ Muslim 1151',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “When Ramadan begins, the gates of Paradise are opened, the gates of the Fire are closed, and the shayatin are chained.”',
      'Ṣaḥīḥ al-Bukhārī 1898; Ṣaḥīḥ Muslim 1079',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “There is a gate in Paradise called al-Rayyān, through which those who fast will enter, and none other than they will enter it.”',
      'Ṣaḥīḥ al-Bukhārī 1896; Ṣaḥīḥ Muslim 1152',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “Fasting is a shield.”',
      'Ṣaḥīḥ al-Bukhārī 1904; Ṣaḥīḥ Muslim 1151',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “Whoever does not give up false speech and acting upon it, Allah has no need of his leaving his food and drink.”',
      'Ṣaḥīḥ al-Bukhārī 1903',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “The people will remain upon goodness as long as they hasten the iftar.”',
      'Ṣaḥīḥ al-Bukhārī 1957; Ṣaḥīḥ Muslim 1098',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “Take suhur, for in suhur there is blessing.”',
      'Ṣaḥīḥ al-Bukhārī 1923; Ṣaḥīḥ Muslim 1095',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “Fasting the day of ʿArafah, I hope from Allah, expiates the year before it and the year after it.”',
      'Ṣaḥīḥ Muslim 1162',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      f,
      'The Messenger of Allah ﷺ said: “Whoever fasts a day in the path of Allah, Allah will place between his face and the Fire a trench like the distance between heaven and earth.”',
      'Ṣaḥīḥ al-Bukhārī 2840',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),

    // --- Hajj ---
    _verse(
      j,
      'Pilgrimage to the House is a duty owed to Allah by people who are able to undertake it.',
      'Qur’an 3:97',
      'Sūrat Āl ʿImrān, verse 97.',
    ),
    _verse(
      j,
      'Complete the Hajj and ʿUmrah for Allah.',
      'Qur’an 2:196',
      'Sūrat al-Baqarah, verse 196.',
    ),
    _verse(
      j,
      'Hajj is in well-known months. Whoever undertakes Hajj in them, there is to be no intimate relations, no disobedience, and no disputing during Hajj.',
      'Qur’an 2:197',
      'Sūrat al-Baqarah, verse 197.',
    ),
    _verse(
      j,
      'Proclaim the Hajj to the people. They will come to you on foot and on every lean camel, coming from every distant pass.',
      'Qur’an 22:27',
      'Sūrat al-Ḥajj, verse 27.',
    ),
    _verse(
      j,
      'Then let them complete their rites, fulfill their vows, and circumambulate the ancient House.',
      'Qur’an 22:29',
      'Sūrat al-Ḥajj, verse 29.',
    ),
    _verse(
      j,
      'Allah has made the Kaʿbah, the Sacred House, a standing for people, and the sacred months, the sacrificial offering, and the garlands.',
      'Qur’an 5:97',
      'Sūrat al-Mā’idah, verse 97.',
    ),
    _verse(
      j,
      'Take the standing place of Ibrahim as a place of prayer.',
      'Qur’an 2:125',
      'Sūrat al-Baqarah, verse 125.',
    ),
    _verse(
      j,
      'Ṣafā and Marwah are among the symbols of Allah. So whoever performs Hajj or ʿUmrah, there is no blame upon him for walking between them.',
      'Qur’an 2:158',
      'Sūrat al-Baqarah, verse 158.',
    ),
    _hadith(
      j,
      'The Messenger of Allah ﷺ said: “Islam is built on five… Hajj to the House.”',
      'Ṣaḥīḥ al-Bukhārī 8; Ṣaḥīḥ Muslim 16',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      j,
      'The Messenger of Allah ﷺ said: “Whoever performs Hajj and does not commit any obscenity or transgression will return as on the day his mother bore him.”',
      'Ṣaḥīḥ al-Bukhārī 1521; Ṣaḥīḥ Muslim 1350',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      j,
      'The Messenger of Allah ﷺ said: “An ʿUmrah to another ʿUmrah is expiation for what is between them, and a Hajj mabrūr has no reward except Paradise.”',
      'Ṣaḥīḥ al-Bukhārī 1773; Ṣaḥīḥ Muslim 1349',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      j,
      'The Messenger of Allah ﷺ said: “Hajj is ʿArafah.”',
      'Jāmiʿ al-Tirmidhī 889; Sunan al-Nasā’ī 3016',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan al-Nasā’ī.',
    ),
    _hadith(
      j,
      'The Messenger of Allah ﷺ said: “Follow up Hajj with ʿUmrah, for they remove poverty and sins as the bellows remove the dross of iron.”',
      'Jāmiʿ al-Tirmidhī 810; Sunan al-Nasā’ī 2631',
      'Recorded in Jāmiʿ al-Tirmidhī and Sunan al-Nasā’ī.',
    ),
    _hadith(
      j,
      'The Messenger of Allah ﷺ said: “There is no day on which Allah frees more servants from the Fire than the day of ʿArafah.”',
      'Ṣaḥīḥ Muslim 1348',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      j,
      'The Prophet ﷺ was asked which deed is best. He said: “Faith in Allah and His Messenger.” He was asked: Then what? He said: “Jihad in the way of Allah.” Then what? “A Hajj that is accepted.”',
      'Ṣaḥīḥ al-Bukhārī 26; Ṣaḥīḥ Muslim 83',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      j,
      'ʿĀ’ishah asked about jihad for women. The Messenger of Allah ﷺ said: “Your jihad is Hajj.”',
      'Ṣaḥīḥ al-Bukhārī 2875',
      'Recorded in Ṣaḥīḥ al-Bukhārī.',
    ),
    _hadith(
      j,
      'Ibn ʿUmar said: I saw the Messenger of Allah ﷺ touching the Black Stone and kissing it.',
      'Ṣaḥīḥ al-Bukhārī 1611; Ṣaḥīḥ Muslim 1270',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      j,
      'The Messenger of Allah ﷺ said in the Farewell Hajj: “Your blood, your wealth, and your honor are sacred to you, like the sanctity of this day of yours, in this month of yours, in this city of yours.”',
      'Ṣaḥīḥ al-Bukhārī 1739; Ṣaḥīḥ Muslim 1679',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),

    // --- Charity ---
    _verse(
      c,
      'Those who spend their wealth by night and by day, secretly and publicly — they will have their reward with their Lord.',
      'Qur’an 2:274',
      'Sūrat al-Baqarah, verse 274.',
    ),
    _verse(
      c,
      'Never will you attain the good until you spend from that which you love.',
      'Qur’an 3:92',
      'Sūrat Āl ʿImrān, verse 92.',
    ),
    _verse(
      c,
      'The example of those who spend their wealth in the way of Allah is like a grain that grows seven ears.',
      'Qur’an 2:261',
      'Sūrat al-Baqarah, verse 261.',
    ),
    _verse(
      c,
      'Who is it that will lend Allah a goodly loan, so He will multiply it for him many times over?',
      'Qur’an 2:245',
      'Sūrat al-Baqarah, verse 245.',
    ),
    _verse(
      c,
      'Zakah expenditures are only for the poor, the needy, those employed to collect it, those whose hearts are to be reconciled, for freeing captives, for those in debt, in the way of Allah, and for the traveler.',
      'Qur’an 9:60',
      'Sūrat al-Tawbah, verse 60.',
    ),
    _verse(
      c,
      'The charitable men and charitable women who lend Allah a goodly loan — it will be multiplied for them, and they will have a noble reward.',
      'Qur’an 57:18',
      'Sūrat al-Ḥadīd, verse 18.',
    ),
    _verse(
      c,
      'If you disclose your charity, it is good; if you conceal it and give it to the poor, it is better for you.',
      'Qur’an 2:271',
      'Sūrat al-Baqarah, verse 271.',
    ),
    _verse(
      c,
      'They give food, despite their love for it, to the needy, the orphan, and the captive.',
      'Qur’an 76:8',
      'Sūrat al-Insān, verse 8.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “Charity does not decrease wealth.”',
      'Ṣaḥīḥ Muslim 2588',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “Protect yourselves from the Fire, even with half a date in charity.”',
      'Ṣaḥīḥ al-Bukhārī 1417; Ṣaḥīḥ Muslim 1016',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “Seven will be shaded by Allah… a man who gave charity so secretly that his left hand did not know what his right spent.”',
      'Ṣaḥīḥ al-Bukhārī 660; Ṣaḥīḥ Muslim 1031',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “When a person dies, his deeds come to an end except three: ongoing charity, beneficial knowledge, and a righteous child who prays for him.”',
      'Ṣaḥīḥ Muslim 1631',
      'Recorded in Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “The believer’s shade on the Day of Resurrection will be his charity.”',
      'Musnad Aḥmad 17333; Jāmiʿ al-Tirmidhī 1925',
      'Recorded in Musnad Aḥmad and Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “No one gives charity from good earnings — and Allah accepts only what is good — except that the Most Merciful takes it in His right hand.”',
      'Ṣaḥīḥ al-Bukhārī 1410; Ṣaḥīḥ Muslim 1014',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “Give charity, for a time will come when a man will walk with his charity and not find anyone to accept it.”',
      'Ṣaḥīḥ al-Bukhārī 1411; Ṣaḥīḥ Muslim 1011',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “The best charity is that given while you are healthy and greedy, hoping to be wealthy and fearing poverty.”',
      'Ṣaḥīḥ al-Bukhārī 1419; Ṣaḥīḥ Muslim 1032',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “Your smiling in the face of your brother is charity.”',
      'Jāmiʿ al-Tirmidhī 1956',
      'Recorded in Jāmiʿ al-Tirmidhī.',
    ),
    _hadith(
      c,
      'The Messenger of Allah ﷺ said: “There is a charity due on every joint of a person every day the sun rises.”',
      'Ṣaḥīḥ al-Bukhārī 2989; Ṣaḥīḥ Muslim 1009',
      'Recorded in Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim.',
    ),
  ];
}
