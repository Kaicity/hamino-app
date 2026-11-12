import '../../domain/entities/workout_session_record.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../models/workout_session_model.dart';

/// Triển khai [HistoryRepository] kết nối với [HistoryLocalDataSource]
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource _dataSource;

  HistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<WorkoutSessionRecord>> getAllSessions() async {
    return await _dataSource.getAllSessions();
  }

  @override
  Future<WorkoutSessionRecord?> getSessionById(String id) async {
    return await _dataSource.getSessionById(id);
  }

  @override
  Future<void> saveSession(WorkoutSessionRecord session) async {
    final model = session is WorkoutSessionModel
        ? session
        : WorkoutSessionModel.fromEntity(session);
    await _dataSource.saveSession(model);
  }

  @override
  Future<void> deleteSession(String id) async {
    await _dataSource.deleteSession(id);
  }

  @override
  Future<void> clearAllSessions() async {
    await _dataSource.clearAllSessions();
  }
}

