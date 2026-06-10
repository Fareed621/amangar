import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/search_filter_model.dart';
import '../providers/search_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late SearchFilterModel _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(searchFilterProvider);
  }

  void _apply() {
    ref.read(searchFilterProvider.notifier).updateFilter(_filter);
    Navigator.pop(context);
  }

  void _clear() {
    setState(() => _filter = const SearchFilterModel());
    ref.read(searchFilterProvider.notifier).clearAll();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                height: 4.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24.w),
                  children: [
                    Text('Filters', style: AppTextStyles.headlineLarge),
                    SizedBox(height: 24.h),

                    // 1. Sort By
                    _SectionHeader(title: 'Sort By'),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _ChoiceChip(
                          label: 'Highest Rated',
                          isSelected: _filter.sortBy == 'rating_desc',
                          onSelected: (val) => setState(() => _filter = _filter.copyWith(sortBy: 'rating_desc')),
                        ),
                        _ChoiceChip(
                          label: 'Most Reviewed',
                          isSelected: _filter.sortBy == 'reviews_desc',
                          onSelected: (val) => setState(() => _filter = _filter.copyWith(sortBy: 'reviews_desc')),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 2. Category
                    _SectionHeader(title: 'Category'),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        _ChoiceChip(
                          label: 'All',
                          isSelected: _filter.serviceCategory == null,
                          onSelected: (val) => setState(() => _filter = _filter.copyWith(serviceCategory: null)),
                        ),
                        _ChoiceChip(
                          label: 'Cook',
                          isSelected: _filter.serviceCategory == 'cook',
                          onSelected: (val) => setState(() => _filter = _filter.copyWith(serviceCategory: 'cook')),
                        ),
                        _ChoiceChip(
                          label: 'Maid',
                          isSelected: _filter.serviceCategory == 'maid',
                          onSelected: (val) => setState(() => _filter = _filter.copyWith(serviceCategory: 'maid')),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 3. City
                    _SectionHeader(title: 'City'),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: _filter.city,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      hint: const Text('Any City'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Any City')),
                        ...['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad', 'Multan', 'Peshawar', 'Quetta']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c))),
                      ],
                      onChanged: (val) => setState(() => _filter = _filter.copyWith(city: val)),
                    ),
                    SizedBox(height: 24.h),

                    // 4. Min Rating
                    _SectionHeader(title: 'Minimum Rating'),
                    SizedBox(height: 12.h),
                    Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return IconButton(
                          icon: Icon(
                            starValue <= _filter.minRating ? Icons.star : Icons.star_border,
                            color: AppColors.warning,
                          ),
                          onPressed: () => setState(() => _filter = _filter.copyWith(minRating: starValue.toDouble())),
                        );
                      }),
                    ),
                    SizedBox(height: 24.h),

                    // 5. Experience
                    _SectionHeader(title: 'Experience Level'),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        _ChoiceChip(
                          label: 'Beginner',
                          isSelected: _filter.experienceLevels.contains('beginner'),
                          onSelected: (selected) {
                            final levels = List<String>.from(_filter.experienceLevels);
                            if (selected) levels.add('beginner'); else levels.remove('beginner');
                            setState(() => _filter = _filter.copyWith(experienceLevels: levels));
                          },
                        ),
                        _ChoiceChip(
                          label: 'Intermediate',
                          isSelected: _filter.experienceLevels.contains('intermediate'),
                          onSelected: (selected) {
                            final levels = List<String>.from(_filter.experienceLevels);
                            if (selected) levels.add('intermediate'); else levels.remove('intermediate');
                            setState(() => _filter = _filter.copyWith(experienceLevels: levels));
                          },
                        ),
                        _ChoiceChip(
                          label: 'Expert',
                          isSelected: _filter.experienceLevels.contains('expert'),
                          onSelected: (selected) {
                            final levels = List<String>.from(_filter.experienceLevels);
                            if (selected) levels.add('expert'); else levels.remove('expert');
                            setState(() => _filter = _filter.copyWith(experienceLevels: levels));
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 6. Availability
                    _SectionHeader(title: 'Availability'),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        _ChoiceChip(
                          label: 'Both',
                          isSelected: _filter.availabilityType == 'both',
                          onSelected: (val) => setState(() => _filter = _filter.copyWith(availabilityType: 'both')),
                        ),
                        _ChoiceChip(
                          label: 'Full-time',
                          isSelected: _filter.availabilityType == 'full_time',
                          onSelected: (val) => setState(() => _filter = _filter.copyWith(availabilityType: 'full_time')),
                        ),
                        _ChoiceChip(
                          label: 'Part-time',
                          isSelected: _filter.availabilityType == 'part_time',
                          onSelected: (val) => setState(() => _filter = _filter.copyWith(availabilityType: 'part_time')),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 7. Verified Only
                    SwitchListTile(
                      title: Text('Verified Providers Only', style: AppTextStyles.bodyLarge),
                      value: _filter.verifiedOnly,
                      onChanged: (val) => setState(() => _filter = _filter.copyWith(verifiedOnly: val)),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SizedBox(height: 24.h),

                    // 8. Price Range
                    _SectionHeader(title: 'Max Price (PKR)'),
                    SizedBox(height: 12.h),
                    Slider(
                      value: _filter.maxPrice?.toDouble() ?? 100000.0,
                      min: 0,
                      max: 100000,
                      divisions: 100,
                      label: '${_filter.maxPrice ?? 100000}',
                      onChanged: (val) => setState(() => _filter = _filter.copyWith(maxPrice: val.toInt())),
                    ),
                    
                    SizedBox(height: 48.h),
                  ],
                ),
              ),
              
              // Bottom Buttons
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: AppButton.secondary(label: 'Clear All', onPressed: _clear)),
                    SizedBox(width: 16.w),
                    Expanded(child: AppButton(label: 'Apply Filters', onPressed: _apply)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.headlineSmall);
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.onBackground),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
    );
  }
}
