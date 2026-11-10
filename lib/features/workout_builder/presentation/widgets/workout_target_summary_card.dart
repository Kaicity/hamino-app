import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/exercise_target_volume.dart';

/// Thẻ hiển thị chi tiết khối lượng mục tiêu cho từng động tác
/// Thay vì cộng dồn chung các bài tập khác nhau thành 1 số reps tổng thể,
/// thẻ này liệt kê chi tiết từng động tác đạt được bao nhiêu rep hoặc bao nhiêu phút giữ:
/// Ví dụ:
/// - Push up: = 50 rep (10 rep/hiệp × 5 hiệp)
/// - Pull ups: = 100 rep (20 rep/hiệp × 5 hiệp)
/// - Plank: = 10 phút (120s/hiệp × 5 hiệp)
/// - Swat hold: = 5 phút (60s/hiệp × 5 hiệp)
class WorkoutTargetSummaryCard extends StatelessWidget {
  final List<ExerciseEntity> exercises;
  final int targetRounds;

  const WorkoutTargetSummaryCard({
    super.key,
    required this.exercises,
    required this.targetRounds,
  });

  /// Danh sách chi tiết mục tiêu của từng động tác
  List<ExerciseTargetVolume> get targetVolumes =>
      ExerciseTargetVolume.fromExercises(
        exercises: exercises,
        targetRounds: targetRounds,
      );

  /// Tổng số rep trong 1 hiệp
  int get totalRepsPerRound =>
      exercises.fold(0, (sum, ex) => sum + ex.defaultReps);

  /// Tổng số rep qua tất cả các hiệp
  int get totalRepsAllRounds => totalRepsPerRound * targetRounds;

  /// Tổng số giây giữ trong 1 hiệp
  int get totalHoldSecondsPerRound =>
      exercises.fold(0, (sum, ex) => sum + ex.holdSeconds);

  /// Tổng số giây giữ qua tất cả các hiệp
  int get totalHoldSecondsAllRounds =>
      totalHoldSecondsPerRound * targetRounds;

  /// Quy đổi tổng số giây giữ thành chuỗi phút / giây dễ hiểu
  String get formattedHoldTime {
    final totalSec = totalHoldSecondsAllRounds;
    if (totalSec <= 0) return '0 giây';
    if (totalSec < 60) return '$totalSec giây';

    final minutes = totalSec ~/ 60;
    final seconds = totalSec % 60;

    if (seconds == 0) {
      return '$minutes phút';
    }
    return '$minutes phút $seconds giây';
  }

  /// Tổng số set (lượt tập) của toàn bộ bài
  int get totalSets => exercises.length * targetRounds;

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textDisabled,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Thêm động tác để xem chi tiết số rep và thời gian giữ mục tiêu từng động tác.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final targets = targetVolumes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.workGreen.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.workGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sports_score_rounded,
                  color: AppColors.workGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MỤC TIÊU TỪNG ĐỘNG TÁC',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Kết quả đạt được qua $targetRounds hiệp tập',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Text(
                  '$totalSets SETS',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderDark),
          const SizedBox(height: 14),

          // ── Danh sách chi tiết mục tiêu từng động tác ──────────────────────
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: targets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final target = targets[index];
              final isHold = target.isStaticHold;
              final accentColor =
                  isHold ? AppColors.restBlue : AppColors.workGreen;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon đại diện
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isHold
                            ? Icons.timer_outlined
                            : Icons.fitness_center_rounded,
                        color: accentColor,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tên động tác và công thức tính
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            target.exerciseName,
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            target.calculationFormula,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Kết quả mục tiêu nổi bật: vd "= 50 rep", "= 10 phút"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        target.targetDisplay,
                        style: AppTypography.labelLarge.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
