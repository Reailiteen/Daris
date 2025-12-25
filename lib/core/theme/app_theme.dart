import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const Color accentPurple = Color(0xFF5856D6);
  static const Color accentBlue = Color(0xFF3B89FA);
  static const Color accentTeal = Color(0xFF5AC8FA);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentRed = Color(0xFFFF3B30);

  // Background Colors - Light
  static const Color backgroundTopLight = Color(0xFFF5F0F1);
  static const Color backgroundBottomLight = Color(0xFFF7F7FC);

  // Background Colors - Dark
  static const Color backgroundTopDark = Color(0xFF191D22);
  static const Color backgroundBottomDark = Color(0xFF101419);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPurple, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundGradient(bool isDark) {
    return LinearGradient(
      colors: isDark 
        ? [backgroundTopDark, backgroundBottomDark]
        : [backgroundTopLight, backgroundBottomLight],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentPurple,
        primary: AppColors.accentPurple,
        secondary: AppColors.accentBlue,
        background: AppColors.backgroundBottomLight,
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentPurple,
        brightness: Brightness.dark,
        primary: AppColors.accentPurple,
        secondary: AppColors.accentBlue,
        background: AppColors.backgroundBottomDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
