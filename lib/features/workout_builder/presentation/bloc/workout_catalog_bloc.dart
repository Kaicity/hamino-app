import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_category.dart';
import '../../domain/entities/workout_template_entity.dart';
import '../../domain/repositories/workout_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class WorkoutCatalogEvent extends Equatable {
  const WorkoutCatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadCatalogEvent extends WorkoutCatalogEvent {
  const LoadCatalogEvent();
}

class FilterByCategoryEvent extends WorkoutCatalogEvent {
  final WorkoutCategory? category;
  const FilterByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class ToggleFavoriteEvent extends WorkoutCatalogEvent {
  final String workoutId;
  final bool isFavorite;
  const ToggleFavoriteEvent(this.workoutId, this.isFavorite);

  @override
  List<Object?> get props => [workoutId, isFavorite];
}

class DeleteWorkoutEvent extends WorkoutCatalogEvent {
  final String workoutId;
  const DeleteWorkoutEvent(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class DuplicateWorkoutEvent extends WorkoutCatalogEvent {
  final String workoutId;
  const DuplicateWorkoutEvent(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

// ─── Status ───────────────────────────────────────────────────────────────────

enum CatalogStatus { loading, loaded, error }

// ─── States ───────────────────────────────────────────────────────────────────

abstract class WorkoutCatalogState extends Equatable {
  final CatalogStatus status;
  final List<WorkoutTemplateEntity> allWorkouts;
  final List<WorkoutTemplateEntity> filteredWorkouts;
  final WorkoutCategory? selectedCategory;
  final String? errorMessage;

  const WorkoutCatalogState({
    required this.status,
    this.allWorkouts = const [],
    this.filteredWorkouts = const [],
    this.selectedCategory,
    this.errorMessage,
  });

  bool get isLoading => status == CatalogStatus.loading;
  bool get isLoaded => status == CatalogStatus.loaded;
  bool get isError => status == CatalogStatus.error;

  @override
  List<Object?> get props => [
        status,
        allWorkouts,
        filteredWorkouts,
        selectedCategory,
        errorMessage,
      ];
}

/// Trạng thái đang tải danh mục bài tập
class CatalogLoading extends WorkoutCatalogState {
  const CatalogLoading({
    super.allWorkouts,
    super.filteredWorkouts,
    super.selectedCategory,
  }) : super(status: CatalogStatus.loading);
}

/// Trạng thái đã tải danh mục bài tập thành công
class CatalogLoaded extends WorkoutCatalogState {
  const CatalogLoaded({
    required super.allWorkouts,
    required super.filteredWorkouts,
    super.selectedCategory,
  }) : super(status: CatalogStatus.loaded);

  CatalogLoaded copyWith({
    List<WorkoutTemplateEntity>? allWorkouts,
    List<WorkoutTemplateEntity>? filteredWorkouts,
    WorkoutCategory? selectedCategory,
    bool clearCategory = false,
  }) {
    return CatalogLoaded(
      allWorkouts: allWorkouts ?? this.allWorkouts,
      filteredWorkouts: filteredWorkouts ?? this.filteredWorkouts,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}

/// Trạng thái xảy ra lỗi khi tải hoặc thao tác với bài tập
class CatalogError extends WorkoutCatalogState {
  const CatalogError(
    String message, {
    super.allWorkouts,
    super.filteredWorkouts,
    super.selectedCategory,
  }) : super(status: CatalogStatus.error, errorMessage: message);
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────

class WorkoutCatalogBloc extends Bloc<WorkoutCatalogEvent, WorkoutCatalogState> {
  final WorkoutRepository _repository;

  WorkoutCatalogBloc(this._repository) : super(const CatalogLoading()) {
    on<LoadCatalogEvent>(_onLoadCatalog);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<DeleteWorkoutEvent>(_onDeleteWorkout);
    on<DuplicateWorkoutEvent>(_onDuplicateWorkout);
  }

  List<WorkoutTemplateEntity> _applyFilter(
    List<WorkoutTemplateEntity> all,
    WorkoutCategory? category,
  ) {
    if (category == null) return all;
    return all.where((w) => w.category == category).toList();
  }

  Future<void> _onLoadCatalog(
    LoadCatalogEvent event,
    Emitter<WorkoutCatalogState> emit,
  ) async {
    emit(CatalogLoading(
      allWorkouts: state.allWorkouts,
      filteredWorkouts: state.filteredWorkouts,
      selectedCategory: state.selectedCategory,
    ));
    try {
      final all = await _repository.getAllWorkouts();
      final filtered = _applyFilter(all, state.selectedCategory);
      emit(CatalogLoaded(
        allWorkouts: all,
        filteredWorkouts: filtered,
        selectedCategory: state.selectedCategory,
      ));
    } catch (e) {
      emit(CatalogError(
        e.toString(),
        allWorkouts: state.allWorkouts,
        filteredWorkouts: state.filteredWorkouts,
        selectedCategory: state.selectedCategory,
      ));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<WorkoutCatalogState> emit,
  ) async {
    final filtered = _applyFilter(state.allWorkouts, event.category);
    emit(CatalogLoaded(
      allWorkouts: state.allWorkouts,
      filteredWorkouts: filtered,
      selectedCategory: event.category,
    ));
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<WorkoutCatalogState> emit,
  ) async {
    try {
      await _repository.toggleFavorite(event.workoutId, event.isFavorite);
      final all = await _repository.getAllWorkouts();
      final filtered = _applyFilter(all, state.selectedCategory);
      emit(CatalogLoaded(
        allWorkouts: all,
        filteredWorkouts: filtered,
        selectedCategory: state.selectedCategory,
      ));
    } catch (e) {
      emit(CatalogError(
        e.toString(),
        allWorkouts: state.allWorkouts,
        filteredWorkouts: state.filteredWorkouts,
        selectedCategory: state.selectedCategory,
      ));
    }
  }

  Future<void> _onDeleteWorkout(
    DeleteWorkoutEvent event,
    Emitter<WorkoutCatalogState> emit,
  ) async {
    try {
      await _repository.deleteWorkout(event.workoutId);
      final all = await _repository.getAllWorkouts();
      final filtered = _applyFilter(all, state.selectedCategory);
      emit(CatalogLoaded(
        allWorkouts: all,
        filteredWorkouts: filtered,
        selectedCategory: state.selectedCategory,
      ));
    } catch (e) {
      emit(CatalogError(
        e.toString(),
        allWorkouts: state.allWorkouts,
        filteredWorkouts: state.filteredWorkouts,
        selectedCategory: state.selectedCategory,
      ));
    }
  }

  Future<void> _onDuplicateWorkout(
    DuplicateWorkoutEvent event,
    Emitter<WorkoutCatalogState> emit,
  ) async {
    try {
      final original = await _repository.getWorkoutById(event.workoutId);
      if (original == null) return;

      const uuid = Uuid();
      final newWorkoutId = uuid.v4();
      final duplicatedExercises = original.exercises.map((ex) {
        return ExerciseEntity(
          id: uuid.v4(),
          workoutId: newWorkoutId,
          name: ex.name,
          defaultReps: ex.defaultReps,
          holdSeconds: ex.holdSeconds,
          orderIndex: ex.orderIndex,
          notes: ex.notes,
        );
      }).toList();

      final duplicated = original.copyWith(
        id: newWorkoutId,
        name: '${original.name} (Copy)',
        isPreset: false,
        isFavorite: false,
        createdAt: DateTime.now(),
        exercises: duplicatedExercises,
      );

      await _repository.saveWorkout(duplicated);
      final all = await _repository.getAllWorkouts();
      final filtered = _applyFilter(all, state.selectedCategory);
      emit(CatalogLoaded(
        allWorkouts: all,
        filteredWorkouts: filtered,
        selectedCategory: state.selectedCategory,
      ));
    } catch (e) {
      emit(CatalogError(
        e.toString(),
        allWorkouts: state.allWorkouts,
        filteredWorkouts: state.filteredWorkouts,
        selectedCategory: state.selectedCategory,
      ));
    }
  }
}
