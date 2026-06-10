import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/booking_card.dart';
import '../../../bookings/presentation/providers/provider_bookings_provider.dart';
import '../../../provider_dashboard/presentation/providers/provider_dashboard_provider.dart';

class ProviderBookingsScreen extends ConsumerStatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  ConsumerState<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends ConsumerState<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Bookings', style: AppTextStyles.headlineSmall),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Upcoming'),
            Tab(text: 'In Progress'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingTab(status: 'pending', emptyMessage: 'No pending requests', isRequestTab: true),
          _BookingTab(status: 'confirmed', emptyMessage: 'No upcoming bookings'),
          _BookingTab(status: 'in_progress', emptyMessage: 'No active bookings'),
          _PastBookingsTab(),
        ],
      ),
    );
  }
}

class _BookingTab extends ConsumerWidget {
  const _BookingTab({required this.status, required this.emptyMessage, this.isRequestTab = false});
  final String status;
  final String emptyMessage;
  final bool isRequestTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(providerBookingsProvider(status));

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return AppEmptyState(
            icon: Icons.calendar_today_outlined,
            title: emptyMessage,
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (ctx, i) {
            final b = bookings[i];
            if (isRequestTab) {
              return _RequestCard(booking: b);
            }
            return BookingCard(
              booking: b,
              userRole: 'provider',
              onTap: () => context.push(RouteNames.bookingDetailPath(b.id)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _PastBookingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(providerBookingsProvider('completed'));
    final cancelledAsync = ref.watch(providerBookingsProvider('cancelled'));
    final rejectedAsync = ref.watch(providerBookingsProvider('rejected'));

    final allPast = [
      ...completedAsync.valueOrNull ?? [],
      ...cancelledAsync.valueOrNull ?? [],
      ...rejectedAsync.valueOrNull ?? [],
    ];
    allPast.sort((a, b) => (b.createdAt?.compareTo(a.createdAt ?? b.createdAt!)) ?? 0);

    if (allPast.isEmpty) {
      return const AppEmptyState(icon: Icons.history, title: 'No past bookings');
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: allPast.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (ctx, i) => BookingCard(
        booking: allPast[i],
        userRole: 'provider',
        onTap: () => context.push(RouteNames.bookingDetailPath(allPast[i].id)),
      ),
    );
  }
}

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
                    onPressed: () => _showRejectSheet(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectSheet(BuildContext context, WidgetRef ref) {
    String? selectedReason;
    final reasons = [
      ('already_booked', 'Already booked on those dates'),
      ('personal_reason', 'Personal reason'),
      ('too_far', 'Too far from my location'),
      ('other', 'Other'),
    ];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reason for Rejection', style: AppTextStyles.headlineSmall),
              SizedBox(height: 12.h),
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
                label: 'Reject',
                onPressed: selectedReason == null
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await ref.read(providerDashboardProvider.notifier).rejectBooking(booking.id, selectedReason!);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
