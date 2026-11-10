import 'package:flutter/material.dart';

import '../../domain/entities/exercise_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'exercise_form_dialog.dart';

/// Widget hiển thị một dòng động tác trong ReorderableListView
class ExerciseListItem extends StatelessWidget {
  final ExerciseEntity exercise;
  final int index;
  final String workoutId;
  final VoidCallback onDelete;
  final void Function(ExerciseEntity updated) onUpdate;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.index,
    required this.workoutId,
    required this.onDelete,
    required this.onUpdate,
  });

  Future<void> _openEditDialog(BuildContext context) async {
    final result = await ExerciseFormDialog.show(
      context,
      exercise: exercise,
      workoutId: workoutId,
    );
    if (result != null) {
      onUpdate(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHold = exercise.isStaticHold;
    final badgeColor = isHold ? AppColors.restBlue : AppColors.workGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Icon(
                Icons.drag_handle_rounded,
                color: AppColors.textDisabled,
                size: 20,
              ),
            ),
          ),

          // Order index badge
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.borderDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${index + 1}',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Exercise name & notes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    exercise.notes!,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textDisabled),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Reps/Hold badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              exercise.targetSummary,
              style: AppTypography.labelSmall.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 2),

          // Edit button
          IconButton(
            onPressed: () => _openEditDialog(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.textMuted,
            tooltip: 'Chỉnh sửa động tác',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),

          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppColors.errorRed.withValues(alpha: 0.8),
            tooltip: 'Xóa động tác',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
