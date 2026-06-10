import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/booking_flow_provider.dart';
import '../../domain/bookings_repository.dart';

part 'booking_detail_screen.g.dart';

final _log = Logger();


@riverpod
Stream<BookingModel?> bookingDetail(BookingDetailRef ref, String bookingId) {
  return ref.read(bookingsRepositoryProvider).getBookingById(bookingId);
}

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBooking = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Booking Details', style: AppTextStyles.headlineSmall),
      ),
      body: asyncBooking.when(
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }
          return _BookingDetailContent(booking: booking);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => AppErrorWidget(message: e.toString(), onRetry: () {}),
      ),
    );
  }
}

class _BookingDetailContent extends ConsumerWidget {
  const _BookingDetailContent({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    if (currentUser == null) return const SizedBox();

    final isHirer = currentUser.uid == booking.hirerId;
    final otherPartyName = isHirer ? booking.providerName : booking.hirerName;
    final otherPartyPhoto = isHirer ? booking.providerPhoto : booking.hirerPhoto;
    final otherPartyRole = isHirer ? 'Provider' : 'Hirer';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBanner(),
          SizedBox(height: 16.h),
          
          GestureDetector(
            onTap: isHirer ? () => context.push('/providers/${booking.providerId}') : null,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    AppAvatar(imageUrl: otherPartyPhoto, name: otherPartyName, size: 48.w),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(otherPartyName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(otherPartyRole, style: AppTextStyles.caption),
                          ),
                        ],
                      ),
                    ),
                    if (isHirer) const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: const BorderSide(color: AppColors.divider),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Service', booking.serviceType == 'full_time' ? 'Full-time' : 'Part-time'),
                  _buildDetailRow('Category', booking.serviceCategory.toUpperCase()),
                  _buildDetailRow('Dates', _formatDates()),
                  _buildDetailRow('Time', '${booking.startTime} - ${booking.endTime}'),
                  _buildDetailRow('Duration', '${booking.totalDurationHours.toStringAsFixed(1)} hours/day'),
                  Divider(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Price', style: AppTextStyles.bodyMedium),
                      Text(Formatters.formatPrice(booking.displayPrice), 
                           style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    Text(booking.notes!, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
          
          if (booking.status == 'confirmed' || booking.status == 'in_progress' || booking.status == 'completed') ...[
            SizedBox(height: 16.h),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Hirer Paid'),
                    subtitle: const Text('Hirer confirms payment sent'),
                    value: booking.hirerConfirmedPayment,
                    onChanged: (currentUser.uid == booking.hirerId || currentUser.id == booking.hirerId)
                      ? (val) => ref.read(bookingsRepositoryProvider).confirmPayment(booking.id, currentUser.uid, status: val)
                      : null,
                    activeColor: AppColors.success,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Provider Received'),
                    subtitle: const Text('Provider confirms payment received'),
                    value: booking.providerConfirmedReceipt,
                    onChanged: (currentUser.uid == booking.providerId || currentUser.id == booking.providerId)
                      ? (val) => ref.read(bookingsRepositoryProvider).confirmReceipt(booking.id, currentUser.uid, status: val)
                      : null,
                    activeColor: AppColors.success,
                  ),
                ],
              ),
            ),
          ],
          
          if (booking.status == 'cancelled' && isHirer) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'You are entitled to a ${_getRefundPercentage()}% refund according to the cancellation policy.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 32.h),
          _buildActionButtons(context, ref, isHirer, currentUser.uid),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  String _formatDates() {
    if (booking.dates.isEmpty) return 'None';
    final first = Formatters.formatDate(booking.dates.first);
    if (booking.dates.length == 1) return first;
    return '$first +${booking.dates.length - 1} more';
  }

  int _getRefundPercentage() {
    if (booking.refundPercentage != null) return booking.refundPercentage!;
    switch (booking.refundPolicy) {
      case 'full': return 100;
      case 'partial_90': return 90;
      case 'partial_50': return 50;
      case 'none': return 0;
      default: return 0;
    }
  }

  bool _isJobTime(BookingModel booking) {
    final now = DateTime.now();
    
    // Check if today is one of the booking dates
    final isToday = booking.dates.any((d) {
      final date = d.toDate();
      return date.year == now.year && date.month == now.month && date.day == now.day;
    });
    
    if (!isToday) return false;

    try {
      final start = _combineDateAndTime(now, booking.startTime);
      // We allow starting slightly after the end time if the status is still confirmed, 
      // but let's stick to the window for now.
      final end = _combineDateAndTime(now, booking.endTime);
      
      // Allow starting 30 minutes early for better UX
      final earlyStart = start.subtract(const Duration(minutes: 30));
      
      return now.isAfter(earlyStart) && now.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    try {
      // 1. Try "HH:mm" (e.g. 14:30)
      if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(timeStr)) {
        final parts = timeStr.split(':');
        return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
      }
      
      // 2. Try "h:mm a" or "hh:mm a" (e.g. 2:30 PM, 09:00 AM)
      final upperTime = timeStr.toUpperCase();
      try {
        final time = DateFormat.jm().parse(upperTime); // h:mm a
        return DateTime(date.year, date.month, date.day, time.hour, time.minute);
      } catch (_) {
        final time = DateFormat("hh:mm a").parse(upperTime);
        return DateTime(date.year, date.month, date.day, time.hour, time.minute);
      }
    } catch (e) {
      _log.w('Error parsing time: $timeStr', error: e);
      return DateTime(date.year, date.month, date.day, 9, 0);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (booking.status) {
      case 'pending':
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        icon = Icons.hourglass_empty;
        text = 'Pending Confirmation';
        break;
      case 'confirmed':
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        icon = Icons.check_circle_outline;
        text = 'Confirmed';
        break;
      case 'in_progress':
        bgColor = const Color(0xFFE8EAF6);
        textColor = const Color(0xFF3F51B5);
        icon = Icons.sync;
        text = 'In Progress';
        break;
      case 'completed':
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        icon = Icons.done_all;
        text = 'Completed';
        break;
      case 'cancelled':
      case 'rejected':
      default:
        bgColor = AppColors.surfaceVariant;
        textColor = AppColors.textSecondary;
        icon = Icons.cancel_outlined;
        text = booking.status == 'rejected' ? 'Rejected' : 'Cancelled';
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20.w),
          SizedBox(width: 8.w),
          Text(text, style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isHirer, String uid) {
    final repo = ref.read(bookingsRepositoryProvider);

    if (isHirer) {
      switch (booking.status) {
        case 'pending':
          return AppButton(
            label: 'Cancel Booking',
            
            onPressed: () => _showCancelDialog(context, repo, uid),
          );
        case 'confirmed':
          return Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: 'Chat',
                  onPressed: () {
                    final uids = [uid, booking.providerId]..sort();
                    final chatId = '${uids[0]}_${uids[1]}';
                    context.push(
                      '/chat/$chatId',
                      extra: {
                        'otherName': booking.providerName,
                        'otherUid': booking.providerId,
                        'otherPhoto': booking.providerPhoto,
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  
                  onPressed: () => _showCancelDialog(context, repo, uid),
                ),
              ),
            ],
          );
        case 'in_progress':
          return Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: 'Chat',
                  onPressed: () {
                    final uids = [uid, booking.providerId]..sort();
                    final chatId = '${uids[0]}_${uids[1]}';
                    context.push(
                      '/chat/$chatId',
                      extra: {
                        'otherName': booking.providerName,
                        'otherUid': booking.providerId,
                        'otherPhoto': booking.providerPhoto,
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  label: 'Mark Complete',
                  onPressed: () => _showCompleteDialog(context, repo, uid),
                ),
              ),
            ],
          );
        case 'completed':
          return Column(
            children: [
              if (!booking.hirerRated) ...[
                AppButton(
                  label: 'Rate Provider',
                  onPressed: () => context.push('/rate/${booking.id}'),
                ),
                SizedBox(height: 12.h),
              ],
              AppButton.secondary(
                label: 'Book Again',
                onPressed: () => context.push('/booking/${booking.providerId}'),
              ),
            ],
          );
        case 'cancelled':
        case 'rejected':
          return AppButton.secondary(
            label: 'Book Again',
            onPressed: () => context.push('/booking/${booking.providerId}'),
          );
      }
    } else {
      // Provider actions
      switch (booking.status) {
        case 'pending':
          return Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Accept',
                  
                  onPressed: () => repo.updateBookingStatus(bookingId: booking.id, newStatus: 'confirmed'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton.secondary(
                  label: 'Reject',
                  onPressed: () => _showRejectSheet(context, repo),
                ),
              ),
            ],
          );
        case 'confirmed':
          final isTime = _isJobTime(booking);
          return Column(
            children: [
              if (isTime) ...[
                AppButton(
                  label: 'Start Job',
                  onPressed: () => repo.updateBookingStatus(
                    bookingId: booking.id, 
                    newStatus: 'in_progress',
                  ),
                ),
                SizedBox(height: 12.h),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 20.w, color: AppColors.textSecondary),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Button will appear at ${booking.startTime} on ${Formatters.formatDate(booking.dates.first)}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Chat',
                      onPressed: () {
                        final uids = [uid, booking.hirerId]..sort();
                        final chatId = '${uids[0]}_${uids[1]}';
                        context.push(
                          '/chat/$chatId',
                          extra: {
                            'otherName': booking.hirerName,
                            'otherUid': booking.hirerId,
                            'otherPhoto': booking.hirerPhoto,
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Cancel',
                      icon: const Icon(Icons.close),
                      onPressed: () => _showCancelDialog(context, repo, uid),
                    ),
                  ),
                ],
              ),
            ],
          );
        case 'in_progress':
          return Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: 'Chat',
                  onPressed: () {
                    final otherUid = isHirer ? booking.providerId : booking.hirerId;
                    final uids = [uid, otherUid]..sort();
                    final chatId = '${uids[0]}_${uids[1]}';
                    context.push(
                      '/chat/$chatId',
                      extra: {
                        'otherName': isHirer ? booking.providerName : booking.hirerName,
                        'otherUid': otherUid,
                        'otherPhoto': isHirer ? booking.providerPhoto : booking.hirerPhoto,
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  label: 'Mark Complete',
                  onPressed: () => _showCompleteDialog(context, repo, uid),
                ),
              ),
            ],
          );
        case 'completed':
          if (!booking.providerRated) {
            return AppButton(
              label: 'Rate Hirer',
              onPressed: () => context.push('/rate/${booking.id}'),
            );
          }
          break;
      }
    }
    return const SizedBox();
  }

  void _showCancelDialog(BuildContext context, BookingsRepository repo, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              repo.updateBookingStatus(
                bookingId: booking.id, 
                newStatus: 'cancelled',
                cancelledBy: uid,
                cancellationReason: 'User cancelled via app',
              );
              context.pop();
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, BookingsRepository repo, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Completed?'),
        content: const Text('Have all services for this booking been fully rendered?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              repo.updateBookingStatus(
                bookingId: booking.id, 
                newStatus: 'completed',
                completedBy: uid,
              );
              context.pop();
            },
            child: const Text('Yes, Mark Complete', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showRejectSheet(BuildContext context, BookingsRepository repo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Reject Booking', style: AppTextStyles.headlineMedium),
            SizedBox(height: 16.h),
            AppButton.secondary(
              label: 'Schedule Conflict',
              onPressed: () {
                repo.updateBookingStatus(bookingId: booking.id, newStatus: 'rejected', rejectionReasonCode: 'schedule_conflict');
                context.pop();
              },
            ),
            SizedBox(height: 12.h),
            AppButton.secondary(
              label: 'Not Servicing Area',
              onPressed: () {
                repo.updateBookingStatus(bookingId: booking.id, newStatus: 'rejected', rejectionReasonCode: 'location');
                context.pop();
              },
            ),
            SizedBox(height: 12.h),
            AppButton.secondary(
              label: 'Other',
              onPressed: () {
                repo.updateBookingStatus(bookingId: booking.id, newStatus: 'rejected', rejectionReasonCode: 'other');
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
