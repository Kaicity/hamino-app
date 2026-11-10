import 'package:get_it/get_it.dart';

/// Service Locator toàn cục của ứng dụng
final sl = GetIt.instance;

/// Khởi tạo và đăng ký tất cả các dependencies trong ứng dụng theo Clean Architecture
Future<void> initDependencies() async {
  // 1. Core Services & External Drivers
  await _initCore();

  // 2. Feature: Workout Builder & Library
  await _initWorkoutBuilder();

  // 3. Feature: Workout Player & Timer Engine
  await _initWorkoutPlayer();

  // 4. Feature: History & Workout Log
  await _initHistory();

  // 5. Feature: App Settings & Audio Config
  await _initSettings();
}

/// Đăng ký các dịch vụ Core dùng chung
Future<void> _initCore() async {
  // Sẽ được bổ sung tại Phase 1 & 4 (DatabaseHelper, AudioCueManager, WakelockService, NotificationService)
}

/// Đăng ký dependencies cho tính năng Workout Builder (CRUD giáo án)
Future<void> _initWorkoutBuilder() async {
  // Sẽ được bổ sung tại Phase 1 & 2 (WorkoutRepository, UseCases, WorkoutCatalogBloc, WorkoutBuilderBloc)
}

/// Đăng ký dependencies cho tính năng Workout Player (Đồng hồ đếm giờ & Trạng thái tập)
Future<void> _initWorkoutPlayer() async {
  // Sẽ được bổ sung tại Phase 3 (PrecisionTicker, WorkoutPlayerBloc)
}

/// Đăng ký dependencies cho tính năng History (Lịch sử buổi tập)
Future<void> _initHistory() async {
  // Sẽ được bổ sung tại Phase 5 (HistoryRepository, HistoryBloc)
}

/// Đăng ký dependencies cho tính năng Settings (Cài đặt)
Future<void> _initSettings() async {
  // Sẽ được bổ sung tại Phase 6 (SettingsBloc)
}

