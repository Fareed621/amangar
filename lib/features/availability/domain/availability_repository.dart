import '../../../../core/models/date_override_model.dart';
import '../../../../core/models/weekly_template_model.dart';

abstract class AvailabilityRepository {
  Future<WeeklyTemplateModel?> getWeeklyTemplate(String providerId);
  Future<List<DateOverrideModel>> getDateOverrides(String providerId, DateTime month);
  Future<Set<DateTime>> getUnavailableDates(String providerId, DateTime startMonth, DateTime endMonth);
  Future<void> saveWeeklyTemplate(String providerId, Map<String, dynamic> template);
  Future<void> setDateOverride(String providerId, DateTime date, bool isBlocked, {String? note});
  Future<void> deleteDateOverride(String providerId, DateTime date);
}
