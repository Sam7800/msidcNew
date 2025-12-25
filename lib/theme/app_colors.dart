import 'package:flutter/material.dart';

/// App color palette for MSIDC Project Management System
/// Modern, vibrant Material You inspired design
class AppColors {
  // Primary colors - Vibrant Blue
  static const Color primary = Color(0xFF0061FF); // Electric Blue
  static const Color primaryLight = Color(0xFF4D8FFF);
  static const Color primaryDark = Color(0xFF0047B3);
  static const Color primaryContainer = Color(0xFFD6E3FF);

  // Secondary colors - Vibrant Purple accent
  static const Color secondary = Color(0xFF7C4DFF); // Vibrant Purple
  static const Color secondaryLight = Color(0xFFB47CFF);
  static const Color secondaryDark = Color(0xFF5E35B1);
  static const Color secondaryContainer = Color(0xFFE8DDFF);

  // Tertiary colors - Energetic Cyan
  static const Color tertiary = Color(0xFF00D9FF); // Bright Cyan
  static const Color tertiaryLight = Color(0xFF66E5FF);
  static const Color tertiaryDark = Color(0xFF00A3BF);

  // Background colors - Modern neutrals
  static const Color background = Color(0xFFFBFCFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F6FA);
  static const Color surfaceDark = Color(0xFF1A1C1E);

  // Status colors - Vibrant & clear
  static const Color success = Color(0xFF00C853); // Vibrant Green
  static const Color warning = Color(0xFFFFAB00); // Bright Amber
  static const Color error = Color(0xFFFF3D00); // Bright Red
  static const Color info = Color(0xFF00B0FF); // Bright Blue

  // Category colors - Bold & distinctive
  static const Color categoryNashik = Color(0xFF0061FF); // Electric Blue
  static const Color categoryHAM = Color(0xFF00E676); // Neon Green
  static const Color categoryNagpur = Color(0xFFFF1744); // Vibrant Red
  static const Color categoryNHAI = Color(0xFFFF9100); // Bright Orange
  static const Color categoryOther = Color(0xFF9C27B0); // Deep Purple

  // Text colors - High contrast for readability
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textDisabled = Color(0xFFBDC1C6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Border colors - Subtle and modern
  static const Color border = Color(0xFFDEE1E6);
  static const Color outline = Color(0xFF79747E);
  static const Color borderLight = Color(0xFFF1F3F5);
  static const Color borderDark = Color(0xFFADB3BA);

  // Milestone completion colors (vibrant gradient)
  static const Color completionLow = Color(0xFFFF3D00); // Bright Red - 0-33%
  static const Color completionMedium = Color(0xFFFFAB00); // Bright Amber - 34-66%
  static const Color completionHigh = Color(0xFF00C853); // Vibrant Green - 67-100%

  // Gradient colors for visual interest
  static const Color gradientStart = Color(0xFF0061FF);
  static const Color gradientMiddle = Color(0xFF7C4DFF);
  static const Color gradientEnd = Color(0xFF00D9FF);

  // Accent colors for highlights
  static const Color accentPink = Color(0xFFFF4081);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color accentIndigo = Color(0xFF536DFE);
  static const Color accentLime = Color(0xFFC6FF00);

  // Card elevation shadow - Modern soft shadow
  static const Color shadow = Color(0x14000000);
  static const Color shadowHeavy = Color(0x29000000);

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

  /// Get completion status color based on percentage
  static Color getCompletionColor(double percentage) {
    if (percentage < 34) {
      return completionLow;
    } else if (percentage < 67) {
      return completionMedium;
    } else {
      return completionHigh;
    }
  }

  /// Get status color by status text
  static Color getStatusColor(String status) {
    final lowercaseStatus = status.toLowerCase();

    if (lowercaseStatus.contains('complete') ||
        lowercaseStatus.contains('approved') ||
        lowercaseStatus.contains('done')) {
      return success;
    } else if (lowercaseStatus.contains('pending') ||
        lowercaseStatus.contains('progress') ||
        lowercaseStatus.contains('processing')) {
      return warning;
    } else if (lowercaseStatus.contains('rejected') ||
        lowercaseStatus.contains('failed') ||
        lowercaseStatus.contains('overdue')) {
      return error;
    } else {
      return info;
    }
  }

  /// Get primary gradient (for modern cards and headers)
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [gradientStart, gradientMiddle],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get vibrant gradient (for accent elements)
  static LinearGradient get vibrantGradient => const LinearGradient(
        colors: [gradientMiddle, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get full spectrum gradient (for special highlights)
  static LinearGradient get spectrumGradient => const LinearGradient(
        colors: [gradientStart, gradientMiddle, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get category gradient by name
  static LinearGradient getCategoryGradient(String category) {
    final baseColor = getCategoryColor(category);
    final lightColor = Color.alphaBlend(
      Colors.white.withOpacity(0.3),
      baseColor,
    );
    return LinearGradient(
      colors: [baseColor, lightColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Get shimmer gradient for loading states
  static LinearGradient get shimmerGradient => LinearGradient(
        colors: [
          borderLight,
          surface,
          borderLight,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
