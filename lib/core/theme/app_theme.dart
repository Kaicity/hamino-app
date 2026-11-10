import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Cấu hình ThemeData chuẩn thể thao Dark Mode tương phản cao cho Hamino Workout
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.workGreen,
      canvasColor: AppColors.bgDark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.workGreen,
        onPrimary: Colors.black,
        secondary: AppColors.workOrange,
        onSecondary: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textWhite,
        error: AppColors.errorRed,
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.workGreen,
          foregroundColor: Colors.black,
          textStyle: AppTypography.labelLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textWhite,
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.workGreen,
          textStyle: AppTypography.labelMedium,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.workGreen,
        disabledColor: AppColors.surfaceElevated,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: Colors.black),
        side: const BorderSide(color: AppColors.borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        titleTextStyle: AppTypography.headlineMedium,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.workGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
        labelStyle: AppTypography.bodyMedium,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.workGreen,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
    );
  }
}

