import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/models/user_model.dart';
import '../providers/report_provider.dart';

void showReportBottomSheet(
  BuildContext context,
  UserModel target, {
  String? bookingId,
  String? chatId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReportBottomSheet(
      target: target,
      bookingId: bookingId,
      chatId: chatId,
    ),
  );
}

class ReportBottomSheet extends ConsumerStatefulWidget {
  const ReportBottomSheet({
    super.key,
    required this.target,
    this.bookingId,
    this.chatId,
  });

  final UserModel target;
  final String? bookingId;
  final String? chatId;

  @override
  ConsumerState<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends ConsumerState<ReportBottomSheet> {
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportNotifierProvider);
    final notifier = ref.read(reportNotifierProvider.notifier);

    final reasons = [
      'Inappropriate behavior',
      'Harassment',
      'Fake profile',
      'Payment issues',
      'Service not as described',
      'Other',
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text('Report ${widget.target.name}', style: AppTextStyles.headlineSmall),
                SizedBox(height: 16.h),
                Text('Select reason(s)', style: AppTextStyles.labelLarge),
                SizedBox(height: 8.h),
                ...reasons.map((reason) => CheckboxListTile(
                      title: Text(reason, style: AppTextStyles.bodyMedium),
                      value: state.selectedReasons.contains(reason),
                      onChanged: (_) => notifier.toggleReason(reason),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
                if (state.selectedReasons.contains('Other')) ...[
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: 'Details',
                    hint: 'Tell us more about the issue...',
                    controller: _detailsController,
                    onChanged: notifier.setDetails,
                    maxLines: 3,
                  ),
                ],
                SizedBox(height: 16.h),
                SwitchListTile(
                  title: Text('Also block this user', style: AppTextStyles.bodyMedium),
                  subtitle: const Text('They won\'t be able to message or see your profile'),
                  value: state.alsoBlock,
                  onChanged: notifier.setAlsoBlock,
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 24.h),
                if (state.error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      state.error!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                AppButton(
                  label: 'Submit Report',
                  isLoading: state.isSubmitting,
                  onPressed: state.selectedReasons.isNotEmpty
                      ? () async {
                          final ok = await notifier.submit(
                            targetUser: widget.target,
                            bookingId: widget.bookingId,
                            chatId: widget.chatId,
                          );
                          if (ok && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Report submitted')),
                            );
                          }
                        }
                      : null,
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }
}
