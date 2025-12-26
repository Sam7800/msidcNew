import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../theme/app_colors.dart';
import '../../../data/models/work_entry_data.dart';
import '../../providers/repository_providers.dart';
import 'package:intl/intl.dart';

/// Work Entry Tab - Complete DPR form with all fields
class WorkEntryTab extends ConsumerStatefulWidget {
  final int projectId;

  const WorkEntryTab({super.key, required this.projectId});

  @override
  ConsumerState<WorkEntryTab> createState() => _WorkEntryTabState();
}

class _WorkEntryTabState extends ConsumerState<WorkEntryTab> {
  WorkEntryData? _workEntryData;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for top-level fields
  final _workIdController = TextEditingController();
  final _nameOfWorkController = TextEditingController();

  // Form data storage for DPR fields
  Map<String, dynamic> _formData = {};

  // Section expansion states
  bool _basicInfoExpanded = true;
  bool _dprSectionExpanded = true;
  bool _workSectionExpanded = false;
  bool _pmsSectionExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _workIdController.dispose();
    _nameOfWorkController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final repository = ref.read(workEntryRepositoryProvider);
    final data = await repository.getWorkEntryByProjectId(widget.projectId);

    setState(() {
      _workEntryData = data;
      _isLoading = false;

      if (data != null) {
        _workIdController.text = data.workId ?? '';
        _nameOfWorkController.text = data.nameOfWork ?? '';

        _formData = {
          ...data.dprSection,
          ...data.workSection,
          ...data.pmsSection,
        };
      }
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(workEntryRepositoryProvider);

    // Get DPR, Work, and PMS data
    final dprData = _getDPRSectionData();
    final workData = _getWorkSectionData();
    final pmsData = _getPMSSectionData();

    final updatedData = WorkEntryData(
      id: _workEntryData?.id,
      projectId: widget.projectId,
      workId: _workIdController.text.trim(),
      nameOfWork: _nameOfWorkController.text.trim(),
      personResponsible: null,
      postHeld: null,
      pendingWith: null,
      dprSection: dprData,
      workSection: workData,
      pmsSection: pmsData,
      isDraft: true,
    );

    await repository.saveDraft(updatedData);

    setState(() => _isEditing = false);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work entry saved as draft'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Map<String, dynamic> _getDPRSectionData() {
    // Return all DPR fields from _formData
    final dprKeys = [
      // Administrative Approval
      'aa_status',
      'aa_amount',
      'aa_person_responsible',
      'aa_post_held',
      'aa_pending_with',
      'broad_scope_aa',

      // DPR Bid Doc
      'dpr_bid_doc_status',
      'dpr_bid_doc_person_responsible',
      'dpr_bid_doc_post_held',
      'dpr_bid_doc_pending_with',

      // Inviting DPR Bid
      'invite_dpr_bid_status', 'invite_dpr_bid_date',
      'invite_dpr_person_responsible',
      'invite_dpr_post_held',
      'invite_dpr_pending_with',

      // Pre-bid Meeting
      'prebid_meeting_date', 'prebid_participants',
      'prebid_person_responsible', 'prebid_post_held', 'prebid_pending_with',

      // CSD
      'csd_status', 'csd_date',
      'csd_person_responsible', 'csd_post_held', 'csd_pending_with',

      // Bid Submission
      'bid_submission_date',
      'bid_submission_person_responsible',
      'bid_submission_post_held',
      'bid_submission_pending_with',

      // Bid Opening
      'bid_opening_date', 'bid_opening_count',
      'bid_opening_person_responsible',
      'bid_opening_post_held',
      'bid_opening_pending_with',

      // Technical Evaluation
      'tech_eval_status', 'tech_eval_qualified',
      'tech_eval_person_responsible',
      'tech_eval_post_held',
      'tech_eval_pending_with',

      // Financial Opening
      'fin_opening_date',
      'fin_opening_bid',
      'fin_opening_amount',
      'fin_opening_variance',
      'fin_opening_person_responsible',
      'fin_opening_post_held',
      'fin_opening_pending_with',

      // Acceptance of Bid
      'bid_acceptance_status', 'bid_acceptance_amount',
      'bid_acceptance_person_responsible',
      'bid_acceptance_post_held',
      'bid_acceptance_pending_with',

      // LOA
      'loa_status', 'loa_date',
      'loa_person_responsible', 'loa_post_held', 'loa_pending_with',

      // PBG Submission
      'pbg_status', 'pbg_amount', 'pbg_date', 'pbg_period',
      'pbg_person_responsible', 'pbg_post_held', 'pbg_pending_with',

      // Insurance Submission (PII)
      'insurance_pii_status',
      'insurance_pii_amount',
      'insurance_pii_date',
      'insurance_pii_period',
      'insurance_pii_person_responsible',
      'insurance_pii_post_held',
      'insurance_pii_pending_with',

      // Work Order
      'work_order_status', 'work_order_date',
      'work_order_person_responsible',
      'work_order_post_held',
      'work_order_pending_with',

      // Inception Report
      'inception_report_status',
      'inception_person_responsible',
      'inception_post_held',
      'inception_pending_with',

      // Survey
      'survey_status',
      'survey_person_responsible', 'survey_post_held', 'survey_pending_with',

      // Geotechnical Investigation
      'geotech_status',
      'geotech_person_responsible', 'geotech_post_held', 'geotech_pending_with',

      // Fixing of Alignment
      'alignment_status',
      'alignment_person_responsible',
      'alignment_post_held',
      'alignment_pending_with',

      // Plan & Profile
      'plan_profile_status',
      'plan_profile_person_responsible',
      'plan_profile_post_held',
      'plan_profile_pending_with',

      // Pavement Design
      'pavement_design_status',
      'pavement_design_person_responsible',
      'pavement_design_post_held',
      'pavement_design_pending_with',

      // Structures Design
      'structures_design_status',
      'structures_design_person_responsible',
      'structures_design_post_held',
      'structures_design_pending_with',

      // Traffic Study Report
      'traffic_study_status',
      'traffic_study_person_responsible',
      'traffic_study_post_held',
      'traffic_study_pending_with',

      // Junctions
      'junctions_status',
      'junctions_person_responsible',
      'junctions_post_held',
      'junctions_pending_with',

      // Drainage Plan
      'drainage_status',
      'drainage_person_responsible',
      'drainage_post_held',
      'drainage_pending_with',

      // Furniture Layout
      'furniture_layout_status',
      'furniture_layout_person_responsible',
      'furniture_layout_post_held',
      'furniture_layout_pending_with',

      // Miscellaneous Structures
      'misc_structures_status',
      'misc_structures_person_responsible',
      'misc_structures_post_held',
      'misc_structures_pending_with',

      // BOQ
      'boq_status', 'boq_amount',
      'boq_person_responsible', 'boq_post_held', 'boq_pending_with',

      // Draft DPR
      'draft_dpr_status',
      'draft_dpr_person_responsible',
      'draft_dpr_post_held',
      'draft_dpr_pending_with',

      // Environmental Clearance
      'env_clearance_applicable', 'env_clearance_status',
      'env_clearance_person_responsible',
      'env_clearance_post_held',
      'env_clearance_pending_with',

      // Land Acquisition
      'land_acquisition_applicable', 'land_acquisition_status',
      'land_acquisition_person_responsible',
      'land_acquisition_post_held',
      'land_acquisition_pending_with',

      // Utility Shifting
      'utility_shifting_applicable', 'utility_shifting_status',
      'utility_shifting_person_responsible',
      'utility_shifting_post_held',
      'utility_shifting_pending_with',

      // Quarry Chart
      'quarry_chart_status',
      'quarry_chart_person_responsible',
      'quarry_chart_post_held',
      'quarry_chart_pending_with',

      // Final DPR
      'final_dpr_status',
      'final_dpr_person_responsible',
      'final_dpr_post_held',
      'final_dpr_pending_with',

      // DPR Approval
      'dpr_approval_status',
      'dpr_approval_person_responsible',
      'dpr_approval_post_held',
      'dpr_approval_pending_with',

      // Contractor Bid Doc
      'contractor_bid_doc_status',
      'contractor_bid_doc_person_responsible',
      'contractor_bid_doc_post_held',
      'contractor_bid_doc_pending_with',

      // RFP
      'rfp_status',
      'rfp_person_responsible', 'rfp_post_held', 'rfp_pending_with',

      // GCC
      'gcc_status',
      'gcc_person_responsible', 'gcc_post_held', 'gcc_pending_with',

      // Schedules
      'schedules_status',
      'schedules_person_responsible',
      'schedules_post_held',
      'schedules_pending_with',

      // Drawings Volume
      'drawings_volume_status',
      'drawings_volume_person_responsible',
      'drawings_volume_post_held',
      'drawings_volume_pending_with',
    ];

    final dprData = <String, dynamic>{};
    for (final key in dprKeys) {
      if (_formData.containsKey(key)) {
        dprData[key] = _formData[key];
      }
    }
    return dprData;
  }

  Map<String, dynamic> _getWorkSectionData() {
    // Return all Work section fields from _formData
    final workKeys = [
      // Administrative Approval
      'work_admin_approval_status', 'work_admin_approval_amount',
      'work_admin_approval_person_responsible',
      'work_admin_approval_post_held',
      'work_admin_approval_pending_with',

      // Broad Scope of Work
      'work_broad_scope',
      'work_broad_scope_person_responsible',
      'work_broad_scope_post_held',
      'work_broad_scope_pending_with',

      // Technical Sanction
      'work_tech_sanction_status', 'work_tech_sanction_amount',
      'work_tech_sanction_person_responsible',
      'work_tech_sanction_post_held',
      'work_tech_sanction_pending_with',

      // Detailed Scope of Work
      'work_detailed_scope',
      'work_detailed_scope_person_responsible',
      'work_detailed_scope_post_held',
      'work_detailed_scope_pending_with',

      // Type of Contract Proposed
      'work_contract_type',
      'work_contract_type_person_responsible',
      'work_contract_type_post_held',
      'work_contract_type_pending_with',

      // DTP Approval
      'work_dtp_approval_status',
      'work_dtp_approval_person_responsible',
      'work_dtp_approval_post_held',
      'work_dtp_approval_pending_with',

      // NIT Invitation
      'work_nit_invitation_status', 'work_nit_invitation_date',
      'work_nit_invitation_person_responsible',
      'work_nit_invitation_post_held',
      'work_nit_invitation_pending_with',

      // Uploading of Bid Doc
      'work_bid_upload_status', 'work_bid_upload_date',
      'work_bid_upload_person_responsible',
      'work_bid_upload_post_held',
      'work_bid_upload_pending_with',

      // Pre-Bid Meeting
      'work_prebid_meeting_date',
      'work_prebid_meeting_person_responsible',
      'work_prebid_meeting_post_held',
      'work_prebid_meeting_pending_with',

      // CSD / Replies to Queries
      'work_csd_status', 'work_csd_date',
      'work_csd_person_responsible',
      'work_csd_post_held',
      'work_csd_pending_with',

      // Bid Submission
      'work_bid_submission_date',
      'work_bid_submission_person_responsible',
      'work_bid_submission_post_held',
      'work_bid_submission_pending_with',

      // Bid Opening
      'work_bid_opening_date', 'work_bid_opening_count',
      'work_bid_opening_person_responsible',
      'work_bid_opening_post_held',
      'work_bid_opening_pending_with',

      // Financial Bid Opening
      'work_fin_bid_opening_date',
      'work_fin_bid_qualified',
      'work_fin_bid_lowest',
      'work_fin_bid_percentage',
      'work_fin_bid_opening_person_responsible',
      'work_fin_bid_opening_post_held',
      'work_fin_bid_opening_pending_with',

      // Acceptance of Offer
      'work_acceptance_status', 'work_acceptance_percentage',
      'work_acceptance_person_responsible',
      'work_acceptance_post_held',
      'work_acceptance_pending_with',

      // Letter of Intent
      'work_loi_status', 'work_loi_date',
      'work_loi_person_responsible',
      'work_loi_post_held',
      'work_loi_pending_with',

      // Letter of Acceptance
      'work_loa_status', 'work_loa_date',
      'work_loa_person_responsible',
      'work_loa_post_held',
      'work_loa_pending_with',

      // PBG Submission
      'work_pbg_status', 'work_pbg_date', 'work_pbg_amount', 'work_pbg_period',
      'work_pbg_person_responsible',
      'work_pbg_post_held',
      'work_pbg_pending_with',

      // Signing of Agreement
      'work_agreement_status', 'work_agreement_date', 'work_agreement_amount',
      'work_agreement_person_responsible',
      'work_agreement_post_held',
      'work_agreement_pending_with',

      // Work Order / Appointed Date
      'work_order_status',
      'work_order_date',
      'work_order_amount',
      'work_order_period',
      'work_order_person_responsible',
      'work_order_post_held',
      'work_order_pending_with',
    ];

    final workData = <String, dynamic>{};
    for (final key in workKeys) {
      if (_formData.containsKey(key)) {
        workData[key] = _formData[key];
      }
    }
    return workData;
  }

  Map<String, dynamic> _getPMSSectionData() {
    // Return all PMS section fields from _formData
    final pmsKeys = [
      // Agreement Amount & Tender Period
      'pms_agreement_amount',
      'pms_agreement_person_responsible',
      'pms_agreement_post_held',
      'pms_agreement_pending_with',
      'pms_tender_period',
      'pms_tender_period_person_responsible',
      'pms_tender_period_post_held',
      'pms_tender_period_pending_with',

      // Insurance Submitted
      'pms_insurance_status', 'pms_insurance_penalty',
      'pms_insurance_person_responsible',
      'pms_insurance_post_held',
      'pms_insurance_pending_with',

      // 1st Milestone & LD
      'pms_milestone_1_target_date',
      'pms_milestone_1_achieved_date',
      'pms_milestone_1_target_amt',
      'pms_milestone_1_achieved_amt',
      'pms_milestone_1_person_responsible',
      'pms_milestone_1_post_held',
      'pms_milestone_1_pending_with',
      'pms_ld_1_applicability', 'pms_ld_1_rate', 'pms_ld_1_recovery',
      'pms_ld_1_person_responsible',
      'pms_ld_1_post_held',
      'pms_ld_1_pending_with',

      // 2nd Milestone & LD
      'pms_milestone_2_target_date',
      'pms_milestone_2_achieved_date',
      'pms_milestone_2_target_amt',
      'pms_milestone_2_achieved_amt',
      'pms_milestone_2_person_responsible',
      'pms_milestone_2_post_held',
      'pms_milestone_2_pending_with',
      'pms_ld_2_applicability', 'pms_ld_2_rate', 'pms_ld_2_recovery',
      'pms_ld_2_person_responsible',
      'pms_ld_2_post_held',
      'pms_ld_2_pending_with',

      // 3rd Milestone & LD
      'pms_milestone_3_target_date',
      'pms_milestone_3_achieved_date',
      'pms_milestone_3_target_amt',
      'pms_milestone_3_achieved_amt',
      'pms_milestone_3_person_responsible',
      'pms_milestone_3_post_held',
      'pms_milestone_3_pending_with',
      'pms_ld_3_applicability', 'pms_ld_3_rate', 'pms_ld_3_recovery',
      'pms_ld_3_person_responsible',
      'pms_ld_3_post_held',
      'pms_ld_3_pending_with',

      // 4th Milestone & LD
      'pms_milestone_4_target_date',
      'pms_milestone_4_achieved_date',
      'pms_milestone_4_target_amt',
      'pms_milestone_4_achieved_amt',
      'pms_milestone_4_person_responsible',
      'pms_milestone_4_post_held',
      'pms_milestone_4_pending_with',
      'pms_ld_4_applicability', 'pms_ld_4_rate', 'pms_ld_4_recovery',
      'pms_ld_4_person_responsible',
      'pms_ld_4_post_held',
      'pms_ld_4_pending_with',

      // 5th Milestone & Final LD
      'pms_milestone_5_target_date',
      'pms_milestone_5_achieved_date',
      'pms_milestone_5_target_amt',
      'pms_milestone_5_achieved_amt',
      'pms_milestone_5_person_responsible',
      'pms_milestone_5_post_held',
      'pms_milestone_5_pending_with',
      'pms_ld_final_applicability',
      'pms_ld_final_rate',
      'pms_ld_final_recovery',
      'pms_ld_final_person_responsible',
      'pms_ld_final_post_held',
      'pms_ld_final_pending_with',

      // Change of Scope Order
      'pms_cos_status', 'pms_cos_date', 'pms_cos_amount', 'pms_cos_scope',
      'pms_cos_person_responsible', 'pms_cos_post_held', 'pms_cos_pending_with',

      // Extension of Time
      'pms_eot_status', 'pms_eot_period',
      'pms_eot_person_responsible', 'pms_eot_post_held', 'pms_eot_pending_with',

      // Cumulative Expenditure
      'pms_cum_exp_amount', 'pms_cum_exp_percentage',
      'pms_cum_exp_person_responsible',
      'pms_cum_exp_post_held',
      'pms_cum_exp_pending_with',

      // Renewal PBG
      'pms_renewal_pbg_date', 'pms_renewal_pbg_status',
      'pms_renewal_pbg_person_responsible',
      'pms_renewal_pbg_post_held',
      'pms_renewal_pbg_pending_with',

      // Renewal of Insurance
      'pms_renewal_insurance_date', 'pms_renewal_insurance_status',
      'pms_renewal_insurance_person_responsible',
      'pms_renewal_insurance_post_held',
      'pms_renewal_insurance_pending_with',

      // Revised Estimate
      'pms_revised_estimate_status',
      'pms_revised_estimate_person_responsible',
      'pms_revised_estimate_post_held',
      'pms_revised_estimate_pending_with',

      // Revised AA
      'pms_revised_aa_status',
      'pms_revised_aa_amount',
      'pms_revised_aa_percentage',
      'pms_revised_aa_person_responsible',
      'pms_revised_aa_post_held',
      'pms_revised_aa_pending_with',

      // Final Bill & Expenditure
      'pms_final_bill_status',
      'pms_final_bill_date',
      'pms_final_bill_amount',
      'pms_final_bill_percentage',
      'pms_final_bill_person_responsible',
      'pms_final_bill_post_held',
      'pms_final_bill_pending_with',

      // LAQ/LCQ
      'pms_laq_lcq_status',
      'pms_laq_lcq_action_proposed',
      'pms_laq_lcq_action_description',
      'pms_laq_lcq_person_responsible',
      'pms_laq_lcq_post_held',
      'pms_laq_lcq_pending_with',

      // Audit Para Replies
      'pms_audit_para_applicability',
      'pms_audit_para_points_count',
      'pms_audit_para_reply_given',
      'pms_audit_para_reply_pending',
      'pms_audit_para_dp_count',
      'pms_audit_para_dropped_count',
      'pms_audit_para_person_responsible',
      'pms_audit_para_post_held',
      'pms_audit_para_pending_with',

      // Technical Audit / Reports
      'pms_tech_audit_status', 'pms_tech_audit_action_description',
      'pms_tech_audit_person_responsible',
      'pms_tech_audit_post_held',
      'pms_tech_audit_pending_with',
    ];

    final pmsData = <String, dynamic>{};
    for (final key in pmsKeys) {
      if (_formData.containsKey(key)) {
        pmsData[key] = _formData[key];
      }
    }
    return pmsData;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              color: AppColors.surfaceVariant.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Work Entry',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      if (_isEditing) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _isEditing = false);
                            _loadData();
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _saveData,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Draft'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Form Sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Basic Info Section
                  _buildSection(
                    title: 'Basic Information',
                    subtitle: 'Work identification details',
                    icon: Icons.info_outline,
                    color: AppColors.primary,
                    isExpanded: _basicInfoExpanded,
                    onExpand: (expanded) =>
                        setState(() => _basicInfoExpanded = expanded),
                    children: _buildBasicInfoFields(),
                  ),

                  const SizedBox(height: 16),

                  // DPR Section
                  _buildSection(
                    title: 'DPR Section',
                    subtitle: 'Complete DPR tracking with all fields',
                    icon: Icons.document_scanner,
                    color: AppColors.categoryNashik,
                    isExpanded: _dprSectionExpanded,
                    onExpand: (expanded) =>
                        setState(() => _dprSectionExpanded = expanded),
                    children: _buildDPRFields(),
                  ),

                  const SizedBox(height: 16),

                  // Work Section
                  _buildSection(
                    title: 'Work Section',
                    subtitle: 'Work execution and contract tracking',
                    icon: Icons.work,
                    color: AppColors.categoryHAM,
                    isExpanded: _workSectionExpanded,
                    onExpand: (expanded) =>
                        setState(() => _workSectionExpanded = expanded),
                    children: _buildWorkFields(),
                  ),

                  const SizedBox(height: 16),

                  // PMS Section
                  _buildSection(
                    title: 'PMS Section',
                    subtitle: 'Project monitoring and milestone tracking',
                    icon: Icons.analytics,
                    color: AppColors.categoryNHAI,
                    isExpanded: _pmsSectionExpanded,
                    onExpand: (expanded) =>
                        setState(() => _pmsSectionExpanded = expanded),
                    children: _buildPMSFields(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isExpanded,
    required Function(bool) onExpand,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpand,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBasicInfoFields() {
    return [
      _buildLabeledTextField(
        label: 'Work ID',
        controller: _workIdController,
        hint: 'Enter alphanumeric work identifier',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Name of Work',
        controller: _nameOfWorkController,
        hint: 'Enter work name/description',
        enabled: _isEditing,
      ),
    ];
  }

  List<Widget> _buildDPRFields() {
    return [
      // AA (Administrative Approval)
      _buildSectionHeader('Administrative Approval (AA)'),
      _buildRadioGroupField(
        label: 'AA Status',
        fieldKey: 'aa_status',
        options: ['Awaited', 'Accorded'],
      ),
      _buildLabeledTextField(
        label: 'AA Amount',
        fieldKey: 'aa_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('aa'),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Broad Scope in AA',
        fieldKey: 'broad_scope_aa',
        hint: 'Enter broad scope description',
        enabled: _isEditing,
        maxLines: 3,
      ),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // DPR Bid Doc for Consultant
      _buildSectionHeader('DPR Bid Doc for Consultant'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'dpr_bid_doc_status',
        options: ['Not Started', 'In progress', 'Ready', 'Approved'],
      ),
      _buildResponsibilityFields('dpr_bid_doc'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Inviting DPR Bid
      _buildSectionHeader('Inviting DPR Bid'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'invite_dpr_bid_status',
        options: ['Not invited yet', 'Invited'],
      ),
      _buildLabeledDateField(
        label: 'Invited Date',
        fieldKey: 'invite_dpr_bid_date',
        hint: 'Select invited date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('invite_dpr'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Pre-Bid Meeting
      _buildSectionHeader('Pre-Bid Meeting'),
      _buildLabeledDateField(
        label: 'Meeting Date',
        fieldKey: 'prebid_meeting_date',
        hint: 'Select meeting date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '# of Participants',
        fieldKey: 'prebid_participants',
        hint: 'Enter number of participants',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('prebid'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // CSD
      _buildSectionHeader('CSD'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'csd_status',
        options: ['In Process', 'Approved', 'Uploaded'],
      ),
      _buildLabeledDateField(
        label: 'Date',
        fieldKey: 'csd_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('csd'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Bid Submission
      _buildSectionHeader('Bid Submission'),
      _buildLabeledDateField(
        label: 'Submission Date',
        fieldKey: 'bid_submission_date',
        hint: 'Select submission date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('bid_submission'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Bid Opening
      _buildSectionHeader('Bid Opening'),
      _buildLabeledDateField(
        label: 'Opening Date',
        fieldKey: 'bid_opening_date',
        hint: 'Select opening date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '# Submitted',
        fieldKey: 'bid_opening_count',
        hint: 'Enter number of bids submitted',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('bid_opening'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Technical Evaluation
      _buildSectionHeader('Technical Evaluation'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'tech_eval_status',
        options: ['In progress', 'Completed'],
      ),
      _buildLabeledTextField(
        label: '# Qualified',
        fieldKey: 'tech_eval_qualified',
        hint: 'Enter number qualified',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('tech_eval'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Financial Opening
      _buildSectionHeader('Financial Opening'),
      _buildLabeledDateField(
        label: 'Opening Date',
        fieldKey: 'fin_opening_date',
        hint: 'Select opening date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Successful Bid',
        fieldKey: 'fin_opening_bid',
        hint: 'Enter successful bid reference',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Amount (Rs. Lakhs)',
        fieldKey: 'fin_opening_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '(+ / -) Variance',
        fieldKey: 'fin_opening_variance',
        hint: 'Enter variance',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('fin_opening'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Acceptance of Bid
      _buildSectionHeader('Acceptance of Bid'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'bid_acceptance_status',
        options: ['In progress', 'Accepted'],
      ),
      _buildLabeledTextField(
        label: 'Final Amount',
        fieldKey: 'bid_acceptance_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('bid_acceptance'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // LOA
      _buildSectionHeader('LOA (Letter of Acceptance)'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'loa_status',
        options: ['Not issued', 'Issued'],
      ),
      _buildLabeledDateField(
        label: 'Issue Date',
        fieldKey: 'loa_date',
        hint: 'Select issue date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('loa'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // PBG Submission
      _buildSectionHeader('PBG Submission'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pbg_status',
        options: ['Not submitted', 'Submitted'],
      ),
      _buildLabeledTextField(
        label: 'Amount',
        fieldKey: 'pbg_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Submission Date',
        fieldKey: 'pbg_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Period (months)',
        fieldKey: 'pbg_period',
        hint: 'Enter period in months',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pbg'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Insurance Submission (PII)
      _buildSectionHeader('Insurance Submission (PII)'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'insurance_pii_status',
        options: ['Not submitted', 'Submitted'],
      ),
      _buildLabeledTextField(
        label: 'Amount',
        fieldKey: 'insurance_pii_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Submission Date',
        fieldKey: 'insurance_pii_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Period (months)',
        fieldKey: 'insurance_pii_period',
        hint: 'Enter period in months',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('insurance_pii'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Work Order
      _buildSectionHeader('Work Order'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_order_status',
        options: ['Not Issued', 'Issued'],
      ),
      _buildLabeledDateField(
        label: 'Issue Date',
        fieldKey: 'work_order_date',
        hint: 'Select issue date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('work_order'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Inception Report
      _buildSectionHeader('Inception Report'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'inception_report_status',
        options: ['Not submitted', 'Submitted'],
      ),
      _buildResponsibilityFields('inception'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Survey
      _buildSectionHeader('Survey'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'survey_status',
        options: ['In progress', 'Completed', 'Validated'],
      ),
      _buildResponsibilityFields('survey'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Geotechnical Investigation
      _buildSectionHeader('Geotechnical Investigation'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'geotech_status',
        options: ['In progress', 'Completed'],
      ),
      _buildResponsibilityFields('geotech'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Fixing of Alignment
      _buildSectionHeader('Fixing of Alignment'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'alignment_status',
        options: ['In progress', 'Prepared', 'Submitted', 'Approved'],
      ),
      _buildResponsibilityFields('alignment'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Plan & Profile
      _buildSectionHeader('Plan & Profile'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'plan_profile_status',
        options: ['In progress', 'Completed', 'Submitted', 'Approved'],
      ),
      _buildResponsibilityFields('plan_profile'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Pavement Design
      _buildSectionHeader('Pavement Design'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pavement_design_status',
        options: ['Prepared', 'Submitted', 'Approved'],
      ),
      _buildResponsibilityFields('pavement_design'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Structures Design
      _buildSectionHeader('Structures Design'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'structures_design_status',
        options: ['In progress', 'Submitted', 'Approved'],
      ),
      _buildResponsibilityFields('structures_design'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Traffic Study Report
      _buildSectionHeader('Traffic Study Report'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'traffic_study_status',
        options: ['Not started', 'In progress', 'Completed', 'Submitted'],
      ),
      _buildResponsibilityFields('traffic_study'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Junctions
      _buildSectionHeader('Junctions'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'junctions_status',
        options: ['In progress', 'Submitted', 'Approved'],
      ),
      _buildResponsibilityFields('junctions'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Drainage Plan
      _buildSectionHeader('Drainage Plan'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'drainage_status',
        options: ['In progress', 'Submitted', 'Approved'],
      ),
      _buildResponsibilityFields('drainage'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Furniture Layout
      _buildSectionHeader('Furniture Layout'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'furniture_layout_status',
        options: ['Not Started', 'In progress', 'Submitted', 'Approved'],
      ),
      _buildResponsibilityFields('furniture_layout'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Miscellaneous Structures
      _buildSectionHeader('Miscellaneous Structures'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'misc_structures_status',
        options: ['Not started', 'In progress', 'Submitted', 'Approved'],
      ),
      _buildResponsibilityFields('misc_structures'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // BOQ
      _buildSectionHeader('BOQ (Bill of Quantities)'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'boq_status',
        options: ['Not Started', 'In progress', 'Ready'],
      ),
      _buildLabeledTextField(
        label: 'Amount (Rs. Lakhs)',
        fieldKey: 'boq_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('boq'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Draft DPR
      _buildSectionHeader('Draft DPR'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'draft_dpr_status',
        options: ['In progress', 'Submitted'],
      ),
      _buildResponsibilityFields('draft_dpr'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Environmental Clearance
      _buildSectionHeader('Environmental Clearance'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'env_clearance_applicable',
        options: ['Not Applicable', 'Applicable'],
      ),
      _buildLabeledTextField(
        label: 'Status (if applicable)',
        fieldKey: 'env_clearance_status',
        hint: 'Enter status',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('env_clearance'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Land Acquisition
      _buildSectionHeader('Land Acquisition'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'land_acquisition_applicable',
        options: ['Not Applicable', 'Applicable'],
      ),
      _buildLabeledTextField(
        label: 'Status (if applicable)',
        fieldKey: 'land_acquisition_status',
        hint: 'Enter status',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('land_acquisition'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Utility Shifting
      _buildSectionHeader('Utility Shifting'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'utility_shifting_applicable',
        options: ['Not Applicable', 'Applicable'],
      ),
      _buildLabeledTextField(
        label: 'Status (if applicable)',
        fieldKey: 'utility_shifting_status',
        hint: 'Enter status',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('utility_shifting'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Quarry Chart
      _buildSectionHeader('Quarry Chart'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'quarry_chart_status',
        options: ['Not Started', 'Ready'],
      ),
      _buildResponsibilityFields('quarry_chart'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Final DPR
      _buildSectionHeader('Final DPR'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'final_dpr_status',
        options: ['Not Started', 'In progress', 'Ready', 'Submitted'],
      ),
      _buildResponsibilityFields('final_dpr'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // DPR Approval
      _buildSectionHeader('DPR Approval'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'dpr_approval_status',
        options: ['In Process', 'Approved'],
      ),
      _buildResponsibilityFields('dpr_approval'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Contractor Bid Doc
      _buildSectionHeader('Contractor Bid Doc'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'contractor_bid_doc_status',
        options: ['Not Started', 'In progress', 'Ready', 'Submitted'],
      ),
      _buildResponsibilityFields('contractor_bid_doc'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // RFP
      _buildSectionHeader('RFP (Request for Proposal)'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'rfp_status',
        options: [
          'Not started',
          'In progress',
          'Ready',
          'Submitted',
          'Approved',
        ],
      ),
      _buildResponsibilityFields('rfp'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // GCC
      _buildSectionHeader('GCC (General Conditions of Contract)'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'gcc_status',
        options: [
          'Not started',
          'In progress',
          'Ready',
          'Submitted',
          'Approved',
        ],
      ),
      _buildResponsibilityFields('gcc'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Schedules
      _buildSectionHeader('Schedules'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'schedules_status',
        options: [
          'Not started',
          'In progress',
          'Ready',
          'Submitted',
          'Approved',
        ],
      ),
      _buildResponsibilityFields('schedules'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Drawings Volume
      _buildSectionHeader('Drawings Volume'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'drawings_volume_status',
        options: [
          'Not Started',
          'In progress',
          'Ready',
          'Submitted',
          'Approved',
        ],
      ),
      _buildResponsibilityFields('drawings_volume'),
    ];
  }

  List<Widget> _buildWorkFields() {
    return [
      // Administrative Approval
      _buildSectionHeader('Administrative Approval'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_admin_approval_status',
        options: ['Not Yet', 'Yes'],
      ),
      _buildLabeledTextField(
        label: 'Amount (Rs.)',
        fieldKey: 'work_admin_approval_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('work_admin_approval'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Broad Scope of Work
      _buildSectionHeader('Broad Scope of Work'),
      _buildLabeledTextField(
        label: 'Description',
        fieldKey: 'work_broad_scope',
        hint: 'Enter broad scope description (up to 500 words)',
        enabled: _isEditing,
        maxLines: 10,
      ),
      _buildResponsibilityFields('work_broad_scope'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Technical Sanction
      _buildSectionHeader('Technical Sanction'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_tech_sanction_status',
        options: ['In progress', 'Ready', 'Submitted', 'Approved'],
      ),
      _buildLabeledTextField(
        label: 'Amount (Rs.)',
        fieldKey: 'work_tech_sanction_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('work_tech_sanction'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Detailed Scope of Work
      _buildSectionHeader('Detailed Scope of Work'),
      _buildLabeledTextField(
        label: 'Description',
        fieldKey: 'work_detailed_scope',
        hint: 'Enter detailed scope description',
        enabled: _isEditing,
        maxLines: 15,
      ),
      _buildResponsibilityFields('work_detailed_scope'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Type of Contract Proposed
      _buildSectionHeader('Type of Contract Proposed'),
      _buildDropdownField(
        label: 'Contract Type',
        fieldKey: 'work_contract_type',
        options: ['EPC', 'Item Rate B-2', '% Rate B-1', 'BOT'],
      ),
      _buildResponsibilityFields('work_contract_type'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // DTP Approval
      _buildSectionHeader('DTP Approval'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_dtp_approval_status',
        options: ['Not submitted', 'Submitted', 'In process', 'Approved'],
      ),
      _buildResponsibilityFields('work_dtp_approval'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // NIT Invitation
      _buildSectionHeader('NIT Invitation'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_nit_invitation_status',
        options: ['Not Ready', 'Ready', 'Published'],
      ),
      _buildLabeledDateField(
        label: 'Published Date',
        fieldKey: 'work_nit_invitation_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('work_nit_invitation'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Uploading of Bid Doc
      _buildSectionHeader('Uploading of Bid Doc'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_bid_upload_status',
        options: ['In Progress', 'Uploaded'],
      ),
      _buildLabeledDateField(
        label: 'Upload Date',
        fieldKey: 'work_bid_upload_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('work_bid_upload'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Pre-Bid Meeting
      _buildSectionHeader('Pre-Bid Meeting'),
      _buildLabeledDateField(
        label: 'Meeting Date',
        fieldKey: 'work_prebid_meeting_date',
        hint: 'Select meeting date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('work_prebid_meeting'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // CSD / Replies to Queries
      _buildSectionHeader('CSD / Replies to Queries'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_csd_status',
        options: ['In progress', 'Submitted', 'Approved', 'Uploaded'],
      ),
      _buildLabeledDateField(
        label: 'Date',
        fieldKey: 'work_csd_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('work_csd'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Bid Submission
      _buildSectionHeader('Bid Submission'),
      _buildLabeledDateField(
        label: 'Submission Date',
        fieldKey: 'work_bid_submission_date',
        hint: 'Select submission date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('work_bid_submission'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Bid Opening
      _buildSectionHeader('Bid Opening'),
      _buildLabeledDateField(
        label: 'Opening Date',
        fieldKey: 'work_bid_opening_date',
        hint: 'Select opening date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '# Submitted',
        fieldKey: 'work_bid_opening_count',
        hint: 'Enter number of bids submitted',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('work_bid_opening'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Financial Bid Opening
      _buildSectionHeader('Financial Bid Opening'),
      _buildLabeledDateField(
        label: 'Opening Date',
        fieldKey: 'work_fin_bid_opening_date',
        hint: 'Select opening date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '# Qualified',
        fieldKey: 'work_fin_bid_qualified',
        hint: 'Enter number qualified',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Lowest Bid',
        fieldKey: 'work_fin_bid_lowest',
        hint: 'Enter lowest bid',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '% +/-',
        fieldKey: 'work_fin_bid_percentage',
        hint: 'Enter percentage variance',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('work_fin_bid_opening'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Acceptance of Offer
      _buildSectionHeader('Acceptance of Offer'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_acceptance_status',
        options: ['Accepted', 'Rejected'],
      ),
      _buildLabeledTextField(
        label: '% +/-',
        fieldKey: 'work_acceptance_percentage',
        hint: 'Enter percentage',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('work_acceptance'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Letter of Intent
      _buildSectionHeader('Letter of Intent'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_loi_status',
        options: ['Not issued', 'Issued'],
      ),
      _buildLabeledDateField(
        label: 'Issue Date',
        fieldKey: 'work_loi_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('work_loi'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Letter of Acceptance
      _buildSectionHeader('Letter of Acceptance'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_loa_status',
        options: ['Not issued', 'Issued'],
      ),
      _buildLabeledDateField(
        label: 'Issue Date',
        fieldKey: 'work_loa_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      _buildResponsibilityFields('work_loa'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // PBG Submission
      _buildSectionHeader('PBG Submission'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_pbg_status',
        options: ['Not yet', 'Submitted'],
      ),
      _buildLabeledDateField(
        label: 'Submission Date',
        fieldKey: 'work_pbg_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Amount',
        fieldKey: 'work_pbg_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Period (months)',
        fieldKey: 'work_pbg_period',
        hint: 'Enter period in months',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('work_pbg'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Signing of Agreement
      _buildSectionHeader('Signing of Agreement'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_agreement_status',
        options: ['Not Signed', 'Signed'],
      ),
      _buildLabeledDateField(
        label: 'Signing Date',
        fieldKey: 'work_agreement_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Amount',
        fieldKey: 'work_agreement_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('work_agreement'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Work Order / Appointed Date
      _buildSectionHeader('Work Order / Appointed Date'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'work_order_status',
        options: ['Not issued', 'Issued'],
      ),
      _buildLabeledDateField(
        label: 'Issue Date',
        fieldKey: 'work_order_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Amount',
        fieldKey: 'work_order_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Period (months)',
        fieldKey: 'work_order_period',
        hint: 'Enter period (default: 24 months)',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('work_order'),
    ];
  }

  List<Widget> _buildPMSFields() {
    return [
      // Agreement Amount
      _buildSectionHeader('Agreement Amount'),
      _buildLabeledTextField(
        label: 'Amount (Rs. Lakhs)',
        fieldKey: 'pms_agreement_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_agreement'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Tender Period
      _buildSectionHeader('Tender Period'),
      _buildLabeledTextField(
        label: 'Period (Months)',
        fieldKey: 'pms_tender_period',
        hint: 'Enter period in months',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_tender_period'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Insurance Submitted
      _buildSectionHeader('Insurance Submitted'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_insurance_status',
        options: ['Yes', 'No'],
      ),
      const SizedBox(height: 16),
      _buildRadioGroupField(
        label: 'Penalty',
        fieldKey: 'pms_insurance_penalty',
        options: ['Yes', 'No'],
      ),
      _buildResponsibilityFields('pms_insurance'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Ist Milestone
      _buildSectionHeader('1st Milestone'),
      _buildLabeledDateField(
        label: 'Target Date',
        fieldKey: 'pms_milestone_1_target_date',
        hint: 'Select target date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Achieved Date',
        fieldKey: 'pms_milestone_1_achieved_date',
        hint: 'Select achieved date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Target Amount',
        fieldKey: 'pms_milestone_1_target_amt',
        hint: 'Enter target amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Achieved Amount',
        fieldKey: 'pms_milestone_1_achieved_amt',
        hint: 'Enter achieved amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_milestone_1'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Ist Liquidated Damages
      _buildSectionHeader('1st Liquidated Damages'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'pms_ld_1_applicability',
        options: ['Not Applicable', 'Applicable'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Rate',
        fieldKey: 'pms_ld_1_rate',
        hint: 'Enter rate',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Recovery',
        fieldKey: 'pms_ld_1_recovery',
        hint: 'Enter recovery amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_ld_1'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // IInd Milestone
      _buildSectionHeader('2nd Milestone'),
      _buildLabeledDateField(
        label: 'Target Date',
        fieldKey: 'pms_milestone_2_target_date',
        hint: 'Select target date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Achieved Date',
        fieldKey: 'pms_milestone_2_achieved_date',
        hint: 'Select achieved date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Target Amount',
        fieldKey: 'pms_milestone_2_target_amt',
        hint: 'Enter target amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Achieved Amount',
        fieldKey: 'pms_milestone_2_achieved_amt',
        hint: 'Enter achieved amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_milestone_2'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // IInd Liquidated Damages
      _buildSectionHeader('2nd Liquidated Damages'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'pms_ld_2_applicability',
        options: ['Not Applicable', 'Applicable'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Rate',
        fieldKey: 'pms_ld_2_rate',
        hint: 'Enter rate',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Recovery',
        fieldKey: 'pms_ld_2_recovery',
        hint: 'Enter recovery amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_ld_2'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // IIIrd Milestone
      _buildSectionHeader('3rd Milestone'),
      _buildLabeledDateField(
        label: 'Target Date',
        fieldKey: 'pms_milestone_3_target_date',
        hint: 'Select target date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Achieved Date',
        fieldKey: 'pms_milestone_3_achieved_date',
        hint: 'Select achieved date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Target Amount',
        fieldKey: 'pms_milestone_3_target_amt',
        hint: 'Enter target amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Achieved Amount',
        fieldKey: 'pms_milestone_3_achieved_amt',
        hint: 'Enter achieved amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_milestone_3'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // IIIrd Liquidated Damages
      _buildSectionHeader('3rd Liquidated Damages'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'pms_ld_3_applicability',
        options: ['Not Applicable', 'Applicable'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Rate',
        fieldKey: 'pms_ld_3_rate',
        hint: 'Enter rate',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Recovery',
        fieldKey: 'pms_ld_3_recovery',
        hint: 'Enter recovery amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_ld_3'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // IVth Milestone
      _buildSectionHeader('4th Milestone'),
      _buildLabeledDateField(
        label: 'Target Date',
        fieldKey: 'pms_milestone_4_target_date',
        hint: 'Select target date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Achieved Date',
        fieldKey: 'pms_milestone_4_achieved_date',
        hint: 'Select achieved date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Target Amount',
        fieldKey: 'pms_milestone_4_target_amt',
        hint: 'Enter target amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Achieved Amount',
        fieldKey: 'pms_milestone_4_achieved_amt',
        hint: 'Enter achieved amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_milestone_4'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // IVth Liquidated Damages
      _buildSectionHeader('4th Liquidated Damages'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'pms_ld_4_applicability',
        options: ['Not Applicable', 'Applicable'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Rate',
        fieldKey: 'pms_ld_4_rate',
        hint: 'Enter rate',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Recovery',
        fieldKey: 'pms_ld_4_recovery',
        hint: 'Enter recovery amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_ld_4'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Vth Milestone
      _buildSectionHeader('5th Milestone'),
      _buildLabeledDateField(
        label: 'Target Date',
        fieldKey: 'pms_milestone_5_target_date',
        hint: 'Select target date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Achieved Date',
        fieldKey: 'pms_milestone_5_achieved_date',
        hint: 'Select achieved date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Target Amount',
        fieldKey: 'pms_milestone_5_target_amt',
        hint: 'Enter target amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Achieved Amount',
        fieldKey: 'pms_milestone_5_achieved_amt',
        hint: 'Enter achieved amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_milestone_5'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Final Liquidated Damages
      _buildSectionHeader('Final Liquidated Damages'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'pms_ld_final_applicability',
        options: ['Not Applicable', 'Applicable'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Rate',
        fieldKey: 'pms_ld_final_rate',
        hint: 'Enter rate',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Recovery',
        fieldKey: 'pms_ld_final_recovery',
        hint: 'Enter recovery amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_ld_final'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Change of Scope Order
      _buildSectionHeader('Change of Scope Order'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_cos_status',
        options: ['Not Applicable', 'Issued'],
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Date',
        fieldKey: 'pms_cos_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Amount',
        fieldKey: 'pms_cos_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Scope',
        fieldKey: 'pms_cos_scope',
        hint: 'Enter scope description',
        enabled: _isEditing,
        maxLines: 3,
      ),
      _buildResponsibilityFields('pms_cos'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Extension of Time
      _buildSectionHeader('Extension of Time'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_eot_status',
        options: ['Not Applicable', 'Applicable', 'Approved'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Period',
        fieldKey: 'pms_eot_period',
        hint: 'Enter period',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_eot'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Cumulative Expenditure
      _buildSectionHeader('Cumulative Expenditure'),
      _buildLabeledTextField(
        label: 'Amount (Rs. Lakhs)',
        fieldKey: 'pms_cum_exp_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '% of Agreement Amount',
        fieldKey: 'pms_cum_exp_percentage',
        hint: 'Enter percentage',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_cum_exp'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Renewal PBG
      _buildSectionHeader('Renewal PBG'),
      _buildLabeledDateField(
        label: 'Date Due',
        fieldKey: 'pms_renewal_pbg_date',
        hint: 'Select due date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_renewal_pbg_status',
        options: ['Renewed', 'Jumped', 'Penalty'],
      ),
      _buildResponsibilityFields('pms_renewal_pbg'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Renewal of Insurance
      _buildSectionHeader('Renewal of Insurance'),
      _buildLabeledDateField(
        label: 'Date Due',
        fieldKey: 'pms_renewal_insurance_date',
        hint: 'Select due date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_renewal_insurance_status',
        options: ['Renewed', 'Jumped', 'Penalty'],
      ),
      _buildResponsibilityFields('pms_renewal_insurance'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Revised Estimate
      _buildSectionHeader('Revised Estimate'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_revised_estimate_status',
        options: [
          'Not Applicable',
          'Applicable',
          'In progress',
          'Submitted',
          'Approved',
        ],
      ),
      _buildResponsibilityFields('pms_revised_estimate'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Revised AA
      _buildSectionHeader('Revised AA'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_revised_aa_status',
        options: [
          'Not Applicable',
          'Submitted',
          'In process',
          'Approved',
          'Rejected',
        ],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Amount',
        fieldKey: 'pms_revised_aa_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '% of Original AA',
        fieldKey: 'pms_revised_aa_percentage',
        hint: 'Enter percentage',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_revised_aa'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Final Bill & Expenditure
      _buildSectionHeader('Final Bill & Expenditure'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_final_bill_status',
        options: ['Not Due', 'Submitted'],
      ),
      const SizedBox(height: 16),
      _buildLabeledDateField(
        label: 'Date',
        fieldKey: 'pms_final_bill_date',
        hint: 'Select date',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Amount',
        fieldKey: 'pms_final_bill_amount',
        hint: 'Enter amount',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '% of Agreement Amount',
        fieldKey: 'pms_final_bill_percentage',
        hint: 'Enter percentage',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_final_bill'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // LAQ/LCQ
      _buildSectionHeader('LAQ / LCQ'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_laq_lcq_status',
        options: ['Not Raised', 'Raised'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Action Proposed',
        fieldKey: 'pms_laq_lcq_action_proposed',
        hint: 'Enter action proposed',
        enabled: _isEditing,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Action Description',
        fieldKey: 'pms_laq_lcq_action_description',
        hint: 'Enter action description',
        enabled: _isEditing,
        maxLines: 3,
      ),
      _buildResponsibilityFields('pms_laq_lcq'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Audit Para Replies
      _buildSectionHeader('Audit Para Replies'),
      _buildRadioGroupField(
        label: 'Applicability',
        fieldKey: 'pms_audit_para_applicability',
        options: ['Not applicable', 'Applicable'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: '# of Points',
        fieldKey: 'pms_audit_para_points_count',
        hint: 'Enter number of points',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Reply Given #',
        fieldKey: 'pms_audit_para_reply_given',
        hint: 'Enter number of replies given',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Reply Pending #',
        fieldKey: 'pms_audit_para_reply_pending',
        hint: 'Enter number of replies pending',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'DP #',
        fieldKey: 'pms_audit_para_dp_count',
        hint: 'Enter DP count',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Dropped #',
        fieldKey: 'pms_audit_para_dropped_count',
        hint: 'Enter dropped count',
        enabled: _isEditing,
        keyboardType: TextInputType.number,
      ),
      _buildResponsibilityFields('pms_audit_para'),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),

      // Technical Audit / Reports
      _buildSectionHeader('Technical Audit / Reports'),
      _buildRadioGroupField(
        label: 'Status',
        fieldKey: 'pms_tech_audit_status',
        options: ['Not done', 'Done', 'Report issued', 'No Action required'],
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Action Description',
        fieldKey: 'pms_tech_audit_action_description',
        hint: 'Enter action description',
        enabled: _isEditing,
        maxLines: 3,
      ),
      _buildResponsibilityFields('pms_tech_audit'),
    ];
  }

  Widget _buildDropdownField({
    required String label,
    required String fieldKey,
    required List<String> options,
  }) {
    final currentValue = _formData[fieldKey]?.toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: currentValue?.isEmpty == true ? null : currentValue,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: !_isEditing,
              fillColor: _isEditing ? null : AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: options.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: _isEditing
                ? (value) {
                    setState(() {
                      _formData[fieldKey] = value ?? '';
                    });
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildResponsibilityFields(String prefix) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 0, top: 8, bottom: 8),
          title: Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Person Responsible & Tracking',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          children: [
            _buildLabeledTextField(
              label: 'Person Responsible',
              fieldKey: '${prefix}_person_responsible',
              hint: 'Enter person responsible',
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildLabeledTextField(
              label: 'Post Held',
              fieldKey: '${prefix}_post_held',
              hint: 'Enter post/designation',
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildLabeledTextField(
              label: 'Pending with whom',
              fieldKey: '${prefix}_pending_with',
              hint: 'Enter pending with whom',
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    TextEditingController? controller,
    String? fieldKey,
    String? hint,
    required bool enabled,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller,
            initialValue: controller == null && fieldKey != null
                ? (_formData[fieldKey]?.toString() ?? '')
                : null,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              filled: !enabled,
              fillColor: enabled ? null : AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: fieldKey != null
                ? (value) {
                    setState(() {
                      _formData[fieldKey] = value;
                    });
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledDateField({
    required String label,
    required String fieldKey,
    String? hint,
    required bool enabled,
  }) {
    final dateStr = _formData[fieldKey]?.toString() ?? '';
    DateTime? selectedDate;
    if (dateStr.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(dateStr);
      } catch (_) {}
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: enabled
                ? () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _formData[fieldKey] = date.toIso8601String().split(
                          'T',
                        )[0];
                      });
                    }
                  }
                : null,
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                filled: !enabled,
                fillColor: enabled ? null : AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: const Icon(Icons.calendar_today, size: 20),
              ),
              child: Text(
                selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedDate)
                    : hint ?? 'Select date',
                style: TextStyle(
                  color: selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioGroupField({
    required String label,
    required String fieldKey,
    required List<String> options,
  }) {
    final currentValue = _formData[fieldKey]?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: options.map((option) {
                  final isSelected = currentValue == option;
                  return InkWell(
                    onTap: _isEditing
                        ? () {
                            setState(() {
                              _formData[fieldKey] = option;
                            });
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
