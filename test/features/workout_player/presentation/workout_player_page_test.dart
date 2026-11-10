import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/di/injection_container.dart';
import 'package:hamino_app/core/theme/app_theme.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/exercise_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_player/domain/services/precision_ticker.dart';
import 'package:hamino_app/features/workout_player/presentation/bloc/workout_player_bloc.dart';
import 'package:hamino_app/features/workout_player/presentation/bloc/workout_player_state.dart';
import 'package:hamino_app/features/workout_player/presentation/pages/workout_player_page.dart';
import 'package:hamino_app/features/workout_player/presentation/widgets/lock_overlay.dart';
import 'package:hamino_app/features/workout_player/presentation/widgets/next_up_card.dart';
import 'package:hamino_app/features/workout_player/presentation/widgets/workout_completed_view.dart';
import 'package:hamino_app/features/workout_player/presentation/widgets/workout_progress_bar.dart';

void main() {
  final testWorkout = WorkoutTemplateEntity(
    id: 'w-player-test',
    name: 'Player Test Routine',
    category: WorkoutCategory.emom,
    prepareSeconds: 5,
    defaultRestSeconds: 45,
    timeCapSeconds: 1200,
    targetRounds: 3,
    createdAt: DateTime.now(),
    exercises: const [
      ExerciseEntity(
        id: 'e1',
        workoutId: 'w-player-test',
        name: 'Handstand Push-up',
        defaultReps: 8,
        holdSeconds: 0,
        orderIndex: 0,
      ),
      ExerciseEntity(
        id: 'e2',
        workoutId: 'w-player-test',
        name: 'Plank Hold',
        defaultReps: 0,
        holdSeconds: 30,
        orderIndex: 1,
      ),
    ],
  );

  setUp(() async {
    await sl.reset();
    sl.registerLazySingleton<PrecisionTicker>(() => const PrecisionTicker());
    sl.registerFactory(() => WorkoutPlayerBloc(ticker: sl<PrecisionTicker>()));
  });

  tearDown(() async {
    await sl.reset();
  });

  group('WorkoutPlayerPage UI Widget Tests (TASK-3.3, TASK-3.4, TASK-3.5)', () {
    testWidgets('Renders immersive player with timer, round pill, controls and Next Up',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: WorkoutPlayerPage(workout: testWorkout),
      ));
      await tester.pumpAndSettle();

      // Round pill
      expect(find.text('HIỆP 1 / 3'), findsOneWidget);

      // Status label (Initial prepare state)
      expect(find.text('CHUẨN BỊ'), findsOneWidget);

      // Timer display (00:05)
      expect(find.text('00:05'), findsOneWidget);

      // Current Exercise Name
      expect(find.text('Handstand Push-up'), findsOneWidget);

      // Control buttons (Previous, Play/Pause, Next)
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);

      // Lock button
      expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);

      // Next Up card shows exercise 2
      expect(find.text('TIẾP THEO'), findsOneWidget);
      expect(find.text('Plank Hold'), findsOneWidget);
    });

    testWidgets('Tapping pause toggles icon to play arrow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: WorkoutPlayerPage(workout: testWorkout),
      ));
      await tester.pumpAndSettle();

      // Tap pause button
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pumpAndSettle();

      expect(find.text('TẠM DỪNG'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Tap play to resume
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      expect(find.text('CHUẨN BỊ'), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('Tapping lock icon enables lock overlay and long press unlocks',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: WorkoutPlayerPage(workout: testWorkout),
      ));
      await tester.pumpAndSettle();

      // Tap lock button
      await tester.tap(find.byIcon(Icons.lock_open_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LockOverlay), findsOneWidget);
      expect(find.text('MÀN HÌNH ĐANG KHÓA'), findsOneWidget);

      // Long press on lock icon in overlay to unlock
      final overlayLockIcon = find.descendant(
        of: find.byType(LockOverlay),
        matching: find.byIcon(Icons.lock_rounded),
      );
      await tester.longPress(overlayLockIcon);
      await tester.pumpAndSettle();

      expect(find.byType(LockOverlay), findsNothing);
    });

    testWidgets('WorkoutProgressBar renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: WorkoutProgressBar(
            workout: testWorkout,
            totalElapsedSeconds: 125,
            progress: 0.25,
          ),
        ),
      ));

      expect(find.text('Tổng: 02:05'), findsOneWidget);
      expect(find.text('Cap: 20:00'), findsOneWidget);
    });

    testWidgets('NextUpCard shows last step message when isLastStep is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: NextUpCard(isLastStep: true),
        ),
      ));

      expect(find.text('BÀI TẬP CUỐI CÙNG - CỐ LÊN!'), findsOneWidget);
    });

    testWidgets('WorkoutCompletedView renders summary statistics',
        (WidgetTester tester) async {
      bool finished = false;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: WorkoutCompletedView(
            state: PlayerCompleted(
              workout: testWorkout,
              totalElapsedSeconds: 1530,
              totalRounds: 3,
              reason: CompletionReason.allRoundsFinished,
              completedRounds: 3,
              totalWorkSeconds: 1200,
            ),
            onFinish: () => finished = true,
          ),
        ),
      ));

      expect(find.text('XUẤT SẮC!'), findsOneWidget);
      expect(find.text('Hoàn thành tất cả các hiệp'), findsOneWidget);
      expect(find.text('25:30'), findsOneWidget); // 1530s = 25m 30s
      expect(find.text('3 / 3'), findsOneWidget);

      await tester.tap(find.text('HOÀN TẤT & VỀ TRANG CHỦ'));
      expect(finished, isTrue);
    });
  });
}
