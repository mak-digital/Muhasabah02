import '../domain/daily_check_in.dart';
import '../domain/dev_feedback.dart';
import '../domain/domain_action.dart';
import '../domain/personal_response.dart';
import '../domain/personal_hadith.dart';
import '../domain/personal_quran_verse.dart';
import '../domain/practice_hadith.dart';
import '../domain/hajj_planning.dart';
import '../domain/productivity_planning.dart';

abstract class CheckInRepository {
  Future<DailyCheckIn?> getByDate(String dateKey);
  Future<List<DailyCheckIn>> allHealthy();
  Future<void> save(DailyCheckIn record);
  Future<bool> delete(String dateKey);
  List<String> get corruptKeys;
}

abstract class ResponseRepository {
  Future<PersonalResponse?> getById(String id);
  Future<List<PersonalResponse>> allHealthy();
  Future<void> save(PersonalResponse record);
  Future<bool> delete(String id);
  List<String> get corruptKeys;
}

abstract class DomainActionRepository {
  Future<DomainAction?> getById(String id);
  Future<List<DomainAction>> allHealthy();
  Future<void> save(DomainAction record);
  Future<bool> delete(String id);
  List<String> get corruptKeys;
}

abstract class PracticeHadithRepository {
  Future<PracticeHadithRecord?> getById(String id);
  Future<List<PracticeHadithRecord>> allHealthy();
  Future<void> save(PracticeHadithRecord record);
  Future<bool> delete(String id);
  List<String> get corruptKeys;
}

abstract class PersonalQuranVerseRepository {
  Future<PersonalQuranVerse?> getById(String id);
  Future<List<PersonalQuranVerse>> allHealthy();
  Future<void> save(PersonalQuranVerse record);
  Future<bool> delete(String id);
  List<String> get corruptKeys;
}

abstract class PersonalHadithRepository {
  Future<PersonalHadith?> getById(String id);
  Future<List<PersonalHadith>> allHealthy();
  Future<void> save(PersonalHadith record);
  Future<bool> delete(String id);
  List<String> get corruptKeys;
}

abstract class HajjStoreRepository {
  HajjStore get store;
  HajjStoreDecodeKind get loadKind;
  bool get hasUnknownSchema;
  Future<void> save(HajjStore store);
  Future<HajjStore> initializeIfNeeded();
}

abstract class ProductivityStoreRepository {
  ProductivityStore get store;
  ProductivityStoreDecodeKind get loadKind;
  bool get hasUnknownSchema;
  Future<void> save(ProductivityStore store);
  Future<ProductivityStore> initializeIfNeeded();
}

abstract class DevFeedbackRepository {
  Future<DevFeedback?> getById(String id);
  Future<List<DevFeedback>> allHealthy();
  Future<void> save(DevFeedback record);
  Future<bool> delete(String id);
  Future<int> nextSerial();
  List<String> get corruptKeys;
}
