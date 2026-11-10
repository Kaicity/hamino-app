/// Định danh bảng và cột cho cơ sở dữ liệu SQLite
class DbConstants {
  DbConstants._();

  static const String databaseName = 'hamino_workout.db';
  static const int databaseVersion = 1;

  // Tên bảng
  static const String tableWorkouts = 'workouts';
  static const String tableExercises = 'exercises';
  static const String tableSessions = 'workout_sessions';

  // Cột bảng workouts
  static const String colWorkoutId = 'id';
  static const String colWorkoutName = 'name';
  static const String colWorkoutCategory = 'category';
  static const String colWorkoutDescription = 'description';
  static const String colWorkoutPrepareSeconds = 'prepare_seconds';
  static const String colWorkoutDefaultRestSeconds = 'default_rest_seconds';
  static const String colWorkoutTimeCapSeconds = 'time_cap_seconds';
  static const String colWorkoutTargetRounds = 'target_rounds';
  static const String colWorkoutIsPreset = 'is_preset';
  static const String colWorkoutIsFavorite = 'is_favorite';
  static const String colWorkoutCreatedAt = 'created_at';

  // Cột bảng exercises
  static const String colExerciseId = 'id';
  static const String colExerciseWorkoutId = 'workout_id';
  static const String colExerciseName = 'name';
  static const String colExerciseDefaultReps = 'default_reps';
  static const String colExerciseHoldSeconds = 'hold_seconds';
  static const String colExerciseOrderIndex = 'order_index';
  static const String colExerciseNotes = 'notes';

  // Cột bảng workout_sessions
  static const String colSessionId = 'id';
  static const String colSessionWorkoutId = 'workout_id';
  static const String colSessionWorkoutName = 'workout_name';
  static const String colSessionStartedAt = 'started_at';
  static const String colSessionFinishedAt = 'finished_at';
  static const String colSessionDurationSeconds = 'duration_seconds';
  static const String colSessionCompletedRounds = 'completed_rounds';
  static const String colSessionRpeScore = 'rpe_score';
  static const String colSessionNotes = 'notes';
}

