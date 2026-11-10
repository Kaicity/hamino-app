import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hệ thống phông chữ thể thao, dễ nhìn từ xa khi tập luyện
class AppTypography {
  AppTypography._();

  // Phông hiển thị số Timer cực đại (Monospace chống giật layout số khi đếm ngược)
  static TextStyle get timerBigDisplay => GoogleFonts.robotoMono(
        fontSize: 92,
        fontWeight: FontWeight.w800,
        color: AppColors.textWhite,
        letterSpacing: -2.0,
      );

  // Phông hiển thị số Timer vừa (dành cho chế độ xem phụ)
  static TextStyle get timerMediumDisplay => GoogleFonts.robotoMono(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        letterSpacing: -1.0,
      );

  // Phông Tiêu đề chính (Thể thao, mạnh mẽ: Barlow Condensed)
  static TextStyle get headlineLarge => GoogleFonts.barlowCondensed(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.barlowCondensed(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      );

  static TextStyle get headlineSmall => GoogleFonts.barlowCondensed(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
      );

  // Phông Tiêu đề thẻ và mục con
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      );

  // Phông Nội dung văn bản
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textWhite,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
      );

  // Phông Nhãn Badge & Chips
  static TextStyle get labelLarge => GoogleFonts.barlowCondensed(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppColors.textWhite,
      );

  static TextStyle get labelMedium => GoogleFonts.barlowCondensed(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.textWhite,
      );

  static TextStyle get labelSmall => GoogleFonts.barlowCondensed(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      );
}

