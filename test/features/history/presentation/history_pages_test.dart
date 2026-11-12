import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/di/injection_container.dart';
import 'package:hamino_app/core/theme/app_theme.dart';
import 'package:hamino_app/features/history/domain/entities/workout_session_record.dart';
import 'package:hamino_app/features/history/domain/repositories/history_repository.dart';
import 'package:hamino_app/features/history/presentation/bloc/history_bloc.dart';
import 'package:hamino_app/features/history/presentation/pages/history_page.dart';
import 'package:hamino_app/features/history/presentation/pages/workout_summary_page.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_player/presentation/bloc/workout_player_state.dart';

class MockHistoryRepo implements HistoryRepository {
  final List<WorkoutSessionRecord> sessions = [];

  @override
  Future<List<WorkoutSessionRecord>> getAllSessions() async => List.from(sessions);

  @override
  Future<WorkoutSessionRecord?> getSessionById(String id) async =>
      sessions.where((s) => s.id == id).firstOrNull;

  @override
  Future<void> saveSession(WorkoutSessionRecord session) async {
    sessions.removeWhere((s) => s.id == session.id);
    sessions.insert(0, session);
  }

  @override
  Future<void> deleteSession(String id) async {
    sessions.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> clearAllSessions() async {
    sessions.clear();
  }
}

void main() {
  late MockHistoryRepo mockRepo;

  final testWorkout = WorkoutTemplateEntity(
    id: 'w-summary-test',
    name: 'Full Body Blast',
    category: WorkoutCategory.endurance,
    prepareSeconds: 10,
    defaultRestSeconds: 60,
    timeCapSeconds: 1800,
    targetRounds: 4,
    createdAt: DateTime.now(),
    exercises: const [],
  );

  setUp(() async {
    await sl.reset();
    mockRepo = MockHistoryRepo();
    sl.registerLazySingleton<HistoryRepository>(() => mockRepo);
    sl.registerFactory<HistoryBloc>(() => HistoryBloc(sl<HistoryRepository>()));
  });

  tearDown(() async {
    await sl.reset();
  });

  group('WorkoutSummaryPage Widget Tests (TASK-5.2)', () {
    testWidgets('Renders summary metrics, RPE slider and note input',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: WorkoutSummaryPage(
          workout: testWorkout,
          totalElapsedSeconds: 1245, // 20m 45s
          completedRounds: 4,
          totalRounds: 4,
          reason: CompletionReason.allRoundsFinished,
          startedAt: DateTime(2026, 11, 12, 10, 0),
          finishedAt: DateTime(2026, 11, 12, 10, 20),
        ),
      ));
      await tester.pumpAndSettle();

      // Title & Workout Name
      expect(find.text('XUẤT SẮC!'), findsOneWidget);
      expect(find.text('Full Body Blast'), findsOneWidget);

      // Metrics
      expect(find.text('20:45'), findsOneWidget);
      expect(find.text('4/4'), findsOneWidget);
      expect(find.text('100% HIỆP MỤC TIÊU'), findsOneWidget);

      // RPE section
      expect(find.text('ĐÁNH GIÁ ĐỘ KHÓ (RPE)'), findsOneWidget);
      expect(find.text('RPE 7 / 10'), findsOneWidget);

      // Notes section
      expect(find.text('NHẬT KÝ & CẢM NHẬN'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Save button
      expect(find.text('LƯU KẾT QUẢ BUỔI TẬP'), findsOneWidget);
    });

    testWidgets('Tapping Save Result button saves session to history repository',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: WorkoutSummaryPage(
          workout: testWorkout,
          totalElapsedSeconds: 900,
          completedRounds: 3,
          totalRounds: 4,
          reason: CompletionReason.finishedEarly,
          startedAt: DateTime.now(),
          finishedAt: DateTime.now(),
        ),
      ));
      await tester.pumpAndSettle();

      // Enter notes
      await tester.enterText(
          find.byType(TextField), 'Buổi tập tốt, kết thúc sớm hiệp 4');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('LƯU KẾT QUẢ BUỔI TẬP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check repository has 1 session saved
      expect(mockRepo.sessions.length, 1);
      expect(mockRepo.sessions.first.workoutName, 'Full Body Blast');
      expect(mockRepo.sessions.first.completedRounds, 3);
      expect(mockRepo.sessions.first.durationSeconds, 900);
      expect(mockRepo.sessions.first.notes,
          'Buổi tập tốt, kết thúc sớm hiệp 4');
    });
  });

  group('HistoryPage Widget Tests (TASK-5.3)', () {
    testWidgets('Renders empty state when no sessions are recorded',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: const HistoryPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('LỊCH SỬ TẬP LUYỆN'), findsOneWidget);
      expect(find.text('CHƯA CÓ LỊCH SỬ TẬP'), findsOneWidget);
      expect(find.text('TUẦN NÀY'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(3)); // 0 sessions this week, 0 minutes, 0 total
    });

    testWidgets('Renders timeline session card and opens detail modal on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = WorkoutSessionRecord(
        id: 'sess-1',
        workoutId: 'w-1',
        workoutName: 'Muscle-up Mastery',
        startedAt: DateTime.now(),
        finishedAt: DateTime.now(),
        durationSeconds: 1800,
        completedRounds: 5,
        rpeScore: 8,
        notes: 'Thực hiện 5 hiệp kéo xà thành công',
      );
      mockRepo.sessions.add(session);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: const HistoryPage(),
      ));
      await tester.pumpAndSettle();

      // Session card
      expect(find.text('Muscle-up Mastery'), findsOneWidget);
      expect(find.text('30:00'), findsOneWidget);
      expect(find.text('5 hiệp'), findsOneWidget);
      expect(find.text('RPE 8'), findsOneWidget);

      // Tap card to open modal
      await tester.tap(find.text('Muscle-up Mastery'));
      await tester.pumpAndSettle();

      // Modal is visible
      expect(find.text('THỜI LƯỢNG'), findsOneWidget);
      expect(find.text('SỐ HIỆP'), findsOneWidget);
      expect(find.text('XÓA BẢN GHI NÀY'), findsOneWidget);
    });
  });
}

