import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/workout_catalog_bloc.dart';
import '../../domain/entities/workout_category.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/workout_card.dart';
import '../../../../features/workout_player/presentation/pages/workout_player_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import 'workout_builder_page.dart';

/// Màn hình danh sách bài tập - màn hình chính của ứng dụng
class WorkoutCatalogPage extends StatelessWidget {
  const WorkoutCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutCatalogBloc>()..add(const LoadCatalogEvent()),
      child: const _WorkoutCatalogView(),
    );
  }
}

class _WorkoutCatalogView extends StatelessWidget {
  const _WorkoutCatalogView();

  void _navigateToBuilder(BuildContext context,
      {required bool isNew, String? workoutId}) async {
    final bloc = context.read<WorkoutCatalogBloc>();

    if (isNew) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const WorkoutBuilderPage()),
      );
      if (result == true) {
        bloc.add(const LoadCatalogEvent());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lưu bài tập thành công!',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } else {
      final state = bloc.state;
      final workout =
          state.allWorkouts.where((w) => w.id == workoutId).firstOrNull;
      if (workout == null) return;

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => WorkoutBuilderPage(workout: workout)),
      );
      if (result == true) {
        bloc.add(const LoadCatalogEvent());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cập nhật bài tập thành công!',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocBuilder<WorkoutCatalogBloc, WorkoutCatalogState>(
          builder: (context, state) {
            final bloc = context.read<WorkoutCatalogBloc>();

            return CustomScrollView(
              slivers: [
                // ── AppBar ───────────────────────────────────────────────
                SliverAppBar(
                  backgroundColor: AppColors.bgDark,
                  pinned: true,
                  elevation: 0,
                  title: Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.workGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'HAMINO',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('WORKOUT', style: AppTypography.headlineMedium),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.history_rounded,
                          color: AppColors.textWhite),
                      tooltip: 'Lịch sử',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: AppColors.textWhite),
                      tooltip: 'Cài đặt',
                      onPressed: () {},
                    ),
                  ],
                ),

                // ── Title section ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THƯ VIỆN BÀI TẬP',
                          style: AppTypography.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chọn bài tập Calisthenics phù hợp với bạn',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Category filter chips ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LỌC THEO THỂ LOẠI',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCategoryChip(
                                label: 'TẤT CẢ',
                                isSelected: state.selectedCategory == null,
                                color: AppColors.workGreen,
                                onTap: () =>
                                    bloc.add(const FilterByCategoryEvent(null)),
                              ),
                              const SizedBox(width: 8),
                              ...WorkoutCategory.values.map((cat) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildCategoryChip(
                                      label: cat.displayName.toUpperCase(),
                                      isSelected:
                                          state.selectedCategory == cat,
                                      color: cat.color,
                                      onTap: () =>
                                          bloc.add(FilterByCategoryEvent(cat)),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Count row ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.filteredWorkouts.length} BÀI TẬP',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.selectedCategory != null)
                          GestureDetector(
                            onTap: () =>
                                bloc.add(const FilterByCategoryEvent(null)),
                            child: Text(
                              'Xem tất cả',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.workGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Workout list / states ─────────────────────────────────
                if (state is CatalogLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.workGreen),
                    ),
                  )
                else if (state is CatalogError)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.errorRed, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              state.errorMessage ?? 'Đã xảy ra lỗi',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.errorRed),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () =>
                                  bloc.add(const LoadCatalogEvent()),
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: AppColors.workGreen),
                              ),
                              child: Text('Thử lại',
                                  style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.workGreen)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (state.filteredWorkouts.isEmpty)
                  SliverFillRemaining(
                    child: EmptyStateWidget(
                      selectedCategory: state.selectedCategory,
                      onCreateWorkout: () =>
                          _navigateToBuilder(context, isNew: true),
                      onResetFilter: () =>
                          bloc.add(const FilterByCategoryEvent(null)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final workout = state.filteredWorkouts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: WorkoutCard(
                              workout: workout,
                              onStart: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WorkoutPlayerPage(workout: workout),
                                  ),
                                );
                              },
                              onEdit: () => _navigateToBuilder(ctx,
                                  isNew: false, workoutId: workout.id),
                              onDelete: () =>
                                  bloc.add(DeleteWorkoutEvent(workout.id)),
                              onDuplicate: () =>
                                  bloc.add(DuplicateWorkoutEvent(workout.id)),
                              onFavoriteToggle: () => bloc.add(
                                ToggleFavoriteEvent(
                                    workout.id, !workout.isFavorite),
                              ),
                            ),
                          );
                        },
                        childCount: state.filteredWorkouts.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToBuilder(context, isNew: true),
        backgroundColor: AppColors.workGreen,
        foregroundColor: Colors.black,
        tooltip: 'Tạo bài tập mới',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.borderDark,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? color : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
