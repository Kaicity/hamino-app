import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/database/preset_workouts_data.dart';
import 'package:hamino_app/core/di/injection_container.dart';
import 'package:hamino_app/core/utils/time_formatter.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/repositories/workout_repository.dart';
import 'package:hamino_app/features/workout_builder/presentation/bloc/workout_builder_bloc.dart';
import 'package:hamino_app/features/workout_builder/presentation/bloc/workout_catalog_bloc.dart';
import 'package:hamino_app/features/workout_player/domain/services/precision_ticker.dart';
import 'package:hamino_app/features/workout_player/presentation/bloc/workout_player_bloc.dart';
import 'package:hamino_app/features/workout_player/presentation/pages/workout_player_page.dart';
import 'package:hamino_app/main.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  List<WorkoutTemplateEntity> workouts = List.from(PresetWorkoutsData.presets);

  @override
  Future<List<WorkoutTemplateEntity>> getAllWorkouts() async => List.from(workouts);

  @override
  Future<List<WorkoutTemplateEntity>> getWorkoutsByCategory(WorkoutCategory category) async {
    return workouts.where((w) => w.category == category).toList();
  }

  @override
  Future<WorkoutTemplateEntity?> getWorkoutById(String id) async {
    return workouts.cast<WorkoutTemplateEntity?>().firstWhere(
          (w) => w?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<void> saveWorkout(WorkoutTemplateEntity workout) async {
    final idx = workouts.indexWhere((w) => w.id == workout.id);
    if (idx >= 0) {
      workouts[idx] = workout;
    } else {
      workouts.add(workout);
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    workouts.removeWhere((w) => w.id == id);
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final idx = workouts.indexWhere((w) => w.id == id);
    if (idx >= 0) {
      workouts[idx] = workouts[idx].copyWith(isFavorite: isFavorite);
    }
  }
}

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerLazySingleton<WorkoutRepository>(() => FakeWorkoutRepository());
    sl.registerFactory(() => WorkoutCatalogBloc(sl<WorkoutRepository>()));
    sl.registerFactory(() => WorkoutBuilderBloc(sl<WorkoutRepository>()));
    sl.registerLazySingleton<PrecisionTicker>(() => const PrecisionTicker());
    sl.registerFactory(() => WorkoutPlayerBloc(ticker: sl<PrecisionTicker>()));
  });

  tearDown(() async {
    await sl.reset();
  });

  group('Hamino Workout Phase 2 Smoke & Catalog Widget Tests', () {
    testWidgets('App renders branding, catalog title, filter chips and preset cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HaminoApp());
      await tester.pumpAndSettle();

      // Header Branding
      expect(find.text('HAMINO'), findsOneWidget);
      expect(find.text('WORKOUT'), findsOneWidget);

      // Section titles
      expect(find.text('THƯ VIỆN BÀI TẬP'), findsOneWidget);
      expect(find.text('LỌC THEO THỂ LOẠI'), findsOneWidget);

      // Filter chips
      expect(find.text('TẤT CẢ'), findsOneWidget);
      expect(find.text('EMOM'), findsAtLeastNWidgets(1));
      expect(find.text('ENDURANCE'), findsAtLeastNWidgets(1));
      expect(find.text('SKILL'), findsAtLeastNWidgets(1));
      expect(find.text('CARDIO'), findsAtLeastNWidgets(1));

      // Preset workout cards
      expect(find.text('EMOM 20m Beast'), findsOneWidget);
      expect(find.text('Endurance 30m Circuit'), findsOneWidget);
      expect(find.text('Skill Handstand Mastery'), findsOneWidget);
      expect(find.text('Cardio HIIT Tabata'), findsOneWidget);

      // Quick start button
      expect(find.text('BẮT ĐẦU TẬP'), findsAtLeastNWidgets(1));

      // FAB "+" to create new workout
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Tapping category filter chip filters workouts list',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HaminoApp());
      await tester.pumpAndSettle();

      // Find chip EMOM and tap
      final emomChip = find.text('EMOM').first;
      await tester.tap(emomChip);
      await tester.pumpAndSettle();

      expect(find.text('1 BÀI TẬP'), findsOneWidget);
      expect(find.text('EMOM 20m Beast'), findsOneWidget);
      expect(find.text('Endurance 30m Circuit'), findsNothing);
    });

    testWidgets('Tapping BẮT ĐẦU TẬP navigates to WorkoutPlayerPage',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HaminoApp());
      await tester.pumpAndSettle();

      final startButton = find.text('BẮT ĐẦU TẬP').first;
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutPlayerPage), findsOneWidget);
      expect(find.text('CHUẨN BỊ'), findsOneWidget);
    });

    test('TimeFormatter formats seconds correctly', () {
      expect(TimeFormatter.formatSeconds(0), '00:00');
      expect(TimeFormatter.formatSeconds(45), '00:45');
      expect(TimeFormatter.formatSeconds(65), '01:05');
      expect(TimeFormatter.formatSeconds(120), '02:00');
      expect(TimeFormatter.formatSeconds(3665), '01:01:05');
    });

    test('TimeFormatter formatSecondsToReadable works as expected', () {
      expect(TimeFormatter.formatSecondsToReadable(30), '30s');
      expect(TimeFormatter.formatSecondsToReadable(60), '1m');
      expect(TimeFormatter.formatSecondsToReadable(90), '1m 30s');
      expect(TimeFormatter.formatSecondsToReadable(120), '2m');
    });
  });
}
