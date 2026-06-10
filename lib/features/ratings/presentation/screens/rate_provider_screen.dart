import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/rating_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../bookings/presentation/screens/booking_detail_screen.dart';
import '../providers/ratings_provider.dart';

class RateProviderScreen extends ConsumerStatefulWidget {
  const RateProviderScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<RateProviderScreen> createState() => _RateProviderScreenState();
}

class _RateProviderScreenState extends ConsumerState<RateProviderScreen> {
  int _selectedRating = 0;
  String _comment = '';
  bool _isSubmitting = false;
  bool _showSuccess = false;

  Future<void> _submit(String raterId, String targetId, String role, String serviceCategory) async {
    setState(() => _isSubmitting = true);
    
    try {
      final repo = ref.read(ratingsRepositoryProvider);
      final currentUser = ref.read(currentUserProvider).valueOrNull;
      final rating = RatingModel(
        id: '',
        fromUserId: raterId,
        toUserId: targetId,
        fromUserName: currentUser?.name ?? 'Unknown',
        fromUserPhoto: currentUser?.profilePhoto,
        bookingId: widget.bookingId,
        rating: _selectedRating,
        comment: _comment.isEmpty ? null : _comment,
      );
      
      await repo.submitRating(rating);
      
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) context.pop();
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncBooking = ref.watch(bookingDetailProvider(widget.bookingId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Rate Your Experience', style: AppTextStyles.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          asyncBooking.when(
            data: (booking) {
              if (booking == null || currentUser == null) return const SizedBox();
              
              final isHirer = currentUser.uid == booking.hirerId;
              final otherPartyName = isHirer ? booking.providerName : booking.hirerName;
              final otherPartyPhoto = isHirer ? booking.providerPhoto : booking.hirerPhoto;
              final otherPartyCategory = booking.serviceCategory.toUpperCase();
              final targetId = isHirer ? booking.providerId : booking.hirerId;
              final role = isHirer ? 'hirer' : 'provider';
              
              return SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Card(
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
                                  Text(otherPartyCategory, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 48.h),
                    Text('How was your experience?', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
                    SizedBox(height: 24.h),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRating = index + 1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Icon(
                              index < _selectedRating ? Icons.star : Icons.star_border,
                              color: index < _selectedRating ? AppColors.warning : AppColors.textDisabled,
                              size: 40.w,
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    SizedBox(height: 32.h),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Leave a comment (optional)',
                      ),
                      maxLines: 4,
                      maxLength: AppLimits.maxRatingCommentLength,
                      onChanged: (val) => setState(() => _comment = val),
                    ),
                    
                    SizedBox(height: 48.h),
                    AppButton(
                      label: 'Submit Review',
                      isLoading: _isSubmitting,
                      onPressed: _selectedRating > 0 ? () => _submit(currentUser.uid, targetId, role, booking.serviceCategory) : null,
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
          
          if (_showSuccess)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _showSuccess ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black45,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle, color: AppColors.success, size: 80.w),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
