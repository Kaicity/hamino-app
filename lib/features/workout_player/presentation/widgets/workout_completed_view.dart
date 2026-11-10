import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../bloc/workout_player_state.dart';

/// Màn hình tổng kết khi hoàn thành buổi tập
class WorkoutCompletedView extends StatelessWidget {
  final PlayerCompleted state;
  final VoidCallback onFinish;

  const WorkoutCompletedView({
    super.key,
    required this.state,
    required this.onFinish,
  });

  String _reasonText(CompletionReason reason) {
    switch (reason) {
      case CompletionReason.allRoundsFinished:
        return 'Hoàn thành tất cả các hiệp';
      case CompletionReason.timeCapReached:
        return 'Đã chạm giới hạn thời gian (Time Cap)';
      case CompletionReason.finishedEarly:
        return 'Kết thúc sớm buổi tập';
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = state.workout;
    final catColor = workout?.category.color ?? AppColors.workGreen;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Trophy Icon
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: catColor.withValues(alpha: 0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: catColor.withValues(alpha: 0.25),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 58,
                color: catColor,
              ),
            ),
            const SizedBox(height: 24),

            // Victory Title
            Text(
              'XUẤT SẮC!',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.textWhite,
                fontSize: 34,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              workout?.name ?? 'Buổi tập Calisthenics',
              style: AppTypography.headlineMedium.copyWith(
                color: catColor,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _reasonText(state.reason),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Metric cards
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  // Duration
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: AppColors.textMuted,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          TimeFormatter.formatSeconds(state.totalElapsedSeconds),
                          style: AppTypography.headlineLarge.copyWith(
                            fontSize: 28,
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'TỔNG THỜI GIAN',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 50,
                    color: AppColors.borderDark,
                  ),

                  // Rounds completed
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.repeat_rounded,
                          color: AppColors.textMuted,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${state.completedRounds} / ${state.totalRounds}',
                          style: AppTypography.headlineLarge.copyWith(
                            fontSize: 28,
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'HIỆP HOÀN THÀNH',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Button finish & exit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: catColor,
                  foregroundColor:
                      catColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'HOÀN TẤT & VỀ TRANG CHỦ',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

