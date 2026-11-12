import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/theme/app_theme.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/exercise_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_builder/presentation/widgets/empty_state_widget.dart';
import 'package:hamino_app/features/workout_builder/presentation/widgets/exercise_form_dialog.dart';
import 'package:hamino_app/features/workout_builder/presentation/widgets/exercise_list_item.dart';
import 'package:hamino_app/features/workout_builder/presentation/widgets/workout_card.dart';
import 'package:hamino_app/features/workout_builder/presentation/widgets/workout_target_summary_card.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('WorkoutCard Widget Tests (TASK-2.2)', () {
    final sampleWorkout = WorkoutTemplateEntity(
      id: 'w-1',
      name: 'Beast Mode EMOM',
      category: WorkoutCategory.emom,
      description: 'Test description for workout',
      prepareSeconds: 10,
      defaultRestSeconds: 60,
      timeCapSeconds: 1200,
      targetRounds: 5,
      isPreset: true,
      isFavorite: false,
      createdAt: DateTime.now(),
      exercises: const [
        ExerciseEntity(
          id: 'ex-1',
          workoutId: 'w-1',
          name: 'Muscle-up',
          defaultReps: 5,
          holdSeconds: 0,
          orderIndex: 0,
        ),
        ExerciseEntity(
          id: 'ex-2',
          workoutId: 'w-1',
          name: 'Handstand Hold',
          defaultReps: 0,
          holdSeconds: 30,
          orderIndex: 1,
        ),
      ],
    );

    testWidgets('Renders all workout information and chips correctly', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWidget(WorkoutCard(workout: sampleWorkout)));

      expect(find.text('EMOM'), findsOneWidget);
      expect(find.text('PRESET'), findsOneWidget);
      expect(find.text('Beast Mode EMOM'), findsOneWidget);
      expect(find.text('Test description for workout'), findsOneWidget);
      expect(find.text('5 Hiệp'), findsOneWidget);
      expect(find.text('Cap: 20 phút'), findsOneWidget);
      expect(find.text('2 Động tác'), findsOneWidget);
      expect(find.text('Muscle-up: = 25 rep'), findsOneWidget);
      expect(find.text('Handstand Hold: = 2 phút 30 giây'), findsOneWidget);
      expect(find.text('Muscle-up'), findsOneWidget);
      expect(find.text('= 25 rep'), findsOneWidget);
      expect(find.text('Handstand Hold'), findsOneWidget);
      expect(find.text('= 2 phút 30 giây'), findsOneWidget);
      expect(find.text('BẮT ĐẦU TẬP'), findsOneWidget);
    });

    testWidgets('Triggers onStart when tapping BẮT ĐẦU TẬP', (tester) async {
      bool started = false;
      await tester.pumpWidget(
        wrapWidget(
          WorkoutCard(workout: sampleWorkout, onStart: () => started = true),
        ),
      );

      await tester.tap(find.text('BẮT ĐẦU TẬP'));
      await tester.pump();

      expect(started, isTrue);
    });

    testWidgets('Triggers onFavoriteToggle when tapping star icon', (
      tester,
    ) async {
      bool toggled = false;
      await tester.pumpWidget(
        wrapWidget(
          WorkoutCard(
            workout: sampleWorkout,
            onFavoriteToggle: () => toggled = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('Opens popup menu with Edit, Duplicate and Delete', (
      tester,
    ) async {
      bool editTapped = false;
      await tester.pumpWidget(
        wrapWidget(
          WorkoutCard(workout: sampleWorkout, onEdit: () => editTapped = true),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Chỉnh sửa'), findsOneWidget);
      expect(find.text('Nhân bản'), findsOneWidget);
      expect(find.text('Xóa'), findsOneWidget);

      await tester.tap(find.text('Chỉnh sửa'));
      await tester.pumpAndSettle();

      expect(editTapped, isTrue);
    });
  });

  group('EmptyStateWidget Tests (TASK-2.1)', () {
    testWidgets('Renders empty state with category and callbacks', (
      tester,
    ) async {
      bool created = false;
      bool reset = false;

      await tester.pumpWidget(
        wrapWidget(
          EmptyStateWidget(
            selectedCategory: WorkoutCategory.cardio,
            onCreateWorkout: () => created = true,
            onResetFilter: () => reset = true,
          ),
        ),
      );

      expect(find.text('CHƯA CÓ BÀI TẬP CARDIO'), findsOneWidget);
      expect(find.text('TẠO BÀI TẬP MỚI'), findsOneWidget);
      expect(find.text('Xem tất cả các thể loại'), findsOneWidget);

      await tester.tap(find.text('TẠO BÀI TẬP MỚI'));
      await tester.pump();
      expect(created, isTrue);

      await tester.tap(find.text('Xem tất cả các thể loại'));
      await tester.pump();
      expect(reset, isTrue);
    });
  });

  group('ExerciseListItem Tests (TASK-2.4)', () {
    const sampleExercise = ExerciseEntity(
      id: 'e-1',
      workoutId: 'w-1',
      name: 'Pull-up',
      defaultReps: 12,
      holdSeconds: 0,
      orderIndex: 0,
      notes: 'Thắt chặt cơ xô',
    );

    testWidgets('Renders exercise item and handles delete tap', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        wrapWidget(
          ExerciseListItem(
            exercise: sampleExercise,
            index: 0,
            workoutId: 'w-1',
            onDelete: () => deleted = true,
            onUpdate: (_) {},
          ),
        ),
      );

      expect(find.text('Pull-up'), findsOneWidget);
      expect(find.text('12 reps'), findsOneWidget);
      expect(find.text('Thắt chặt cơ xô'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump();

      expect(deleted, isTrue);
    });
  });

  group('ExerciseFormDialog Tests (TASK-2.4)', () {
    testWidgets('Renders modal and switches between reps and hold mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () =>
                      ExerciseFormDialog.show(ctx, workoutId: 'test-w'),
                  child: const Text('OPEN'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(find.text('THÊM ĐỘNG TÁC'), findsOneWidget);
      expect(find.text('Theo số lần'), findsOneWidget);
      expect(find.text('Theo giây'), findsOneWidget);

      // Switch to hold mode
      await tester.tap(find.text('Theo giây'));
      await tester.pumpAndSettle();

      expect(find.text('Số giây *'), findsOneWidget);
    });
  });

  group('WorkoutTargetSummaryCard Tests', () {
    testWidgets('Renders empty state hint when exercises list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWidget(
          const WorkoutTargetSummaryCard(exercises: [], targetRounds: 4),
        ),
      );

      expect(
        find.text(
          'Thêm động tác để xem chi tiết số rep và thời gian giữ mục tiêu từng động tác.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Calculates total reps across all rounds correctly', (
      tester,
    ) async {
      const exercises = [
        ExerciseEntity(
          id: 'e1',
          workoutId: 'w1',
          name: 'Push-ups',
          defaultReps: 20,
          holdSeconds: 0,
          orderIndex: 0,
        ),
        ExerciseEntity(
          id: 'e2',
          workoutId: 'w1',
          name: 'Pull-ups',
          defaultReps: 10,
          holdSeconds: 0,
          orderIndex: 1,
        ),
      ];

      await tester.pumpWidget(
        wrapWidget(
          const WorkoutTargetSummaryCard(exercises: exercises, targetRounds: 5),
        ),
      );

      // Hiển thị chi tiết từng động tác thay vì cộng gộp
      expect(find.text('MỤC TIÊU TỪNG ĐỘNG TÁC'), findsOneWidget);
      expect(find.text('Kết quả đạt được qua 5 hiệp tập'), findsOneWidget);
      expect(find.text('10 SETS'), findsOneWidget); // 2 ex * 5 rounds
      expect(find.text('Push-ups'), findsOneWidget);
      expect(find.text('= 100 rep'), findsOneWidget);
      expect(find.text('20 rep/hiệp × 5 hiệp'), findsOneWidget);
      expect(find.text('Pull-ups'), findsOneWidget);
      expect(find.text('= 50 rep'), findsOneWidget);
      expect(find.text('10 rep/hiệp × 5 hiệp'), findsOneWidget);
      // Không cộng dồn tổng thể thành một số chung
      expect(find.text('TỔNG SỐ REPS'), findsNothing);
    });

    testWidgets(
      'Calculates total hold seconds converted to minutes per exercise',
      (tester) async {
        const exercises = [
          ExerciseEntity(
            id: 'e1',
            workoutId: 'w1',
            name: 'Handstand Hold',
            defaultReps: 0,
            holdSeconds: 30,
            orderIndex: 0,
          ),
        ];

        await tester.pumpWidget(
          wrapWidget(
            const WorkoutTargetSummaryCard(
              exercises: exercises,
              targetRounds: 5,
            ),
          ),
        );

        // Total hold = 30s * 5 = 150s = 2 phút 30 giây
        expect(find.text('MỤC TIÊU TỪNG ĐỘNG TÁC'), findsOneWidget);
        expect(find.text('Handstand Hold'), findsOneWidget);
        expect(find.text('= 2 phút 30 giây'), findsOneWidget);
        expect(find.text('30s/hiệp × 5 hiệp'), findsOneWidget);
        expect(find.text('5 SETS'), findsOneWidget);
        expect(find.text('TỔNG SỐ REPS'), findsNothing);
      },
    );

    testWidgets(
      'Calculates user specific example: Push up, Pull ups, Plank, Swat hold',
      (tester) async {
        const exercises = [
          ExerciseEntity(
            id: 'e1',
            workoutId: 'w1',
            name: 'Push up',
            defaultReps: 10,
            holdSeconds: 0,
            orderIndex: 0,
          ),
          ExerciseEntity(
            id: 'e2',
            workoutId: 'w1',
            name: 'Pull ups',
            defaultReps: 20,
            holdSeconds: 0,
            orderIndex: 1,
          ),
          ExerciseEntity(
            id: 'e3',
            workoutId: 'w1',
            name: 'Plank',
            defaultReps: 0,
            holdSeconds: 120,
            orderIndex: 2,
          ),
          ExerciseEntity(
            id: 'e4',
            workoutId: 'w1',
            name: 'Swat hold',
            defaultReps: 0,
            holdSeconds: 60,
            orderIndex: 3,
          ),
        ];

        await tester.pumpWidget(
          wrapWidget(
            const WorkoutTargetSummaryCard(
              exercises: exercises,
              targetRounds: 5,
            ),
          ),
        );

        // Kiểm tra chính xác theo yêu cầu người dùng:
        // Push up: = 50 rep (10 * 5)
        expect(find.text('Push up'), findsOneWidget);
        expect(find.text('= 50 rep'), findsOneWidget);
        expect(find.text('10 rep/hiệp × 5 hiệp'), findsOneWidget);

        // Pull ups: = 100 rep (20 * 5)
        expect(find.text('Pull ups'), findsOneWidget);
        expect(find.text('= 100 rep'), findsOneWidget);
        expect(find.text('20 rep/hiệp × 5 hiệp'), findsOneWidget);

        // Plank: = 10 phút (120s * 5 = 600s = 10 phút)
        expect(find.text('Plank'), findsOneWidget);
        expect(find.text('= 10 phút'), findsOneWidget);
        expect(find.text('120s/hiệp × 5 hiệp'), findsOneWidget);

        // Swat hold: = 5 phút (60s * 5 = 300s = 5 phút)
        expect(find.text('Swat hold'), findsOneWidget);
        expect(find.text('= 5 phút'), findsOneWidget);
        expect(find.text('60s/hiệp × 5 hiệp'), findsOneWidget);

        expect(find.text('20 SETS'), findsOneWidget);
      },
    );
  });
}
