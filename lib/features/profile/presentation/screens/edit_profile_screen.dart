import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/profile_provider.dart';

/// Shared edit profile screen for both hirers and providers.
/// Pass [isProvider] = true to show provider-specific fields.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.isProvider = false});
  final bool isProvider;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _fullRateCtrl = TextEditingController();
  final _partRateCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    _fullRateCtrl.dispose();
    _partRateCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  void _initControllers(dynamic user, dynamic profile) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = user?.name ?? '';
    _phoneCtrl.text = user?.phone ?? '';
    if (widget.isProvider && profile != null) {
      _bioCtrl.text = profile.bio ?? '';
      _fullRateCtrl.text = profile.fullTimeRate.toString();
      _partRateCtrl.text = profile.partTimeRate.toString();
      _expCtrl.text = profile.experienceYears.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final profileState = ref.watch(profileNotifierProvider);

    ref.listen(profileNotifierProvider.select((s) => s.isSuccess), (_, success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    });

    ref.listen(profileNotifierProvider.select((s) => s.error), (_, err) {
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      }
    });

    _initControllers(user, null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Common Fields ────────────────────────────────────────────
              AppTextField(
                label: 'Full Name',
                hint: 'Your full name',
                controller: _nameCtrl,
                validator: Validators.name,
              ),

              SizedBox(height: 16.h),

              AppTextField(
                label: 'Phone Number',
                hint: '03001234567',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),

              // ── Provider-specific Fields ─────────────────────────────────
              if (widget.isProvider) ...[
                SizedBox(height: 16.h),
                AppTextField(
                  label: 'Bio / About Me',
                  hint: 'Tell hirers about yourself, your skills and experience...',
                  controller: _bioCtrl,
                  maxLines: 4,
                  validator: null,
                ),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Full-time Rate (PKR/day)',
                        hint: '20000',
                        controller: _fullRateCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) => (int.tryParse(v ?? '') == null || int.parse(v!) <= 0)
                            ? 'Invalid rate'
                            : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppTextField(
                        label: 'Part-time Rate (PKR/hr)',
                        hint: '800',
                        controller: _partRateCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) => (int.tryParse(v ?? '') == null || int.parse(v!) <= 0)
                            ? 'Invalid rate'
                            : null,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                AppTextField(
                  label: 'Years of Experience',
                  hint: '3',
                  controller: _expCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => int.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
              ],

              SizedBox(height: 32.h),

              AppButton(
                label: 'Save Changes',
                isLoading: profileState.isUpdating,
                onPressed: profileState.isUpdating ? null : _save,
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(profileNotifierProvider.notifier);

    // Update user document
    await notifier.updateProfile({
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    });

    // Update providerProfile if applicable
    if (widget.isProvider) {
      await notifier.updateProviderProfile({
        'bio': _bioCtrl.text.trim(),
        'fullTimeRate': int.tryParse(_fullRateCtrl.text.trim()) ?? 0,
        'partTimeRate': int.tryParse(_partRateCtrl.text.trim()) ?? 0,
        'experienceYears': int.tryParse(_expCtrl.text.trim()) ?? 0,
      });
    }
  }
}
