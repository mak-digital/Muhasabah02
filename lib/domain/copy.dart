import 'domain_briefing.dart';

class Copy {
  static const appName = 'Private Muhasabah';
  static const appSlogan = 'Your record, not a ruling.';
  static const appNotice = 'Notice your day to improve. Keep it yours.';
  static const homeCheckIn = 'Start today’s check-in';
  static const today = 'Today';
  static const todayEmpty =
      'No domains are shown for today. Choose Domains and this season’s mix in Settings.';
  static const todayDomainEmpty =
      'No rows for this domain today. Nothing was invented.';
  static const todayRecorded = 'Recorded';
  static const todayNoResponseYet = 'No response yet';
  static const todayRecordedToday = 'Recorded today';
  static const todayRecordedForToday = 'Recorded for today';
  static const todayZakatStatus = 'Status';
  static const quickTap = 'Quick tap';
  static const quickTapTitle = 'Quick tap';
  static const quickTapNote =
      'Busy day. Tiles are this season’s mix on domains you show. Each tap steps the same list as check-in. Unticked stays unanswered. After unanswered, your most recorded choice comes first. Reflection can wait.';
  static const quickTapEmpty =
      'No mix rows on shown domains. Choose Domains and this season’s mix in Settings.';
  static const quickTapFajrHint = 'On time is not a khushu’ score.';
  static const homeReview = 'Review recorded experience';
  static const homeManage = 'Manage past check-ins';
  static const reviewTitle = 'Review';
  static const historyTitle = 'Manage past check-ins';
  static const historyGuard =
      'Edit a saved day, or remove the app’s record. This is not a score. Recorded days is the read-only view.';
  static const historyTapToEdit = 'Tap to edit';
  static const historyEditCheckIn = 'Edit this check-in';
  static const historyRemoveRecord = 'Remove app record…';
  static const historyRemoveTitle = 'Remove this check-in?';
  static const historyRemoveBody =
      'This removes the app-managed record. It does not claim forensic erasure.';
  static const historyKeep = 'Keep';
  static const historyRemove = 'Remove';
  static const unsavedCheckInTitle = 'Unsaved check-in';
  static const unsavedCheckInSave = 'Save for this date';
  static const unsavedCheckInContinue = 'Continue editing';
  static const unsavedCheckInDiscard = 'Discard changes';
  static String unsavedCheckInBody(String date) =>
      'You have unsaved changes for $date. They have not been stored.';
  static const historyDayMenu = 'Edit or remove';
  static const historyFilterAll = 'All';
  static const historyEmptyFilter =
      'No saved check-ins in this window. Switch to All to see every saved day.';
  static const recordedDaysTitle = 'Recorded days';
  static const historicalReflectionTitle = 'Historical Reflection';
  static const myResponse = 'My Response';
  static const myResponseDescription =
      'A private, optional place to write a note, question, or something you want to keep in mind.';
  static const addAResponse = 'Add a response';
  static const creationPrompt =
      'What, if anything, would you like to note or keep in mind?';
  static const emptyResponses =
      'You haven’t saved any responses. Creating one is optional.';
  static const saveResponse = 'Save response';
  static const editResponse = 'Edit response';
  static const archiveResponse = 'Archive response';
  static const restoreResponse = 'Restore response';
  static const deleteResponse = 'Delete response';
  static const ponderPrompt =
      'What do you notice about your recorded Qur’an engagement in this period?';
  static const evidenceUnavailable =
      'The originating evidence is no longer available.';
  static const applicationReflectionNote =
      'Application Reflection records reflection on possible practical relevance only. It is not evidence of action, implementation, obedience, compliance, successful application, or completion of a Response.';
  static const youRecorded = 'You recorded';
  static const missingDays = 'Days with no check-in';
  static const recordedDays = 'Days with a saved check-in';
  static const recordedDaysGuard =
      'Read-only. Tap a saved day to view it. Editing is in Manage past check-ins.';
  static const recordedDaysSavedLegend = 'Saved — open';
  static const recordedDaysEmptyLegend = 'No check-in';
  static const recordedDaysSaved = 'Saved';
  static const recordedDaysEmptyNote =
      'Empty days stay visible so missing is not hidden. They are not tappable and are not treated as missed.';
  static const historicalReflectionGuard = 'Historical Reflection · read-only';
  static const sampleRecordPill = 'Sample';
  static const notesOnThisDay = 'Notes on this day';
  static const factorsNotCauses =
      'You recorded these factors. They are not causes.';
  static const unansweredNotMissed = 'Not recorded is not the same as missed.';
  static const reviewGuard =
      'A private reading of what you recorded. This screen does not change records or tell you what to do next.';
  static const reviewThisPeriod = 'This period';
  static const reviewUnansweredDays = 'Unanswered days';
  static const reviewNoneRecorded = 'None recorded';
  static const reviewDomainsTap = 'Domains · tap to open Progress';
  static const reviewOpenProgress = 'Open Progress';
  static const reviewLookCloser = 'Look closer';
  static const reviewPonder = 'Ponder';
  static const reviewWhatRecordsShow = 'What the records show';
  static const reviewYouAlsoRecorded = 'You also recorded';
  static const reviewRecognitionBody =
      'Descriptive context patterns in 30- and 90-day views';
  static const edit = 'Edit';
  static String get akhlaqObservationNote => akhlaqBriefing.plainText;
  static const akhlaqStruggleNote = 'Struggle note';
  static const akhlaqStruggleHint =
      'Optional, about yourself only. Not a score. Example: I was impatient today, but I caught myself. Or: I reached for it, then I stopped.';
  static const akhlaqNoticed = 'I noticed this in myself';
  static const akhlaqNotToday = 'I did not notice this today';
  static String get huquqObservationNote => huquqBriefing.plainText;
  static const huquqAttended = 'I attended to a right I owe';
  static const huquqNeglected = 'I neglected a right I owe';
  static String get knowledgeObservationNote => knowledgeBriefing.plainText;
  static const knowledgeNoticed = 'I noticed this in myself';
  static const knowledgeNotToday = 'I did not notice this today';
  static String get timeObservationNote => timeBriefing.plainText;
  static const timeNoticed = 'I noticed this in myself';
  static const timeNotToday = 'I did not notice this today';
  static String get healthObservationNote => healthBriefing.plainText;
  static const healthNoticed = 'I noticed this in myself';
  static const healthNotToday = 'I did not notice this today';
  static String get wealthObservationNote => wealthBriefing.plainText;
  static const wealthNoticed = 'I noticed this in myself';
  static const wealthNotToday = 'I did not notice this today';
  static String get ummahObservationNote => ummahBriefing.plainText;
  static const ummahNoticed = 'I noticed this in myself';
  static const ummahNotToday = 'I did not notice this today';
  static String get hadithObservationNote => hadithBriefing.plainText;
  static const hadithNoticed = 'I noticed this in myself';
  static const hadithNotToday = 'I did not notice this today';
  static String get hajjObservationNote => hajjBriefing.plainText;
  static const hajjStatusLabel = 'Hajj';
  static const hajjStatusNote =
      'This is your record, not a ruling. The app does not decide ability or timing.';
  static const hajjPonderDue =
      'You recorded Hajj as due. What preparation, if any, would you like to notice this season?';
  static const hajjPonderPreparing =
      'You recorded Hajj as preparing. What, if anything, would you like to notice next?';
  static const pastSalahEntryNote =
      'This day is stored. Tap Edit to change it, then Save. Unanswered is not missed.';
  static const applicationReflectionIntroTitle = 'Application Reflection';
  static const firstLookDoorTitle = 'This recorder is yours';
  static const firstLookDoorPrivate =
      'This is a private recorder. It does not score your worship, keep a streak, or issue a ruling.';
  static const firstLookDoorEmpty =
      'An empty mark is not missed. You can save a day with unanswered rows.';
  static const firstLookDoorSeason =
      'Home shows Salah, Qur’an, Hadith, Character, Rights, and Charity. This season starts with a short list; the rest stays in collapsed bands and Settings.';
  static const firstLookStartBlank = 'Start with a quiet week';
  static const firstLookShowSample = 'Show sample days';
  static const seePonderExplore = 'SEE → PONDER → EXPLORE';
  static const sampleDataNotice =
      'Sample/demo records are visible. They stay until you archive them.';
  static const archiveSamplePrompt =
      'Would you like to archive the sample records and use only your own records?';
  static const settingsTitle = 'Settings';
  static const aboutMuhasabah = 'About Private Muhasabah';
  static const faqTitle = 'FAQ';
  static const faqNote =
      'Clarifications only. Not advice, scores, or a verdict.';
  static const faqSettingsNote = 'Clarifications only';
  static const accountAndData = 'Account & data';
  static const developerSampleData = 'Developer & sample data';
  static const applicationSection = 'Application';
  static const privacySection = 'Privacy';
  static const dataManagement = 'Developer & sample data';
  static const appearancePreferences = 'Application';
  static const appearance = 'Appearance';
  static const appearanceNote = 'System, light, dark';
  static const textSize = 'Text size';
  static const textSizeNote = 'Follows device scale';
  static const onDeviceStorage = 'On-device storage';
  static const onDeviceStorageNote =
      'Days stay on this phone. No account, no telemetry, and no cloud copy. Android backup of this app is off. Delete is not forensic erasure.';
  static const privacyBody =
      'Default: local-first and offline. No telemetry, ads, cloud AI, or remote analytics in core functionality.\n\nThe phone lock is the main protection if the device is lost. Optional Unlock with this device asks for this phone’s PIN, pattern, or biometrics before the app is shown. Private Muhasabah does not store a separate password.\n\nThe app does not encrypt the files on disk. The app does not claim encryption-at-rest, forensic deletion, or absolute confidentiality.\n\nAnyone who can open an unlocked phone can read the days if Unlock with this device is off.';
  static const appLockTitle = 'Unlock with this device';
  static const appLockNote =
      'Uses this phone’s PIN, pattern, or biometrics. Private Muhasabah does not store a separate password. This does not encrypt files. It only asks before showing the app.';
  static const appLockBody =
      'Private Muhasabah uses this phone’s PIN, pattern, or biometrics. This does not encrypt files.';
  static const appLockUnlock = 'Unlock';
  static const appLockWaiting = 'Waiting…';
  static const appLockReason = 'Unlock Private Muhasabah on this device';
  static const appLockUnavailable =
      'This phone has no PIN, pattern, or biometrics to use.';
  static const manageCheckInsNote = 'Edit or remove saved days';
  static const myResponseSettingsNote = 'Private notes, optional';
  static const firstDayOfWeek = 'First day of week';
  static const firstDayOfWeekNote =
      'Changes how weeks are shown. Saved records are not altered.';
  static const calendar = 'Calendar';
  static const calendarNote =
      'Changes how dates are shown. Uses the civil Islamic calendar when Islamic is selected; moon sighting may differ by a day. Saved records are not altered.';
  static const visibleDomains = 'Domains';
  static const activitiesTitle = 'Activities';
  static const activitiesNote =
      'Salah check-in list. Shared mark colour is the default. Optional activity colours name the recorded Salah choice and the Qur’an Journey group. Not a score.';
  static const salahMarkColour = 'Salah mark colour';
  static const salahMarkShared = 'Shared (current)';
  static const salahMarkActivityColours = 'Activity colours';
  static const salahMarkActivityNote =
      'Colour names the recorded Salah choice or Qur’an Journey group. It does not rank spirituality or tell you what to do next. Other domains keep the shared mark colour.';
  static const visibleDomainsNote =
      'Choose which domains appear on Home, Review, and today’s check-in. This season’s mix is on the same screen. Hidden domains keep any saved records. You can show them again later. Recorded days still shows what was stored.';
  static const shownDomainsNote =
      'Choose which domains appear on Home, Review, and today’s check-in. Hidden domains keep any saved records. You can show them again later. Recorded days still shows what was stored.';
  static const thisSeasonsMix = 'This season’s mix';
  static const personalMix = 'Personal mix';
  static const personalMixNote =
      'Where I want to notice this season among the domains shown above. Home and today’s check-in show one mix domain at a time. Review still shows every visible domain. Not a score. Does not rewrite saved days.';
  static const mixNotShownInDomains = 'Not shown in Domains';
  static const mixNotShownNote =
      'Off Home, Review, and today’s check-in until you show this domain above. The mix is kept.';
  static const mixDomainOffHome = 'Off Home until shown above';
  static const mixKeptUntilDomainsShown =
      'Kept in the mix. Those rows appear on Home when you show the related domains above.';
  static String mixKeptUntilDomainShown(String domain) =>
      'Kept in the mix. It appears on Home when you show $domain above.';
  static String showDomainAction(String domain) => 'Show $domain';
  static const personalMixAlsoRecorded = 'Also recorded today';
  static const personalMixSeasonPrefix = 'This season I am noticing';
  static const personalMixShortListNote =
      'A short list is easier to notice. This is not a score.';
  static const selectAllDomains = 'All domains';
  static const basicAkhlaqDomains = 'Salah, Qur’an & Akhlaq';
  static const basicAkhlaqDomainsNote =
      'Shows Salah & Prayer Quality, Qur’an Engagement, Hadith & Living Sunnah, Character & Morals (Akhlaq), Rights of Others (Huquq al-Ibad), and Charity. Knowledge & Beneficial Speech, Time & Barakah, Physical Health & Energy, Wealth & Stewardship, Ummah, Dhikr & Dua, Fasting, and Hajj stay hidden unless you add them.';
  static const customSelectionSets = 'Custom selection sets';
  static const customSelectionSetsNote =
      'Save this screen’s domains and mix into Custom #1, #2 or #3. Activate a set to use it. Overlap is allowed. Saved days are not changed.';
  static const customSlotActivate = 'Activate';
  static const customSlotSave = 'Save current selection';
  static const customSlotRename = 'Rename';
  static const customSlotActive = 'Active';
  static const customSlotModified = 'Modified';
  static const customSlotSaved = 'Saved';
  static const customSlotRenameTitle = 'Name this custom set';
  static const customSlotRenameHint = 'Optional short name';
  static const cancel = 'Cancel';
  static const activateModifiedTitle = 'Replace current selection?';
  static const activateModifiedBody =
      'You have unsaved changes to the current selection. Activating this set replaces them. The saved custom sets are not deleted.';
  static const activateModifiedAction = 'Activate';
  static const clearAllSelections = 'Clear all selections';
  static const clearAllSelectionsTitle = 'Clear current selections?';
  static const clearAllSelectionsBody =
      'This clears the domains and mix shown now, including Salah. Custom #1, #2 and #3 and all saved days stay as they are.';
  static const clearAllSelectionsAction = 'Clear';
  static const lunarWhiteDaysNote =
      'Civil Hijri 13, 14 and 15 are highlighted so White Days are easier to locate. This does not record a fast or tell you to fast.';
  static const marksGuide = 'Guide';
  static const marksGuideTitle = 'Marks Guide';
  static const marksGuideIntro =
      'These marks show what was recorded.\n\nThey do not measure spirituality, worth, rank, achievement, success or failure.\n\nMissing records are not treated as missed.\n\nMarks share one colour. The card wash identifies the domain.';
  static const currentWeek = 'Current week';
  static const homeDomainPillsNote = 'Domains on Home. Not a score.';
  static const checkInDomainPillsNote =
      'Domains on this check-in. Not a score.';
  static String previousDomain(String name) => 'Previous, $name';
  static String nextDomain(String name) => 'Next, $name';
  static const noPreviousDomain = 'No previous domain';
  static const noNextDomain = 'No next domain';
  static const patternsNoticed = 'Patterns Noticed';
  static const patternsNoticedNote =
      'Observations from what you recorded in visible domains and this season’s mix. Not improvement, decline, or a score.';
  static const viewEvidence = 'View evidence';
  static const situationNotesTitle = 'Context notes';
  static const situationNotesNote =
      'Optional. You authored these. They are not causes and are not interpreted automatically.';
  static const hadithMemorisationFocus = 'Current Memorisation Focus';
  static const factorsYouNoticed = 'Factors you noticed';
  static const recordedFactors = 'Recorded factors';
  static const meaningFillsRecitation =
      'Recitation with Meaning as engagement also records Recitation as engagement for this day.';
  static const recitationLockedByMeaning =
      'Recitation with Meaning is recorded as engagement today. Change that first to record Recitation as not done or unanswered.';
  static const quranStageNote =
      'Colour is the Journey group when activity colours are on. The letter is the activity. Marks share one colour by default. Not a spiritual score.';
  static const quranCheckInIntro =
      'Record the activity for each row. Recitation with Meaning as engagement also records Recitation. Other rows stay independent. Home records the Journey group and activity on the week grid. Application Reflection is not recorded here.';
  static const quranJourney = 'Qur’an Journey';
  static const quranDayLevel = 'This group';
  static const quranDayActivity = 'Activity';
  static const quranDayNote = 'Note';
  static const quranDayNone = 'None';
  static const quranDayNoActivity = 'No activity';
  static const quranDayUnanswered = 'No answer recorded';
  static const personalReflection = 'Personal Reflection';
  static const consciousApplicationNote =
      'Practical relevance records that you noticed a possible connection to daily life. It is not evidence of action, implementation, obedience, or completion of a Response. It is not Application Reflection.';
  static const personalAspirations = 'Personal Aspirations';
  static const reflectionPreferences = 'Reflection Preferences';
  static const reflectionsQuotations = 'Reflections & Quotations';
  static const baselinesTitle = 'Baselines';
  static const baselinesNote =
      'Baselines store recorded patterns only. They are not scores, success rates, or achievements.';
  static const aspirationsNote =
      'Aspirations are yours. They are optional. They are never scored, graded, or marked achieved or failed.';
  static const quotationCadence = 'Quotation cadence';
  static const quotationCadenceNote =
      'Quotes rotate by calendar. They are not chosen from your records.';
  static const reflectionOfTheWeek = 'Reflection of the Week';
  static const noticedThisWeek = 'Noticed This Week';
  static const noticedThisWeekNote =
      'Observation only. Not a comparison, trend, or judgment. Follows Domains and Personal mix on Home.';
  static const weeklyJournalTitle = 'This week I noticed…';
  static const weeklyJournalNote =
      'Optional. Stored on this device. Not analysed and not scored.';
  static const viewSource = 'View source';
  static const saveQuoteToResponse = 'Save to my response';
  static const youRecordedColon = 'You recorded:';
}
