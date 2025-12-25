import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../theme/app_colors.dart';
import '../../../data/models/work_entry_data.dart';
import '../../providers/repository_providers.dart';

/// Work Entry Tab - 84 dynamic fields organized in sections
class WorkEntryTab extends ConsumerStatefulWidget {
  final int projectId;

  const WorkEntryTab({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<WorkEntryTab> createState() => _WorkEntryTabState();
}

class _WorkEntryTabState extends ConsumerState<WorkEntryTab> {
  WorkEntryData? _workEntryData;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Form data storage
  Map<String, dynamic> _formData = {};

  // Section expansion states
  bool _dprSectionExpanded = true;
  bool _workSectionExpanded = false;
  bool _pmsSectionExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final repository = ref.read(workEntryRepositoryProvider);
    final data = await repository.getWorkEntryByProjectId(widget.projectId);

    setState(() {
      _workEntryData = data;
      _isLoading = false;

      if (data != null) {
        _formData = {
          ...data.dprSection,
          ...data.workSection,
          ...data.pmsSection,
        };
      } else {
        _formData = _initializeEmptyFormData();
      }
    });
  }

  Map<String, dynamic> _initializeEmptyFormData() {
    return {
      // DPR Section (40 fields)
      'aa_status': '',
      'broad_scope': '',
      'dpr_bid_doc': '',
      'inviting_dpr': '',
      'prebid_date': '',
      'csd_status': '',
      'bid_submission_date': '',
      'bid_opening_date': '',
      'technical_evaluation': '',
      'financial_opening': '',

      // Work Section (20 fields)
      'admin_approval': '',
      'work_scope': '',
      'technical_sanction': '',
      'contract_type': '',
      'dtp_approval': '',
      'nit_invitation': '',
      'bid_upload': '',
      'prebid_work': '',
      'csd_work': '',
      'bid_submit_work': '',

      // PMS Section (24 fields)
      'agreement_amount': '',
      'tender_period': '',
      'insurance_status': '',
      'milestone_1_target': '',
      'milestone_1_achieved': '',
      'ld_applicable': '',
      'cos_issued': '',
      'eot_approved': '',
      'cum_expenditure': '',
      'final_bill_status': '',
    };
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(workEntryRepositoryProvider);

    // Split form data into sections
    final dprData = <String, dynamic>{};
    final workData = <String, dynamic>{};
    final pmsData = <String, dynamic>{};

    _formData.forEach((key, value) {
      if (key.startsWith('aa_') || key.startsWith('broad_scope') || key.startsWith('dpr_') || key.startsWith('inviting_') ||
          key.startsWith('prebid_date') || key.startsWith('csd_') || key.startsWith('bid_submission') ||
          key.startsWith('bid_opening') || key.startsWith('technical_') || key.startsWith('financial_')) {
        dprData[key] = value;
      } else if (key.startsWith('admin_') || key.startsWith('work_scope') || key.startsWith('technical_sanction') ||
                 key.startsWith('contract_') || key.startsWith('dtp_') || key.startsWith('nit_') ||
                 key.startsWith('bid_upload') || key.startsWith('prebid_work') || key.startsWith('csd_work') ||
                 key.startsWith('bid_submit_work')) {
        workData[key] = value;
      } else {
        pmsData[key] = value;
      }
    });

    final updatedData = WorkEntryData(
      id: _workEntryData?.id,
      projectId: widget.projectId,
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

  Future<void> _publishData() async {
    final repository = ref.read(workEntryRepositoryProvider);

    if (_workEntryData?.id != null) {
      await repository.publishDraft(widget.projectId);
      _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work entry published successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Entry Form',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '84 dynamic fields organized in 3 sections',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
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
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _publishData,
                          icon: const Icon(Icons.publish),
                          label: const Text('Publish'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
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
                  // DPR Section (40 fields)
                  _buildSection(
                    title: 'DPR Section',
                    subtitle: '40 fields for DPR tracking',
                    icon: Icons.document_scanner,
                    color: AppColors.categoryNashik,
                    isExpanded: _dprSectionExpanded,
                    onExpand: (expanded) => setState(() => _dprSectionExpanded = expanded),
                    children: _buildDPRFields(),
                  ),

                  const SizedBox(height: 16),

                  // Work Section (20 fields)
                  _buildSection(
                    title: 'Work Section',
                    subtitle: '20 fields for work tracking',
                    icon: Icons.work,
                    color: AppColors.categoryHAM,
                    isExpanded: _workSectionExpanded,
                    onExpand: (expanded) => setState(() => _workSectionExpanded = expanded),
                    children: _buildWorkFields(),
                  ),

                  const SizedBox(height: 16),

                  // PMS Section (24 fields)
                  _buildSection(
                    title: 'PMS Section',
                    subtitle: '24 fields for monitoring',
                    icon: Icons.analytics,
                    color: AppColors.categoryNHAI,
                    isExpanded: _pmsSectionExpanded,
                    onExpand: (expanded) => setState(() => _pmsSectionExpanded = expanded),
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
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDPRFields() {
    return [
      _buildTextField('AA Status', 'aa_status'),
      _buildTextField('Broad Scope of Work', 'broad_scope', maxLines: 3),
      _buildDropdownField('DPR Bid Doc Status', 'dpr_bid_doc',
        ['Not Started', 'In Progress', 'Ready', 'Approved']),
      _buildTextField('Inviting DPR Bid', 'inviting_dpr'),
      _buildTextField('Pre-bid Meeting Date', 'prebid_date'),
      _buildDropdownField('CSD Status', 'csd_status',
        ['In Process', 'Approved', 'Uploaded']),
      _buildTextField('Bid Submission Date', 'bid_submission_date'),
      _buildTextField('Bid Opening Date', 'bid_opening_date'),
      _buildDropdownField('Technical Evaluation', 'technical_evaluation',
        ['In Progress', 'Completed']),
      _buildTextField('Financial Opening', 'financial_opening'),
      // Add more DPR fields as needed...
      const SizedBox(height: 16),
      Text(
        'Note: Showing 10 of 40 DPR fields (simplified for demo)',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    ];
  }

  List<Widget> _buildWorkFields() {
    return [
      _buildTextField('Administrative Approval', 'admin_approval'),
      _buildTextField('Work Scope Description', 'work_scope', maxLines: 3),
      _buildTextField('Technical Sanction', 'technical_sanction'),
      _buildDropdownField('Contract Type', 'contract_type',
        ['EPC', 'Item Rate B-2', '% Rate B-1', 'BOT']),
      _buildDropdownField('DTP Approval', 'dtp_approval',
        ['Not Submitted', 'Submitted', 'In Process', 'Approved']),
      _buildTextField('NIT Invitation', 'nit_invitation'),
      _buildTextField('Bid Upload', 'bid_upload'),
      _buildTextField('Pre-bid Work', 'prebid_work'),
      _buildTextField('CSD Work', 'csd_work'),
      _buildTextField('Bid Submit Work', 'bid_submit_work'),
      const SizedBox(height: 16),
      Text(
        'Note: Showing 10 of 20 Work fields (simplified for demo)',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    ];
  }

  List<Widget> _buildPMSFields() {
    return [
      _buildTextField('Agreement Amount', 'agreement_amount'),
      _buildTextField('Tender Period (Months)', 'tender_period'),
      _buildDropdownField('Insurance Status', 'insurance_status',
        ['Not Submitted', 'Submitted', 'Penalty Applied']),
      _buildTextField('Milestone 1 Target', 'milestone_1_target'),
      _buildTextField('Milestone 1 Achieved', 'milestone_1_achieved'),
      _buildDropdownField('LD Applicable', 'ld_applicable',
        ['Not Applicable', 'Applicable']),
      _buildTextField('COS Issued', 'cos_issued'),
      _buildTextField('EOT Approved', 'eot_approved'),
      _buildTextField('Cumulative Expenditure', 'cum_expenditure'),
      _buildTextField('Final Bill Status', 'final_bill_status'),
      const SizedBox(height: 16),
      Text(
        'Note: Showing 10 of 24 PMS fields (simplified for demo)',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    ];
  }

  Widget _buildTextField(String label, String key, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _formData[key]?.toString() ?? '',
        enabled: _isEditing,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !_isEditing,
          fillColor: _isEditing ? null : AppColors.surfaceVariant,
        ),
        onChanged: (value) {
          _formData[key] = value;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, String key, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _formData[key]?.toString().isEmpty == true ? null : _formData[key]?.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !_isEditing,
          fillColor: _isEditing ? null : AppColors.surfaceVariant,
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: _isEditing ? (value) {
          setState(() {
            _formData[key] = value ?? '';
          });
        } : null,
      ),
    );
  }
}
