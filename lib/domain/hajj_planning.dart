import 'dart:convert';

/// Canonical Hajj store schema. Bump only with an explicit migration after launch.
const kHajjStoreSchemaVersion = 1;

const kHajjStoreDocumentKey = 'current';

/// Hive box for the Hajj store. Independent of DailyCheckIn and AppPrefs.
const hajjStoreBoxName = 'muhasabah_hajj_v1';

/// Retired AppPrefs key. Discarded on first open of the Hajj store.
const kLegacyHajjStatusPrefsKey = 'hajj_status';

enum HajjStoreDecodeKind { ok, missing, unknownVersion, corrupt }

/// Lifetime Hajj standing. User-owned. Never an obligation engine.
enum HajjStandingKind {
  unanswered,
  unsure,
  believeDue,
  preparing,
  performed,
  notPlanning,
  notApplicable,
  preferNotToRecord,
}

extension HajjStandingKindX on HajjStandingKind {
  bool get isRecorded =>
      this != HajjStandingKind.unanswered &&
      this != HajjStandingKind.preferNotToRecord;

  String get label => switch (this) {
    HajjStandingKind.unanswered => 'Not recorded',
    HajjStandingKind.unsure => 'Unsure',
    HajjStandingKind.believeDue => 'I believe it is due',
    HajjStandingKind.preparing => 'Preparing',
    HajjStandingKind.performed => 'Performed',
    HajjStandingKind.notPlanning => 'Not planning',
    HajjStandingKind.notApplicable => 'Not applicable',
    HajjStandingKind.preferNotToRecord => 'Prefer not to record',
  };

  static HajjStandingKind fromId(String? id) {
    if (id == null || id.isEmpty) return HajjStandingKind.unanswered;
    return HajjStandingKind.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjStandingKind.unanswered,
    );
  }
}

/// Optional journey lifecycle. Independent of [HajjStandingKind].
enum HajjJourneyLifecycle {
  considering,
  planning,
  booked,
  inProgress,
  completed,
  deferred,
  cancelled,
  unknown,
}

extension HajjJourneyLifecycleX on HajjJourneyLifecycle {
  String get label => switch (this) {
    HajjJourneyLifecycle.considering => 'Considering',
    HajjJourneyLifecycle.planning => 'Planning',
    HajjJourneyLifecycle.booked => 'Booked',
    HajjJourneyLifecycle.inProgress => 'In progress',
    HajjJourneyLifecycle.completed => 'Completed',
    HajjJourneyLifecycle.deferred => 'Deferred',
    HajjJourneyLifecycle.cancelled => 'Cancelled',
    HajjJourneyLifecycle.unknown => 'Unknown',
  };

  static HajjJourneyLifecycle fromId(String? id) {
    if (id == null || id.isEmpty) return HajjJourneyLifecycle.unknown;
    return HajjJourneyLifecycle.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjJourneyLifecycle.unknown,
    );
  }
}

enum HajjTravelerRole {
  self,
  spouse,
  child,
  parent,
  otherFamily,
  companion,
  unknown,
}

extension HajjTravelerRoleX on HajjTravelerRole {
  String get label => switch (this) {
    HajjTravelerRole.self => 'Self',
    HajjTravelerRole.spouse => 'Spouse',
    HajjTravelerRole.child => 'Child',
    HajjTravelerRole.parent => 'Parent',
    HajjTravelerRole.otherFamily => 'Other family',
    HajjTravelerRole.companion => 'Companion',
    HajjTravelerRole.unknown => 'Unknown',
  };

  static HajjTravelerRole fromId(String? id) {
    if (id == null || id.isEmpty) return HajjTravelerRole.unknown;
    return HajjTravelerRole.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjTravelerRole.unknown,
    );
  }
}

enum HajjReadinessStatus {
  unanswered,
  unknown,
  notApplicable,
  notStarted,
  inProgress,
  confirmedReady,
  blocked,
}

extension HajjReadinessStatusX on HajjReadinessStatus {
  String get label => switch (this) {
    HajjReadinessStatus.unanswered => 'Not recorded',
    HajjReadinessStatus.unknown => 'Needs verification',
    HajjReadinessStatus.notApplicable => 'Not applicable',
    HajjReadinessStatus.notStarted => 'Not recorded',
    HajjReadinessStatus.inProgress => 'In progress',
    HajjReadinessStatus.confirmedReady => 'Confirmed by user',
    HajjReadinessStatus.blocked => 'Needs verification',
  };

  static HajjReadinessStatus fromId(String? id) {
    if (id == null || id.isEmpty) return HajjReadinessStatus.unanswered;
    return HajjReadinessStatus.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjReadinessStatus.unanswered,
    );
  }
}

enum HajjMilestoneStatus {
  unanswered,
  unknown,
  notApplicable,
  pending,
  ready,
  done,
  blocked,
}

extension HajjMilestoneStatusX on HajjMilestoneStatus {
  String get label => switch (this) {
    HajjMilestoneStatus.unanswered => 'Not recorded',
    HajjMilestoneStatus.unknown => 'Unknown',
    HajjMilestoneStatus.notApplicable => 'Not applicable',
    HajjMilestoneStatus.pending => 'Pending',
    HajjMilestoneStatus.ready => 'Ready',
    HajjMilestoneStatus.done => 'Done',
    HajjMilestoneStatus.blocked => 'Blocked',
  };

  static HajjMilestoneStatus fromId(String? id) {
    if (id == null || id.isEmpty) return HajjMilestoneStatus.unanswered;
    return HajjMilestoneStatus.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjMilestoneStatus.unknown,
    );
  }
}

enum HajjProvenanceKind {
  officialVerified,
  userEntered,
  aiInterpretation,
  appEstimate,
}

extension HajjProvenanceKindX on HajjProvenanceKind {
  String get label => switch (this) {
    HajjProvenanceKind.officialVerified => 'Officially verified by you',
    HajjProvenanceKind.userEntered => 'User-entered, unverified',
    HajjProvenanceKind.aiInterpretation => 'AI interpretation',
    HajjProvenanceKind.appEstimate => 'App planning estimate',
  };

  static HajjProvenanceKind fromId(String? id) {
    if (id == null || id.isEmpty) return HajjProvenanceKind.userEntered;
    return HajjProvenanceKind.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjProvenanceKind.userEntered,
    );
  }
}

enum HajjSourceTrustClass { official, secondary, userNote, unknown }

extension HajjSourceTrustClassX on HajjSourceTrustClass {
  static HajjSourceTrustClass fromId(String? id) {
    if (id == null || id.isEmpty) return HajjSourceTrustClass.unknown;
    return HajjSourceTrustClass.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjSourceTrustClass.unknown,
    );
  }
}

enum HajjVerificationStatus {
  unverified,
  verifiedByUser,
  outdated,
  unknown,
  notApplicable,
}

enum HajjSourceRetrievalMode {
  unknown,
  demonstration,
  liveHttp,
  manualLink,
  unavailable,
}

extension HajjSourceRetrievalModeX on HajjSourceRetrievalMode {
  String get label => switch (this) {
    HajjSourceRetrievalMode.unknown => 'Unknown retrieval',
    HajjSourceRetrievalMode.demonstration => 'Demonstration',
    HajjSourceRetrievalMode.liveHttp => 'Live official-source information',
    HajjSourceRetrievalMode.manualLink => 'Source requires manual verification',
    HajjSourceRetrievalMode.unavailable => 'Source unavailable',
  };

  static HajjSourceRetrievalMode fromId(String? id) {
    if (id == null || id.isEmpty) return HajjSourceRetrievalMode.unknown;
    return HajjSourceRetrievalMode.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjSourceRetrievalMode.unknown,
    );
  }
}

extension HajjVerificationStatusX on HajjVerificationStatus {
  static HajjVerificationStatus fromId(String? id) {
    if (id == null || id.isEmpty) return HajjVerificationStatus.unverified;
    return HajjVerificationStatus.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjVerificationStatus.unknown,
    );
  }
}

enum HajjDateCertainty { unknown, tentative, confirmed }

extension HajjDateCertaintyX on HajjDateCertainty {
  String get label => switch (this) {
    HajjDateCertainty.unknown => 'Unknown',
    HajjDateCertainty.tentative => 'Tentative',
    HajjDateCertainty.confirmed => 'Confirmed',
  };

  static HajjDateCertainty fromId(String? id) {
    if (id == null || id.isEmpty) return HajjDateCertainty.unknown;
    return HajjDateCertainty.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjDateCertainty.unknown,
    );
  }
}

enum HajjLearningState { notStarted, learning, practised, readyToRevisit }

extension HajjLearningStateX on HajjLearningState {
  String get label => switch (this) {
    HajjLearningState.notStarted => 'Not started',
    HajjLearningState.learning => 'Learning',
    HajjLearningState.practised => 'Practised',
    HajjLearningState.readyToRevisit => 'Ready to revisit',
  };

  static HajjLearningState fromId(String? id) {
    if (id == null || id.isEmpty) return HajjLearningState.notStarted;
    return HajjLearningState.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjLearningState.notStarted,
    );
  }
}

/// Planner checklist choices. Blocked/notStarted stay in storage for v1.
const kHajjReadinessPlannerStatuses = [
  HajjReadinessStatus.unanswered,
  HajjReadinessStatus.unknown,
  HajjReadinessStatus.inProgress,
  HajjReadinessStatus.confirmedReady,
  HajjReadinessStatus.notApplicable,
];

enum HajjAfterReturnIntention {
  unanswered,
  unknown,
  notPlanning,
  considering,
  planning,
  notApplicable,
}

extension HajjAfterReturnIntentionX on HajjAfterReturnIntention {
  String get label => switch (this) {
    HajjAfterReturnIntention.unanswered => 'Not recorded',
    HajjAfterReturnIntention.unknown => 'Unknown',
    HajjAfterReturnIntention.notPlanning => 'Not planning a return',
    HajjAfterReturnIntention.considering => 'Considering',
    HajjAfterReturnIntention.planning => 'Planning',
    HajjAfterReturnIntention.notApplicable => 'Not applicable',
  };

  static HajjAfterReturnIntention fromId(String? id) {
    if (id == null || id.isEmpty) return HajjAfterReturnIntention.unanswered;
    return HajjAfterReturnIntention.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjAfterReturnIntention.unknown,
    );
  }
}

class HajjStandingRecord {
  const HajjStandingRecord({
    this.kind = HajjStandingKind.unanswered,
    this.updatedAt,
    this.note,
  });

  final HajjStandingKind kind;
  final String? updatedAt;
  final String? note;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    if (updatedAt != null) 'updatedAt': updatedAt,
    if (note != null) 'note': note,
  };

  factory HajjStandingRecord.fromJson(Map<String, dynamic> json) {
    return HajjStandingRecord(
      kind: HajjStandingKindX.fromId(_optString(json, 'kind')),
      updatedAt: _optString(json, 'updatedAt'),
      note: _optString(json, 'note'),
    );
  }
}

class HajjStandingEvent {
  const HajjStandingEvent({
    required this.kind,
    required this.recordedAt,
    this.note,
  });

  final HajjStandingKind kind;
  final String recordedAt;
  final String? note;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'recordedAt': recordedAt,
    if (note != null) 'note': note,
  };

  factory HajjStandingEvent.fromJson(Map<String, dynamic> json) {
    return HajjStandingEvent(
      kind: HajjStandingKindX.fromId(_optString(json, 'kind')),
      recordedAt: _optString(json, 'recordedAt') ?? '',
      note: _optString(json, 'note'),
    );
  }
}

class HajjSeason {
  const HajjSeason({
    this.hijriYear,
    this.gregorianYear,
    this.label,
    this.datesUnknown = false,
  });

  final int? hijriYear;
  final int? gregorianYear;
  final String? label;
  final bool datesUnknown;

  Map<String, dynamic> toJson() => {
    if (hijriYear != null) 'hijriYear': hijriYear,
    if (gregorianYear != null) 'gregorianYear': gregorianYear,
    if (label != null) 'label': label,
    'datesUnknown': datesUnknown,
  };

  factory HajjSeason.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HajjSeason(datesUnknown: true);
    return HajjSeason(
      hijriYear: _optInt(json, 'hijriYear'),
      gregorianYear: _optInt(json, 'gregorianYear'),
      label: _optString(json, 'label'),
      datesUnknown: json['datesUnknown'] == true,
    );
  }
}

class HajjOfficialSource {
  const HajjOfficialSource({
    required this.id,
    this.title,
    this.uri,
    this.citation,
    this.trustClass = HajjSourceTrustClass.unknown,
    this.verificationStatus = HajjVerificationStatus.unverified,
    this.notes,
    this.issuingAuthority,
    this.jurisdictionCountry,
    this.applicableSeason,
    this.publishedDate,
    this.retrievedAt,
    this.requirementText,
    this.deadline,
    this.appliesToPathwayIds = const [],
    this.provenance = HajjProvenanceKind.userEntered,
    this.demonstration = false,
    this.retrievalMode = HajjSourceRetrievalMode.unknown,
    this.authenticityStatus,
    this.freshnessStatus,
    this.applicabilityStatus,
    this.limitations,
  });

  final String id;
  final String? title;
  final String? uri;
  final String? citation;
  final HajjSourceTrustClass trustClass;
  final HajjVerificationStatus verificationStatus;
  final String? notes;
  final String? issuingAuthority;
  final String? jurisdictionCountry;
  final String? applicableSeason;
  final String? publishedDate;
  final String? retrievedAt;
  final String? requirementText;
  final String? deadline;
  final List<String> appliesToPathwayIds;
  final HajjProvenanceKind provenance;
  final bool demonstration;
  final HajjSourceRetrievalMode retrievalMode;
  final String? authenticityStatus;
  final String? freshnessStatus;
  final String? applicabilityStatus;
  final String? limitations;

  HajjOfficialSource copyWith({
    String? title,
    String? uri,
    String? citation,
    HajjSourceTrustClass? trustClass,
    HajjVerificationStatus? verificationStatus,
    String? notes,
    String? issuingAuthority,
    String? jurisdictionCountry,
    String? applicableSeason,
    String? publishedDate,
    String? retrievedAt,
    String? requirementText,
    String? deadline,
    List<String>? appliesToPathwayIds,
    HajjProvenanceKind? provenance,
    bool? demonstration,
    HajjSourceRetrievalMode? retrievalMode,
    String? authenticityStatus,
    String? freshnessStatus,
    String? applicabilityStatus,
    String? limitations,
  }) {
    return HajjOfficialSource(
      id: id,
      title: title ?? this.title,
      uri: uri ?? this.uri,
      citation: citation ?? this.citation,
      trustClass: trustClass ?? this.trustClass,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      notes: notes ?? this.notes,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      jurisdictionCountry: jurisdictionCountry ?? this.jurisdictionCountry,
      applicableSeason: applicableSeason ?? this.applicableSeason,
      publishedDate: publishedDate ?? this.publishedDate,
      retrievedAt: retrievedAt ?? this.retrievedAt,
      requirementText: requirementText ?? this.requirementText,
      deadline: deadline ?? this.deadline,
      appliesToPathwayIds: appliesToPathwayIds ?? this.appliesToPathwayIds,
      provenance: provenance ?? this.provenance,
      demonstration: demonstration ?? this.demonstration,
      retrievalMode: retrievalMode ?? this.retrievalMode,
      authenticityStatus: authenticityStatus ?? this.authenticityStatus,
      freshnessStatus: freshnessStatus ?? this.freshnessStatus,
      applicabilityStatus: applicabilityStatus ?? this.applicabilityStatus,
      limitations: limitations ?? this.limitations,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (title != null) 'title': title,
    if (uri != null) 'uri': uri,
    if (citation != null) 'citation': citation,
    'trustClass': trustClass.name,
    'verificationStatus': verificationStatus.name,
    if (notes != null) 'notes': notes,
    if (issuingAuthority != null) 'issuingAuthority': issuingAuthority,
    if (jurisdictionCountry != null) 'jurisdictionCountry': jurisdictionCountry,
    if (applicableSeason != null) 'applicableSeason': applicableSeason,
    if (publishedDate != null) 'publishedDate': publishedDate,
    if (retrievedAt != null) 'retrievedAt': retrievedAt,
    if (requirementText != null) 'requirementText': requirementText,
    if (deadline != null) 'deadline': deadline,
    'appliesToPathwayIds': appliesToPathwayIds,
    'provenance': provenance.name,
    'demonstration': demonstration,
    'retrievalMode': retrievalMode.name,
    if (authenticityStatus != null) 'authenticityStatus': authenticityStatus,
    if (freshnessStatus != null) 'freshnessStatus': freshnessStatus,
    if (applicabilityStatus != null) 'applicabilityStatus': applicabilityStatus,
    if (limitations != null) 'limitations': limitations,
  };

  factory HajjOfficialSource.fromJson(Map<String, dynamic> json) {
    return HajjOfficialSource(
      id: _optString(json, 'id') ?? '',
      title: _optString(json, 'title'),
      uri: _optString(json, 'uri'),
      citation: _optString(json, 'citation'),
      trustClass: HajjSourceTrustClassX.fromId(_optString(json, 'trustClass')),
      verificationStatus: HajjVerificationStatusX.fromId(
        _optString(json, 'verificationStatus'),
      ),
      notes: _optString(json, 'notes'),
      issuingAuthority: _optString(json, 'issuingAuthority'),
      jurisdictionCountry: _optString(json, 'jurisdictionCountry'),
      applicableSeason: _optString(json, 'applicableSeason'),
      publishedDate: _optString(json, 'publishedDate'),
      retrievedAt: _optString(json, 'retrievedAt'),
      requirementText: _optString(json, 'requirementText'),
      deadline: _optString(json, 'deadline'),
      appliesToPathwayIds: _stringList(json['appliesToPathwayIds']),
      provenance: HajjProvenanceKindX.fromId(_optString(json, 'provenance')),
      demonstration: json['demonstration'] == true,
      retrievalMode: HajjSourceRetrievalModeX.fromId(
        _optString(json, 'retrievalMode'),
      ),
      authenticityStatus: _optString(json, 'authenticityStatus'),
      freshnessStatus: _optString(json, 'freshnessStatus'),
      applicabilityStatus: _optString(json, 'applicabilityStatus'),
      limitations: _optString(json, 'limitations'),
    );
  }
}

class HajjTravelerProfile {
  const HajjTravelerProfile({
    required this.id,
    this.role = HajjTravelerRole.unknown,
    this.displayName,
    this.citizenships = const [],
    this.nationalityCountry,
    this.residenceCountry,
    this.passportExpiryDate,
    this.residenceExpiryDate,
    this.documentationDeadline,
    this.departurePreference,
    this.returnPreference,
    this.readinessStatus = HajjReadinessStatus.unanswered,
    this.readiness = const [],
    this.consentConfirmed,
    this.notes,
    this.healthPreparationNote,
    this.confirmedPathwayIds = const [],
  });

  final String id;
  final HajjTravelerRole role;
  final String? displayName;
  final List<String> citizenships;
  final String? nationalityCountry;
  final String? residenceCountry;
  final String? passportExpiryDate;
  final String? residenceExpiryDate;
  final String? documentationDeadline;
  final String? departurePreference;
  final String? returnPreference;
  final HajjReadinessStatus readinessStatus;
  final List<HajjReadinessPrerequisite> readiness;
  final bool? consentConfirmed;
  final String? notes;
  final String? healthPreparationNote;
  final List<String> confirmedPathwayIds;

  HajjTravelerProfile copyWith({
    HajjTravelerRole? role,
    String? displayName,
    List<String>? citizenships,
    String? nationalityCountry,
    String? residenceCountry,
    String? passportExpiryDate,
    String? residenceExpiryDate,
    String? documentationDeadline,
    String? departurePreference,
    String? returnPreference,
    HajjReadinessStatus? readinessStatus,
    List<HajjReadinessPrerequisite>? readiness,
    bool? consentConfirmed,
    String? notes,
    String? healthPreparationNote,
    List<String>? confirmedPathwayIds,
  }) {
    return HajjTravelerProfile(
      id: id,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      citizenships: citizenships ?? this.citizenships,
      nationalityCountry: nationalityCountry ?? this.nationalityCountry,
      residenceCountry: residenceCountry ?? this.residenceCountry,
      passportExpiryDate: passportExpiryDate ?? this.passportExpiryDate,
      residenceExpiryDate: residenceExpiryDate ?? this.residenceExpiryDate,
      documentationDeadline:
          documentationDeadline ?? this.documentationDeadline,
      departurePreference: departurePreference ?? this.departurePreference,
      returnPreference: returnPreference ?? this.returnPreference,
      readinessStatus: readinessStatus ?? this.readinessStatus,
      readiness: readiness ?? this.readiness,
      consentConfirmed: consentConfirmed ?? this.consentConfirmed,
      notes: notes ?? this.notes,
      healthPreparationNote:
          healthPreparationNote ?? this.healthPreparationNote,
      confirmedPathwayIds: confirmedPathwayIds ?? this.confirmedPathwayIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.name,
    if (displayName != null) 'displayName': displayName,
    'citizenships': citizenships,
    if (nationalityCountry != null) 'nationalityCountry': nationalityCountry,
    if (residenceCountry != null) 'residenceCountry': residenceCountry,
    if (passportExpiryDate != null) 'passportExpiryDate': passportExpiryDate,
    if (residenceExpiryDate != null) 'residenceExpiryDate': residenceExpiryDate,
    if (documentationDeadline != null)
      'documentationDeadline': documentationDeadline,
    if (departurePreference != null) 'departurePreference': departurePreference,
    if (returnPreference != null) 'returnPreference': returnPreference,
    'readinessStatus': readinessStatus.name,
    'readiness': [for (final item in readiness) item.toJson()],
    if (consentConfirmed != null) 'consentConfirmed': consentConfirmed,
    if (notes != null) 'notes': notes,
    if (healthPreparationNote != null)
      'healthPreparationNote': healthPreparationNote,
    'confirmedPathwayIds': confirmedPathwayIds,
  };

  factory HajjTravelerProfile.fromJson(Map<String, dynamic> json) {
    return HajjTravelerProfile(
      id: _optString(json, 'id') ?? '',
      role: HajjTravelerRoleX.fromId(_optString(json, 'role')),
      displayName: _optString(json, 'displayName'),
      citizenships: _stringList(json['citizenships']),
      nationalityCountry: _optString(json, 'nationalityCountry'),
      residenceCountry: _optString(json, 'residenceCountry'),
      passportExpiryDate: _optString(json, 'passportExpiryDate'),
      residenceExpiryDate: _optString(json, 'residenceExpiryDate'),
      documentationDeadline: _optString(json, 'documentationDeadline'),
      departurePreference: _optString(json, 'departurePreference'),
      returnPreference: _optString(json, 'returnPreference'),
      readinessStatus: HajjReadinessStatusX.fromId(
        _optString(json, 'readinessStatus'),
      ),
      readiness: _readinessList(json['readiness']),
      consentConfirmed: json['consentConfirmed'] is bool
          ? json['consentConfirmed'] as bool
          : null,
      notes: _optString(json, 'notes'),
      healthPreparationNote: _optString(json, 'healthPreparationNote'),
      confirmedPathwayIds: _stringList(json['confirmedPathwayIds']),
    );
  }
}

class HajjReadinessPrerequisite {
  const HajjReadinessPrerequisite({
    required this.id,
    this.group,
    this.title,
    this.status = HajjReadinessStatus.unanswered,
    this.confirmedByUser = false,
    this.confirmationRecordedAt,
    this.evidenceSourceId,
    this.officialDeadline,
    this.internalTargetDate,
    this.dependsOn = const [],
    this.travelerId,
    this.officialRequirementVerified = false,
    this.notes,
  });

  final String id;
  final String? group;
  final String? title;
  final HajjReadinessStatus status;
  final bool confirmedByUser;
  final String? confirmationRecordedAt;
  final String? evidenceSourceId;
  final String? officialDeadline;
  final String? internalTargetDate;
  final List<String> dependsOn;
  final String? travelerId;
  final bool officialRequirementVerified;
  final String? notes;

  HajjReadinessPrerequisite copyWith({
    String? group,
    String? title,
    HajjReadinessStatus? status,
    bool? confirmedByUser,
    String? confirmationRecordedAt,
    String? evidenceSourceId,
    String? officialDeadline,
    String? internalTargetDate,
    List<String>? dependsOn,
    String? travelerId,
    bool? officialRequirementVerified,
    String? notes,
  }) {
    return HajjReadinessPrerequisite(
      id: id,
      group: group ?? this.group,
      title: title ?? this.title,
      status: status ?? this.status,
      confirmedByUser: confirmedByUser ?? this.confirmedByUser,
      confirmationRecordedAt:
          confirmationRecordedAt ?? this.confirmationRecordedAt,
      evidenceSourceId: evidenceSourceId ?? this.evidenceSourceId,
      officialDeadline: officialDeadline ?? this.officialDeadline,
      internalTargetDate: internalTargetDate ?? this.internalTargetDate,
      dependsOn: dependsOn ?? this.dependsOn,
      travelerId: travelerId ?? this.travelerId,
      officialRequirementVerified:
          officialRequirementVerified ?? this.officialRequirementVerified,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (group != null) 'group': group,
    if (title != null) 'title': title,
    'status': status.name,
    'confirmedByUser': confirmedByUser,
    if (confirmationRecordedAt != null)
      'confirmationRecordedAt': confirmationRecordedAt,
    if (evidenceSourceId != null) 'evidenceSourceId': evidenceSourceId,
    if (officialDeadline != null) 'officialDeadline': officialDeadline,
    if (internalTargetDate != null) 'internalTargetDate': internalTargetDate,
    'dependsOn': dependsOn,
    if (travelerId != null) 'travelerId': travelerId,
    'officialRequirementVerified': officialRequirementVerified,
    if (notes != null) 'notes': notes,
  };

  factory HajjReadinessPrerequisite.fromJson(Map<String, dynamic> json) {
    return HajjReadinessPrerequisite(
      id: _optString(json, 'id') ?? '',
      group: _optString(json, 'group'),
      title: _optString(json, 'title'),
      status: HajjReadinessStatusX.fromId(_optString(json, 'status')),
      confirmedByUser: json['confirmedByUser'] == true,
      confirmationRecordedAt: _optString(json, 'confirmationRecordedAt'),
      evidenceSourceId: _optString(json, 'evidenceSourceId'),
      officialDeadline: _optString(json, 'officialDeadline'),
      internalTargetDate: _optString(json, 'internalTargetDate'),
      dependsOn: _stringList(json['dependsOn']),
      travelerId: _optString(json, 'travelerId'),
      officialRequirementVerified: json['officialRequirementVerified'] == true,
      notes: _optString(json, 'notes'),
    );
  }
}

class HajjMilestone {
  const HajjMilestone({
    required this.id,
    this.title,
    this.dependsOn = const [],
    this.travelerIds = const [],
    this.plannedDate,
    this.plannedDateCertainty = HajjDateCertainty.unknown,
    this.officialDeadline,
    this.internalTargetDate,
    this.recommendedStartDate,
    this.recommendedCompletionDate,
    this.bufferDays,
    this.processingDurationDays,
    this.status = HajjMilestoneStatus.unanswered,
    this.notes,
    this.templateId,
  });

  final String id;
  final String? title;
  final List<String> dependsOn;
  final List<String> travelerIds;
  final String? plannedDate;
  final HajjDateCertainty plannedDateCertainty;
  final String? officialDeadline;
  final String? internalTargetDate;
  final String? recommendedStartDate;
  final String? recommendedCompletionDate;
  final int? bufferDays;
  final int? processingDurationDays;
  final HajjMilestoneStatus status;
  final String? notes;
  final String? templateId;

  HajjMilestone copyWith({
    String? title,
    List<String>? dependsOn,
    List<String>? travelerIds,
    String? plannedDate,
    HajjDateCertainty? plannedDateCertainty,
    String? officialDeadline,
    String? internalTargetDate,
    String? recommendedStartDate,
    String? recommendedCompletionDate,
    int? bufferDays,
    int? processingDurationDays,
    HajjMilestoneStatus? status,
    String? notes,
    String? templateId,
  }) {
    return HajjMilestone(
      id: id,
      title: title ?? this.title,
      dependsOn: dependsOn ?? this.dependsOn,
      travelerIds: travelerIds ?? this.travelerIds,
      plannedDate: plannedDate ?? this.plannedDate,
      plannedDateCertainty: plannedDateCertainty ?? this.plannedDateCertainty,
      officialDeadline: officialDeadline ?? this.officialDeadline,
      internalTargetDate: internalTargetDate ?? this.internalTargetDate,
      recommendedStartDate: recommendedStartDate ?? this.recommendedStartDate,
      recommendedCompletionDate:
          recommendedCompletionDate ?? this.recommendedCompletionDate,
      bufferDays: bufferDays ?? this.bufferDays,
      processingDurationDays:
          processingDurationDays ?? this.processingDurationDays,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      templateId: templateId ?? this.templateId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (title != null) 'title': title,
    'dependsOn': dependsOn,
    'travelerIds': travelerIds,
    if (plannedDate != null) 'plannedDate': plannedDate,
    'plannedDateCertainty': plannedDateCertainty.name,
    if (officialDeadline != null) 'officialDeadline': officialDeadline,
    if (internalTargetDate != null) 'internalTargetDate': internalTargetDate,
    if (recommendedStartDate != null)
      'recommendedStartDate': recommendedStartDate,
    if (recommendedCompletionDate != null)
      'recommendedCompletionDate': recommendedCompletionDate,
    if (bufferDays != null) 'bufferDays': bufferDays,
    if (processingDurationDays != null)
      'processingDurationDays': processingDurationDays,
    'status': status.name,
    if (notes != null) 'notes': notes,
    if (templateId != null) 'templateId': templateId,
  };

  factory HajjMilestone.fromJson(Map<String, dynamic> json) {
    return HajjMilestone(
      id: _optString(json, 'id') ?? '',
      title: _optString(json, 'title'),
      dependsOn: _stringList(json['dependsOn']),
      travelerIds: _stringList(json['travelerIds']),
      plannedDate: _optString(json, 'plannedDate'),
      plannedDateCertainty: HajjDateCertaintyX.fromId(
        _optString(json, 'plannedDateCertainty'),
      ),
      officialDeadline: _optString(json, 'officialDeadline'),
      internalTargetDate: _optString(json, 'internalTargetDate'),
      recommendedStartDate: _optString(json, 'recommendedStartDate'),
      recommendedCompletionDate: _optString(json, 'recommendedCompletionDate'),
      bufferDays: _optInt(json, 'bufferDays'),
      processingDurationDays: _optInt(json, 'processingDurationDays'),
      status: HajjMilestoneStatusX.fromId(_optString(json, 'status')),
      notes: _optString(json, 'notes'),
      templateId: _optString(json, 'templateId'),
    );
  }
}

/// Reserved for a later provider-directory UI. Stored empty in Phase 1.
class HajjProviderSlot {
  const HajjProviderSlot({
    required this.id,
    this.kind,
    this.status,
    this.name,
    this.country,
    this.serviceArea,
    this.season,
    this.contact,
    this.packageInfo,
    this.sourceUri,
    this.retrievedAt,
    this.authorizationEvidence,
    this.independentReview,
    this.officiallyAuthorized = false,
    this.demonstration = false,
  });

  final String id;
  final String? kind;
  final String? status;
  final String? name;
  final String? country;
  final String? serviceArea;
  final String? season;
  final String? contact;
  final String? packageInfo;
  final String? sourceUri;
  final String? retrievedAt;
  final String? authorizationEvidence;
  final String? independentReview;
  final bool officiallyAuthorized;
  final bool demonstration;

  Map<String, dynamic> toJson() => {
    'id': id,
    if (kind != null) 'kind': kind,
    if (status != null) 'status': status,
    if (name != null) 'name': name,
    if (country != null) 'country': country,
    if (serviceArea != null) 'serviceArea': serviceArea,
    if (season != null) 'season': season,
    if (contact != null) 'contact': contact,
    if (packageInfo != null) 'packageInfo': packageInfo,
    if (sourceUri != null) 'sourceUri': sourceUri,
    if (retrievedAt != null) 'retrievedAt': retrievedAt,
    if (authorizationEvidence != null)
      'authorizationEvidence': authorizationEvidence,
    if (independentReview != null) 'independentReview': independentReview,
    'officiallyAuthorized': officiallyAuthorized,
    'demonstration': demonstration,
  };

  factory HajjProviderSlot.fromJson(Map<String, dynamic> json) {
    return HajjProviderSlot(
      id: _optString(json, 'id') ?? '',
      kind: _optString(json, 'kind'),
      status: _optString(json, 'status'),
      name: _optString(json, 'name'),
      country: _optString(json, 'country'),
      serviceArea: _optString(json, 'serviceArea'),
      season: _optString(json, 'season'),
      contact: _optString(json, 'contact'),
      packageInfo: _optString(json, 'packageInfo'),
      sourceUri: _optString(json, 'sourceUri'),
      retrievedAt: _optString(json, 'retrievedAt'),
      authorizationEvidence: _optString(json, 'authorizationEvidence'),
      independentReview: _optString(json, 'independentReview'),
      officiallyAuthorized: json['officiallyAuthorized'] == true,
      demonstration: json['demonstration'] == true,
    );
  }
}

/// Reserved for later travel-leg UI.
class HajjTravelLeg {
  const HajjTravelLeg({required this.id, this.notes});

  final String id;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'id': id,
    if (notes != null) 'notes': notes,
  };

  factory HajjTravelLeg.fromJson(Map<String, dynamic> json) {
    return HajjTravelLeg(
      id: _optString(json, 'id') ?? '',
      notes: _optString(json, 'notes'),
    );
  }
}

enum HajjReturnScenarioKind {
  standardPackage,
  earlyAfterRites,
  differentCountry,
}

extension HajjReturnScenarioKindX on HajjReturnScenarioKind {
  String get label => switch (this) {
    HajjReturnScenarioKind.standardPackage => 'Standard package return',
    HajjReturnScenarioKind.earlyAfterRites =>
      'Earlier return after completing the required Hajj rites',
    HajjReturnScenarioKind.differentCountry =>
      'Return to a different country from departure',
  };

  static HajjReturnScenarioKind fromId(String? id) {
    if (id == null || id.isEmpty) {
      return HajjReturnScenarioKind.standardPackage;
    }
    return HajjReturnScenarioKind.values.firstWhere(
      (item) => item.name == id,
      orElse: () => HajjReturnScenarioKind.standardPackage,
    );
  }
}

class HajjReturnScenario {
  const HajjReturnScenario({
    required this.kind,
    this.packageCost,
    this.changeFees,
    this.extraTransport,
    this.extraAccommodation,
    this.confirmedRefunds,
    this.packageRestrictions,
    this.leaveImplications,
    this.familyCoordination,
    this.residenceReentry,
  });

  final HajjReturnScenarioKind kind;
  final int? packageCost;
  final int? changeFees;
  final int? extraTransport;
  final int? extraAccommodation;
  final int? confirmedRefunds;
  final String? packageRestrictions;
  final String? leaveImplications;
  final String? familyCoordination;
  final String? residenceReentry;

  HajjReturnScenario copyWith({
    int? packageCost,
    int? changeFees,
    int? extraTransport,
    int? extraAccommodation,
    int? confirmedRefunds,
    String? packageRestrictions,
    String? leaveImplications,
    String? familyCoordination,
    String? residenceReentry,
  }) {
    return HajjReturnScenario(
      kind: kind,
      packageCost: packageCost ?? this.packageCost,
      changeFees: changeFees ?? this.changeFees,
      extraTransport: extraTransport ?? this.extraTransport,
      extraAccommodation: extraAccommodation ?? this.extraAccommodation,
      confirmedRefunds: confirmedRefunds ?? this.confirmedRefunds,
      packageRestrictions: packageRestrictions ?? this.packageRestrictions,
      leaveImplications: leaveImplications ?? this.leaveImplications,
      familyCoordination: familyCoordination ?? this.familyCoordination,
      residenceReentry: residenceReentry ?? this.residenceReentry,
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    if (packageCost != null) 'packageCost': packageCost,
    if (changeFees != null) 'changeFees': changeFees,
    if (extraTransport != null) 'extraTransport': extraTransport,
    if (extraAccommodation != null) 'extraAccommodation': extraAccommodation,
    if (confirmedRefunds != null) 'confirmedRefunds': confirmedRefunds,
    if (packageRestrictions != null) 'packageRestrictions': packageRestrictions,
    if (leaveImplications != null) 'leaveImplications': leaveImplications,
    if (familyCoordination != null) 'familyCoordination': familyCoordination,
    if (residenceReentry != null) 'residenceReentry': residenceReentry,
  };

  factory HajjReturnScenario.fromJson(
    Map<String, dynamic>? json, {
    required HajjReturnScenarioKind fallback,
  }) {
    if (json == null) return HajjReturnScenario(kind: fallback);
    return HajjReturnScenario(
      kind: HajjReturnScenarioKindX.fromId(_optString(json, 'kind')),
      packageCost: _optInt(json, 'packageCost'),
      changeFees: _optInt(json, 'changeFees'),
      extraTransport: _optInt(json, 'extraTransport'),
      extraAccommodation: _optInt(json, 'extraAccommodation'),
      confirmedRefunds: _optInt(json, 'confirmedRefunds'),
      packageRestrictions: _optString(json, 'packageRestrictions'),
      leaveImplications: _optString(json, 'leaveImplications'),
      familyCoordination: _optString(json, 'familyCoordination'),
      residenceReentry: _optString(json, 'residenceReentry'),
    );
  }
}

class HajjPlanningInputs {
  const HajjPlanningInputs({
    this.expectedHajjPeriodStart,
    this.expectedHajjPeriodEnd,
    this.registrationAuthority,
    this.registrationOpenDate,
    this.registrationCloseDate,
    this.packageBookingDeadline,
    this.workLeaveNote,
    this.familyCommitmentsNote,
    this.healthAccessibilityNote,
    this.budgetAmount,
    this.returnFlexibilityNote,
    this.suggestedPathwayIds = const [],
    this.confirmedPathwayIds = const [],
    this.pathwaysConfirmedByUser = false,
    this.templatesApplied = false,
  });

  final String? expectedHajjPeriodStart;
  final String? expectedHajjPeriodEnd;
  final String? registrationAuthority;
  final String? registrationOpenDate;
  final String? registrationCloseDate;
  final String? packageBookingDeadline;
  final String? workLeaveNote;
  final String? familyCommitmentsNote;
  final String? healthAccessibilityNote;
  final int? budgetAmount;
  final String? returnFlexibilityNote;
  final List<String> suggestedPathwayIds;
  final List<String> confirmedPathwayIds;
  final bool pathwaysConfirmedByUser;
  final bool templatesApplied;

  HajjPlanningInputs copyWith({
    String? expectedHajjPeriodStart,
    String? expectedHajjPeriodEnd,
    String? registrationAuthority,
    String? registrationOpenDate,
    String? registrationCloseDate,
    String? packageBookingDeadline,
    String? workLeaveNote,
    String? familyCommitmentsNote,
    String? healthAccessibilityNote,
    int? budgetAmount,
    String? returnFlexibilityNote,
    List<String>? suggestedPathwayIds,
    List<String>? confirmedPathwayIds,
    bool? pathwaysConfirmedByUser,
    bool? templatesApplied,
  }) {
    return HajjPlanningInputs(
      expectedHajjPeriodStart:
          expectedHajjPeriodStart ?? this.expectedHajjPeriodStart,
      expectedHajjPeriodEnd:
          expectedHajjPeriodEnd ?? this.expectedHajjPeriodEnd,
      registrationAuthority:
          registrationAuthority ?? this.registrationAuthority,
      registrationOpenDate: registrationOpenDate ?? this.registrationOpenDate,
      registrationCloseDate:
          registrationCloseDate ?? this.registrationCloseDate,
      packageBookingDeadline:
          packageBookingDeadline ?? this.packageBookingDeadline,
      workLeaveNote: workLeaveNote ?? this.workLeaveNote,
      familyCommitmentsNote:
          familyCommitmentsNote ?? this.familyCommitmentsNote,
      healthAccessibilityNote:
          healthAccessibilityNote ?? this.healthAccessibilityNote,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      returnFlexibilityNote:
          returnFlexibilityNote ?? this.returnFlexibilityNote,
      suggestedPathwayIds: suggestedPathwayIds ?? this.suggestedPathwayIds,
      confirmedPathwayIds: confirmedPathwayIds ?? this.confirmedPathwayIds,
      pathwaysConfirmedByUser:
          pathwaysConfirmedByUser ?? this.pathwaysConfirmedByUser,
      templatesApplied: templatesApplied ?? this.templatesApplied,
    );
  }

  Map<String, dynamic> toJson() => {
    if (expectedHajjPeriodStart != null)
      'expectedHajjPeriodStart': expectedHajjPeriodStart,
    if (expectedHajjPeriodEnd != null)
      'expectedHajjPeriodEnd': expectedHajjPeriodEnd,
    if (registrationAuthority != null)
      'registrationAuthority': registrationAuthority,
    if (registrationOpenDate != null)
      'registrationOpenDate': registrationOpenDate,
    if (registrationCloseDate != null)
      'registrationCloseDate': registrationCloseDate,
    if (packageBookingDeadline != null)
      'packageBookingDeadline': packageBookingDeadline,
    if (workLeaveNote != null) 'workLeaveNote': workLeaveNote,
    if (familyCommitmentsNote != null)
      'familyCommitmentsNote': familyCommitmentsNote,
    if (healthAccessibilityNote != null)
      'healthAccessibilityNote': healthAccessibilityNote,
    if (budgetAmount != null) 'budgetAmount': budgetAmount,
    if (returnFlexibilityNote != null)
      'returnFlexibilityNote': returnFlexibilityNote,
    'suggestedPathwayIds': suggestedPathwayIds,
    'confirmedPathwayIds': confirmedPathwayIds,
    'pathwaysConfirmedByUser': pathwaysConfirmedByUser,
    'templatesApplied': templatesApplied,
  };

  factory HajjPlanningInputs.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HajjPlanningInputs();
    return HajjPlanningInputs(
      expectedHajjPeriodStart: _optString(json, 'expectedHajjPeriodStart'),
      expectedHajjPeriodEnd: _optString(json, 'expectedHajjPeriodEnd'),
      registrationAuthority: _optString(json, 'registrationAuthority'),
      registrationOpenDate: _optString(json, 'registrationOpenDate'),
      registrationCloseDate: _optString(json, 'registrationCloseDate'),
      packageBookingDeadline: _optString(json, 'packageBookingDeadline'),
      workLeaveNote: _optString(json, 'workLeaveNote'),
      familyCommitmentsNote: _optString(json, 'familyCommitmentsNote'),
      healthAccessibilityNote: _optString(json, 'healthAccessibilityNote'),
      budgetAmount: _optInt(json, 'budgetAmount'),
      returnFlexibilityNote: _optString(json, 'returnFlexibilityNote'),
      suggestedPathwayIds: _stringList(json['suggestedPathwayIds']),
      confirmedPathwayIds: _stringList(json['confirmedPathwayIds']),
      pathwaysConfirmedByUser: json['pathwaysConfirmedByUser'] == true,
      templatesApplied: json['templatesApplied'] == true,
    );
  }
}

class HajjJourneyReturnPlan {
  const HajjJourneyReturnPlan({
    this.status,
    this.notes,
    this.selectedKind = HajjReturnScenarioKind.standardPackage,
    this.standard = const HajjReturnScenario(
      kind: HajjReturnScenarioKind.standardPackage,
    ),
    this.earlyAfterRites = const HajjReturnScenario(
      kind: HajjReturnScenarioKind.earlyAfterRites,
    ),
    this.differentCountry = const HajjReturnScenario(
      kind: HajjReturnScenarioKind.differentCountry,
    ),
  });

  final String? status;
  final String? notes;
  final HajjReturnScenarioKind selectedKind;
  final HajjReturnScenario standard;
  final HajjReturnScenario earlyAfterRites;
  final HajjReturnScenario differentCountry;

  HajjReturnScenario get selected => switch (selectedKind) {
    HajjReturnScenarioKind.standardPackage => standard,
    HajjReturnScenarioKind.earlyAfterRites => earlyAfterRites,
    HajjReturnScenarioKind.differentCountry => differentCountry,
  };

  HajjJourneyReturnPlan copyWith({
    String? status,
    String? notes,
    HajjReturnScenarioKind? selectedKind,
    HajjReturnScenario? standard,
    HajjReturnScenario? earlyAfterRites,
    HajjReturnScenario? differentCountry,
  }) {
    return HajjJourneyReturnPlan(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      selectedKind: selectedKind ?? this.selectedKind,
      standard: standard ?? this.standard,
      earlyAfterRites: earlyAfterRites ?? this.earlyAfterRites,
      differentCountry: differentCountry ?? this.differentCountry,
    );
  }

  Map<String, dynamic> toJson() => {
    if (status != null) 'status': status,
    if (notes != null) 'notes': notes,
    'selectedKind': selectedKind.name,
    'standard': standard.toJson(),
    'earlyAfterRites': earlyAfterRites.toJson(),
    'differentCountry': differentCountry.toJson(),
  };

  factory HajjJourneyReturnPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HajjJourneyReturnPlan();
    return HajjJourneyReturnPlan(
      status: _optString(json, 'status'),
      notes: _optString(json, 'notes'),
      selectedKind: HajjReturnScenarioKindX.fromId(
        _optString(json, 'selectedKind'),
      ),
      standard: HajjReturnScenario.fromJson(
        _asMap(json['standard']),
        fallback: HajjReturnScenarioKind.standardPackage,
      ),
      earlyAfterRites: HajjReturnScenario.fromJson(
        _asMap(json['earlyAfterRites']),
        fallback: HajjReturnScenarioKind.earlyAfterRites,
      ),
      differentCountry: HajjReturnScenario.fromJson(
        _asMap(json['differentCountry']),
        fallback: HajjReturnScenarioKind.differentCountry,
      ),
    );
  }
}

class HajjJourney {
  const HajjJourney({
    required this.id,
    this.lifecycle = HajjJourneyLifecycle.considering,
    this.archived = false,
    this.targetSeason = const HajjSeason(datesUnknown: true),
    this.routeTags = const [],
    this.countries = const [],
    this.departureCountry,
    this.returnCountry,
    this.intendedDepartureDate,
    this.intendedReturnDate,
    this.datesUnknown = true,
    this.dateCertainty = HajjDateCertainty.unknown,
    this.horizonMonths,
    this.budgetNote,
    this.travelPreferences,
    this.travelerIds = const [],
    this.readiness = const [],
    this.milestones = const [],
    this.sourceIds = const [],
    this.providers = const [],
    this.travelLegs = const [],
    this.returnPlan = const HajjJourneyReturnPlan(),
    this.notes,
    this.planning = const HajjPlanningInputs(),
  });

  final String id;
  final HajjJourneyLifecycle lifecycle;
  final bool archived;
  final HajjSeason targetSeason;
  final List<String> routeTags;
  final List<String> countries;
  final String? departureCountry;
  final String? returnCountry;
  final String? intendedDepartureDate;
  final String? intendedReturnDate;
  final bool datesUnknown;
  final HajjDateCertainty dateCertainty;
  final int? horizonMonths;
  final String? budgetNote;
  final String? travelPreferences;
  final List<String> travelerIds;
  final List<HajjReadinessPrerequisite> readiness;
  final List<HajjMilestone> milestones;
  final List<String> sourceIds;
  final List<HajjProviderSlot> providers;
  final List<HajjTravelLeg> travelLegs;
  final HajjJourneyReturnPlan returnPlan;
  final String? notes;
  final HajjPlanningInputs planning;

  HajjJourney copyWith({
    HajjJourneyLifecycle? lifecycle,
    bool? archived,
    HajjSeason? targetSeason,
    List<String>? routeTags,
    List<String>? countries,
    String? departureCountry,
    String? returnCountry,
    String? intendedDepartureDate,
    String? intendedReturnDate,
    bool? datesUnknown,
    HajjDateCertainty? dateCertainty,
    int? horizonMonths,
    String? budgetNote,
    String? travelPreferences,
    List<String>? travelerIds,
    List<HajjReadinessPrerequisite>? readiness,
    List<HajjMilestone>? milestones,
    List<String>? sourceIds,
    List<HajjProviderSlot>? providers,
    List<HajjTravelLeg>? travelLegs,
    HajjJourneyReturnPlan? returnPlan,
    String? notes,
    HajjPlanningInputs? planning,
  }) {
    return HajjJourney(
      id: id,
      lifecycle: lifecycle ?? this.lifecycle,
      archived: archived ?? this.archived,
      targetSeason: targetSeason ?? this.targetSeason,
      routeTags: routeTags ?? this.routeTags,
      countries: countries ?? this.countries,
      departureCountry: departureCountry ?? this.departureCountry,
      returnCountry: returnCountry ?? this.returnCountry,
      intendedDepartureDate:
          intendedDepartureDate ?? this.intendedDepartureDate,
      intendedReturnDate: intendedReturnDate ?? this.intendedReturnDate,
      datesUnknown: datesUnknown ?? this.datesUnknown,
      dateCertainty: dateCertainty ?? this.dateCertainty,
      horizonMonths: horizonMonths ?? this.horizonMonths,
      budgetNote: budgetNote ?? this.budgetNote,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      travelerIds: travelerIds ?? this.travelerIds,
      readiness: readiness ?? this.readiness,
      milestones: milestones ?? this.milestones,
      sourceIds: sourceIds ?? this.sourceIds,
      providers: providers ?? this.providers,
      travelLegs: travelLegs ?? this.travelLegs,
      returnPlan: returnPlan ?? this.returnPlan,
      notes: notes ?? this.notes,
      planning: planning ?? this.planning,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lifecycle': lifecycle.name,
    'archived': archived,
    'targetSeason': targetSeason.toJson(),
    'routeTags': routeTags,
    'countries': countries,
    if (departureCountry != null) 'departureCountry': departureCountry,
    if (returnCountry != null) 'returnCountry': returnCountry,
    if (intendedDepartureDate != null)
      'intendedDepartureDate': intendedDepartureDate,
    if (intendedReturnDate != null) 'intendedReturnDate': intendedReturnDate,
    'datesUnknown': datesUnknown,
    'dateCertainty': dateCertainty.name,
    if (horizonMonths != null) 'horizonMonths': horizonMonths,
    if (budgetNote != null) 'budgetNote': budgetNote,
    if (travelPreferences != null) 'travelPreferences': travelPreferences,
    'travelerIds': travelerIds,
    'readiness': [for (final item in readiness) item.toJson()],
    'milestones': [for (final item in milestones) item.toJson()],
    'sourceIds': sourceIds,
    'providers': [for (final item in providers) item.toJson()],
    'travelLegs': [for (final item in travelLegs) item.toJson()],
    'returnPlan': returnPlan.toJson(),
    if (notes != null) 'notes': notes,
    'planning': planning.toJson(),
  };

  factory HajjJourney.fromJson(Map<String, dynamic> json) {
    return HajjJourney(
      id: _optString(json, 'id') ?? '',
      lifecycle: HajjJourneyLifecycleX.fromId(_optString(json, 'lifecycle')),
      archived: json['archived'] == true,
      targetSeason: HajjSeason.fromJson(_asMap(json['targetSeason'])),
      routeTags: _stringList(json['routeTags']),
      countries: _stringList(json['countries']),
      departureCountry: _optString(json, 'departureCountry'),
      returnCountry: _optString(json, 'returnCountry'),
      intendedDepartureDate: _optString(json, 'intendedDepartureDate'),
      intendedReturnDate: _optString(json, 'intendedReturnDate'),
      datesUnknown: json['datesUnknown'] != false,
      dateCertainty: HajjDateCertaintyX.fromId(
        _optString(json, 'dateCertainty'),
      ),
      horizonMonths: _optInt(json, 'horizonMonths'),
      budgetNote: _optString(json, 'budgetNote'),
      travelPreferences: _optString(json, 'travelPreferences'),
      travelerIds: _stringList(json['travelerIds']),
      readiness: [
        for (final item in _mapList(json['readiness']))
          HajjReadinessPrerequisite.fromJson(item),
      ],
      milestones: [
        for (final item in _mapList(json['milestones']))
          HajjMilestone.fromJson(item),
      ],
      sourceIds: _stringList(json['sourceIds']),
      providers: [
        for (final item in _mapList(json['providers']))
          HajjProviderSlot.fromJson(item),
      ],
      travelLegs: [
        for (final item in _mapList(json['travelLegs']))
          HajjTravelLeg.fromJson(item),
      ],
      returnPlan: HajjJourneyReturnPlan.fromJson(_asMap(json['returnPlan'])),
      notes: _optString(json, 'notes'),
      planning: HajjPlanningInputs.fromJson(_asMap(json['planning'])),
    );
  }
}

class HajjAfterRecord {
  const HajjAfterRecord({
    this.reflectionText,
    this.continuingPracticeIds = const [],
    this.returnIntention = HajjAfterReturnIntention.unanswered,
    this.updatedAt,
  });

  final String? reflectionText;
  final List<String> continuingPracticeIds;
  final HajjAfterReturnIntention returnIntention;
  final String? updatedAt;

  bool get isEmpty =>
      (reflectionText == null || reflectionText!.isEmpty) &&
      continuingPracticeIds.isEmpty &&
      returnIntention == HajjAfterReturnIntention.unanswered;

  HajjAfterRecord copyWith({
    String? reflectionText,
    List<String>? continuingPracticeIds,
    HajjAfterReturnIntention? returnIntention,
    String? updatedAt,
  }) {
    return HajjAfterRecord(
      reflectionText: reflectionText ?? this.reflectionText,
      continuingPracticeIds:
          continuingPracticeIds ?? this.continuingPracticeIds,
      returnIntention: returnIntention ?? this.returnIntention,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    if (reflectionText != null) 'reflectionText': reflectionText,
    'continuingPracticeIds': continuingPracticeIds,
    'returnIntention': returnIntention.name,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };

  factory HajjAfterRecord.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HajjAfterRecord();
    return HajjAfterRecord(
      reflectionText: _optString(json, 'reflectionText'),
      continuingPracticeIds: _stringList(json['continuingPracticeIds']),
      returnIntention: HajjAfterReturnIntentionX.fromId(
        _optString(json, 'returnIntention'),
      ),
      updatedAt: _optString(json, 'updatedAt'),
    );
  }
}

class HajjLearningProgress {
  const HajjLearningProgress({
    required this.topicId,
    this.state = HajjLearningState.notStarted,
  });

  final String topicId;
  final HajjLearningState state;

  Map<String, dynamic> toJson() => {'topicId': topicId, 'state': state.name};

  factory HajjLearningProgress.fromJson(Map<String, dynamic> json) {
    return HajjLearningProgress(
      topicId: _optString(json, 'topicId') ?? '',
      state: HajjLearningStateX.fromId(_optString(json, 'state')),
    );
  }
}

class HajjOnlineAssistConsent {
  const HajjOnlineAssistConsent({
    this.lookupConsented = false,
    this.aiConsented = false,
    this.acknowledgedAt,
    this.revokedAt,
  });

  final bool lookupConsented;
  final bool aiConsented;
  final String? acknowledgedAt;
  final String? revokedAt;

  bool get anyOnline => lookupConsented || aiConsented;

  HajjOnlineAssistConsent copyWith({
    bool? lookupConsented,
    bool? aiConsented,
    String? acknowledgedAt,
    String? revokedAt,
  }) {
    return HajjOnlineAssistConsent(
      lookupConsented: lookupConsented ?? this.lookupConsented,
      aiConsented: aiConsented ?? this.aiConsented,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'lookupConsented': lookupConsented,
    'aiConsented': aiConsented,
    if (acknowledgedAt != null) 'acknowledgedAt': acknowledgedAt,
    if (revokedAt != null) 'revokedAt': revokedAt,
  };

  factory HajjOnlineAssistConsent.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HajjOnlineAssistConsent();
    return HajjOnlineAssistConsent(
      lookupConsented: json['lookupConsented'] == true,
      aiConsented: json['aiConsented'] == true,
      acknowledgedAt: _optString(json, 'acknowledgedAt'),
      revokedAt: _optString(json, 'revokedAt'),
    );
  }
}

class HajjPlanProposal {
  const HajjPlanProposal({
    required this.id,
    required this.title,
    required this.detail,
    this.origin = HajjProvenanceKind.aiInterpretation,
    this.milestoneTitle,
    this.accepted = false,
    this.dismissed = false,
    this.sourceIds = const [],
    this.extractedRequirement,
    this.jurisdiction,
    this.season,
    this.retrievedAt,
    this.uncertaintyNote,
    this.requiresUserApproval = true,
  });

  final String id;
  final String title;
  final String detail;
  final HajjProvenanceKind origin;
  final String? milestoneTitle;
  final bool accepted;
  final bool dismissed;
  final List<String> sourceIds;
  final String? extractedRequirement;
  final String? jurisdiction;
  final String? season;
  final String? retrievedAt;
  final String? uncertaintyNote;
  final bool requiresUserApproval;

  HajjPlanProposal copyWith({bool? accepted, bool? dismissed}) {
    return HajjPlanProposal(
      id: id,
      title: title,
      detail: detail,
      origin: origin,
      milestoneTitle: milestoneTitle,
      accepted: accepted ?? this.accepted,
      dismissed: dismissed ?? this.dismissed,
      sourceIds: sourceIds,
      extractedRequirement: extractedRequirement,
      jurisdiction: jurisdiction,
      season: season,
      retrievedAt: retrievedAt,
      uncertaintyNote: uncertaintyNote,
      requiresUserApproval: requiresUserApproval,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'detail': detail,
    'origin': origin.name,
    if (milestoneTitle != null) 'milestoneTitle': milestoneTitle,
    'accepted': accepted,
    'dismissed': dismissed,
    'sourceIds': sourceIds,
    if (extractedRequirement != null)
      'extractedRequirement': extractedRequirement,
    if (jurisdiction != null) 'jurisdiction': jurisdiction,
    if (season != null) 'season': season,
    if (retrievedAt != null) 'retrievedAt': retrievedAt,
    if (uncertaintyNote != null) 'uncertaintyNote': uncertaintyNote,
    'requiresUserApproval': requiresUserApproval,
  };

  factory HajjPlanProposal.fromJson(Map<String, dynamic> json) {
    return HajjPlanProposal(
      id: _optString(json, 'id') ?? '',
      title: _optString(json, 'title') ?? '',
      detail: _optString(json, 'detail') ?? '',
      origin: HajjProvenanceKindX.fromId(_optString(json, 'origin')),
      milestoneTitle: _optString(json, 'milestoneTitle'),
      accepted: json['accepted'] == true,
      dismissed: json['dismissed'] == true,
      sourceIds: _stringList(json['sourceIds']),
      extractedRequirement: _optString(json, 'extractedRequirement'),
      jurisdiction: _optString(json, 'jurisdiction'),
      season: _optString(json, 'season'),
      retrievedAt: _optString(json, 'retrievedAt'),
      uncertaintyNote: _optString(json, 'uncertaintyNote'),
      requiresUserApproval: json['requiresUserApproval'] != false,
    );
  }
}

class HajjStore {
  const HajjStore({
    this.schemaVersion = kHajjStoreSchemaVersion,
    this.standing = const HajjStandingRecord(),
    this.standingHistory = const [],
    this.travelers = const [],
    this.journeys = const [],
    this.sources = const [],
    this.afterHajj = const HajjAfterRecord(),
    this.providers = const [],
    this.activeJourneyId,
    this.learningProgress = const [],
    this.onlineAssist = const HajjOnlineAssistConsent(),
    this.pendingProposals = const [],
  });

  final int schemaVersion;
  final HajjStandingRecord standing;
  final List<HajjStandingEvent> standingHistory;
  final List<HajjTravelerProfile> travelers;
  final List<HajjJourney> journeys;
  final List<HajjOfficialSource> sources;
  final HajjAfterRecord afterHajj;

  /// Store-level provider slots for a later directory UI.
  final List<HajjProviderSlot> providers;
  final String? activeJourneyId;
  final List<HajjLearningProgress> learningProgress;
  final HajjOnlineAssistConsent onlineAssist;
  final List<HajjPlanProposal> pendingProposals;

  static const empty = HajjStore();

  List<HajjJourney> get visibleJourneys => [
    for (final journey in journeys)
      if (!journey.archived) journey,
  ];

  HajjJourney? get selectedJourney {
    for (final journey in journeys) {
      if (journey.id == activeJourneyId) return journey;
    }
    final visible = visibleJourneys;
    if (visible.length == 1) return visible.first;
    return null;
  }

  bool get hasActiveJourney => visibleJourneys.any(
    (journey) =>
        journey.lifecycle != HajjJourneyLifecycle.cancelled &&
        journey.lifecycle != HajjJourneyLifecycle.completed &&
        journey.lifecycle != HajjJourneyLifecycle.deferred,
  );

  HajjStore copyWith({
    HajjStandingRecord? standing,
    List<HajjStandingEvent>? standingHistory,
    List<HajjTravelerProfile>? travelers,
    List<HajjJourney>? journeys,
    List<HajjOfficialSource>? sources,
    HajjAfterRecord? afterHajj,
    List<HajjProviderSlot>? providers,
    String? activeJourneyId,
    List<HajjLearningProgress>? learningProgress,
    HajjOnlineAssistConsent? onlineAssist,
    List<HajjPlanProposal>? pendingProposals,
  }) {
    return HajjStore(
      schemaVersion: kHajjStoreSchemaVersion,
      standing: standing ?? this.standing,
      standingHistory: standingHistory ?? this.standingHistory,
      travelers: travelers ?? this.travelers,
      journeys: journeys ?? this.journeys,
      sources: sources ?? this.sources,
      afterHajj: afterHajj ?? this.afterHajj,
      providers: providers ?? this.providers,
      activeJourneyId: activeJourneyId ?? this.activeJourneyId,
      learningProgress: learningProgress ?? this.learningProgress,
      onlineAssist: onlineAssist ?? this.onlineAssist,
      pendingProposals: pendingProposals ?? this.pendingProposals,
    );
  }

  HajjStore withStanding(
    HajjStandingKind kind, {
    required String recordedAt,
    String? note,
  }) {
    final next = HajjStandingRecord(
      kind: kind,
      updatedAt: recordedAt,
      note: note,
    );
    if (standing.kind == kind && standing.note == note) {
      return copyWith(standing: next);
    }
    return copyWith(
      standing: next,
      standingHistory: [
        ...standingHistory,
        HajjStandingEvent(kind: kind, recordedAt: recordedAt, note: note),
      ],
    );
  }

  HajjStore upsertTraveler(HajjTravelerProfile traveler) {
    return copyWith(
      travelers: _upsertById(travelers, traveler, (item) => item.id),
    );
  }

  HajjStore deleteTraveler(String id) {
    return copyWith(
      travelers: [
        for (final item in travelers)
          if (item.id != id) item,
      ],
      journeys: [
        for (final journey in journeys)
          journey.copyWith(
            travelerIds: [
              for (final travelerId in journey.travelerIds)
                if (travelerId != id) travelerId,
            ],
          ),
      ],
    );
  }

  HajjStore upsertJourney(HajjJourney journey) {
    return copyWith(
      journeys: _upsertById(journeys, journey, (item) => item.id),
      activeJourneyId: activeJourneyId ?? journey.id,
    );
  }

  HajjStore selectJourney(String id) => copyWith(activeJourneyId: id);

  HajjStore archiveJourney(String id) {
    return copyWith(
      journeys: [
        for (final item in journeys)
          if (item.id == id) item.copyWith(archived: true) else item,
      ],
    );
  }

  HajjStore deleteJourney(String id) {
    return HajjStore(
      schemaVersion: kHajjStoreSchemaVersion,
      standing: standing,
      standingHistory: standingHistory,
      travelers: travelers,
      journeys: [
        for (final item in journeys)
          if (item.id != id) item,
      ],
      sources: sources,
      afterHajj: afterHajj,
      providers: providers,
      activeJourneyId: activeJourneyId == id ? null : activeJourneyId,
      learningProgress: learningProgress,
      onlineAssist: onlineAssist,
      pendingProposals: pendingProposals,
    );
  }

  HajjStore withLearningState(String topicId, HajjLearningState state) {
    return copyWith(
      learningProgress: _upsertById(
        learningProgress,
        HajjLearningProgress(topicId: topicId, state: state),
        (item) => item.topicId,
      ),
    );
  }

  HajjLearningState learningStateFor(String topicId) {
    for (final item in learningProgress) {
      if (item.topicId == topicId) return item.state;
    }
    return HajjLearningState.notStarted;
  }

  HajjStore upsertProvider(HajjProviderSlot provider) {
    return copyWith(
      providers: _upsertById(providers, provider, (item) => item.id),
    );
  }

  HajjStore upsertSource(HajjOfficialSource source) {
    return copyWith(sources: _upsertById(sources, source, (item) => item.id));
  }

  HajjStore deleteSource(String id) {
    return copyWith(
      sources: [
        for (final item in sources)
          if (item.id != id) item,
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'standing': standing.toJson(),
    'standingHistory': [for (final item in standingHistory) item.toJson()],
    'travelers': [for (final item in travelers) item.toJson()],
    'journeys': [for (final item in journeys) item.toJson()],
    'sources': [for (final item in sources) item.toJson()],
    'afterHajj': afterHajj.toJson(),
    'providers': [for (final item in providers) item.toJson()],
    if (activeJourneyId != null) 'activeJourneyId': activeJourneyId,
    'learningProgress': [for (final item in learningProgress) item.toJson()],
    'onlineAssist': onlineAssist.toJson(),
    'pendingProposals': [for (final item in pendingProposals) item.toJson()],
  };

  factory HajjStore.fromJson(Map<String, dynamic> json) {
    return HajjStore(
      schemaVersion: _optInt(json, 'schemaVersion') ?? kHajjStoreSchemaVersion,
      standing: HajjStandingRecord.fromJson(_asMap(json['standing']) ?? {}),
      standingHistory: [
        for (final item in _mapList(json['standingHistory']))
          HajjStandingEvent.fromJson(item),
      ],
      travelers: [
        for (final item in _mapList(json['travelers']))
          HajjTravelerProfile.fromJson(item),
      ],
      journeys: [
        for (final item in _mapList(json['journeys']))
          HajjJourney.fromJson(item),
      ],
      sources: [
        for (final item in _mapList(json['sources']))
          HajjOfficialSource.fromJson(item),
      ],
      afterHajj: HajjAfterRecord.fromJson(_asMap(json['afterHajj'])),
      providers: [
        for (final item in _mapList(json['providers']))
          HajjProviderSlot.fromJson(item),
      ],
      activeJourneyId: _optString(json, 'activeJourneyId'),
      learningProgress: [
        for (final item in _mapList(json['learningProgress']))
          HajjLearningProgress.fromJson(item),
      ],
      onlineAssist: HajjOnlineAssistConsent.fromJson(
        _asMap(json['onlineAssist']),
      ),
      pendingProposals: [
        for (final item in _mapList(json['pendingProposals']))
          HajjPlanProposal.fromJson(item),
      ],
    );
  }
}

class HajjStoreDecode {
  const HajjStoreDecode._({required this.kind, this.store});

  final HajjStoreDecodeKind kind;
  final HajjStore? store;

  factory HajjStoreDecode.ok(HajjStore store) =>
      HajjStoreDecode._(kind: HajjStoreDecodeKind.ok, store: store);

  factory HajjStoreDecode.missing() =>
      const HajjStoreDecode._(kind: HajjStoreDecodeKind.missing);

  factory HajjStoreDecode.unknownVersion() =>
      const HajjStoreDecode._(kind: HajjStoreDecodeKind.unknownVersion);

  factory HajjStoreDecode.corrupt() =>
      const HajjStoreDecode._(kind: HajjStoreDecodeKind.corrupt);
}

String encodeHajjStore(HajjStore store) => jsonEncode(store.toJson());

HajjStoreDecode decodeHajjStore(String? raw) {
  if (raw == null || raw.trim().isEmpty) return HajjStoreDecode.missing();
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return HajjStoreDecode.corrupt();
    final json = Map<String, dynamic>.from(decoded);
    final version = _optInt(json, 'schemaVersion');
    if (version == null || version < 1) return HajjStoreDecode.corrupt();
    if (version > kHajjStoreSchemaVersion) {
      return HajjStoreDecode.unknownVersion();
    }
    return HajjStoreDecode.ok(HajjStore.fromJson(json));
  } catch (_) {
    return HajjStoreDecode.corrupt();
  }
}

String newHajjEntityId(String prefix, DateTime now, [int salt = 0]) {
  return '${prefix}_${now.millisecondsSinceEpoch}_$salt';
}

List<T> _upsertById<T>(List<T> items, T next, String Function(T) idOf) {
  final id = idOf(next);
  final updated = <T>[];
  var replaced = false;
  for (final item in items) {
    if (idOf(item) == id) {
      updated.add(next);
      replaced = true;
    } else {
      updated.add(item);
    }
  }
  if (!replaced) updated.add(next);
  return updated;
}

String? _optString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  final text = '$value'.trim();
  return text.isEmpty ? null : text;
}

int? _optInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return [for (final item in value) '$item'];
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}

List<HajjReadinessPrerequisite> _readinessList(dynamic value) {
  return [
    for (final item in _mapList(value))
      HajjReadinessPrerequisite.fromJson(item),
  ];
}
