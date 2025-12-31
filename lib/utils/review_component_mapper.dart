import 'package:flutter/material.dart';
import '../domain/models/review_component_config.dart';
import '../domain/models/review_section.dart';
import '../data/models/work_entry_data.dart';
import '../theme/app_colors.dart';
import 'field_name_mapper.dart';

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
        fieldKeys: ['boq_status', 'boq_likely_completion', 'boq_items'], // Added likely_completion
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
        fieldKeys: ['env_clearance_status', 'env_proposal_submitted_date', 'env_status_description'], // Added 2 fields
        stateField: 'env_clearance_status',
        primaryColor: const Color(0xFF22C55E),
        icon: Icons.eco,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.landAcquisition,
        id: 'LA',
        title: 'Land Acquisition',
        section: ReviewSection.dpr,
        fieldKeys: ['land_acquisition_status', 'la_proposal_submitted_date', 'la_status_description'], // Added 2 fields
        stateField: 'land_acquisition_status',
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.landscape,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.utilityShifting,
        id: 'Utility',
        title: 'Utility Shifting',
        section: ReviewSection.dpr,
        fieldKeys: ['utility_shifting_status', 'utility_proposal_submitted_date', 'utility_status_description'], // Added 2 fields
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
        fieldKeys: ['nit_status', 'nit_issued_date', 'nit_likely_issue_date', 'nit_bid_submission_date', 'nit_method', 'nit_type'], // Added likely_issue_date
        stateField: 'nit_status',
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.announcement,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.prebid,
        id: 'Pre-bid',
        title: 'Pre-bid Meeting',
        section: ReviewSection.work,
        fieldKeys: ['prebid_status', 'prebid_date', 'prebid_number_of_bidders', 'prebid_written_applications'], // Added written_applications
        stateField: 'prebid_status',
        primaryColor: const Color(0xFFEAB308),
        icon: Icons.meeting_room,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.csd,
        id: 'CSD',
        title: 'Common Set of Deviations',
        section: ReviewSection.dpr,
        fieldKeys: [
          'csd_status',
          'csd_date',
        ],
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
        fieldKeys: [
          'tech_eval_status',
          'tech_eval_qualified',
          'tech_eval_likely_completion', // NEW - for In Progress state
          'tech_eval_results_published_date', // NEW - results published checkbox
          'tech_eval_fin_bid_opening_informed', // NEW - financial bid opening date
          'tech_eval_person_responsible',
          'tech_eval_post_held',
          'tech_eval_pending_with',
        ],
        stateField: 'tech_eval_status',
        primaryColor: const Color(0xFF6366F1),
        icon: Icons.assessment,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.financialBid,
        id: 'Fin Bid',
        title: 'Financial Bid',
        section: ReviewSection.dpr,
        fieldKeys: ['fin_opening_date', 'fin_bid_qualified_count', 'fin_opening_bid', 'fin_opening_amount', 'fin_opening_variance'], // Added qualified_count and other fields
        stateField: 'fin_opening_date',
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
        fieldKeys: [
          'milestone_1_description', // FIXED: removed pms_ prefix
          'milestone_1_period', // NEW
          'milestone_1_target_date', // FIXED
          'milestone_1_target_amount', // FIXED
          'milestone_1_physical_target', // NEW
          'milestone_1_achieved_date', // FIXED
          'milestone_1_achieved_amount', // FIXED
          'milestone_1_physical_achieved', // NEW
          'milestone_1_person_responsible', // FIXED
          'milestone_1_post_held', // FIXED
          'milestone_1_pending_with', // FIXED
          'ld_1_applicable', // FIXED
          'milestone_1_remarks', // FIXED
        ],
        stateField: null,
        primaryColor: const Color(0xFF8B5CF6),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone2,
        id: 'MS-II',
        title: 'Milestone II',
        section: ReviewSection.pms,
        fieldKeys: [
          'milestone_2_description', // FIXED
          'milestone_2_period', // NEW
          'milestone_2_target_date', // FIXED
          'milestone_2_target_amount', // FIXED
          'milestone_2_physical_target', // NEW
          'milestone_2_achieved_date', // FIXED
          'milestone_2_achieved_amount', // FIXED
          'milestone_2_physical_achieved', // NEW
          'milestone_2_person_responsible', // FIXED
          'milestone_2_post_held', // FIXED
          'milestone_2_pending_with', // FIXED
          'ld_2_applicable', // FIXED
          'milestone_2_remarks', // FIXED
        ],
        stateField: null,
        primaryColor: const Color(0xFFA78BFA),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone3,
        id: 'MS-III',
        title: 'Milestone III',
        section: ReviewSection.pms,
        fieldKeys: [
          'milestone_3_description', // FIXED
          'milestone_3_period', // NEW
          'milestone_3_target_date', // FIXED
          'milestone_3_target_amount', // FIXED
          'milestone_3_physical_target', // NEW
          'milestone_3_achieved_date', // FIXED
          'milestone_3_achieved_amount', // FIXED
          'milestone_3_physical_achieved', // NEW
          'milestone_3_person_responsible', // FIXED
          'milestone_3_post_held', // FIXED
          'milestone_3_pending_with', // FIXED
          'ld_3_applicable', // FIXED
          'milestone_3_remarks', // FIXED
        ],
        stateField: null,
        primaryColor: const Color(0xFF6366F1),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone4,
        id: 'MS-IV',
        title: 'Milestone IV',
        section: ReviewSection.pms,
        fieldKeys: [
          'milestone_4_description', // FIXED
          'milestone_4_period', // NEW
          'milestone_4_target_date', // FIXED
          'milestone_4_target_amount', // FIXED
          'milestone_4_physical_target', // NEW
          'milestone_4_achieved_date', // FIXED
          'milestone_4_achieved_amount', // FIXED
          'milestone_4_physical_achieved', // NEW
          'milestone_4_person_responsible', // FIXED
          'milestone_4_post_held', // FIXED
          'milestone_4_pending_with', // FIXED
          'ld_4_applicable', // FIXED
          'milestone_4_remarks', // FIXED
        ],
        stateField: null,
        primaryColor: const Color(0xFF3B82F6),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.milestone5,
        id: 'MS-V',
        title: 'Milestone V',
        section: ReviewSection.pms,
        fieldKeys: [
          'milestone_5_description', // FIXED
          'milestone_5_period', // NEW
          'milestone_5_target_date', // FIXED
          'milestone_5_target_amount', // FIXED
          'milestone_5_physical_target', // NEW
          'milestone_5_achieved_date', // FIXED
          'milestone_5_achieved_amount', // FIXED
          'milestone_5_physical_achieved', // NEW
          'milestone_5_person_responsible', // FIXED
          'milestone_5_post_held', // FIXED
          'milestone_5_pending_with', // FIXED
          'ld_final_applicable', // FIXED
          'milestone_5_remarks', // FIXED
        ],
        stateField: null,
        primaryColor: const Color(0xFF06B6D4),
        icon: Icons.flag,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.ld,
        id: 'LD',
        title: 'Liquidated Damages',
        section: ReviewSection.pms,
        fieldKeys: [
          'ld_final_applicable', // FIXED
          'ld_final_rate', // FIXED
          'ld_final_recovery', // FIXED
          'ld_amount_deposited', // NEW
          'ld_amount_released', // NEW
          'ld_final_person_responsible',
          'ld_final_post_held',
          'ld_final_pending_with',
          'ld_1_recovery', // FIXED
          'ld_2_recovery', // FIXED
          'ld_3_recovery', // FIXED
          'ld_4_recovery', // FIXED
        ],
        stateField: 'ld_final_applicable', // FIXED
        primaryColor: const Color(0xFFEF4444),
        icon: Icons.gavel,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.eot,
        id: 'EOT',
        title: 'Extension of Time',
        section: ReviewSection.pms,
        fieldKeys: [
          'eot_applicable', // FIXED
          'eot_period', // FIXED
          'eot_proposal_submitted_date', // NEW
          'eot_with_escalation', // NEW
          'eot_without_escalation', // NEW
          'eot_by_freezing_indices', // NEW
          'eot_without_ld', // NEW
          'eot_with_ld', // NEW
          'eot_compensation_payable', // NEW
          'eot_compensation_claimed_amount', // NEW
          'eot_compensation_admitted_amount', // NEW
          'eot_person_responsible',
          'eot_post_held',
          'eot_pending_with',
        ],
        stateField: 'eot_applicable', // FIXED
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.update,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.cos,
        id: 'COS',
        title: 'Change of Scope',
        section: ReviewSection.pms,
        fieldKeys: [
          'cos_status', // FIXED
          'cos_date', // FIXED
          'cos_amount', // FIXED
          'cos_scope', // FIXED
          'cos_proposed_items', // NEW
          'cos_approved_items', // NEW
          'cos_person_responsible',
          'cos_post_held',
          'cos_pending_with',
        ],
        stateField: 'cos_status', // FIXED
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
        fieldKeys: [
          'audit_para_applicable', // FIXED
          'audit_para_points', // FIXED - # of draft paras
          'audit_para_replied', // FIXED
          'audit_para_pending', // FIXED
          'audit_para_dp', // FIXED
          'audit_para_dropped', // FIXED
          'audit_para_details_items', // NEW - Details of paras table (3x4)
          'audit_para_replies_items', // NEW - Replies Submitted table (3x4)
          'audit_para_closed_items', // NEW - Paras Closed table (3x4)
          'audit_para_person_responsible',
          'audit_para_post_held',
          'audit_para_pending_with',
        ],
        stateField: 'audit_para_applicable', // FIXED
        primaryColor: const Color(0xFFEF4444),
        icon: Icons.receipt_long,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.laq,
        id: 'LAQ',
        title: 'LAQ',
        section: ReviewSection.pms,
        fieldKeys: [
          'laq_lcq_status', // FIXED
          'laq_lcq_action',
          'laq_lcq_description',
          'laq_count', // NEW
          'lcq_count', // NEW
          'lakshvwdhi_count', // NEW
          'laq_others_count', // NEW
          'laq_questions_items', // NEW (JSON table)
          'laq_replies_items', // NEW (JSON table)
          'laq_promises_items', // NEW (JSON table)
          'laq_compliance_items', // NEW (JSON table)
        ],
        stateField: 'laq_lcq_status', // FIXED
        primaryColor: const Color(0xFFF59E0B),
        icon: Icons.help_outline,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.technicalAudit,
        id: 'Tech Audit',
        title: 'Technical Audit',
        section: ReviewSection.pms,
        fieldKeys: [
          'tech_audit_status', // FIXED
          'tech_audit_report',
          'tech_audit_action',
          'tech_audit_no_action',
          'tech_audit_responsible_ee', // NEW
          'tech_audit_compliance_count', // NEW
          'tech_audit_compliance_dates', // NEW
        ],
        stateField: 'tech_audit_status', // FIXED
        primaryColor: const Color(0xFF6366F1),
        icon: Icons.search,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.revAA,
        id: 'Rev AA',
        title: 'Revised AA',
        section: ReviewSection.pms,
        fieldKeys: [
          'revised_aa_status', // FIXED
          'revised_aa_amount', // FIXED
          'revised_aa_percentage', // FIXED
          'rev_aa_recap_sheet_items', // NEW (JSON table)
        ],
        stateField: 'revised_aa_status', // FIXED
        primaryColor: const Color(0xFF8B5CF6),
        icon: Icons.refresh,
      ),

      ReviewComponentConfig(
        type: ReviewComponentType.supplementaryAgreement,
        id: 'Supp Agr',
        title: 'Supplementary Agreement',
        section: ReviewSection.work,
        fieldKeys: [
          'suppl_agreement_status',
          'suppl_agreement_date',
          'suppl_agreement_number',
          'suppl_agreement_amount',
          'suppl_agreement_period', // NEW
          'suppl_agreement_scope',
        ],
        stateField: 'suppl_agreement_status',
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
  /// Convert component ID to field mapper key
  /// Handles special cases like roman numerals, abbreviations, etc.
  static String _getMapperKey(String componentId) {
    // Map component IDs to field mapper keys
    const idToMapperKey = {
      'AA': 'aa',
      'DPR': 'dpr',
      'BOQ': 'boq',
      'Sch': 'schedules',
      'Dwg': 'drawings',
      'Bid Doc': 'bidDocuments',
      'ENV': 'envClearance',
      'LA': 'landAcquisition',
      'Utility': 'utilityShifting',
      'CSD': 'csd',
      'Bid Sub': 'bidSubmission',
      'Tech Eval': 'techEvaluation',
      'Fin Bid': 'financialBid',
      'Bid Accept': 'bidAcceptance',
      'LOA': 'loa',
      'PBG': 'pbg',
      'TS': 'ts',
      'NIT': 'nit',
      'Pre-bid': 'prebid',
      'Work Order': 'workOrder',
      'Agr Amt': 'expenditure',  // Agreement amount is part of expenditure
      'App Date': 'workOrder',  // Appointed date is in work order section
      'Tender': 'workOrder',  // Tender period is in work order section
      'MS-I': 'ms1',
      'MS-II': 'ms2',
      'MS-III': 'ms3',
      'MS-IV': 'ms4',
      'MS-V': 'ms5',
      'LD': 'ld',
      'EOT': 'eot',
      'COS': 'cos',
      'Exp': 'expenditure',
      'Audit Para': 'auditPara',
      'LAQ': 'laq',
      'Tech Audit': 'technicalAudit',
      'Rev AA': 'revAa',
      'Suppl Agr': 'supplAgreement',
    };

    return idToMapperKey[componentId] ?? componentId.toLowerCase().replaceAll(' ', '');
  }

  static Map<String, dynamic> extractComponentData(
    ReviewComponentConfig config,
    WorkEntryData data,
  ) {
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

    if (sectionData == null || sectionData.isEmpty) {
      return {};
    }

    // Get the proper field mapper key for this component
    final componentType = _getMapperKey(config.id);

    // Apply field name translation if mapping exists
    final translatedData = FieldNameMapper.translateData(
      componentType,
      sectionData,
    );

    // Extract only the fields defined in config.fieldKeys (original names)
    // plus any translated fields
    final extractedData = <String, dynamic>{};

    for (final fieldKey in config.fieldKeys) {
      if (translatedData.containsKey(fieldKey)) {
        extractedData[fieldKey] = translatedData[fieldKey];
      }
    }

    // Also include any translated standard field names (status, amount, etc.)
    final standardFields = [
      'status', 'amount', 'person_responsible', 'post_held', 'pending_with',
      'date', 'broad_scope', 'applicable', 'qualified', 'bid', 'variance',
      'period',
      // Milestone-specific fields
      'description', 'target_date', 'target_amount', 'achievement_date',
      'achievement_amount', 'ld_imposed', 'remarks',
      'physical_target', 'physical_achieved', // NEW milestone fields
      // LD fields
      'total_amount', 'amount_recovered', 'amount_pending',
      'ms1_amount', 'ms2_amount', 'ms3_amount', 'ms4_amount', 'ms5_amount',
      'amount_deposited', 'amount_released', // NEW LD fields
      // EOT fields
      'application_date', 'requested_period', 'reasons', 'approval_status',
      'approved_period', 'approval_date', 'original_completion_date',
      'revised_completion_date', 'with_compensation', 'compensation_amount',
      'proposal_submitted_date', 'with_escalation', 'without_escalation', // NEW EOT fields
      'by_freezing_indices', 'without_ld', 'with_ld', 'compensation_payable',
      'compensation_claimed_amount', 'compensation_admitted_amount',
      // COS fields
      'sub_status', 'proposal_date', 'proposal_total_amount', 'proposed_items',
      'approved_amount', 'approved_items',
      'scope', // NEW COS field
      // Audit fields
      'count', 'settled_count', 'pending_count', 'items',
      'agency', 'findings_count', 'critical_findings', 'resolved_findings',
      'pending_findings', 'summary',
      'points_count', 'reply_given', 'reply_pending', 'dp_count', 'dropped_count', // NEW audit fields
      // LAQ fields (NEW)
      'laq_count', 'lcq_count', 'lakshvwdhi_count', 'others_count',
      'questions_items', 'replies_items', 'promises_items', 'compliance_items',
      // Technical Audit fields (NEW)
      'responsible_ee', 'compliance_count', 'compliance_dates',
      // Rev AA fields
      'original_amount', 'proposed_amount', 'increase_amount',
      'submission_date', 'approved_date', 'number',
      'recap_sheet_items', // NEW Rev AA field
      // Other fields
      'issue_date', 'prebid_date', 'submission_date', 'broad_items', 'emd_items',
      'not_issued_reasons', 'number_of_bidders', 'applications_received',
      'queries_raised', 'scheduled_date',
      'likely_completion', 'status_description', 'written_applications', // NEW misc fields
      'likely_issue_date', 'likely_submission_date', 'qualified_count',
      'results_published_date', 'fin_bid_opening_informed',
    ];

    for (final standardField in standardFields) {
      if (translatedData.containsKey(standardField) &&
          !extractedData.containsKey(standardField)) {
        extractedData[standardField] = translatedData[standardField];
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
