import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/exercise_entity.dart';

/// Thẻ hiển thị tổng kết khối lượng và mục tiêu của bài tập
/// Tính toán tổng số rep và tổng số giây giữ (quy đổi ra phút) trên toàn bộ số hiệp
class WorkoutTargetSummaryCard extends StatelessWidget {
  final List<ExerciseEntity> exercises;
  final int targetRounds;

  const WorkoutTargetSummaryCard({
    super.key,
    required this.exercises,
    required this.targetRounds,
  });

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
  /// Ví dụ: 60s -> "1 phút", 150s -> "2 phút 30 giây", 45s -> "45 giây"
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
                'Thêm động tác để xem tổng số rep và thời gian giữ mục tiêu.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hasReps = totalRepsAllRounds > 0;
    final hasHold = totalHoldSecondsAllRounds > 0;

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
                  Icons.insights_rounded,
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
                      'MỤC TIÊU TOÀN BUỔI TẬP',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Tổng khối lượng qua $targetRounds hiệp tập',
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

          // ── Metric Tiles ──────────────────────────────────────────────────
          Row(
            children: [
              // Cột 1: Tổng số Reps
              if (hasReps)
                Expanded(
                  child: _metricTile(
                    title: 'TỔNG SỐ REPS',
                    value: '$totalRepsAllRounds',
                    unit: 'reps',
                    subtitle:
                        '$totalRepsPerRound reps/hiệp × $targetRounds hiệp',
                    color: AppColors.workGreen,
                    icon: Icons.repeat_rounded,
                  ),
                ),

              if (hasReps && hasHold)
                Container(
                  width: 1,
                  height: 54,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: AppColors.borderDark,
                ),

              // Cột 2: Tổng thời gian giữ
              if (hasHold)
                Expanded(
                  child: _metricTile(
                    title: 'TỔNG THỜI GIAN GIỮ',
                    value: formattedHoldTime,
                    unit: '',
                    subtitle:
                        '${totalHoldSecondsPerRound}s/hiệp × $targetRounds hiệp',
                    color: AppColors.restBlue,
                    icon: Icons.timer_outlined,
                  ),
                ),

              // Nếu chỉ có 1 trong 2 hoặc không có cả 2
              if (!hasHold && !hasReps)
                Expanded(
                  child: Text(
                    'Chưa có dữ liệu số rep hoặc giây giữ',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                value,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

