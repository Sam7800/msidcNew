import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/work_data.dart';
import '../../providers/repository_providers.dart';

/// Work Tab - 15 milestone date fields
class WorkTab extends ConsumerStatefulWidget {
  final int projectId;

  const WorkTab({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<WorkTab> createState() => _WorkTabState();
}

class _WorkTabState extends ConsumerState<WorkTab> {
  WorkData? _workData;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Date storage for 15 fields
  final Map<String, DateTime?> _dates = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final repository = ref.read(workRepositoryProvider);
    final data = await repository.getWorkByProjectId(widget.projectId);

    setState(() {
      _workData = data;
      _isLoading = false;

      if (data != null) {
        _dates['aa'] = data.aa;
        _dates['dpr'] = data.dpr;
        _dates['ts'] = data.ts;
        _dates['bidDoc'] = data.bidDoc;
        _dates['bidInvite'] = data.bidInvite;
        _dates['prebid'] = data.prebid;
        _dates['csd'] = data.csd;
        _dates['bidSubmit'] = data.bidSubmit;
        _dates['finBid'] = data.finBid;
        _dates['loi'] = data.loi;
        _dates['loa'] = data.loa;
        _dates['pbg'] = data.pbg;
        _dates['agreement'] = data.agreement;
        _dates['workOrder'] = data.workOrder;
      }
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(workRepositoryProvider);

    final updatedData = WorkData(
      id: _workData?.id,
      projectId: widget.projectId,
      aa: _dates['aa'],
      dpr: _dates['dpr'],
      ts: _dates['ts'],
      bidDoc: _dates['bidDoc'],
      bidInvite: _dates['bidInvite'],
      prebid: _dates['prebid'],
      csd: _dates['csd'],
      bidSubmit: _dates['bidSubmit'],
      finBid: _dates['finBid'],
      loi: _dates['loi'],
      loa: _dates['loa'],
      pbg: _dates['pbg'],
      agreement: _dates['agreement'],
      workOrder: _dates['workOrder'],
    );

    if (_workData?.id == null) {
      await repository.insertWork(updatedData);
    } else {
      await repository.updateWork(updatedData);
    }

    setState(() => _isEditing = false);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work data saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Work Milestones',
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

            // Milestone Fields (15 dates)
            _buildDateField('Administrative Approval (AA)', 'aa'),
            _buildDateField('DPR', 'dpr'),
            _buildDateField('Technical Sanction (TS)', 'ts'),
            _buildDateField('Bid Document', 'bidDoc'),
            _buildDateField('Bid Invitation', 'bidInvite'),
            _buildDateField('Pre-bid Meeting', 'prebid'),
            _buildDateField('CSD', 'csd'),
            _buildDateField('Bid Submission', 'bidSubmit'),
            _buildDateField('Financial Bid Opening', 'finBid'),
            _buildDateField('Letter of Intent (LOI)', 'loi'),
            _buildDateField('Letter of Acceptance (LOA)', 'loa'),
            _buildDateField('PBG Submission', 'pbg'),
            _buildDateField('Agreement Signed', 'agreement'),
            _buildDateField('Work Order', 'workOrder'),

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
