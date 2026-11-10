import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/exercise_entity.dart';

/// Data Model đại diện cho một động tác trong database SQLite
class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    required super.id,
    required super.workoutId,
    required super.name,
    super.defaultReps = 10,
    super.holdSeconds = 0,
    required super.orderIndex,
    super.notes,
  });

  /// Khởi tạo Model từ Thực thể Domain
  factory ExerciseModel.fromEntity(ExerciseEntity entity) {
    return ExerciseModel(
      id: entity.id,
      workoutId: entity.workoutId,
      name: entity.name,
      defaultReps: entity.defaultReps,
      holdSeconds: entity.holdSeconds,
      orderIndex: entity.orderIndex,
      notes: entity.notes,
    );
  }

  /// Khởi tạo từ Map đọc ra từ SQLite
  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map[DbConstants.colExerciseId] as String,
      workoutId: map[DbConstants.colExerciseWorkoutId] as String,
      name: map[DbConstants.colExerciseName] as String,
      defaultReps: (map[DbConstants.colExerciseDefaultReps] as num?)?.toInt() ?? 10,
      holdSeconds: (map[DbConstants.colExerciseHoldSeconds] as num?)?.toInt() ?? 0,
      orderIndex: (map[DbConstants.colExerciseOrderIndex] as num?)?.toInt() ?? 0,
      notes: map[DbConstants.colExerciseNotes] as String?,
    );
  }

  /// Chuyển đổi thành Map để ghi vào SQLite
  Map<String, dynamic> toMap() {
    return {
      DbConstants.colExerciseId: id,
      DbConstants.colExerciseWorkoutId: workoutId,
      DbConstants.colExerciseName: name,
      DbConstants.colExerciseDefaultReps: defaultReps,
      DbConstants.colExerciseHoldSeconds: holdSeconds,
      DbConstants.colExerciseOrderIndex: orderIndex,
      DbConstants.colExerciseNotes: notes,
    };
  }

  @override
  ExerciseModel copyWith({
    String? id,
    String? workoutId,
    String? name,
    int? defaultReps,
    int? holdSeconds,
    int? orderIndex,
    String? notes,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      defaultReps: defaultReps ?? this.defaultReps,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
    );
  }
}

