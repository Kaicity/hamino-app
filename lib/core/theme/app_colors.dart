import 'package:flutter/material.dart';

/// Bảng màu Dark Mode thể thao, độ tương phản cao cho người tập Hamino Workout
class AppColors {
  AppColors._();

  // Nền & Bề mặt (Background & Surfaces)
  static const Color bgDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF2A2A2A);
  static const Color borderDark = Color(0xFF333333);

  // Trạng thái tập luyện (Workout Timer States)
  static const Color workGreen = Color(0xFF00E676);     // Work chính (High-energy neon green)
  static const Color workOrange = Color(0xFFFF6D00);    // Work phụ / EMOM
  static const Color restBlue = Color(0xFF2979FF);      // Thời gian nghỉ hồi phục (Cool blue)
  static const Color prepareYellow = Color(0xFFFFD600); // Chuẩn bị (Vibrant warning yellow)

  // Màu sắc thể loại Calisthenics (Category Colors)
  static const Color catEmom = Color(0xFFFF6D00);
  static const Color catEndurance = Color(0xFF00E676);
  static const Color catSkill = Color(0xFF7C4DFF);
  static const Color catCardio = Color(0xFFFF5252);

  // Văn bản & Biểu tượng (Typography & Icons)
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB0BEC5);
  static const Color textDisabled = Color(0xFF616161);

  // Trạng thái chức năng (Utility States)
  static const Color accent = Color(0xFF00E676);        // Màu chủ đạo thể thao
  static const Color errorRed = Color(0xFFFF5252);
  static const Color warningOrange = Color(0xFFFF9100);
  static const Color successGreen = Color(0xFF00E676);
  static const Color starFavorite = Color(0xFFFFD700);
}

