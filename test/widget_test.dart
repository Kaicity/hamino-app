import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/database/preset_workouts_data.dart';
import 'package:hamino_app/core/di/injection_container.dart';
import 'package:hamino_app/core/utils/time_formatter.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/repositories/workout_repository.dart';
import 'package:hamino_app/main.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  List<WorkoutTemplateEntity> workouts = List.from(PresetWorkoutsData.presets);

  @override
  Future<List<WorkoutTemplateEntity>> getAllWorkouts() async => workouts;

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
  });

  tearDown(() async {
    await sl.reset();
  });

  group('Hamino Workout Phase 1 Smoke & Widget Tests', () {
    testWidgets('App renders branding, Phase 1 banner and loads preset workouts',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HaminoApp());
      // Cho phép microtasks hoàn tất việc tải danh sách bài tập từ repository
      await tester.pump();
      await tester.pump();

      expect(find.text('HAMINO'), findsOneWidget);
      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('PHASE 1 HOÀN TẤT'), findsOneWidget);
      expect(find.text('GIÁO ÁN CALISTHENICS (4)'), findsOneWidget);
      expect(find.text('EMOM 20m Beast'), findsOneWidget);
      expect(find.text('Endurance 30m Circuit'), findsOneWidget);
      expect(find.text('Skill Handstand Mastery'), findsOneWidget);
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
