import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/workout_builder/domain/entities/workout_template_entity.dart';
import '../../domain/services/precision_ticker.dart';
import 'workout_player_event.dart';
import 'workout_player_state.dart';

class WorkoutPlayerBloc extends Bloc<WorkoutPlayerEvent, WorkoutPlayerState> {
  final PrecisionTicker _ticker;
  StreamSubscription<DateTime>? _tickerSubscription;

  late WorkoutTemplateEntity _workout;
  late DateTime _workoutStartedAt;
  late DateTime _stepStartedAt;
  DateTime? _lastPausedAt;

  Duration _accumulatedPauseDuration = Duration.zero;
  Duration _totalWorkoutPauseDuration = Duration.zero;
  int _targetStepSeconds = 0;
  int _totalWorkSeconds = 0;

  WorkoutPlayerBloc({PrecisionTicker? ticker})
      : _ticker = ticker ?? const PrecisionTicker(),
        super(const PlayerInitial()) {
    on<StartWorkoutEvent>(_onStartWorkout);
    on<TimerTickEvent>(_onTimerTick);
    on<PauseWorkoutEvent>(_onPauseWorkout);
    on<ResumeWorkoutEvent>(_onResumeWorkout);
    on<SkipNextEvent>(_onSkipNext);
    on<PreviousStepEvent>(_onPreviousStep);
    on<AddRestTimeEvent>(_onAddRestTime);
    on<FinishWorkoutEarlyEvent>(_onFinishWorkoutEarly);
    on<ToggleScreenLockEvent>(_onToggleScreenLock);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStartWorkout(StartWorkoutEvent event, Emitter<WorkoutPlayerState> emit) {
    _workout = event.workout;
    final now = DateTime.now();
    _workoutStartedAt = now;
    _stepStartedAt = now;
    _lastPausedAt = null;
    _accumulatedPauseDuration = Duration.zero;
    _totalWorkoutPauseDuration = Duration.zero;
    _targetStepSeconds = _workout.prepareSeconds;
    _totalWorkSeconds = 0;

    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick().listen((time) {
      add(TimerTickEvent(time));
    });

    if (_workout.prepareSeconds > 0) {
      emit(PlayerPrepare(
        workout: _workout,
        totalRounds: _workout.targetRounds,
        currentRound: 1,
        currentExerciseIndex: 0,
        remainingSeconds: _workout.prepareSeconds,
      ));
    } else {
      _startWorkStep(round: 1, exerciseIndex: 0, totalElapsed: 0, emit: emit);
    }
  }

  void _onTimerTick(TimerTickEvent event, Emitter<WorkoutPlayerState> emit) {
    if (state is PlayerInitial || state is PlayerPaused || state is PlayerCompleted) {
      return;
    }

    final totalElapsedMs = event.currentTime.difference(_workoutStartedAt).inMilliseconds -
        _totalWorkoutPauseDuration.inMilliseconds;
    final totalElapsedSec = (totalElapsedMs / 1000).floor().clamp(0, 999999);

    // Kiểm tra Time Cap
    if (_workout.hasTimeCap && totalElapsedSec >= _workout.timeCapSeconds) {
      _tickerSubscription?.cancel();
      emit(PlayerCompleted(
        workout: _workout,
        totalElapsedSeconds: totalElapsedSec,
        totalRounds: _workout.targetRounds,
        reason: CompletionReason.timeCapReached,
        completedRounds: state.currentRound,
        totalWorkSeconds: _totalWorkSeconds,
      ));
      return;
    }

    final stepElapsedMs = event.currentTime.difference(_stepStartedAt).inMilliseconds -
        _accumulatedPauseDuration.inMilliseconds;
    final stepElapsedSec = (stepElapsedMs / 1000).floor().clamp(0, 999999);

    if (state is PlayerPrepare) {
      final remaining = _targetStepSeconds - stepElapsedSec;
      if (remaining <= 0) {
        _startWorkStep(round: 1, exerciseIndex: 0, totalElapsed: totalElapsedSec, emit: emit);
      } else {
        emit((state as PlayerPrepare).copyWith(
          remainingSeconds: remaining,
          elapsedSeconds: stepElapsedSec,
          totalElapsedSeconds: totalElapsedSec,
        ));
      }
    } else if (state is PlayerWork) {
      final workState = state as PlayerWork;
      final currentEx = workState.currentExercise;

      if (currentEx != null && currentEx.isStaticHold) {
        final remaining = _targetStepSeconds - stepElapsedSec;
        if (remaining <= 0) {
          _totalWorkSeconds += _targetStepSeconds;
          _advanceFromWork(
            currentState: workState,
            totalElapsed: totalElapsedSec,
            emit: emit,
          );
        } else {
          emit(workState.copyWith(
            remainingSeconds: remaining,
            elapsedSeconds: stepElapsedSec,
            totalElapsedSeconds: totalElapsedSec,
          ));
        }
      } else {
        // Chế độ Reps: đếm tiến
        emit(workState.copyWith(
          elapsedSeconds: stepElapsedSec,
          totalElapsedSeconds: totalElapsedSec,
        ));
      }
    } else if (state is PlayerRest) {
      final restState = state as PlayerRest;
      final remaining = _targetStepSeconds - stepElapsedSec;
      if (remaining <= 0) {
        _startWorkStep(
          round: restState.nextRound,
          exerciseIndex: restState.nextExerciseIndex,
          totalElapsed: totalElapsedSec,
          emit: emit,
        );
      } else {
        emit(restState.copyWith(
          remainingSeconds: remaining,
          elapsedSeconds: stepElapsedSec,
          totalElapsedSeconds: totalElapsedSec,
        ));
      }
    }
  }

  void _startWorkStep({
    required int round,
    required int exerciseIndex,
    required int totalElapsed,
    required Emitter<WorkoutPlayerState> emit,
  }) {
    final now = DateTime.now();
    _stepStartedAt = now;
    _accumulatedPauseDuration = Duration.zero;

    final exercise = _workout.exercises[exerciseIndex];
    final isHold = exercise.isStaticHold;
    _targetStepSeconds = isHold ? exercise.holdSeconds : 0;

    emit(PlayerWork(
      workout: _workout,
      currentRound: round,
      totalRounds: _workout.targetRounds,
      currentExerciseIndex: exerciseIndex,
      remainingSeconds: isHold ? exercise.holdSeconds : 0,
      elapsedSeconds: 0,
      totalElapsedSeconds: totalElapsed,
      isScreenLocked: state.isScreenLocked,
    ));
  }

  void _advanceFromWork({
    required PlayerWork currentState,
    required int totalElapsed,
    required Emitter<WorkoutPlayerState> emit,
  }) {
    final isLastExInRound = currentState.isLastExerciseInRound;
    final isLastRound = currentState.isLastRound;

    if (isLastExInRound && isLastRound) {
      // Hoàn thành toàn bộ giáo án
      _tickerSubscription?.cancel();
      emit(PlayerCompleted(
        workout: _workout,
        totalElapsedSeconds: totalElapsed,
        totalRounds: _workout.targetRounds,
        reason: CompletionReason.allRoundsFinished,
        completedRounds: _workout.targetRounds,
        totalWorkSeconds: _totalWorkSeconds,
      ));
      return;
    }

    final int nextRound = isLastExInRound ? currentState.currentRound + 1 : currentState.currentRound;
    final int nextExIndex = isLastExInRound ? 0 : currentState.currentExerciseIndex + 1;

    // Vào thời gian nghỉ (Rest)
    final now = DateTime.now();
    _stepStartedAt = now;
    _accumulatedPauseDuration = Duration.zero;
    _targetStepSeconds = _workout.defaultRestSeconds;

    emit(PlayerRest(
      workout: _workout,
      currentRound: currentState.currentRound,
      totalRounds: _workout.targetRounds,
      currentExerciseIndex: currentState.currentExerciseIndex,
      nextRound: nextRound,
      nextExerciseIndex: nextExIndex,
      remainingSeconds: _workout.defaultRestSeconds,
      totalElapsedSeconds: totalElapsed,
      isScreenLocked: state.isScreenLocked,
    ));
  }

  void _onSkipNext(SkipNextEvent event, Emitter<WorkoutPlayerState> emit) {
    if (state is PlayerPrepare) {
      _startWorkStep(
        round: 1,
        exerciseIndex: 0,
        totalElapsed: state.totalElapsedSeconds,
        emit: emit,
      );
    } else if (state is PlayerWork) {
      final workState = state as PlayerWork;
      _totalWorkSeconds += workState.elapsedSeconds;
      _advanceFromWork(
        currentState: workState,
        totalElapsed: workState.totalElapsedSeconds,
        emit: emit,
      );
    } else if (state is PlayerRest) {
      final restState = state as PlayerRest;
      _startWorkStep(
        round: restState.nextRound,
        exerciseIndex: restState.nextExerciseIndex,
        totalElapsed: restState.totalElapsedSeconds,
        emit: emit,
      );
    }
  }

  void _onPreviousStep(PreviousStepEvent event, Emitter<WorkoutPlayerState> emit) {
    if (state is PlayerRest) {
      // Quay lại bài tập vừa thực hiện
      final restState = state as PlayerRest;
      _startWorkStep(
        round: restState.currentRound,
        exerciseIndex: restState.currentExerciseIndex,
        totalElapsed: restState.totalElapsedSeconds,
        emit: emit,
      );
    } else if (state is PlayerWork) {
      final workState = state as PlayerWork;
      if (workState.currentExerciseIndex > 0) {
        _startWorkStep(
          round: workState.currentRound,
          exerciseIndex: workState.currentExerciseIndex - 1,
          totalElapsed: workState.totalElapsedSeconds,
          emit: emit,
        );
      } else if (workState.currentRound > 1) {
        _startWorkStep(
          round: workState.currentRound - 1,
          exerciseIndex: _workout.exercises.length - 1,
          totalElapsed: workState.totalElapsedSeconds,
          emit: emit,
        );
      } else {
        // Ở bài đầu tiên của hiệp đầu: reset timer của bài này
        _startWorkStep(
          round: 1,
          exerciseIndex: 0,
          totalElapsed: workState.totalElapsedSeconds,
          emit: emit,
        );
      }
    } else if (state is PlayerPrepare) {
      final now = DateTime.now();
      _stepStartedAt = now;
      _accumulatedPauseDuration = Duration.zero;
      _targetStepSeconds = _workout.prepareSeconds;
      emit((state as PlayerPrepare).copyWith(
        remainingSeconds: _workout.prepareSeconds,
        elapsedSeconds: 0,
      ));
    }
  }

  void _onPauseWorkout(PauseWorkoutEvent event, Emitter<WorkoutPlayerState> emit) {
    if (state is PlayerPaused || state is PlayerCompleted || state is PlayerInitial) {
      return;
    }
    _lastPausedAt = DateTime.now();
    emit(PlayerPaused(
      previousState: state,
      workout: state.workout,
      currentRound: state.currentRound,
      totalRounds: state.totalRounds,
      currentExerciseIndex: state.currentExerciseIndex,
      remainingSeconds: state.remainingSeconds,
      elapsedSeconds: state.elapsedSeconds,
      totalElapsedSeconds: state.totalElapsedSeconds,
      isScreenLocked: state.isScreenLocked,
    ));
  }

  void _onResumeWorkout(ResumeWorkoutEvent event, Emitter<WorkoutPlayerState> emit) {
    if (state is! PlayerPaused) return;

    final pausedState = state as PlayerPaused;
    final pauseDuration = DateTime.now().difference(_lastPausedAt ?? DateTime.now());
    _accumulatedPauseDuration += pauseDuration;
    _totalWorkoutPauseDuration += pauseDuration;
    _lastPausedAt = null;

    emit(pausedState.previousState);
  }

  void _onAddRestTime(AddRestTimeEvent event, Emitter<WorkoutPlayerState> emit) {
    if (state is PlayerRest) {
      final restState = state as PlayerRest;
      _targetStepSeconds += event.additionalSeconds;
      final newRemaining = restState.remainingSeconds + event.additionalSeconds;
      emit(restState.copyWith(remainingSeconds: newRemaining));
    }
  }

  void _onFinishWorkoutEarly(
      FinishWorkoutEarlyEvent event, Emitter<WorkoutPlayerState> emit) {
    _tickerSubscription?.cancel();
    emit(PlayerCompleted(
      workout: _workout,
      totalElapsedSeconds: state.totalElapsedSeconds,
      totalRounds: _workout.targetRounds,
      reason: CompletionReason.finishedEarly,
      completedRounds: state.currentRound,
      totalWorkSeconds: _totalWorkSeconds + (state is PlayerWork ? state.elapsedSeconds : 0),
    ));
  }

  void _onToggleScreenLock(
      ToggleScreenLockEvent event, Emitter<WorkoutPlayerState> emit) {
    final nextLock = !state.isScreenLocked;
    if (state is PlayerPrepare) {
      emit((state as PlayerPrepare).copyWith(isScreenLocked: nextLock));
    } else if (state is PlayerWork) {
      emit((state as PlayerWork).copyWith(isScreenLocked: nextLock));
    } else if (state is PlayerRest) {
      emit((state as PlayerRest).copyWith(isScreenLocked: nextLock));
    } else if (state is PlayerPaused) {
      emit((state as PlayerPaused).copyWith(isScreenLocked: nextLock));
    }
  }
}
