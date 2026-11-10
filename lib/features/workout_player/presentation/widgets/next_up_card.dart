import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/workout_builder/domain/entities/exercise_entity.dart';

/// Thẻ xem trước động tác kế tiếp (Next Up preview)
class NextUpCard extends StatelessWidget {
  final ExerciseEntity? nextExercise;
  final bool isLastStep;

  const NextUpCard({
    super.key,
    this.nextExercise,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLastStep) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.workOrange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.workOrange.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.workOrange,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'BÀI TẬP CUỐI CÙNG - CỐ LÊN!',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.workOrange,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (nextExercise == null) return const SizedBox.shrink();

    final isHold = nextExercise!.isStaticHold;
    final badgeColor = isHold ? AppColors.restBlue : AppColors.workGreen;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'TIẾP THEO',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nextExercise!.name,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              nextExercise!.targetSummary,
              style: AppTypography.labelSmall.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

