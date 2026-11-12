import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../workout_builder/domain/entities/workout_template_entity.dart';
import '../../../workout_player/presentation/bloc/workout_player_state.dart';
import '../../domain/entities/workout_session_record.dart';
import '../../domain/repositories/history_repository.dart';

/// Màn hình tổng kết buổi tập (Workout Summary Screen)
/// Cho phép người dùng đánh giá RPE, viết ghi chú và lưu lại vào nhật ký SQLite
class WorkoutSummaryPage extends StatefulWidget {
  final WorkoutTemplateEntity? workout;
  final int totalElapsedSeconds;
  final int completedRounds;
  final int totalRounds;
  final CompletionReason reason;
  final DateTime startedAt;
  final DateTime finishedAt;

  const WorkoutSummaryPage({
    super.key,
    required this.workout,
    required this.totalElapsedSeconds,
    required this.completedRounds,
    required this.totalRounds,
    required this.reason,
    required this.startedAt,
    required this.finishedAt,
  });

  @override
  State<WorkoutSummaryPage> createState() => _WorkoutSummaryPageState();
}

class _WorkoutSummaryPageState extends State<WorkoutSummaryPage> {
  late final TextEditingController _notesController;
  int _rpeScore = 7; // Mặc định RPE 7 (Nỗ lực tốt)
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getRpeLabel(int score) {
    switch (score) {
      case 1:
      case 2:
        return 'Rất nhẹ (Khởi động, hầu như không mệt)';
      case 3:
      case 4:
        return 'Nhẹ (Thở đều, tập luyện nhẹ nhàng)';
      case 5:
      case 6:
        return 'Vừa phải (Bắt đầu toát mồ hôi, thở sâu)';
      case 7:
      case 8:
        return 'Nặng (Thở dốc, cơ bắp căng mỏi nhiều, rất tốt!)';
      case 9:
        return 'Rất nặng (Gần chạm ngưỡng thất bại cơ)';
      case 10:
        return 'Cực đại (100% sức lực, không thể thêm rep nào)';
      default:
        return '';
    }
  }

  Color _getRpeColor(int score) {
    if (score <= 2) return const Color(0xFF00E5FF);
    if (score <= 4) return AppColors.workGreen;
    if (score <= 6) return AppColors.prepareYellow;
    if (score <= 8) return AppColors.warningOrange;
    return AppColors.errorRed;
  }

  String _formatDurationVietnamese(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes == 0) return '$seconds giây';
    if (seconds == 0) return '$minutes phút';
    return '$minutes phút $seconds giây';
  }

  String _getReasonDescription(CompletionReason reason) {
    switch (reason) {
      case CompletionReason.allRoundsFinished:
        return 'Đạt mục tiêu 100% tất cả các hiệp';
      case CompletionReason.timeCapReached:
        return 'Chạm mốc thời gian giới hạn (Time Cap)';
      case CompletionReason.finishedEarly:
        return 'Dừng buổi tập sớm';
    }
  }

  Future<void> _saveSession() async {
    setState(() => _isSaving = true);
    try {
      final repository = sl<HistoryRepository>();
      final record = WorkoutSessionRecord(
        id: const Uuid().v4(),
        workoutId: widget.workout?.id ?? 'custom_workout',
        workoutName: widget.workout?.name ?? 'Buổi tập Calisthenics',
        startedAt: widget.startedAt,
        finishedAt: widget.finishedAt,
        durationSeconds: widget.totalElapsedSeconds,
        completedRounds: widget.completedRounds,
        rpeScore: _rpeScore,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await repository.saveSession(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đã ghi nhận buổi tập vào Lịch sử!',
                    style:
                        AppTypography.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Quay về trang chủ
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu kết quả: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = widget.workout?.category.color ?? AppColors.workGreen;
    final rpeColor = _getRpeColor(_rpeScore);
    final percentage = widget.totalRounds > 0
        ? ((widget.completedRounds / widget.totalRounds) * 100).round()
        : 100;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textWhite),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          title: Text(
            'TỔNG KẾT BUỔI TẬP',
            style: AppTypography.headlineMedium.copyWith(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Trophy Icon & Workout Title ──
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: catColor.withValues(alpha: 0.7),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: catColor.withValues(alpha: 0.25),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          size: 44,
                          color: catColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'XUẤT SẮC!',
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.workout?.name ?? 'Buổi tập Calisthenics',
                        style: AppTypography.headlineMedium.copyWith(
                          color: catColor,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getReasonDescription(widget.reason),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Highlight Metrics Cards ──
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
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
                              Icons.timer_rounded,
                              color: AppColors.workGreen,
                              size: 26,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              TimeFormatter.formatSeconds(
                                  widget.totalElapsedSeconds),
                              style: AppTypography.headlineLarge.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDurationVietnamese(
                                  widget.totalElapsedSeconds),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 50,
                        color: AppColors.borderDark,
                      ),

                      // Completed Rounds
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.catEndurance,
                              size: 26,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.completedRounds}/${widget.totalRounds}',
                              style: AppTypography.headlineLarge.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$percentage% HIỆP MỤC TIÊU',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── RPE Scale Section (1-10) ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ĐÁNH GIÁ ĐỘ KHÓ (RPE)',
                            style: AppTypography.labelLarge.copyWith(
                              letterSpacing: 1.0,
                              color: AppColors.textWhite,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: rpeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: rpeColor, width: 1.5),
                            ),
                            child: Text(
                              'RPE $_rpeScore / 10',
                              style: AppTypography.labelLarge.copyWith(
                                color: rpeColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getRpeLabel(_rpeScore),
                        style: AppTypography.bodySmall.copyWith(
                          color: rpeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Slider RPE
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: rpeColor,
                          inactiveTrackColor: AppColors.surfaceElevated,
                          thumbColor: rpeColor,
                          overlayColor: rpeColor.withValues(alpha: 0.2),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                        ),
                        child: Slider(
                          value: _rpeScore.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (val) {
                            setState(() => _rpeScore = val.round());
                          },
                        ),
                      ),

                      // Quick select chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(10, (index) {
                            final score = index + 1;
                            final isSelected = _rpeScore == score;
                            final color = _getRpeColor(score);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _rpeScore = score),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color
                                        : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : AppColors.borderDark,
                                    ),
                                  ),
                                  child: Text(
                                    '$score',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isSelected
                                          ? Colors.black
                                          : AppColors.textWhite,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Personal Notes Section ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NHẬT KÝ & CẢM NHẬN',
                        style: AppTypography.labelLarge.copyWith(
                          letterSpacing: 1.0,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText:
                              'Ghi chú cảm giác cơ bắp, mức tạ, số rep tối đa đạt được...',
                          hintStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted.withValues(alpha: 0.7),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.borderDark),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.borderDark),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.workGreen),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Save Result Button ──
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.workGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'LƯU KẾT QUẢ BUỔI TẬP',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Skip without saving ──
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Text(
                    'Bỏ qua không lưu',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

