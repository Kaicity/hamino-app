import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/exercise_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/repositories/workout_repository.dart';
import 'package:hamino_app/features/workout_builder/presentation/bloc/workout_builder_bloc.dart';

class MockWorkoutRepository implements WorkoutRepository {
  List<WorkoutTemplateEntity> workouts = [];

  @override
  Future<List<WorkoutTemplateEntity>> getAllWorkouts() async => workouts;

  @override
  Future<List<WorkoutTemplateEntity>> getWorkoutsByCategory(WorkoutCategory category) async => [];

  @override
  Future<WorkoutTemplateEntity?> getWorkoutById(String id) async => null;

  @override
  Future<void> saveWorkout(WorkoutTemplateEntity workout) async {
    workouts.add(workout);
  }

  @override
  Future<void> deleteWorkout(String id) async {}

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {}
}

void main() {
  late MockWorkoutRepository repository;
  late WorkoutBuilderBloc bloc;

  setUp(() {
    repository = MockWorkoutRepository();
    bloc = WorkoutBuilderBloc(repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('WorkoutBuilderBloc Tests (TASK-2.3 & TASK-2.4)', () {
    test('Initial state has default values', () {
      expect(bloc.state.name, '');
      expect(bloc.state.category, WorkoutCategory.endurance);
      expect(bloc.state.prepareSeconds, 10);
      expect(bloc.state.defaultRestSeconds, 0);
      expect(bloc.state.timeCapSeconds, 0);
      expect(bloc.state.targetRounds, 1);
      expect(bloc.state.exercises, isEmpty);
      expect(bloc.state.isTimeCapped, false);
      expect(bloc.state.isSaving, false);
      expect(bloc.state.isSaved, false);
    });

    test('InitBuilderEvent with existing workout populates fields', () {
      final existing = WorkoutTemplateEntity(
        id: 'existing-123',
        name: 'Custom Push Workout',
        category: WorkoutCategory.emom,
        description: 'Hard push session',
        prepareSeconds: 15,
        defaultRestSeconds: 90,
        timeCapSeconds: 1200,
        targetRounds: 4,
        createdAt: DateTime.now(),
        exercises: const [
          ExerciseEntity(
            id: 'ex-1',
            workoutId: 'existing-123',
            name: 'Push-ups',
            defaultReps: 20,
            holdSeconds: 0,
            orderIndex: 0,
          ),
        ],
      );

      bloc.add(InitBuilderEvent(existing));

      expect(bloc.stream, emits(predicate<WorkoutBuilderState>((state) {
        return state.editingId == 'existing-123' &&
            state.name == 'Custom Push Workout' &&
            state.category == WorkoutCategory.emom &&
            state.description == 'Hard push session' &&
            state.prepareSeconds == 15 &&
            state.defaultRestSeconds == 90 &&
            state.timeCapSeconds == 1200 &&
            state.targetRounds == 4 &&
            state.isTimeCapped == true &&
            state.exercises.length == 1;
      })));
    });

    test('Updating fields changes state correctly', () async {
      bloc.add(const UpdateNameEvent('Muscle-Up Mastery'));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.name == 'Muscle-Up Mastery')),
      );

      bloc.add(const UpdateCategoryEvent(WorkoutCategory.skill));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.category == WorkoutCategory.skill)),
      );

      bloc.add(const UpdatePrepareSecondsEvent(5));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.prepareSeconds == 5)),
      );

      bloc.add(const UpdateDefaultRestSecondsEvent(120));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.defaultRestSeconds == 120)),
      );

      bloc.add(const ToggleTimeCapEvent(true));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.isTimeCapped == true && s.timeCapSeconds > 0)),
      );

      bloc.add(const UpdateTargetRoundsEvent(5));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.targetRounds == 5)),
      );
    });

    test('Target rounds clamping works (between 1 and 100)', () async {
      bloc.add(const UpdateTargetRoundsEvent(0));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.targetRounds == 1)),
      );

      bloc.add(const UpdateTargetRoundsEvent(150));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.targetRounds == 100)),
      );
    });

    test('Add, update, reorder and remove exercises', () async {
      const ex1 = ExerciseEntity(
        id: '1',
        workoutId: 'w1',
        name: 'Pull-up',
        defaultReps: 10,
        holdSeconds: 0,
        orderIndex: 0,
      );
      const ex2 = ExerciseEntity(
        id: '2',
        workoutId: 'w1',
        name: 'Dips',
        defaultReps: 15,
        holdSeconds: 0,
        orderIndex: 1,
      );

      // Add ex1
      bloc.add(const AddExerciseEvent(ex1));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.exercises.length == 1)),
      );

      // Add ex2
      bloc.add(const AddExerciseEvent(ex2));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) => s.exercises.length == 2)),
      );

      // Update ex1 (e.g. change reps to 12)
      const updatedEx1 = ExerciseEntity(
        id: '1',
        workoutId: 'w1',
        name: 'Pull-up',
        defaultReps: 12,
        holdSeconds: 0,
        orderIndex: 0,
      );
      bloc.add(const UpdateExerciseEvent(0, updatedEx1));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>(
            (s) => s.exercises[0].defaultReps == 12)),
      );

      // Reorder: Move Dips (index 1) to index 0
      bloc.add(const ReorderExercisesEvent(1, 0));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) {
          return s.exercises[0].name == 'Dips' &&
              s.exercises[0].orderIndex == 0 &&
              s.exercises[1].name == 'Pull-up' &&
              s.exercises[1].orderIndex == 1;
        })),
      );

      // Remove index 0
      bloc.add(const RemoveExerciseEvent(0));
      await expectLater(
        bloc.stream,
        emits(predicate<WorkoutBuilderState>((s) {
          return s.exercises.length == 1 &&
              s.exercises[0].name == 'Pull-up' &&
              s.exercises[0].orderIndex == 0;
        })),
      );
    });

    test('Save validation fails if name is less than 3 characters', () async {
      bloc.add(const UpdateNameEvent('Ab'));
      bloc.add(const AddExerciseEvent(ExerciseEntity(
        id: '1',
        workoutId: 'w1',
        name: 'Push-up',
        defaultReps: 10,
        holdSeconds: 0,
        orderIndex: 0,
      )));
      bloc.add(const SaveWorkoutEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WorkoutBuilderState>(
          (s) => s.errorMessage == 'Tên bài tập phải có ít nhất 3 ký tự',
        )),
      );
    });

    test('Save validation fails if exercises list is empty', () async {
      bloc.add(const UpdateNameEvent('Leg Destroyer'));
      bloc.add(const SaveWorkoutEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WorkoutBuilderState>(
          (s) => s.errorMessage == 'Vui lòng thêm ít nhất 1 động tác',
        )),
      );
    });

    test('Save succeeds with valid name and exercises', () async {
      bloc.add(const UpdateNameEvent('Leg Destroyer'));
      bloc.add(const AddExerciseEvent(ExerciseEntity(
        id: '1',
        workoutId: 'w1',
        name: 'Squats',
        defaultReps: 25,
        holdSeconds: 0,
        orderIndex: 0,
      )));
      bloc.add(const SaveWorkoutEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<WorkoutBuilderState>(
          (s) => s.isSaved == true && repository.workouts.length == 1,
        )),
      );
    });
  });
}

