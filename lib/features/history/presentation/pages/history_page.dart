import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/workout_session_record.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/history_session_card.dart';
import '../widgets/session_detail_modal.dart';

/// Màn hình lịch sử và thống kê tập luyện (History & Stats Screen)
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryBloc>()..add(const LoadHistoryEvent()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  void _confirmDelete(
    BuildContext context,
    WorkoutSessionRecord session,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xóa buổi tập?', style: AppTypography.headlineSmall),
        content: Text(
          'Bạn có chắc muốn xóa bản ghi buổi tập "${session.workoutName}" không? Dữ liệu này không thể khôi phục.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'HỦY',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<HistoryBloc>().add(DeleteSessionEvent(session.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa buổi tập khỏi lịch sử'),
                  backgroundColor: AppColors.surfaceElevated,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
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
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xóa toàn bộ lịch sử?', style: AppTypography.headlineSmall),
        content: Text(
          'Tất cả các bản ghi buổi tập đã hoàn thành sẽ bị xóa vĩnh viễn khỏi thiết bị.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'HỦY',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<HistoryBloc>().add(const ClearHistoryEvent());
            },
            child: Text(
              'XÓA HẾT',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'LỊCH SỬ TẬP LUYỆN',
          style: AppTypography.headlineMedium.copyWith(fontSize: 18),
        ),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state is HistoryLoaded && state.sessions.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded,
                      color: AppColors.textMuted),
                  tooltip: 'Xóa tất cả',
                  onPressed: () => _confirmClearAll(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.workGreen),
              );
            }

            if (state is HistoryError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: AppColors.errorRed),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<HistoryBloc>()
                            .add(const LoadHistoryEvent()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.workGreen,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is HistoryLoaded) {
              return CustomScrollView(
                slivers: [
                  // ── Thống kê nhanh trên đầu trang ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          _buildStatCard(
                            title: 'TUẦN NÀY',
                            value: '${state.workoutsThisWeekCount}',
                            unit: 'buổi tập',
                            icon: Icons.calendar_view_week_rounded,
                            color: AppColors.workGreen,
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            title: 'VẬN ĐỘNG TUẦN',
                            value: '${state.minutesThisWeek}',
                            unit: 'phút',
                            icon: Icons.timer_outlined,
                            color: AppColors.catEndurance,
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            title: 'TỔNG CỘNG',
                            value: '${state.totalSessions}',
                            unit: 'buổi',
                            icon: Icons.fitness_center_rounded,
                            color: AppColors.prepareYellow,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Title Danh sách ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TIMELINE BUỔI TẬP',
                            style: AppTypography.labelLarge.copyWith(
                              letterSpacing: 1.0,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '${state.sessions.length} bản ghi',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Empty State hoặc List các buổi tập ──
                  if (state.sessions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(context),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final session = state.sessions[index];
                            return HistorySessionCard(
                              session: session,
                              onTap: () {
                                SessionDetailModal.show(
                                  context,
                                  session: session,
                                  onDelete: () =>
                                      _confirmDelete(context, session),
                                );
                              },
                              onDelete: () => _confirmDelete(context, session),
                            );
                          },
                          childCount: state.sessions.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.headlineLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textWhite,
              ),
            ),
            Text(
              unit,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_toggle_off_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'CHƯA CÓ LỊCH SỬ TẬP',
              style: AppTypography.headlineMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Hãy bắt đầu buổi tập đầu tiên của bạn. Mọi kết quả và ghi chú sẽ được lưu trữ tự động tại đây.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

