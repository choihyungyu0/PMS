import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      primary: AppColors.primaryPurple,
      secondary: AppColors.deepPurple,
      surface: AppColors.softCard,
    );
    const brandStyle = TextStyle(
      fontFamily: AppFonts.brand,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    );
    const titleStyle = TextStyle(
      fontFamily: AppFonts.title,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    );
    const bodyStyle = TextStyle(
      fontFamily: AppFonts.body,
      color: AppColors.textPrimary,
      letterSpacing: 0,
      height: 1.45,
    );
    const actionStyle = TextStyle(
      fontFamily: AppFonts.action,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lavenderBackground,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
      textTheme: const TextTheme(
        displayLarge: brandStyle,
        displayMedium: brandStyle,
        displaySmall: brandStyle,
        headlineLarge: titleStyle,
        headlineMedium: titleStyle,
        headlineSmall: titleStyle,
        titleLarge: titleStyle,
        titleMedium: titleStyle,
        titleSmall: titleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: bodyStyle,
        bodySmall: TextStyle(
          fontFamily: AppFonts.body,
          color: AppColors.textSecondary,
          letterSpacing: 0,
          height: 1.35,
        ),
        labelLarge: actionStyle,
        labelMedium: actionStyle,
        labelSmall: actionStyle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.title,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          fontFamily: AppFonts.body,
          color: AppColors.textSecondary,
          letterSpacing: 0,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppFonts.body,
          color: AppColors.textSecondary,
          letterSpacing: 0,
        ),
        errorStyle: const TextStyle(
          fontFamily: AppFonts.body,
          color: Color(0xFFC44949),
          letterSpacing: 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryPurple,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.primaryPurple,
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(
          fontFamily: AppFonts.action,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: actionStyle.copyWith(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: actionStyle.copyWith(fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: actionStyle.copyWith(fontSize: 15),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelStyle: TextStyle(
          fontFamily: AppFonts.action,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppFonts.action,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedLabelStyle: TextStyle(
          fontFamily: AppFonts.action,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppFonts.action,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      dialogTheme: const DialogThemeData(
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.title,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.body,
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.45,
          letterSpacing: 0,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.body,
          color: Colors.white,
          fontSize: 14,
          height: 1.35,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
