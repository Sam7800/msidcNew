import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// Utilities for formatting and styling component status information
class ComponentStatusUtils {
  /// Get color based on status string
  ///
  /// Maps common status keywords to appropriate colors:
  /// - Green: Completed, Approved, Accorded, Submitted
  /// - Blue: In Progress, Submitted, Issued
  /// - Orange: Awaited, Pending, Not Started
  /// - Red: Rejected, Failed, Not Issued
  /// - Gray: Default/Unknown
  static Color getStatusColor(String? status) {
    if (status == null || status.isEmpty) {
      return AppColors.textSecondary;
    }

    final lower = status.toLowerCase().trim();

    // Success states (Green)
    if (lower.contains('completed') ||
        lower.contains('approved') ||
        lower.contains('accorded') ||
        lower.contains('achieved') ||
        lower.contains('qualified') ||
        lower.contains('accepted')) {
      return AppColors.success;
    }

    // Progress states (Blue)
    if (lower.contains('progress') ||
        lower.contains('issued') ||
        lower.contains('submitted') ||
        lower.contains('uploaded')) {
      return AppColors.info;
    }

    // Warning states (Orange)
    if (lower.contains('awaited') ||
        lower.contains('pending') ||
        lower.contains('not started') ||
        lower.contains('consideration')) {
      return AppColors.warning;
    }

    // Error states (Red)
    if (lower.contains('rejected') ||
        lower.contains('failed') ||
        lower.contains('not issued') ||
        lower.contains('not submitted')) {
      return AppColors.error;
    }

    // Default (Gray)
    return AppColors.textSecondary;
  }

  /// Format status string for display
  ///
  /// Converts snake_case or camelCase to Title Case
  /// Example: 'in_progress' → 'In Progress'
  /// Example: 'notStarted' → 'Not Started'
  static String formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Not Started';

    // Replace underscores and split by capital letters
    final words = status
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .split(' ');

    // Capitalize first letter of each word
    return words
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Format currency value for display
  ///
  /// Example: 123.45 → '₹ 123.45 Lakhs'
  /// Example: 1234.56 (inCrore: true) → '₹ 1,234.56 Cr'
  static String formatCurrency(dynamic value, {bool inCrore = false}) {
    if (value == null) return 'N/A';

    final num = double.tryParse(value.toString()) ?? 0;

    if (num == 0) return 'N/A';

    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    final formatted = formatter.format(num);

    if (inCrore) {
      return '₹ $formatted Cr';
    } else {
      return '₹ $formatted Lakhs';
    }
  }

  /// Format date value for display
  ///
  /// Example: '2024-12-26' → '26 Dec 2024'
  /// Returns 'Not set' if value is null or invalid
  static String formatDate(dynamic value) {
    if (value == null) return 'Not set';

    try {
      DateTime date;
      if (value is DateTime) {
        date = value;
      } else {
        date = DateTime.parse(value.toString());
      }
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return value.toString().isEmpty ? 'Not set' : value.toString();
    }
  }

  /// Format percentage value for display
  ///
  /// Example: 75.5 → '75.5%'
  /// Example: null → 'N/A'
  static String formatPercentage(dynamic value) {
    if (value == null) return 'N/A';

    final num = double.tryParse(value.toString()) ?? 0;
    return '${num.toStringAsFixed(1)}%';
  }

  /// Format number value for display
  ///
  /// Example: 1234 → '1,234'
  /// Example: null → 'N/A'
  static String formatNumber(dynamic value) {
    if (value == null) return 'N/A';

    final num = double.tryParse(value.toString()) ?? 0;

    if (num == 0) return 'N/A';

    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return formatter.format(num);
  }

  /// Get formatted field value based on field name
  ///
  /// Auto-detects field type and applies appropriate formatting
  static String formatFieldValue(String fieldName, dynamic value) {
    if (value == null) return 'Not provided';

    final lower = fieldName.toLowerCase();

    // Date fields
    if (lower.contains('date')) {
      return formatDate(value);
    }

    // Currency fields
    if (lower.contains('amount') ||
        lower.contains('cost') ||
        lower.contains('price') ||
        lower.contains('bid')) {
      final isCrore = lower.contains('crore') || lower.contains('cr');
      return formatCurrency(value, inCrore: isCrore);
    }

    // Percentage fields
    if (lower.contains('percent') ||
        lower.contains('%') ||
        lower.contains('completion')) {
      return formatPercentage(value);
    }

    // Number fields
    if (lower.contains('count') ||
        lower.contains('number') ||
        lower.contains('qty') ||
        lower.contains('quantity')) {
      return formatNumber(value);
    }

    // Status fields
    if (lower.contains('status')) {
      return formatStatus(value.toString());
    }

    // Default: return as string
    return value.toString();
  }

  /// Get color for completion percentage
  ///
  /// Returns color based on completion level:
  /// - Red: 0-39%
  /// - Orange: 40-69%
  /// - Blue: 70-89%
  /// - Green: 90-100%
  static Color getCompletionColor(double percent) {
    if (percent >= 90) {
      return AppColors.success;
    } else if (percent >= 70) {
      return AppColors.info;
    } else if (percent >= 40) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  /// Check if a field has a valid value (not null, not empty)
  static bool hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String && value.trim().isEmpty) return false;
    return true;
  }
}
