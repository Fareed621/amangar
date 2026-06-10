import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../providers/profile_provider.dart';

class PortfolioManageScreen extends ConsumerWidget {
  const PortfolioManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).valueOrNull?.uid ?? '';
    final profileAsync = ref.watch(providerDetailProvider(uid));
    final profileState = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);

    final photos = profileAsync.valueOrNull?.profile?.portfolioPhotos ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Portfolio Photos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Upload button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppButton(
              label: profileState.isUpdating ? 'Uploading...' : 'Add Photo',
              onPressed: profileState.isUpdating
                  ? null
                  : () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                      if (picked != null) {
                        await notifier.uploadPortfolioPhoto(File(picked.path));
                        ref.invalidate(providerDetailProvider(uid));
                      }
                    },
            ),
          ),

          if (profileState.isUpdating)
            const LinearProgressIndicator(color: AppColors.primary),

          if (profileState.error != null)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                profileState.error!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),

          // Grid
          Expanded(
            child: profileAsync.when(
              data: (_) {
                if (photos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 64.w, color: AppColors.textDisabled),
                        SizedBox(height: 12.h),
                        Text('No portfolio photos yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        SizedBox(height: 8.h),
                        Text('Add photos to showcase your work', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.w,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (ctx, i) => _PhotoTile(
                    url: photos[i],
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: ctx,
                        builder: (d) => AlertDialog(
                          title: const Text('Delete Photo'),
                          content: const Text('Remove this photo from your portfolio?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(d, true),
                              child: Text('Delete', style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await notifier.removePortfolioPhoto(photos[i]);
                        ref.invalidate(providerDetailProvider(uid));
                      }
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.url, required this.onDelete});
  final String url;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.85), shape: BoxShape.circle),
              child: Icon(Icons.close, size: 12.w, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
