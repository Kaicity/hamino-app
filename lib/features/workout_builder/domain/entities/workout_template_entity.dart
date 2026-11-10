import 'package:equatable/equatable.dart';

import 'exercise_entity.dart';
import 'workout_category.dart';

/// Thực thể giáo án bài tập Calisthenics
class WorkoutTemplateEntity extends Equatable {
  final String id;
  final String name;
  final WorkoutCategory category;
  final String? description;
  final int prepareSeconds;
  final int defaultRestSeconds;
  final int timeCapSeconds;
  final int targetRounds;
  final bool isPreset;
  final bool isFavorite;
  final DateTime createdAt;
  final List<ExerciseEntity> exercises;

  const WorkoutTemplateEntity({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.prepareSeconds = 10,
    this.defaultRestSeconds = 60,
    this.timeCapSeconds = 0,
    this.targetRounds = 1,
    this.isPreset = false,
    this.isFavorite = false,
    required this.createdAt,
    this.exercises = const [],
  });

  /// Tổng số động tác con trong một vòng
  int get totalExercises => exercises.length;

  /// Có giới hạn thời gian (Time Cap) hay không
  bool get hasTimeCap => timeCapSeconds > 0;

  /// Chuỗi hiển thị nhanh giới hạn thời gian (VD: "20:00" hoặc "Không giới hạn")
  String get timeCapDisplay {
    if (!hasTimeCap) return 'Không giới hạn';
    final minutes = timeCapSeconds ~/ 60;
    final seconds = timeCapSeconds % 60;
    if (seconds == 0) {
      return '$minutes phút';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Tạo bản sao cập nhật trạng thái
  WorkoutTemplateEntity copyWith({
    String? id,
    String? name,
    WorkoutCategory? category,
    String? description,
    int? prepareSeconds,
    int? defaultRestSeconds,
    int? timeCapSeconds,
    int? targetRounds,
    bool? isPreset,
    bool? isFavorite,
    DateTime? createdAt,
    List<ExerciseEntity>? exercises,
  }) {
    return WorkoutTemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      prepareSeconds: prepareSeconds ?? this.prepareSeconds,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      timeCapSeconds: timeCapSeconds ?? this.timeCapSeconds,
      targetRounds: targetRounds ?? this.targetRounds,
      isPreset: isPreset ?? this.isPreset,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        description,
        prepareSeconds,
        defaultRestSeconds,
        timeCapSeconds,
        targetRounds,
        isPreset,
        isFavorite,
        createdAt,
        exercises,
      ];
}

