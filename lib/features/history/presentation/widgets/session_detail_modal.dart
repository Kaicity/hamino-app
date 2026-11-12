import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../domain/entities/workout_session_record.dart';

/// BottomSheet hoặc Modal hiển thị chi tiết buổi tập đã hoàn thành
class SessionDetailModal extends StatelessWidget {
  final WorkoutSessionRecord session;
  final VoidCallback onDelete;

  const SessionDetailModal({
    super.key,
    required this.session,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required WorkoutSessionRecord session,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SessionDetailModal(
        session: session,
        onDelete: onDelete,
      ),
    );
  }

  Color _getRpeColor(int? score) {
    if (score == null) return AppColors.textMuted;
    if (score <= 2) return const Color(0xFF00E5FF);
    if (score <= 4) return AppColors.workGreen;
    if (score <= 6) return AppColors.prepareYellow;
    if (score <= 8) return AppColors.warningOrange;
    return AppColors.errorRed;
  }

  String _getRpeDescription(int? score) {
    if (score == null) return 'Không đánh giá';
    switch (score) {
      case 1:
      case 2:
        return 'Rất nhẹ - Khởi động';
      case 3:
      case 4:
        return 'Nhẹ - Vận động thoải mái';
      case 5:
      case 6:
        return 'Vừa phải - Thở sâu, toát mồ hôi';
      case 7:
      case 8:
        return 'Nặng - Thở dốc, cơ bắp căng mỏi';
      case 9:
      case 10:
        return 'Cực đại - 100% nỗ lực';
      default:
        return 'Mức $score / 10';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd/MM/yyyy • HH:mm').format(session.startedAt);

    final rpeColor = _getRpeColor(session.rpeScore);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.workoutName,
                  style: AppTypography.headlineMedium.copyWith(fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          Text(
            formattedDate,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),

          const SizedBox(height: 20),

          // Detail grid: Duration, Rounds, RPE
          Row(
            children: [
              _buildDetailItem(
                title: 'THỜI LƯỢNG',
                value: TimeFormatter.formatSeconds(session.durationSeconds),
                icon: Icons.timer_outlined,
                color: AppColors.workGreen,
              ),
              const SizedBox(width: 12),
              _buildDetailItem(
                title: 'SỐ HIỆP',
                value: '${session.completedRounds} hiệp',
                icon: Icons.repeat_rounded,
                color: AppColors.prepareYellow,
              ),
              const SizedBox(width: 12),
              _buildDetailItem(
                title: 'ĐÁNH GIÁ RPE',
                value: session.rpeScore != null
                    ? 'RPE ${session.rpeScore}'
                    : 'N/A',
                icon: Icons.speed_rounded,
                color: rpeColor,
                subtitle: _getRpeDescription(session.rpeScore),
              ),
            ],
          ),

          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'NHẬT KÝ & CẢM NHẬN',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Text(
                session.notes!,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Delete button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.errorRed, size: 20),
            label: Text(
              'XÓA BẢN GHI NÀY',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.errorRed),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontSize: 8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

