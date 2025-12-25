import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme configuration using Material 3
class AppTheme {
  /// Light theme - Professional & Calm (Claude-inspired)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        surfaceVariant: AppColors.surfaceVariant,
        error: AppColors.error,
        brightness: Brightness.light,
      ),

      // App bar theme - Clean, minimal (white with border bottom)
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0, // Flat, no shadow even when scrolled
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600, // Reduced from w700
          color: AppColors.textPrimary,
          letterSpacing: -0.2, // Tighter, modern spacing
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),

      // Card theme - Border-based, minimal shadow
      cardTheme: CardThemeData(
        elevation: 0, // No elevation, use border instead
        shadowColor: Colors.transparent,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Reduced from 16
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // More breathing room
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated button theme - Flat, professional
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // Flat design
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 40), // Consistent height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Cleaner, reduced from 12
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500, // Reduced from w700
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500, // Reduced from w700
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Reduced from 12
          ),
          side: const BorderSide(color: AppColors.border, width: 1), // Subtle border
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500, // Reduced from w700
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Floating Action Button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2, // Reduced from 4
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        sizeConstraints: BoxConstraints.tightFor(
          width: 56,
          height: 56,
        ),
      ),

      // Input decoration theme - Clean, white background
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface, // White, not grey
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced from 12
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5), // Reduced from 2.5
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500, // Reduced from w600
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500, // Reduced from w700
          color: AppColors.primary,
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textTertiary, // Lighter hint color
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400, // Reduced from w600
          color: AppColors.error,
        ),
      ),

      // Data table theme - Minimal, clean tables
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          AppColors.surfaceVariant, // Subtle grey, not colored
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.hover; // Very subtle hover
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainer.withOpacity(0.15); // Reduced from 0.3
          }
          return null;
        }),
        headingTextStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600, // Reduced from w800
          color: AppColors.textPrimary, // Dark text, not colored
          letterSpacing: 0.3,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400, // Reduced from w500
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(8), // Reduced from 12
        ),
      ),

      // Chip theme - Subtle, professional chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500, // Reduced from w700
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: AppColors.border, width: 1),
        elevation: 0, // Flat
      ),

      // Dialog theme - Clean, minimal elevation
      dialogTheme: DialogThemeData(
        elevation: 2, // Reduced from 8
        shadowColor: AppColors.shadow,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Reduced from 24
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600, // Reduced from w800
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400, // Reduced from w500
          color: AppColors.textSecondary,
          height: 1.6, // Increased from 1.5 for better readability
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 16,
      ),

      // Tab bar theme - Minimal, clean tabs
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2), // Reduced from 3
          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600, // Reduced from w800
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500, // Reduced from w600
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400, // Reduced from w600
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Reduced from 12
        ),
        elevation: 2, // Reduced from 4
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600, // Reduced from w700
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500, // Reduced from w600
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0, // Flat with border instead
      ),

      // Text theme - Professional, readable typography
      textTheme: const TextTheme(
        // Display styles - for large headlines
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700, // Reduced from w900
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600, // Reduced from w800
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600, // Reduced from w700
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        // Headlines - for section headers
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600, // Reduced from w800
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600, // Same weight
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600, // Same weight
          color: AppColors.textPrimary,
          letterSpacing: 0,
          height: 1.4,
        ),
        // Titles - for cards and components
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600, // Same weight
          color: AppColors.textPrimary,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600, // Same weight
          color: AppColors.textPrimary,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600, // Same weight
          color: AppColors.textPrimary,
          letterSpacing: 0,
          height: 1.4,
        ),
        // Body text - for content
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400, // Reduced from w500
          color: AppColors.textPrimary,
          height: 1.6, // Increased for better readability
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400, // Reduced from w500
          color: AppColors.textPrimary,
          height: 1.6, // Increased
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400, // Reduced from w500
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        // Labels - for UI elements
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500, // Reduced from w700
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500, // Reduced from w700
          color: AppColors.textSecondary,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500, // Reduced from w700
          color: AppColors.textTertiary,
          letterSpacing: 0.1,
        ),
      ),

      // Scaffold background
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  /// Dark theme (optional, for future)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
