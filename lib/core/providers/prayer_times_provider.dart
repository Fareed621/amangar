// lib/core/providers/prayer_times_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/prayer_times_service.dart';

part 'prayer_times_provider.g.dart';

/// Singleton service provider — reuse the same [http.Client] across calls.
@Riverpod(keepAlive: true)
PrayerTimesService prayerTimesService(PrayerTimesServiceRef ref) {
  return PrayerTimesService();
}

/// FutureProvider that fetches today's prayer times for Karachi.
///
/// Usage in a widget:
/// ```dart
/// final prayerAsync = ref.watch(prayerTimesProvider);
/// prayerAsync.when(
///   data:    (model) => PrayerTimesCard(model: model),
///   loading: () => const PrayerTimesCardSkeleton(),
///   error:   (e, _) => const SizedBox.shrink(),
/// );
/// ```
///
/// The provider caches the result until the widget tree is disposed.
/// Call `ref.invalidate(prayerTimesProvider)` to force a refresh.
@riverpod
Future<PrayerTimesModel> prayerTimes(PrayerTimesRef ref) async {
  final service = ref.watch(prayerTimesServiceProvider);
  return service.getPrayerTimes(city: 'Karachi', country: 'Pakistan');
}
