import 'package:uuid/uuid.dart';

import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_category.dart';

/// Model biểu diễn bài tập được trích xuất từ Gemini AI
class AiParsedWorkout {
  final String name;
  final WorkoutCategory category;
  final String? description;
  final int prepareSeconds;
  final int defaultRestSeconds;
  final int timeCapSeconds;
  final int targetRounds;
  final List<AiParsedExercise> exercises;

  const AiParsedWorkout({
    required this.name,
    required this.category,
    this.description,
    this.prepareSeconds = 10,
    this.defaultRestSeconds = 60,
    this.timeCapSeconds = 0,
    this.targetRounds = 1,
    required this.exercises,
  });

  /// Chuyển đổi sang danh sách `ExerciseEntity` phù hợp với schema của ứng dụng
  List<ExerciseEntity> toExerciseEntities(String workoutId) {
    const uuid = Uuid();
    return exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final ex = entry.value;
      return ExerciseEntity(
        id: uuid.v4(),
        workoutId: workoutId,
        name: ex.name.trim(),
        defaultReps: ex.defaultReps,
        holdSeconds: ex.holdSeconds,
        orderIndex: index,
        notes: ex.notes?.trim().isEmpty == true ? null : ex.notes?.trim(),
      );
    }).toList();
  }

  /// Parse từ JSON map trả về từ Gemini
  factory AiParsedWorkout.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category']?.toString();
    final parsedCategory = WorkoutCategory.fromString(rawCategory);

    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    final exercises = rawExercises
        .map((e) => AiParsedExercise.fromJson(e as Map<String, dynamic>))
        .toList();

    return AiParsedWorkout(
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : 'Bài tập mới (AI)',
      category: parsedCategory,
      description: json['description'] as String?,
      prepareSeconds: (json['prepareSeconds'] as num?)?.toInt() ?? 10,
      defaultRestSeconds: (json['defaultRestSeconds'] as num?)?.toInt() ?? 60,
      timeCapSeconds: (json['timeCapSeconds'] as num?)?.toInt() ?? 0,
      targetRounds: ((json['targetRounds'] as num?)?.toInt() ?? 1).clamp(1, 100),
      exercises: exercises,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.name,
      'description': description,
      'prepareSeconds': prepareSeconds,
      'defaultRestSeconds': defaultRestSeconds,
      'timeCapSeconds': timeCapSeconds,
      'targetRounds': targetRounds,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model biểu diễn từng động tác do AI phân tích
class AiParsedExercise {
  final String name;
  final int defaultReps;
  final int holdSeconds;
  final String? notes;

  const AiParsedExercise({
    required this.name,
    this.defaultReps = 10,
    this.holdSeconds = 0,
    this.notes,
  });

  bool get isHold => holdSeconds > 0 && defaultReps == 0;

  factory AiParsedExercise.fromJson(Map<String, dynamic> json) {
    var reps = (json['defaultReps'] as num?)?.toInt() ?? 0;
    var hold = (json['holdSeconds'] as num?)?.toInt() ?? 0;

    // Nếu cả 2 đều bằng 0, mặc định cho 10 reps
    if (reps <= 0 && hold <= 0) {
      reps = 10;
    }

    return AiParsedExercise(
      name: (json['name'] as String?)?.trim() ?? 'Động tác',
      defaultReps: reps < 0 ? 0 : reps,
      holdSeconds: hold < 0 ? 0 : hold,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'defaultReps': defaultReps,
      'holdSeconds': holdSeconds,
      'notes': notes,
    };
  }
}

