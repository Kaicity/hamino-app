import '../entities/workout_session_record.dart';

/// Hợp đồng lưu trữ và truy vấn lịch sử các buổi tập luyện Hamino
abstract class HistoryRepository {
  /// Lấy toàn bộ lịch sử các buổi tập, sắp xếp theo thời gian mới nhất
  Future<List<WorkoutSessionRecord>> getAllSessions();

  /// Lấy chi tiết một buổi tập theo [id]
  Future<WorkoutSessionRecord?> getSessionById(String id);

  /// Lưu một buổi tập mới vào cơ sở dữ liệu
  Future<void> saveSession(WorkoutSessionRecord session);

  /// Xóa một bản ghi buổi tập theo [id]
  Future<void> deleteSession(String id);

  /// Xóa toàn bộ lịch sử tập luyện
  Future<void> clearAllSessions();
}

