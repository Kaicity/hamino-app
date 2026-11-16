import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hamino_app/core/services/gemini_service.dart';
import 'package:hamino_app/features/workout_builder/data/models/ai_parsed_workout.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/repositories/workout_repository.dart';
import 'package:hamino_app/features/workout_builder/presentation/bloc/workout_builder_bloc.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';

class MockWorkoutRepository implements WorkoutRepository {
  WorkoutTemplateEntity? savedWorkout;

  @override
  Future<List<WorkoutTemplateEntity>> getAllWorkouts() async => [];

  @override
  Future<WorkoutTemplateEntity?> getWorkoutById(String id) async => null;

  @override
  Future<void> saveWorkout(WorkoutTemplateEntity workout) async {
    savedWorkout = workout;
  }

  @override
  Future<void> deleteWorkout(String id) async {}

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {}

  @override
  Future<WorkoutTemplateEntity> duplicateWorkout(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  group('AiParsedWorkout Model Test', () {
    test('Parse thành công cấu trúc JSON chuẩn theo ví dụ người dùng yêu cầu', () {
      final sampleJson = {
        'name': 'Cardio Day',
        'category': 'cardio',
        'description': 'Buổi tập đốt mỡ bụng 4 hiệp',
        'targetRounds': 4,
        'prepareSeconds': 10,
        'defaultRestSeconds': 60,
        'timeCapSeconds': 0,
        'exercises': [
          {'name': 'Nâng chân', 'defaultReps': 15, 'holdSeconds': 0, 'notes': null},
          {'name': 'Gập bụng ngược', 'defaultReps': 15, 'holdSeconds': 0, 'notes': null},
          {'name': 'Plank', 'defaultReps': 0, 'holdSeconds': 45, 'notes': null},
          {'name': 'Bicycle Crunch', 'defaultReps': 20, 'holdSeconds': 0, 'notes': null},
          {'name': 'Hollow Body Hold', 'defaultReps': 0, 'holdSeconds': 20, 'notes': null},
          {'name': 'V-Up', 'defaultReps': 15, 'holdSeconds': 0, 'notes': '10-15 reps'},
          {'name': 'Đá chân rung', 'defaultReps': 0, 'holdSeconds': 30, 'notes': null},
          {'name': 'Side Plank', 'defaultReps': 0, 'holdSeconds': 30, 'notes': '30 giây mỗi bên'},
          {'name': 'Mountain Climber', 'defaultReps': 0, 'holdSeconds': 30, 'notes': null},
          {'name': 'Giữ nâng chân', 'defaultReps': 0, 'holdSeconds': 20, 'notes': '15-20 giây'},
        ],
      };

      final parsed = AiParsedWorkout.fromJson(sampleJson);

      expect(parsed.name, 'Cardio Day');
      expect(parsed.category, WorkoutCategory.cardio);
      expect(parsed.targetRounds, 4);
      expect(parsed.prepareSeconds, 10);
      expect(parsed.defaultRestSeconds, 60);
      expect(parsed.exercises.length, 10);

      // Kiểm tra động tác reps
      expect(parsed.exercises[0].name, 'Nâng chân');
      expect(parsed.exercises[0].defaultReps, 15);
      expect(parsed.exercises[0].holdSeconds, 0);
      expect(parsed.exercises[0].isHold, false);

      // Kiểm tra động tác tĩnh hold seconds
      expect(parsed.exercises[2].name, 'Plank');
      expect(parsed.exercises[2].defaultReps, 0);
      expect(parsed.exercises[2].holdSeconds, 45);
      expect(parsed.exercises[2].isHold, true);

      // Chuyển sang ExerciseEntity của ứng dụng
      final entities = parsed.toExerciseEntities('workout-uuid-123');
      expect(entities.length, 10);
      expect(entities[0].workoutId, 'workout-uuid-123');
      expect(entities[0].orderIndex, 0);
      expect(entities[5].notes, '10-15 reps');
      expect(entities[7].notes, '30 giây mỗi bên');
      expect(entities[9].orderIndex, 9);
    });
  });

  group('GeminiService Test with Mock Client', () {
    test('Gọi Gemini API thành công và trích xuất đúng dữ liệu JSON', () async {
      final mockApiResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'name': 'Cardio Day',
                    'category': 'cardio',
                    'description': '4 hiệp Cardio cường độ cao',
                    'targetRounds': 4,
                    'prepareSeconds': 10,
                    'defaultRestSeconds': 60,
                    'exercises': [
                      {'name': 'Nâng chân', 'defaultReps': 15, 'holdSeconds': 0},
                      {'name': 'Plank', 'defaultReps': 0, 'holdSeconds': 45},
                    ],
                  }),
                }
              ]
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        expect(request.url.host, 'generativelanguage.googleapis.com');
        expect(request.url.queryParameters['key'], 'test-api-key');
        return http.Response(jsonEncode(mockApiResponse), 200);
      });

      final service = GeminiService(client: mockClient);
      final result = await service.parseWorkoutText(
        rawText: 'CADIOR DAY - 4 SET\n1. Nâng chân - 15 reps\n2. Plank - 45 giây',
        customApiKey: 'test-api-key',
      );

      expect(result.name, 'Cardio Day');
      expect(result.category, WorkoutCategory.cardio);
      expect(result.targetRounds, 4);
      expect(result.exercises.length, 2);
      expect(result.exercises[1].holdSeconds, 45);
    });

    test('Xử lý được phản hồi Gemini khi có bọc markdown codeblock ```json', () async {
      final jsonPayload = jsonEncode({
        'name': 'Ab Workout',
        'category': 'endurance',
        'targetRounds': 3,
        'exercises': [
          {'name': 'Gập bụng', 'defaultReps': 20, 'holdSeconds': 0},
        ],
      });

      final mockApiResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': '```json\n$jsonPayload\n```'}
              ]
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockApiResponse), 200);
      });

      final service = GeminiService(client: mockClient);
      final result = await service.parseWorkoutText(
        rawText: 'Ab Workout - 3 SET\n1. Gập bụng - 20 reps',
        customApiKey: 'test-api-key',
      );

      expect(result.name, 'Ab Workout');
      expect(result.targetRounds, 3);
      expect(result.exercises.first.name, 'Gập bụng');
    });

    test('Ném ngoại lệ rõ ràng khi Gemini API trả về mã lỗi 400/403', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'message': 'API_KEY_INVALID'}
          }),
          400,
        );
      });

      final service = GeminiService(client: mockClient);
      expect(
        () => service.parseWorkoutText(
          rawText: 'Push up 10 reps',
          customApiKey: 'invalid-key',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('WorkoutBuilderBloc with ApplyParsedWorkoutEvent', () {
    test('Cập nhật đầy đủ trạng thái khi nhận ApplyParsedWorkoutEvent', () async {
      final repository = MockWorkoutRepository();
      final bloc = WorkoutBuilderBloc(repository);

      final parsed = AiParsedWorkout(
        name: 'Cardio Day',
        category: WorkoutCategory.cardio,
        description: 'Bài tập 4 hiệp',
        targetRounds: 4,
        prepareSeconds: 10,
        defaultRestSeconds: 60,
        exercises: const [
          AiParsedExercise(name: 'Nâng chân', defaultReps: 15),
          AiParsedExercise(name: 'Plank', holdSeconds: 45),
        ],
      );

      final entities = parsed.toExerciseEntities('w-1');

      bloc.add(
        ApplyParsedWorkoutEvent(
          name: parsed.name,
          category: parsed.category,
          description: parsed.description,
          prepareSeconds: parsed.prepareSeconds,
          defaultRestSeconds: parsed.defaultRestSeconds,
          timeCapSeconds: parsed.timeCapSeconds,
          targetRounds: parsed.targetRounds,
          exercises: entities,
        ),
      );

      await expectLater(
        bloc.stream,
        emits(
          predicate<WorkoutBuilderState>((state) {
            return state.name == 'Cardio Day' &&
                state.category == WorkoutCategory.cardio &&
                state.targetRounds == 4 &&
                state.defaultRestSeconds == 60 &&
                state.exercises.length == 2 &&
                state.exercises[1].holdSeconds == 45;
          }),
        ),
      );
    });
  });
}

