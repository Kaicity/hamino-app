import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/database/preset_workouts_data.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/repositories/workout_repository.dart';
import 'package:hamino_app/features/workout_builder/presentation/bloc/workout_catalog_bloc.dart';

class MockWorkoutRepository implements WorkoutRepository {
  List<WorkoutTemplateEntity> items = List.from(PresetWorkoutsData.presets);

  @override
  Future<List<WorkoutTemplateEntity>> getAllWorkouts() async => List.from(items);

  @override
  Future<List<WorkoutTemplateEntity>> getWorkoutsByCategory(WorkoutCategory category) async {
    return items.where((w) => w.category == category).toList();
  }

  @override
  Future<WorkoutTemplateEntity?> getWorkoutById(String id) async {
    return items.cast<WorkoutTemplateEntity?>().firstWhere(
          (w) => w?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<void> saveWorkout(WorkoutTemplateEntity workout) async {
    final idx = items.indexWhere((w) => w.id == workout.id);
    if (idx >= 0) {
      items[idx] = workout;
    } else {
      items.add(workout);
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    items.removeWhere((w) => w.id == id);
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final idx = items.indexWhere((w) => w.id == id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(isFavorite: isFavorite);
    }
  }
}

void main() {
  late MockWorkoutRepository repository;
  late WorkoutCatalogBloc bloc;

  setUp(() {
    repository = MockWorkoutRepository();
    bloc = WorkoutCatalogBloc(repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('WorkoutCatalogBloc Tests (TASK-2.1)', () {
    test('Initial state is CatalogLoading', () {
      expect(bloc.state, isA<CatalogLoading>());
      expect(bloc.state.status, CatalogStatus.loading);
    });

    test('LoadCatalogEvent loads all workouts and emits CatalogLoaded', () async {
      bloc.add(const LoadCatalogEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CatalogLoading>(),
          predicate<CatalogLoaded>((state) {
            return state.allWorkouts.length == 4 &&
                state.filteredWorkouts.length == 4 &&
                state.selectedCategory == null;
          }),
        ]),
      );
    });

    test('FilterByCategoryEvent filters workouts by category properly', () async {
      bloc.add(const LoadCatalogEvent());
      await bloc.stream.firstWhere((s) => s is CatalogLoaded);

      bloc.add(const FilterByCategoryEvent(WorkoutCategory.skill));

      await expectLater(
        bloc.stream,
        emits(predicate<CatalogLoaded>((state) {
          return state.selectedCategory == WorkoutCategory.skill &&
              state.filteredWorkouts.length == 1 &&
              state.filteredWorkouts.first.name == 'Skill Handstand Mastery';
        })),
      );

      // Reset filter to All
      bloc.add(const FilterByCategoryEvent(null));

      await expectLater(
        bloc.stream,
        emits(predicate<CatalogLoaded>((state) {
          return state.selectedCategory == null &&
              state.filteredWorkouts.length == 4;
        })),
      );
    });

    test('ToggleFavoriteEvent updates favorite status', () async {
      bloc.add(const LoadCatalogEvent());
      await bloc.stream.firstWhere((s) => s is CatalogLoaded);

      final workoutId = repository.items.first.id;
      bloc.add(ToggleFavoriteEvent(workoutId, true));

      await expectLater(
        bloc.stream,
        emits(predicate<CatalogLoaded>((state) {
          final target = state.allWorkouts.firstWhere((w) => w.id == workoutId);
          return target.isFavorite == true;
        })),
      );
    });

    test('DuplicateWorkoutEvent creates a copy with new id and (Copy) in name', () async {
      bloc.add(const LoadCatalogEvent());
      await bloc.stream.firstWhere((s) => s is CatalogLoaded);

      final originalId = repository.items.first.id;
      final originalName = repository.items.first.name;

      bloc.add(DuplicateWorkoutEvent(originalId));

      await expectLater(
        bloc.stream,
        emits(predicate<CatalogLoaded>((state) {
          final duplicated = state.allWorkouts.where(
            (w) => w.name == '$originalName (Copy)',
          );
          return state.allWorkouts.length == 5 && duplicated.isNotEmpty;
        })),
      );
    });

    test('DeleteWorkoutEvent removes workout from repository and state', () async {
      bloc.add(const LoadCatalogEvent());
      await bloc.stream.firstWhere((s) => s is CatalogLoaded);

      final workoutToDelete = repository.items.first.id;

      bloc.add(DeleteWorkoutEvent(workoutToDelete));

      await expectLater(
        bloc.stream,
        emits(predicate<CatalogLoaded>((state) {
          final exists = state.allWorkouts.any((w) => w.id == workoutToDelete);
          return state.allWorkouts.length == 3 && !exists;
        })),
      );
    });
  });
}

