import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class OnboardingSuccessScreen extends StatelessWidget {
  const OnboardingSuccessScreen({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isProvider = role == 'provider';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100.w,
                height: 100.w,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 60.w),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).then().shimmer(),
              
              SizedBox(height: 32.h),
              Text(
                'Registration Complete!',
                style: AppTextStyles.displayLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              
              SizedBox(height: 16.h),
              Text(
                isProvider 
                    ? 'Your profile is now live. We recommend getting verified to build trust with hirers and get more bookings.'
                    : 'Your account is ready. You can now start browsing and booking providers for your home needs.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              
              const Spacer(),
              
              AppButton(
                label: isProvider ? 'Go to Dashboard' : 'Start Browsing',
                onPressed: () => context.go(isProvider ? RouteNames.providerHome : RouteNames.hirerHome),
              ).animate().fadeIn(delay: 800.ms),
              
              if (isProvider) ...[
                SizedBox(height: 12.h),
                AppButton.secondary(
                  label: 'Get Verified Now',
                  onPressed: () => context.go(RouteNames.verification),
                ).animate().fadeIn(delay: 1000.ms),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
