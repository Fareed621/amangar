// lib/features/auth/presentation/screens/provider_additional_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_config_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/provider_setup_provider.dart';

/// Provider additional setup screen (step 2 of onboarding).
/// Sets service category, skills, languages, rates, and bio.
/// GoRouter redirect sends to /provider/home on completion.
class ProviderAdditionalSetupScreen extends ConsumerStatefulWidget {
  const ProviderAdditionalSetupScreen({super.key});

  @override
  ConsumerState<ProviderAdditionalSetupScreen> createState() =>
      _ProviderSetupState();
}

class _ProviderSetupState
    extends ConsumerState<ProviderAdditionalSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullTimeRateCtrl = TextEditingController();
  final _partTimeRateCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  String? _serviceCategory;
  final Set<String> _selectedSkills = {};
  final Set<String> _selectedLanguages = {};
  int _experienceYears = 0;

  static const _experienceOptions = [
    (label: 'Less than 1 year', value: 0, level: '0-2 years'),
    (label: '1–2 years', value: 1, level: '0-2 years'),
    (label: '3–5 years', value: 3, level: '3-5 years'),
    (label: '5+ years', value: 5, level: '5+ years'),
  ];

  @override
  void dispose() {
    _fullTimeRateCtrl.dispose();
    _partTimeRateCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    if (_serviceCategory == null) return false;
    if (_selectedSkills.isEmpty) return false;
    if (_selectedLanguages.isEmpty) return false;
    if (Validators.fullTimeRate(_fullTimeRateCtrl.text) != null) return false;
    if (Validators.partTimeRate(_partTimeRateCtrl.text) != null) return false;
    return true;
  }

  String _experienceLevelFor(int years) {
    if (years >= 5) return '5+ years';
    if (years >= 3) return '3-5 years';
    return '0-2 years';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final fullTimeRate =
        int.tryParse(_fullTimeRateCtrl.text.replaceAll(',', '')) ?? 0;
    final partTimeRate =
        int.tryParse(_partTimeRateCtrl.text.replaceAll(',', '')) ?? 0;

    final ok = await ref.read(providerSetupNotifierProvider.notifier).submit(
          serviceCategory: _serviceCategory!,
          skills: _selectedSkills.toList(),
          languages: _selectedLanguages.toList(),
          fullTimeRate: fullTimeRate,
          partTimeRate: partTimeRate,
          experienceYears: _experienceYears,
          experienceLevel: _experienceLevelFor(_experienceYears),
          bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        );

    if (!ok && mounted) {
      final err =
          ref.read(providerSetupNotifierProvider).error ?? context.l10n.errorGeneric;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(providerSetupNotifierProvider.notifier).clearError();
    }
    // GoRouter redirect handles navigation
  }

  @override
  Widget build(BuildContext context) {
    final providerState = ref.watch(providerSetupNotifierProvider);
    final skillTagsAsync = ref.watch(skillTagsProvider);

    final List<String> skills = skillTagsAsync.whenOrNull(
            data: (t) => _serviceCategory == 'cook' ? t.cookSkills : t.maidSkills) ??
        [];
    final List<String> languages =
        skillTagsAsync.whenOrNull(data: (t) => t.languages) ?? [];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(context.l10n.providerSetupTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 24.w, vertical: 24.h),
              children: [
                // Step 2 indicator
                Row(children: [
                  Expanded(
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 32.h),

                // Service Category
                Text(context.l10n.providerSetupCategoryLabel,
                    style: AppTextStyles.headlineMedium),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _CategoryCard(
                        icon: Icons.restaurant_rounded,
                        label: context.l10n.providerSetupCookTitle,
                        isSelected: _serviceCategory == 'cook',
                        bgColor: AppColors.cookTint,
                        fgColor: AppColors.secondary,
                        onTap: () => setState(() {
                          _serviceCategory = 'cook';
                          _selectedSkills.clear();
                        }),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _CategoryCard(
                        icon: Icons.cleaning_services_rounded,
                        label: context.l10n.providerSetupMaidTitle,
                        isSelected: _serviceCategory == 'maid',
                        bgColor: AppColors.maidTint,
                        fgColor: AppColors.primary,
                        onTap: () => setState(() {
                          _serviceCategory = 'maid';
                          _selectedSkills.clear();
                        }),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),

                // Skills
                if (_serviceCategory != null && skills.isNotEmpty) ...[
                  Text(context.l10n.providerSetupSkillsLabel,
                      style: AppTextStyles.headlineSmall),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: skills.map((s) {
                      final sel = _selectedSkills.contains(s);
                      return FilterChip(
                        label: Text(s),
                        selected: sel,
                        onSelected: (_) => setState(() {
                          if (sel) {
                            _selectedSkills.remove(s);
                          } else {
                            _selectedSkills.add(s);
                          }
                        }),
                        selectedColor: AppColors.primary.withValues(alpha: 0.12),
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: sel ? AppColors.primary : AppColors.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedSkills.isEmpty)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 4.h),
                      child: Text(
                        context.l10n.providerSetupSkillsHint,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  SizedBox(height: 28.h),
                ],

                // Experience
                Text(context.l10n.providerSetupExperienceLabel,
                    style: AppTextStyles.headlineSmall),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _experienceOptions.map((opt) {
                    final sel = _experienceYears == opt.value;
                    return ChoiceChip(
                      label: Text(opt.label),
                      selected: sel,
                      onSelected: (_) =>
                          setState(() => _experienceYears = opt.value),
                      selectedColor: AppColors.primary.withValues(alpha: 0.12),
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: sel ? AppColors.primary : AppColors.onSurface,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 28.h),

                // Languages
                if (languages.isNotEmpty) ...[
                  Text(context.l10n.providerSetupLanguagesLabel,
                      style: AppTextStyles.headlineSmall),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: languages.map((l) {
                      final sel = _selectedLanguages.contains(l);
                      return FilterChip(
                        label: Text(l),
                        selected: sel,
                        onSelected: (_) => setState(() {
                          if (sel) {
                            _selectedLanguages.remove(l);
                          } else {
                            _selectedLanguages.add(l);
                          }
                        }),
                        selectedColor: AppColors.primary.withValues(alpha: 0.12),
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: sel ? AppColors.primary : AppColors.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 28.h),
                ],

                // Rates
                AppTextField(
                  label: context.l10n.providerSetupFullTimeRateLabel,
                  hint: '20000',
                  controller: _fullTimeRateCtrl,
                  validator: Validators.fullTimeRate,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 20.h),
                AppTextField(
                  label: context.l10n.providerSetupPartTimeRateLabel,
                  hint: '500',
                  controller: _partTimeRateCtrl,
                  validator: Validators.partTimeRate,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 20.h),

                // Bio
                AppTextField(
                  label: context.l10n.providerSetupBioLabel,
                  hint: context.l10n.providerSetupBioHint,
                  controller: _bioCtrl,
                  validator: Validators.bio,
                  maxLines: 4,
                  maxLength: AppLimits.maxBioLength,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 40.h),

                AppButton(
                  label: context.l10n.providerSetupGetStartedButton,
                  isLoading: providerState.isSubmitting,
                  onPressed: _isFormValid ? _submit : null,
                ),
                SizedBox(height: 24.h),
              ]
                  .animate(interval: 60.ms)
                  .fadeIn(duration: AppDurations.normal)
                  .slideY(begin: 0.08, end: 0),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.bgColor,
    required this.fgColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color bgColor;
  final Color fgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        height: 120.h,
        decoration: BoxDecoration(
          color: isSelected ? bgColor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? fgColor : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 32.w, color: isSelected ? fgColor : AppColors.textSecondary),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? fgColor : AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
