import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/workout_session_record.dart';

/// Data Model đại diện cho một buổi tập trong cơ sở dữ liệu SQLite
class WorkoutSessionModel extends WorkoutSessionRecord {
  const WorkoutSessionModel({
    required super.id,
    required super.workoutId,
    required super.workoutName,
    required super.startedAt,
    required super.finishedAt,
    required super.durationSeconds,
    required super.completedRounds,
    super.rpeScore,
    super.notes,
  });

  /// Khởi tạo Model từ Thực thể Domain
  factory WorkoutSessionModel.fromEntity(WorkoutSessionRecord entity) {
    return WorkoutSessionModel(
      id: entity.id,
      workoutId: entity.workoutId,
      workoutName: entity.workoutName,
      startedAt: entity.startedAt,
      finishedAt: entity.finishedAt,
      durationSeconds: entity.durationSeconds,
      completedRounds: entity.completedRounds,
      rpeScore: entity.rpeScore,
      notes: entity.notes,
    );
  }

  /// Khởi tạo Model từ Map đọc ra từ bảng workout_sessions
  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionModel(
      id: map[DbConstants.colSessionId] as String,
      workoutId: map[DbConstants.colSessionWorkoutId] as String,
      workoutName: map[DbConstants.colSessionWorkoutName] as String,
      startedAt: DateTime.tryParse(map[DbConstants.colSessionStartedAt] as String? ?? '') ??
          DateTime.now(),
      finishedAt: DateTime.tryParse(map[DbConstants.colSessionFinishedAt] as String? ?? '') ??
          DateTime.now(),
      durationSeconds: (map[DbConstants.colSessionDurationSeconds] as num?)?.toInt() ?? 0,
      completedRounds: (map[DbConstants.colSessionCompletedRounds] as num?)?.toInt() ?? 0,
      rpeScore: (map[DbConstants.colSessionRpeScore] as num?)?.toInt(),
      notes: map[DbConstants.colSessionNotes] as String?,
    );
  }

  /// Chuyển đổi thành Map để ghi vào bảng workout_sessions
  Map<String, dynamic> toMap() {
    return {
      DbConstants.colSessionId: id,
      DbConstants.colSessionWorkoutId: workoutId,
      DbConstants.colSessionWorkoutName: workoutName,
      DbConstants.colSessionStartedAt: startedAt.toIso8601String(),
      DbConstants.colSessionFinishedAt: finishedAt.toIso8601String(),
      DbConstants.colSessionDurationSeconds: durationSeconds,
      DbConstants.colSessionCompletedRounds: completedRounds,
      DbConstants.colSessionRpeScore: rpeScore,
      DbConstants.colSessionNotes: notes,
    };
  }

  @override
  WorkoutSessionModel copyWith({
    String? id,
    String? workoutId,
    String? workoutName,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? durationSeconds,
    int? completedRounds,
    int? rpeScore,
    String? notes,
  }) {
    return WorkoutSessionModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedRounds: completedRounds ?? this.completedRounds,
      rpeScore: rpeScore ?? this.rpeScore,
      notes: notes ?? this.notes,
    );
  }
}

