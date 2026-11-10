import 'package:sqflite/sqflite.dart' hide DatabaseException;

import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/workout_category.dart';
import '../../domain/entities/workout_template_entity.dart';
import '../../domain/repositories/workout_repository.dart';
import '../models/exercise_model.dart';
import '../models/workout_template_model.dart';

/// Triển khai thực tế của WorkoutRepository sử dụng SQLite qua DatabaseHelper
class WorkoutRepositoryImpl implements WorkoutRepository {
  final DatabaseHelper databaseHelper;

  WorkoutRepositoryImpl(this.databaseHelper);

  @override
  Future<List<WorkoutTemplateModel>> getAllWorkouts() async {
    try {
      final db = await databaseHelper.database;

      // 1. Lấy tất cả giáo án, ưu tiên bài yêu thích lên đầu
      final workoutMaps = await db.query(
        DbConstants.tableWorkouts,
        orderBy: '${DbConstants.colWorkoutIsFavorite} DESC, ${DbConstants.colWorkoutCreatedAt} DESC',
      );

      if (workoutMaps.isEmpty) {
        return [];
      }

      // 2. Tối ưu truy vấn: Lấy tất cả động tác trong một lần gọi (tránh N+1 queries)
      final exerciseMaps = await db.query(
        DbConstants.tableExercises,
        orderBy: '${DbConstants.colExerciseOrderIndex} ASC',
      );

      // Nhóm bài tập con theo workoutId
      final Map<String, List<ExerciseModel>> exercisesByWorkoutId = {};
      for (final map in exerciseMaps) {
        final exercise = ExerciseModel.fromMap(map);
        exercisesByWorkoutId.putIfAbsent(exercise.workoutId, () => []).add(exercise);
      }

      // 3. Ghép danh sách bài tập con vào từng giáo án
      return workoutMaps.map((map) {
        final workoutId = map[DbConstants.colWorkoutId] as String;
        final exercises = exercisesByWorkoutId[workoutId] ?? [];
        return WorkoutTemplateModel.fromMap(map, exercises: exercises);
      }).toList();
    } catch (e, stackTrace) {
      throw DatabaseException('Lỗi khi tải danh sách giáo án: $e', stackTrace);
    }
  }

  @override
  Future<List<WorkoutTemplateModel>> getWorkoutsByCategory(WorkoutCategory category) async {
    try {
      final db = await databaseHelper.database;

      final workoutMaps = await db.query(
        DbConstants.tableWorkouts,
        where: '${DbConstants.colWorkoutCategory} = ?',
        whereArgs: [category.name],
        orderBy: '${DbConstants.colWorkoutIsFavorite} DESC, ${DbConstants.colWorkoutCreatedAt} DESC',
      );

      if (workoutMaps.isEmpty) {
        return [];
      }

      final workoutIds = workoutMaps.map((m) => m[DbConstants.colWorkoutId] as String).toList();
      final placeholders = List.filled(workoutIds.length, '?').join(',');

      final exerciseMaps = await db.query(
        DbConstants.tableExercises,
        where: '${DbConstants.colExerciseWorkoutId} IN ($placeholders)',
        whereArgs: workoutIds,
        orderBy: '${DbConstants.colExerciseOrderIndex} ASC',
      );

      final Map<String, List<ExerciseModel>> exercisesByWorkoutId = {};
      for (final map in exerciseMaps) {
        final exercise = ExerciseModel.fromMap(map);
        exercisesByWorkoutId.putIfAbsent(exercise.workoutId, () => []).add(exercise);
      }

      return workoutMaps.map((map) {
        final workoutId = map[DbConstants.colWorkoutId] as String;
        final exercises = exercisesByWorkoutId[workoutId] ?? [];
        return WorkoutTemplateModel.fromMap(map, exercises: exercises);
      }).toList();
    } catch (e, stackTrace) {
      throw DatabaseException('Lỗi khi lọc giáo án theo thể loại ${category.displayName}: $e', stackTrace);
    }
  }

  @override
  Future<WorkoutTemplateModel?> getWorkoutById(String id) async {
    try {
      final db = await databaseHelper.database;

      final workoutMaps = await db.query(
        DbConstants.tableWorkouts,
        where: '${DbConstants.colWorkoutId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (workoutMaps.isEmpty) {
        return null;
      }

      final exerciseMaps = await db.query(
        DbConstants.tableExercises,
        where: '${DbConstants.colExerciseWorkoutId} = ?',
        whereArgs: [id],
        orderBy: '${DbConstants.colExerciseOrderIndex} ASC',
      );

      final exercises = exerciseMaps.map(ExerciseModel.fromMap).toList();
      return WorkoutTemplateModel.fromMap(workoutMaps.first, exercises: exercises);
    } catch (e, stackTrace) {
      throw DatabaseException('Lỗi khi tìm giáo án ID $id: $e', stackTrace);
    }
  }

  @override
  Future<void> saveWorkout(WorkoutTemplateEntity workout) async {
    try {
      final db = await databaseHelper.database;
      final model = workout is WorkoutTemplateModel
          ? workout
          : WorkoutTemplateModel.fromEntity(workout);

      await db.transaction((txn) async {
        // 1. Chèn hoặc cập nhật thông tin bảng workouts
        await txn.insert(
          DbConstants.tableWorkouts,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // 2. Xóa các bài tập con cũ của giáo án này
        await txn.delete(
          DbConstants.tableExercises,
          where: '${DbConstants.colExerciseWorkoutId} = ?',
          whereArgs: [model.id],
        );

        // 3. Chèn lại danh sách bài tập con mới
        for (int i = 0; i < model.exercises.length; i++) {
          final exercise = model.exercises[i];
          final exerciseToInsert = exercise.orderIndex == i
              ? exercise
              : exercise.copyWith(orderIndex: i);

          await txn.insert(
            DbConstants.tableExercises,
            exerciseToInsert.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e, stackTrace) {
      throw DatabaseException('Lỗi khi lưu giáo án ${workout.name}: $e', stackTrace);
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    try {
      final db = await databaseHelper.database;

      await db.transaction((txn) async {
        // Xóa bài tập con trước để đảm bảo tính toàn vẹn (ngay cả khi SQLite tắt PRAGMA foreign_keys)
        await txn.delete(
          DbConstants.tableExercises,
          where: '${DbConstants.colExerciseWorkoutId} = ?',
          whereArgs: [id],
        );

        await txn.delete(
          DbConstants.tableWorkouts,
          where: '${DbConstants.colWorkoutId} = ?',
          whereArgs: [id],
        );
      });
    } catch (e, stackTrace) {
      throw DatabaseException('Lỗi khi xóa giáo án ID $id: $e', stackTrace);
    }
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      final db = await databaseHelper.database;

      await db.update(
        DbConstants.tableWorkouts,
        {DbConstants.colWorkoutIsFavorite: isFavorite ? 1 : 0},
        where: '${DbConstants.colWorkoutId} = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      throw DatabaseException('Lỗi khi cập nhật trạng thái yêu thích: $e', stackTrace);
    }
  }
}
