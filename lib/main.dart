import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'features/workout_builder/domain/entities/workout_category.dart';
import 'features/workout_builder/domain/entities/workout_template_entity.dart';
import 'features/workout_builder/domain/repositories/workout_repository.dart';
import 'features/workout_builder/presentation/pages/workout_catalog_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khóa hướng màn hình dọc làm chuẩn cho bài tập
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Cấu hình thanh trạng thái hệ thống trong suốt trên nền tối
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Khởi tạo Dependency Injection (Service Locator)
  await initDependencies();

  runApp(const HaminoApp());
}

/// Root widget của ứng dụng Hamino Workout
class HaminoApp extends StatelessWidget {
  const HaminoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WorkoutCatalogPage(),
    );
  }
}

/// Màn hình chính tích hợp kiểm thử trực quan Phase 1: Local DB & Thư viện Presets
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WorkoutRepository _workoutRepository;
  WorkoutCategory? _selectedCategory;
  List<WorkoutTemplateEntity> _workouts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _workoutRepository = sl<WorkoutRepository>();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = _selectedCategory == null
          ? await _workoutRepository.getAllWorkouts()
          : await _workoutRepository.getWorkoutsByCategory(_selectedCategory!);

      if (mounted) {
        setState(() {
          _workouts = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(WorkoutTemplateEntity workout) async {
    final nextFavorite = !workout.isFavorite;
    await _workoutRepository.toggleFavorite(workout.id, nextFavorite);
    await _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            icon: const Icon(Icons.refresh, color: AppColors.textWhite),
            tooltip: 'Tải lại bài tập',
            onPressed: _loadWorkouts,
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textWhite,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWorkouts,
          color: AppColors.workGreen,
          backgroundColor: AppColors.surfaceElevated,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner chào mừng & Trạng thái Phase 1
                      _buildPhase1Banner(),
                      const SizedBox(height: 24),

                      // Filter chips theo thể loại Calisthenics
                      _buildCategoryFilters(),
                      const SizedBox(height: 20),

                      // Tiêu đề danh sách giáo án
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GIÁO ÁN CALISTHENICS (${_workouts.length})',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedCategory != null)
                            GestureDetector(
                              onTap: () {
                                setState(() => _selectedCategory = null);
                                _loadWorkouts();
                              },
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
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Danh sách bài tập từ SQLite
              _buildWorkoutList(),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhase1Banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceElevated, AppColors.surfaceDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.workGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.workGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'PHASE 1 HOÀN TẤT',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.workGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'SQLite Database & 4 Preset Calisthenics Chuẩn Sẵn Sàng',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Cơ sở dữ liệu offline 100% (Foreign Keys Cascade, Repositories). Nạp sẵn EMOM 20m, Endurance 30m, Skill Handstand, Tabata Burpees.',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Column(
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
                isSelected: _selectedCategory == null,
                color: AppColors.workGreen,
                onTap: () {
                  setState(() => _selectedCategory = null);
                  _loadWorkouts();
                },
              ),
              const SizedBox(width: 8),
              ...WorkoutCategory.values.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCategoryChip(
                    label: cat.displayName.toUpperCase(),
                    isSelected: _selectedCategory == cat,
                    color: cat.color,
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _loadWorkouts();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          color: isSelected ? color.withValues(alpha: 0.25) : AppColors.surfaceElevated,
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

  Widget _buildWorkoutList() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.workGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.errorRed),
            ),
          ),
        ),
      );
    }

    if (_workouts.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Chưa có bài tập nào trong mục này',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final workout = _workouts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _WorkoutPresetCard(
                workout: workout,
                onFavoriteToggle: () => _toggleFavorite(workout),
              ),
            );
          },
          childCount: _workouts.length,
        ),
      ),
    );
  }
}

/// Thẻ hiển thị giáo án Calisthenics từ Database
class _WorkoutPresetCard extends StatelessWidget {
  final WorkoutTemplateEntity workout;
  final VoidCallback onFavoriteToggle;

  const _WorkoutPresetCard({
    required this.workout,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = workout.category.color;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: workout.isFavorite
              ? AppColors.starFavorite.withValues(alpha: 0.4)
              : AppColors.borderDark,
          width: workout.isFavorite ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Badge + Preset Tag + Favorite Star
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: catColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(workout.category.icon, size: 14, color: catColor),
                      const SizedBox(width: 4),
                      Text(
                        workout.category.displayName.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (workout.isPreset) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PRESET',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: Icon(
                    workout.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: workout.isFavorite ? AppColors.starFavorite : AppColors.textMuted,
                    size: 24,
                  ),
                  onPressed: onFavoriteToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: workout.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
                ),
              ],
            ),
          ),

          // Tên bài tập
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              workout.name,
              style: AppTypography.headlineMedium.copyWith(fontSize: 20),
            ),
          ),

          // Mô tả ngắn
          if (workout.description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(
                workout.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 12),

          // Thông số tóm tắt: Rounds, Time Cap, Exercises count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _buildMetric(Icons.repeat, '${workout.targetRounds} Hiệp'),
                _buildMetric(Icons.timer_outlined, workout.timeCapDisplay),
                _buildMetric(Icons.fitness_center_outlined, '${workout.totalExercises} Động tác'),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderDark),

          // Danh sách các động tác con
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...workout.exercises.map(
                  (ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${ex.orderIndex + 1}',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ex.name,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ex.isStaticHold
                                ? AppColors.restBlue.withValues(alpha: 0.15)
                                : AppColors.workGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ex.targetSummary,
                            style: AppTypography.labelSmall.copyWith(
                              color: ex.isStaticHold ? AppColors.restBlue : AppColors.workGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
