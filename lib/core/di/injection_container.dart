import 'package:get_it/get_it.dart';

import '../database/database_helper.dart';
import '../../features/workout_builder/data/repositories/workout_repository_impl.dart';
import '../../features/workout_builder/domain/repositories/workout_repository.dart';
import '../../features/workout_builder/presentation/bloc/workout_catalog_bloc.dart';
import '../../features/workout_builder/presentation/bloc/workout_builder_bloc.dart';
import '../../features/workout_player/domain/services/precision_ticker.dart';
import '../../features/workout_player/presentation/bloc/workout_player_bloc.dart';

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
  // Database SQLite
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
}

/// Đăng ký dependencies cho tính năng Workout Builder (CRUD giáo án)
Future<void> _initWorkoutBuilder() async {
  // Repository
  sl.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(sl<DatabaseHelper>()),
  );

  // BLoCs (factory - mỗi lần dùng cần instance mới)
  sl.registerFactory(() => WorkoutCatalogBloc(sl<WorkoutRepository>()));
  sl.registerFactory(() => WorkoutBuilderBloc(sl<WorkoutRepository>()));
}

/// Đăng ký dependencies cho tính năng Workout Player (Đồng hồ đếm giờ & Trạng thái tập)
Future<void> _initWorkoutPlayer() async {
  sl.registerLazySingleton<PrecisionTicker>(() => const PrecisionTicker());
  sl.registerFactory(() => WorkoutPlayerBloc(ticker: sl<PrecisionTicker>()));
}

/// Đăng ký dependencies cho tính năng History (Lịch sử buổi tập)
Future<void> _initHistory() async {
  // Sẽ được bổ sung tại Phase 5 (HistoryRepository, HistoryBloc)
}

/// Đăng ký dependencies cho tính năng Settings (Cài đặt)
Future<void> _initSettings() async {
  // Sẽ được bổ sung tại Phase 6 (SettingsBloc)
}

