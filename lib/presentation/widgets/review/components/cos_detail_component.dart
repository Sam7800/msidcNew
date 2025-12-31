import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// COS (Change of Scope) Detail Component
///
/// Two states: Not Applicable or Applicable with sub-states and tables
class COSDetailComponent extends BaseReviewComponent {
  const COSDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Use standardized field names (automatically mapped from cos_*)
    final status = data['status']?.toString().toLowerCase() ?? '';
    final isApplicable = status.contains('applicable') && !status.contains('not');

    if (!isApplicable) {
      return _buildNotApplicableView();
    } else {
      return _buildApplicableView();
    }
  }

  Widget _buildNotApplicableView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.success.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Change of Scope Not Applicable',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicableView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Change of Scope Details'),
        const SizedBox(height: 12),

        // Use standardized field names (automatically mapped from pms_cos_*)
        buildFieldRow('date', label: 'Proposal Submitted Date', placeholder: 'Not submitted'),
        buildFieldRow('amount', label: 'Amount', placeholder: '₹ 0'),

        buildDivider(),

        buildSectionHeader('Scope'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            ComponentStatusUtils.hasValue(data['scope'])
                ? data['scope'].toString()
                : 'No scope description provided',
            style: TextStyle(
              fontSize: 12,
              color: ComponentStatusUtils.hasValue(data['scope'])
                  ? AppColors.textPrimary
                  : AppColors.textSecondary.withOpacity(0.6),
              fontStyle: ComponentStatusUtils.hasValue(data['scope'])
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
        ),

        buildDivider(),

        // Proposal under Consideration Table (3x4)
        buildSectionHeader('Proposal under Consideration'),
        const SizedBox(height: 8),
        _buildProposedChangesTable(),

        buildDivider(),

        // Proposal Approved Table (3x7)
        buildSectionHeader('Proposal Approved'),
        const SizedBox(height: 8),
        _buildApprovedScopeTable(),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('person_responsible', label: 'Person Responsible', placeholder: 'Not assigned'),
        buildFieldRow('post_held', label: 'Post Held', placeholder: 'Not specified'),
        buildFieldRow('pending_with', label: 'Pending With', placeholder: 'Not specified'),
      ],
    );
  }

  Widget _buildProposedChangesTable() {
    // Removed - not used with actual work entry field structure
    final items = data['proposed_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No proposed changes data available',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            config.primaryColor.withOpacity(0.1),
          ),
          columns: [
            DataColumn(label: Text('Sr. No.', style: _headerStyle)),
            DataColumn(label: Text('Item Description', style: _headerStyle)),
            DataColumn(label: Text('Proposed Amount', style: _headerStyle)),
          ],
          rows: _buildProposedRows(items),
        ),
      ),
    );
  }

  Widget _buildApprovedScopeTable() {
    final items = data['approved_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No approved scope data available',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            config.primaryColor.withOpacity(0.1),
          ),
          columns: [
            DataColumn(label: Text('Sr. No.', style: _headerStyle)),
            DataColumn(label: Text('Item Description', style: _headerStyle)),
            DataColumn(label: Text('Original Amount', style: _headerStyle)),
            DataColumn(label: Text('Revised Amount', style: _headerStyle)),
            DataColumn(label: Text('Change', style: _headerStyle)),
            DataColumn(label: Text('Approval Date', style: _headerStyle)),
            DataColumn(label: Text('Remarks', style: _headerStyle)),
          ],
          rows: _buildApprovedRows(items),
        ),
      ),
    );
  }

  TextStyle get _headerStyle => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  List<DataRow> _buildProposedRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}', style: _cellStyle)),
          DataCell(Text(item['description']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatCurrency(item['amount']), style: _cellStyle)),
        ],
      );
    }).toList();
  }

  List<DataRow> _buildApprovedRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}', style: _cellStyle)),
          DataCell(Text(item['description']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatCurrency(item['original_amount']), style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatCurrency(item['revised_amount']), style: _cellStyle)),
          DataCell(Text(item['change']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatDate(item['approval_date']), style: _cellStyle)),
          DataCell(Text(item['remarks']?.toString() ?? '-', style: _cellStyle)),
        ],
      );
    }).toList();
  }

  TextStyle get _cellStyle => TextStyle(
        fontSize: 12,
        color: AppColors.textPrimary,
      );
}
