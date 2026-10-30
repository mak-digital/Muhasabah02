import 'app_language.dart';

/// First Bangla draft, keyed by the English line it replaces.
/// Missing keys stay in English so an unfinished screen is still readable.
const kBanglaByEnglish = <String, String>{
  'Private Muhasabah': 'প্রাইভেট মুহাসাবা',
  'Your record, not a ruling.': 'আপনার হিসাব, কোনো ফতোয়া নয়।',
  'Notice your day to improve. Keep it yours.':
      'দিনটি লক্ষ্য করুন। হিসাব আপনারই থাকবে।',
  'Start today’s check-in': 'আজকের হিসাব শুরু করুন',
  'Quick tap': 'দ্রুত ট্যাপ',
  'Home': 'মূলপাতা',
  'Input': 'ইনপুট',
  'Review': 'পর্যালোচনা',
  'Registry': 'তালিকা',
  'Settings': 'সেটিংস',
  'FAQ': 'প্রশ্নোত্তর',
  'Language': 'ভাষা',
  'ACTIVE DOMAIN & MIX': 'চলতি বিষয় ও মিশ্রণ',
  'This recorder is yours': 'এই হিসাবখাতা আপনার',
  'This is a private recorder. It does not score your worship, keep a streak, or issue a ruling.': 'এটি একটি ব্যক্তিগত হিসাবখাতা। এটি ইবাদতের নম্বর দেয় না, ধারা রাখে না, এবং কোনো ফতোয়া দেয় না।',
  'An empty mark is not missed. You can save a day with unanswered rows.': 'খালি চিহ্ন মানে ছুটে যাওয়া নয়। উত্তর না দিয়েও একটি দিন সংরক্ষণ করা যায়।',
  'Home starts with Salah, Qur’an, and Dhikr. Add Hadith, Fasting, Character, Rights, or Charity when you want them. Empty is not missed.': 'মূলপাতা শুরু হয় সালাত, কুরআন ও জিকির দিয়ে। চাইলে হাদিস, রোজা, চরিত্র, হক বা সদকা যোগ করুন। খালি রাখা মানে ছুটে যাওয়া নয়।',
  'Start with a quiet week': 'শান্ত একটি সপ্তাহ দিয়ে শুরু',
  'Show sample days': 'নমুনা দিন দেখুন',
  'Sample days use the same live fields so you can try looking back. Later windows can look busier than earlier ones. That is a demonstration, not a target.': 'নমুনা দিনগুলো একই ঘর ব্যবহার করে, যাতে পেছনে তাকানো যায়। পরের দিনগুলো আগের দিনের চেয়ে বেশি ভরা দেখাতে পারে। এটি দেখানোর জন্য, কোনো লক্ষ্য নয়।',
  'Sample/demo records are visible so you can try looking back. They stay until you archive them. They are not a target.': 'নমুনা হিসাব দেখা যাচ্ছে, যাতে পেছনে তাকানো যায়। আপনি সরিয়ে না দেওয়া পর্যন্ত এগুলো থাকবে। এগুলো কোনো লক্ষ্য নয়।',
  'This season I am noticing': 'এই মৌসুমে আমি লক্ষ্য করছি',
  'RECORD → REFLECT → REVIEW → RECOGNISE → PONDER → RESPOND':
      'লিপিবদ্ধ → ভাবনা → পর্যালোচনা → চিনে নেওয়া → চিন্তা → সাড়া',
  'SEE → PONDER → EXPLORE': 'দেখা → চিন্তা → খোঁজা',
  'About Private Muhasabah': 'প্রাইভেট মুহাসাবা সম্পর্কে',
  'Purpose, mix, and clarifications': 'উদ্দেশ্য, মিশ্রণ ও ব্যাখ্যা',
  'Clarifications only. Not advice, scores, or a verdict. Grayed items below are not in this version.': 'শুধু ব্যাখ্যা। পরামর্শ, নম্বর বা রায় নয়। নিচের ধূসর বিষয়গুলো এই সংস্করণে নেই।',
  'Wording for your review': 'আপনার দেখার জন্য ভাষা',
  'Read the Bangla under each English line. Tell me which lines to change. Screens that are not in this list stay in English for now. Arabic verses and hadith stay in Arabic.': 'প্রতিটি ইংরেজি লাইনের নিচে বাংলা পড়ুন। কোন লাইন বদলাতে হবে, তা বলুন। এই তালিকায় নেই এমন পর্দা আপাতত ইংরেজিতেই থাকবে। কুরআন ও হাদিসের আরবি আরবিতেই থাকবে।',
  'English or Bangla for this first draft. The daily path and these lines switch. The rest of the app stays in English until the next pass.': 'এই প্রথম খসড়ায় English বা বাংলা। দৈনিক পথ ও এই লাইনগুলো বদলায়। বাকি অ্যাপ পরের ধাপ পর্যন্ত ইংরেজিতে থাকে।',
  'Salah': 'সালাত',
  'Qur’an': 'কুরআন',
  'Hadith': 'হাদিস',
  'Dhikr': 'জিকির',
  'Character': 'চরিত্র',
  'Rights': 'হক',
  'Charity': 'সদকা',
  'Fasting': 'রোজা',
  'Knowledge': 'জ্ঞান',
  'Time': 'সময়',
  'Health': 'স্বাস্থ্য',
  'Wealth': 'সম্পদ',
  'Ummah': 'উম্মাহ',
  'Hajj': 'হজ্জ',
  'Productivity': 'কাজ',
  'Salah & Prayer Quality': 'সালাত ও নামাজের উপস্থিতি',
  'Qur’an Engagement': 'কুরআনের সঙ্গে যোগ',
  'Hadith & Living Sunnah': 'হাদিস ও জীবন্ত সুন্নাহ',
  'Dhikr & Dua': 'জিকির ও দোয়া',
  'Character & Morals (Akhlaq)': 'চরিত্র ও নৈতিকতা (আখলাক)',
  'Rights of Others (Huquq al-Ibad)': 'অন্যের হক (হুকুকুল ইবাদ)',
  'Knowledge & Beneficial Speech': 'জ্ঞান ও উপকারী কথা',
  'Time & Barakah': 'সময় ও বরকত',
  'Physical Health & Energy': 'শারীরিক সুস্থতা ও শক্তি',
  'Wealth & Stewardship': 'সম্পদ ও আমানত',
  'Was my heart present when I stood before Allah?':
      'আল্লাহর সামনে দাঁড়ানোর সময় কি আমার মন উপস্থিত ছিল?',
  'Did I let the Qur’an speak to me today?':
      'আজ কি আমি কুরআনকে আমার সঙ্গে কথা বলতে দিয়েছি?',
  'Did a teaching of the Prophet ﷺ reach my day?':
      'নবী ﷺ-এর কোনো শিক্ষা কি আজ আমার দিনে পৌঁছেছে?',
  'Did I remember Allah outside of prayer?':
      'নামাজের বাইরে কি আমি আল্লাহকে স্মরণ করেছি?',
  'Did my behavior today invite people toward goodness?':
      'আজ আমার আচরণ কি মানুষকে কল্যাণের দিকে ডেকেছে?',
  'Did I fulfill, harm, or neglect anyone’s right over me?':
      'কারো হক কি আমি আদায় করেছি, নষ্ট করেছি, নাকি উপেক্ষা করেছি?',
  'Did I learn something true, and did I speak only what was beneficial?':
      'কি আমি সত্য কিছু শিখেছি, এবং কি শুধু উপকারী কথা বলেছি?',
  'Did I treat my time as a trust from Allah?':
      'সময়কে কি আমি আল্লাহর আমানত হিসেবে দেখেছি?',
  'Did I care for the body Allah entrusted to me?':
      'আল্লাহ আমাকে যে দেহ দিয়েছেন, তার যত্ন কি আমি নিয়েছি?',
  'Did I manage earning, spending and wealth as trusts from Allah?':
      'উপার্জন, খরচ ও সম্পদকে কি আমি আল্লাহর আমানত হিসেবে দেখেছি?',
  'Did I serve anyone beyond myself today?':
      'আজ কি আমি নিজের বাইরে কাউকে সহায়তা করেছি?',
  'Did I notice fasting, worship, and balance without scoring sawm?':
      'রোজা, ইবাদত ও ভারসাম্য কি আমি লক্ষ্য করেছি — কোনো নম্বর ছাড়া?',
  'Have I named how Hajj stands with me — as I see it, not as the app decides?': 'হজ্জ আমার ক্ষেত্রে কোথায়, তা কি আমি নিজে বলেছি — অ্যাপের সিদ্ধান্ত নয়?',
  'Which actions did I choose to move today?':
      'আজ কোন কাজগুলো আমি এগিয়ে নিতে বেছে নিয়েছি?',
  'Private Muhasabah is your private recorder. RECORD what you noticed, REFLECT on the day, REVIEW later windows, RECOGNISE descriptive patterns, PONDER, and RESPOND in your own words. It does not score worship, keep a streak, or issue a ruling.\n\nAfter you record, look back. You may notice what you recorded more or less often, and optional factors you named around those days. Factors are not causes. The app does not diagnose a reason, prescribe a remedy, or set a standard of practice. A Response is yours: you decide whether anything needs a change.\n\nShow only the domains you want. Leave a row unanswered when it does not apply — empty is not missed. Records stay on this device.\n\nSample days, if you choose them, use the same live fields so Review and 30-day graphs can be tried. Later windows can look busier than earlier ones so the views have something to show. That is a demonstration, not a target.\n\nThis season: Salah (prayers you recorded), Qur’an (three independent sittings), Hadith (whether a teaching reached the day), Dhikr (performed lists), Fasting (Ramadan and voluntary noticing), Character (yourself only), Rights (what you owe others), and Charity (giving without amounts).': 'প্রাইভেট মুহাসাবা আপনার ব্যক্তিগত হিসাবখাতা। যা লক্ষ্য করেছেন তা লিপিবদ্ধ করুন, দিনটি নিয়ে ভাবুন, পরে পর্যালোচনা করুন, যা দেখা যায় তা চিনে নিন, চিন্তা করুন, এবং নিজের কথায় সাড়া লিখুন। এটি ইবাদতের নম্বর দেয় না, ধারা রাখে না, এবং ফতোয়া দেয় না।\n\nলিপিবদ্ধ করার পর পেছনে তাকান। কোনো বিষয় আপনি বেশি বা কম লিখেছেন, এবং সেই দিনগুলোর পাশে কোন ঐচ্ছিক বিষয় রেখেছেন, তা দেখতে পারেন। সেই বিষয়গুলো কারণ নয়। অ্যাপ কোনো কারণ ধরে না, কোনো ব্যবস্থা বলে না, এবং চর্চার কোনো মানদণ্ড বসায় না। সাড়া আপনার: কিছু বদলাতে হবে কি না, তা আপনি ঠিক করেন।\n\nযে বিষয়গুলো চান, শুধু সেগুলো দেখান। যে ঘর খাটে না, সেটি খালি রাখুন — খালি মানে ছুটে যাওয়া নয়। হিসাব এই ফোনেই থাকে।\n\nনমুনা দিন চাইলে, একই ঘর দিয়ে পর্যালোচনা ও ৩০ দিনের ছবি দেখা যায়। পরের অংশ আগের অংশের চেয়ে বেশি ভরা দেখাতে পারে, যাতে দেখার কিছু থাকে। এটি দেখানোর জন্য, কোনো লক্ষ্য নয়।\n\nএই মৌসুম: সালাত (যে নামাজ আপনি লিখেছেন), কুরআন (তিনটি আলাদা বসা), হাদিস (কোনো শিক্ষা দিনে পৌঁছেছে কি না), জিকির (যা পড়েছেন তার তালিকা), রোজা (রমজান ও নফল লক্ষ্য), চরিত্র (শুধু নিজের), হক (অন্যের প্রতি যা আপনার), এবং সদকা (পরিমাণ ছাড়া দান)।',
};

String localizedUi(AppLanguage language, String english) {
  if (language != AppLanguage.bangla) return english;
  return kBanglaByEnglish[english] ?? english;
}
