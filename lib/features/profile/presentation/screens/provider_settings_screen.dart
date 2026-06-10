import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../providers/profile_provider.dart';

class ProviderSettingsScreen extends ConsumerWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final uid = user?.uid ?? '';
    final profileAsync = ref.watch(providerDetailProvider(uid));
    final profile = profileAsync.valueOrNull?.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // ── Profile Header ────────────────────────────────────────────
            _ProfileHeader(user: user, profile: profile, ref: ref),

            SizedBox(height: 28.h),

            // ── Provider Info ──────────────────────────────────────────────
            _SectionCard(
              title: 'Provider Profile',
              items: [
                _SettingsTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () => context.push(RouteNames.providerEditProfile),
                ),
                _SettingsTile(
                  icon: Icons.photo_library_outlined,
                  label: 'Portfolio Photos',
                  onTap: () => context.push(RouteNames.portfolio),
                ),
                _SettingsTile(
                  icon: Icons.event_available_outlined,
                  label: 'Availability Schedule',
                  onTap: () => context.push(RouteNames.availability),
                ),
                _SettingsTile(
                  icon: Icons.verified_user_outlined,
                  label: 'Verification',
                  trailing: profile?.isVerified == true
                      ? Icon(Icons.verified, color: AppColors.success, size: 18.w)
                      : null,
                  onTap: () => context.push(RouteNames.verification),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Finance ────────────────────────────────────────────────────
            _SectionCard(
              title: 'Finance',
              items: [
                _SettingsTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Earnings & Withdrawals',
                  onTap: () => context.push(RouteNames.earnings),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Account ───────────────────────────────────────────────────
            _SectionCard(
              title: 'Account',
              items: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => context.push(RouteNames.notifications),
                ),
                _SettingsTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () => context.push(RouteNames.support),
                ),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  labelColor: AppColors.error,
                  iconColor: AppColors.error,
                  showDivider: false,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Logout', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(authStateNotifierProvider.notifier).signOut();
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // App version
            Text('AmanGhar v1.0.0', style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled)),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.user, this.profile, required this.ref});
  final dynamic user;
  final dynamic profile;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.providerEditProfile),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                AppAvatar(imageUrl: user?.profilePhoto, name: user?.name ?? '', size: 64.w),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                      if (picked != null) {
                        await ref.read(profileNotifierProvider.notifier).uploadProfilePhoto(File(picked.path));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, size: 12.w, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? '', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text(
                    profile?.serviceCategory ?? '',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '★ ${(user?.rating as double?)?.toStringAsFixed(1) ?? '0.0'} · ${profile?.totalReviews ?? 0} reviews',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Section Card ──────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.items});
  final String title;
  final List<_SettingsTile> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelColor,
    this.iconColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? labelColor;
  final Color? iconColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 22.w),
          title: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: labelColor)),
          trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18.w),
          onTap: onTap,
          dense: true,
        ),
        if (showDivider) const Divider(height: 1, indent: 56),
      ],
    );
  }
}
