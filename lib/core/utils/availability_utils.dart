// lib/core/utils/availability_utils.dart
import '../constants/app_constants.dart';

/// Price calculation matching api-contracts.md Section 6.5 exactly.
int calculateDisplayPrice({
  required String serviceType,
  required int fullTimeRate,
  required int partTimeRate,
  required int numberOfDays,
  required String startTime,
  required String endTime,
}) {
  if (serviceType == 'full_time') {
    return fullTimeRate * numberOfDays;
  } else {
    final hours = calculateDurationHours(startTime, endTime);
    return (partTimeRate * hours).round();
  }
}

/// Parses HH:MM strings and returns decimal hours.
double calculateDurationHours(String startTime, String endTime) {
  try {
    final s = startTime.split(':');
    final e = endTime.split(':');
    final startMins = int.parse(s[0]) * 60 + int.parse(s[1]);
    final endMins = int.parse(e[0]) * 60 + int.parse(e[1]);
    return (endMins - startMins) / 60.0;
  } catch (_) {
    return 0.0;
  }
}

/// Returns all dates between [startDate] and [endDate] (inclusive) that
/// match any of the given [weekdays] (1=Monday … 7=Sunday, per DateTime.weekday).
/// Maximum [AppLimits.maxBookingDates] dates returned.
List<DateTime> generateRecurringDates({
  required DateTime startDate,
  required DateTime endDate,
  required List<int> weekdays,
}) {
  final result = <DateTime>[];
  var current = DateTime(startDate.year, startDate.month, startDate.day);
  final last = DateTime(endDate.year, endDate.month, endDate.day);

  while (!current.isAfter(last) && result.length < AppLimits.maxBookingDates) {
    if (weekdays.contains(current.weekday)) {
      result.add(current);
    }
    current = current.add(const Duration(days: 1));
  }
  return result;
}
