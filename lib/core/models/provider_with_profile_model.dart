// lib/core/models/provider_with_profile_model.dart
import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'provider_profile_model.dart';

/// Combined model used when a provider's user doc and profile doc
/// are fetched together (e.g., search results, provider detail screen).
class ProviderWithProfileModel extends Equatable {
  const ProviderWithProfileModel({
    required this.user,
    this.profile,
  });

  final UserModel user;
  final ProviderProfileModel? profile;

  ProviderWithProfileModel copyWith({
    UserModel? user,
    ProviderProfileModel? profile,
  }) =>
      ProviderWithProfileModel(
        user: user ?? this.user,
        profile: profile ?? this.profile,
      );

  @override
  List<Object?> get props => [user, profile];
}
