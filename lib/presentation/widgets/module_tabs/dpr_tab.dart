import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/dpr_data.dart';
import '../../../core/database/repositories/dpr_repository.dart';
import '../../providers/repository_providers.dart';

/// DPR Tab - 19 milestone date fields
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
  DPRData? _dprData;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for all 19 date fields
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, DateTime?> _dates = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final repository = ref.read(dprRepositoryProvider);
    final data = await repository.getDPRByProjectId(widget.projectId);

    setState(() {
      _dprData = data;
      _isLoading = false;

      // Initialize dates from loaded data
      if (data != null) {
        _dates['bidDocDPR'] = data.bidDocDpr;
        _dates['invite'] = data.invite;
        _dates['prebid'] = data.prebid;
        _dates['csd'] = data.csd;
        _dates['bidSubmit'] = data.bidSubmit;
        _dates['workOrder'] = data.workOrder;
        _dates['inceptionReport'] = data.inceptionReport;
        _dates['survey'] = data.survey;
        _dates['alignment'] = data.alignmentLayout;
        _dates['draftDPR'] = data.draftDpr;
        _dates['drawings'] = data.drawings;
        _dates['boq'] = data.boq;
        _dates['envClearance'] = data.envClearance;
        _dates['cashFlow'] = data.cashFlow;
        _dates['laProposal'] = data.laProposal;
        _dates['utilityShifting'] = data.utilityShifting;
        _dates['finalDPR'] = data.finalDpr;
        _dates['bidDocWork'] = data.bidDocWork;
      }
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(dprRepositoryProvider);

    final updatedData = DPRData(
      id: _dprData?.id,
      projectId: widget.projectId,
      bidDocDpr: _dates['bidDocDPR'],
      invite: _dates['invite'],
      prebid: _dates['prebid'],
      csd: _dates['csd'],
      bidSubmit: _dates['bidSubmit'],
      workOrder: _dates['workOrder'],
      inceptionReport: _dates['inceptionReport'],
      survey: _dates['survey'],
      alignmentLayout: _dates['alignment'],
      draftDpr: _dates['draftDPR'],
      drawings: _dates['drawings'],
      boq: _dates['boq'],
      envClearance: _dates['envClearance'],
      cashFlow: _dates['cashFlow'],
      laProposal: _dates['laProposal'],
      utilityShifting: _dates['utilityShifting'],
      finalDpr: _dates['finalDPR'],
      bidDocWork: _dates['bidDocWork'],
      broadScope: _dprData?.broadScope,
    );

    if (_dprData?.id == null) {
      await repository.insertDPR(updatedData);
    } else {
      await repository.updateDPR(updatedData);
    }

    setState(() => _isEditing = false);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DPR data saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DPR Milestones',
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
                        label: const Text('Save'),
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

            const SizedBox(height: 24),

            // Milestone Fields (19 dates)
            _buildDateField('Bid Doc DPR', 'bidDocDPR'),
            _buildDateField('Invite', 'invite'),
            _buildDateField('Pre-bid Meeting', 'prebid'),
            _buildDateField('CSD', 'csd'),
            _buildDateField('Bid Submission', 'bidSubmit'),
            _buildDateField('Work Order', 'workOrder'),
            _buildDateField('Inception Report', 'inceptionReport'),
            _buildDateField('Survey', 'survey'),
            _buildDateField('Alignment/Layout', 'alignment'),
            _buildDateField('Draft DPR', 'draftDPR'),
            _buildDateField('Drawings', 'drawings'),
            _buildDateField('BOQ', 'boq'),
            _buildDateField('Environmental Clearance', 'envClearance'),
            _buildDateField('Cash Flow', 'cashFlow'),
            _buildDateField('LA Proposal', 'laProposal'),
            _buildDateField('Utility Shifting', 'utilityShifting'),
            _buildDateField('Final DPR', 'finalDPR'),
            _buildDateField('Bid Doc Work', 'bidDocWork'),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, String fieldKey) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: _isEditing
                ? InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dates[fieldKey] ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _dates[fieldKey] = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: label,
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(
                        _dates[fieldKey] != null
                            ? dateFormat.format(_dates[fieldKey]!)
                            : 'Select date',
                        style: TextStyle(
                          color: _dates[fieldKey] != null
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.outline,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _dates[fieldKey] != null
                          ? dateFormat.format(_dates[fieldKey]!)
                          : '-',
                      style: TextStyle(
                        color: _dates[fieldKey] != null
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
