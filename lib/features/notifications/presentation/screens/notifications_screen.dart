import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/notifications_provider.dart';
import '../../notification_service.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/providers/auth_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-mark notifications as read when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        ref.read(notificationsRepositoryProvider).markAllAsRead(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (user != null)
            TextButton(
              onPressed: () => ref
                  .read(notificationsRepositoryProvider)
                  .markAllAsRead(user.uid),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const AppEmptyState(
              title: "You're all caught up!",
              subtitle: 'No new notifications',
              icon: Icons.notifications_none,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationItem(notification: notif)
                    .animate(delay: (index * 60).ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          );
        },
        loading: () => ListView.builder(
          itemCount: 8,
          itemBuilder: (context, index) => const _NotificationSkeleton(),
        ),
        error: (e, st) => AppErrorWidget(
          message: 'Failed to load notifications',
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  const _NotificationItem({required this.notification});
  final NotificationModel notification;

  IconData _getIcon() {
    switch (notification.type) {
      case 'booking_request':
      case 'booking_confirmed':
      case 'booking_cancelled':
      case 'booking_completed':
        return Icons.calendar_today;
      case 'new_message':
        return Icons.chat_bubble;
      case 'verification_approved':
      case 'verification_rejected':
        return Icons.verified_user;
      case 'withdrawal_success':
      case 'withdrawal_failed':
        return Icons.account_balance_wallet;
      case 'rating_received':
        return Icons.star;
      case 'account_warning':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case 'verification_approved':
        return Colors.green;
      case 'verification_rejected':
      case 'account_warning':
        return Colors.red;
      case 'new_message':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        // In a real app we would call a delete method
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getIconColor().withOpacity(0.1),
          child: Icon(_getIcon(), color: _getIconColor(), size: 20.w),
        ),
        title: Text(
          notification.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              Formatters.formatRelativeTime(notification.createdAt),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        tileColor:
            notification.isRead ? null : AppColors.primary.withOpacity(0.04),
        onTap: () {
          ref.read(markNotificationReadProvider(notification.id));
          // Navigation logic...
        },
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 150.w,
                    height: 12.h,
                    color: AppColors.surfaceVariant),
                SizedBox(height: 8.h),
                Container(
                    width: double.infinity,
                    height: 10.h,
                    color: AppColors.surfaceVariant),
                SizedBox(height: 4.h),
                Container(
                    width: 100.w,
                    height: 10.h,
                    color: AppColors.surfaceVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
