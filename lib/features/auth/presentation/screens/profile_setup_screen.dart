// lib/features/auth/presentation/screens/profile_setup_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/providers/app_config_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/profile_setup_provider.dart';

/// Profile setup screen for both hirers and providers.
/// After submit, GoRouter redirect sends hirers to /hirer/home
/// and providers to /provider-setup.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedCity;
  String? _photoUrl;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      Validators.name(_nameCtrl.text) == null &&
      Validators.phone(_phoneCtrl.text) == null &&
      _selectedCity != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Explicitly fetch the exact user document to avoid any stream delays or nulls
    final userDoc = await FirebaseFirestore.instance
        .doc(FirestorePaths.user(FirebaseAuth.instance.currentUser!.uid))
        .get();
    final role = userDoc.data()?['role'] as String? ?? 'hirer';

    final ok = await ref.read(profileSetupNotifierProvider.notifier).submit(
          role: role,
          name: _nameCtrl.text,
          phone: _phoneCtrl.text,
          city: _selectedCity!,
          photoUrl: _photoUrl,
        );

    if (!ok && mounted) {
      final err = ref.read(profileSetupNotifierProvider).error ??
          context.l10n.errorGeneric;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(profileSetupNotifierProvider.notifier).clearError();
    }
    // GoRouter redirect handles navigation automatically
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileSetupNotifierProvider);
    final configState = ref.watch(appConfigProvider);

    // Handle loading and error states for config
    final cities = configState.when(
      data: (c) => c.cities,
      loading: () => <String>[],
      error: (err, stack) => <String>[],
    );

    // Seed name from Google display name
    final googleName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    if (_nameCtrl.text.isEmpty && googleName.isNotEmpty) {
      _nameCtrl.text = googleName;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(context.l10n.profileSetupTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 24.w,
                vertical: 24.h,
              ),
              children: [
                // Step indicator
                const _StepIndicator(current: 1, total: 2),
                SizedBox(height: 32.h),

                // Photo Upload
                Center(
                  child: Stack(
                    children: [
                      AppAvatar(
                        imageUrl: _photoUrl,
                        name: _nameCtrl.text.isEmpty ? '?' : _nameCtrl.text,
                        size: 100.w,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 20.w),
                          ),
                        ),
                      ),
                      if (profileState.isUploadingPhoto)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Fields
                AppTextField(
                  label: context.l10n.profileSetupNameLabel,
                  hint: context.l10n.profileSetupNameHint,
                  controller: _nameCtrl,
                  validator: Validators.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 20.h),

                AppTextField(
                  label: context.l10n.profileSetupPhoneLabel,
                  hint: context.l10n.profileSetupPhoneHint,
                  controller: _phoneCtrl,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 20.h),

                // City dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.profileSetupCityLabel,
                        style: AppTextStyles.labelMedium),
                    SizedBox(height: AppSpacing.xs),
                    configState.when(
                      data: (_) => DropdownButtonFormField<String>(
                        initialValue: _selectedCity,
                        hint: Text(
                          context.l10n.profileSetupCityHint,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textDisabled),
                        ),
                        items: cities
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child:
                                      Text(c, style: AppTextStyles.bodyMedium),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCity = v),
                        validator: (v) =>
                            v == null ? context.l10n.validationRequired : null,
                        decoration: const InputDecoration(),
                      ),
                      loading: () => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (err, stack) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.error),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Failed to load cities',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),

                AppButton(
                  label: context.l10n.profileSetupCompleteButton,
                  isLoading: profileState.isSubmitting,
                  onPressed: _isFormValid ? _submit : null,
                ),
              ]
                  .animate(interval: 80.ms)
                  .fadeIn(duration: AppDurations.normal)
                  .slideY(begin: 0.08, end: 0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      final url = await ref
          .read(profileSetupNotifierProvider.notifier)
          .uploadPhoto(File(picked.path));
      if (url != null) {
        setState(() => _photoUrl = url);
      }
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i + 1 == current || i + 1 < current;
        return Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsetsDirectional.only(end: i < total - 1 ? 8.w : 0),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }
}
