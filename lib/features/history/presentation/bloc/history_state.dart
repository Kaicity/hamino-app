import 'package:equatable/equatable.dart';

import '../../domain/entities/workout_session_record.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<WorkoutSessionRecord> sessions;

  const HistoryLoaded(this.sessions);

  /// Tổng số buổi tập đã hoàn thành
  int get totalSessions => sessions.length;

  /// Tổng thời lượng tập luyện tích lũy (giây)
  int get totalDurationSeconds =>
      sessions.fold(0, (sum, s) => sum + s.durationSeconds);

  /// Tổng thời lượng tập luyện tích lũy (phút)
  int get totalDurationMinutes => (totalDurationSeconds / 60).round();

  /// Số buổi tập trong tuần hiện tại (tính từ Thứ 2)
  int get workoutsThisWeekCount {
    final now = DateTime.now();
    // Tìm ngày đầu tuần (Thứ 2)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    return sessions.where((s) => s.startedAt.isAfter(startOfWeek)).length;
  }

  /// Tổng số phút tập luyện trong tuần hiện tại
  int get minutesThisWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final secondsThisWeek = sessions
        .where((s) => s.startedAt.isAfter(startOfWeek))
        .fold(0, (sum, s) => sum + s.durationSeconds);

    return (secondsThisWeek / 60).round();
  }

  @override
  List<Object?> get props => [sessions];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

