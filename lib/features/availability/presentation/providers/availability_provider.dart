import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/weekly_template_model.dart';
import '../../data/availability_repository_impl.dart';
import '../../domain/availability_repository.dart';

part 'availability_provider.g.dart';

@riverpod
AvailabilityRepository availabilityRepository(AvailabilityRepositoryRef ref) {
  return AvailabilityRepositoryImpl();
}

@riverpod
Future<WeeklyTemplateModel?> weeklyTemplate(WeeklyTemplateRef ref, String uid) {
  return ref.read(availabilityRepositoryProvider).getWeeklyTemplate(uid);
}

@riverpod
Future<Set<DateTime>> unavailableDates(
    UnavailableDatesRef ref, String providerId, DateTime startMonth, DateTime endMonth) {
  return ref.read(availabilityRepositoryProvider).getUnavailableDates(providerId, startMonth, endMonth);
}
