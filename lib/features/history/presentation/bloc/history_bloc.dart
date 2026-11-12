import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/history_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

/// BLoC quản lý trạng thái tải và xóa lịch sử buổi tập
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _historyRepository;

  HistoryBloc(this._historyRepository) : super(const HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<DeleteSessionEvent>(_onDeleteSession);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      final sessions = await _historyRepository.getAllSessions();
      emit(HistoryLoaded(sessions));
    } catch (e) {
      emit(HistoryError('Không thể tải lịch sử tập luyện: $e'));
    }
  }

  Future<void> _onDeleteSession(
    DeleteSessionEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _historyRepository.deleteSession(event.id);
      final sessions = await _historyRepository.getAllSessions();
      emit(HistoryLoaded(sessions));
    } catch (e) {
      emit(HistoryError('Không thể xóa buổi tập: $e'));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _historyRepository.clearAllSessions();
      emit(const HistoryLoaded([]));
    } catch (e) {
      emit(HistoryError('Không thể xóa toàn bộ lịch sử: $e'));
    }
  }
}

