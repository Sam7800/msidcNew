import 'package:flutter/material.dart';

/// App color palette for MSIDC Project Management System
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF3F3F46);
  static const Color primaryLight = Color(0xFF52525B);
  static const Color primaryDark = Color(0xFF27272A);
  static const Color primaryContainer = Color(0xFFF1F5F9);

  // Secondary colors
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryContainer = Color(0xFFF5F3FF);

  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF52525B);

  // Category colors
  static const Color categoryNashik = Color(0xFF3B82F6);
  static const Color categoryHAM = Color(0xFF10B981);
  static const Color categoryNagpur = Color(0xFFEF4444);
  static const Color categoryNHAI = Color(0xFFF59E0B);
  static const Color categoryOther = Color(0xFF8B5CF6);

  // Text colors
  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF71717A);
  static const Color textTertiary = Color(0xFFA1A1AA);
  static const Color textDisabled = Color(0xFFD4D4D8);

  // Border colors
  static const Color border = Color(0xFFE4E4E7);
  static const Color borderStrong = Color(0xFFD4D4D8);
  static const Color divider = Color(0xFFE4E4E7);
  static const Color outline = Color(0xFFE4E4E7);

  // Shadow colors
  static const Color shadow = Color(0x08000000);
  static const Color shadowLight = Color(0x05000000);
  static const Color shadowMedium = Color(0x0A000000);
  static const Color shadowColor = Color(0x1A000000);

  // Additional colors
  static const Color white = Color(0xFFFFFFFF);

  /// Get category color by name
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Nashik Kumbhmela':
        return categoryNashik;
      case 'HAM Projects':
        return categoryHAM;
      case 'Nagpur Works':
        return categoryNagpur;
      case 'NHAI Projects':
        return categoryNHAI;
      case 'Other Projects':
        return categoryOther;
      default:
        return primary;
    }
  }

  /// Get spectrum gradient (for splash screen)
  static LinearGradient get spectrumGradient => const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF06B6D4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
