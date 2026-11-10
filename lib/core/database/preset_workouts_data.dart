import '../../features/workout_builder/data/models/exercise_model.dart';
import '../../features/workout_builder/data/models/workout_template_model.dart';
import '../../features/workout_builder/domain/entities/workout_category.dart';

/// Thư viện 4 giáo án Calisthenics chuẩn mực được nạp sẵn khi cài ứng dụng
class PresetWorkoutsData {
  PresetWorkoutsData._();

  static const String presetEmomId = 'preset_emom_20m_beast';
  static const String presetEnduranceId = 'preset_endurance_30m_circuit';
  static const String presetSkillId = 'preset_skill_handstand_mastery';
  static const String presetCardioId = 'preset_cardio_hiit_tabata';

  /// Danh sách 4 bài mẫu Calisthenics chuẩn
  static List<WorkoutTemplateModel> get presets => [
        _presetEmom,
        _presetEndurance,
        _presetSkill,
        _presetCardio,
      ];

  /// Preset 1 (EMOM): "EMOM 20m Beast"
  static final WorkoutTemplateModel _presetEmom = WorkoutTemplateModel(
    id: presetEmomId,
    name: 'EMOM 20m Beast',
    category: WorkoutCategory.emom,
    description:
        'Bài tập EMOM Calisthenics 20 phút kinh điển. Mỗi phút hoàn thành mục tiêu số reps quy định, thời gian còn lại của phút dành để nghỉ.',
    prepareSeconds: 10,
    defaultRestSeconds: 0,
    timeCapSeconds: 1200, // 20 phút
    targetRounds: 5,
    isPreset: true,
    isFavorite: false,
    createdAt: DateTime(2026, 1, 1),
    exercises: const [
      ExerciseModel(
        id: 'ex_emom_1',
        workoutId: presetEmomId,
        name: 'Pull-ups',
        defaultReps: 10,
        holdSeconds: 0,
        orderIndex: 0,
        notes: 'Phút 1: Kéo cằm vượt xà, duỗi hết tay khi hạ thân người',
      ),
      ExerciseModel(
        id: 'ex_emom_2',
        workoutId: presetEmomId,
        name: 'Push-ups',
        defaultReps: 20,
        holdSeconds: 0,
        orderIndex: 1,
        notes: 'Phút 2: Ngực chạm sàn, siết chặt cơ bụng và mông',
      ),
      ExerciseModel(
        id: 'ex_emom_3',
        workoutId: presetEmomId,
        name: 'Dips',
        defaultReps: 15,
        holdSeconds: 0,
        orderIndex: 2,
        notes: 'Phút 3: Bắp tay vuông góc 90 độ ở điểm thấp nhất',
      ),
      ExerciseModel(
        id: 'ex_emom_4',
        workoutId: presetEmomId,
        name: 'Rest',
        defaultReps: 0,
        holdSeconds: 60,
        orderIndex: 3,
        notes: 'Phút 4: Nghỉ ngơi trọn vẹn 60 giây để hồi sức cho vòng tiếp theo',
      ),
    ],
  );

  /// Preset 2 (Endurance): "Endurance 30m Circuit"
  static final WorkoutTemplateModel _presetEndurance = WorkoutTemplateModel(
    id: presetEnduranceId,
    name: 'Endurance 30m Circuit',
    category: WorkoutCategory.endurance,
    description:
        'Tập sức bền thể lực Calisthenics toàn diện với chuỗi 4 bài xà và sàn liên tục, rèn luyện hệ hô hấp tim mạch và sức chịu đựng cơ bắp.',
    prepareSeconds: 10,
    defaultRestSeconds: 90,
    timeCapSeconds: 1800, // 30 phút
    targetRounds: 5,
    isPreset: true,
    isFavorite: true,
    createdAt: DateTime(2026, 1, 2),
    exercises: const [
      ExerciseModel(
        id: 'ex_endurance_1',
        workoutId: presetEnduranceId,
        name: 'Pull-ups',
        defaultReps: 8,
        holdSeconds: 0,
        orderIndex: 0,
        notes: 'Kiểm soát nhịp độ, không đung đưa xà',
      ),
      ExerciseModel(
        id: 'ex_endurance_2',
        workoutId: presetEnduranceId,
        name: 'Dips',
        defaultReps: 12,
        holdSeconds: 0,
        orderIndex: 1,
        notes: 'Khóa khớp nhẹ ở đỉnh, ngực hơi đổ về phía trước',
      ),
      ExerciseModel(
        id: 'ex_endurance_3',
        workoutId: presetEnduranceId,
        name: 'Australian Rows',
        defaultReps: 12,
        holdSeconds: 0,
        orderIndex: 2,
        notes: 'Kéo thanh xà thấp ngang ngực dưới, ép chặt bả vai',
      ),
      ExerciseModel(
        id: 'ex_endurance_4',
        workoutId: presetEnduranceId,
        name: 'Bodyweight Squats',
        defaultReps: 20,
        holdSeconds: 0,
        orderIndex: 3,
        notes: 'Xuống sâu đùi song song mặt đất, giữ thẳng lưng',
      ),
    ],
  );

  /// Preset 3 (Skill): "Skill Handstand Mastery"
  static final WorkoutTemplateModel _presetSkill = WorkoutTemplateModel(
    id: presetSkillId,
    name: 'Skill Handstand Mastery',
    category: WorkoutCategory.skill,
    description:
        'Giáo án rèn thăng bằng, sức mạnh khớp vai và khả năng gồng siết core phục vụ kỹ năng trồng chuối (Handstand).',
    prepareSeconds: 10,
    defaultRestSeconds: 90,
    timeCapSeconds: 0, // Không giới hạn
    targetRounds: 6,
    isPreset: true,
    isFavorite: false,
    createdAt: DateTime(2026, 1, 3),
    exercises: const [
      ExerciseModel(
        id: 'ex_skill_1',
        workoutId: presetSkillId,
        name: 'Handstand Wall Hold',
        defaultReps: 0,
        holdSeconds: 20,
        orderIndex: 0,
        notes: 'Đạp mũi chân lên tường, gồng chặt core và đẩy vai thẳng',
      ),
      ExerciseModel(
        id: 'ex_skill_2',
        workoutId: presetSkillId,
        name: 'Rest',
        defaultReps: 0,
        holdSeconds: 90,
        orderIndex: 1,
        notes: 'Nghỉ thả lỏng cổ tay và xoay khớp vai',
      ),
      ExerciseModel(
        id: 'ex_skill_3',
        workoutId: presetSkillId,
        name: 'Pike Push-ups',
        defaultReps: 8,
        holdSeconds: 0,
        orderIndex: 2,
        notes: 'Mông đẩy cao tạo hình tam giác, trán chạm sàn nhẹ nhàng',
      ),
      ExerciseModel(
        id: 'ex_skill_4',
        workoutId: presetSkillId,
        name: 'Rest',
        defaultReps: 0,
        holdSeconds: 90,
        orderIndex: 3,
        notes: 'Nghỉ hồi phục hoàn toàn trước khi bước vào hiệp mới',
      ),
    ],
  );

  /// Preset 4 (Cardio): "Cardio HIIT Tabata"
  static final WorkoutTemplateModel _presetCardio = WorkoutTemplateModel(
    id: presetCardioId,
    name: 'Cardio HIIT Tabata',
    category: WorkoutCategory.cardio,
    description:
        'Đốt mỡ cường độ cao chuẩn giao thức Tabata kinh điển 8 rounds Burpees bùng nổ (20s Work / 10s Rest).',
    prepareSeconds: 10,
    defaultRestSeconds: 10,
    timeCapSeconds: 240, // 4 phút
    targetRounds: 8,
    isPreset: true,
    isFavorite: false,
    createdAt: DateTime(2026, 1, 4),
    exercises: const [
      ExerciseModel(
        id: 'ex_cardio_1',
        workoutId: presetCardioId,
        name: 'Burpees',
        defaultReps: 0,
        holdSeconds: 20,
        orderIndex: 0,
        notes: '20 giây bùng nổ hết tốc lực, bật nhảy cao vỗ tay qua đầu',
      ),
      ExerciseModel(
        id: 'ex_cardio_2',
        workoutId: presetCardioId,
        name: 'Rest',
        defaultReps: 0,
        holdSeconds: 10,
        orderIndex: 1,
        notes: '10 giây hít thở sâu phục hồi, chuẩn bị ngay cho đợt bùng nổ kế',
      ),
    ],
  );
}

