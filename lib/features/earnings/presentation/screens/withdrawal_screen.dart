import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/withdrawal_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/earnings_provider.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();

  String _method = 'jazzcash';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accountCtrl.dispose();
    _ibanCtrl.dispose();
    _bankNameCtrl.dispose();
    _holderNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wState = ref.watch(withdrawalNotifierProvider);

    ref.listen(withdrawalNotifierProvider.select((s) => s.isSuccess), (_, success) {
      if (success) {
        _showSuccessAndPop();
      }
    });

    ref.listen(withdrawalNotifierProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.error));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, title: const Text('Request Withdrawal')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount field
              AppTextField(
                label: 'Amount (PKR)',
                hint: 'Minimum PKR ${AppLimits.minWithdrawalAmount}',
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.withdrawalAmount,
              ),

              SizedBox(height: 24.h),

              // Method selection
              Text('Transfer Method', style: AppTextStyles.headlineSmall),
              SizedBox(height: 12.h),
              ...[
                ('jazzcash', 'JazzCash', Icons.phone_android),
                ('easypaisa', 'EasyPaisa', Icons.phone_iphone),
                ('bank', 'Bank Transfer (IBAN)', Icons.account_balance),
              ].map((m) => _MethodCard(
                    label: m.$2,
                    icon: m.$3,
                    value: m.$1,
                    groupValue: _method,
                    onChanged: (v) => setState(() => _method = v ?? _method),
                  )),

              SizedBox(height: 20.h),

              // Conditional fields
              if (_method == 'jazzcash' || _method == 'easypaisa')
                AppTextField(
                  label: 'Account Number (03XXXXXXXXX)',
                  hint: '03001234567',
                  controller: _accountCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.length < 11) ? 'Enter valid account number' : null,
                ),
              if (_method == 'bank') ...[
                AppTextField(
                  label: 'IBAN Number',
                  hint: 'PK36SCBL0000001123456702',
                  controller: _ibanCtrl,
                  validator: (v) => (v == null || v.isEmpty) ? 'IBAN is required' : null,
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  label: 'Bank Name',
                  hint: 'e.g. HBL, Meezan, UBL...',
                  controller: _bankNameCtrl,
                  validator: (v) => (v == null || v.isEmpty) ? 'Bank name is required' : null,
                ),
              ],

              SizedBox(height: 16.h),

              AppTextField(
                label: 'Account Holder Name',
                hint: 'Full name as on account',
                controller: _holderNameCtrl,
                validator: (v) => (v == null || v.isEmpty) ? 'Holder name is required' : null,
              ),

              SizedBox(height: 24.h),

              // Info card
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning, size: 18.w),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Processing takes 1–2 business days. Any transfer fees are borne by you.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              AppButton(
                label: 'Submit Request',
                isLoading: wState.isSubmitting,
                onPressed: wState.isSubmitting ? null : _submit,
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    final accountDetails = _method == 'bank'
        ? _ibanCtrl.text.trim()
        : _accountCtrl.text.trim();

    final withdrawal = WithdrawalModel(
      id: const Uuid().v4(),
      providerId: user.uid,
      providerName: user.name,
      providerPhone: user.phone ?? '',
      amount: amount,
      method: _method,
      accountDetails: accountDetails,
      accountHolderName: _holderNameCtrl.text.trim(),
      status: 'pending',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await ref.read(withdrawalNotifierProvider.notifier).submit(withdrawal);
  }

  void _showSuccessAndPop() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 64.w),
            SizedBox(height: 16.h),
            Text('Withdrawal Requested!', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text('Your request has been submitted. We will process it within 1–2 business days.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // pop dialog
        Navigator.of(context).pop(); // pop withdrawal screen
      }
    });
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({required this.label, required this.icon, required this.value, required this.groupValue, required this.onChanged});
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            if (selected) Icon(Icons.check_circle, color: AppColors.primary, size: 20.w),
          ],
        ),
      ),
    );
  }
}
