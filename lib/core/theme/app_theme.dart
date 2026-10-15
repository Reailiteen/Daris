import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// MeritColors — canonical brand palette
// ---------------------------------------------------------------------------
class MeritColors {
  MeritColors._();

  // -- Brand purple
  static const Color primary = Color(0xFF5856D6);
  static const Color primaryLight = Color(0xFF7B79E0);
  static const Color primaryDark = Color(0xFF3D3BB8);
  static const Color primarySurface = Color(0xFF1A1933);

  // -- Semantic
  static const Color success = Color(0xFF34C759);
  static const Color reward = Color(0xFFFFCC00);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);

  // -- Dark surfaces
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color surfaceDark = Color(0xFF13131A);
  static const Color surfaceElevated = Color(0xFF1C1C28);

  // -- Light surfaces
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // -- Dark text
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFF8E8EA0);

  // -- Light text
  static const Color textPrimaryLight = Color(0xFF0A0A0F);
  static const Color textSecondaryLight = Color(0xFF6B6B80);

  // -- Borders
  static const Color border = Color(0xFF2A2A3A);

  // -- Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5856D6), Color(0xFF3D3BB8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rewardGradient = LinearGradient(
    colors: [Color(0xFFFFCC00), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // -- Helpers
  static Color flat(bool isDark) => isDark ? backgroundDark : backgroundLight;

  // -------------------------------------------------------------------------
  // Legacy aliases — kept so all existing callers compile without changes.
  // -------------------------------------------------------------------------

  // Surfaces
  static const Color surface = surfaceLight;
  static const Color background = backgroundLight;

  // Text (light-mode forwards)
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Dividers
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = border;

  // Accent aliases
  static const Color accentPurple = primary;
  static const Color accentBlue = primaryLight;
  static const Color accentTeal = Color(0xFF26A69A);
  static const Color accentGreen = success;
  static const Color accentOrange = warning;
  static const Color accentRed = error;

  // Reward dark (legacy)
  static const Color rewardDark = Color(0xFFFF9500);

  static const List<BoxShadow> cardShadow = [];
  static const List<BoxShadow> elevatedShadow = [];

  // Legacy gradient helper
  static LinearGradient backgroundGradient(bool isDark) {
    final c = isDark ? backgroundDark : backgroundLight;
    return LinearGradient(colors: [c, c]);
  }
}

// ---------------------------------------------------------------------------
// MeritDecorations — canonical decoration helpers
// ---------------------------------------------------------------------------
class MeritDecorations {
  MeritDecorations._();

  static const double cardRadius = 20;
  static const double buttonRadius = 16;
  static const double pillRadius = 100;
  static const double chipRadius = 12;

  static BoxDecoration card(bool isDark) => BoxDecoration(
    color: isDark ? MeritColors.surfaceDark : MeritColors.surfaceLight,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(
      color: isDark
          ? MeritColors.border.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.08),
      width: 1,
    ),
    boxShadow: null,
  );

  static BoxDecoration elevatedCard(bool isDark) => BoxDecoration(
    color: isDark ? MeritColors.surfaceElevated : MeritColors.surfaceLight,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(
      color: isDark
          ? MeritColors.border.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.08),
      width: 1,
    ),
    boxShadow: null,
  );

  static BoxDecoration pill(bool isDark) => BoxDecoration(
    color: isDark ? MeritColors.surfaceDark : MeritColors.surfaceLight,
    borderRadius: BorderRadius.circular(pillRadius),
    border: Border.all(
      color: isDark
          ? MeritColors.border.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.08),
      width: 1,
    ),
  );

  static BoxDecoration glassCard() => BoxDecoration(
    color: MeritColors.backgroundDark.withValues(alpha: 0.80),
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: MeritColors.border, width: 1),
    boxShadow: null,
  );
}

// ---------------------------------------------------------------------------
// AppTheme — ThemeData factories
// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  // Daris uses light mode throughout the app.
  static ThemeData get theme => lightTheme;

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: MeritColors.primary,
        primaryContainer: MeritColors.primarySurface,
        secondary: MeritColors.primaryLight,
        surface: MeritColors.surfaceDark,
        error: MeritColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: MeritColors.textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: MeritColors.backgroundDark,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: MeritColors.textPrimaryDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: MeritColors.textPrimaryDark,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: MeritColors.textPrimaryDark,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryDark,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryDark,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: MeritColors.textPrimaryDark,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MeritColors.textPrimaryDark,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: MeritColors.textPrimaryDark,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: MeritColors.textSecondaryDark,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: MeritColors.textSecondaryDark,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryDark,
        ),
        labelMedium: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MeritColors.textSecondaryDark,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: MeritColors.textSecondaryDark,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: MeritColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: MeritColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeritDecorations.cardRadius),
          side: BorderSide(
            color: MeritColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MeritColors.backgroundDark,
        selectedItemColor: MeritColors.primary,
        unselectedItemColor: MeritColors.textSecondaryDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return MeritColors.surfaceElevated;
            }
            return MeritColors.primary;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                MeritDecorations.buttonRadius,
              ),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MeritColors.primary,
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MeritColors.primary,
          side: const BorderSide(color: MeritColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MeritDecorations.buttonRadius),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MeritColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MeritColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MeritColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MeritColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: MeritColors.textSecondaryDark,
        ),
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: MeritColors.textSecondaryDark,
        ),
        errorStyle: GoogleFonts.outfit(fontSize: 12, color: MeritColors.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MeritColors.surfaceElevated,
        selectedColor: MeritColors.primarySurface,
        labelStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: MeritColors.textPrimaryDark,
        ),
        side: BorderSide(
          color: MeritColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeritDecorations.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: MeritColors.border,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : MeritColors.textSecondaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? MeritColors.primary
              : MeritColors.surfaceElevated;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MeritColors.primary,
        linearTrackColor: MeritColors.surfaceElevated,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MeritColors.surfaceElevated,
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: MeritColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: MeritColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeritDecorations.cardRadius),
          side: BorderSide(
            color: MeritColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryDark,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: MeritColors.textSecondaryDark,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MeritColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: MeritColors.primary,
        primaryContainer: MeritColors.primarySurface,
        secondary: MeritColors.primaryLight,
        surface: MeritColors.surfaceLight,
        error: MeritColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: MeritColors.textPrimaryLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: MeritColors.backgroundLight,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: MeritColors.textPrimaryLight,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: MeritColors.textPrimaryLight,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: MeritColors.textPrimaryLight,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryLight,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryLight,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryLight,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: MeritColors.textPrimaryLight,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MeritColors.textPrimaryLight,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: MeritColors.textPrimaryLight,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: MeritColors.textSecondaryLight,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: MeritColors.textSecondaryLight,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryLight,
        ),
        labelMedium: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MeritColors.textSecondaryLight,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: MeritColors.textSecondaryLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: MeritColors.textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: MeritColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeritDecorations.cardRadius),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MeritColors.backgroundLight,
        selectedItemColor: MeritColors.primary,
        unselectedItemColor: MeritColors.textSecondaryLight,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return MeritColors.textSecondaryLight.withValues(alpha: 0.2);
            }
            return MeritColors.primary;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                MeritDecorations.buttonRadius,
              ),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MeritColors.primary,
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MeritColors.primary,
          side: const BorderSide(color: MeritColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MeritDecorations.buttonRadius),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MeritColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MeritColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MeritColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: MeritColors.textSecondaryLight,
        ),
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: MeritColors.textSecondaryLight,
        ),
        errorStyle: GoogleFonts.outfit(fontSize: 12, color: MeritColors.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.black.withValues(alpha: 0.06),
        selectedColor: MeritColors.primarySurface,
        labelStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: MeritColors.textPrimaryLight,
        ),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeritDecorations.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : MeritColors.textSecondaryLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? MeritColors.primary
              : Colors.black.withValues(alpha: 0.12);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MeritColors.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MeritColors.textPrimaryLight,
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: MeritColors.backgroundLight,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: MeritColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeritDecorations.cardRadius),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MeritColors.textPrimaryLight,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: MeritColors.textSecondaryLight,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MeritColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Backward-compatibility shims
//
// All existing callers that reference AppColors.* or DarisDecorations.*
// resolve to the MeritColors / MeritDecorations statics via these type
// aliases.  We cannot use class inheritance because MeritColors and
// MeritDecorations both have private constructors (_()).  Instead we expose
// static getters / methods that forward to the canonical implementations.
// ---------------------------------------------------------------------------

// ignore_for_file: non_constant_identifier_names

class AppColors {
  AppColors._();

  static const Color primary = MeritColors.primary;
  static const Color primaryLight = MeritColors.primaryLight;
  static const Color primaryDark = MeritColors.primaryDark;
  static const Color primarySurface = MeritColors.primarySurface;
  static const Color success = MeritColors.success;
  static const Color reward = MeritColors.reward;
  static const Color rewardDark = MeritColors.rewardDark;
  static const Color error = MeritColors.error;
  static const Color warning = MeritColors.warning;
  static const Color backgroundDark = MeritColors.backgroundDark;
  static const Color surfaceDark = MeritColors.surfaceDark;
  static const Color surfaceElevated = MeritColors.surfaceElevated;
  static const Color backgroundLight = MeritColors.backgroundLight;
  static const Color surfaceLight = MeritColors.surfaceLight;
  static const Color background = MeritColors.background;
  static const Color surface = MeritColors.surface;
  static const Color textPrimaryDark = MeritColors.textPrimaryDark;
  static const Color textSecondaryDark = MeritColors.textSecondaryDark;
  static const Color textPrimaryLight = MeritColors.textPrimaryLight;
  static const Color textSecondaryLight = MeritColors.textSecondaryLight;
  static const Color textPrimary = MeritColors.textPrimary;
  static const Color textSecondary = MeritColors.textSecondary;
  static const Color textTertiary = MeritColors.textTertiary;
  static const Color border = MeritColors.border;
  static const Color divider = MeritColors.divider;
  static const Color dividerDark = MeritColors.dividerDark;
  static const Color accentPurple = MeritColors.accentPurple;
  static const Color accentBlue = MeritColors.accentBlue;
  static const Color accentTeal = MeritColors.accentTeal;
  static const Color accentGreen = MeritColors.accentGreen;
  static const Color accentOrange = MeritColors.accentOrange;
  static const Color accentRed = MeritColors.accentRed;
  static const LinearGradient primaryGradient = MeritColors.primaryGradient;
  static const LinearGradient rewardGradient = MeritColors.rewardGradient;

  static Color flat(bool isDark) => MeritColors.flat(isDark);
  static LinearGradient backgroundGradient(bool isDark) =>
      MeritColors.backgroundGradient(isDark);
  static List<BoxShadow> get cardShadow => MeritColors.cardShadow;
  static List<BoxShadow> get elevatedShadow => MeritColors.elevatedShadow;
}

class DarisDecorations {
  DarisDecorations._();

  static const double cardRadius = MeritDecorations.cardRadius;
  static const double buttonRadius = MeritDecorations.buttonRadius;
  static const double pillRadius = MeritDecorations.pillRadius;
  static const double chipRadius = MeritDecorations.chipRadius;

  static BoxDecoration card(bool isDark) => MeritDecorations.card(isDark);
  static BoxDecoration elevatedCard(bool isDark) =>
      MeritDecorations.elevatedCard(isDark);
  static BoxDecoration pill(bool isDark) => MeritDecorations.pill(isDark);
  static BoxDecoration glassCard() => MeritDecorations.glassCard();
}
