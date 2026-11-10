import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_category.dart';
import '../../domain/entities/workout_template_entity.dart';
import 'exercise_model.dart';

/// Data Model đại diện cho giáo án bài tập trong SQLite
class WorkoutTemplateModel extends WorkoutTemplateEntity {
  const WorkoutTemplateModel({
    required super.id,
    required super.name,
    required super.category,
    super.description,
    super.prepareSeconds = 10,
    super.defaultRestSeconds = 60,
    super.timeCapSeconds = 0,
    super.targetRounds = 1,
    super.isPreset = false,
    super.isFavorite = false,
    required super.createdAt,
    super.exercises = const [],
  });

  @override
  List<ExerciseModel> get exercises =>
      super.exercises.map((e) => e is ExerciseModel ? e : ExerciseModel.fromEntity(e)).toList();

  /// Chuyển đổi từ Thực thể Domain sang Data Model
  factory WorkoutTemplateModel.fromEntity(WorkoutTemplateEntity entity) {
    return WorkoutTemplateModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      description: entity.description,
      prepareSeconds: entity.prepareSeconds,
      defaultRestSeconds: entity.defaultRestSeconds,
      timeCapSeconds: entity.timeCapSeconds,
      targetRounds: entity.targetRounds,
      isPreset: entity.isPreset,
      isFavorite: entity.isFavorite,
      createdAt: entity.createdAt,
      exercises: entity.exercises
          .map((e) => e is ExerciseModel ? e : ExerciseModel.fromEntity(e))
          .toList(),
    );
  }

  /// Khởi tạo Model từ Map đọc từ SQLite
  factory WorkoutTemplateModel.fromMap(
    Map<String, dynamic> map, {
    List<ExerciseModel> exercises = const [],
  }) {
    return WorkoutTemplateModel(
      id: map[DbConstants.colWorkoutId] as String,
      name: map[DbConstants.colWorkoutName] as String,
      category: WorkoutCategory.fromString(map[DbConstants.colWorkoutCategory] as String?),
      description: map[DbConstants.colWorkoutDescription] as String?,
      prepareSeconds: (map[DbConstants.colWorkoutPrepareSeconds] as num?)?.toInt() ?? 10,
      defaultRestSeconds: (map[DbConstants.colWorkoutDefaultRestSeconds] as num?)?.toInt() ?? 60,
      timeCapSeconds: (map[DbConstants.colWorkoutTimeCapSeconds] as num?)?.toInt() ?? 0,
      targetRounds: (map[DbConstants.colWorkoutTargetRounds] as num?)?.toInt() ?? 1,
      isPreset: (map[DbConstants.colWorkoutIsPreset] as num?) == 1,
      isFavorite: (map[DbConstants.colWorkoutIsFavorite] as num?) == 1,
      createdAt: DateTime.tryParse(map[DbConstants.colWorkoutCreatedAt] as String? ?? '') ??
          DateTime.now(),
      exercises: exercises,
    );
  }

  /// Chuyển đổi thành Map để ghi vào SQLite (chỉ chứa các trường của bảng workouts)
  Map<String, dynamic> toMap() {
    return {
      DbConstants.colWorkoutId: id,
      DbConstants.colWorkoutName: name,
      DbConstants.colWorkoutCategory: category.name,
      DbConstants.colWorkoutDescription: description,
      DbConstants.colWorkoutPrepareSeconds: prepareSeconds,
      DbConstants.colWorkoutDefaultRestSeconds: defaultRestSeconds,
      DbConstants.colWorkoutTimeCapSeconds: timeCapSeconds,
      DbConstants.colWorkoutTargetRounds: targetRounds,
      DbConstants.colWorkoutIsPreset: isPreset ? 1 : 0,
      DbConstants.colWorkoutIsFavorite: isFavorite ? 1 : 0,
      DbConstants.colWorkoutCreatedAt: createdAt.toIso8601String(),
    };
  }

  @override
  WorkoutTemplateModel copyWith({
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
    return WorkoutTemplateModel(
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
      exercises: exercises != null
          ? exercises
              .map((e) => e is ExerciseModel ? e : ExerciseModel.fromEntity(e))
              .toList()
          : this.exercises,
    );
  }
}
