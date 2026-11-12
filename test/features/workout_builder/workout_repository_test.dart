import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/database/database_helper.dart';
import 'package:hamino_app/core/database/preset_workouts_data.dart';
import 'package:hamino_app/features/workout_builder/data/models/exercise_model.dart';
import 'package:hamino_app/features/workout_builder/data/models/workout_template_model.dart';
import 'package:hamino_app/features/workout_builder/data/repositories/workout_repository_impl.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Khởi tạo sqflite FFI cho môi trường test trên Desktop/Unit test
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper & WorkoutRepository Integration Tests', () {
    late DatabaseHelper databaseHelper;
    late WorkoutRepositoryImpl repository;

    setUp(() async {
      // Sử dụng in-memory database riêng cho mỗi test để cô lập dữ liệu
      databaseHelper = DatabaseHelper(dbName: inMemoryDatabasePath);
      repository = WorkoutRepositoryImpl(databaseHelper);
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('Initial database creation should automatically seed 4 Calisthenics presets', () async {
      final workouts = await repository.getAllWorkouts();

      expect(workouts.length, 4);

      final presetIds = workouts.map((w) => w.id).toSet();
      expect(presetIds, contains(PresetWorkoutsData.presetCardioId));

      // Kiểm tra bài yêu thích (Endurance có isFavorite = true) nằm đầu danh sách
      expect(workouts.first.isFavorite, true);

      // Kiểm tra tất cả các bài tập con được load đầy đủ
      for (final workout in workouts) {
        expect(workout.exercises.isNotEmpty, true);
        for (int i = 0; i < workout.exercises.length; i++) {
          expect(workout.exercises[i].orderIndex, i);
        }
      }
    });

    test(
      'saveWorkout should insert a new custom workout with exercises',
      () async {
        const customId = 'custom_workout_123';
        final newWorkout = WorkoutTemplateModel(
          id: customId,
          name: 'Full Body Bar Workout',
          category: WorkoutCategory.endurance,
          description: 'Bài tập xà đơn và xà kép tự chế',
          prepareSeconds: 15,
          defaultRestSeconds: 75,
          timeCapSeconds: 2400,
          targetRounds: 4,
          isPreset: false,
          isFavorite: false,
          createdAt: DateTime(2026, 11, 10),
          exercises: const [
            ExerciseModel(
              id: 'ex_c1',
              workoutId: customId,
              name: 'Muscle-ups',
              defaultReps: 5,
              holdSeconds: 0,
              orderIndex: 0,
            ),
            ExerciseModel(
              id: 'ex_c2',
              workoutId: customId,
              name: 'Straight Bar Dips',
              defaultReps: 10,
              holdSeconds: 0,
              orderIndex: 1,
            ),
          ],
        );

        await repository.saveWorkout(newWorkout);

        final fetched = await repository.getWorkoutById(customId);
        expect(fetched, isNotNull);
        expect(fetched!.name, 'Full Body Bar Workout');
        expect(fetched.exercises.length, 2);
        expect(fetched.exercises[0].name, 'Muscle-ups');
        expect(fetched.exercises[1].name, 'Straight Bar Dips');

        final all = await repository.getAllWorkouts();
        expect(all.length, 5); // 4 presets + 1 custom
      },
    );

    test('saveWorkout should update an existing workout and replace exercises in a transaction', () async {
      final existing = await repository.getWorkoutById(
        PresetWorkoutsData.presetCardioId,
      );
      expect(existing, isNotNull);

      // Cập nhật tên và đổi danh sách bài tập con
      final updatedWorkout = existing!.copyWith(
        name: 'Cardio HIIT Tabata Pro',
        targetRounds: 10,
        exercises: const [
          ExerciseModel(
            id: 'ex_tabata_pro_1',
            workoutId: PresetWorkoutsData.presetCardioId,
            name: 'Burpee Over Bar',
            defaultReps: 0,
            holdSeconds: 20,
            orderIndex: 0,
          ),
          ExerciseModel(
            id: 'ex_tabata_pro_2',
            workoutId: PresetWorkoutsData.presetCardioId,
            name: 'Rest',
            defaultReps: 0,
            holdSeconds: 10,
            orderIndex: 1,
          ),
          ExerciseModel(
            id: 'ex_tabata_pro_3',
            workoutId: PresetWorkoutsData.presetCardioId,
            name: 'High Knees',
            defaultReps: 0,
            holdSeconds: 20,
            orderIndex: 2,
          ),
        ],
      );

      await repository.saveWorkout(updatedWorkout);

      final reFetched = await repository.getWorkoutById(
        PresetWorkoutsData.presetCardioId,
      );
      expect(reFetched, isNotNull);
      expect(reFetched!.name, 'Cardio HIIT Tabata Pro');
      expect(reFetched.targetRounds, 10);
      expect(reFetched.exercises.length, 3);
      expect(reFetched.exercises[2].name, 'High Knees');
    });
  });
}
