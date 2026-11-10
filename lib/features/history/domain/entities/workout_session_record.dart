import 'package:equatable/equatable.dart';

/// Thực thể ghi nhận một buổi tập đã hoàn thành trong lịch sử
class WorkoutSessionRecord extends Equatable {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int durationSeconds;
  final int completedRounds;
  final int? rpeScore; // Đánh giá cảm nhận độ khó (1-10)
  final String? notes;

  const WorkoutSessionRecord({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.startedAt,
    required this.finishedAt,
    required this.durationSeconds,
    required this.completedRounds,
    this.rpeScore,
    this.notes,
  });

  /// Tạo bản sao cập nhật trạng thái
  WorkoutSessionRecord copyWith({
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
    return WorkoutSessionRecord(
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

  @override
  List<Object?> get props => [
        id,
        workoutId,
        workoutName,
        startedAt,
        finishedAt,
        durationSeconds,
        completedRounds,
        rpeScore,
        notes,
      ];
}

