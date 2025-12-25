import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/monitoring_data.dart';
import '../../providers/repository_providers.dart';

/// Monitoring Tab - 19 financial and metric fields
class MonitoringTab extends ConsumerStatefulWidget {
  final int projectId;

  const MonitoringTab({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<MonitoringTab> createState() => _MonitoringTabState();
}

class _MonitoringTabState extends ConsumerState<MonitoringTab> {
  MonitoringData? _monitoringData;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _agmntAmountController = TextEditingController();
  final _tenderPeriodController = TextEditingController();
  final _ldController = TextEditingController();
  final _cosController = TextEditingController();
  final _eotController = TextEditingController();
  final _cumExpController = TextEditingController();
  final _finalBillController = TextEditingController();
  final _auditParaController = TextEditingController();
  final _repliesController = TextEditingController();
  final _laqController = TextEditingController();
  final _techAuditController = TextEditingController();
  final _revAAController = TextEditingController();

  // Dates
  DateTime? _appointedDate;
  DateTime? _firstMilestoneDate;
  DateTime? _secondMilestoneDate;
  DateTime? _thirdMilestoneDate;
  DateTime? _fourthMilestoneDate;
  DateTime? _fifthMilestoneDate;

  // Milestone amounts
  final _firstAmountController = TextEditingController();
  final _secondAmountController = TextEditingController();
  final _thirdAmountController = TextEditingController();
  final _fourthAmountController = TextEditingController();
  final _fifthAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final repository = ref.read(monitoringRepositoryProvider);
    final data = await repository.getMonitoringByProjectId(widget.projectId);

    setState(() {
      _monitoringData = data;
      _isLoading = false;

      if (data != null) {
        _agmntAmountController.text = data.agmntAmount?.toString() ?? '';
        _appointedDate = data.appointedDate;
        _tenderPeriodController.text = data.tenderPeriod?.toString() ?? '';

        _firstMilestoneDate = data.firstMilestoneDate;
        _firstAmountController.text = data.firstMilestoneAmount?.toString() ?? '';

        _secondMilestoneDate = data.secondMilestoneDate;
        _secondAmountController.text = data.secondMilestoneAmount?.toString() ?? '';

        _thirdMilestoneDate = data.thirdMilestoneDate;
        _thirdAmountController.text = data.thirdMilestoneAmount?.toString() ?? '';

        _fourthMilestoneDate = data.fourthMilestoneDate;
        _fourthAmountController.text = data.fourthMilestoneAmount?.toString() ?? '';

        _fifthMilestoneDate = data.fifthMilestoneDate;
        _fifthAmountController.text = data.fifthMilestoneAmount?.toString() ?? '';

        _ldController.text = data.ld?.toString() ?? '';
        _cosController.text = data.cos?.toString() ?? '';
        _eotController.text = data.eot?.toString() ?? '';
        _cumExpController.text = data.cumExp?.toString() ?? '';
        _finalBillController.text = data.finalBill?.toString() ?? '';
        _auditParaController.text = data.auditPara ?? '';
        _repliesController.text = data.replies ?? '';
        _laqController.text = data.laqLcq ?? '';
        _techAuditController.text = data.techAudit ?? '';
        _revAAController.text = data.revAa ?? '';
      }
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(monitoringRepositoryProvider);

    final updatedData = MonitoringData(
      id: _monitoringData?.id,
      projectId: widget.projectId,
      agmntAmount: double.tryParse(_agmntAmountController.text),
      appointedDate: _appointedDate,
      tenderPeriod: int.tryParse(_tenderPeriodController.text),
      firstMilestoneDate: _firstMilestoneDate,
      firstMilestoneAmount: double.tryParse(_firstAmountController.text),
      secondMilestoneDate: _secondMilestoneDate,
      secondMilestoneAmount: double.tryParse(_secondAmountController.text),
      thirdMilestoneDate: _thirdMilestoneDate,
      thirdMilestoneAmount: double.tryParse(_thirdAmountController.text),
      fourthMilestoneDate: _fourthMilestoneDate,
      fourthMilestoneAmount: double.tryParse(_fourthAmountController.text),
      fifthMilestoneDate: _fifthMilestoneDate,
      fifthMilestoneAmount: double.tryParse(_fifthAmountController.text),
      ld: double.tryParse(_ldController.text),
      cos: double.tryParse(_cosController.text),
      eot: int.tryParse(_eotController.text),
      cumExp: double.tryParse(_cumExpController.text),
      finalBill: double.tryParse(_finalBillController.text),
      auditPara: _auditParaController.text.isEmpty ? null : _auditParaController.text,
      replies: _repliesController.text.isEmpty ? null : _repliesController.text,
      laqLcq: _laqController.text.isEmpty ? null : _laqController.text,
      techAudit: _techAuditController.text.isEmpty ? null : _techAuditController.text,
      revAa: _revAAController.text.isEmpty ? null : _revAAController.text,
    );

    if (_monitoringData?.id == null) {
      await repository.insertMonitoring(updatedData);
    } else {
      await repository.updateMonitoring(updatedData);
    }

    setState(() => _isEditing = false);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Monitoring data saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _agmntAmountController.dispose();
    _tenderPeriodController.dispose();
    _ldController.dispose();
    _cosController.dispose();
    _eotController.dispose();
    _cumExpController.dispose();
    _finalBillController.dispose();
    _auditParaController.dispose();
    _repliesController.dispose();
    _laqController.dispose();
    _techAuditController.dispose();
    _revAAController.dispose();
    _firstAmountController.dispose();
    _secondAmountController.dispose();
    _thirdAmountController.dispose();
    _fourthAmountController.dispose();
    _fifthAmountController.dispose();
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
                  'Project Monitoring',
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

            // Financial Fields
            _buildSectionHeader('Agreement Details'),
            _buildNumericField('Agreement Amount (Rs. Cr)', _agmntAmountController),
            _buildDateField('Appointed Date', _appointedDate, (date) => _appointedDate = date),
            _buildNumericField('Tender Period (Months)', _tenderPeriodController, isInteger: true),

            const SizedBox(height: 24),
            _buildSectionHeader('Milestones'),
            _buildMilestoneRow('1st Milestone', _firstMilestoneDate, (date) => _firstMilestoneDate = date, _firstAmountController),
            _buildMilestoneRow('2nd Milestone', _secondMilestoneDate, (date) => _secondMilestoneDate = date, _secondAmountController),
            _buildMilestoneRow('3rd Milestone', _thirdMilestoneDate, (date) => _thirdMilestoneDate = date, _thirdAmountController),
            _buildMilestoneRow('4th Milestone', _fourthMilestoneDate, (date) => _fourthMilestoneDate = date, _fourthAmountController),
            _buildMilestoneRow('5th Milestone', _fifthMilestoneDate, (date) => _fifthMilestoneDate = date, _fifthAmountController),

            const SizedBox(height: 24),
            _buildSectionHeader('Penalties & Extensions'),
            _buildNumericField('Liquidated Damages (Rs)', _ldController),
            _buildNumericField('Change of Scope (Rs. Cr)', _cosController),
            _buildNumericField('Extension of Time (Months)', _eotController, isInteger: true),

            const SizedBox(height: 24),
            _buildSectionHeader('Expenditure'),
            _buildNumericField('Cumulative Expenditure (Rs. Cr)', _cumExpController),
            _buildNumericField('Final Bill (Rs. Cr)', _finalBillController),

            const SizedBox(height: 24),
            _buildSectionHeader('Audit & Compliance'),
            _buildTextField('Audit Para', _auditParaController),
            _buildTextField('Replies', _repliesController),
            _buildTextField('LAQ/LCQ', _laqController),
            _buildTextField('Technical Audit', _techAuditController),
            _buildTextField('Revised AA', _revAAController),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
      ),
    );
  }

  Widget _buildNumericField(String label, TextEditingController controller, {bool isInteger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
        inputFormatters: [
          if (isInteger) FilteringTextInputFormatter.digitsOnly
          else FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !_isEditing,
          fillColor: _isEditing ? null : AppColors.surfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !_isEditing,
          fillColor: _isEditing ? null : AppColors.surfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime?) onDateChanged) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _isEditing
          ? InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => onDateChanged(picked));
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  date != null ? dateFormat.format(date) : 'Select date',
                  style: TextStyle(
                    color: date != null ? AppColors.textPrimary : AppColors.textDisabled,
                  ),
                ),
              ),
            )
          : TextFormField(
              initialValue: date != null ? dateFormat.format(date) : '-',
              enabled: false,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
            ),
    );
  }

  Widget _buildMilestoneRow(String label, DateTime? date, Function(DateTime?) onDateChanged, TextEditingController amountController) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
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
            flex: 2,
            child: _isEditing
                ? InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => onDateChanged(picked));
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today, size: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        date != null ? dateFormat.format(date) : 'Select date',
                        style: TextStyle(
                          fontSize: 13,
                          color: date != null ? AppColors.textPrimary : AppColors.textDisabled,
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Text(
                      date != null ? dateFormat.format(date) : '-',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: amountController,
              enabled: _isEditing,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount (Rs. Cr)',
                border: const OutlineInputBorder(),
                filled: !_isEditing,
                fillColor: _isEditing ? null : AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
