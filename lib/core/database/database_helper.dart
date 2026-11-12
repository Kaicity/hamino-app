import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' hide DatabaseException;

import '../constants/db_constants.dart';
import '../error/exceptions.dart';
import 'preset_workouts_data.dart';

/// Lớp điều phối kết nối và quản lý cơ sở dữ liệu SQLite cục bộ (100% Offline)
class DatabaseHelper {
  static Database? _database;
  final String dbName;

  DatabaseHelper({this.dbName = DbConstants.databaseName});

  /// Lấy instance Database đang mở hoặc khởi tạo mới
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Khởi tạo và mở kết nối đến SQLite
  Future<Database> _initDatabase() async {
    try {
      final String fullPath;
      if (dbName == inMemoryDatabasePath) {
        fullPath = inMemoryDatabasePath;
      } else {
        final dbPath = await getDatabasesPath();
        fullPath = p.join(dbPath, dbName);
      }

      return await openDatabase(
        fullPath,
        version: DbConstants.databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        'Khởi tạo cơ sở dữ liệu SQLite thất bại: $e',
        stackTrace,
      );
    }
  }

  /// Bật ràng buộc khóa ngoại (Foreign Keys) trong SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  /// Tạo cấu trúc bảng và chèn dữ liệu Preset mẫu trong lần đầu chạy ứng dụng
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // 1. Tạo bảng workouts
    batch.execute('''
      CREATE TABLE ${DbConstants.tableWorkouts} (
        ${DbConstants.colWorkoutId} TEXT PRIMARY KEY,
        ${DbConstants.colWorkoutName} TEXT NOT NULL,
        ${DbConstants.colWorkoutCategory} TEXT NOT NULL,
        ${DbConstants.colWorkoutDescription} TEXT,
        ${DbConstants.colWorkoutPrepareSeconds} INTEGER DEFAULT 10,
        ${DbConstants.colWorkoutDefaultRestSeconds} INTEGER DEFAULT 60,
        ${DbConstants.colWorkoutTimeCapSeconds} INTEGER DEFAULT 0,
        ${DbConstants.colWorkoutTargetRounds} INTEGER DEFAULT 1,
        ${DbConstants.colWorkoutIsPreset} INTEGER DEFAULT 0,
        ${DbConstants.colWorkoutIsFavorite} INTEGER DEFAULT 0,
        ${DbConstants.colWorkoutCreatedAt} TEXT NOT NULL
      );
    ''');

    // 2. Tạo bảng exercises với Foreign Key ON DELETE CASCADE
    batch.execute('''
      CREATE TABLE ${DbConstants.tableExercises} (
        ${DbConstants.colExerciseId} TEXT PRIMARY KEY,
        ${DbConstants.colExerciseWorkoutId} TEXT NOT NULL,
        ${DbConstants.colExerciseName} TEXT NOT NULL,
        ${DbConstants.colExerciseDefaultReps} INTEGER DEFAULT 10,
        ${DbConstants.colExerciseHoldSeconds} INTEGER DEFAULT 0,
        ${DbConstants.colExerciseOrderIndex} INTEGER NOT NULL,
        ${DbConstants.colExerciseNotes} TEXT,
        FOREIGN KEY (${DbConstants.colExerciseWorkoutId}) 
          REFERENCES ${DbConstants.tableWorkouts} (${DbConstants.colWorkoutId}) 
          ON DELETE CASCADE
      );
    ''');

    // 3. Tạo bảng workout_sessions ghi nhận lịch sử tập luyện
    batch.execute('''
      CREATE TABLE ${DbConstants.tableSessions} (
        ${DbConstants.colSessionId} TEXT PRIMARY KEY,
        ${DbConstants.colSessionWorkoutId} TEXT NOT NULL,
        ${DbConstants.colSessionWorkoutName} TEXT NOT NULL,
        ${DbConstants.colSessionStartedAt} TEXT NOT NULL,
        ${DbConstants.colSessionFinishedAt} TEXT NOT NULL,
        ${DbConstants.colSessionDurationSeconds} INTEGER NOT NULL,
        ${DbConstants.colSessionCompletedRounds} INTEGER NOT NULL,
        ${DbConstants.colSessionRpeScore} INTEGER,
        ${DbConstants.colSessionNotes} TEXT
      );
    ''');

    // 4. Tạo các chỉ mục (Indexes) để tăng tốc độ truy vấn
    batch.execute('''
      CREATE INDEX idx_exercises_workout_id 
      ON ${DbConstants.tableExercises} (${DbConstants.colExerciseWorkoutId});
    ''');

    batch.execute('''
      CREATE INDEX idx_sessions_workout_id 
      ON ${DbConstants.tableSessions} (${DbConstants.colSessionWorkoutId});
    ''');

    await batch.commit(noResult: true);

    // 5. Nạp sẵn 4 giáo án Calisthenics chuẩn (Seed Presets)
    await _seedPresetWorkouts(db);
  }

  /// Nạp danh sách giáo án Calisthenics mẫu vào database
  Future<void> _seedPresetWorkouts(Database db) async {
    final batch = db.batch();
    for (final preset in PresetWorkoutsData.presets) {
      batch.insert(
        DbConstants.tableWorkouts,
        preset.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final exercise in preset.exercises) {
        batch.insert(
          DbConstants.tableExercises,
          exercise.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    await batch.commit(noResult: true);
  }

  /// Nạp lại dữ liệu preset mẫu nếu cần thiết (ví dụ khi khôi phục cài đặt)
  Future<void> seedPresets() async {
    final db = await database;
    await _seedPresetWorkouts(db);
  }

  /// Đóng kết nối cơ sở dữ liệu
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// Xóa toàn bộ dữ liệu (chỉ dùng cho testing hoặc factory reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(DbConstants.tableExercises);
      await txn.delete(DbConstants.tableWorkouts);
      await txn.delete(DbConstants.tableSessions);
    });
  }
}
