import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/work_entry_data.dart';
import '../../providers/repository_providers.dart';

/// DPR Tab - Timeline and Form view of all DPR milestones
class DPRTab extends ConsumerStatefulWidget {
  final int projectId;

  const DPRTab({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<DPRTab> createState() => _DPRTabState();
}

class _DPRTabState extends ConsumerState<DPRTab> {
  WorkEntryData? _workEntryData;
  bool _isLoading = true;
  bool _isTimelineView = true; // Toggle between timeline and form view

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final repository = ref.read(workEntryRepositoryProvider);
    // Load draft first, then fall back to final data
    final data = await repository.getWorkEntryOrDraftByProjectId(widget.projectId);

    setState(() {
      _workEntryData = data;
      _isLoading = false;
    });

    if (data != null) {
      print('[DPRTab] Loaded work entry - DPR fields: ${data.dprSection.length}, isDraft: ${data.isDraft}');
    } else {
      print('[DPRTab] No work entry data found for project ${widget.projectId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_workEntryData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No DPR data available',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header with view toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DPR Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isTimelineView ? 'Timeline View' : 'Detailed View',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // View Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _ViewToggleButton(
                            icon: Icons.timeline,
                            label: 'Timeline',
                            isSelected: _isTimelineView,
                            onTap: () => setState(() => _isTimelineView = true),
                          ),
                          _ViewToggleButton(
                            icon: Icons.view_list,
                            label: 'Details',
                            isSelected: !_isTimelineView,
                            onTap: () => setState(() => _isTimelineView = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 22),
                      tooltip: 'Refresh',
                      onPressed: _loadData,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isTimelineView
                ? _buildTimelineView()
                : _buildFormView(),
          ),
        ],
      ),
    );
  }

  // Timeline View - Gantt-style visualization
  Widget _buildTimelineView() {
    final dprData = _workEntryData!.dprSection;
    final milestones = _getMilestones(dprData);

    if (milestones.isEmpty) {
      return const Center(
        child: Text(
          'No milestone data available',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Summary Card
        _buildSummaryCard(milestones),

        const SizedBox(height: 24),

        // Milestone Timeline
        ...milestones.map((milestone) => _buildMilestoneBar(milestone)),
      ],
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> milestones) {
    final total = milestones.length;
    final completed = milestones.where((m) => m['status'] == 'completed').length;
    final inProgress = milestones.where((m) => m['status'] == 'in_progress').length;
    final pending = milestones.where((m) => m['status'] == 'pending').length;
    final percentage = total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.categoryNashik.withOpacity(0.1),
            AppColors.categoryNashik.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.categoryNashik.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.categoryNashik, size: 24),
              const SizedBox(width: 12),
              Text(
                'Progress Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Completion',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.categoryNashik,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completed / (total > 0 ? total : 1),
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Status Chips
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _StatusChip(
                icon: Icons.check_circle,
                label: 'Completed',
                count: completed,
                color: AppColors.success,
              ),
              _StatusChip(
                icon: Icons.pending,
                label: 'In Progress',
                count: inProgress,
                color: AppColors.warning,
              ),
              _StatusChip(
                icon: Icons.schedule,
                label: 'Pending',
                count: pending,
                color: AppColors.textSecondary,
              ),
              _StatusChip(
                icon: Icons.assignment,
                label: 'Total',
                count: total,
                color: AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneBar(Map<String, dynamic> milestone) {
    final status = milestone['status'] as String;
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final date = milestone['date'] as String?;
    final amount = milestone['amount'] as String?;
    final hasData = date != null || amount != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasData ? color.withOpacity(0.3) : AppColors.outline,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Milestone Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
              child: Row(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),

                  const SizedBox(width: 12),

                  // Milestone Name
                  Expanded(
                    child: Text(
                      milestone['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Milestone Data
            if (hasData)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (date != null) ...[
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                    if (date != null && amount != null) ...[
                      const SizedBox(width: 20),
                      Container(
                        width: 1,
                        height: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 20),
                    ],
                    if (amount != null) ...[
                      const Icon(Icons.currency_rupee, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Form View - Clean readonly detailed view
  Widget _buildFormView() {
    final dprData = _workEntryData!.dprSection;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildFormSection('Administrative Approval', [
          _buildFormField('AA Status', dprData['aa_status']),
          _buildFormField('AA Amount', dprData['aa_amount'], isAmount: true),
          _buildFormField('Broad Scope in AA', dprData['broad_scope_aa']),
          _buildResponsibilityFields('AA', dprData),
        ]),

        const SizedBox(height: 20),

        _buildFormSection('DPR Bid Documentation', [
          _buildFormField('Bid Doc Status', dprData['dpr_bid_doc_status']),
          _buildResponsibilityFields('DPR Bid Doc', dprData, prefix: 'dpr_bid_doc'),
        ]),

        const SizedBox(height: 20),

        _buildFormSection('Bidding Process', [
          _buildFormField('Invite DPR Status', dprData['invite_dpr_bid_status']),
          _buildFormField('Invite Date', dprData['invite_dpr_bid_date'], isDate: true),
          _buildFormField('Pre-bid Meeting Date', dprData['prebid_meeting_date'], isDate: true),
          _buildFormField('Participants', dprData['prebid_participants']),
          _buildFormField('CSD Status', dprData['csd_status']),
          _buildFormField('CSD Date', dprData['csd_date'], isDate: true),
          _buildFormField('Bid Submission Date', dprData['bid_submission_date'], isDate: true),
          _buildFormField('Bid Opening Date', dprData['bid_opening_date'], isDate: true),
          _buildFormField('Bids Submitted', dprData['bid_opening_count']),
        ]),

        const SizedBox(height: 20),

        _buildFormSection('Evaluation & Acceptance', [
          _buildFormField('Technical Evaluation Status', dprData['tech_eval_status']),
          _buildFormField('Qualified Bidders', dprData['tech_eval_qualified']),
          _buildFormField('Financial Opening Date', dprData['fin_opening_date'], isDate: true),
          _buildFormField('Successful Bidder', dprData['fin_opening_bid']),
          _buildFormField('Bid Amount (Rs. Lakhs)', dprData['fin_opening_amount'], isAmount: true),
          _buildFormField('Variance (%)', dprData['fin_opening_variance']),
          _buildFormField('Acceptance Status', dprData['bid_acceptance_status']),
          _buildFormField('Final Amount', dprData['bid_acceptance_amount'], isAmount: true),
        ]),

        const SizedBox(height: 20),

        _buildFormSection('Documents & Orders', [
          _buildFormField('LOA Status', dprData['loa_status']),
          _buildFormField('LOA Date', dprData['loa_date'], isDate: true),
          _buildFormField('PBG Status', dprData['pbg_status']),
          _buildFormField('PBG Amount', dprData['pbg_amount'], isAmount: true),
          _buildFormField('PBG Date', dprData['pbg_date'], isDate: true),
          _buildFormField('PBG Period (months)', dprData['pbg_period']),
          _buildFormField('Insurance Status', dprData['insurance_pii_status']),
          _buildFormField('Insurance Amount', dprData['insurance_pii_amount'], isAmount: true),
          _buildFormField('Work Order Status', dprData['work_order_status']),
          _buildFormField('Work Order Date', dprData['work_order_date'], isDate: true),
        ]),

        const SizedBox(height: 20),

        _buildFormSection('Technical Work', [
          _buildFormField('Inception Report', dprData['inception_report_status']),
          _buildFormField('Survey', dprData['survey_status']),
          _buildFormField('Geotechnical Investigation', dprData['geotech_status']),
          _buildFormField('Alignment Fixing', dprData['alignment_status']),
          _buildFormField('Plan & Profile', dprData['plan_profile_status']),
        ]),

        const SizedBox(height: 20),

        _buildFormSection('Design Work', [
          _buildFormField('Pavement Design', dprData['pavement_design_status']),
          _buildFormField('Structures Design', dprData['structures_design_status']),
          _buildFormField('Traffic Study', dprData['traffic_study_status']),
          _buildFormField('Junctions', dprData['junctions_status']),
          _buildFormField('Drainage Plan', dprData['drainage_status']),
          _buildFormField('Furniture Layout', dprData['furniture_layout_status']),
          _buildFormField('Miscellaneous Structures', dprData['misc_structures_status']),
        ]),

        const SizedBox(height: 20),

        _buildFormSection('DPR Finalization', [
          _buildFormField('BOQ Status', dprData['boq_status']),
          _buildFormField('BOQ Amount', dprData['boq_amount'], isAmount: true),
          _buildFormField('Draft DPR', dprData['draft_dpr_status']),
          _buildFormField('Environmental Clearance', dprData['env_clearance_applicable']),
          _buildFormField('Clearance Status', dprData['env_clearance_status']),
          _buildFormField('Land Acquisition', dprData['land_acquisition_applicable']),
          _buildFormField('LA Status', dprData['land_acquisition_status']),
          _buildFormField('Utility Shifting', dprData['utility_shifting_applicable']),
          _buildFormField('Shifting Status', dprData['utility_shifting_status']),
          _buildFormField('Quarry Chart', dprData['quarry_chart_status']),
          _buildFormField('Final DPR', dprData['final_dpr_status']),
          _buildFormField('DPR Approval', dprData['dpr_approval_status']),
        ]),

        const SizedBox(height: 20),

        _buildFormSection('Contract Documents', [
          _buildFormField('Contractor Bid Doc', dprData['contractor_bid_doc_status']),
          _buildFormField('RFP', dprData['rfp_status']),
          _buildFormField('GCC', dprData['gcc_status']),
          _buildFormField('Schedules', dprData['schedules_status']),
          _buildFormField('Drawings Volume', dprData['drawings_volume_status']),
        ]),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildFormSection(String title, List<Widget> fields) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open, size: 18, color: AppColors.categoryNashik),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: fields,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, dynamic value, {bool isDate = false, bool isAmount = false}) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    String displayValue = value.toString();
    if (isAmount && !displayValue.contains('Rs')) {
      displayValue = 'Rs. $displayValue';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  if (isDate) ...[
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                  ],
                  if (isAmount) ...[
                    const Icon(Icons.currency_rupee, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      displayValue,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilityFields(String sectionName, Map<String, dynamic> data, {String? prefix}) {
    final prefixKey = prefix ?? sectionName.toLowerCase().replaceAll(' ', '_');
    final person = data['${prefixKey}_person_responsible'];
    final post = data['${prefixKey}_post_held'];
    final pending = data['${prefixKey}_pending_with'];

    if (person == null && post == null && pending == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.info.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_outline, size: 14, color: AppColors.info),
                const SizedBox(width: 6),
                const Text(
                  'Responsibility Tracking',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            if (person != null) ...[
              const SizedBox(height: 8),
              _buildSmallField('Person Responsible', person),
            ],
            if (post != null) _buildSmallField('Post Held', post),
            if (pending != null) _buildSmallField('Pending With', pending),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Map<String, dynamic>> _getMilestones(Map<String, dynamic> dprData) {
    final milestones = <Map<String, dynamic>>[];

    void addMilestone(String name, String? status, {String? dateKey, String? amountKey}) {
      final date = dateKey != null ? dprData[dateKey]?.toString() : null;
      final amount = amountKey != null ? dprData[amountKey]?.toString() : null;

      String milestoneStatus = 'pending';
      if (status != null) {
        final statusLower = status.toLowerCase();
        if (statusLower.contains('done') ||
            statusLower.contains('completed') ||
            statusLower.contains('approved') ||
            statusLower.contains('accorded') ||
            statusLower.contains('issued') ||
            statusLower.contains('submitted') ||
            statusLower.contains('uploaded')) {
          milestoneStatus = 'completed';
        } else if (statusLower.contains('progress') || statusLower.contains('ready')) {
          milestoneStatus = 'in_progress';
        }
      } else if (date != null || amount != null) {
        milestoneStatus = 'completed';
      }

      milestones.add({
        'name': name,
        'status': milestoneStatus,
        'date': date,
        'amount': amount,
      });
    }

    // Add all DPR milestones
    addMilestone('Administrative Approval', dprData['aa_status'], amountKey: 'aa_amount');
    addMilestone('DPR Bid Doc', dprData['dpr_bid_doc_status']);
    addMilestone('Invite DPR Bid', dprData['invite_dpr_bid_status'], dateKey: 'invite_dpr_bid_date');
    addMilestone('Pre-bid Meeting', null, dateKey: 'prebid_meeting_date');
    addMilestone('CSD', dprData['csd_status'], dateKey: 'csd_date');
    addMilestone('Bid Submission', null, dateKey: 'bid_submission_date');
    addMilestone('Bid Opening', null, dateKey: 'bid_opening_date');
    addMilestone('Technical Evaluation', dprData['tech_eval_status']);
    addMilestone('Financial Opening', null, dateKey: 'fin_opening_date', amountKey: 'fin_opening_amount');
    addMilestone('Bid Acceptance', dprData['bid_acceptance_status'], amountKey: 'bid_acceptance_amount');
    addMilestone('LOA', dprData['loa_status'], dateKey: 'loa_date');
    addMilestone('PBG Submission', dprData['pbg_status'], dateKey: 'pbg_date', amountKey: 'pbg_amount');
    addMilestone('Insurance', dprData['insurance_pii_status'], dateKey: 'insurance_pii_date');
    addMilestone('Work Order', dprData['work_order_status'], dateKey: 'work_order_date');
    addMilestone('Inception Report', dprData['inception_report_status']);
    addMilestone('Survey', dprData['survey_status']);
    addMilestone('Geotechnical Investigation', dprData['geotech_status']);
    addMilestone('Alignment Fixing', dprData['alignment_status']);
    addMilestone('Plan & Profile', dprData['plan_profile_status']);
    addMilestone('Pavement Design', dprData['pavement_design_status']);
    addMilestone('Structures Design', dprData['structures_design_status']);
    addMilestone('Traffic Study', dprData['traffic_study_status']);
    addMilestone('Junctions', dprData['junctions_status']);
    addMilestone('Drainage Plan', dprData['drainage_status']);
    addMilestone('Furniture Layout', dprData['furniture_layout_status']);
    addMilestone('Misc Structures', dprData['misc_structures_status']);
    addMilestone('BOQ', dprData['boq_status'], amountKey: 'boq_amount');
    addMilestone('Draft DPR', dprData['draft_dpr_status']);
    addMilestone('Environmental Clearance', dprData['env_clearance_status']);
    addMilestone('Land Acquisition', dprData['land_acquisition_status']);
    addMilestone('Utility Shifting', dprData['utility_shifting_status']);
    addMilestone('Quarry Chart', dprData['quarry_chart_status']);
    addMilestone('Final DPR', dprData['final_dpr_status']);
    addMilestone('DPR Approval', dprData['dpr_approval_status']);
    addMilestone('Contractor Bid Doc', dprData['contractor_bid_doc_status']);
    addMilestone('RFP', dprData['rfp_status']);
    addMilestone('GCC', dprData['gcc_status']);
    addMilestone('Schedules', dprData['schedules_status']);
    addMilestone('Drawings Volume', dprData['drawings_volume_status']);

    return milestones;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'pending':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.pending;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Done';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      default:
        return 'Unknown';
    }
  }
}

// View Toggle Button Widget
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Status Chip Widget
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
