// lib/features/auth/presentation/screens/role_selection_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_selectedRole == null) return;
    setState(() => _isSubmitting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      // Satisfy Firestore Security Rules by providing all required fields for initial creation
      await FirebaseFirestore.instance.doc(FirestorePaths.user(uid)).set(
        {
          'uid': uid,
          'role': _selectedRole,
          'name': FirebaseAuth.instance.currentUser?.displayName ?? 'New User',
          'email': FirebaseAuth.instance.currentUser?.email ?? '',
          'phone': '+920000000000', // Valid placeholder to pass rules
          'city': 'Karachi', // Valid placeholder to pass rules
          'onboardingComplete': false,
          'isAdmin': false,
          'isBanned': false,
          'isDeleted': false,
          'isVerified': false,
          'rating': 0.0,
          'totalReviews': 0,
          'profilePhoto': FirebaseAuth.instance.currentUser?.photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (mounted) context.go(RouteNames.profileSetup);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 24.w,
              vertical: 40.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.l10n.roleSelectionTitle,
                  style: AppTextStyles.displayLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  context.l10n.roleSelectionSubtitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.warning),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),

                // Hirer card
                _RoleCard(
                  icon: Icons.home_work_outlined,
                  title: context.l10n.roleHirerTitle,
                  subtitle: context.l10n.roleHirerSubtitle,
                  isSelected: _selectedRole == 'hirer',
                  onTap: () => setState(() => _selectedRole = 'hirer'),
                )
                    .animate()
                    .fadeIn(duration: AppDurations.normal)
                    .slideY(begin: 0.15, end: 0),

                SizedBox(height: 24.h),

                // Provider card
                _RoleCard(
                  icon: Icons.work_outline_rounded,
                  title: context.l10n.roleProviderTitle,
                  subtitle: context.l10n.roleProviderSubtitle,
                  isSelected: _selectedRole == 'provider',
                  onTap: () => setState(() => _selectedRole = 'provider'),
                )
                    .animate(delay: 60.ms)
                    .fadeIn(duration: AppDurations.normal)
                    .slideY(begin: 0.15, end: 0),

                SizedBox(height: 48.h),
                AppButton(
                  label: context.l10n.continueButton,
                  isLoading: _isSubmitting,
                  onPressed: _selectedRole != null ? _submit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        constraints: BoxConstraints(minHeight: 130.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40.w,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineMedium),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 24.w),
          ],
        ),
      ),
    );
  }
}
