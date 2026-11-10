import 'package:flutter/material.dart';

import '../../domain/entities/workout_category.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget thể thao hiển thị khi danh sách bài tập trống
class EmptyStateWidget extends StatelessWidget {
  final WorkoutCategory? selectedCategory;
  final VoidCallback? onCreateWorkout;
  final VoidCallback? onResetFilter;

  const EmptyStateWidget({
    super.key,
    this.selectedCategory,
    this.onCreateWorkout,
    this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    final hasCategoryFilter = selectedCategory != null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with neon border
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: (hasCategoryFilter
                          ? selectedCategory!.color
                          : AppColors.workGreen)
                      .withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                hasCategoryFilter
                    ? selectedCategory!.icon
                    : Icons.fitness_center_outlined,
                size: 44,
                color: hasCategoryFilter
                    ? selectedCategory!.color
                    : AppColors.workGreen,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              hasCategoryFilter
                  ? 'CHƯA CÓ BÀI TẬP ${selectedCategory!.displayName.toUpperCase()}'
                  : 'CHƯA CÓ BÀI TẬP',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 18,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              hasCategoryFilter
                  ? 'Chưa có giáo án nào thuộc thể loại ${selectedCategory!.displayName}.\nHãy tạo bài tập mới hoặc đặt lại bộ lọc.'
                  : 'Thư viện bài tập hiện đang trống.\nHãy tạo bài tập đầu tiên để bắt đầu luyện tập!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Create button
            if (onCreateWorkout != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCreateWorkout,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('TẠO BÀI TẬP MỚI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.workGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

            // Reset filter button
            if (hasCategoryFilter && onResetFilter != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onResetFilter,
                child: Text(
                  'Xem tất cả các thể loại',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.workGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

