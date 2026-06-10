import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/date_override_model.dart';
import '../../../../core/models/weekly_template_model.dart';
import '../domain/availability_repository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<WeeklyTemplateModel?> getWeeklyTemplate(String providerId) async {
    final doc = await _firestore.doc(FirestorePaths.weeklyTemplate(providerId)).get();
    if (doc.exists && doc.data() != null) {
      return WeeklyTemplateModel.fromFirestore(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<DateOverrideModel>> getDateOverrides(String providerId, DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snap = await _firestore
        .collection(FirestorePaths.availabilityOverrides(providerId))
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return snap.docs.map((doc) => DateOverrideModel.fromFirestore(doc)).toList();
  }

  @override
  Future<Set<DateTime>> getUnavailableDates(String providerId, DateTime startMonth, DateTime endMonth) async {
    final template = await getWeeklyTemplate(providerId);
    final overrides = <DateOverrideModel>[];
    
    DateTime currentMonth = DateTime(startMonth.year, startMonth.month, 1);
    final endLimit = DateTime(endMonth.year, endMonth.month + 1, 1);
    
    while (currentMonth.isBefore(endLimit)) {
      final monthOverrides = await getDateOverrides(providerId, currentMonth);
      overrides.addAll(monthOverrides);
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    final unavailable = <DateTime>{};
    
    if (template != null) {
      final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      DateTime curr = DateTime(startMonth.year, startMonth.month, 1);
      final lastDate = DateTime(endMonth.year, endMonth.month + 1, 0, 23, 59, 59);
      
      while (!curr.isAfter(lastDate)) {
        final dayName = days[curr.weekday - 1];
        final dayTemplate = template.template[dayName];
        if (dayTemplate == null || !dayTemplate.isAvailable) {
          unavailable.add(DateTime(curr.year, curr.month, curr.day));
        }
        curr = curr.add(const Duration(days: 1));
      }
    }

    for (final override in overrides) {
      final date = override.date.toDate();
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (override.isBlocked) {
        unavailable.add(normalizedDate);
      } else {
        unavailable.remove(normalizedDate);
      }
    }

    return unavailable;
  }

  @override
  Future<void> saveWeeklyTemplate(String providerId, Map<String, dynamic> template) async {
    await _firestore.doc(FirestorePaths.weeklyTemplate(providerId)).set(
      {'template': template},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> setDateOverride(String providerId, DateTime date, bool isBlocked, {String? note}) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final dateString = '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
    
    final override = DateOverrideModel(
      date: Timestamp.fromDate(normalized),
      isBlocked: isBlocked,
      note: note,
    );

    await _firestore
        .doc(FirestorePaths.availabilityOverride(providerId, dateString))
        .set(override.toFirestore());
  }

  @override
  Future<void> deleteDateOverride(String providerId, DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final dateString = '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
    
    await _firestore.doc(FirestorePaths.availabilityOverride(providerId, dateString)).delete();
  }
}
