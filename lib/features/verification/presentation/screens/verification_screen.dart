import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../providers/verification_notifier.dart';

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).valueOrNull?.uid ?? '';
    final profileAsync = ref.watch(providerDetailProvider(uid));
    final verStatus = profileAsync.valueOrNull?.profile?.verificationStatus ?? 'none';
    final rejectionReason = profileAsync.valueOrNull?.profile?.verificationRejectionReason;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, title: const Text('Verification')),
      body: switch (verStatus) {
        'approved' => _VerifiedView(),
        'pending' => _PendingView(),
        'rejected' => _RejectedView(
            reason: rejectionReason,
          ),
        _ => _UploadView(),
      },
    );
  }
}

// ── Already verified ─────────────────────────────────────────────────────────
class _VerifiedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: AppColors.success, size: 80.w),
            SizedBox(height: 16.h),
            Text('You are Verified!', style: AppTextStyles.headlineMedium),
            SizedBox(height: 8.h),
            Text(
              'Your account has been verified. A verified badge is displayed on your profile to attract more hirers.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pending review ────────────────────────────────────────────────────────────
class _PendingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 80.w),
            SizedBox(height: 16.h),
            Text('Under Review', style: AppTextStyles.headlineMedium),
            SizedBox(height: 8.h),
            Text(
              'Your documents have been submitted and are being reviewed. This typically takes 1–2 business days.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rejected — allow resubmit ─────────────────────────────────────────────────
class _RejectedView extends StatelessWidget {
  const _RejectedView({this.reason});
  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.cancel_outlined, color: AppColors.error, size: 24.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verification Rejected', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
                      if (reason != null) ...[
                        SizedBox(height: 4.h),
                        Text(reason!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text('Please re-submit with clearer documents.', style: AppTextStyles.bodyMedium),
          SizedBox(height: 16.h),
          Expanded(child: _UploadView(isResubmit: true)),
        ],
      ),
    );
  }
}

// ── Upload form ───────────────────────────────────────────────────────────────
class _UploadView extends ConsumerWidget {
  const _UploadView({this.isResubmit = false});
  final bool isResubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationNotifierProvider);
    final notifier = ref.read(verificationNotifierProvider.notifier);

    ref.listen(verificationNotifierProvider.select((s) => s.isSuccess), (_, success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documents submitted! We\'ll notify you once reviewed.')),
        );
        Navigator.of(context).pop();
      }
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isResubmit) ...[
            Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 48.w),
            SizedBox(height: 12.h),
            Text(
              'Get Verified',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Upload your CNIC (front & back) to verify your identity. A verified badge helps you get more bookings.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
          ],

          // CNIC Front
          _DocUploadTile(
            label: 'CNIC – Front',
            subtitle: 'Clear photo of the front side',
            icon: Icons.credit_card,
            isUploaded: state.cnicFrontUrl != null,
            onTap: () async {
              final file = await _pickImage(context);
              if (file != null) await notifier.uploadCNIC(file, true);
            },
          ),
          SizedBox(height: 12.h),

          // CNIC Back
          _DocUploadTile(
            label: 'CNIC – Back',
            subtitle: 'Clear photo of the back side',
            icon: Icons.credit_card_outlined,
            isUploaded: state.cnicBackUrl != null,
            onTap: () async {
              final file = await _pickImage(context);
              if (file != null) await notifier.uploadCNIC(file, false);
            },
          ),
          SizedBox(height: 12.h),

          // Optional: Certification
          _DocUploadTile(
            label: 'Professional Certification',
            subtitle: 'Any trade or service certification',
            icon: Icons.workspace_premium_outlined,
            isUploaded: state.certUrl != null,
            isOptional: true,
            onTap: () async {
              final file = await _pickImage(context);
              if (file != null) await notifier.uploadCertification(file);
            },
          ),

          // Upload progress
          if (state.isUploading) ...[
            SizedBox(height: 16.h),
            LinearProgressIndicator(value: state.uploadProgress, color: AppColors.primary),
            SizedBox(height: 4.h),
            Text(
              'Uploading ${((state.uploadProgress ?? 0) * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],

          if (state.error != null) ...[
            SizedBox(height: 12.h),
            Text(state.error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error), textAlign: TextAlign.center),
          ],

          SizedBox(height: 28.h),

          AppButton(
            label: 'Submit for Verification',
            isLoading: state.isSubmitting,
            onPressed: state.canSubmit ? () => notifier.submitForVerification() : null,
          ),

          SizedBox(height: 16.h),
          Text(
            'Your documents are stored securely and only used for identity verification.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  // ── Image Picking ──────────────────────────────────────────────────────────

  /// Shows a bottom sheet so the user can choose Camera or Gallery.
  /// Requests the appropriate OS permission before launching the picker.
  /// Returns null if permission is denied or user cancels.
  static Future<File?> _pickImage(BuildContext context) async {
    final source = await _showImageSourceDialog(context);
    if (source == null) return null;

    final granted = source == ImageSource.camera
        ? await PermissionUtils.requestCamera(context)
        : await PermissionUtils.requestPhotos(context);

    if (!granted) return null;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    return picked != null ? File(picked.path) : null;
  }

  /// Shows a native-style modal bottom sheet for source selection.
  static Future<ImageSource?> _showImageSourceDialog(
      BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Upload Document',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how you\'d like to add your document',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Take Photo',
                  color: AppColors.primary,
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                _SourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColors.secondary,
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DocUploadTile extends StatelessWidget {
  const _DocUploadTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isUploaded,
    required this.onTap,
    this.isOptional = false,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool isUploaded;
  final VoidCallback onTap;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.success.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.divider,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isUploaded ? AppColors.success.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_outline : icon,
                color: isUploaded ? AppColors.success : AppColors.primary,
                size: 24.w,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(label, style: AppTextStyles.labelMedium),
                      ),
                      if (isOptional) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.textDisabled.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text('Optional', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isUploaded ? 'Uploaded successfully ✓' : subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUploaded ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.upload_rounded, color: isUploaded ? AppColors.success : AppColors.textSecondary, size: 20.w),
          ],
        ),
      ),
    );
  }
}

// ── Source option button used in _showImageSourceDialog ──────────────────────

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
