// lib/core/constants/route_names.dart

/// Every route path constant for GoRouter.
/// Never use raw strings for navigation — always use this class.
class RouteNames {
  RouteNames._();

  // ── Auth & Onboarding ────────────────────────────────────────────────────
  static const splash        = '/';
  static const login         = '/login';
  static const roleSelection = '/role-selection';
  static const profileSetup      = '/profile-setup';
  static const providerSetup     = '/provider-setup';
  static const onboardingSuccess = '/onboarding-success';

  // ── Hirer Shell ──────────────────────────────────────────────────────────
  static const hirerHome     = '/hirer/home';
  static const hirerBookings = '/hirer/bookings';
  static const hirerChat     = '/hirer/chat';
  static const hirerProfile  = '/hirer/profile';
  static const hirerFavorites      = '/hirer/favorites';
  static const hirerEditProfile    = '/hirer/edit-profile';

  // ── Provider Shell ───────────────────────────────────────────────────────
  static const providerHome        = '/provider/home';
  static const providerBookings    = '/provider/bookings';
  static const providerChat        = '/provider/chat';
  static const providerProfile     = '/provider/profile';
  static const availability        = '/provider/availability';
  static const earnings            = '/provider/earnings';
  static const withdrawal          = '/provider/withdrawal';
  static const verification        = '/provider/verification';
  static const portfolio           = '/provider/portfolio';
  static const providerEditProfile = '/provider/edit-profile';

  // ── Shared Detail Screens ────────────────────────────────────────────────
  static const providerList   = '/providers';
  static const providerDetail = '/providers/:providerId';
  static const bookingFlow    = '/booking/:providerId';
  static const bookingDetail  = '/bookings/:bookingId';
  static const chatDetail     = '/chat/:chatId';
  static const rateProvider   = '/rate/:bookingId';
  static const notifications  = '/notifications';
  static const support        = '/support';

  // ── Admin Shell ──────────────────────────────────────────────────────────
  static const adminDashboard    = '/admin';
  static const adminVerification = '/admin/verification';
  static const adminUsers        = '/admin/users';
  static const adminReports      = '/admin/reports';
  static const adminWithdrawals  = '/admin/withdrawals';
  static const adminSupport      = '/admin/support';

  // ── Helper: build concrete paths (replaces :param placeholders) ──────────
  static String providerDetailPath(String providerId) =>
      '/providers/$providerId';
  static String bookingFlowPath(String providerId) =>
      '/booking/$providerId';
  static String bookingDetailPath(String bookingId) =>
      '/bookings/$bookingId';
  static String chatDetailPath(String chatId) =>
      '/chat/$chatId';
  static String rateProviderPath(String bookingId) =>
      '/rate/$bookingId';
}
