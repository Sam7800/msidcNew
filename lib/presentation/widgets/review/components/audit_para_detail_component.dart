import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Audit Para Detail Component
///
/// Two states: Not Applicable or Applicable with multiple paras
class AuditParaDetailComponent extends BaseReviewComponent {
  const AuditParaDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Use standardized field name 'status' (automatically mapped from 'audit_para_status')
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
              'No Audit Paras',
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
        buildSectionHeader('Audit Para Summary'),
        // Use standardized field names (automatically mapped from pms_audit_para_*)
        buildFieldRow('points_count', label: '# of Draft Paras', placeholder: '0'),
        buildFieldRow('reply_given', label: 'Reply Given', placeholder: '0'),
        buildFieldRow('reply_pending', label: 'Reply Pending', placeholder: '0'),
        buildFieldRow('dp_count', label: 'DP Count', placeholder: '0'),
        buildFieldRow('dropped_count', label: 'Dropped Count', placeholder: '0'),

        buildDivider(),

        // Details of paras table (3x4)
        buildSectionHeader('Details of Paras'),
        const SizedBox(height: 8),
        _buildDetailsTable(),

        buildDivider(),

        // Replies Submitted table (3x4)
        buildSectionHeader('Replies Submitted: # and Dates'),
        const SizedBox(height: 8),
        _buildRepliesTable(),

        buildDivider(),

        // Paras Closed table (3x4)
        buildSectionHeader('Paras Closed'),
        const SizedBox(height: 8),
        _buildClosedTable(),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('person_responsible', label: 'Responsible Person for Replies', placeholder: 'Not assigned'),
        buildFieldRow('post_held', label: 'Post Held', placeholder: 'Not specified'),
        buildFieldRow('pending_with', label: 'Pending With', placeholder: 'Not specified'),
      ],
    );
  }

  Widget _buildDetailsTable() {
    final items = data['details_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No para details available',
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
            DataColumn(label: Text('Para Description', style: _headerStyle)),
            DataColumn(label: Text('Amount', style: _headerStyle)),
            DataColumn(label: Text('Status', style: _headerStyle)),
          ],
          rows: _buildDetailsRows(items),
        ),
      ),
    );
  }

  Widget _buildRepliesTable() {
    final items = data['replies_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No replies submitted yet',
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
            DataColumn(label: Text('Para No.', style: _headerStyle)),
            DataColumn(label: Text('Reply Submitted', style: _headerStyle)),
            DataColumn(label: Text('Date', style: _headerStyle)),
          ],
          rows: _buildRepliesRows(items),
        ),
      ),
    );
  }

  Widget _buildClosedTable() {
    final items = data['closed_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No paras closed yet',
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
            DataColumn(label: Text('Para No.', style: _headerStyle)),
            DataColumn(label: Text('Closed Status', style: _headerStyle)),
            DataColumn(label: Text('Closure Date', style: _headerStyle)),
          ],
          rows: _buildClosedRows(items),
        ),
      ),
    );
  }

  TextStyle get _headerStyle => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  List<DataRow> _buildDetailsRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}', style: _cellStyle)),
          DataCell(Text(item['description']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatCurrency(item['amount']), style: _cellStyle)),
          DataCell(Text(item['status']?.toString() ?? '', style: _cellStyle)),
        ],
      );
    }).toList();
  }

  List<DataRow> _buildRepliesRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}', style: _cellStyle)),
          DataCell(Text(item['para_no']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(item['reply_status']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatDate(item['date']), style: _cellStyle)),
        ],
      );
    }).toList();
  }

  List<DataRow> _buildClosedRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}', style: _cellStyle)),
          DataCell(Text(item['para_no']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(item['closed_status']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatDate(item['closure_date']), style: _cellStyle)),
        ],
      );
    }).toList();
  }

  TextStyle get _cellStyle => TextStyle(
        fontSize: 12,
        color: AppColors.textPrimary,
      );
}
