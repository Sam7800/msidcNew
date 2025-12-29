import 'package:flutter/material.dart';
import 'review_section.dart';

/// Enum representing all possible component types in the Review screen
enum ReviewComponentType {
  // DPR Section components (16)
  aa,
  dpr,
  boq,
  schedules,
  drawings,
  bidDocuments,
  envClearance,
  landAcquisition,
  utilityShifting,
  csd,
  bidSubmission,
  techEvaluation,
  financialBid,
  bidAcceptance,
  loa,
  pbg,

  // Work Section components (8)
  ts,
  nit,
  prebid,
  workOrder,
  agreementAmount,
  appointedDate,
  tenderPeriod,
  supplementaryAgreement,

  // PMS Section components (9)
  milestone1,
  milestone2,
  milestone3,
  milestone4,
  milestone5,
  ld,
  eot,
  cos,
  expenditure,
  auditPara,
  laq,
  technicalAudit,
  revAA,
}

/// Configuration class for each Review component
///
/// Defines metadata about a component including which section it belongs to,
/// what data fields it needs, its visual appearance, and display properties
class ReviewComponentConfig {
  /// Unique type identifier for this component
  final ReviewComponentType type;

  /// Unique string ID for this component (used for state management)
  final String id;

  /// Display title for the component
  final String title;

  /// Which section this component belongs to (DPR, Work, or PMS)
  final ReviewSection section;

  /// List of field keys from WorkEntryData to extract for this component
  /// Example: ['aa_status', 'aa_amount', 'broad_scope_aa']
  final List<String> fieldKeys;

  /// Optional field key that determines the current state of the component
  /// Example: 'aa_status' might be 'awaited' or 'accorded'
  final String? stateField;

  /// Map defining different states and their required fields
  /// Example: {'awaited': ['aa_status'], 'accorded': ['aa_status', 'aa_amount']}
  final Map<String, List<String>>? states;

  /// Primary color for this component (used in header, borders, etc.)
  final Color primaryColor;

  /// Icon to display for this component
  final IconData icon;

  /// Short description shown in hover preview
  final String? description;

  const ReviewComponentConfig({
    required this.type,
    required this.id,
    required this.title,
    required this.section,
    required this.fieldKeys,
    this.stateField,
    this.states,
    required this.primaryColor,
    required this.icon,
    this.description,
  });

  @override
  String toString() => 'ReviewComponentConfig($id - $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewComponentConfig &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
