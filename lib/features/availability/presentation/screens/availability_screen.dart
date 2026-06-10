import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/models/date_override_model.dart';
import '../../../../core/models/weekly_template_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../presentation/providers/availability_notifier.dart';

class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availabilityNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Availability'),
        actions: [
          TextButton(
            onPressed: state.isDirty && !state.isSaving
                ? () => ref
                    .read(availabilityNotifierProvider.notifier)
                    .saveTemplate()
                : null,
            child: state.isSaving
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2))
                : Text('Save',
                    style: TextStyle(
                        color: state.isDirty
                            ? AppColors.primary
                            : AppColors.textDisabled)),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1: Weekly Template
                  SectionHeader(title: 'Weekly Schedule'),
                  SizedBox(height: 12.h),
                  if (state.template != null)
                    _WeeklyTemplateSection(template: state.template!),

                  SizedBox(height: 32.h),

                  // SECTION 2: Date Overrides
                  SectionHeader(title: 'Block / Unblock Specific Dates'),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap a date to block it. Tap a blocked date to unblock.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 12.h),
                  _DateOverrideCalendar(state: state),

                  SizedBox(height: 16.h),
                  // Legend
                  Wrap(
                    spacing: 16.w,
                    runSpacing: 8.h,
                    children: [
                      _LegendItem(
                          color: AppColors.error.withValues(alpha: 0.3),
                          label: 'Blocked'),
                      _LegendItem(
                          color: AppColors.success.withValues(alpha: 0.3),
                          label: 'Manually Available'),
                      _LegendItem(
                          color: Colors.grey.withValues(alpha: 0.3),
                          label: 'Template Unavailable'),
                      _LegendItem(
                          color: AppColors.error.withValues(alpha: 0.6),
                          label: 'Booked (locked)'),
                    ],
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
    );
  }
}

class _WeeklyTemplateSection extends ConsumerWidget {
  const _WeeklyTemplateSection({required this.template});
  final WeeklyTemplateModel template;

  static const _dayLabels = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(availabilityNotifierProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: List.generate(_dayLabels.length, (i) {
          final key = _dayLabels[i];
          final day =
              template.template[key] ?? const DayTemplate(isAvailable: false);
          final isLast = i == _dayLabels.length - 1;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90.w,
                      child:
                          Text(_dayNames[i], style: AppTextStyles.bodyMedium),
                    ),
                    Expanded(
                      child: day.isAvailable
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  _TimeButton(
                                    time: day.startTime ?? '09:00',
                                    onTap: () => _pickTime(
                                        context,
                                        ref,
                                        notifier,
                                        key,
                                        true,
                                        day.startTime ?? '09:00'),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Text('to',
                                        style: AppTextStyles.caption),
                                  ),
                                  _TimeButton(
                                    time: day.endTime ?? '17:00',
                                    onTap: () => _pickTime(
                                        context,
                                        ref,
                                        notifier,
                                        key,
                                        false,
                                        day.endTime ?? '17:00'),
                                  ),
                                ],
                              ),
                            )
                          : Text('Unavailable',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary)),
                    ),
                    Switch(
                      value: day.isAvailable,
                      onChanged: (v) => notifier.toggleDay(key, v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1.h),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _pickTime(
      BuildContext context,
      WidgetRef ref,
      AvailabilityNotifier notifier,
      String key,
      bool isStart,
      String current) async {
    final parts = current.split(':');
    final initial =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t != null) {
      final formatted =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      notifier.updateDayTime(key,
          startTime: isStart ? formatted : null,
          endTime: isStart ? null : formatted);
    }
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.time, required this.onTap});
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parts = time.split(':');
    final h = int.tryParse(parts[0]) ?? 9;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final display = DateFormat('h:mm a').format(DateTime(2000, 1, 1, h, m));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(display,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
      ),
    );
  }
}

class _DateOverrideCalendar extends ConsumerWidget {
  const _DateOverrideCalendar({required this.state});
  final dynamic state; // AvailabilityState

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(availabilityNotifierProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: TableCalendar(
        firstDay: DateTime(2024, 1, 1),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: state.viewMonth,
        onPageChanged: (d) => notifier.changeMonth(d),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (ctx, day, focusedDay) =>
              _buildDayCell(ctx, day, state),
          todayBuilder: (ctx, day, focusedDay) =>
              _buildDayCell(ctx, day, state, isToday: true),
        ),
        onDaySelected: (selected, focused) {
          final normalized =
              DateTime(selected.year, selected.month, selected.day);
          // Check if it has a booking (locked) — don't allow tapping
          final override = (state.dateOverrides as List)
              .cast<DateOverrideModel>()
              .where((o) {
            final d = o.date.toDate();
            return DateTime(d.year, d.month, d.day) == normalized;
          }).firstOrNull;
          if (override?.bookingId != null) return; // locked
          notifier.toggleDateOverride(normalized);
        },
        headerStyle:
            const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),
      ),
    );
  }

  Widget _buildDayCell(BuildContext ctx, DateTime day, dynamic state,
      {bool isToday = false}) {
    final normalized = DateTime(day.year, day.month, day.day);
    final overrides = (state.dateOverrides as List).cast<DateOverrideModel>();
    final override = overrides.where((o) {
      final d = o.date.toDate();
      return DateTime(d.year, d.month, d.day) == normalized;
    }).firstOrNull;

    Color bgColor = Colors.transparent;
    Color textColor = AppColors.onBackground;
    Widget? badge;

    if (override?.bookingId != null) {
      bgColor = AppColors.error.withValues(alpha: 0.6);
      textColor = Colors.white;
      badge = Icon(Icons.lock, size: 8.w, color: Colors.white);
    } else if (override?.isBlocked == true) {
      bgColor = AppColors.error.withValues(alpha: 0.25);
      textColor = AppColors.error;
    } else if (override?.isBlocked == false) {
      bgColor = AppColors.success.withValues(alpha: 0.2);
      textColor = AppColors.success;
    } else {
      // Check template
      final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      final dayKey = days[day.weekday - 1];
      final tmpl =
          (state.template?.template as Map<String, DayTemplate>?)?[dayKey];
      if (tmpl != null && !tmpl.isAvailable) {
        bgColor = Colors.grey.withValues(alpha: 0.2);
        textColor = AppColors.textDisabled;
      }
    }

    if (isToday) bgColor = AppColors.primary.withValues(alpha: 0.15);

    return Container(
      margin: EdgeInsets.all(2.w),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('${day.day}',
              style: TextStyle(color: textColor, fontSize: 13.sp)),
          if (badge != null) Positioned(bottom: 4.h, right: 4.w, child: badge),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
