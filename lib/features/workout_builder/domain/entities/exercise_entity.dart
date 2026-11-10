import 'package:equatable/equatable.dart';

/// Thực thể động tác trong bài tập Calisthenics
class ExerciseEntity extends Equatable {
  final String id;
  final String workoutId;
  final String name;
  final int defaultReps;
  final int holdSeconds;
  final int orderIndex;
  final String? notes;

  const ExerciseEntity({
    required this.id,
    required this.workoutId,
    required this.name,
    this.defaultReps = 10,
    this.holdSeconds = 0,
    required this.orderIndex,
    this.notes,
  });

  /// Kiểm tra xem động tác là bài giữ tĩnh (Static Hold như Handstand, Plank) hay bài lặp reps
  bool get isStaticHold => holdSeconds > 0 && defaultReps == 0;

  /// Chuỗi hiển thị tóm tắt mục tiêu (VD: "10 reps", "30s hold", "10 reps (30s)")
  String get targetSummary {
    if (isStaticHold) {
      return '${holdSeconds}s hold';
    } else if (holdSeconds > 0) {
      return '$defaultReps reps (${holdSeconds}s)';
    } else {
      return '$defaultReps reps';
    }
  }

  /// Tạo bản sao với các thuộc tính thay đổi
  ExerciseEntity copyWith({
    String? id,
    String? workoutId,
    String? name,
    int? defaultReps,
    int? holdSeconds,
    int? orderIndex,
    String? notes,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      defaultReps: defaultReps ?? this.defaultReps,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutId,
        name,
        defaultReps,
        holdSeconds,
        orderIndex,
        notes,
      ];
}

