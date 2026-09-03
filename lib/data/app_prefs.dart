abstract class AppPrefs {
  bool get sampleSeeded;
  bool get sampleRemovedByUser;
  bool get archivePromptDismissed;
  bool get applicationReflectionAcknowledged;

  Future<void> setSampleSeeded(bool value);
  Future<void> setSampleRemovedByUser(bool value);
  Future<void> setArchivePromptDismissed(bool value);
  Future<void> setApplicationReflectionAcknowledged(bool value);
}

class MemoryAppPrefs implements AppPrefs {
  MemoryAppPrefs({
    this.sampleSeeded = false,
    this.sampleRemovedByUser = false,
    this.archivePromptDismissed = false,
    this.applicationReflectionAcknowledged = true,
  });

  @override
  bool sampleSeeded;
  @override
  bool sampleRemovedByUser;
  @override
  bool archivePromptDismissed;
  @override
  bool applicationReflectionAcknowledged;

  @override
  Future<void> setSampleSeeded(bool value) async => sampleSeeded = value;

  @override
  Future<void> setSampleRemovedByUser(bool value) async =>
      sampleRemovedByUser = value;

  @override
  Future<void> setArchivePromptDismissed(bool value) async =>
      archivePromptDismissed = value;

  @override
  Future<void> setApplicationReflectionAcknowledged(bool value) async =>
      applicationReflectionAcknowledged = value;
}
