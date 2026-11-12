import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Nạp danh sách lịch sử các buổi tập
class LoadHistoryEvent extends HistoryEvent {
  const LoadHistoryEvent();
}

/// Xóa một buổi tập cụ thể
class DeleteSessionEvent extends HistoryEvent {
  final String id;

  const DeleteSessionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Xóa toàn bộ lịch sử tập luyện
class ClearHistoryEvent extends HistoryEvent {
  const ClearHistoryEvent();
}

