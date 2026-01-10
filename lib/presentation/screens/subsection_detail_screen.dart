import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../data/models/project.dart';
import '../../data/models/work_entry_data.dart';
import '../../data/models/subsection_field_mapping.dart';
import '../providers/repository_providers.dart';

/// Subsection Detail Screen
///
/// Shows detailed view of a single critical subsection with all form fields
/// Allows editing and toggling critical status
class SubsectionDetailScreen extends ConsumerStatefulWidget {
  final Project project;
  final String category; // DPR, Work, or PMS
  final String subsectionName;

  const SubsectionDetailScreen({
    super.key,
    required this.project,
    required this.category,
    required this.subsectionName,
  });

  @override
  ConsumerState<SubsectionDetailScreen> createState() =>
      _SubsectionDetailScreenState();
}

class _SubsectionDetailScreenState
    extends ConsumerState<SubsectionDetailScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isCritical = true; // Assume critical since we navigated from critical screen
  WorkEntryData? _workEntry;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load work entry data for this project
      final workEntryRepo = ref.read(workEntryRepositoryProvider);
      final workEntry =
          await workEntryRepo.getWorkEntryOrDraftByProjectId(widget.project.id!);

      // Check if subsection is critical
      final criticalRepo = ref.read(criticalSubsectionsRepositoryProvider);
      final isCritical = await criticalRepo.isCritical(
        widget.project.id!,
        widget.category,
        widget.subsectionName,
      );

      // Get fields for this subsection
      final fields = SubsectionFieldMapping.getFieldsForSubsection(
        widget.subsectionName,
        widget.category,
      );

      // Initialize controllers with current values
      if (workEntry != null) {
        final sectionData = _getSectionData(workEntry, widget.category);
        for (var fieldKey in fields) {
          final value = sectionData[fieldKey]?.toString() ?? '';
          _controllers[fieldKey] = TextEditingController(text: value);
        }
      }

      setState(() {
        _workEntry = workEntry;
        _isCritical = isCritical;
        _isLoading = false;
      });
    } catch (e) {
      print('[SubsectionDetailScreen] Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _getSectionData(WorkEntryData workEntry, String category) {
    switch (category) {
      case 'DPR':
        return workEntry.dprSection;
      case 'Work':
        return workEntry.workSection;
      case 'PMS':
        return workEntry.pmsSection;
      default:
        return {};
    }
  }

  Future<void> _toggleCritical() async {
    final criticalRepo = ref.read(criticalSubsectionsRepositoryProvider);

    try {
      final newStatus = await criticalRepo.toggleCritical(
        widget.project.id!,
        widget.category,
        widget.subsectionName,
      );

      setState(() => _isCritical = newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'Marked as critical' : 'Removed from critical',
            ),
            backgroundColor: newStatus ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('[SubsectionDetailScreen] Error toggling critical: $e');
    }
  }

  Future<void> _saveData() async {
    if (_workEntry == null) return;

    try {
      // Update section data with controller values
      final sectionData =
          Map<String, dynamic>.from(_getSectionData(_workEntry!, widget.category));
      for (var entry in _controllers.entries) {
        sectionData[entry.key] =
            entry.value.text.isEmpty ? null : entry.value.text;
      }

      // Create updated work entry
      WorkEntryData updatedEntry;
      switch (widget.category) {
        case 'DPR':
          updatedEntry = _workEntry!.copyWith(
            dprSection: sectionData,
            updatedAt: DateTime.now(),
          );
          break;
        case 'Work':
          updatedEntry = _workEntry!.copyWith(
            workSection: sectionData,
            updatedAt: DateTime.now(),
          );
          break;
        case 'PMS':
          updatedEntry = _workEntry!.copyWith(
            pmsSection: sectionData,
            updatedAt: DateTime.now(),
          );
          break;
        default:
          return;
      }

      // Save to database
      final workEntryRepo = ref.read(workEntryRepositoryProvider);
      await workEntryRepo.updateWorkEntry(updatedEntry);

      setState(() {
        _workEntry = updatedEntry;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('[SubsectionDetailScreen] Error saving: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Category color
    Color categoryColor;
    switch (widget.category) {
      case 'DPR':
        categoryColor = const Color(0xFF3B82F6); // Blue
        break;
      case 'Work':
        categoryColor = const Color(0xFF10B981); // Green
        break;
      case 'PMS':
        categoryColor = const Color(0xFF8B5CF6); // Purple
        break;
      default:
        categoryColor = AppColors.textSecondary;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, _isCritical),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subsectionName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.project.name,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Critical marker button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleCritical,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _isCritical ? Icons.error : Icons.error_outline,
                  size: 24,
                  color: _isCritical
                      ? const Color(0xFFEF4444) // Red for critical
                      : AppColors.textSecondary, // Grey for not critical
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Edit/Save button
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save, color: AppColors.primary),
              onPressed: _saveData,
              tooltip: 'Save',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.textPrimary),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Build fields based on category and subsection
                  ..._buildSubsectionFields(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildSubsectionFields() {
    final fields = SubsectionFieldMapping.getFieldsForSubsection(
      widget.subsectionName,
      widget.category,
    );

    if (fields.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No fields configured for ${widget.subsectionName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return fields
        .map((fieldKey) => _buildDynamicField(fieldKey))
        .toList();
  }

  Widget _buildDynamicField(String fieldKey) {
    // Determine field type and render accordingly
    if (_isRadioField(fieldKey)) {
      return _buildRadioField(fieldKey);
    } else if (_isDateField(fieldKey)) {
      return _buildDateField(fieldKey);
    } else {
      return _buildTextFieldTile(fieldKey);
    }
  }

  bool _isRadioField(String fieldKey) {
    // Status fields are typically radio buttons
    return fieldKey.endsWith('_status') ||
        fieldKey.endsWith('_applicable') ||
        fieldKey == 'aa_status' ||
        fieldKey == 'loa_status' ||
        fieldKey == 'pbg_status' ||
        fieldKey == 'work_admin_approval_status' ||
        fieldKey == 'work_tech_sanction_status' ||
        fieldKey == 'loi_status_work' ||
        fieldKey == 'loa_status_work' ||
        fieldKey == 'pbg_status_work' ||
        fieldKey == 'ld_1_applicable' ||
        fieldKey == 'ld_2_applicable' ||
        fieldKey == 'ld_3_applicable' ||
        fieldKey == 'ld_4_applicable' ||
        fieldKey == 'ld_final_applicable' ||
        fieldKey == 'eot_applicable' ||
        fieldKey == 'audit_para_applicable';
  }

  bool _isDateField(String fieldKey) {
    return fieldKey.contains('_date') || fieldKey.contains('_due');
  }

  Widget _buildRadioField(String fieldKey) {
    final label = _getFieldLabel(fieldKey);
    final currentValue = _controllers[fieldKey]?.text ?? '';

    // Get options based on field key
    List<String> options = _getRadioOptions(fieldKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = currentValue == option;
              return GestureDetector(
                onTap: _isEditing
                    ? () {
                        setState(() {
                          _controllers[fieldKey]?.text = option;
                        });
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Center(
                                child: Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String fieldKey) {
    final label = _getFieldLabel(fieldKey);
    final controller = _controllers[fieldKey];

    if (controller == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _isEditing
                ? () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        controller.text =
                            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                      });
                    }
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isEditing
                    ? AppColors.background
                    : AppColors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: _isEditing ? AppColors.primary : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? 'Select date' : controller.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: controller.text.isEmpty
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
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

  Widget _buildTextFieldTile(String fieldKey) {
    final label = _getFieldLabel(fieldKey);
    final controller = _controllers[fieldKey];

    if (controller == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: _isEditing,
            maxLines: _isMultilineField(fieldKey) ? 3 : 1,
            keyboardType: _getKeyboardType(fieldKey),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              filled: true,
              fillColor: _isEditing
                  ? AppColors.background
                  : AppColors.surfaceVariant.withOpacity(0.3),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getRadioOptions(String fieldKey) {
    // Return appropriate options based on field key
    if (fieldKey == 'aa_status' || fieldKey.contains('admin_approval_status')) {
      return ['Awaited', 'Accorded'];
    } else if (fieldKey.contains('_applicable')) {
      return ['Yes', 'No'];
    } else if (fieldKey.contains('dpr_bid_doc_status') ||
        fieldKey.contains('contractor_bid_doc_status')) {
      return ['Not Started', 'In progress', 'Ready', 'Approved'];
    } else if (fieldKey.contains('invite_dpr_bid_status')) {
      return ['Not invited yet', 'Invited'];
    } else if (fieldKey.contains('tech_eval_status')) {
      return ['Not Started', 'In progress', 'Completed'];
    } else if (fieldKey.contains('loa_status') || fieldKey.contains('loi_status')) {
      return ['Not Issued', 'Issued'];
    } else if (fieldKey.contains('pbg_status') || fieldKey.contains('insurance')) {
      return ['Not Submitted', 'Submitted'];
    } else if (fieldKey.contains('work_order_status')) {
      return ['Not Issued', 'Issued'];
    } else if (fieldKey.contains('_status')) {
      // Generic status field
      return ['Not Started', 'In progress', 'Completed'];
    }
    return ['Yes', 'No']; // Default
  }

  String _getFieldLabel(String fieldKey) {
    // Convert field key to readable label
    return fieldKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  bool _isMultilineField(String fieldKey) {
    return fieldKey.contains('scope') ||
        fieldKey.contains('description') ||
        fieldKey.contains('remarks');
  }

  TextInputType _getKeyboardType(String fieldKey) {
    if (fieldKey.contains('amount') ||
        fieldKey.contains('count') ||
        fieldKey.contains('period') ||
        fieldKey.contains('percentage') ||
        fieldKey.contains('rate') ||
        fieldKey.contains('recovery') ||
        fieldKey.contains('variance') ||
        fieldKey.contains('qualified') ||
        fieldKey.contains('bid')) {
      return TextInputType.number;
    }
    if (fieldKey.contains('date')) {
      return TextInputType.datetime;
    }
    return TextInputType.text;
  }
}
