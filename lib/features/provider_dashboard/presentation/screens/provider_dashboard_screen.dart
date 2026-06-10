import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_banner_ad.dart';
import '../../../../core/widgets/booking_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../providers/provider_dashboard_provider.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(providerDashboardProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final firstName = user?.name.split(' ').first ?? 'Provider';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(providerDashboardProvider),
        child: dashboardAsync.when(
          data: (state) => _DashboardContent(state: state, firstName: firstName, user: user),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.state, required this.firstName, this.user});
  final ProviderDashboardState state;
  final String firstName;
  final dynamic user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(providerDetailProvider(user?.uid ?? ''));
    final profile = profileAsync.valueOrNull?.profile;

    return CustomScrollView(
      slivers: [
        // AppBar with search bar
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          toolbarHeight: 64.h,
          title: GestureDetector(
            onTap: () => context.push(RouteNames.providerList),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Icon(Icons.search, color: AppColors.textTertiary, size: 20.w),
                  SizedBox(width: 8.w),
                  Text('Browse providers...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled)),
                ],
              ),
            ),
          ),
          actions: [
            const NotificationBell(),
            SizedBox(width: 8.w),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: const Divider(height: 1),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Greeting
              Text('Welcome back,', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text(firstName, style: AppTextStyles.headlineMedium),
              SizedBox(height: 24.h),

              // ── Verification Banner ───────────────────────────────────────────
              if (profile != null && profile.verificationStatus != 'approved')
                _VerificationBanner(status: profile.verificationStatus),

              SizedBox(height: 24.h),

              // ── Stats Row ───────────────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                    label: 'This Month',
                    value: profile?.currentMonthBookings.toString() ?? '—',
                    onTap: () => context.push(RouteNames.earnings),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                  SizedBox(width: 8.w),
                  _StatCard(
                    label: 'Earnings',
                    value: profile != null ? Formatters.formatPrice(profile.currentMonthEarnings) : '—',
                    onTap: () => context.push(RouteNames.earnings),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  SizedBox(width: 8.w),
                  _StatCard(
                    label: 'Rating',
                    value: user != null ? '★ ${Formatters.formatRating(user.rating as double)}' : '—',
                    onTap: null,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              ],
              ),

              SizedBox(height: 24.h),
              const AppBannerAd(),

              // ── New Requests Section ─────────────────────────────────────
              if (state.pendingRequests.isNotEmpty) ...[
                SizedBox(height: 28.h),
                SectionHeader(
                  title: 'New Requests',
                  actionLabel: 'View All',
                  onAction: () => context.push(RouteNames.providerBookings),
                ),
                SizedBox(height: 12.h),
                ...state.pendingRequests.map((booking) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _RequestCard(booking: booking),
                    )),
              ],

              // ── Recent Bookings ──────────────────────────────────────────
              SizedBox(height: 28.h),
              SectionHeader(
                title: 'Recent Bookings',
                actionLabel: 'View All',
                onAction: () => context.push(RouteNames.providerBookings),
              ),
              SizedBox(height: 12.h),
              if (state.recentBookings.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text('No bookings yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                )
              else
                ...state.recentBookings.map((b) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: BookingCard(
                        booking: b,
                        userRole: 'provider',
                        onTap: () => context.push(RouteNames.bookingDetailPath(b.id)),
                      ),
                    )),

              // ── Quick Actions ────────────────────────────────────────────
              SizedBox(height: 28.h),
              Text('Quick Actions', style: AppTextStyles.headlineSmall),
              SizedBox(height: 12.h),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuickActionCard(icon: Icons.event_available, label: 'Availability', onTap: () => context.push(RouteNames.availability)),
                  _QuickActionCard(icon: Icons.account_balance_wallet, label: 'Earnings', onTap: () => context.push(RouteNames.earnings)),
                  _QuickActionCard(icon: Icons.photo_library_outlined, label: 'Portfolio', onTap: () => context.push(RouteNames.portfolio)),
                  _QuickActionCard(
                    icon: Icons.verified_user_outlined,
                    label: 'Verification',
                    onTap: () => context.push(RouteNames.verification),
                    status: profile?.verificationStatus ?? 'none',
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary), textAlign: TextAlign.center),
              SizedBox(height: 4.h),
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Request Card ─────────────────────────────────────────────────────────────
class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(providerDashboardProvider.notifier);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(imageUrl: booking.hirerPhoto, name: booking.hirerName, size: 48.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.hirerName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text(
                        booking.dates.isNotEmpty ? Formatters.formatDate(booking.dates.first) : '',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        booking.serviceType == 'full_time' ? 'Full-time' : 'Part-time',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                      Text(Formatters.formatPrice(booking.displayPrice), style: AppTextStyles.labelMedium),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Accept',
                    onPressed: () async {
                      await notifier.acceptBooking(booking.id);
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: AppButton.secondary(
                    label: 'Reject',
                    onPressed: () => _showRejectSheet(context, ref, booking.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.015, duration: AppDurations.slow, curve: Curves.easeInOut);
  }

  void _showRejectSheet(BuildContext context, WidgetRef ref, String bookingId) {
    String? selectedReason;
    final reasons = [
      ('already_booked', 'Already booked on those dates'),
      ('personal_reason', 'Personal reason'),
      ('too_far', 'Too far from my location'),
      ('other', 'Other'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reason for Rejection', style: AppTextStyles.headlineSmall),
              SizedBox(height: 16.h),
              ...reasons.map((r) => RadioListTile<String>(
                    title: Text(r.$2),
                    value: r.$1,
                    groupValue: selectedReason,
                    onChanged: (v) => setState(() => selectedReason = v),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  )),
              SizedBox(height: 16.h),
              AppButton(
                label: 'Reject Booking',
                onPressed: selectedReason == null
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await ref.read(providerDashboardProvider.notifier).rejectBooking(bookingId, selectedReason!);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Verification Banner ──────────────────────────────────────────────────────
class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    return GestureDetector(
      onTap: () => context.push(RouteNames.verification),
      child: Container(
        margin: EdgeInsets.only(top: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isRejected 
              ? AppColors.error.withValues(alpha: 0.1) 
              : isPending 
                  ? AppColors.warning.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isRejected 
                ? AppColors.error 
                : isPending 
                    ? AppColors.warning
                    : AppColors.primary,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isRejected ? Icons.error_outline : isPending ? Icons.hourglass_empty : Icons.verified_user_outlined,
              color: isRejected ? AppColors.error : isPending ? AppColors.warning : AppColors.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRejected ? 'Verification Rejected' : isPending ? 'Verification Pending' : 'Get Verified',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isRejected ? AppColors.error : isPending ? AppColors.warning : AppColors.primary,
                    ),
                  ),
                  Text(
                    isRejected 
                        ? 'Please check details and resubmit.' 
                        : isPending 
                            ? 'Your documents are being reviewed.' 
                            : 'Upload CNIC to get a verified badge.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.status = 'none',
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String status;

  @override
  Widget build(BuildContext context) {
    final isVerified = status == 'approved';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28.w, color: AppColors.primary),
                  SizedBox(height: 8.h),
                  Text(label, style: AppTextStyles.labelLarge, textAlign: TextAlign.center),
                ],
              ),
            ),
            if (isVerified || isPending || isRejected)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isVerified ? AppColors.success : isPending ? AppColors.warning : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVerified ? Icons.check : isPending ? Icons.access_time : Icons.close,
                    size: 10.w,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
