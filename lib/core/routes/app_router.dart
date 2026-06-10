// lib/core/routes/app_router.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_keys.dart';
import '../constants/route_names.dart';
import '../providers/auth_provider.dart';
import '../theme/app_text_styles.dart';
import '../../features/auth/presentation/screens/onboarding_success_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/provider_additional_setup_screen.dart';
import '../../features/hirer_dashboard/presentation/screens/hirer_dashboard_screen.dart';
import '../../features/search/presentation/screens/provider_list_screen.dart';
import '../../features/search/presentation/screens/provider_profile_screen.dart';
import '../../features/bookings/presentation/screens/booking_detail_screen.dart';
import '../../features/bookings/presentation/screens/booking_flow_screen.dart';
import '../../features/bookings/presentation/screens/hirer_bookings_screen.dart';
import '../../features/ratings/presentation/screens/rate_provider_screen.dart';
import '../../features/bookings/presentation/screens/provider_bookings_screen.dart';
import '../../features/provider_dashboard/presentation/screens/provider_dashboard_screen.dart';
// Phase 4 screens
import '../../features/availability/presentation/screens/availability_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/earnings/presentation/screens/withdrawal_screen.dart';
import '../../features/verification/presentation/screens/verification_screen.dart';
import '../../features/profile/presentation/screens/hirer_profile_screen.dart';
import '../../features/profile/presentation/screens/provider_settings_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/portfolio_manage_screen.dart';
import '../providers/splash_delay_provider.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/providers/chat_list_provider.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';

part 'app_router.g.dart';

/// Converts multiple Providers to a Listenable for GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    for (final s in streams) {
      _subscriptions.add(s.listen((_) => notifyListeners()));
    }
  }

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }
}

/// Placeholder screen used for shell branches not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(label, style: AppTextStyles.headlineMedium),
        ),
      );
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  // We don't use ref.watch here because we want the GoRouter instance to be stable.
  // Instead, we use refreshListenable to trigger redirects when providers change.

  return GoRouter(
    navigatorKey: AppKeys.navigatorKey,
    initialLocation: RouteNames.splash,
    refreshListenable: GoRouterRefreshStream([
      FirebaseAuth.instance.authStateChanges(),
      FirebaseAuth.instance.userChanges(),
      // currentUserProvider is a StreamProvider, so it has .stream
      ref.watch(currentUserProvider.stream),
      // splashDelayProvider is a FutureProvider, so we convert its .future to a stream
      ref.watch(splashDelayProvider.future).asStream(),
    ]),
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Use ref.read to get the current state of providers without subscribing to rebuilds.
      final splashDelay = ref.read(splashDelayProvider);
      final authState = ref.read(authStateProvider);
      final currentUser = ref.read(currentUserProvider);

      // 0. Enforce minimum splash delay
      if (splashDelay.isLoading) {
        if (loc == RouteNames.splash) return null;
        return RouteNames.splash;
      }

      // 1. Wait for Firebase Auth to initialize
      if (authState.isLoading) {
        if (loc == RouteNames.splash) return null;
        return RouteNames.splash;
      }

      final isLoggedIn = authState.valueOrNull != null;

      // 2. Not logged in → go to login
      if (!isLoggedIn) {
        if (loc == RouteNames.login) return null;
        return RouteNames.login;
      }

      // If we reach here, user is authenticated in Firebase Auth.
      // Wait for user document from Firestore to load (if it exists).
      if (currentUser.isLoading) {
        if (loc == RouteNames.splash) return null;
        return RouteNames.splash;
      }

      final user = currentUser.valueOrNull;

      // 3. Banned user → sign out + login
      if (user?.isBanned == true) {
        FirebaseAuth.instance.signOut();
        return RouteNames.login;
      }

      // 4. No user document or role yet → role selection
      if (user == null || user.role == null) {
        if (loc == RouteNames.roleSelection) return null;
        return RouteNames.roleSelection;
      }

      // 5. Role set but onboarding incomplete
      if (user.onboardingComplete == false) {
        if (user.role == 'provider') {
          // Check if step 1 (profileSetup) is done
          // We know step 1 is NOT done if phone is null or the placeholder from RoleSelectionScreen
          if (user.phone == null || user.phone == '+920000000000') {
            if (loc == RouteNames.profileSetup) return null;
            return RouteNames.profileSetup;
          }
          if (loc == RouteNames.providerSetup) return null;
          return RouteNames.providerSetup;
        }
        if (loc == RouteNames.profileSetup) return null;
        return RouteNames.profileSetup;
      }

      // 6. Fully onboarded user on auth screens → redirect to dashboard or success screen
      if (loc == RouteNames.login ||
          loc == RouteNames.splash ||
          loc == RouteNames.roleSelection ||
          loc == RouteNames.profileSetup ||
          loc == RouteNames.providerSetup) {
        // If they were on a setup screen, they just finished onboarding
        final wasOnboarding = loc == RouteNames.roleSelection ||
            loc == RouteNames.profileSetup ||
            loc == RouteNames.providerSetup;

        if (wasOnboarding) {
          return RouteNames.onboardingSuccess;
        }

        if (user.isAdmin == true) return RouteNames.adminDashboard;
        if (user.role == 'provider') return RouteNames.providerHome;
        return RouteNames.hirerHome;
      }

      // Allow staying on onboarding success
      if (loc == RouteNames.onboardingSuccess) return null;

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.onboardingSuccess,
        builder: (context, state) {
          final role =
              ref.read(currentUserProvider).valueOrNull?.role ?? 'hirer';
          return OnboardingSuccessScreen(role: role);
        },
      ),
      // ── Auth & Onboarding ───────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.bookingFlow,
        builder: (context, state) => BookingFlowScreen(
          providerId: state.pathParameters['providerId']!,
        ),
      ),
      GoRoute(
        path: RouteNames.bookingDetail,
        builder: (context, state) => BookingDetailScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(
        path: RouteNames.rateProvider,
        builder: (context, state) => RateProviderScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(
        path: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: RouteNames.providerSetup,
        builder: (context, state) => const ProviderAdditionalSetupScreen(),
      ),
      GoRoute(
        path: RouteNames.providerList,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProviderListScreen(category: extra?['category'] as String?);
        },
      ),
      GoRoute(
        path: RouteNames.providerDetail,
        builder: (context, state) {
          final id = state.pathParameters['providerId']!;
          return ProviderProfileScreen(providerId: id);
        },
      ),

      // ── Hirer Shell ─────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _HirerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.hirerHome,
              builder: (_, __) => const HirerDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.hirerBookings,
              builder: (context, state) => const HirerBookingsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.hirerChat,
              builder: (_, __) => const ChatListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.hirerProfile,
              builder: (_, __) => const HirerProfileScreen(),
            ),
          ]),
        ],
      ),

      // ── Provider Shell ──────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ProviderShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.providerHome,
              builder: (_, __) => const ProviderDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.providerBookings,
              builder: (_, __) => const ProviderBookingsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.providerChat,
              builder: (_, __) => const ChatListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.providerProfile,
              builder: (_, __) => const ProviderSettingsScreen(),
            ),
          ]),
        ],
      ),

      // ── Admin Shell ─────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminDashboard,
              builder: (_, __) =>
                  const _PlaceholderScreen(label: 'Admin Dashboard'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminVerification,
              builder: (_, __) =>
                  const _PlaceholderScreen(label: 'Verifications'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminUsers,
              builder: (_, __) => const _PlaceholderScreen(label: 'Users'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminReports,
              builder: (_, __) => const _PlaceholderScreen(label: 'Reports'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminWithdrawals,
              builder: (_, __) =>
                  const _PlaceholderScreen(label: 'Withdrawals'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.adminSupport,
              builder: (_, __) => const _PlaceholderScreen(label: 'Support'),
            ),
          ]),
        ],
      ),

      GoRoute(
        path: RouteNames.hirerFavorites,
        builder: (_, __) => const FavoritesScreen(),
      ),
      GoRoute(
        path: RouteNames.hirerEditProfile,
        builder: (_, __) => const EditProfileScreen(isProvider: false),
      ),
      GoRoute(
        path: RouteNames.availability,
        builder: (_, __) => const AvailabilityScreen(),
      ),
      GoRoute(
        path: RouteNames.earnings,
        builder: (_, __) => const EarningsScreen(),
      ),
      GoRoute(
        path: RouteNames.withdrawal,
        builder: (_, __) => const WithdrawalScreen(),
      ),
      GoRoute(
        path: RouteNames.verification,
        builder: (_, __) => const VerificationScreen(),
      ),
      GoRoute(
        path: RouteNames.portfolio,
        builder: (_, __) => const PortfolioManageScreen(),
      ),
      GoRoute(
        path: RouteNames.providerEditProfile,
        builder: (_, __) => const EditProfileScreen(isProvider: true),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.chatDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            chatId: state.pathParameters['chatId']!,
            otherName: extra?['otherName'] as String? ?? 'Chat',
            otherUid: extra?['otherUid'] as String? ?? '',
            otherPhoto: extra?['otherPhoto'] as String?,
          );
        },
      ),
      GoRoute(
        path: RouteNames.support,
        builder: (_, __) => const _PlaceholderScreen(label: 'Help & Support'),
      ),
    ],
  );
}

// ── Shell scaffold widgets ───────────────────────────────────────────────────

class _HirerShell extends ConsumerWidget {
  const _HirerShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(totalUnreadCountProvider).valueOrNull ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(unreadCount.toString()),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Badge(
              label: Text(unreadCount.toString()),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ProviderShell extends ConsumerWidget {
  const _ProviderShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(totalUnreadCountProvider).valueOrNull ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(unreadCount.toString()),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Badge(
              label: Text(unreadCount.toString()),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _AdminShell extends StatelessWidget {
  const _AdminShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Verify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Withdrawals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
