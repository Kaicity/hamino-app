import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/database/database_helper.dart';
import 'package:hamino_app/features/history/data/datasources/history_local_datasource.dart';
import 'package:hamino_app/features/history/data/repositories/history_repository_impl.dart';
import 'package:hamino_app/features/history/domain/entities/workout_session_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('HistoryRepository & LocalDataSource SQLite Tests (TASK-5.2 & TASK-5.3)', () {
    late DatabaseHelper databaseHelper;
    late HistoryLocalDataSource dataSource;
    late HistoryRepositoryImpl repository;

    setUp(() async {
      databaseHelper = DatabaseHelper(dbName: inMemoryDatabasePath);
      dataSource = HistoryLocalDataSourceImpl(databaseHelper);
      repository = HistoryRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('Initial database should have 0 workout sessions', () async {
      final sessions = await repository.getAllSessions();
      expect(sessions, isEmpty);
    });

    test('Saving a workout session record should persist and retrieve it', () async {
      final session = WorkoutSessionRecord(
        id: 'session-101',
        workoutId: 'w-preset-1',
        workoutName: 'Tabata Burner',
        startedAt: DateTime(2026, 11, 12, 8, 30),
        finishedAt: DateTime(2026, 11, 12, 8, 50),
        durationSeconds: 1200,
        completedRounds: 4,
        rpeScore: 8,
        notes: 'Cơ bụng và vai mỏi nhiều, hoàn thành tốt',
      );

      await repository.saveSession(session);

      final allSessions = await repository.getAllSessions();
      expect(allSessions.length, 1);
      expect(allSessions.first.id, 'session-101');
      expect(allSessions.first.workoutName, 'Tabata Burner');
      expect(allSessions.first.durationSeconds, 1200);
      expect(allSessions.first.completedRounds, 4);
      expect(allSessions.first.rpeScore, 8);
      expect(allSessions.first.notes, contains('Cơ bụng'));

      // Test getSessionById
      final fetched = await repository.getSessionById('session-101');
      expect(fetched, isNotNull);
      expect(fetched?.workoutName, 'Tabata Burner');
    });

    test('Sessions should be sorted by startedAt descending (newest first)', () async {
      final sessionOld = WorkoutSessionRecord(
        id: 's-old',
        workoutId: 'w-1',
        workoutName: 'Bài tập cũ',
        startedAt: DateTime(2026, 11, 10, 8, 0),
        finishedAt: DateTime(2026, 11, 10, 8, 30),
        durationSeconds: 1800,
        completedRounds: 3,
      );

      final sessionNew = WorkoutSessionRecord(
        id: 's-new',
        workoutId: 'w-2',
        workoutName: 'Bài tập mới',
        startedAt: DateTime(2026, 11, 12, 9, 0),
        finishedAt: DateTime(2026, 11, 12, 9, 30),
        durationSeconds: 1800,
        completedRounds: 4,
      );

      await repository.saveSession(sessionOld);
      await repository.saveSession(sessionNew);

      final sessions = await repository.getAllSessions();
      expect(sessions.length, 2);
      expect(sessions.first.id, 's-new');
      expect(sessions.last.id, 's-old');
    });

    test('Delete a session by ID should remove it from SQLite', () async {
      final session = WorkoutSessionRecord(
        id: 'session-del',
        workoutId: 'w-1',
        workoutName: 'Bài tập chuẩn bị xóa',
        startedAt: DateTime.now(),
        finishedAt: DateTime.now(),
        durationSeconds: 600,
        completedRounds: 2,
      );

      await repository.saveSession(session);
      expect((await repository.getAllSessions()).length, 1);

      await repository.deleteSession('session-del');
      expect(await repository.getAllSessions(), isEmpty);
    });

    test('ClearAllSessions should delete all records', () async {
      for (int i = 0; i < 3; i++) {
        await repository.saveSession(WorkoutSessionRecord(
          id: 's-$i',
          workoutId: 'w-$i',
          workoutName: 'Bài tập $i',
          startedAt: DateTime.now(),
          finishedAt: DateTime.now(),
          durationSeconds: 500,
          completedRounds: 1,
        ));
      }

      expect((await repository.getAllSessions()).length, 3);
      await repository.clearAllSessions();
      expect(await repository.getAllSessions(), isEmpty);
    });
  });
}

