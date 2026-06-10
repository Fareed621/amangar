// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$earningsRepositoryHash() =>
    r'5efda9044e25c0d4b7e89e61c9593ec605f82a26';

/// See also [earningsRepository].
@ProviderFor(earningsRepository)
final earningsRepositoryProvider =
    AutoDisposeProvider<EarningsRepository>.internal(
  earningsRepository,
  name: r'earningsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$earningsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EarningsRepositoryRef = AutoDisposeProviderRef<EarningsRepository>;
String _$withdrawalsHash() => r'3ce9bd42941f2b14d1baa29da41727ca8eecedc6';

/// See also [withdrawals].
@ProviderFor(withdrawals)
final withdrawalsProvider =
    AutoDisposeStreamProvider<List<WithdrawalModel>>.internal(
  withdrawals,
  name: r'withdrawalsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$withdrawalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WithdrawalsRef = AutoDisposeStreamProviderRef<List<WithdrawalModel>>;
String _$earningsLedgerNotifierHash() =>
    r'1635ddc6ad4dae38865db423d30408302e39e9ed';

/// See also [EarningsLedgerNotifier].
@ProviderFor(EarningsLedgerNotifier)
final earningsLedgerNotifierProvider =
    AutoDisposeNotifierProvider<EarningsLedgerNotifier, LedgerState>.internal(
  EarningsLedgerNotifier.new,
  name: r'earningsLedgerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$earningsLedgerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EarningsLedgerNotifier = AutoDisposeNotifier<LedgerState>;
String _$withdrawalNotifierHash() =>
    r'ecdace73e4b72ca6bc2b1dde437b42ae7b0c98aa';

/// See also [WithdrawalNotifier].
@ProviderFor(WithdrawalNotifier)
final withdrawalNotifierProvider =
    AutoDisposeNotifierProvider<WithdrawalNotifier, WithdrawalState>.internal(
  WithdrawalNotifier.new,
  name: r'withdrawalNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$withdrawalNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WithdrawalNotifier = AutoDisposeNotifier<WithdrawalState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
