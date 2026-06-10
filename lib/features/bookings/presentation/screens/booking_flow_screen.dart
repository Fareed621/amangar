import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/availability_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../../../availability/presentation/providers/availability_provider.dart';
import '../providers/booking_flow_provider.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key, required this.providerId});
  final String providerId;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final providerDetail =
        await ref.read(providerDetailProvider(widget.providerId).future);
    if (providerDetail != null) {
      ref.read(bookingFlowProvider.notifier).initProvider(providerDetail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingFlowProvider);
    final notifier = ref.read(bookingFlowProvider.notifier);

    ref.listen(bookingFlowProvider.select((s) => s.error), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next)));
      }
    });

    if (state.isSuccess) {
      return _SuccessStep(bookingId: state.lastBookingId ?? '');
    }

    final title = state.providerName != null
        ? 'Book ${state.providerName!.split(' ').first}'
        : 'Book Provider';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (state.currentStep == 0) {
              context.pop();
            } else {
              notifier.previousStep();
            }
          },
        ),
        title: Text(title, style: AppTextStyles.headlineSmall),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.h),
          child: LinearProgressIndicator(
            value: (state.currentStep + 1) / 4,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 120.h),
          child: _buildStep(state, notifier),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: state.currentStep == 3
            ? AppButton(
                label: 'Confirm Booking',
                isLoading: state.isSubmitting,
                onPressed:
                    state.canSubmit ? () => notifier.submit(context) : null,
              )
            : AppButton(
                label: 'Next',
                onPressed: state.canProceed ? notifier.nextStep : null,
              ),
      ),
    );
  }

  Widget _buildStep(BookingFlowState state, BookingFlow notifier) {
    // Adding Keys to each step to ensure full widget tree reset and avoid layout bleed/overlap
    switch (state.currentStep) {
      case 0:
        return _ServiceTypeStep(
            key: const ValueKey('step_0'), state: state, notifier: notifier);
      case 1:
        return _DateTimeStep(
            key: const ValueKey('step_1'),
            state: state,
            notifier: notifier,
            providerId: widget.providerId);
      case 2:
        return _NotesStep(
            key: const ValueKey('step_2'), state: state, notifier: notifier);
      case 3:
        return _ReviewAndConfirmStep(
            key: const ValueKey('step_3'), state: state, notifier: notifier);
      default:
        return const Center(child: Text('Unknown step'));
    }
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: AppColors.primary, size: 80.w),
              ),
              SizedBox(height: 32.h),
              Text('Booking Placed!', style: AppTextStyles.headlineLarge),
              SizedBox(height: 16.h),
              Text(
                'Your request has been sent to the provider. You can track the status in your dashboard.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 48.h),
              AppButton(
                label: 'View Booking Details',
                onPressed: () =>
                    context.pushReplacement(RouteNames.bookingDetailPath(bookingId)),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => context.go(RouteNames.hirerHome),
                child: Text('Back to Home',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTypeStep extends StatelessWidget {
  const _ServiceTypeStep(
      {super.key, required this.state, required this.notifier});
  final BookingFlowState state;
  final BookingFlow notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Choose Service Type', style: AppTextStyles.headlineMedium),
          SizedBox(height: 8.h),
          Text('Full-time for the whole day, part-time for a few hours',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 32.h),
          _ServiceTypeCard(
            title: 'Full-time',
            subtitle: state.fullTimeRate != null
                ? Formatters.formatPricePerDay(state.fullTimeRate!)
                : 'N/A',
            icon: Icons.wb_sunny_outlined,
            isSelected: state.serviceType == 'full_time',
            onTap: () => notifier.setServiceType('full_time'),
          ),
          SizedBox(height: 16.h),
          _ServiceTypeCard(
            title: 'Part-time',
            subtitle: state.partTimeRate != null
                ? Formatters.formatPricePerHour(state.partTimeRate!)
                : 'N/A',
            icon: Icons.schedule_outlined,
            isSelected: state.serviceType == 'part_time',
            onTap: () => notifier.setServiceType('part_time'),
          ),
        ],
      ),
    );
  }
}

class _ServiceTypeCard extends StatelessWidget {
  const _ServiceTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: 2),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 32.w,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineSmall),
                  Text(subtitle,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24.w),
          ],
        ),
      ),
    );
  }
}

class _DateTimeStep extends ConsumerStatefulWidget {
  const _DateTimeStep(
      {super.key,
      required this.state,
      required this.notifier,
      required this.providerId});
  final BookingFlowState state;
  final BookingFlow notifier;
  final String providerId;

  @override
  ConsumerState<_DateTimeStep> createState() => _DateTimeStepState();
}

class _DateTimeStepState extends ConsumerState<_DateTimeStep> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final startMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final unavailableDatesAsync = ref.watch(
        unavailableDatesProvider(widget.providerId, startMonth, endMonth));

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [


          SizedBox(height: 32.h),
          Text('Select Date(s)', style: AppTextStyles.headlineMedium),
          SizedBox(height: 16.h),

          unavailableDatesAsync.when(
            data: (unavailableDates) {
              return Container(
                padding: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.divider),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 90)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return widget.state.dates.any((d) => isSameDay(d, day));
                  },
                  enabledDayPredicate: (day) {
                    final n = DateTime(day.year, day.month, day.day);
                    return !unavailableDates.contains(n);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    final n = DateTime(
                        selectedDay.year, selectedDay.month, selectedDay.day);
                    if (unavailableDates.contains(n)) return;

                    setState(() => _focusedDay = focusedDay);

                    final newDates = List<DateTime>.from(widget.state.dates);
                    if (newDates.any((d) => isSameDay(d, selectedDay))) {
                      newDates.removeWhere((d) => isSameDay(d, selectedDay));
                    } else {
                      if (newDates.length < AppLimits.maxBookingDates) {
                        newDates.add(selectedDay);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Maximum 31 dates allowed')),
                        );
                      }
                    }
                    newDates.sort();
                    widget.notifier.setDates(newDates);
                  },
                  onPageChanged: (focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    disabledTextStyle:
                        const TextStyle(color: AppColors.textDisabled),
                    disabledDecoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
            loading: () => Container(
              height: 300.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error loading calendar: $e'),
          ),

          SizedBox(height: 32.h),
          Text('Select Time', style: AppTextStyles.headlineMedium),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(true),
                  child: Text(widget.state.startTime),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(false),
                  child: Text(widget.state.endTime),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '${calculateDurationHours(widget.state.startTime, widget.state.endTime).toStringAsFixed(1)} hours per day',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),

          SizedBox(height: 32.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                Text('Total Estimated Price', style: AppTextStyles.bodyMedium),
                SizedBox(height: 8.h),
                Text(
                  Formatters.formatPrice(widget.state.computedPrice),
                  style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? widget.state.startTime : widget.state.endTime;
    final parts = current.split(':');
    final initial =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final time = await showTimePicker(context: context, initialTime: initial);
    if (time != null) {
      final formatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        widget.notifier.setStartTime(formatted);
      } else {
        widget.notifier.setEndTime(formatted);
      }
    }
  }
}

class _NotesStep extends StatelessWidget {
  const _NotesStep({super.key, required this.state, required this.notifier});
  final BookingFlowState state;
  final BookingFlow notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Any Special Instructions?', style: AppTextStyles.headlineSmall),
          SizedBox(height: 8.h),
          Text('Optional - shown to the provider before they accept.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 24.h),
          TextFormField(
            initialValue: state.notes,
            decoration: const InputDecoration(
              hintText: 'e.g. Biryani for 10 people, halal only...',
            ),
            maxLines: 5,
            maxLength: AppLimits.maxBookingNotesLength,
            onChanged: notifier.setNotes,
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Notes cannot be edited after booking is placed.',
                    style:
                        AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewAndConfirmStep extends StatelessWidget {
  const _ReviewAndConfirmStep(
      {super.key, required this.state, required this.notifier});
  final BookingFlowState state;
  final BookingFlow notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Review Your Booking', style: AppTextStyles.headlineMedium),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(
                        imageUrl: state.providerPhoto,
                        name: state.providerName ?? 'Unknown',
                        size: 40.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.providerName ?? 'Provider',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold)),
                          Text(state.serviceCategory?.toUpperCase() ?? '',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 32.h),
                _SummaryRow(
                    label: 'Service',
                    value: state.serviceType == 'full_time'
                        ? 'Full-time'
                        : 'Part-time'),
                _SummaryRow(
                    label: 'Date(s)',
                    value: state.dates.isEmpty
                        ? 'None'
                        : '${Formatters.formatDate(Timestamp.fromDate(state.dates.first))} ${state.dates.length > 1 ? '+${state.dates.length - 1} more' : ''}'),
                _SummaryRow(
                    label: 'Time',
                    value: '${state.startTime} - ${state.endTime}'),
                _SummaryRow(
                    label: 'Duration',
                    value:
                        '${calculateDurationHours(state.startTime, state.endTime).toStringAsFixed(1)} hours/day'),
                Divider(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(Formatters.formatPrice(state.computedPrice),
                        style: AppTextStyles.headlineMedium
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Cancellations made within 24 hours of the start time may incur a fee according to the provider\'s policy.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Checkbox(
                value: state.termsAccepted,
                onChanged: (val) => notifier.setTermsAccepted(val ?? false),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => notifier.setTermsAccepted(!state.termsAccepted),
                  child: Text('I agree to the cancellation policy',
                      style: AppTextStyles.bodyMedium),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
