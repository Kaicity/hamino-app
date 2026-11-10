import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/utils/time_formatter.dart';

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
      home: const HomeScreenPlaceholder(),
    );
  }
}

/// Màn hình khởi đầu giới thiệu và kiểm thử hệ thống Theme / Kiến trúc Phase 0
class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

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
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textWhite,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner chào mừng & Trạng thái Phase 0
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.surfaceElevated, AppColors.surfaceDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.workGreen.withValues(alpha: 0.3),
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
                          'PHASE 0 HOÀN TẤT',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.workGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kiến trúc Nền tảng & Theme Thể thao Sẵn sàng',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Feature-First Clean Architecture, Dark High-Contrast Theme, Service Locator (GetIt) đã được tích hợp.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preview Typography Timer
              Text(
                'PREVIEW TYPOGRAPHY (TIMER DRIFT-PROOF)',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  children: [
                    Text(
                      TimeFormatter.formatSeconds(120),
                      style: AppTypography.timerBigDisplay.copyWith(
                        color: AppColors.workGreen,
                      ),
                    ),
                    Text(
                      'HIỆP 1/5 • WORK (45S)',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Thể loại Calisthenics Badges
              Text(
                'PHÂN LOẠI CALISTHENICS (CATEGORIES)',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _CategoryChip(label: 'EMOM', color: AppColors.catEmom),
                  _CategoryChip(
                    label: 'ENDURANCE',
                    color: AppColors.catEndurance,
                  ),
                  _CategoryChip(label: 'SKILL', color: AppColors.catSkill),
                  _CategoryChip(label: 'CARDIO', color: AppColors.catCardio),
                ],
              ),
              const SizedBox(height: 24),

              // Trạng thái Timer Colors
              Text(
                'HỆ THỐNG MÀU TRẠNG THÁI (COLOR TOKENS)',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _ColorStatusCard(
                      label: 'PREPARE',
                      time: '00:10',
                      color: AppColors.prepareYellow,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _ColorStatusCard(
                      label: 'WORK',
                      time: '00:45',
                      color: AppColors.workGreen,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _ColorStatusCard(
                      label: 'REST',
                      time: '01:00',
                      color: AppColors.restBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Nút hành động sẵn sàng cho Phase 1
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.fitness_center),
                  label: const Text(
                    'SẴN SÀNG TRIỂN KHAI PHASE 1: DATABASE & PRESETS',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ColorStatusCard extends StatelessWidget {
  final String label;
  final String time;
  final Color color;

  const _ColorStatusCard({
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
