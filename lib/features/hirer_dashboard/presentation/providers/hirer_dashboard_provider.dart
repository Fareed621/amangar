import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/models/favorite_model.dart';
import '../../../../core/models/provider_with_profile_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/hirer_dashboard_repository_impl.dart';
import '../../domain/hirer_dashboard_repository.dart';

part 'hirer_dashboard_provider.g.dart';

class HirerDashboardState extends Equatable {
  const HirerDashboardState({
    required this.recentBookings,
    required this.favorites,
    required this.recommendedProviders,
  });

  final List<BookingModel> recentBookings;
  final List<FavoriteModel> favorites;
  final List<ProviderWithProfileModel> recommendedProviders;

  @override
  List<Object?> get props => [recentBookings, favorites, recommendedProviders];
}

@riverpod
HirerDashboardRepository hirerDashboardRepository(HirerDashboardRepositoryRef ref) {
  return HirerDashboardRepositoryImpl();
}

@riverpod
class HirerDashboard extends _$HirerDashboard {
  @override
  Future<HirerDashboardState> build() async {
    return _loadDashboard();
  }

  Future<HirerDashboardState> _loadDashboard() async {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const HirerDashboardState(
        recentBookings: [],
        favorites: [],
        recommendedProviders: [],
      );
    }

    final repo = ref.read(hirerDashboardRepositoryProvider);
    
    // Fetch all three simultaneously
    final results = await Future.wait([
      repo.getRecentBookings(user.uid),
      repo.getFavorites(user.uid),
      repo.getRecommendedProviders(user.city ?? '', null),
    ]);

    return HirerDashboardState(
      recentBookings: results[0] as List<BookingModel>,
      favorites: results[1] as List<FavoriteModel>,
      recommendedProviders: results[2] as List<ProviderWithProfileModel>,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadDashboard);
  }
}
