import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../features/workout_builder/domain/entities/workout_template_entity.dart';

/// Thanh tiến độ tổng thể mảnh trên cùng của màn hình tập luyện
class WorkoutProgressBar extends StatelessWidget {
  final WorkoutTemplateEntity workout;
  final int totalElapsedSeconds;
  final double progress;

  const WorkoutProgressBar({
    super.key,
    required this.workout,
    required this.totalElapsedSeconds,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress indicator bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: AppColors.borderDark,
            valueColor: AlwaysStoppedAnimation<Color>(workout.category.color),
          ),
        ),
        const SizedBox(height: 6),

        // Time and info row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Tổng: ${TimeFormatter.formatSeconds(totalElapsedSeconds)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (workout.hasTimeCap)
                Text(
                  'Cap: ${TimeFormatter.formatSeconds(workout.timeCapSeconds)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warningOrange,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                Text(
                  workout.category.displayName.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: workout.category.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

