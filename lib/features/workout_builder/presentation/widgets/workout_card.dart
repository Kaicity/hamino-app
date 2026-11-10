import 'package:flutter/material.dart';

import '../../domain/entities/workout_template_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget thẻ hiển thị một giáo án trong danh sách Catalog
class WorkoutCard extends StatelessWidget {
  final WorkoutTemplateEntity workout;
  final VoidCallback? onStart;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onFavoriteToggle;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onStart,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onFavoriteToggle,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Xóa bài tập?',
          style: AppTypography.headlineSmall,
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${workout.name}" không? Hành động này không thể hoàn tác.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'HỦY',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'XÓA',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = workout.category.color;
    final borderColor = workout.isFavorite
        ? AppColors.starFavorite.withValues(alpha: 0.5)
        : AppColors.borderDark;
    final borderWidth = workout.isFavorite ? 1.5 : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: catColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(workout.category.icon, size: 13, color: catColor),
                      const SizedBox(width: 4),
                      Text(
                        workout.category.displayName.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // PRESET tag
                if (workout.isPreset) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PRESET',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Favorite star
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      workout.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: workout.isFavorite ? AppColors.starFavorite : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ),

                // Popup menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textMuted, size: 20),
                  color: AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                      case 'duplicate':
                        onDuplicate?.call();
                      case 'delete':
                        _confirmDelete(context);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 16, color: AppColors.textWhite),
                          const SizedBox(width: 10),
                          Text('Chỉnh sửa',
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          const Icon(Icons.copy_outlined, size: 16, color: AppColors.textWhite),
                          const SizedBox(width: 10),
                          Text('Nhân bản',
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              size: 16, color: AppColors.errorRed),
                          const SizedBox(width: 10),
                          Text('Xóa',
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.errorRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tên bài tập ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              workout.name,
              style: AppTypography.headlineMedium.copyWith(fontSize: 20),
            ),
          ),

          // ── Mô tả ───────────────────────────────────────────────────────────
          if (workout.description != null && workout.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(
                workout.description!,
                style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 12),

          // ── Thông số chips ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _metricChip(Icons.repeat_rounded, '${workout.targetRounds} Hiệp'),
                _metricChip(
                    Icons.timer_outlined,
                    workout.hasTimeCap ? 'Cap: ${workout.timeCapDisplay}' : 'Không giới hạn'),
                _metricChip(
                    Icons.fitness_center_outlined, '${workout.totalExercises} Động tác'),
                if (workout.totalRepsAllRounds > 0)
                  _metricChip(Icons.flash_on_rounded, 'Mục tiêu: ${workout.totalRepsAllRounds} reps'),
                if (workout.totalHoldSecondsAllRounds > 0)
                  _metricChip(Icons.hourglass_bottom_rounded, 'Giữ: ${workout.totalHoldTimeDisplay}'),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderDark),

          // ── Preview 3 động tác đầu ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...workout.exercises.take(3).map((ex) {
                  final isHold = ex.isStaticHold;
                  final badgeColor = isHold ? AppColors.restBlue : AppColors.workGreen;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${ex.orderIndex + 1}',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ex.name,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ex.targetSummary,
                            style: AppTypography.labelSmall.copyWith(
                              color: badgeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (workout.exercises.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '... và ${workout.exercises.length - 3} động tác khác',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),

          // ── Button BẮT ĐẦU TẬP ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: catColor,
                  foregroundColor: catColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'BẮT ĐẦU TẬP',
                  style: AppTypography.labelLarge.copyWith(
                    color: catColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
