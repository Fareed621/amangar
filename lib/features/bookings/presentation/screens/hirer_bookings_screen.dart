import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/booking_card.dart';
import '../../../../core/widgets/booking_card_skeleton.dart';
import '../providers/hirer_bookings_provider.dart';

class HirerBookingsScreen extends ConsumerWidget {
  const HirerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text('My Bookings', style: AppTextStyles.headlineSmall),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingsTab(isUpcoming: true),
            _BookingsTab(isUpcoming: false),
          ],
        ),
      ),
    );
  }
}

class _BookingsTab extends ConsumerWidget {
  const _BookingsTab({required this.isUpcoming});
  final bool isUpcoming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = isUpcoming ? ref.watch(hirerUpcomingBookingsProvider) : ref.watch(hirerPastBookingsProvider);

    return stream.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return AppEmptyState(
            icon: isUpcoming ? Icons.calendar_today : Icons.history,
            title: isUpcoming ? 'No upcoming bookings' : 'No past bookings',
            subtitle: isUpcoming 
              ? 'When you book a provider, it will appear here.'
              : 'Your completed and cancelled bookings will appear here.',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: BookingCard(
                  booking: booking,
                  userRole: 'hirer',
                  onTap: () => context.push(RouteNames.bookingDetailPath(booking.id)),
                ),
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: const BookingCardSkeleton(),
        ),
      ),
      error: (e, stack) => AppErrorWidget(
        message: e.toString(), 
        onRetry: () {
          ref.invalidate(hirerUpcomingBookingsProvider);
          ref.invalidate(hirerPastBookingsProvider);
        },
      ),
    );
  }
}
