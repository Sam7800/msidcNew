import 'package:flutter/material.dart';

/// App color palette for MSIDC Project Management System
/// Claude.com inspired - Professional, calm, monitoring-focused design
class AppColors {
  // Primary colors - Professional Dark Grey (Claude-style)
  static const Color primary = Color(0xFF3F3F46); // Dark Slate Grey - calm, professional
  static const Color primaryLight = Color(0xFF52525B); // Medium-dark grey
  static const Color primaryDark = Color(0xFF27272A); // Very dark grey
  static const Color primaryContainer = Color(0xFFF1F5F9); // Light grey container

  // Secondary colors - Subtle Purple accent (reserved for highlights)
  static const Color secondary = Color(0xFF8B5CF6); // Professional purple
  static const Color secondaryLight = Color(0xFFA78BFA); // Light purple
  static const Color secondaryDark = Color(0xFF7C3AED); // Deep purple
  static const Color secondaryContainer = Color(0xFFF5F3FF); // Very light purple

  // Tertiary colors - Professional Cyan (for accents)
  static const Color tertiary = Color(0xFF06B6D4); // Professional Cyan
  static const Color tertiaryLight = Color(0xFF22D3EE); // Light cyan
  static const Color tertiaryDark = Color(0xFF0891B2); // Deep cyan

  // Background colors - Calm neutrals for monitoring
  static const Color background = Color(0xFFFAFAFA); // Off-white - easier on eyes
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Light blue-grey
  static const Color surfaceDark = Color(0xFF1A1C1E); // Dark mode surface

  // Status colors - Professional & clear (less vibrant)
  static const Color success = Color(0xFF10B981); // Emerald green - professional
  static const Color warning = Color(0xFFF59E0B); // Warm amber
  static const Color error = Color(0xFFEF4444); // Softer red
  static const Color info = Color(0xFF52525B); // Grey for info (not bright blue)

  // Category colors - Distinctive but professional (reduced saturation)
  static const Color categoryNashik = Color(0xFF3B82F6); // Professional Blue
  static const Color categoryHAM = Color(0xFF10B981); // Emerald Green
  static const Color categoryNagpur = Color(0xFFEF4444); // Professional Red
  static const Color categoryNHAI = Color(0xFFF59E0B); // Warm Amber
  static const Color categoryOther = Color(0xFF8B5CF6); // Professional Purple

  // Text colors - Optimized contrast for monitoring
  static const Color textPrimary = Color(0xFF18181B); // Almost black, high contrast
  static const Color textSecondary = Color(0xFF71717A); // Medium grey
  static const Color textTertiary = Color(0xFFA1A1AA); // Light grey for labels
  static const Color textDisabled = Color(0xFFD4D4D8); // Very light grey
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on dark
  static const Color textOnSecondary = Color(0xFFFFFFFF); // White

  // Border colors - Subtle, professional separation
  static const Color border = Color(0xFFE4E4E7); // Standard border - soft grey
  static const Color borderStrong = Color(0xFFD4D4D8); // Emphasized border
  static const Color borderLight = Color(0xFFF4F4F5); // Subtle border
  static const Color outline = Color(0xFFA1A1AA); // Outline color

  // Hover & Interactive states
  static const Color hover = Color(0xFFF1F5F9); // Hover background
  static const Color active = Color(0xFFE4E4E7); // Active/selected state
  static const Color pressed = Color(0xFFD4D4D8); // Pressed state

  // Milestone completion colors (professional)
  static const Color completionLow = Color(0xFFEF4444); // Red - 0-33%
  static const Color completionMedium = Color(0xFFF59E0B); // Amber - 34-66%
  static const Color completionHigh = Color(0xFF10B981); // Emerald - 67-100%

  // Gradient colors for special elements only (reduced usage)
  static const Color gradientStart = Color(0xFF3B82F6);
  static const Color gradientMiddle = Color(0xFF8B5CF6);
  static const Color gradientEnd = Color(0xFF06B6D4);

  // Accent colors for highlights (more professional tones)
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentLime = Color(0xFF84CC16);

  // Shadows - Minimal, subtle (border-first approach)
  static const Color shadow = Color(0x08000000); // 5% black - very subtle
  static const Color shadowLight = Color(0x05000000); // 3% black - barely visible
  static const Color shadowMedium = Color(0x0A000000); // 6% black

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

  /// Get primary gradient (subtle - use sparingly, mainly for splash screen)
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [gradientStart, gradientMiddle],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get vibrant gradient (reserved for special accents only)
  static LinearGradient get vibrantGradient => const LinearGradient(
        colors: [gradientMiddle, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get full spectrum gradient (splash screen only)
  static LinearGradient get spectrumGradient => const LinearGradient(
        colors: [gradientStart, gradientMiddle, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get category gradient by name (subtle, for small accent badges only)
  static LinearGradient getCategoryGradient(String category) {
    final baseColor = getCategoryColor(category);
    final lightColor = Color.alphaBlend(
      Colors.white.withOpacity(0.4),
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

  /// Get subtle background for category badges (preferred over gradients)
  static Color getCategoryBackgroundLight(String category) {
    return getCategoryColor(category).withOpacity(0.10);
  }

  /// Get category border color (for accent borders)
  static Color getCategoryBorderColor(String category) {
    return getCategoryColor(category).withOpacity(0.30);
  }
}
