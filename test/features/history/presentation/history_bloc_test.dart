import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/features/history/domain/entities/workout_session_record.dart';
import 'package:hamino_app/features/history/domain/repositories/history_repository.dart';
import 'package:hamino_app/features/history/presentation/bloc/history_bloc.dart';
import 'package:hamino_app/features/history/presentation/bloc/history_event.dart';
import 'package:hamino_app/features/history/presentation/bloc/history_state.dart';

class FakeHistoryRepository implements HistoryRepository {
  final List<WorkoutSessionRecord> _storage = [];

  @override
  Future<List<WorkoutSessionRecord>> getAllSessions() async {
    return List.from(_storage);
  }

  @override
  Future<WorkoutSessionRecord?> getSessionById(String id) async {
    return _storage.where((s) => s.id == id).firstOrNull;
  }

  @override
  Future<void> saveSession(WorkoutSessionRecord session) async {
    _storage.removeWhere((s) => s.id == session.id);
    _storage.insert(0, session);
  }

  @override
  Future<void> deleteSession(String id) async {
    _storage.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> clearAllSessions() async {
    _storage.clear();
  }
}

void main() {
  group('HistoryBloc Tests (TASK-5.3)', () {
    late FakeHistoryRepository fakeRepository;
    late HistoryBloc bloc;

    setUp(() {
      fakeRepository = FakeHistoryRepository();
      bloc = HistoryBloc(fakeRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is HistoryInitial', () {
      expect(bloc.state, const HistoryInitial());
    });

    test('LoadHistoryEvent emits [HistoryLoading, HistoryLoaded] with stats',
        () async {
      final now = DateTime.now();
      await fakeRepository.saveSession(WorkoutSessionRecord(
        id: 's-1',
        workoutId: 'w-1',
        workoutName: 'Muscle-up Mastery',
        startedAt: now.subtract(const Duration(hours: 2)),
        finishedAt: now.subtract(const Duration(hours: 1)),
        durationSeconds: 3600,
        completedRounds: 5,
        rpeScore: 9,
      ));

      expectLater(
        bloc.stream,
        emitsInOrder([
          const HistoryLoading(),
          isA<HistoryLoaded>()
              .having((s) => s.sessions.length, 'sessions.length', 1)
              .having((s) => s.totalSessions, 'totalSessions', 1)
              .having((s) => s.totalDurationMinutes, 'totalDurationMinutes', 60)
              .having((s) => s.workoutsThisWeekCount, 'workoutsThisWeekCount', 1)
              .having((s) => s.minutesThisWeek, 'minutesThisWeek', 60),
        ]),
      );

      bloc.add(const LoadHistoryEvent());
    });

    test('DeleteSessionEvent removes item and reloads list', () async {
      final session = WorkoutSessionRecord(
        id: 's-delete',
        workoutId: 'w-1',
        workoutName: 'Push Routine',
        startedAt: DateTime.now(),
        finishedAt: DateTime.now(),
        durationSeconds: 900,
        completedRounds: 3,
      );
      await fakeRepository.saveSession(session);

      bloc.add(const LoadHistoryEvent());
      await pumpEventQueue();

      expect(bloc.state, isA<HistoryLoaded>());
      expect((bloc.state as HistoryLoaded).sessions.length, 1);

      bloc.add(const DeleteSessionEvent('s-delete'));
      await pumpEventQueue();

      expect(bloc.state, isA<HistoryLoaded>());
      expect((bloc.state as HistoryLoaded).sessions, isEmpty);
    });

    test('ClearHistoryEvent clears all sessions and emits HistoryLoaded([])',
        () async {
      await fakeRepository.saveSession(WorkoutSessionRecord(
        id: 's-1',
        workoutId: 'w-1',
        workoutName: 'Routine 1',
        startedAt: DateTime.now(),
        finishedAt: DateTime.now(),
        durationSeconds: 600,
        completedRounds: 2,
      ));

      bloc.add(const ClearHistoryEvent());
      await pumpEventQueue();

      expect(bloc.state, isA<HistoryLoaded>());
      expect((bloc.state as HistoryLoaded).sessions, isEmpty);
    });
  });
}

