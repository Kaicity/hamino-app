import 'package:sqflite/sqflite.dart' hide DatabaseException;

import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_session_model.dart';

/// Giao diện nguồn dữ liệu cục bộ cho lịch sử buổi tập
abstract class HistoryLocalDataSource {
  Future<List<WorkoutSessionModel>> getAllSessions();
  Future<WorkoutSessionModel?> getSessionById(String id);
  Future<void> saveSession(WorkoutSessionModel session);
  Future<void> deleteSession(String id);
  Future<void> clearAllSessions();
}

/// Hiện thực nguồn dữ liệu cục bộ sử dụng SQLite qua [DatabaseHelper]
class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final DatabaseHelper _databaseHelper;

  HistoryLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<WorkoutSessionModel>> getAllSessions() async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        DbConstants.tableSessions,
        orderBy: '${DbConstants.colSessionStartedAt} DESC',
      );

      return results.map((map) => WorkoutSessionModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw DatabaseException(
        'Lỗi khi tải lịch sử buổi tập: $e',
        stackTrace,
      );
    }
  }

  @override
  Future<WorkoutSessionModel?> getSessionById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        DbConstants.tableSessions,
        where: '${DbConstants.colSessionId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) return null;
      return WorkoutSessionModel.fromMap(results.first);
    } catch (e, stackTrace) {
      throw DatabaseException(
        'Lỗi khi tìm buổi tập ID $id: $e',
        stackTrace,
      );
    }
  }

  @override
  Future<void> saveSession(WorkoutSessionModel session) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        DbConstants.tableSessions,
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        'Lỗi khi lưu kết quả buổi tập: $e',
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        DbConstants.tableSessions,
        where: '${DbConstants.colSessionId} = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        'Lỗi khi xóa bản ghi lịch sử ID $id: $e',
        stackTrace,
      );
    }
  }

  @override
  Future<void> clearAllSessions() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(DbConstants.tableSessions);
    } catch (e, stackTrace) {
      throw DatabaseException(
        'Lỗi khi xóa toàn bộ lịch sử buổi tập: $e',
        stackTrace,
      );
    }
  }
}

