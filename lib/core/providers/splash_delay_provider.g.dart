// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_delay_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$splashDelayHash() => r'68fa7c2b0ee895ac887cb0366671d057b01922b9';

/// A simple provider that waits for a minimum duration (e.g. 2s)
/// to ensure the splash screen is visible and animations can play.
///
/// Copied from [splashDelay].
@ProviderFor(splashDelay)
final splashDelayProvider = AutoDisposeFutureProvider<void>.internal(
  splashDelay,
  name: r'splashDelayProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$splashDelayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashDelayRef = AutoDisposeFutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
