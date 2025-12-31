import 'dart:convert';

/// Work Entry Data Model
///
/// Complex model with 84 dynamic fields across 3 sections
/// - DPR Section: 40 fields
/// - Work Section: 20 fields
/// - PMS Section: 24 fields
///
/// Fields are stored as JSON for flexibility with the dynamic form system
class WorkEntryData {
  final int? id;
  final int projectId;
  final String? workId; // Alphanumeric work identifier
  final String? nameOfWork; // Name/description of work
  final String? personResponsible;
  final String? postHeld;
  final String? pendingWith;

  // Three sections stored as JSON
  final Map<String, dynamic> dprSection;
  final Map<String, dynamic> workSection;
  final Map<String, dynamic> pmsSection;

  final bool isDraft;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkEntryData({
    this.id,
    required this.projectId,
    this.workId,
    this.nameOfWork,
    this.personResponsible,
    this.postHeld,
    this.pendingWith,
    Map<String, dynamic>? dprSection,
    Map<String, dynamic>? workSection,
    Map<String, dynamic>? pmsSection,
    this.isDraft = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : dprSection = dprSection ?? {},
        workSection = workSection ?? {},
        pmsSection = pmsSection ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create WorkEntryData from database map
  factory WorkEntryData.fromMap(Map<String, dynamic> map) {
    return WorkEntryData(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      workId: map['work_id'] as String?,
      nameOfWork: map['name_of_work'] as String?,
      personResponsible: map['person_responsible'] as String?,
      postHeld: map['post_held'] as String?,
      pendingWith: map['pending_with'] as String?,
      dprSection: _parseJsonSection(map['dpr_section']),
      workSection: _parseJsonSection(map['work_section']),
      pmsSection: _parseJsonSection(map['pms_section']),
      isDraft: (map['is_draft'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create empty WorkEntryData for a project
  factory WorkEntryData.empty(int projectId) {
    return WorkEntryData(
      projectId: projectId,
      dprSection: _getEmptyDPRSection(),
      workSection: _getEmptyWorkSection(),
      pmsSection: _getEmptyPMSSection(),
      isDraft: true,
    );
  }

  /// Convert WorkEntryData to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'work_id': workId,
      'name_of_work': nameOfWork,
      'person_responsible': personResponsible,
      'post_held': postHeld,
      'pending_with': pendingWith,
      'dpr_section': jsonEncode(dprSection),
      'work_section': jsonEncode(workSection),
      'pms_section': jsonEncode(pmsSection),
      'is_draft': isDraft ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Parse JSON section from string or map
  static Map<String, dynamic> _parseJsonSection(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  /// Get empty DPR section structure (65 fields - was 40, added 25)
  static Map<String, dynamic> _getEmptyDPRSection() {
    return {
      // Administrative Approval (added 5 new fields)
      'aa_status': null,
      'aa_amount': null,
      'aa_number': null, // NEW
      'aa_date': null, // NEW
      'aa_proposed_amount': null, // NEW
      'aa_proposal_date': null, // NEW
      'aa_pending_with': null, // NEW
      'broad_scope_aa': null,

      // DPR Bid Process (added 1 new field)
      'dpr_bid_doc_status': null,
      'invite_dpr_bid_status': null,
      'invite_dpr_bid_date': null,
      'prebid_meeting_date': null,
      'prebid_participants': null,
      'prebid_written_applications': null, // NEW

      // CSD & Bid Submission
      'csd_status': null,
      'csd_date': null,
      'bid_submission_date': null,
      'bid_opening_date': null,
      'bid_opening_count': null,

      // Technical & Financial Evaluation (added 4 new fields)
      'tech_eval_status': null,
      'tech_eval_qualified': null,
      'tech_eval_likely_completion': null, // NEW
      'tech_eval_results_published_date': null, // NEW
      'tech_eval_fin_bid_opening_informed': null, // NEW
      'fin_opening_date': null,
      'fin_opening_bid': null,
      'fin_opening_amount': null,
      'fin_opening_variance': null,
      'fin_bid_qualified_count': null, // NEW

      // Acceptance & LOA
      'bid_acceptance_status': null,
      'bid_acceptance_amount': null,
      'loa_status': null,
      'loa_date': null,

      // PBG & Insurance
      'pbg_status': null,
      'pbg_amount': null,
      'pbg_date': null,
      'pbg_period': null,
      'insurance_pii_status': null,
      'insurance_pii_amount': null,
      'insurance_pii_date': null,
      'insurance_pii_period': null,

      // Work Order & Reports
      'work_order_status': null,
      'work_order_date': null,
      'inception_report_status': null,

      // Technical Work
      'survey_status': null,
      'geotech_status': null,
      'alignment_status': null,
      'plan_profile_status': null,
      'pavement_design_status': null,
      'structures_design_status': null,
      'traffic_study_status': null,
      'junctions_status': null,
      'drainage_status': null,
      'furniture_layout_status': null,
      'misc_structures_status': null,

      // BOQ & DPR Finalization (added 1 new field)
      'boq_status': null,
      'boq_amount': null,
      'boq_likely_completion': null, // NEW
      'draft_dpr_status': null,

      // Clearances (added 6 new fields)
      'env_clearance_applicable': null,
      'env_clearance_status': null,
      'env_proposal_submitted_date': null, // NEW
      'env_status_description': null, // NEW
      'land_acquisition_applicable': null,
      'land_acquisition_status': null,
      'la_proposal_submitted_date': null, // NEW
      'la_status_description': null, // NEW
      'utility_shifting_applicable': null,
      'utility_shifting_status': null,
      'utility_proposal_submitted_date': null, // NEW
      'utility_status_description': null, // NEW

      // Final DPR & Bid Doc
      'quarry_chart_status': null,
      'final_dpr_status': null,
      'dpr_approval_status': null,
      'contractor_bid_doc_status': null,
      'rfp_status': null,
      'gcc_status': null,
      'schedules_status': null,
      'drawings_volume_status': null,
    };
  }

  /// Get empty Work section structure (26 fields - was 20, added 6)
  static Map<String, dynamic> _getEmptyWorkSection() {
    return {
      // Approvals (added 3 new fields)
      'admin_approval': null,
      'admin_approval_amount': null,
      'broad_scope_work': null,
      'tech_sanction_status': null,
      'tech_sanction_amount': null,
      'ts_number': null, // NEW
      'ts_date': null, // NEW
      'ts_likely_submission_date': null, // NEW
      'detailed_scope_work': null,
      'contract_type': null,

      // Bid Process (added 1 new field)
      'dtp_approval_status': null,
      'nit_invitation_status': null,
      'nit_invitation_date': null,
      'nit_likely_issue_date': null, // NEW
      'bid_doc_upload_status': null,
      'bid_doc_upload_date': null,
      'prebid_meeting_date': null,

      // CSD & Bidding
      'csd_replies_status': null,
      'csd_replies_date': null,
      'bid_submission_date_work': null,
      'bid_opening_date_work': null,
      'bid_opening_count_work': null,

      // Financial Evaluation
      'fin_bid_opening_date': null,
      'fin_bid_qualified': null,
      'fin_bid_lowest': null,
      'fin_bid_variance': null,

      // Acceptance & Agreements
      'offer_acceptance': null,
      'offer_variance': null,
      'loi_status_work': null,
      'loi_date_work': null,
      'loa_status_work': null,
      'loa_date_work': null,

      // PBG & Agreement
      'pbg_status_work': null,
      'pbg_date_work': null,
      'pbg_amount_work': null,
      'pbg_period_work': null,
      'agreement_status': null,
      'agreement_date': null,
      'agreement_amount': null,

      // Work Order (added 2 new fields)
      'work_order_status_work': null,
      'work_order_date_work': null,
      'work_order_number': null, // NEW
      'work_order_amount': null,
      'work_order_period': null,
      'appointed_date': null, // NEW
    };
  }

  /// Get empty PMS section structure (90 fields - was 24, added 66)
  static Map<String, dynamic> _getEmptyPMSSection() {
    return {
      // Basic Info
      'agreement_amount_pms': null,
      'tender_period_pms': null,
      'insurance_submitted': null,
      'insurance_penalty': null,

      // Milestone 1 (added 8 new fields per milestone)
      'milestone_1_description': null, // NEW
      'milestone_1_period': null, // NEW
      'milestone_1_target_date': null,
      'milestone_1_target_amount': null,
      'milestone_1_physical_target': null, // NEW (%)
      'milestone_1_achieved_date': null,
      'milestone_1_achieved_amount': null,
      'milestone_1_physical_achieved': null, // NEW (%)
      'milestone_1_person_responsible': null, // NEW
      'milestone_1_post_held': null, // NEW
      'milestone_1_pending_with': null, // NEW
      'milestone_1_remarks': null, // NEW
      'ld_1_applicable': null,
      'ld_1_rate': null,
      'ld_1_recovery': null,

      // Milestone 2 (added 8 new fields)
      'milestone_2_description': null, // NEW
      'milestone_2_period': null, // NEW
      'milestone_2_target_date': null,
      'milestone_2_target_amount': null,
      'milestone_2_physical_target': null, // NEW (%)
      'milestone_2_achieved_date': null,
      'milestone_2_achieved_amount': null,
      'milestone_2_physical_achieved': null, // NEW (%)
      'milestone_2_person_responsible': null, // NEW
      'milestone_2_post_held': null, // NEW
      'milestone_2_pending_with': null, // NEW
      'milestone_2_remarks': null, // NEW
      'ld_2_applicable': null,
      'ld_2_rate': null,
      'ld_2_recovery': null,

      // Milestone 3 (added 8 new fields)
      'milestone_3_description': null, // NEW
      'milestone_3_period': null, // NEW
      'milestone_3_target_date': null,
      'milestone_3_target_amount': null,
      'milestone_3_physical_target': null, // NEW (%)
      'milestone_3_achieved_date': null,
      'milestone_3_achieved_amount': null,
      'milestone_3_physical_achieved': null, // NEW (%)
      'milestone_3_person_responsible': null, // NEW
      'milestone_3_post_held': null, // NEW
      'milestone_3_pending_with': null, // NEW
      'milestone_3_remarks': null, // NEW
      'ld_3_applicable': null,
      'ld_3_rate': null,
      'ld_3_recovery': null,

      // Milestone 4 (added 8 new fields)
      'milestone_4_description': null, // NEW
      'milestone_4_period': null, // NEW
      'milestone_4_target_date': null,
      'milestone_4_target_amount': null,
      'milestone_4_physical_target': null, // NEW (%)
      'milestone_4_achieved_date': null,
      'milestone_4_achieved_amount': null,
      'milestone_4_physical_achieved': null, // NEW (%)
      'milestone_4_person_responsible': null, // NEW
      'milestone_4_post_held': null, // NEW
      'milestone_4_pending_with': null, // NEW
      'milestone_4_remarks': null, // NEW
      'ld_4_applicable': null,
      'ld_4_rate': null,
      'ld_4_recovery': null,

      // Milestone 5 (added 8 new fields)
      'milestone_5_description': null, // NEW
      'milestone_5_period': null, // NEW
      'milestone_5_target_date': null,
      'milestone_5_target_amount': null,
      'milestone_5_physical_target': null, // NEW (%)
      'milestone_5_achieved_date': null,
      'milestone_5_achieved_amount': null,
      'milestone_5_physical_achieved': null, // NEW (%)
      'milestone_5_person_responsible': null, // NEW
      'milestone_5_post_held': null, // NEW
      'milestone_5_pending_with': null, // NEW
      'milestone_5_remarks': null, // NEW
      'ld_final_applicable': null,
      'ld_final_rate': null,
      'ld_final_recovery': null,
      'ld_amount_deposited': null, // NEW (LD)
      'ld_amount_released': null, // NEW (LD)

      // Changes & Extensions (added 11 new fields)
      'cos_status': null,
      'cos_date': null,
      'cos_amount': null,
      'cos_scope': null,
      'cos_proposed_items': null, // NEW (JSON table 3x4)
      'cos_approved_items': null, // NEW (JSON table 3x7)
      'eot_applicable': null,
      'eot_approved': null,
      'eot_period': null,
      'eot_proposal_submitted_date': null, // NEW
      'eot_with_escalation': null, // NEW (boolean)
      'eot_without_escalation': null, // NEW (boolean)
      'eot_by_freezing_indices': null, // NEW (boolean)
      'eot_without_ld': null, // NEW (boolean)
      'eot_with_ld': null, // NEW (boolean)
      'eot_compensation_payable': null, // NEW (boolean)
      'eot_compensation_claimed_amount': null, // NEW
      'eot_compensation_admitted_amount': null, // NEW

      // Expenditure
      'cum_exp_lakhs': null,
      'cum_exp_percentage': null,

      // Renewals
      'renewal_pbg_due': null,
      'renewal_pbg_status': null,
      'renewal_pbg_penalty': null,
      'renewal_insurance_due': null,
      'renewal_insurance_status': null,
      'renewal_insurance_penalty': null,

      // Revisions
      'revised_estimate_status': null,
      'revised_aa_status': null,
      'revised_aa_amount': null,
      'revised_aa_percentage': null,

      // Final Bill
      'final_bill_status': null,
      'final_bill_date': null,
      'final_bill_amount': null,
      'final_bill_percentage': null,

      // Audit & Questions (added 8 new fields for LAQ)
      'laq_lcq_status': null,
      'laq_lcq_action': null,
      'laq_lcq_description': null,
      'laq_count': null, // NEW
      'lcq_count': null, // NEW
      'lakshvwdhi_count': null, // NEW
      'laq_others_count': null, // NEW
      'laq_questions_items': null, // NEW (JSON table 3x4)
      'laq_replies_items': null, // NEW (JSON table 3x4)
      'laq_promises_items': null, // NEW (JSON table 3x4)
      'laq_compliance_items': null, // NEW (JSON table 3x5)
      'audit_para_applicable': null,
      'audit_para_points': null,
      'audit_para_replied': null,
      'audit_para_pending': null,
      'audit_para_dp': null,
      'audit_para_dropped': null,
      'audit_para_details_items': null, // NEW - Details of paras table (3x4)
      'audit_para_replies_items': null, // NEW - Replies Submitted table (3x4)
      'audit_para_closed_items': null, // NEW - Paras Closed table (3x4)

      // Technical Audit (added 3 new fields)
      'tech_audit_status': null,
      'tech_audit_report': null,
      'tech_audit_action': null,
      'tech_audit_no_action': null,
      'tech_audit_responsible_ee': null, // NEW
      'tech_audit_compliance_count': null, // NEW
      'tech_audit_compliance_dates': null, // NEW

      // Revised AA (added 1 new field)
      'rev_aa_recap_sheet_items': null, // NEW (JSON table)

      // Supplementary Agreement (added 1 new field)
      'suppl_agreement_period': null, // NEW
    };
  }

  /// Update a field in a specific section
  WorkEntryData updateField(String section, String fieldId, dynamic value) {
    final Map<String, dynamic> updatedSection;

    switch (section) {
      case 'dpr':
        updatedSection = Map<String, dynamic>.from(dprSection);
        updatedSection[fieldId] = value;
        return copyWith(dprSection: updatedSection);
      case 'work':
        updatedSection = Map<String, dynamic>.from(workSection);
        updatedSection[fieldId] = value;
        return copyWith(workSection: updatedSection);
      case 'pms':
        updatedSection = Map<String, dynamic>.from(pmsSection);
        updatedSection[fieldId] = value;
        return copyWith(pmsSection: updatedSection);
      default:
        return this;
    }
  }

  /// Calculate overall completion percentage
  double getCompletionPercentage() {
    int totalFields = 181; // Updated: 65 (DPR) + 26 (Work) + 90 (PMS)
    int completedFields = 0;

    // Count filled fields in DPR section
    completedFields += dprSection.values
        .where((v) => v != null && v.toString().isNotEmpty)
        .length;

    // Count filled fields in Work section
    completedFields += workSection.values
        .where((v) => v != null && v.toString().isNotEmpty)
        .length;

    // Count filled fields in PMS section
    completedFields += pmsSection.values
        .where((v) => v != null && v.toString().isNotEmpty)
        .length;

    return (completedFields / totalFields) * 100;
  }

  /// Get section completion percentage
  double getSectionCompletion(String section) {
    Map<String, dynamic> sectionData;
    int totalFields;

    switch (section) {
      case 'dpr':
        sectionData = dprSection;
        totalFields = 65; // Updated from 40
        break;
      case 'work':
        sectionData = workSection;
        totalFields = 26; // Updated from 20
        break;
      case 'pms':
        sectionData = pmsSection;
        totalFields = 90; // Updated from 24
        break;
      default:
        return 0;
    }

    final completedFields = sectionData.values
        .where((v) => v != null && v.toString().isNotEmpty)
        .length;

    return (completedFields / totalFields) * 100;
  }

  /// Copy with updated fields
  WorkEntryData copyWith({
    int? id,
    int? projectId,
    String? workId,
    String? nameOfWork,
    String? personResponsible,
    String? postHeld,
    String? pendingWith,
    Map<String, dynamic>? dprSection,
    Map<String, dynamic>? workSection,
    Map<String, dynamic>? pmsSection,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkEntryData(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      workId: workId ?? this.workId,
      nameOfWork: nameOfWork ?? this.nameOfWork,
      personResponsible: personResponsible ?? this.personResponsible,
      postHeld: postHeld ?? this.postHeld,
      pendingWith: pendingWith ?? this.pendingWith,
      dprSection: dprSection ?? this.dprSection,
      workSection: workSection ?? this.workSection,
      pmsSection: pmsSection ?? this.pmsSection,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkEntryData(id: $id, projectId: $projectId, isDraft: $isDraft, completion: ${getCompletionPercentage().toStringAsFixed(1)}%)';
  }
}
