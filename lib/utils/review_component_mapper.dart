import 'package:flutter/material.dart';
import '../domain/models/review_component_config.dart';
import '../domain/models/review_section.dart';
import '../data/models/work_entry_data.dart';
import '../theme/app_colors.dart';

/// Utility class for mapping WorkEntryData fields to Review components
///
/// This class serves as the central configuration hub that:
/// - Defines all component configurations
/// - Maps field keys from WorkEntryData to components
/// - Extracts component-specific data
/// - Determines component state based on field values
class ReviewComponentMapper {
  /// Get all configured components for the Review screen
  ///
  /// Returns all 37 components grouped in 4 visual rows as per user design
  static List<ReviewComponentConfig> getAllComponents() {
    return [
      // ============================================================
      // ROW 1: DPR Documents (10 components)
      // ============================================================

      ReviewComponentConfig(
        type: ReviewComponentType.aa,
        id: 'AA',
        title: 'Administrative Approval',
        section: ReviewSection.dpr,
        fieldKeys: ['aa_status', 'broad_scope_aa', 'aa_amount', 'aa_sanctioned_date'],
        stateField: 'aa_status',
        primaryColor: const Color(0xFF6366F1),
        icon: Icons.approval,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.dpr,
        id: 'DPR',
        title: 'Detailed Project Report',
        section: ReviewSection.dpr,
        fieldKeys: ['dpr_status', 'dpr_name', 'broad_scope_dpr', 'dpr_pa_name', 'dpr_submitted_date', 'dpr_approved_date'],
        stateField: 'dpr_status',
        primaryColor: const Color(0xFF3B82F6),
        icon: Icons.description,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.boq,
        id: 'BOQ',
        title: 'Bill of Quantities',
        section: ReviewSection.dpr,
        fieldKeys: ['boq_status', 'boq_items'],
        stateField: 'boq_status',
        primaryColor: const Color(0xFF06B6D4),
        icon: Icons.table_chart,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.schedules,
        id: 'Sch',
        title: 'Schedules',
        section: ReviewSection.dpr,
        fieldKeys: ['schedules_status'],
        stateField: 'schedules_status',
        primaryColor: const Color(0xFF14B8A6),
        icon: Icons.schedule,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.drawings,
        id: 'Dwg',
        title: 'Drawings',
        section: ReviewSection.dpr,
        fieldKeys: ['drawings_status'],
        stateField: 'drawings_status',
        primaryColor: const Color(0xFF10B981),
        icon: Icons.draw,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.bidDocuments,
        id: 'Bid Doc',
        title: 'Bid Documents',
        section: ReviewSection.dpr,
        fieldKeys: ['bid_documents_status'],
        stateField: 'bid_documents_status',
        primaryColor: const Color(0xFF84CC16),
        icon: Icons.folder,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.envClearance,
        id: 'ENV',
        title: 'Environmental Clearance',
        section: ReviewSection.dpr,
        fieldKeys: ['env_clearance_status'],
        stateField: 'env_clearance_status',
        primaryColor: const Color(0xFF22C55E),
        icon: Icons.eco,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.landAcquisition,
        id: 'LA',
        title: 'Land Acquisition',
        section: ReviewSection.dpr,
        fieldKeys: ['land_acquisition_status'],
        stateField: 'land_acquisition_status',
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.landscape,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.utilityShifting,
        id: 'Utility',
        title: 'Utility Shifting',
        section: ReviewSection.dpr,
        fieldKeys: ['utility_shifting_status'],
        stateField: 'utility_shifting_status',
        primaryColor: const Color(0xFFEAB308),
        icon: Icons.build,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.ts,
        id: 'TS',
        title: 'Technical Sanction',
        section: ReviewSection.work,
        fieldKeys: ['ts_status', 'ts_accorded_date', 'ts_sanctioned_cost', 'ts_items'],
        stateField: 'ts_status',
        primaryColor: const Color(0xFF10B981),
        icon: Icons.verified,
      ),

      // ============================================================
      // ROW 2: Bidding & Award (10 components)
      // ============================================================

      ReviewComponentConfig(
        type: ReviewComponentType.nit,
        id: 'NIT',
        title: 'Notice Inviting Tender',
        section: ReviewSection.work,
        fieldKeys: ['nit_status', 'nit_issued_date', 'nit_bid_submission_date', 'nit_method', 'nit_type'],
        stateField: 'nit_status',
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.announcement,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.prebid,
        id: 'Pre-bid',
        title: 'Pre-bid Meeting',
        section: ReviewSection.work,
        fieldKeys: ['prebid_status', 'prebid_date'],
        stateField: 'prebid_status',
        primaryColor: const Color(0xFFEAB308),
        icon: Icons.meeting_room,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.csd,
        id: 'CSD',
        title: 'Call for Sealed Document',
        section: ReviewSection.dpr,
        fieldKeys: ['csd_status'],
        stateField: 'csd_status',
        primaryColor: const Color(0xFF8B5CF6),
        icon: Icons.lock,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.bidSubmission,
        id: 'Bid Sub',
        title: 'Bid Submission',
        section: ReviewSection.dpr,
        fieldKeys: ['bid_submission_status', 'bid_submission_date'],
        stateField: 'bid_submission_status',
        primaryColor: const Color(0xFFA78BFA),
        icon: Icons.upload,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.techEvaluation,
        id: 'Tech Eval',
        title: 'Technical Evaluation',
        section: ReviewSection.dpr,
        fieldKeys: ['tech_evaluation_status'],
        stateField: 'tech_evaluation_status',
        primaryColor: const Color(0xFF6366F1),
        icon: Icons.assessment,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.financialBid,
        id: 'Fin Bid',
        title: 'Financial Bid',
        section: ReviewSection.dpr,
        fieldKeys: ['financial_bid_status'],
        stateField: 'financial_bid_status',
        primaryColor: const Color(0xFF3B82F6),
        icon: Icons.attach_money,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.bidAcceptance,
        id: 'Bid Accept',
        title: 'Bid Acceptance',
        section: ReviewSection.dpr,
        fieldKeys: ['bid_acceptance_status'],
        stateField: 'bid_acceptance_status',
        primaryColor: const Color(0xFF06B6D4),
        icon: Icons.check_circle,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.loa,
        id: 'LOA',
        title: 'Letter of Acceptance',
        section: ReviewSection.dpr,
        fieldKeys: ['loa_status', 'loa_date'],
        stateField: 'loa_status',
        primaryColor: const Color(0xFF14B8A6),
        icon: Icons.mail,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.workOrder,
        id: 'Work Order',
        title: 'Work Order',
        section: ReviewSection.work,
        fieldKeys: ['work_order_number', 'work_order_issue_date', 'contractor_name'],
        stateField: null,
        primaryColor: const Color(0xFF10B981),
        icon: Icons.work,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.pbg,
        id: 'PBG',
        title: 'Performance Bank Guarantee',
        section: ReviewSection.dpr,
        fieldKeys: ['pbg_status', 'pbg_amount'],
        stateField: 'pbg_status',
        primaryColor: const Color(0xFF84CC16),
        icon: Icons.account_balance,
      ),

      // ============================================================
      // ROW 3: Contract & Milestones (11 components)
      // ============================================================

      ReviewComponentConfig(
        type: ReviewComponentType.agreementAmount,
        id: 'Agr Amt',
        title: 'Agreement Amount',
        section: ReviewSection.work,
        fieldKeys: ['agreement_amount'],
        stateField: null,
        primaryColor: const Color(0xFF22C55E),
        icon: Icons.currency_rupee,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.appointedDate,
        id: 'App Date',
        title: 'Appointed Date',
        section: ReviewSection.work,
        fieldKeys: ['appointed_date'],
        stateField: null,
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.calendar_today,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.tenderPeriod,
        id: 'Tender',
        title: 'Tender Period',
        section: ReviewSection.work,
        fieldKeys: ['tender_period'],
        stateField: null,
        primaryColor: const Color(0xFFEAB308),
        icon: Icons.timelapse,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone1,
        id: 'MS-I',
        title: 'Milestone I',
        section: ReviewSection.pms,
        fieldKeys: ['ms1_description', 'ms1_target_date', 'ms1_target_amount', 'ms1_achievement_date', 'ms1_achievement_amount'],
        stateField: null,
        primaryColor: const Color(0xFF8B5CF6),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone2,
        id: 'MS-II',
        title: 'Milestone II',
        section: ReviewSection.pms,
        fieldKeys: ['ms2_description', 'ms2_target_date', 'ms2_target_amount', 'ms2_achievement_date', 'ms2_achievement_amount'],
        stateField: null,
        primaryColor: const Color(0xFFA78BFA),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone3,
        id: 'MS-III',
        title: 'Milestone III',
        section: ReviewSection.pms,
        fieldKeys: ['ms3_description', 'ms3_target_date', 'ms3_target_amount', 'ms3_achievement_date', 'ms3_achievement_amount'],
        stateField: null,
        primaryColor: const Color(0xFF6366F1),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone4,
        id: 'MS-IV',
        title: 'Milestone IV',
        section: ReviewSection.pms,
        fieldKeys: ['ms4_description', 'ms4_target_date', 'ms4_target_amount', 'ms4_achievement_date', 'ms4_achievement_amount'],
        stateField: null,
        primaryColor: const Color(0xFF3B82F6),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone5,
        id: 'MS-V',
        title: 'Milestone V',
        section: ReviewSection.pms,
        fieldKeys: ['ms5_description', 'ms5_target_date', 'ms5_target_amount', 'ms5_achievement_date', 'ms5_achievement_amount'],
        stateField: null,
        primaryColor: const Color(0xFF06B6D4),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.ld,
        id: 'LD',
        title: 'Liquidated Damages',
        section: ReviewSection.pms,
        fieldKeys: ['ld_status', 'ld_amount'],
        stateField: 'ld_status',
        primaryColor: const Color(0xFFEF4444),
        icon: Icons.gavel,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.eot,
        id: 'EOT',
        title: 'Extension of Time',
        section: ReviewSection.pms,
        fieldKeys: ['eot_status', 'eot_period'],
        stateField: 'eot_status',
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.update,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.cos,
        id: 'COS',
        title: 'Change of Scope',
        section: ReviewSection.pms,
        fieldKeys: ['cos_status', 'cos_description'],
        stateField: 'cos_status',
        primaryColor: const Color(0xFFEAB308),
        icon: Icons.swap_horiz,
      ),

      // ============================================================
      // ROW 4: Monitoring & Audit (6 components)
      // ============================================================

      ReviewComponentConfig(
        type: ReviewComponentType.expenditure,
        id: 'Exp',
        title: 'Expenditure',
        section: ReviewSection.pms,
        fieldKeys: ['agreement_amount', 'expenditure_till_date', 'expenditure_percentage'],
        stateField: null,
        primaryColor: const Color(0xFF10B981),
        icon: Icons.currency_rupee,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.auditPara,
        id: 'Audit Para',
        title: 'Audit Para',
        section: ReviewSection.pms,
        fieldKeys: ['audit_para_status'],
        stateField: 'audit_para_status',
        primaryColor: const Color(0xFFEF4444),
        icon: Icons.receipt_long,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.laq,
        id: 'LAQ',
        title: 'LAQ',
        section: ReviewSection.pms,
        fieldKeys: ['laq_status'],
        stateField: 'laq_status',
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.help_outline,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.technicalAudit,
        id: 'Tech Audit',
        title: 'Technical Audit',
        section: ReviewSection.pms,
        fieldKeys: ['technical_audit_status'],
        stateField: 'technical_audit_status',
        primaryColor: const Color(0xFF6366F1),
        icon: Icons.search,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.revAA,
        id: 'Rev AA',
        title: 'Revised AA',
        section: ReviewSection.pms,
        fieldKeys: ['rev_aa_status', 'rev_aa_amount'],
        stateField: 'rev_aa_status',
        primaryColor: const Color(0xFF8B5CF6),
        icon: Icons.refresh,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.supplementaryAgreement,
        id: 'Supp Agr',
        title: 'Supplementary Agreement',
        section: ReviewSection.work,
        fieldKeys: ['supp_agreement_status'],
        stateField: 'supp_agreement_status',
        primaryColor: const Color(0xFF3B82F6),
        icon: Icons.note_add,
      ),
    ];
  }

  /// Get components filtered by section
  ///
  /// [section] - The section to filter by (all, dpr, work, pms)
  /// Returns list of components belonging to that section
  static List<ReviewComponentConfig> getComponentsBySection(
      ReviewSection section) {
    final allComponents = getAllComponents();

    if (section == ReviewSection.all) {
      return allComponents;
    }

    return allComponents.where((c) => c.section == section).toList();
  }

  /// Extract component-specific data from WorkEntryData
  ///
  /// [config] - The component configuration
  /// [data] - The WorkEntryData containing all form fields
  ///
  /// Returns a Map<String, dynamic> with only the fields relevant to this component
  static Map<String, dynamic> extractComponentData(
    ReviewComponentConfig config,
    WorkEntryData data,
  ) {
    final extractedData = <String, dynamic>{};

    // Determine which section data to read from
    Map<String, dynamic>? sectionData;
    switch (config.section) {
      case ReviewSection.dpr:
        sectionData = data.dprSection;
        break;
      case ReviewSection.work:
        sectionData = data.workSection;
        break;
      case ReviewSection.pms:
        sectionData = data.pmsSection;
        break;
      case ReviewSection.all:
        // Should not happen for individual components
        sectionData = {};
        break;
    }

    if (sectionData == null) {
      return extractedData;
    }

    // Extract only the fields defined in config.fieldKeys
    for (final fieldKey in config.fieldKeys) {
      if (sectionData.containsKey(fieldKey)) {
        extractedData[fieldKey] = sectionData[fieldKey];
      } else {
        extractedData[fieldKey] = null; // Field not found
      }
    }

    return extractedData;
  }

  /// Get the current state of a component based on its state field
  ///
  /// [config] - The component configuration
  /// [data] - The extracted component data
  ///
  /// Returns the current state as a string (e.g., 'awaited', 'accorded')
  /// Returns null if component has no states or state field not found
  static String? getCurrentState(
    ReviewComponentConfig config,
    Map<String, dynamic> data,
  ) {
    if (config.stateField == null || config.states == null) {
      return null; // Component doesn't use states
    }

    final stateValue = data[config.stateField];
    if (stateValue == null) {
      return null;
    }

    // Normalize state value (lowercase, trim, replace spaces with underscores)
    final normalizedState = stateValue
        .toString()
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_');

    // Check if this normalized state exists in component's state definitions
    if (config.states!.containsKey(normalizedState)) {
      return normalizedState;
    }

    // Return the raw state value if no exact match found
    return stateValue.toString();
  }

  /// Get visible fields for the current state of a component
  ///
  /// [config] - The component configuration
  /// [currentState] - The current state string
  ///
  /// Returns list of field keys that should be visible in this state
  /// Returns all fieldKeys if component doesn't use states
  static List<String> getVisibleFields(
    ReviewComponentConfig config,
    String? currentState,
  ) {
    if (currentState == null ||
        config.states == null ||
        !config.states!.containsKey(currentState)) {
      // No state-based filtering, show all fields
      return config.fieldKeys;
    }

    return config.states![currentState]!;
  }

  /// Get a component configuration by its ID
  ///
  /// [componentId] - The unique ID of the component (e.g., 'aa', 'dpr')
  /// Returns the component config or null if not found
  static ReviewComponentConfig? getComponentById(String componentId) {
    try {
      return getAllComponents().firstWhere((c) => c.id == componentId);
    } catch (_) {
      return null;
    }
  }

  /// Get a component configuration by its type
  ///
  /// [type] - The ReviewComponentType enum value
  /// Returns the component config or null if not found
  static ReviewComponentConfig? getComponentByType(ReviewComponentType type) {
    try {
      return getAllComponents().firstWhere((c) => c.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Check if component has any data (at least one non-null field)
  ///
  /// [data] - The extracted component data
  /// Returns true if at least one field has a value
  static bool hasData(Map<String, dynamic> data) {
    return data.values.any((value) =>
        value != null && value.toString().trim().isNotEmpty);
  }

  /// Get display-friendly field names
  ///
  /// Converts field keys to human-readable labels
  /// Example: 'aa_status' -> 'Status'
  /// Example: 'dpr_submitted_date' -> 'Submitted Date'
  static String getFieldLabel(String fieldKey) {
    // Remove common prefixes
    String label = fieldKey
        .replaceFirst(RegExp(r'^aa_'), '')
        .replaceFirst(RegExp(r'^dpr_'), '')
        .replaceFirst(RegExp(r'^boq_'), '')
        .replaceFirst(RegExp(r'^ts_'), '')
        .replaceFirst(RegExp(r'^nit_'), '')
        .replaceFirst(RegExp(r'^ms\d+_'), '')
        .replaceFirst(RegExp(r'^work_order_'), '');

    // Convert snake_case to Title Case
    return label
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
