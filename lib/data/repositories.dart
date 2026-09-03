import '../domain/daily_check_in.dart';
import '../domain/personal_response.dart';

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
