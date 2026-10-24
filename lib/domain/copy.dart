import 'domain_briefing.dart';

class Copy {
  static const appName = 'Private Muhasabah';
  static const openingYourRecord = 'Opening your record';
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
      'Busy day. Tiles are this season’s mix. Each tap steps the same list as check-in (Other Adhkar opens its list). Unticked stays unanswered — not missed. After unanswered, your most recorded choice comes first. Reflection can wait.';
  static const quickTapEmpty =
      'No mix rows on shown domains. Choose Domains and this season’s mix in Settings.';
  static const quickTapFajrHint = 'On time is not a khushu’ score.';
  static const homeReview = 'Review recorded experience';
  static const homeManage = 'Manage past check-ins';
  static const reviewTitle = 'Review';
  static const registryTab = 'Registry';
  static const registryTitle = 'Registry';
  static const registryTabActions = 'Action Register';
  static const registryTabHadith = 'Hadith Register';
  static const registryTabDeveloper = 'Note to Developer';
  static const registryTabHistory = 'History';
  static const registryTabActionsShort = 'Actions';
  static const registryTabHadithShort = 'Hadith';
  static const registryTabDeveloperShort = 'Developer';
  static const hadithTopicColumn = 'Topic / Added';
  static const hadithSourceColumn = 'Source';
  static const hadithStatusColumn = 'Practice';
  static const hadithSharedColumn = 'Shared';
  static const developerDomainDateColumn = 'Domain / Date';
  static String registryFilterNote({
    required String mixLabel,
    required String domains,
  }) =>
      'Showing $mixLabel: $domains. Other saved items stay on this device until those domains are in focus.';
  static const registryHistoryFilterNote =
      'Every saved check-in day is listed. Domain and mix filters apply on the other Registry tabs.';
  static const registryHadithHidden =
      'Hadith is not in your current domains and mix. Saved register items stay on this device.';
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
  static const myResponse = 'My Notes';
  static const myResponseDescription =
      'A private, optional place to write a note, question, or something you want to keep in mind.';
  static const addAResponse = '+ Add a Note';
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
  static const addReminder = 'Add Reminder';
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
  static const actionDomainDateColumn = 'Domain / Target';
  static const actionStatusShort = 'Status';
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
      'You haven’t saved any notes. Creating one is optional.';
  static const saveResponse = 'Save note';
  static const editResponse = 'Edit note';
  static const archiveResponse = 'Archive';
  static const restoreResponse = 'Restore';
  static const deleteResponse = 'Delete';
  static const noteActionReminder = 'Action reminder';
  static const noteCodeColumn = 'No.';
  static const noteDomainColumn = 'Domain';
  static const noteSourceColumn = 'Source';
  static const noteDomainSourceColumn = 'Domain / Source';
  static const noteContentColumn = 'Note';
  static const noteGeneralDomainHint = 'General / not domain specific';
  static const noteNothingSelected = 'Select a note first.';
  static const noteConfirmDelete =
      'Remove the selected notes from this device? This cannot be undone.';
  static const noteReminderSaved =
      'Saved as an action reminder on that domain’s list. Not a score or obligation.';
  static const noteReminderNeedsDomain =
      'Choose a domain for the action reminder.';
  static const noteReminderLimit =
      'That domain already has five active actions listed.';
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
      'One observation per row, about yourself only. Empty is not a relapse. Colour names the choice when activity colours are on — not a grade.';
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
      'One observation per row of a right you owe. Empty is not neglect. Do not name others’ faults. Colour names the choice when activity colours are on — not a relationship score.';
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
      'One observation per row. Empty is not ignorance. Colour names the choice when activity colours are on — not a grade.';
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
      'One observation per row. Corrected is not ranked above acted. Empty is not wasted time.';
  static String get healthObservationNote => healthBriefing.plainText;
  static const healthNoticed = 'I noticed this in myself';
  static const healthNotToday = 'I did not notice this today';
  static const healthCheckInNote =
      'One observation per row. Prefer not to record is not empty. Empty is not a failing of the body.';
  static String get wealthObservationNote => wealthBriefing.plainText;
  static const wealthNoticed = 'I noticed this in myself';
  static const wealthNotToday = 'I did not notice this today';
  static const wealthCheckInNote =
      'One observation per row. Prefer not to record is not empty. No relevant activity is not a failure.';
  static String get ummahObservationNote => ummahBriefing.plainText;
  static const ummahNoticed = 'I noticed this in myself';
  static const ummahNotToday = 'I did not notice this today';
  static String get charityObservationNote => charityBriefing.plainText;
  static String get fastingObservationNote => fastingBriefing.plainText;
  static const charityNoticed = 'I noticed this in myself';
  static const charityNotToday = 'I did not notice this today';
  static const charityCheckInNote =
      'One observation per row — no amounts or names. Prefer not to record is not empty. No relevant opportunity is not withheld charity. Zakat is a status, not a calculator.';
  static const ummahCheckInNote =
      'One observation per row. Prefer not to record is not empty. No relevant opportunity is not neglect of the Ummah.';
  static String get hadithObservationNote => hadithBriefing.plainText;
  static const hadithNoticed = 'I noticed this in myself';
  static const hadithNotToday = 'I did not notice this today';
  static const hadithDurationNote =
      'Four rows: read/listened, memorization or revision, study circle, and lived or noticed in others. Time is observational. Lived/noticed is not a revival score.';
  static String get hajjObservationNote => hajjBriefing.plainText;
  static String get productivityObservationNote =>
      productivityBriefing.plainText;
  static const hajjStatusLabel = 'Hajj standing';
  static const hajjStatusNote =
      'This is a lifetime record you set, not a ruling. The app does not decide ability or timing. A journey is optional and separate. Unsure and not applicable stay available.';
  static const hajjJourneyInvite =
      'You may keep a plan here if you want. Creating a plan does not mean you must undertake Hajj.';
  static const hajjCreateJourney = 'Create a Hajj plan';
  static const hajjJourneySection = 'My Hajj Journey';
  static const hajjReadinessSection = 'Readiness & Prerequisites';
  static const hajjCalendarSection = 'Planning Calendar';
  static const hajjFamilySection = 'Family & Companions';
  static const hajjAfterSection = 'After Hajj';
  static const hajjLearningSection = 'Readiness learning';
  static const hajjConfirmationNote =
      'Confirmed by you is not official verification. Official deadlines stay as you typed them.';
  static const hajjOfficialVerifiedLabel = 'Verified official requirement';
  static const hajjUserConfirmedLabel = 'Confirmed by user';
  static const hajjTravelerReadinessNote =
      'Each companion keeps their own passport, residence, health, and travel confirmations. Shared milestones do not copy those confirmations.';
  static const hajjNoDocumentUpload =
      'Do not upload identity documents. Notes and a source label you type are enough.';
  static const hajjDependencyCycle =
      'A milestone cannot depend on itself or on a chain that loops back.';
  static const hajjActionWindow = 'Recommended action window';
  static const hajjMilestoneTitleRequired =
      'Name this milestone before saving.';
  static const hajjMilestoneDateRequired =
      'Add an official or tentative date, or mark it as unscheduled.';
  static const hajjMilestoneDateInvalid =
      'Use YYYY-MM-DD for dates you type. The official deadline is not invented.';
  static const hajjMilestoneUnscheduled = 'Unscheduled — no date yet';
  static const hajjPastMilestones = 'Past dates';
  static const hajjBeyondHorizon = 'After this horizon';
  static const hajjUnscheduledMilestones = 'Unscheduled milestones';
  static const hajjMonthEmpty = 'No stored dates this month';
  static const hajjPlanSummarySection = 'Journey summary';
  static const hajjPathwaySection = 'Planning pathways';
  static const hajjReturnSection = 'Return scenarios';
  static const hajjPathwayConfirm = 'Confirm planning route';
  static const hajjApplyTemplates = 'Apply preparation template';
  static const hajjPathwayNotEligibility =
      'These are planning categories, not legal eligibility. Confirm a route yourself. The app does not check quota, visas, or operators.';
  static const hajjEstimateNotOfficial =
      'Suggested dates are planning estimates. Official deadlines stay as you typed them.';
  static const hajjUnusedNotRefundable =
      'Unused package services are not assumed refundable.';
  static const hajjRitesMustComplete =
      'Do not omit required Hajj rites to leave earlier.';
  static const hajjOnlineSection = 'Online assistance';
  static const hajjSourcesSection = 'Official sources';
  static const hajjProvidersSection = 'Provider information';
  static const hajjOnlineDefault =
      'Offline by default. Nothing is sent until you opt in.';
  static const hajjDemoNoLiveVerification = 'Demo — no live verification';
  static const hajjConsentLookup =
      'Allow official-source bookmarks (demonstration catalog on this device)';
  static const hajjConsentAi =
      'Allow AI-style interpretation (demonstration only; not a live model)';
  static const hajjConsentBody =
      'If you continue, only season, nationality, residence, departure country, and confirmed pathway labels may be used. Passport numbers, scans, health notes, family names, and private reflections are not sent. Live lookup stays off until a Worker URL is configured. AI is not enabled. You can turn either control off at any time.';
  static const hajjOfflineMode = 'Offline';
  static const hajjLiveMode = 'Live official-source information';
  static const hajjManualMode = 'Source requires manual verification';
  static const hajjUnavailableMode = 'Source unavailable';
  static const hajjAiDisabled = 'AI is not enabled.';
  static const hajjNotEstimated = 'Not estimated';
  static const hajjUntitledMilestones =
      'Untitled milestones are excluded from the critical path until you name or delete them.';
  static const hajjAfterNote =
      'Optional. Performed standing does not open this for you. Not a trophy or acceptance claim.';
  static const hajjNoPassportScan =
      'Do not store passport numbers or scans. Nationality and residence are separate.';
  static const hajjPonderDue =
      'You recorded that you believe Hajj is due. A journey is optional. Learn & Practice stays available either way.';
  static const hajjPonderPreparing =
      'You recorded Hajj as preparing. Readiness lives on a journey you choose to start. It is not a daily score.';
  static const pastSalahEntryNote =
      'This day is stored. Tap Edit to change it, then Save. Unanswered is not missed.';
  static const applicationReflectionIntroTitle = 'Application Reflection';
  static const firstLookDoorTitle = 'This recorder is yours';
  static const firstLookDoorPrivate =
      'This is a private recorder. It does not score your worship, keep a streak, or issue a ruling.';
  static const firstLookDoorEmpty =
      'An empty mark is not missed. You can save a day with unanswered rows.';
  static const firstLookDoorSeason =
      'Home starts with Salah, Qur’an, and Dhikr. Add Hadith, Fasting, Character, Rights, or Charity when you want them. Empty is not missed.';
  static const firstLookStartBlank = 'Start with a quiet week';
  static const firstLookShowSample = 'Show sample days';
  static const firstLookDoorSample =
      'Sample days use the same live fields so you can try looking back. Later windows can look busier than earlier ones. That is a demonstration, not a target.';
  static const seePonderExplore = 'SEE → PONDER → EXPLORE';
  static const dhikrPerformedHint =
      'Tick practised formulas. Unticked stays unanswered, not missed.';
  static const dhikrPerformedHeading = 'Dhikr performed';
  static const dhikrPerformedCountHeading = 'Count';
  static const verifiedWordingAvailable = 'Verified wording available';
  static const relatedWordingAvailable = 'Related wording available';
  static const sampleDataNotice =
      'Sample/demo records are visible so you can try looking back. They stay until you archive them. They are not a target.';
  static const archiveSamplePrompt =
      'Would you like to archive the sample records and use only your own records?';
  static const settingsTitle = 'Settings';
  static const aboutMuhasabah = 'About Private Muhasabah';
  static const faqTitle = 'FAQ';
  static const recordReflectLoop =
      'RECORD → REFLECT → REVIEW → RECOGNISE → PONDER → RESPOND';
  static const lookingBackPurpose =
      'After you record, look back at past days. You may notice what you recorded more or less often, and optional factors you named around those days. Factors are not causes. The app does not diagnose a reason or prescribe a next step. A Response is your own note about what you might try. Sample days, if you choose them, show how Review and 30-day graphs can look — they are a demonstration, not a target or a model of practice.';
  static const faqPurpose =
      'Private Muhasabah is your private recorder. RECORD what you noticed, REFLECT on the day, REVIEW later windows, RECOGNISE descriptive patterns, PONDER, and RESPOND in your own words. It does not score worship, keep a streak, or issue a ruling.\n\nAfter you record, look back. You may notice what you recorded more or less often, and optional factors you named around those days. Factors are not causes. The app does not diagnose a reason, prescribe a remedy, or set a standard of practice. A Response is yours: you decide whether anything needs a change.\n\nShow only the domains you want. Leave a row unanswered when it does not apply — empty is not missed. Records stay on this device.\n\nSample days, if you choose them, use the same live fields so Review and 30-day graphs can be tried. Later windows can look busier than earlier ones so the views have something to show. That is a demonstration, not a target.\n\nThis season: Salah (prayers you recorded), Qur’an (three independent sittings), Hadith (whether a teaching reached the day), Dhikr (performed lists), Fasting (Ramadan and voluntary noticing), Character (yourself only), Rights (what you owe others), and Charity (giving without amounts).';
  static const faqNote =
      'Clarifications only. Not advice, scores, or a verdict. Grayed items below are not in this version.';
  static const faqSettingsNote = 'Purpose, mix, and clarifications';
  static const faqThisVersionHeading = 'This version';
  static const faqNotApplicableHeading = 'Not applicable in this version';
  static const faqNotApplicableLabel = 'Not applicable';
  static const faqNotApplicableNote =
      'Listed so you can find them. Not active in this season. Saved records stay. Home, Review, and check-in do not use these domains yet.';
  static const accountAndData = 'Account & data';
  static const developerSampleData = 'Developer & sample data';
  static const applicationSection = 'Preferences';
  static const privacySection = 'Privacy';
  static const dataManagement = 'Developer & sample data';
  static const appearancePreferences = 'Preferences';
  static const appearance = 'Appearance';
  static const appearanceNote =
      'System, light, dark, plus three named looks. Not a score.';
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
  static const worshipListGender = 'Salah list for me';
  static const worshipListGenderNote =
      'This only changes whether Excused appears on obligatory Salah and Jumu‘ah. It is not a ruling, a profile, or a score. Not recorded keeps every choice visible. Excused is for days when those prayers are not required (such as hayd or nifas). Saved days are not rewritten.';
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
  static const productivitySettings = 'Productivity';
  static const productivitySettingsNote =
      'Today’s board size and carry-forward';
  static const productivityDailyActions = 'Daily action(s)';
  static const productivityDailyActionsNote =
      'How many rows to show on today’s board (1–5). Extra nominated items stay in the Productivity register. Not a quota.';
  static const productivityCarryForwardInfo =
      'Unfinished actions on today’s board move to the next day. That is carry-forward, not a fail.';
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
      'Tick the formulas you practised after this fard prayer. Unticked stays unanswered, not missed. Optional count is yours. Colour names the recorded choice when activity colours are on — not a khushu’ score.';
  static const visibleDomainsNote =
      'Choose which domains belong in this profile. This season’s mix, on the same screen, is a subset of those domains: bands and rows to notice. Leave a domain or row unselected if it does not apply. Home, Review, Progress, check-in, Quick Tap, and Recorded days follow the mix among the domains shown. Hidden domains keep any saved records.';
  static const shownDomainsNote =
      'Choose which domains belong in this profile. Leave a domain unselected if it does not apply. Home, Review, and today’s check-in follow the domains shown here and the mix below. Hidden domains keep any saved records.';
  static const dormantDomainNote =
      'Listed here so you can find it. Not active in this season. Saved records stay. Home, Review, and check-in do not use it yet.';
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
      'Shows Salah & Prayer Quality, Qur’an Engagement, and Dhikr & Dua. Hadith & Living Sunnah, Rights of Others, Charity, Character & Morals (Akhlaq), and Fasting stay hidden unless you add them. Knowledge, Time, Health, Wealth, Ummah, Hajj, and Productivity stay listed but are not active this season.';
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
  static const checkInAddNoteNote =
      'Optional. Saved in My Notes, linked to this check-in day. Not a score.';
  static const hadithMemorisationFocus = 'Current Memorisation Focus';
  static String practiceLearnTitle(String domainShort) =>
      'LEARN & PRACTICE ($domainShort)';
  static String get practiceSalahTitle => practiceLearnTitle('Salah');
  static const practiceSalahNote =
      'Verses and authentic hadith grouped like Home. Add one if you want to learn it. Presence of heart is not scored.';
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
      'Daily-practice hadith and related supplications (Arabic, transliteration, translation). Add one if you want to learn it. Not a checklist or revival programme.';
  static const addPracticeHadith = '+ add Hadith';
  static String openPracticeLearnRegister(String domainShort) =>
      'Learn & Practice ($domainShort) Register';
  static String get openPracticeHadithRegister => 'Hadith Register';
  static String practiceLearnRegisterTitle(String domainShort) =>
      'Learn & Practice ($domainShort) Register';
  static String get practiceHadithRegisterTitle =>
      practiceLearnRegisterTitle('Hadith');
  static const practiceHadithRegisterNote =
      'Your list. Date added, source, content, topic, and whether you are learning it, have learnt it, are practicing it, or living it. Archive marks a hadith so Home reflection can skip it when another quote is available. The built-in list is never removed. Select and delete only the private copy on this device if it should not stay here. This does not fill Living Sunnah.';
  static const practiceHadithRegisterEmpty = 'No hadith in the register.';
  static const practiceHadithAlreadyAdded = 'Already in your register';
  static const bringHadith = 'Fetch a Hadith';
  static const hadithMap = 'Hadith Map';
  static const hadithMapNote =
      'The map always shows the full unique list. Week or month is only a count in the table below; it does not hide marks. Shape is the topic family. Fill is how you have met it, not a grade. A tick marks Shared. Gold is a recently fetched copy.';
  static const hadithMapColourCoding = 'Colour coding';
  static const hadithMapTopicShapes = 'Topic shapes';
  static const hadithMapByTopic = 'By topic';
  static const hadithMapCounts = 'HADITH COUNTS';
  static const hadithMapMetHistory = 'Met history';
  static const hadithMapThisPeriod = 'this period';
  static const hadithMapNew = 'New';
  static const hadithMapNotMet = 'Not met';
  static const hadithMapShared = 'Shared';
  static const hadithMapWeek = 'w';
  static const hadithMapMonth = 'm';
  static const hadithMapChoose = 'Tap a mark to read it.';
  static const playHadith = 'Play';
  static const pauseHadith = 'Pause';
  static const hadithPlayCouldNotStart =
      'This device has no speaking voice for playback.';
  static String hadithMapFullTitle(int count) =>
      'FULL MAP $count Unique Hadiths';
  static String hadithMapFamilyLabel(String id) => switch (id) {
    'prayer' => 'Prayer',
    'fasting' => 'Fasting',
    'dhikr' => 'Dhikr',
    'character' => 'Character',
    'family' => 'Family',
    'knowledge' => 'Knowledge',
    'travel' => 'Travel',
    'daily' => 'Daily life',
    'charity' => 'Charity',
    _ => 'Daily life',
  };
  static String hadithMapFillLabel(String id) => switch (id) {
    'recentlyFetched' => hadithMapNew,
    'notMet' => hadithMapNotMet,
    'learning' => practiceStatusLearning,
    'shared' => hadithMapShared,
    'living' => practiceHadithStatusHabit,
    _ => hadithMapNotMet,
  };
  static const bringHadithTitle = 'Fetch a Hadith into Learn';
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
      'Remove the selected private copies from this device? The built-in hadith list stays. This cannot be undone.';
  static const practiceHadithNothingSelected = 'Select a hadith first.';
  static const practiceHadithArchiveHint =
      'Archived hadith stay in the built-in list. Matching daily or weekly reflections are skipped when another quote is available.';
  static String get practiceDhikrTitle => practiceLearnTitle('Dhikr');
  static const practiceDhikrNote =
      'Authentic dhikr and dua, grouped by occasion. Post-prayer, morning, and evening sit first. Add one if you want to learn it. Not a target or score.';
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
      'Verses and authentic hadith grouped like Home. Add one if you want to learn it. Not a character grade.';
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
      'Verses and authentic hadith grouped like Home. Add one if you want to learn it. Not a relationship score or chore list.';
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
      'Verses and authentic hadith grouped like Home. Ramadan noticing is not a validity ruling. Add one if you want to learn it — not a countdown or a prescription to fast.';
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
      'Qur’an verses and authentic hadith you may learn at any time. Learn & Practice is independent of standing and of any journey. Add one if you want to learn it and bring it into practice. This is not a due-date, ability calculator, checklist score, or trophy.';
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
      'Verses and authentic hadith grouped like Home. A smile is sadaqah. Amounts are not recorded. Add one if you want to learn it — not a generosity score.';
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
      'Three independent rows share one duration list: recitation/memorisation/revision, meaning and pondering, and noticing a verse in daily life. Unanswered is empty, not “not engaged”. Duration is not a khushu’ score.';
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
  static const saveQuoteToResponse = 'Save to My Notes';
  static const youRecordedColon = 'You recorded:';
}
