// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportsRepositoryHash() => r'1ea8cfb66361c4181e4ed4200a58f5e037f5196b';

/// See also [reportsRepository].
@ProviderFor(reportsRepository)
final reportsRepositoryProvider =
    AutoDisposeProvider<ReportsRepository>.internal(
  reportsRepository,
  name: r'reportsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportsRepositoryRef = AutoDisposeProviderRef<ReportsRepository>;
String _$reportNotifierHash() => r'a50151fe52e5f5bde48369acb12053acba5a7046';

/// See also [ReportNotifier].
@ProviderFor(ReportNotifier)
final reportNotifierProvider =
    AutoDisposeNotifierProvider<ReportNotifier, ReportState>.internal(
  ReportNotifier.new,
  name: r'reportNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportNotifier = AutoDisposeNotifier<ReportState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
