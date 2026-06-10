import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/models/withdrawal_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../providers/earnings_provider.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).valueOrNull?.uid ?? '';
    final profileAsync = ref.watch(providerDetailProvider(uid));
    final withdrawalsAsync = ref.watch(withdrawalsProvider);
    final ledgerState = ref.watch(earningsLedgerNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Earnings'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(earningsLedgerNotifierProvider.notifier).loadPage(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Summary Cards ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: profileAsync.when(
                      data: (p) => _SummaryCard(
                        label: 'Total Earned',
                        value: p?.profile?.totalEarningsTracked != null
                            ? Formatters.formatPrice(p!.profile!.totalEarningsTracked)
                            : '—',
                        icon: Icons.account_balance_wallet,
                        color: AppColors.primary,
                      ),
                      loading: () => AppSkeleton.rect(height: 80),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: profileAsync.when(
                      data: (p) => _SummaryCard(
                        label: 'This Month',
                        value: p?.profile?.currentMonthEarnings != null
                            ? Formatters.formatPrice(p!.profile!.currentMonthEarnings)
                            : '—',
                        icon: Icons.trending_up,
                        color: AppColors.secondary,
                      ),
                      loading: () => AppSkeleton.rect(height: 80),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // ── Withdraw Button ────────────────────────────────────────────
              AppButton(
                label: 'Withdraw Funds',
                onPressed: () => context.push(RouteNames.withdrawal),
              ),

              SizedBox(height: 28.h),

              // ── Withdrawal History ─────────────────────────────────────────
              withdrawalsAsync.when(
                data: (withdrawals) {
                  if (withdrawals.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Withdrawal History'),
                      SizedBox(height: 12.h),
                      ...withdrawals.map((w) => _WithdrawalTile(withdrawal: w)),
                      SizedBox(height: 20.h),
                    ],
                  );
                },
                loading: () => Column(
                  children: [
                    SectionHeader(title: 'Withdrawal History'),
                    SizedBox(height: 12.h),
                    AppSkeleton.rect(height: 60),
                    SizedBox(height: 8.h),
                    AppSkeleton.rect(height: 60),
                  ],
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // ── Transaction Ledger ─────────────────────────────────────────
              SectionHeader(title: 'Transaction History'),
              SizedBox(height: 12.h),

              if (ledgerState.isLoading && ledgerState.items.isEmpty)
                Column(
                  children: List.generate(
                    5,
                    (_) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: AppSkeleton.rect(height: 50),
                    ),
                  ),
                )
              else if (ledgerState.items.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text('No transactions yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                )
              else
                Column(
                  children: [
                    ...ledgerState.items.map((item) => _LedgerRow(
                          date: Formatters.formatDate(item.createdAt),
                          name: item.hirerName ?? item.serviceCategory,
                          amount: item.amount,
                          isCredit: item.entryType == 'credit',
                        )),
                    if (ledgerState.hasMore)
                      Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: AppButton.secondary(
                          label: ledgerState.isLoading ? 'Loading...' : 'Load More',
                          onPressed: ledgerState.isLoading
                              ? null
                              : () => ref.read(earningsLedgerNotifierProvider.notifier).loadMore(),
                        ),
                      ),
                  ],
                ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
          SizedBox(height: 4.h),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  const _WithdrawalTile({required this.withdrawal});
  final WithdrawalModel withdrawal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.formatPrice(withdrawal.amount), style: AppTextStyles.labelMedium),
                Text(withdrawal.method.toUpperCase(), style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                if (withdrawal.createdAt != null)
                  Text(Formatters.formatDate(withdrawal.createdAt), style: AppTextStyles.caption),
              ],
            ),
          ),
          StatusBadge(status: withdrawal.status),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.date, required this.name, required this.amount, required this.isCredit});
  final String date;
  final String name;
  final int amount;
  final bool isCredit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                Text(date, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'} ${Formatters.formatPrice(amount)}',
            style: AppTextStyles.labelMedium.copyWith(color: isCredit ? AppColors.success : AppColors.error),
          ),
        ],
      ),
    );
  }
}
