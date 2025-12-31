/// Field Name Mapper Utility
///
/// Translates field names between Work Entry form and Review components.
/// This allows components to use consistent naming while the underlying
/// database/form uses different field names.
///
/// Usage in components:
/// ```dart
/// final data = FieldNameMapper.translateData(rawData);
/// // Now use consistent field names like 'status', 'amount', etc.
/// ```
class FieldNameMapper {
  /// Master mapping of component types to their field name translations
  ///
  /// Key: Review component field name (what components expect)
  /// Value: Work entry field name (what's in database)
  static const Map<String, Map<String, String>> _componentFieldMaps = {
    // ================================================================
    // DPR SECTION COMPONENTS
    // ================================================================

    'aa': {
      'status': 'aa_status',
      'amount': 'aa_amount',
      'number': 'aa_number', // NEW
      'date': 'aa_date', // NEW
      'proposed_amount': 'aa_proposed_amount', // NEW
      'proposal_date': 'aa_proposal_date', // NEW
      'pending_with': 'aa_pending_with', // NEW (standardized)
      'person_responsible': 'aa_person_responsible',
      'post_held': 'aa_post_held',
      'broad_scope': 'broad_scope_aa',
    },

    'dpr': {
      'status': 'final_dpr_status',
      'person_responsible': 'final_dpr_person_responsible',
      'post_held': 'final_dpr_post_held',
      'pending_with': 'final_dpr_pending_with',
    },

    'boq': {
      'status': 'boq_status',
      'amount': 'boq_amount',
      'likely_completion': 'boq_likely_completion', // NEW
      'person_responsible': 'boq_person_responsible',
      'post_held': 'boq_post_held',
      'pending_with': 'boq_pending_with',
    },

    'schedules': {
      'status': 'schedules_status',
      'person_responsible': 'schedules_person_responsible',
      'post_held': 'schedules_post_held',
      'pending_with': 'schedules_pending_with',
    },

    'drawings': {
      'status': 'drawings_volume_status',
      'person_responsible': 'drawings_volume_person_responsible',
      'post_held': 'drawings_volume_post_held',
      'pending_with': 'drawings_volume_pending_with',
    },

    'bidDocuments': {
      'status': 'contractor_bid_doc_status',
      'person_responsible': 'contractor_bid_doc_person_responsible',
      'post_held': 'contractor_bid_doc_post_held',
      'pending_with': 'contractor_bid_doc_pending_with',
    },

    'envClearance': {
      'status': 'env_clearance_status',
      'applicable': 'env_clearance_applicable',
      'proposal_submitted_date': 'env_proposal_submitted_date', // NEW
      'status_description': 'env_status_description', // NEW
      'person_responsible': 'env_clearance_person_responsible',
      'post_held': 'env_clearance_post_held',
      'pending_with': 'env_clearance_pending_with',
    },

    'landAcquisition': {
      'status': 'land_acquisition_status',
      'applicable': 'land_acquisition_applicable',
      'proposal_submitted_date': 'la_proposal_submitted_date', // NEW
      'status_description': 'la_status_description', // NEW
      'person_responsible': 'land_acquisition_person_responsible',
      'post_held': 'land_acquisition_post_held',
      'pending_with': 'land_acquisition_pending_with',
    },

    'utilityShifting': {
      'status': 'utility_shifting_status',
      'applicable': 'utility_shifting_applicable',
      'proposal_submitted_date': 'utility_proposal_submitted_date', // NEW
      'status_description': 'utility_status_description', // NEW
      'person_responsible': 'utility_shifting_person_responsible',
      'post_held': 'utility_shifting_post_held',
      'pending_with': 'utility_shifting_pending_with',
    },

    'csd': {
      'status': 'csd_status',
      'date': 'csd_date',
      'person_responsible': 'csd_person_responsible',
      'post_held': 'csd_post_held',
      'pending_with': 'csd_pending_with',
    },

    'bidSubmission': {
      'date': 'bid_submission_date',
      'person_responsible': 'bid_submission_person_responsible',
      'post_held': 'bid_submission_post_held',
      'pending_with': 'bid_submission_pending_with',
    },

    'techEvaluation': {
      'status': 'tech_eval_status',
      'qualified': 'tech_eval_qualified',
      'likely_completion': 'tech_eval_likely_completion', // NEW
      'results_published_date': 'tech_eval_results_published_date', // NEW
      'fin_bid_opening_informed': 'tech_eval_fin_bid_opening_informed', // NEW
      'person_responsible': 'tech_eval_person_responsible',
      'post_held': 'tech_eval_post_held',
      'pending_with': 'tech_eval_pending_with',
    },

    'financialBid': {
      'date': 'fin_opening_date',
      'bid': 'fin_opening_bid',
      'amount': 'fin_opening_amount',
      'variance': 'fin_opening_variance',
      'qualified_count': 'fin_bid_qualified_count', // NEW
      'person_responsible': 'fin_opening_person_responsible',
      'post_held': 'fin_opening_post_held',
      'pending_with': 'fin_opening_pending_with',
    },

    'bidAcceptance': {
      'status': 'bid_acceptance_status',
      'amount': 'bid_acceptance_amount',
      'person_responsible': 'bid_acceptance_person_responsible',
      'post_held': 'bid_acceptance_post_held',
      'pending_with': 'bid_acceptance_pending_with',
    },

    'loa': {
      'status': 'loa_status',
      'date': 'loa_date',
      'person_responsible': 'loa_person_responsible',
      'post_held': 'loa_post_held',
      'pending_with': 'loa_pending_with',
    },

    'pbg': {
      'status': 'pbg_status',
      'amount': 'pbg_amount',
      'date': 'pbg_date',
      'period': 'pbg_period',
      'person_responsible': 'pbg_person_responsible',
      'post_held': 'pbg_post_held',
      'pending_with': 'pbg_pending_with',
    },

    // ================================================================
    // WORK SECTION COMPONENTS
    // ================================================================

    'ts': {
      'status': 'work_tech_sanction_status',
      'amount': 'work_tech_sanction_amount',
      'number': 'ts_number', // NEW
      'date': 'ts_date', // NEW
      'likely_submission_date': 'ts_likely_submission_date', // NEW
    },

    'workOrder': {
      'status': 'work_order_status',
      'date': 'work_order_date',
      'number': 'work_order_number', // NEW
      'person_responsible': 'work_order_person_responsible',
      'post_held': 'work_order_post_held',
      'pending_with': 'work_order_pending_with',
    },

    'nit': {
      'status': 'nit_status',
      'issue_date': 'nit_issue_date',
      'likely_issue_date': 'nit_likely_issue_date', // NEW
      'amount': 'nit_amount',
      'prebid_date': 'nit_prebid_date',
      'submission_date': 'nit_submission_date',
      'broad_items': 'nit_broad_items',
      'emd_items': 'nit_emd_items',
      'not_issued_reasons': 'nit_not_issued_reasons',
    },

    'prebid': {
      'status': 'prebid_status',
      'date': 'prebid_date',
      'number_of_bidders': 'prebid_number_of_bidders',
      'applications_received': 'prebid_applications_received',
      'written_applications': 'prebid_written_applications', // NEW
      'queries_raised': 'prebid_queries_raised',
      'scheduled_date': 'prebid_scheduled_date',
      'remarks': 'prebid_remarks',
    },

    // ================================================================
    // PMS SECTION COMPONENTS
    // ================================================================

    'ms1': {
      'description': 'milestone_1_description', // FIXED: removed pms_ prefix
      'period': 'milestone_1_period', // NEW
      'target_date': 'milestone_1_target_date', // FIXED
      'target_amount': 'milestone_1_target_amount', // FIXED
      'physical_target': 'milestone_1_physical_target', // NEW (%)
      'achievement_date': 'milestone_1_achieved_date', // FIXED
      'achievement_amount': 'milestone_1_achieved_amount', // FIXED
      'physical_achieved': 'milestone_1_physical_achieved', // NEW (%)
      'person_responsible': 'milestone_1_person_responsible', // FIXED
      'post_held': 'milestone_1_post_held', // FIXED
      'pending_with': 'milestone_1_pending_with', // FIXED
      'ld_imposed': 'ld_1_applicable', // FIXED
      'remarks': 'milestone_1_remarks', // FIXED
    },

    'ms2': {
      'description': 'milestone_2_description', // FIXED
      'period': 'milestone_2_period', // NEW
      'target_date': 'milestone_2_target_date', // FIXED
      'target_amount': 'milestone_2_target_amount', // FIXED
      'physical_target': 'milestone_2_physical_target', // NEW (%)
      'achievement_date': 'milestone_2_achieved_date', // FIXED
      'achievement_amount': 'milestone_2_achieved_amount', // FIXED
      'physical_achieved': 'milestone_2_physical_achieved', // NEW (%)
      'person_responsible': 'milestone_2_person_responsible', // FIXED
      'post_held': 'milestone_2_post_held', // FIXED
      'pending_with': 'milestone_2_pending_with', // FIXED
      'ld_imposed': 'ld_2_applicable', // FIXED
      'remarks': 'milestone_2_remarks', // FIXED
    },

    'ms3': {
      'description': 'milestone_3_description', // FIXED
      'period': 'milestone_3_period', // NEW
      'target_date': 'milestone_3_target_date', // FIXED
      'target_amount': 'milestone_3_target_amount', // FIXED
      'physical_target': 'milestone_3_physical_target', // NEW (%)
      'achievement_date': 'milestone_3_achieved_date', // FIXED
      'achievement_amount': 'milestone_3_achieved_amount', // FIXED
      'physical_achieved': 'milestone_3_physical_achieved', // NEW (%)
      'person_responsible': 'milestone_3_person_responsible', // FIXED
      'post_held': 'milestone_3_post_held', // FIXED
      'pending_with': 'milestone_3_pending_with', // FIXED
      'ld_imposed': 'ld_3_applicable', // FIXED
      'remarks': 'milestone_3_remarks', // FIXED
    },

    'ms4': {
      'description': 'milestone_4_description', // FIXED
      'period': 'milestone_4_period', // NEW
      'target_date': 'milestone_4_target_date', // FIXED
      'target_amount': 'milestone_4_target_amount', // FIXED
      'physical_target': 'milestone_4_physical_target', // NEW (%)
      'achievement_date': 'milestone_4_achieved_date', // FIXED
      'achievement_amount': 'milestone_4_achieved_amount', // FIXED
      'physical_achieved': 'milestone_4_physical_achieved', // NEW (%)
      'person_responsible': 'milestone_4_person_responsible', // FIXED
      'post_held': 'milestone_4_post_held', // FIXED
      'pending_with': 'milestone_4_pending_with', // FIXED
      'ld_imposed': 'ld_4_applicable', // FIXED
      'remarks': 'milestone_4_remarks', // FIXED
    },

    'ms5': {
      'description': 'milestone_5_description', // FIXED
      'period': 'milestone_5_period', // NEW
      'target_date': 'milestone_5_target_date', // FIXED
      'target_amount': 'milestone_5_target_amount', // FIXED
      'physical_target': 'milestone_5_physical_target', // NEW (%)
      'achievement_date': 'milestone_5_achieved_date', // FIXED
      'achievement_amount': 'milestone_5_achieved_amount', // FIXED
      'physical_achieved': 'milestone_5_physical_achieved', // NEW (%)
      'person_responsible': 'milestone_5_person_responsible', // FIXED
      'post_held': 'milestone_5_post_held', // FIXED
      'pending_with': 'milestone_5_pending_with', // FIXED
      'ld_imposed': 'ld_final_applicable', // FIXED
      'remarks': 'milestone_5_remarks', // FIXED
    },

    'ld': {
      'status': 'ld_final_applicable', // FIXED
      'applicability': 'ld_final_applicable', // FIXED
      'rate': 'ld_final_rate', // FIXED
      'recovery': 'ld_final_recovery', // FIXED
      'amount_deposited': 'ld_amount_deposited', // NEW
      'amount_released': 'ld_amount_released', // NEW
      'person_responsible': 'ld_final_person_responsible',
      'post_held': 'ld_final_post_held',
      'pending_with': 'ld_final_pending_with',
      // Individual LD amounts for each milestone
      'ms1_applicability': 'ld_1_applicable', // FIXED
      'ms1_rate': 'ld_1_rate', // FIXED
      'ms1_recovery': 'ld_1_recovery', // FIXED
      'ms2_applicability': 'ld_2_applicable', // FIXED
      'ms2_rate': 'ld_2_rate', // FIXED
      'ms2_recovery': 'ld_2_recovery', // FIXED
      'ms3_applicability': 'ld_3_applicable', // FIXED
      'ms3_rate': 'ld_3_rate', // FIXED
      'ms3_recovery': 'ld_3_recovery', // FIXED
      'ms4_applicability': 'ld_4_applicable', // FIXED
      'ms4_rate': 'ld_4_rate', // FIXED
      'ms4_recovery': 'ld_4_recovery', // FIXED
      'ms5_applicability': 'ld_final_applicable', // FIXED
      'ms5_rate': 'ld_final_rate', // FIXED
      'ms5_recovery': 'ld_final_recovery', // FIXED
    },

    'eot': {
      'status': 'eot_applicable', // FIXED
      'period': 'eot_period', // FIXED
      'proposal_submitted_date': 'eot_proposal_submitted_date', // NEW
      'with_escalation': 'eot_with_escalation', // NEW
      'without_escalation': 'eot_without_escalation', // NEW
      'by_freezing_indices': 'eot_by_freezing_indices', // NEW
      'without_ld': 'eot_without_ld', // NEW
      'with_ld': 'eot_with_ld', // NEW
      'compensation_payable': 'eot_compensation_payable', // NEW
      'compensation_claimed_amount': 'eot_compensation_claimed_amount', // NEW
      'compensation_admitted_amount': 'eot_compensation_admitted_amount', // NEW
      'person_responsible': 'eot_person_responsible',
      'post_held': 'eot_post_held',
      'pending_with': 'eot_pending_with',
    },

    'cos': {
      'status': 'cos_status', // FIXED
      'date': 'cos_date', // FIXED
      'amount': 'cos_amount', // FIXED
      'scope': 'cos_scope', // FIXED
      'proposed_items': 'cos_proposed_items', // NEW (JSON table)
      'approved_items': 'cos_approved_items', // NEW (JSON table)
      'person_responsible': 'cos_person_responsible',
      'post_held': 'cos_post_held',
      'pending_with': 'cos_pending_with',
    },

    'expenditure': {
      'agreement_amount': 'agreement_amount',
      'expenditure_till_date': 'expenditure_till_date',
      'expenditure_percentage': 'expenditure_percentage',
    },

    'auditPara': {
      'status': 'audit_para_applicable', // FIXED
      'applicability': 'audit_para_applicable', // FIXED
      'points_count': 'audit_para_points', // FIXED
      'reply_given': 'audit_para_replied', // FIXED
      'reply_pending': 'audit_para_pending', // FIXED
      'dp_count': 'audit_para_dp', // FIXED
      'dropped_count': 'audit_para_dropped', // FIXED
      'details_items': 'audit_para_details_items', // NEW - Details of paras table (3x4)
      'replies_items': 'audit_para_replies_items', // NEW - Replies Submitted table (3x4)
      'closed_items': 'audit_para_closed_items', // NEW - Paras Closed table (3x4)
      'person_responsible': 'audit_para_person_responsible',
      'post_held': 'audit_para_post_held',
      'pending_with': 'audit_para_pending_with',
    },

    'laq': {
      'status': 'laq_lcq_status', // FIXED
      'laq_count': 'laq_count', // NEW
      'lcq_count': 'lcq_count', // NEW
      'lakshvwdhi_count': 'lakshvwdhi_count', // NEW
      'others_count': 'laq_others_count', // NEW
      'questions_items': 'laq_questions_items', // NEW (JSON table)
      'replies_items': 'laq_replies_items', // NEW (JSON table)
      'promises_items': 'laq_promises_items', // NEW (JSON table)
      'compliance_items': 'laq_compliance_items', // NEW (JSON table)
      'settled_count': 'laq_settled_count',
      'pending_count': 'laq_pending_count',
      'items': 'laq_items',
      'remarks': 'laq_lcq_description',
    },

    'technicalAudit': {
      'status': 'tech_audit_status', // FIXED
      'date': 'tech_audit_date',
      'agency': 'tech_audit_agency',
      'findings_count': 'tech_audit_findings_count',
      'critical_findings': 'tech_audit_critical_findings',
      'resolved_findings': 'tech_audit_resolved_findings',
      'pending_findings': 'tech_audit_pending_findings',
      'responsible_ee': 'tech_audit_responsible_ee', // NEW
      'compliance_count': 'tech_audit_compliance_count', // NEW
      'compliance_dates': 'tech_audit_compliance_dates', // NEW
      'summary': 'tech_audit_summary',
      'remarks': 'tech_audit_remarks',
    },

    'revAa': {
      'status': 'revised_aa_status', // FIXED
      'sub_status': 'rev_aa_sub_status',
      'original_amount': 'rev_aa_original_amount',
      'proposed_amount': 'revised_aa_amount', // FIXED
      'increase_amount': 'rev_aa_increase_amount',
      'submission_date': 'rev_aa_submission_date',
      'reasons': 'rev_aa_reasons',
      'approved_date': 'rev_aa_approved_date',
      'approved_amount': 'rev_aa_approved_amount',
      'number': 'rev_aa_number',
      'recap_sheet_items': 'rev_aa_recap_sheet_items', // NEW (JSON table)
      'remarks': 'rev_aa_remarks',
    },

    'supplAgreement': {
      'status': 'suppl_agreement_status',
      'date': 'suppl_agreement_date',
      'number': 'suppl_agreement_number',
      'amount': 'suppl_agreement_amount',
      'period': 'suppl_agreement_period', // NEW
      'original_amount': 'suppl_agreement_original_amount',
      'total_amount': 'suppl_agreement_total_amount',
      'scope': 'suppl_agreement_scope',
      'remarks': 'suppl_agreement_remarks',
    },
  };

  /// Translate data from work entry field names to component field names
  ///
  /// Takes raw data from database with work entry field names and returns
  /// a new map with translated field names that components expect.
  ///
  /// Example:
  /// ```dart
  /// Input: {'aa_status': 'Accorded', 'aa_amount': '15000'}
  /// Output: {'status': 'Accorded', 'amount': '15000', 'aa_status': 'Accorded', 'aa_amount': '15000'}
  /// ```
  ///
  /// Note: Keeps both original and translated field names for compatibility
  static Map<String, dynamic> translateData(
    String componentType,
    Map<String, dynamic> rawData,
  ) {
    final translatedData = Map<String, dynamic>.from(rawData);
    final fieldMap = _componentFieldMaps[componentType];

    if (fieldMap == null) {
      // No mapping defined for this component, return original data
      return translatedData;
    }

    // Add translated field names alongside originals
    fieldMap.forEach((componentFieldName, workEntryFieldName) {
      if (rawData.containsKey(workEntryFieldName)) {
        translatedData[componentFieldName] = rawData[workEntryFieldName];
      }
    });

    return translatedData;
  }

  /// Get the work entry field name for a component field name
  ///
  /// Useful when you need to know what the actual database field is called
  static String? getWorkEntryFieldName(
    String componentType,
    String componentFieldName,
  ) {
    final fieldMap = _componentFieldMaps[componentType];
    return fieldMap?[componentFieldName];
  }

  /// Get all work entry field names for a component
  ///
  /// Returns list of all database field names that this component uses
  static List<String> getWorkEntryFieldNames(String componentType) {
    final fieldMap = _componentFieldMaps[componentType];
    if (fieldMap == null) return [];
    return fieldMap.values.toList();
  }

  /// Check if a component has a field mapping defined
  static bool hasMapping(String componentType) {
    return _componentFieldMaps.containsKey(componentType);
  }

  /// Reverse translate - from component field name to work entry field name
  ///
  /// Useful when saving data back to database
  static Map<String, dynamic> reverseTranslateData(
    String componentType,
    Map<String, dynamic> componentData,
  ) {
    final workEntryData = <String, dynamic>{};
    final fieldMap = _componentFieldMaps[componentType];

    if (fieldMap == null) {
      return componentData;
    }

    fieldMap.forEach((componentFieldName, workEntryFieldName) {
      if (componentData.containsKey(componentFieldName)) {
        workEntryData[workEntryFieldName] = componentData[componentFieldName];
      }
    });

    return workEntryData;
  }
}
