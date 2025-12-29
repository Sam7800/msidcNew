import 'package:flutter/material.dart';
import '../domain/models/review_component_config.dart';

/// Utilities for calculating responsive grid layout properties
class ReviewGridLayout {
  /// Calculate number of columns based on screen width
  ///
  /// Breakpoints (for compact button cards):
  /// - >1600px: 8 columns (large desktop)
  /// - >1200px: 6 columns (desktop)
  /// - >800px: 4 columns (tablet)
  /// - <800px: 3 columns (mobile)
  static int calculateColumns(double screenWidth) {
    if (screenWidth > 1600) return 8;
    if (screenWidth > 1200) return 6;
    if (screenWidth > 800) return 4;
    return 3;
  }

  /// Calculate card height based on expansion state and component type
  ///
  /// Heights:
  /// - Collapsed: 120px (all types) - compact size
  /// - Expanded simple: 250px (AA, TS, simple 2-state)
  /// - Expanded standard: 300px (most components)
  /// - Expanded complex: 400px (components with tables, milestones)
  static double calculateCardHeight({
    required bool isExpanded,
    required ReviewComponentType type,
  }) {
    if (!isExpanded) return 120; // Collapsed height - smaller

    // Expanded heights vary by component complexity
    switch (type) {
      // Complex components with tables or multiple sub-sections
      case ReviewComponentType.boq:
      case ReviewComponentType.ts:
      case ReviewComponentType.nit:
      case ReviewComponentType.milestone1:
      case ReviewComponentType.milestone2:
      case ReviewComponentType.milestone3:
      case ReviewComponentType.milestone4:
      case ReviewComponentType.milestone5:
      case ReviewComponentType.cos:
      case ReviewComponentType.auditPara:
      case ReviewComponentType.laq:
        return 400;

      // Simple 2-state components
      case ReviewComponentType.aa:
      case ReviewComponentType.loa:
      case ReviewComponentType.pbg:
      case ReviewComponentType.appointedDate:
      case ReviewComponentType.tenderPeriod:
      case ReviewComponentType.agreementAmount:
        return 250;

      // Standard components
      default:
        return 300;
    }
  }

  /// Get padding for cards in the grid
  static EdgeInsets getCardPadding() {
    return const EdgeInsets.all(12);
  }

  /// Get spacing between cards
  static double getCardSpacing() {
    return 16;
  }

  /// Get grid padding (outer padding around entire grid)
  static EdgeInsets getGridPadding() {
    return const EdgeInsets.all(20);
  }

  /// Calculate child aspect ratio for GridView
  ///
  /// Returns width/height ratio for grid items
  /// For compact button cards: 1.8 (wider than tall for better text fit)
  static double getChildAspectRatio() {
    return 1.8;
  }

  /// Get responsive font size for card title
  static double getTitleFontSize(double screenWidth) {
    if (screenWidth > 1200) return 16;
    if (screenWidth > 800) return 15;
    return 14;
  }

  /// Get responsive icon size for cards
  static double getIconSize(double screenWidth) {
    if (screenWidth > 1200) return 24;
    if (screenWidth > 800) return 22;
    return 20;
  }

  /// Check if device is mobile (single column layout)
  static bool isMobile(double screenWidth) {
    return screenWidth <= 800;
  }

  /// Check if device is tablet (2 column layout)
  static bool isTablet(double screenWidth) {
    return screenWidth > 800 && screenWidth <= 1200;
  }

  /// Check if device is desktop (3+ column layout)
  static bool isDesktop(double screenWidth) {
    return screenWidth > 1200;
  }

  /// Get hover preview offset
  ///
  /// Returns horizontal offset for hover preview tooltip
  /// - Desktop: 300px to the right
  /// - Mobile: 0px (show above/below instead)
  static double getHoverPreviewOffset(double screenWidth) {
    return isMobile(screenWidth) ? 0 : 300;
  }

  /// Get animation duration for card expansion
  static Duration getExpansionDuration() {
    return const Duration(milliseconds: 300);
  }

  /// Get animation curve for card expansion
  static Curve getExpansionCurve() {
    return Curves.easeInOutCubic;
  }
}
