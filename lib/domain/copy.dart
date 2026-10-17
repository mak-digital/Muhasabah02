import 'domain_briefing.dart';

class Copy {
  static const appName = 'Private Muhasabah';
  static const appSlogan = 'Your record, not a ruling.';
  static const appNotice = 'Notice your day to improve. Keep it yours.';
  static const homeCheckIn = 'Start today’s check-in';
  static const today = 'TODAY';
  static String todayHeading(String weekday, String dateLine) =>
      'TODAY : $weekday, $dateLine';
  static const activeDomainAndMix = 'ACTIVE DOMAIN & MIX';
  static String mixRowsRecorded(int recorded, int total) {
    if (total <= 0) return 'No mix rows';
    if (recorded <= 0) return 'None of $total recorded';
    if (recorded >= total) return 'All $total recorded';
    return '$recorded of $total recorded';
  }

  static String mixRowsCount(int recorded, int total) {
    if (total <= 0) return '0 of 0';
    return '$recorded of $total';
  }

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
  static const quickTapNoteTitle = 'Busy day';
  static const previousDay = 'Previous day';
  static const nextDay = 'Next day';
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
  static const unsavedResponseTitle = 'Unsaved response';
  static const unsavedResponseBody =
      'You have unsaved changes. They have not been stored.';
  static const unsavedResponseSave = 'Save this response';
  static const unsavedResponseContinue = 'Continue editing';
  static const unsavedResponseDiscard = 'Discard changes';
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
  static String domainActionsTitle(String domain) =>
      '$domain actions you listed';
  static const washAboutTitle = 'About this list';
  static const aboutThisDomain = 'About this domain';
  static const progressMarksTitle = 'About these marks';
  static const domainActionsNote =
      'Your list. Not a score, reminder, or prescription. Stored on this device.';
  static const openActionRegister = 'Open Action Register';
  static const closeActionRegister = 'Close';
  static String actionRegisterTitle(String domain) => '$domain action register';
  static const actionRegisterNote =
      'Active actions stay at the top. Closed and deleted actions remain here until you select them and delete them from this register.';
  static const actionSelectAll = 'Select all';
  static const actionDeleteSelected = 'Delete';
  static const actionRegisterEmpty = 'No actions in the register.';
  static const actionNothingSelected = 'Select an action first.';
  static const actionConfirmPermanentDelete =
      'Remove the selected actions from this device? This cannot be undone.';
  static const actionConfirmPermanentDeleteAction = 'Remove';
  static const addAction = '+ add Action';
  static const saveListedAction = 'Save action';
  static const actionField = 'Action';
  static const actionTargetDate = 'Target date';
  static const actionPriority = 'Priority';
  static const actionPrioritySoon = 'High';
  static const actionPriorityWeek = 'Medium';
  static const actionPriorityLater = 'Low';
  static const actionActive = 'Active';
  static const actionClosed = 'Closed';
  static const actionDeleted = 'Deleted';
  static const actionStatusColumn = 'Active / Closed / Deleted';
  static const parkSettledAction = 'Move off this list';
  static const actionEmpty = 'No active actions listed.';
  static const actionNeedsText = 'Write the action before adding it.';
  static const actionLimitReached =
      'Close or delete an active action before listing another. At most five stay listed.';
  static const closeListedAction = 'Close action';
  static const reopenAction = 'Reopen';
  static const deleteAction = 'Delete';
  static const actionCircleMenu = 'Action options';
  static const actionCompletedClosed = 'Completed / Closed';
  static const actionInProgressActive = 'In progress / Active';
  static const actionEdit = 'Edit';
  static const saveEditedAction = 'Save changes';
  static const moveActionUp = 'Move up';
  static const moveActionDown = 'Move down';
  static const addDeveloperNote = '+ add Note';
  static const developerNotesTitle = 'Note to the developer';
  static const developerNotesNote =
      'About this domain. Stored locally with a serial number. The app does not send mail. Open the register to edit, delete, or download.';
  static const openNotesRegister = 'Open Note Register';
  static const notesRegisterTitle = 'Notes to the developer';
  static const notesRegisterNote =
      'Edit a note if you need to change it. Select notes and delete them before download if they should not be shared.';
  static const notesRegisterEmpty = 'No notes in the register.';
  static const notesConfirmPermanentDelete =
      'Remove the selected notes from this device? They will not be in the download. This cannot be undone.';
  static const notesConfirmPermanentDeleteAction = 'Remove';
  static const editDeveloperNote = 'Edit';
  static const developerNotesPrompt = 'What should we know?';
  static const saveDeveloperNote = 'Save note';
  static const downloadDeveloperNotes = 'Download all notes';
  static const copyDeveloperNotes = 'Copy all notes';
  static const developerNoteNeedsText = 'Write the note before saving.';
  static const noDeveloperNotes =
      'No notes saved yet. Write one above, then save.';
  static const developerNotesCopied = 'Copied. Paste into mail if you wish.';
  static String developerNoteSaved(String serial, String domain, String date) =>
      'Saved as $serial · $domain · $date.';
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
  static const recognitionTitle = 'Recognition';
  static const recognitionSevenDay =
      'Recognition is available for 30-day and 90-day views. It describes recorded context; it does not explain causes.';
  static const recognitionGuard =
      'These lines describe what appeared in your recorded context. They do not say that a factor caused an outcome.';
  static const recognitionNoPatternsTitle = 'No descriptive patterns yet';
  static const recognitionNoPatternsBody =
      'Patterns appear only when enough optional context is recorded across distinct dates.';
  static const recognitionNoEligibleTitle = 'No included Qur’an practices';
  static const recognitionNoEligibleBody =
      'This mix does not include Qur’an practices that Recognition can describe. Stored rows stay unchanged. Unanswered is not missed.';
  static String recognitionCoverage(int savedDays, int windowDays) =>
      'This $windowDays-day window: $savedDays of $windowDays days have a saved check-in. Unanswered rows are not missed.';
  static const edit = 'Edit';
  static String get akhlaqObservationNote => akhlaqBriefing.plainText;
  static const akhlaqStruggleNote = 'Struggle note';
  static const akhlaqStruggleHint =
      'Optional, about yourself only. Not a score. Example: I was impatient today, but I caught myself. Or: I reached for it, then I stopped.';
  static const akhlaqStruggleFieldHint = 'About yourself only. Not a score.';
  static const akhlaqFollowUpNote =
      'Optional. Stored. Never causes, completion, or scores. Not a character grade.';
  static const akhlaqWhereDidItHappen = 'Where did it happen?';
  static const akhlaqWhatHelped = 'What helped or could help next time?';
  static const akhlaqPrivateStruggleNote = 'Private struggle note';
  static const akhlaqCheckInNote =
      'Each row stores one observation: virtue demonstrated, struggled, shortcoming recognised, corrective action, or no relevant situation. Corrective action is not the same as avoiding the original lapse. Colour names the recorded choice when activity colours are on. Unanswered is empty, not a relapse.';
  static const akhlaqNoticed = 'I noticed this in myself';
  static const akhlaqNotToday = 'I did not notice this today';
  static String get huquqObservationNote => huquqBriefing.plainText;
  static const huquqAttended = 'I attended to a right I owe';
  static const huquqNeglected = 'I neglected a right I owe';
  static const huquqFollowUpNote =
      'Optional. Stored. Never scores, ranks, or classifies a shortcoming as a religious violation. Lack of daily contact is not neglect. Reconciliation is never required where it would be unsafe.';
  static const huquqNatureOfEngagement = 'Nature of engagement';
  static const huquqOutcomeObserved = 'Outcome observed';
  static const huquqOptionalQuantity = 'Optional quantity';
  static const huquqOccasionsHint = 'Number of occasions';
  static const huquqTimeSpentHint = 'Approximate time spent, if relevant';
  static const huquqPrivateReflection = 'Private reflection';
  static const huquqReflectionHint =
      'About your own conduct only. No names or identifying details required.';
  static const huquqCheckInNote =
      'Each row stores one observation: a positive action, partial effort, a recognised shortcoming, a corrective step, or no applicable situation. Colour names the recorded choice when activity colours are on. Unanswered is empty, not neglect. Optional follow-ups are provenance, not a relationship score.';
  static String get knowledgeObservationNote => knowledgeBriefing.plainText;
  static const knowledgeNoticed = 'I noticed this in myself';
  static const knowledgeNotToday = 'I did not notice this today';
  static const knowledgeFollowUpNote =
      'Optional. Stored. Never scores learning, intelligence, or religious merit. Reading, asking, teaching, or creating does not prove the information is correct. AI-assisted learning is not treated as verified.';
  static const knowledgeTypeOfKnowledge = 'Type of knowledge or activity';
  static const knowledgeSourceOfLearning = 'Source of learning';
  static const knowledgeReliability = 'Reliability / verification';
  static const knowledgeUnderstanding = 'Understanding';
  static const knowledgeApplication = 'Application or outcome';
  static const knowledgeOptionalQuantity = 'Optional quantity';
  static const knowledgeMinutesHint =
      'Approximate minutes. Not a measure of knowledge quality.';
  static const knowledgePrivateReflection = 'Private reflection';
  static const knowledgeReflectionHint =
      'What did I learn? What do I still need to verify? How could I apply it beneficially? Did I correct something I previously misunderstood?';
  static const knowledgeCheckInNote =
      'Each row stores one observation: beneficial activity, partial engagement, a recognised gap, a correction, or no relevant situation. Colour names the recorded choice when activity colours are on. Unanswered is empty, not ignorance. Optional follow-ups are provenance, not a grade.';
  static String get timeObservationNote => timeBriefing.plainText;
  static const timeNoticed = 'I noticed this in myself';
  static const timeNotToday = 'I did not notice this today';
  static const timeFollowUpNote =
      'Optional. Stored as you report it. Not a productivity score, screen-time contest, or a measure of barakah. Recreation is not automatically wasted time. Illness, caregiving, and needed rest are not failings.';
  static const timeActivityContext = 'Activity context';
  static const timeMainChallenge = 'Main challenge noticed';
  static const timeWhatHelped = 'What helped?';
  static const timeObservableOutcome = 'Observable outcome';
  static const timeOptionalQuantity = 'Optional quantitative information';
  static const timeQuantityHint =
      'A count or approximate minutes. Not a quality or barakah measure.';
  static const timeCheckInNote =
      'Each row stores one observation: beneficial action, partial effort, a recognised lapse, a corrective adjustment, or no relevant situation. Corrected is not ranked above acted. Colour names the recorded choice when activity colours are on. Unanswered is empty, not wasted time.';
  static String get healthObservationNote => healthBriefing.plainText;
  static const healthNoticed = 'I noticed this in myself';
  static const healthNotToday = 'I did not notice this today';
  static const healthCheckInNote =
      'Each row stores one observation: care taken, partial or mixed care, a difficulty noticed, avoidable neglect, an adjustment, circumstances beyond control, no relevant need, or prefer not to record. Prefer not to record is not unanswered. Colour names the recorded choice when activity colours are on. Unanswered is empty, not a failing of the body.';
  static String get wealthObservationNote => wealthBriefing.plainText;
  static const wealthNoticed = 'I noticed this in myself';
  static const wealthNotToday = 'I did not notice this today';
  static const wealthCheckInNote =
      'Each row stores one observation: a reported action, a check or clarification, an unresolved concern, no relevant activity, or prefer not to record. Prefer not to record is not unanswered. No relevant activity is not a failure. Colour names the recorded choice when activity colours are on. Unanswered is empty, not a failing of provision.';
  static String get ummahObservationNote => ummahBriefing.plainText;
  static const ummahNoticed = 'I noticed this in myself';
  static const ummahNotToday = 'I did not notice this today';
  static String get charityObservationNote => charityBriefing.plainText;
  static String get fastingObservationNote => fastingBriefing.plainText;
  static const charityNoticed = 'I noticed this in myself';
  static const charityNotToday = 'I did not notice this today';
  static const charityCheckInNote =
      'Each row stores one observation: a reported gift or support, an intended or arranged effort, a recognised need without the wished action, no relevant opportunity, or prefer not to record. Prefer not to record is not the same as not recorded. No relevant opportunity is not withheld charity. Zakat is a separate status, not a calculator and not a daily missed obligation. Colour names the recorded choice when activity colours are on. Not recorded is empty.';
  static const ummahCheckInNote =
      'Each row stores one observation: a reported action, remote or spoken effort, an opportunity noticed without the wished action, no relevant opportunity, or prefer not to record. Prefer not to record is not unanswered. No relevant opportunity is not neglect of the Ummah. Colour names the recorded choice when activity colours are on. Unanswered is empty, not isolation.';
  static String get hadithObservationNote => hadithBriefing.plainText;
  static const hadithNoticed = 'I noticed this in myself';
  static const hadithNotToday = 'I did not notice this today';
  static const hadithDurationNote =
      'ENGAGED with Hadith holds four rows: read and/or listened, memorization or revision, study circle or discussion, and lived or noticed in others. The first three use the same duration steps as Qur’an Engagement. Lived /Noticed others is how a teaching reached life today — not a revival score.';
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
      'Home shows Salah, Qur’an, and Dhikr. This season starts with a short list; the rest stays in collapsed bands and Settings.';
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
  static const applicationSection = 'Preferences';
  static const privacySection = 'Privacy';
  static const dataManagement = 'Developer & sample data';
  static const appearancePreferences = 'Preferences';
  static const appearance = 'Appearance';
  static const appearanceNote = 'System, light, dark';
  static const textSize = 'Text size';
  static const textSizeNote = 'Follows device scale';
  static const arabicScript = 'Arabic script';
  static const arabicScriptNote =
      'Face and size for Arabic in Learn & Practice. Uthmani is the mushaf-style face for the Qur’an list. Not a recitation score, and not a device-wide text size.';
  static const arabicScriptSmaller = 'Smaller Arabic';
  static const arabicScriptLarger = 'Larger Arabic';
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
  static const ramadanCalendarOffset = 'Ramadan dates';
  static const ramadanCalendarOffsetNote =
      'Ramadan observation rows follow civil Hijri month 9. If local moon sighting differs by a day, choose one day earlier or later. This is not a legal ruling, and it does not change saved days.';
  static const ramadanOffsetCivil = 'Civil tabular dates (default)';
  static const ramadanOffsetEarlier = 'Start Ramadan one day earlier';
  static const ramadanOffsetLater = 'Start Ramadan one day later';
  static const showFastingRamadanHistory = 'Show all Fasting rows for review';
  static const showFastingRamadanHistoryNote =
      'Ramadan rows appear in Ramadan. Voluntary and make-up rows appear outside it. Turn this on to see both at any time for review or testing. Days that already have a mark still show those rows.';
  static const visibleDomains = 'Domains in Focus';
  static const activitiesTitle = 'Activities & legend';
  static const activitiesNote =
      'Salah check-in list. Shared mark colour is the default. Optional activity colours name the recorded Salah choice, the Qur’an duration step, post-fard Dhikr remembrance, Character & Morals, Rights of Others, Charity, Knowledge & Beneficial Speech, Time & Barakah, Physical Health & Energy, Wealth & Stewardship, Ummah, and Fasting observations. Not a score.';
  static const salahMarkColour = 'Salah mark colour';
  static const salahMarkShared = 'Shared (current)';
  static const salahMarkActivityColours = 'Activity colours';
  static const salahMarkActivityNote =
      'Colour names the recorded Salah choice, Qur’an duration step, post-fard Dhikr remembrance, Character & Morals, Rights of Others, Charity, Knowledge & Beneficial Speech, Time & Barakah, Physical Health & Energy, Wealth & Stewardship, Ummah, or Fasting observation. It does not rank spirituality or tell you what to do next. Other domains keep the shared mark colour.';
  static const howAttentiveWasI = 'How attentive was I';
  static const dhikrPostFardNote =
      'Post-fard Salah Adhkar records remembrance after each fard prayer. Remembrance with action uses the same blue as congregation on time. The other steps twin the remaining Salah activity colours. How attentive was I is optional provenance, not a khushu’ score.';
  static const visibleDomainsNote =
      'Choose which domains belong in this profile. This season’s mix, on the same screen, is a subset of those domains: bands and rows to notice. Leave a domain or row unselected if it does not apply. Home, Review, Progress, check-in, Quick Tap, and Recorded days follow the mix among the domains shown. Hidden domains keep any saved records.';
  static const shownDomainsNote =
      'Choose which domains belong in this profile. Leave a domain unselected if it does not apply. Home, Review, and today’s check-in follow the domains shown here and the mix below. Hidden domains keep any saved records.';
  static const thisSeasonsMix = 'This season’s mix';
  static const personalMix = 'Personal mix';
  static const personalMixNote =
      'The mix is a subset of the domains shown above: which bands and rows to notice this season. Leave a row unselected if it does not apply. Home, Review, Progress, today’s check-in, and Quick Tap show this mix. Not a score. Does not rewrite saved days.';
  static const mixNotShownInDomains = 'Not shown above';
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
      'A short list is easier to notice. Rows left unselected stay out of this season. This is not a score.';
  static const selectAllDomains = 'All domains';
  static const basicDhikrDomains = 'Salah, Qur’an & Dhikr';
  static const basicDhikrDomainsNote =
      'Shows Salah & Prayer Quality, Qur’an Engagement, and Dhikr & Dua. Hadith & Living Sunnah, Rights of Others, Charity, Knowledge & Beneficial Speech, Time & Barakah, Physical Health & Energy, Wealth & Stewardship, Ummah, Character & Morals (Akhlaq), Fasting, and Hajj stay hidden unless you add them.';
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
  static const clearAllSelections = 'Clear All';
  static const clearAllSelectionsTitle = 'Clear current selections?';
  static const clearAllSelectionsBody =
      'This clears the domains and mix shown now, including Salah. Custom #1, #2 and #3 and all saved days stay as they are.';
  static const clearAllSelectionsAction = 'Clear';
  static const clearCustomSlotTitle = 'Clear this custom set?';
  static const clearCustomSlotBody =
      'This clears the saved domains and mix in this custom set. Saved days stay as they are.';
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
  static String practiceLearnTitle(String domainShort) =>
      'LEARN & PRACTICE ($domainShort)';
  static String get practiceSalahTitle => practiceLearnTitle('Salah');
  static const practiceSalahNote =
      'Qur’an verses and authentic hadith that encourage the prayers on this card, grouped as on Home. Presence of heart is not scored. Add one if you want to learn it and bring it into practice. This is not a khushu’ score, congregation requirement, or daily grade.';
  static const addPracticeSalah = '+ add reminder';
  static String get openPracticeSalahRegister =>
      openPracticeLearnRegister('Salah');
  static String get practiceSalahRegisterTitle =>
      practiceLearnRegisterTitle('Salah');
  static const practiceSalahRegisterNote =
      'Your list. Date added, source, content, prayer, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a khushu’ score.';
  static const practiceSalahRegisterEmpty = 'No reminders in the register.';
  static const practiceSalahConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceQuranTitle => practiceLearnTitle('Qur’an');
  static const practiceQuranNote =
      'A repository of widely used verses for daily reading and memorization — Al-Fātiḥah, openings of often-recited surahs, Āyat al-Kursī, the close of Al-Baqarah, short prayer surahs, and duas said in worship. Skim with the arrows and add one if you want to learn it. This is not a khushu’ score, recitation streak, or Knowledge’s residual.';
  static const addPracticeQuran = '+ add verse';
  static String get openPracticeQuranRegister =>
      openPracticeLearnRegister('Qur’an');
  static String get practiceQuranRegisterTitle =>
      practiceLearnRegisterTitle('Qur’an');
  static const practiceQuranRegisterNote =
      'Your list. Date added, source, content, topic, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a khushu’ score.';
  static const practiceQuranRegisterEmpty = 'No verses in the register.';
  static const practiceQuranConfirmDelete =
      'Remove the selected verses from this device? This cannot be undone.';
  static const practiceQuranAlreadyAdded = 'Already in your register';
  static const practiceQuranAdded = 'Added to your register.';
  static const practiceQuranNothingSelected = 'Select a verse first.';
  static const bringQuranVerse = 'Bring a verse';
  static const bringQuranVerseTitle = 'Bring a verse into Learn';
  static const bringQuranSearchHint =
      'Search by topic or a few words — for example kursi, parents, ease.';
  static const bringQuranSearchEmpty =
      'No matching verse in this list. Try other words, or use a chapter and verse if you have it.';
  static const bringQuranOrReference = 'Or if you have the exact reference';
  static const bringQuranVerseHint =
      'Surah and verse, or a short range — for example 2:255 or 2:255–257.';
  static const bringQuranUrlHint =
      'Or paste a quran.com link, for example quran.com/2/255.';
  static const bringQuranLookUp = 'Look up';
  static const bringQuranSave = 'Save to Learn';
  static const bringQuranSaveReferenceOnly = 'Save the reference only';
  static const bringQuranCouldNotFetch =
      'Could not load the Arabic and English while you are offline. Save the reference only, or try again when you are online.';
  static const bringQuranInvalid =
      'Enter a chapter and verse, a short range, or a quran.com link.';
  static const bringQuranTooLong =
      'Bring a short passage — up to 7 verses at a time.';
  static const bringQuranAlreadyOnLearn =
      'That verse is already on your Learn list.';
  static const bringQuranAlreadyOnLearnCheck =
      'This verse is already on your Learn list. Check the words below if you want to compare, then choose whether to save.';
  static const bringQuranDontSave = 'Don’t save';
  static const bringQuranSaveAnyway = 'Save anyway';
  static const bringQuranKeptOnLearn =
      'Already on your Learn list. Nothing extra was added.';
  static const bringQuranSaved = 'Added to your Learn list.';
  static const bringQuranReferenceSaved =
      'Reference saved. Words will fill when you look it up online.';
  static const bringThisVerseIntoLearn = 'Bring this verse into Learn';
  static String get practiceHadithTitle => practiceLearnTitle('Hadith');
  static const practiceHadithNote =
      'A built-in list of daily-practice hadith and related supplications, with Arabic, transliteration, and translation. Add one if you want to learn it and bring it into practice. This is not a checklist, score, or revival programme.';
  static const addPracticeHadith = '+ add Hadith';
  static String openPracticeLearnRegister(String domainShort) =>
      'Learn & Practice ($domainShort) Register';
  static String get openPracticeHadithRegister =>
      openPracticeLearnRegister('Hadith');
  static String practiceLearnRegisterTitle(String domainShort) =>
      'Learn & Practice ($domainShort) Register';
  static String get practiceHadithRegisterTitle =>
      practiceLearnRegisterTitle('Hadith');
  static const practiceHadithRegisterNote =
      'Your list. Date added, source, content, topic, and whether you are learning it, have learnt it, are practicing it, or living it. Select and delete if it should not stay here. This does not fill Living Sunnah.';
  static const practiceHadithRegisterEmpty = 'No hadith in the register.';
  static const practiceHadithAlreadyAdded = 'Already in your register';
  static const bringHadith = 'Bring a hadith';
  static const bringHadithTitle = 'Bring a hadith into Learn';
  static const bringHadithSearchHint =
      'Search by topic or a few words — for example intention, mother, anger.';
  static const bringHadithSearchEmpty =
      'No matching hadith in this list. Try other words, or use a collection and number if you have it.';
  static const bringHadithOrReference = 'Or if you have the exact reference';
  static const bringHadithHint =
      'Collection and number — for example Bukhari 6312 or Muslim 234.';
  static const bringHadithUrlHint =
      'Or paste a sunnah.com link, for example sunnah.com/bukhari:6312.';
  static const bringHadithInvalid =
      'Enter a collection and number, or a sunnah.com link.';
  static const bringHadithAlreadyOnLearn =
      'That hadith is already on your Learn list.';
  static const bringHadithAlreadyOnLearnCheck =
      'This hadith is already on your Learn list. Check the words below if you want to compare, then choose whether to save.';
  static const bringHadithDontSave = 'Don’t save';
  static const bringHadithSaveAnyway = 'Save anyway';
  static const bringHadithKeptOnLearn =
      'Already on your Learn list. Nothing extra was added.';
  static const bringHadithSaved = 'Added to your Learn list.';
  static const bringHadithCouldNotFetch =
      'Could not load the Arabic and English while you are offline. Save the reference only, or try again when you are online.';
  static const bringHadithReferenceSaved =
      'Reference saved. Words will fill when you look it up online.';
  static const bringThisHadithIntoLearn = 'Bring this hadith into Learn';
  static const practiceHadithAdded = 'Added to your register.';
  static const practiceStatusLearning = 'Learning';
  static const practiceStatusLearnt = 'Learnt';
  static const practiceStatusPracticing = 'Practicing';
  static const practiceHadithStatusHabit = 'Living it';
  static const practiceDhikrStatusHabit = 'Habit';
  static const practiceHadithConfirmDelete =
      'Remove the selected hadith from this device? This cannot be undone.';
  static const practiceHadithNothingSelected = 'Select a hadith first.';
  static String get practiceDhikrTitle => practiceLearnTitle('Dhikr');
  static const practiceDhikrNote =
      'Widely used authentic dhikr and dua, grouped by occasion. Highly recommended post-prayer, morning, and evening sets are listed together first. Add one if you want to learn it and bring it into practice. This is not a target, score, or prescription.';
  static const addPracticeDhikr = '+ add Dhikr';
  static String get openPracticeDhikrRegister =>
      openPracticeLearnRegister('Dhikr');
  static String get practiceDhikrRegisterTitle =>
      practiceLearnRegisterTitle('Dhikr');
  static const practiceDhikrRegisterNote =
      'Your list. Date added, source, content, occasion, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a dhikr target.';
  static const practiceDhikrRegisterEmpty = 'No dhikr in the register.';
  static const practiceDhikrConfirmDelete =
      'Remove the selected dhikr from this device? This cannot be undone.';
  static String get practiceAkhlaqTitle => practiceLearnTitle('Character');
  static const practiceAkhlaqNote =
      'Qur’an verses and authentic hadith that encourage the behaviours on this card, grouped as on Home. Highly recommended reminders sit together first. Add one if you want to learn it and bring it into practice. This is not a character grade, score, or prescription.';
  static const addPracticeAkhlaq = '+ add reminder';
  static String get openPracticeAkhlaqRegister =>
      openPracticeLearnRegister('Character');
  static String get practiceAkhlaqRegisterTitle =>
      practiceLearnRegisterTitle('Character');
  static const practiceAkhlaqRegisterNote =
      'Your list. Date added, source, content, behaviour, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a character grade.';
  static const practiceAkhlaqRegisterEmpty = 'No reminders in the register.';
  static const practiceAkhlaqConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceHuquqTitle => practiceLearnTitle('Rights');
  static const practiceHuquqNote =
      'Qur’an verses and authentic hadith that encourage the rights on this card, grouped as on Home. Highly recommended reminders sit together first. Add one if you want to learn it and bring it into practice. This is not a relationship score, chore list, or prescription.';
  static const addPracticeHuquq = '+ add reminder';
  static String get openPracticeHuquqRegister =>
      openPracticeLearnRegister('Rights');
  static String get practiceHuquqRegisterTitle =>
      practiceLearnRegisterTitle('Rights');
  static const practiceHuquqRegisterNote =
      'Your list. Date added, source, content, right, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a relationship score.';
  static const practiceHuquqRegisterEmpty = 'No reminders in the register.';
  static const practiceHuquqConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceKnowledgeTitle => practiceLearnTitle('Knowledge');
  static const practiceKnowledgeNote =
      'Qur’an verses and authentic hadith that encourage the rows on this card, grouped as on Home. This is other learning and speech — not Qur’an, Hadith, or Character’s tone. A single fact is enough. Add one if you want to learn it and bring it into practice. This is not a learnedness grade, study-hour badge, or prescription.';
  static const addPracticeKnowledge = '+ add reminder';
  static String get openPracticeKnowledgeRegister =>
      openPracticeLearnRegister('Knowledge');
  static String get practiceKnowledgeRegisterTitle =>
      practiceLearnRegisterTitle('Knowledge');
  static const practiceKnowledgeRegisterNote =
      'Your list. Date added, source, content, row, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a learnedness grade.';
  static const practiceKnowledgeRegisterEmpty = 'No reminders in the register.';
  static const practiceKnowledgeConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceTimeTitle => practiceLearnTitle('Time');
  static const practiceTimeNote =
      'Qur’an verses and authentic hadith that encourage the eight observations on this card, grouped as on Home. They are independent reminders, not eight daily achievements. Add one if you want to learn it and bring it into practice. This is not a productivity score, schedule, streak, or estimate of barakah.';
  static const addPracticeTime = '+ add reminder';
  static String get openPracticeTimeRegister =>
      openPracticeLearnRegister('Time');
  static String get practiceTimeRegisterTitle =>
      practiceLearnRegisterTitle('Time');
  static const practiceTimeRegisterNote =
      'Your list. Date added, source, content, practice, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a productivity score.';
  static const practiceTimeRegisterEmpty = 'No reminders in the register.';
  static const practiceTimeConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceHealthTitle => practiceLearnTitle('Health');
  static const practiceHealthNote =
      'Qur’an verses and authentic hadith that encourage the rows on this card, grouped as on Home. Each row skims a few well-known reminders (direct or indirect). Care of the body as a trust — not fitness, calories, or Time’s rest. Add one if you want to learn it and bring it into practice. This is not a body grade, hour badge, or prescription.';
  static const addPracticeHealth = '+ add reminder';
  static String get openPracticeHealthRegister =>
      openPracticeLearnRegister('Health');
  static String get practiceHealthRegisterTitle =>
      practiceLearnRegisterTitle('Health');
  static const practiceHealthRegisterNote =
      'Your list. Date added, source, content, row, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a fitness grade.';
  static const practiceHealthRegisterEmpty = 'No reminders in the register.';
  static const practiceHealthConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceWealthTitle => practiceLearnTitle('Wealth');
  static const practiceWealthNote =
      'Qur’an verses and authentic hadith that encourage the rows on this card, grouped as on Home. Earning as a trust — not net worth or giving. Giving and zakat stay on Charity. Add one if you want to learn it and bring it into practice. This is not a money score, zakat calculator, or prescription.';
  static const addPracticeWealth = '+ add reminder';
  static String get openPracticeWealthRegister =>
      openPracticeLearnRegister('Wealth');
  static String get practiceWealthRegisterTitle =>
      practiceLearnRegisterTitle('Wealth');
  static const practiceWealthRegisterNote =
      'Your list. Date added, source, content, row, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a money score.';
  static const practiceWealthRegisterEmpty = 'No reminders in the register.';
  static const practiceWealthConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceUmmahTitle => practiceLearnTitle('Ummah');
  static const practiceUmmahNote =
      'Qur’an verses and authentic hadith that encourage the rows on this card, grouped as on Home. Belonging beyond the household — not the fard, not Charity giving, and not a public check-in. Add one if you want to learn it and bring it into practice. This is not a social grade, political log, or ethnic list.';
  static const addPracticeUmmah = '+ add reminder';
  static String get openPracticeUmmahRegister =>
      openPracticeLearnRegister('Ummah');
  static String get practiceUmmahRegisterTitle =>
      practiceLearnRegisterTitle('Ummah');
  static const practiceUmmahRegisterNote =
      'Your list. Date added, source, content, row, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a social grade.';
  static const practiceUmmahRegisterEmpty = 'No reminders in the register.';
  static const practiceUmmahConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceFastingTitle => practiceLearnTitle('Fasting');
  static const practiceFastingNote =
      'Qur’an verses and authentic hadith that encourage the rows on this card, grouped as on Home. Ramadan observations are descriptive, not a ruling on validity. Voluntary and make-up noticing stays separate. Add one if you want to learn it and bring it into practice. This is not a sawm score, countdown, or prescription to fast.';
  static const addPracticeFasting = '+ add reminder';
  static String get openPracticeFastingRegister =>
      openPracticeLearnRegister('Fasting');
  static String get practiceFastingRegisterTitle =>
      practiceLearnRegisterTitle('Fasting');
  static const practiceFastingRegisterNote =
      'Your list. Date added, source, content, row, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a fasting score.';
  static const practiceFastingRegisterEmpty = 'No reminders in the register.';
  static const practiceFastingConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceHajjTitle => practiceLearnTitle('Hajj');
  static const practiceHajjNote =
      'Qur’an verses and authentic hadith that encourage the preparation row on this card. Standing status stays in Settings. Add one if you want to learn it and bring it into practice. This is not a due-date, ability calculator, countdown, or trophy.';
  static const addPracticeHajj = '+ add reminder';
  static String get openPracticeHajjRegister =>
      openPracticeLearnRegister('Hajj');
  static String get practiceHajjRegisterTitle =>
      practiceLearnRegisterTitle('Hajj');
  static const practiceHajjRegisterNote =
      'Your list. Date added, source, content, row, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a Hajj score.';
  static const practiceHajjRegisterEmpty = 'No reminders in the register.';
  static const practiceHajjConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static String get practiceCharityTitle => practiceLearnTitle('Charity');
  static const practiceCharityNote =
      'Qur’an verses and authentic hadith that encourage the rows on this card, grouped as on Home. Giving and care — a smile is sadaqah. Amounts are not recorded. Add one if you want to learn it and bring it into practice. This is not a generosity score, leaderboard, or zakat calculator.';
  static const addPracticeCharity = '+ add reminder';
  static String get openPracticeCharityRegister =>
      openPracticeLearnRegister('Charity');
  static String get practiceCharityRegisterTitle =>
      practiceLearnRegisterTitle('Charity');
  static const practiceCharityRegisterNote =
      'Your list. Date added, source, content, row, and whether you are learning it, have learnt it, are practicing it, or it has become a habit. Select and delete if it should not stay here. This is not a generosity score.';
  static const practiceCharityRegisterEmpty = 'No reminders in the register.';
  static const practiceCharityConfirmDelete =
      'Remove the selected reminders from this device? This cannot be undone.';
  static const factorsYouNoticed = 'Factors you noticed';
  static const recordedFactors = 'Recorded factors';
  static const meaningFillsRecitation =
      'Recitation with Meaning as engagement also records Recitation as engagement for this day.';
  static const recitationLockedByMeaning =
      'Recitation with Meaning is recorded as engagement today. Change that first to record Recitation as not done or unanswered.';
  static const quranStageNote =
      'Each duration step reuses a Salah activity colour. 3–5 minutes is still a recorded sitting (same light green as 5–10, empty circle). Unanswered is never inferred as not engaged. Duration is not a khushu’ score, streak, or spiritual grade. Missed colours are not used here because these rows are not fard.';
  static const quranCheckInIntroTitle = 'About these rows';
  static const quranCheckInIntro =
      'Three independent notice-rows share one duration list. Engagement is recitation, memorisation and/or revision. Understanding & reflection is meaning and/or tafsir plus pondering. Practical relevance is noticing implications or use of learnt verses — not a deed score. Unanswered is empty, not “not engaged”.';
  static const quranCheckInFactorsIntro =
      'Factors you noticed (optional). They are things you noticed — not causes. Skipping changes nothing.';
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
      'Quotes rotate by calendar. Daily uses a new quote each local day. Weekly keeps one quote for the week. Hidden removes the card. You can step to another quote; the one you stop on stays as that day’s or week’s reflection. They are not chosen from your records. The Home heading follows this choice.';
  static const reflectionOfTheWeek = 'Reflection of the Week';
  static const reflectionOfTheDay = 'Reflection of the Day';
  static const previousReflection = 'Previous reflection';
  static const nextReflection = 'Next reflection';
  static const noticedThisWeek = 'Noticed This Week';
  static const noticedThisWeekNote =
      'Observation only. Not a comparison, trend, or judgment. Follows Domains and Personal mix on Home.';
  static const weeklyJournalTitle = 'This week I noticed…';
  static const weeklyJournalNote =
      'Optional. Stored on this device. Not analysed and not scored.';
  static const viewSource = 'View source';
  static const openReflectionSource = 'Open citation';
  static const shareCitation = 'Share';
  static const citationClose = 'Close';
  static const openCitationInBrowser = 'Open in browser';
  static const previousCitationPage = 'Previous source';
  static const nextCitationPage = 'Next source';
  static String citationPageIndex(int page, int of) => '$page of $of';
  static const playRecitation = 'Play recitation';
  static const pauseRecitation = 'Pause recitation';
  static const recitationCouldNotStart =
      'Recitation could not start. Open in browser to use the site’s own player.';
  static const recitationBarNote =
      'Plays a public recitation in this app so the sound stays clear. The page is for reading. This is not a recitation score.';
  static const reflectionSourceNote =
      'Opens in this app with Close and Share. If the citation names more than one source, each has its own page — use Next or Previous. For Qur’an, Play recitation uses a public audio file in this app so playback stays clear; the page is for reading. Open in browser if you want the site’s own player. Close or Back returns here. This app does not send your records. Citation only — not a ruling.';
  static const reflectionSourceReturn = 'Close, or use Back, to return here.';
  static const reflectionSourceCouldNotOpen =
      'Nothing on this device could open that citation. The reference stays here.';
  static const saveQuoteToResponse = 'Save to my response';
  static const youRecordedColon = 'You recorded:';
}
