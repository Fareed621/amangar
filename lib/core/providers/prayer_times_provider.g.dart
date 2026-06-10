// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$prayerTimesServiceHash() =>
    r'b7d17e8c30edc69b1275739ed20656e5c0389df7';

/// Singleton service provider — reuse the same [http.Client] across calls.
///
/// Copied from [prayerTimesService].
@ProviderFor(prayerTimesService)
final prayerTimesServiceProvider = Provider<PrayerTimesService>.internal(
  prayerTimesService,
  name: r'prayerTimesServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$prayerTimesServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrayerTimesServiceRef = ProviderRef<PrayerTimesService>;
String _$prayerTimesHash() => r'0d398e97083c64703b28368516ced94f2372359f';

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
///
/// Copied from [prayerTimes].
@ProviderFor(prayerTimes)
final prayerTimesProvider =
    AutoDisposeFutureProvider<PrayerTimesModel>.internal(
  prayerTimes,
  name: r'prayerTimesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$prayerTimesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrayerTimesRef = AutoDisposeFutureProviderRef<PrayerTimesModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
