import 'package:flutter/material.dart';

/// Enum representing the different sections in the Review screen
///
/// Used for filtering which components to display in the grid
enum ReviewSection {
  /// Show all components from all sections
  all('All', Icons.dashboard),

  /// Show only DPR (Detailed Project Report) section components
  dpr('DPR', Icons.description),

  /// Show only Work section components
  work('Work', Icons.work),

  /// Show only PMS (Project Monitoring System) section components
  pms('PMS', Icons.analytics);

  /// Human-readable label for the section
  final String label;

  /// Icon to display for this section
  final IconData icon;

  const ReviewSection(this.label, this.icon);
}
