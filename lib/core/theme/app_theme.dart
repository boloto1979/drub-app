import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  // Dark
  static const background = Color(0xFF0F0B08);
  static const surface = Color(0xFF1C1510);
  static const surfaceVariant = Color(0xFF2A1F18);
  static const gold = Color(0xFFC4973A);
  static const goldLight = Color(0xFFDFB96A);
  static const goldDim = Color(0xFF8A6825);
  static const maroon = Color(0xFF7B2230);
  static const maroonLight = Color(0xFF9E3040);
  static const textPrimary = Color(0xFFF0E6D0);
  static const textSecondary = Color(0xFFB09070);
  static const textMuted = Color(0xFF6B5540);
  static const divider = Color(0xFF2E2318);

  // Light
  static const lightBackground = Color(0xFFF7F2EA);
  static const lightSurface = Color(0xFFEDE5D5);
  static const lightSurfaceVariant = Color(0xFFE0D4BE);
  static const lightTextPrimary = Color(0xFF1E1510);
  static const lightTextSecondary = Color(0xFF6B4F2A);
  static const lightTextMuted = Color(0xFFAA8860);
  static const lightDivider = Color(0xFFD4C4A8);
}

abstract class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.cormorantGaramondTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.background,
        secondary: AppColors.maroon,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        outline: AppColors.divider,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.5,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.2,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          height: 1.7,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        labelLarge: GoogleFonts.poppins(
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
        labelMedium: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
          fontSize: 11,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.goldDim.withOpacity(0.3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.gold, size: 22);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              color: AppColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            );
          }
          return GoogleFonts.poppins(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 1.0,
          );
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.goldDim,
          foregroundColor: AppColors.textPrimary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.cormorantGaramondTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.goldDim,
        onPrimary: AppColors.lightBackground,
        secondary: AppColors.maroon,
        onSecondary: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        outline: AppColors.lightDivider,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          height: 1.7,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextSecondary,
          height: 1.6,
        ),
        labelLarge: GoogleFonts.poppins(
          color: AppColors.goldDim,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
        labelMedium: GoogleFonts.poppins(
          color: AppColors.lightTextSecondary,
          letterSpacing: 1.2,
          fontSize: 11,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.goldDim),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.goldDim.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.goldDim, size: 22);
          }
          return const IconThemeData(color: AppColors.lightTextMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              color: AppColors.goldDim,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            );
          }
          return GoogleFonts.poppins(
            color: AppColors.lightTextMuted,
            fontSize: 10,
            letterSpacing: 1.0,
          );
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.lightDivider, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.goldDim,
          foregroundColor: AppColors.lightBackground,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextSecondary),
    );
  }
}

