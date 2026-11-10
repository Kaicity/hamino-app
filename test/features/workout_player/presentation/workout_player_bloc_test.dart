import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/exercise_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_player/domain/services/precision_ticker.dart';
import 'package:hamino_app/features/workout_player/presentation/bloc/workout_player_bloc.dart';
import 'package:hamino_app/features/workout_player/presentation/bloc/workout_player_event.dart';
import 'package:hamino_app/features/workout_player/presentation/bloc/workout_player_state.dart';

class TestTicker implements PrecisionTicker {
  final StreamController<DateTime> controller =
      StreamController<DateTime>.broadcast();

  @override
  Stream<DateTime> tick({Duration interval = const Duration(milliseconds: 100)}) {
    return controller.stream;
  }
}

void main() {
  late TestTicker testTicker;
  late WorkoutPlayerBloc bloc;

  final sampleWorkout = WorkoutTemplateEntity(
    id: 'test-workout',
    name: 'Test Calisthenics Routine',
    category: WorkoutCategory.endurance,
    prepareSeconds: 5,
    defaultRestSeconds: 30,
    timeCapSeconds: 600, // 10 phút
    targetRounds: 2,
    createdAt: DateTime.now(),
    exercises: const [
      ExerciseEntity(
        id: 'e1',
        workoutId: 'test-workout',
        name: 'Pull-up',
        defaultReps: 10,
        holdSeconds: 0,
        orderIndex: 0,
      ),
      ExerciseEntity(
        id: 'e2',
        workoutId: 'test-workout',
        name: 'L-Sit Hold',
        defaultReps: 0,
        holdSeconds: 15,
        orderIndex: 1,
      ),
    ],
  );

  setUp(() {
    testTicker = TestTicker();
    bloc = WorkoutPlayerBloc(ticker: testTicker);
  });

  tearDown(() {
    bloc.close();
    testTicker.controller.close();
  });

  group('WorkoutPlayerBloc FSM Tests (TASK-3.2)', () {
    test('Initial state is PlayerInitial', () {
      expect(bloc.state, isA<PlayerInitial>());
    });

    test('StartWorkoutEvent emits PlayerPrepare with prepare seconds', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerPrepare>((state) {
          return state.remainingSeconds == 5 &&
              state.currentRound == 1 &&
              state.totalRounds == 2 &&
              state.currentExerciseIndex == 0 &&
              state.currentExercise?.name == 'Pull-up';
        })),
      );
    });

    test('SkipNextEvent skips Prepare and starts PlayerWork directly', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));
      await bloc.stream.firstWhere((s) => s is PlayerPrepare);

      bloc.add(const SkipNextEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerWork>((state) {
          return state.currentRound == 1 &&
              state.currentExerciseIndex == 0 &&
              state.currentExercise?.name == 'Pull-up' &&
              state.remainingSeconds == 0;
        })),
      );
    });

    test('Work to Rest transition when tapping SkipNext on Reps exercise', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));
      await bloc.stream.firstWhere((s) => s is PlayerPrepare);

      // Skip prepare -> enters Work
      bloc.add(const SkipNextEvent());
      await bloc.stream.firstWhere((s) => s is PlayerWork);

      // Complete reps -> enters Rest
      bloc.add(const SkipNextEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerRest>((state) {
          return state.currentRound == 1 &&
              state.currentExerciseIndex == 0 &&
              state.nextRound == 1 &&
              state.nextExerciseIndex == 1 &&
              state.remainingSeconds == 30;
        })),
      );
    });

    test('AddRestTimeEvent extends rest duration', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));
      await bloc.stream.firstWhere((s) => s is PlayerPrepare);
      bloc.add(const SkipNextEvent()); // to Work
      await bloc.stream.firstWhere((s) => s is PlayerWork);
      bloc.add(const SkipNextEvent()); // to Rest
      await bloc.stream.firstWhere((s) => s is PlayerRest);

      bloc.add(const AddRestTimeEvent(10));

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerRest>((state) {
          return state.remainingSeconds == 40;
        })),
      );
    });

    test('PreviousStepEvent in Rest goes back to Work of current exercise', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));
      await bloc.stream.firstWhere((s) => s is PlayerPrepare);
      bloc.add(const SkipNextEvent()); // to Work E0
      await bloc.stream.firstWhere((s) => s is PlayerWork);
      bloc.add(const SkipNextEvent()); // to Rest
      await bloc.stream.firstWhere((s) => s is PlayerRest);

      bloc.add(const PreviousStepEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerWork>((state) {
          return state.currentRound == 1 &&
              state.currentExerciseIndex == 0 &&
              state.currentExercise?.name == 'Pull-up';
        })),
      );
    });

    test('PauseWorkoutEvent and ResumeWorkoutEvent pause and resume timer', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));
      await bloc.stream.firstWhere((s) => s is PlayerPrepare);

      bloc.add(const PauseWorkoutEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerPaused>((state) {
          return state.previousState is PlayerPrepare;
        })),
      );

      bloc.add(const ResumeWorkoutEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerPrepare>((state) {
          return state.remainingSeconds == 5;
        })),
      );
    });

    test('FinishWorkoutEarlyEvent emits PlayerCompleted with finishedEarly', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));
      await bloc.stream.firstWhere((s) => s is PlayerPrepare);

      bloc.add(const FinishWorkoutEarlyEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerCompleted>((state) {
          return state.reason == CompletionReason.finishedEarly &&
              state.completedRounds == 1;
        })),
      );
    });

    test('ToggleScreenLockEvent toggles lock state', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));
      await bloc.stream.firstWhere((s) => s is PlayerPrepare);

      expect(bloc.state.isScreenLocked, isFalse);

      bloc.add(const ToggleScreenLockEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerPrepare>((state) => state.isScreenLocked == true)),
      );

      bloc.add(const ToggleScreenLockEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerPrepare>((state) => state.isScreenLocked == false)),
      );
    });

    test('Full workout progression to PlayerCompleted', () async {
      bloc.add(StartWorkoutEvent(sampleWorkout));
      await bloc.stream.firstWhere((s) => s is PlayerPrepare);

      // Round 1, Exercise 0 (Pull-up)
      bloc.add(const SkipNextEvent());
      await bloc.stream.firstWhere((s) => s is PlayerWork && s.currentExerciseIndex == 0);

      // Round 1, Rest after E0
      bloc.add(const SkipNextEvent());
      await bloc.stream.firstWhere((s) => s is PlayerRest && s.currentExerciseIndex == 0);

      // Round 1, Exercise 1 (L-Sit Hold)
      bloc.add(const SkipNextEvent());
      await bloc.stream.firstWhere((s) => s is PlayerWork && s.currentExerciseIndex == 1);

      // Round 1, Rest after E1 -> transition to Round 2
      bloc.add(const SkipNextEvent());
      await bloc.stream.firstWhere((s) => s is PlayerRest && s.nextRound == 2);

      // Round 2, Exercise 0 (Pull-up)
      bloc.add(const SkipNextEvent());
      await bloc.stream.firstWhere((s) => s is PlayerWork && s.currentRound == 2 && s.currentExerciseIndex == 0);

      // Round 2, Rest after E0
      bloc.add(const SkipNextEvent());
      await bloc.stream.firstWhere((s) => s is PlayerRest && s.currentRound == 2);

      // Round 2, Exercise 1 (L-Sit Hold - LAST STEP!)
      bloc.add(const SkipNextEvent());
      await bloc.stream.firstWhere((s) => s is PlayerWork && s.currentRound == 2 && s.currentExerciseIndex == 1);

      // Finish last step of last round
      bloc.add(const SkipNextEvent());

      await expectLater(
        bloc.stream,
        emits(predicate<PlayerCompleted>((state) {
          return state.reason == CompletionReason.allRoundsFinished &&
              state.completedRounds == 2;
        })),
      );
    });
  });
}

