import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Thể loại bài tập Calisthenics
enum WorkoutCategory {
  emom,
  endurance,
  skill,
  cardio;

  /// Tên hiển thị ngắn gọn tiếng Anh chuẩn thể thao
  String get displayName {
    switch (this) {
      case WorkoutCategory.emom:
        return 'EMOM';
      case WorkoutCategory.endurance:
        return 'Endurance';
      case WorkoutCategory.skill:
        return 'Skill';
      case WorkoutCategory.cardio:
        return 'Cardio';
    }
  }

  /// Nhãn mô tả tiếng Việt chi tiết
  String get vietnameseLabel {
    switch (this) {
      case WorkoutCategory.emom:
        return 'Mỗi phút 1 bài (EMOM)';
      case WorkoutCategory.endurance:
        return 'Sức bền (Endurance)';
      case WorkoutCategory.skill:
        return 'Kỹ năng (Skill)';
      case WorkoutCategory.cardio:
        return 'Đốt mỡ / HIIT (Cardio)';
    }
  }

  /// Màu sắc đại diện cho thể loại
  Color get color {
    switch (this) {
      case WorkoutCategory.emom:
        return AppColors.catEmom;
      case WorkoutCategory.endurance:
        return AppColors.catEndurance;
      case WorkoutCategory.skill:
        return AppColors.catSkill;
      case WorkoutCategory.cardio:
        return AppColors.catCardio;
    }
  }

  /// Icon đại diện thể loại
  IconData get icon {
    switch (this) {
      case WorkoutCategory.emom:
        return Icons.timer_outlined;
      case WorkoutCategory.endurance:
        return Icons.fitness_center_outlined;
      case WorkoutCategory.skill:
        return Icons.sports_gymnastics_outlined;
      case WorkoutCategory.cardio:
        return Icons.local_fire_department_outlined;
    }
  }

  /// Chuyển đổi từ chuỗi lưu trữ trong SQLite (không phân biệt hoa thường)
  static WorkoutCategory fromString(String? value) {
    if (value == null) return WorkoutCategory.endurance;
    final normalized = value.trim().toLowerCase();
    for (final category in WorkoutCategory.values) {
      if (category.name.toLowerCase() == normalized) {
        return category;
      }
    }
    return WorkoutCategory.endurance;
  }
}

