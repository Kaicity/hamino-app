import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_category.dart';
import '../../domain/entities/workout_template_entity.dart';
import '../../domain/repositories/workout_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class WorkoutBuilderEvent extends Equatable {
  const WorkoutBuilderEvent();

  @override
  List<Object?> get props => [];
}

class InitBuilderEvent extends WorkoutBuilderEvent {
  final WorkoutTemplateEntity? existingWorkout;
  const InitBuilderEvent(this.existingWorkout);

  @override
  List<Object?> get props => [existingWorkout];
}

class UpdateNameEvent extends WorkoutBuilderEvent {
  final String name;
  const UpdateNameEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateCategoryEvent extends WorkoutBuilderEvent {
  final WorkoutCategory category;
  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateDescriptionEvent extends WorkoutBuilderEvent {
  final String? description;
  const UpdateDescriptionEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class UpdatePrepareSecondsEvent extends WorkoutBuilderEvent {
  final int seconds;
  const UpdatePrepareSecondsEvent(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class UpdateDefaultRestSecondsEvent extends WorkoutBuilderEvent {
  final int seconds;
  const UpdateDefaultRestSecondsEvent(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class ToggleTimeCapEvent extends WorkoutBuilderEvent {
  final bool enabled;
  const ToggleTimeCapEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateTimeCapSecondsEvent extends WorkoutBuilderEvent {
  final int seconds;
  const UpdateTimeCapSecondsEvent(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class UpdateTargetRoundsEvent extends WorkoutBuilderEvent {
  final int rounds;
  const UpdateTargetRoundsEvent(this.rounds);

  @override
  List<Object?> get props => [rounds];
}

class AddExerciseEvent extends WorkoutBuilderEvent {
  final ExerciseEntity exercise;
  const AddExerciseEvent(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class UpdateExerciseEvent extends WorkoutBuilderEvent {
  final int index;
  final ExerciseEntity exercise;
  const UpdateExerciseEvent(this.index, this.exercise);

  @override
  List<Object?> get props => [index, exercise];
}

class RemoveExerciseEvent extends WorkoutBuilderEvent {
  final int index;
  const RemoveExerciseEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ReorderExercisesEvent extends WorkoutBuilderEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderExercisesEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class SaveWorkoutEvent extends WorkoutBuilderEvent {
  const SaveWorkoutEvent();
}

// ─── State ────────────────────────────────────────────────────────────────────

class WorkoutBuilderState extends Equatable {
  final String? editingId;
  final String name;
  final WorkoutCategory category;
  final String? description;
  final int prepareSeconds;
  final int defaultRestSeconds;
  final int timeCapSeconds;
  final int targetRounds;
  final List<ExerciseEntity> exercises;
  final bool isTimeCapped;
  final bool isSaving;
  final bool isSaved;
  final String? errorMessage;

  const WorkoutBuilderState({
    this.editingId,
    this.name = '',
    this.category = WorkoutCategory.endurance,
    this.description,
    this.prepareSeconds = 10,
    this.defaultRestSeconds = 60,
    this.timeCapSeconds = 0,
    this.targetRounds = 1,
    this.exercises = const [],
    this.isTimeCapped = false,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
  });

  WorkoutBuilderState copyWith({
    String? editingId,
    String? name,
    WorkoutCategory? category,
    String? description,
    bool clearDescription = false,
    int? prepareSeconds,
    int? defaultRestSeconds,
    int? timeCapSeconds,
    int? targetRounds,
    List<ExerciseEntity>? exercises,
    bool? isTimeCapped,
    bool? isSaving,
    bool? isSaved,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkoutBuilderState(
      editingId: editingId ?? this.editingId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: clearDescription ? null : (description ?? this.description),
      prepareSeconds: prepareSeconds ?? this.prepareSeconds,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      timeCapSeconds: timeCapSeconds ?? this.timeCapSeconds,
      targetRounds: targetRounds ?? this.targetRounds,
      exercises: exercises ?? this.exercises,
      isTimeCapped: isTimeCapped ?? this.isTimeCapped,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Tổng số rep trong 1 hiệp
  int get totalRepsPerRound =>
      exercises.fold(0, (sum, ex) => sum + ex.defaultReps);

  /// Tổng số rep của toàn bộ bài tập (tất cả các hiệp)
  int get totalRepsAllRounds => totalRepsPerRound * targetRounds;

  /// Tổng số giây giữ tĩnh trong 1 hiệp
  int get totalHoldSecondsPerRound =>
      exercises.fold(0, (sum, ex) => sum + ex.holdSeconds);

  /// Tổng số giây giữ tĩnh của toàn bộ bài tập (tất cả các hiệp)
  int get totalHoldSecondsAllRounds =>
      totalHoldSecondsPerRound * targetRounds;

  /// Chuỗi quy đổi tổng số giây giữ sang phút/giây
  /// Ví dụ: 60s -> "1 phút", 150s -> "2 phút 30 giây", 45s -> "45 giây"
  String get totalHoldTimeDisplay {
    final totalSec = totalHoldSecondsAllRounds;
    if (totalSec <= 0) return '0 giây';
    if (totalSec < 60) return '$totalSec giây';
    final minutes = totalSec ~/ 60;
    final seconds = totalSec % 60;
    if (seconds == 0) {
      return '$minutes phút';
    }
    return '$minutes phút $seconds giây';
  }

  /// Tổng số lượt tập (sets) của cả buổi tập
  int get totalSets => exercises.length * targetRounds;

  @override
  List<Object?> get props => [
        editingId,
        name,
        category,
        description,
        prepareSeconds,
        defaultRestSeconds,
        timeCapSeconds,
        targetRounds,
        exercises,
        isTimeCapped,
        isSaving,
        isSaved,
        errorMessage,
      ];
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────

class WorkoutBuilderBloc extends Bloc<WorkoutBuilderEvent, WorkoutBuilderState> {
  final WorkoutRepository _repository;

  WorkoutBuilderBloc(this._repository) : super(const WorkoutBuilderState()) {
    on<InitBuilderEvent>(_onInitBuilder);
    on<UpdateNameEvent>(_onUpdateName);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<UpdatePrepareSecondsEvent>(_onUpdatePrepareSeconds);
    on<UpdateDefaultRestSecondsEvent>(_onUpdateDefaultRestSeconds);
    on<ToggleTimeCapEvent>(_onToggleTimeCap);
    on<UpdateTimeCapSecondsEvent>(_onUpdateTimeCapSeconds);
    on<UpdateTargetRoundsEvent>(_onUpdateTargetRounds);
    on<AddExerciseEvent>(_onAddExercise);
    on<UpdateExerciseEvent>(_onUpdateExercise);
    on<RemoveExerciseEvent>(_onRemoveExercise);
    on<ReorderExercisesEvent>(_onReorderExercises);
    on<SaveWorkoutEvent>(_onSaveWorkout);
  }

  void _onInitBuilder(InitBuilderEvent event, Emitter<WorkoutBuilderState> emit) {
    final workout = event.existingWorkout;
    if (workout == null) {
      emit(const WorkoutBuilderState());
    } else {
      emit(WorkoutBuilderState(
        editingId: workout.id,
        name: workout.name,
        category: workout.category,
        description: workout.description,
        prepareSeconds: workout.prepareSeconds,
        defaultRestSeconds: workout.defaultRestSeconds,
        timeCapSeconds: workout.timeCapSeconds,
        targetRounds: workout.targetRounds,
        exercises: List.from(workout.exercises),
        isTimeCapped: workout.timeCapSeconds > 0,
      ));
    }
  }

  void _onUpdateName(UpdateNameEvent event, Emitter<WorkoutBuilderState> emit) {
    emit(state.copyWith(name: event.name, clearError: true));
  }

  void _onUpdateCategory(UpdateCategoryEvent event, Emitter<WorkoutBuilderState> emit) {
    emit(state.copyWith(category: event.category));
  }

  void _onUpdateDescription(
      UpdateDescriptionEvent event, Emitter<WorkoutBuilderState> emit) {
    if (event.description == null || event.description!.isEmpty) {
      emit(state.copyWith(clearDescription: true));
    } else {
      emit(state.copyWith(description: event.description));
    }
  }

  void _onUpdatePrepareSeconds(
      UpdatePrepareSecondsEvent event, Emitter<WorkoutBuilderState> emit) {
    emit(state.copyWith(prepareSeconds: event.seconds));
  }

  void _onUpdateDefaultRestSeconds(
      UpdateDefaultRestSecondsEvent event, Emitter<WorkoutBuilderState> emit) {
    emit(state.copyWith(defaultRestSeconds: event.seconds));
  }

  void _onToggleTimeCap(
      ToggleTimeCapEvent event, Emitter<WorkoutBuilderState> emit) {
    emit(state.copyWith(
      isTimeCapped: event.enabled,
      timeCapSeconds:
          event.enabled ? (state.timeCapSeconds > 0 ? state.timeCapSeconds : 1200) : 0,
    ));
  }

  void _onUpdateTimeCapSeconds(
      UpdateTimeCapSecondsEvent event, Emitter<WorkoutBuilderState> emit) {
    emit(state.copyWith(timeCapSeconds: event.seconds));
  }

  void _onUpdateTargetRounds(
      UpdateTargetRoundsEvent event, Emitter<WorkoutBuilderState> emit) {
    final rounds = event.rounds.clamp(1, 30);
    emit(state.copyWith(targetRounds: rounds));
  }

  void _onAddExercise(AddExerciseEvent event, Emitter<WorkoutBuilderState> emit) {
    final updated = List<ExerciseEntity>.from(state.exercises)..add(event.exercise);
    emit(state.copyWith(exercises: updated, clearError: true));
  }

  void _onUpdateExercise(
      UpdateExerciseEvent event, Emitter<WorkoutBuilderState> emit) {
    final updated = List<ExerciseEntity>.from(state.exercises);
    if (event.index >= 0 && event.index < updated.length) {
      updated[event.index] = event.exercise;
    }
    emit(state.copyWith(exercises: updated));
  }

  void _onRemoveExercise(
      RemoveExerciseEvent event, Emitter<WorkoutBuilderState> emit) {
    final updated = List<ExerciseEntity>.from(state.exercises);
    if (event.index >= 0 && event.index < updated.length) {
      updated.removeAt(event.index);
      final reindexed = updated.asMap().entries.map((entry) {
        return entry.value.copyWith(orderIndex: entry.key);
      }).toList();
      emit(state.copyWith(exercises: reindexed));
      return;
    }
    emit(state.copyWith(exercises: updated));
  }

  void _onReorderExercises(
      ReorderExercisesEvent event, Emitter<WorkoutBuilderState> emit) {
    final updated = List<ExerciseEntity>.from(state.exercises);
    if (event.oldIndex < 0 || event.oldIndex >= updated.length) return;
    final item = updated.removeAt(event.oldIndex);
    final targetIndex = event.newIndex.clamp(0, updated.length);
    updated.insert(targetIndex, item);
    final reindexed = updated.asMap().entries.map((entry) {
      return entry.value.copyWith(orderIndex: entry.key);
    }).toList();
    emit(state.copyWith(exercises: reindexed));
  }

  Future<void> _onSaveWorkout(
      SaveWorkoutEvent event, Emitter<WorkoutBuilderState> emit) async {
    // Validate tên
    if (state.name.trim().length < 3) {
      emit(state.copyWith(errorMessage: 'Tên bài tập phải có ít nhất 3 ký tự'));
      return;
    }
    // Validate động tác
    if (state.exercises.isEmpty) {
      emit(state.copyWith(errorMessage: 'Vui lòng thêm ít nhất 1 động tác'));
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      const uuid = Uuid();
      final workoutId = state.editingId ?? uuid.v4();

      final exercises = state.exercises.asMap().entries.map((entry) {
        return ExerciseEntity(
          id: entry.value.id.isNotEmpty ? entry.value.id : uuid.v4(),
          workoutId: workoutId,
          name: entry.value.name,
          defaultReps: entry.value.defaultReps,
          holdSeconds: entry.value.holdSeconds,
          orderIndex: entry.key,
          notes: entry.value.notes,
        );
      }).toList();

      final workout = WorkoutTemplateEntity(
        id: workoutId,
        name: state.name.trim(),
        category: state.category,
        description: state.description?.trim(),
        prepareSeconds: state.prepareSeconds,
        defaultRestSeconds: state.defaultRestSeconds,
        timeCapSeconds: state.isTimeCapped ? state.timeCapSeconds : 0,
        targetRounds: state.targetRounds,
        isPreset: false,
        createdAt: DateTime.now(),
        exercises: exercises,
      );

      await _repository.saveWorkout(workout);
      emit(state.copyWith(isSaving: false, isSaved: true));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
