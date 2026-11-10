import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/constants/db_constants.dart';
import 'package:hamino_app/core/database/preset_workouts_data.dart';
import 'package:hamino_app/core/theme/app_colors.dart';
import 'package:hamino_app/features/history/data/models/workout_session_model.dart';
import 'package:hamino_app/features/history/domain/entities/workout_session_record.dart';
import 'package:hamino_app/features/workout_builder/data/models/exercise_model.dart';
import 'package:hamino_app/features/workout_builder/data/models/workout_template_model.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/exercise_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';

void main() {
  group('WorkoutCategory Tests', () {
    test('Category properties should return correct values', () {
      expect(WorkoutCategory.emom.displayName, 'EMOM');
      expect(WorkoutCategory.endurance.displayName, 'Endurance');
      expect(WorkoutCategory.skill.displayName, 'Skill');
      expect(WorkoutCategory.cardio.displayName, 'Cardio');

      expect(WorkoutCategory.emom.vietnameseLabel, contains('EMOM'));
      expect(WorkoutCategory.endurance.vietnameseLabel, contains('Endurance'));
      expect(WorkoutCategory.skill.vietnameseLabel, contains('Skill'));
      expect(WorkoutCategory.cardio.vietnameseLabel, contains('Cardio'));

      expect(WorkoutCategory.emom.color, AppColors.catEmom);
      expect(WorkoutCategory.endurance.color, AppColors.catEndurance);
      expect(WorkoutCategory.skill.color, AppColors.catSkill);
      expect(WorkoutCategory.cardio.color, AppColors.catCardio);
    });

    test('fromString should parse category strings case-insensitively', () {
      expect(WorkoutCategory.fromString('emom'), WorkoutCategory.emom);
      expect(WorkoutCategory.fromString('EMOM'), WorkoutCategory.emom);
      expect(WorkoutCategory.fromString('endurance'), WorkoutCategory.endurance);
      expect(WorkoutCategory.fromString('SKILL'), WorkoutCategory.skill);
      expect(WorkoutCategory.fromString('Cardio'), WorkoutCategory.cardio);
      expect(WorkoutCategory.fromString('invalid_val'), WorkoutCategory.endurance);
      expect(WorkoutCategory.fromString(null), WorkoutCategory.endurance);
    });
  });

  group('ExerciseEntity & ExerciseModel Tests', () {
    const exercise = ExerciseModel(
      id: 'ex_1',
      workoutId: 'w_1',
      name: 'Pull-ups',
      defaultReps: 10,
      holdSeconds: 0,
      orderIndex: 0,
      notes: 'Duỗi hết tay',
    );

    test('isStaticHold and targetSummary should work correctly', () {
      expect(exercise.isStaticHold, false);
      expect(exercise.targetSummary, '10 reps');

      const holdEx = ExerciseModel(
        id: 'ex_2',
        workoutId: 'w_1',
        name: 'Plank',
        defaultReps: 0,
        holdSeconds: 30,
        orderIndex: 1,
      );
      expect(holdEx.isStaticHold, true);
      expect(holdEx.targetSummary, '30s hold');

      const timedRepEx = ExerciseModel(
        id: 'ex_3',
        workoutId: 'w_1',
        name: 'Isometric Squat',
        defaultReps: 5,
        holdSeconds: 10,
        orderIndex: 2,
      );
      expect(timedRepEx.isStaticHold, false);
      expect(timedRepEx.targetSummary, '5 reps (10s)');
    });

    test('toMap and fromMap should correctly serialize and deserialize', () {
      final map = exercise.toMap();
      expect(map[DbConstants.colExerciseId], 'ex_1');
      expect(map[DbConstants.colExerciseWorkoutId], 'w_1');
      expect(map[DbConstants.colExerciseName], 'Pull-ups');
      expect(map[DbConstants.colExerciseDefaultReps], 10);
      expect(map[DbConstants.colExerciseHoldSeconds], 0);
      expect(map[DbConstants.colExerciseOrderIndex], 0);
      expect(map[DbConstants.colExerciseNotes], 'Duỗi hết tay');

      final fromMapEx = ExerciseModel.fromMap(map);
      expect(fromMapEx, exercise);
    });

    test('copyWith should update fields correctly', () {
      final updated = exercise.copyWith(name: 'Chin-ups', defaultReps: 12);
      expect(updated.name, 'Chin-ups');
      expect(updated.defaultReps, 12);
      expect(updated.id, exercise.id);
      expect(updated.workoutId, exercise.workoutId);
    });

    test('fromEntity should convert ExerciseEntity to ExerciseModel', () {
      const entity = ExerciseEntity(
        id: 'e_10',
        workoutId: 'w_10',
        name: 'Dips',
        defaultReps: 15,
        holdSeconds: 0,
        orderIndex: 3,
        notes: 'Gập 90 độ',
      );
      final model = ExerciseModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.defaultReps, entity.defaultReps);
    });
  });

  group('WorkoutTemplateEntity & WorkoutTemplateModel Tests', () {
    final now = DateTime(2026, 11, 10, 10, 0, 0);
    final workout = WorkoutTemplateModel(
      id: 'w_test_1',
      name: 'Test Workout',
      category: WorkoutCategory.emom,
      description: 'Mô tả test',
      prepareSeconds: 10,
      defaultRestSeconds: 45,
      timeCapSeconds: 600,
      targetRounds: 4,
      isPreset: false,
      isFavorite: true,
      createdAt: now,
      exercises: const [
        ExerciseModel(
          id: 'ex_1',
          workoutId: 'w_test_1',
          name: 'Push-ups',
          defaultReps: 15,
          orderIndex: 0,
        ),
      ],
    );

    test('Properties and helper getters should return expected values', () {
      expect(workout.totalExercises, 1);
      expect(workout.hasTimeCap, true);
      expect(workout.timeCapDisplay, '10 phút');

      // Target volume getters
      expect(workout.totalRepsPerRound, 15);
      expect(workout.totalRepsAllRounds, 60);
      expect(workout.totalHoldSecondsPerRound, 0);
      expect(workout.totalHoldSecondsAllRounds, 0);
      expect(workout.totalHoldTimeDisplay, '0 giây');
      expect(workout.totalSets, 4);

      final holdWorkout = workout.copyWith(
        exercises: const [
          ExerciseModel(
            id: 'ex_hold',
            workoutId: 'w_test_1',
            name: 'Plank Hold',
            defaultReps: 0,
            holdSeconds: 45,
            orderIndex: 0,
          ),
        ],
      );
      expect(holdWorkout.totalHoldSecondsPerRound, 45);
      expect(holdWorkout.totalHoldSecondsAllRounds, 180);
      expect(holdWorkout.totalHoldTimeDisplay, '3 phút');

      final noCapWorkout = workout.copyWith(timeCapSeconds: 0);
      expect(noCapWorkout.hasTimeCap, false);
      expect(noCapWorkout.timeCapDisplay, 'Không giới hạn');
    });

    test('toMap and fromMap should correctly serialize and deserialize', () {
      final map = workout.toMap();
      expect(map[DbConstants.colWorkoutId], 'w_test_1');
      expect(map[DbConstants.colWorkoutName], 'Test Workout');
      expect(map[DbConstants.colWorkoutCategory], 'emom');
      expect(map[DbConstants.colWorkoutDescription], 'Mô tả test');
      expect(map[DbConstants.colWorkoutPrepareSeconds], 10);
      expect(map[DbConstants.colWorkoutDefaultRestSeconds], 45);
      expect(map[DbConstants.colWorkoutTimeCapSeconds], 600);
      expect(map[DbConstants.colWorkoutTargetRounds], 4);
      expect(map[DbConstants.colWorkoutIsPreset], 0);
      expect(map[DbConstants.colWorkoutIsFavorite], 1);
      expect(map[DbConstants.colWorkoutCreatedAt], now.toIso8601String());

      final fromMapWorkout = WorkoutTemplateModel.fromMap(
        map,
        exercises: workout.exercises,
      );
      expect(fromMapWorkout.id, workout.id);
      expect(fromMapWorkout.name, workout.name);
      expect(fromMapWorkout.category, workout.category);
      expect(fromMapWorkout.isFavorite, true);
      expect(fromMapWorkout.exercises.length, 1);
    });

    test('fromEntity should convert WorkoutTemplateEntity to WorkoutTemplateModel', () {
      final entity = WorkoutTemplateEntity(
        id: 'w_entity',
        name: 'Entity Workout',
        category: WorkoutCategory.skill,
        createdAt: now,
      );
      final model = WorkoutTemplateModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.category, WorkoutCategory.skill);
    });
  });

  group('WorkoutSessionRecord & WorkoutSessionModel Tests', () {
    final started = DateTime(2026, 11, 10, 8, 0, 0);
    final finished = DateTime(2026, 11, 10, 8, 30, 0);
    final session = WorkoutSessionModel(
      id: 'session_1',
      workoutId: 'w_test_1',
      workoutName: 'Test Workout',
      startedAt: started,
      finishedAt: finished,
      durationSeconds: 1800,
      completedRounds: 5,
      rpeScore: 8,
      notes: 'Buổi tập rất sung sức',
    );

    test('toMap and fromMap should correctly serialize and deserialize', () {
      final map = session.toMap();
      expect(map[DbConstants.colSessionId], 'session_1');
      expect(map[DbConstants.colSessionWorkoutId], 'w_test_1');
      expect(map[DbConstants.colSessionWorkoutName], 'Test Workout');
      expect(map[DbConstants.colSessionStartedAt], started.toIso8601String());
      expect(map[DbConstants.colSessionFinishedAt], finished.toIso8601String());
      expect(map[DbConstants.colSessionDurationSeconds], 1800);
      expect(map[DbConstants.colSessionCompletedRounds], 5);
      expect(map[DbConstants.colSessionRpeScore], 8);
      expect(map[DbConstants.colSessionNotes], 'Buổi tập rất sung sức');

      final fromMapSession = WorkoutSessionModel.fromMap(map);
      expect(fromMapSession.id, session.id);
      expect(fromMapSession.workoutName, session.workoutName);
      expect(fromMapSession.durationSeconds, 1800);
      expect(fromMapSession.completedRounds, 5);
      expect(fromMapSession.rpeScore, 8);
    });

    test('fromEntity should convert WorkoutSessionRecord to WorkoutSessionModel', () {
      final entity = WorkoutSessionRecord(
        id: 's_ent',
        workoutId: 'w_ent',
        workoutName: 'Entity Name',
        startedAt: started,
        finishedAt: finished,
        durationSeconds: 1200,
        completedRounds: 4,
      );
      final model = WorkoutSessionModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.workoutName, entity.workoutName);
      expect(model.completedRounds, 4);
    });
  });

  group('PresetWorkoutsData Tests (TASK-1.4)', () {
    test('Should have exactly 4 presets defined', () {
      final presets = PresetWorkoutsData.presets;
      expect(presets.length, 4);
    });

    test('Preset 1: EMOM 20m Beast should meet all specifications', () {
      final emom = PresetWorkoutsData.presets.firstWhere(
        (p) => p.id == PresetWorkoutsData.presetEmomId,
      );
      expect(emom.name, 'EMOM 20m Beast');
      expect(emom.category, WorkoutCategory.emom);
      expect(emom.targetRounds, 5);
      expect(emom.timeCapSeconds, 1200); // 20m
      expect(emom.isPreset, true);
      expect(emom.exercises.length, 4);
      expect(emom.exercises[0].name, 'Pull-ups');
      expect(emom.exercises[0].defaultReps, 10);
      expect(emom.exercises[1].name, 'Push-ups');
      expect(emom.exercises[1].defaultReps, 20);
      expect(emom.exercises[2].name, 'Dips');
      expect(emom.exercises[2].defaultReps, 15);
      expect(emom.exercises[3].name, 'Rest');
      expect(emom.exercises[3].holdSeconds, 60);
    });

    test('Preset 2: Endurance 30m Circuit should meet all specifications', () {
      final endurance = PresetWorkoutsData.presets.firstWhere(
        (p) => p.id == PresetWorkoutsData.presetEnduranceId,
      );
      expect(endurance.name, 'Endurance 30m Circuit');
      expect(endurance.category, WorkoutCategory.endurance);
      expect(endurance.targetRounds, 5);
      expect(endurance.defaultRestSeconds, 90);
      expect(endurance.timeCapSeconds, 1800); // 30m
      expect(endurance.isPreset, true);
      expect(endurance.exercises.length, 4);
      expect(endurance.exercises[0].name, 'Pull-ups');
      expect(endurance.exercises[0].defaultReps, 8);
      expect(endurance.exercises[1].name, 'Dips');
      expect(endurance.exercises[1].defaultReps, 12);
      expect(endurance.exercises[2].name, 'Australian Rows');
      expect(endurance.exercises[2].defaultReps, 12);
      expect(endurance.exercises[3].name, 'Bodyweight Squats');
      expect(endurance.exercises[3].defaultReps, 20);
    });

    test('Preset 3: Skill Handstand Mastery should meet all specifications', () {
      final skill = PresetWorkoutsData.presets.firstWhere(
        (p) => p.id == PresetWorkoutsData.presetSkillId,
      );
      expect(skill.name, 'Skill Handstand Mastery');
      expect(skill.category, WorkoutCategory.skill);
      expect(skill.targetRounds, 6);
      expect(skill.defaultRestSeconds, 90);
      expect(skill.timeCapSeconds, 0); // No time cap
      expect(skill.isPreset, true);
      expect(skill.exercises.length, 4);
      expect(skill.exercises[0].name, 'Handstand Wall Hold');
      expect(skill.exercises[0].holdSeconds, 20);
      expect(skill.exercises[1].name, 'Rest');
      expect(skill.exercises[1].holdSeconds, 90);
      expect(skill.exercises[2].name, 'Pike Push-ups');
      expect(skill.exercises[2].defaultReps, 8);
      expect(skill.exercises[3].name, 'Rest');
      expect(skill.exercises[3].holdSeconds, 90);
    });

    test('Preset 4: Cardio HIIT Tabata should meet all specifications', () {
      final cardio = PresetWorkoutsData.presets.firstWhere(
        (p) => p.id == PresetWorkoutsData.presetCardioId,
      );
      expect(cardio.name, 'Cardio HIIT Tabata');
      expect(cardio.category, WorkoutCategory.cardio);
      expect(cardio.targetRounds, 8);
      expect(cardio.defaultRestSeconds, 10);
      expect(cardio.timeCapSeconds, 240); // 4m
      expect(cardio.isPreset, true);
      expect(cardio.exercises.length, 2);
      expect(cardio.exercises[0].name, 'Burpees');
      expect(cardio.exercises[0].holdSeconds, 20);
      expect(cardio.exercises[1].name, 'Rest');
      expect(cardio.exercises[1].holdSeconds, 10);
    });
  });
}

