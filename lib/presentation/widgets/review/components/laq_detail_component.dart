import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// LAQ (Local Audit Query) Detail Component
///
/// Two states: Not Applicable or Applicable with query details
class LAQDetailComponent extends BaseReviewComponent {
  const LAQDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Use standardized field name 'status' (automatically mapped from 'laq_status')
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
              'No Local Audit Queries',
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
        buildSectionHeader('# of LAQs / LCQs / Lakshvwdhi / Others'),
        // Type breakdown
        buildFieldRow('laq_count', label: 'LAQ Count', placeholder: '0'),
        buildFieldRow('lcq_count', label: 'LCQ Count', placeholder: '0'),
        buildFieldRow('lakshvwdhi_count', label: 'Lakshvwdhi Count', placeholder: '0'),
        buildFieldRow('laq_others_count', label: 'Others Count', placeholder: '0'),

        buildDivider(),

        // Details of Questions table (3x4)
        buildSectionHeader('Details of Questions'),
        const SizedBox(height: 8),
        _buildQuestionsTable(),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('person_responsible', label: 'Responsible Person for Replies', placeholder: 'Not assigned'),

        buildDivider(),

        // Replies Submitted table (3x4)
        buildSectionHeader('Replies Submitted: # and Dates'),
        const SizedBox(height: 8),
        _buildRepliesTable(),

        buildDivider(),

        // Promises given table (3x4)
        buildSectionHeader('Promises given by Hon Minister/s'),
        const SizedBox(height: 8),
        _buildPromisesTable(),

        buildDivider(),

        // Promises Compliance table (3x5)
        buildSectionHeader('Promises Compliance'),
        const SizedBox(height: 8),
        _buildComplianceTable(),
      ],
    );
  }

  Widget _buildQuestionsTable() {
    final items = data['questions_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No questions data available',
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
            DataColumn(label: Text('Question Type', style: _headerStyle)),
            DataColumn(label: Text('Description', style: _headerStyle)),
            DataColumn(label: Text('Date', style: _headerStyle)),
          ],
          rows: _buildQuestionsRows(items),
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
            DataColumn(label: Text('Question No.', style: _headerStyle)),
            DataColumn(label: Text('Reply Status', style: _headerStyle)),
            DataColumn(label: Text('Date', style: _headerStyle)),
          ],
          rows: _buildRepliesRows(items),
        ),
      ),
    );
  }

  Widget _buildPromisesTable() {
    final items = data['promises_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No promises given',
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
            DataColumn(label: Text('Minister', style: _headerStyle)),
            DataColumn(label: Text('Promise', style: _headerStyle)),
            DataColumn(label: Text('Date', style: _headerStyle)),
          ],
          rows: _buildPromisesRows(items),
        ),
      ),
    );
  }

  Widget _buildComplianceTable() {
    final items = data['compliance_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No compliance data available',
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
            DataColumn(label: Text('Promise No.', style: _headerStyle)),
            DataColumn(label: Text('Compliance Status', style: _headerStyle)),
            DataColumn(label: Text('Action Taken', style: _headerStyle)),
            DataColumn(label: Text('Date', style: _headerStyle)),
          ],
          rows: _buildComplianceRows(items),
        ),
      ),
    );
  }

  TextStyle get _headerStyle => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  List<DataRow> _buildQuestionsRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}', style: _cellStyle)),
          DataCell(Text(item['type']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(item['description']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatDate(item['date']), style: _cellStyle)),
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
          DataCell(Text(item['question_no']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(item['reply_status']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatDate(item['date']), style: _cellStyle)),
        ],
      );
    }).toList();
  }

  List<DataRow> _buildPromisesRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}', style: _cellStyle)),
          DataCell(Text(item['minister']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(item['promise']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatDate(item['date']), style: _cellStyle)),
        ],
      );
    }).toList();
  }

  List<DataRow> _buildComplianceRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}', style: _cellStyle)),
          DataCell(Text(item['promise_no']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(item['compliance_status']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(item['action_taken']?.toString() ?? '', style: _cellStyle)),
          DataCell(Text(ComponentStatusUtils.formatDate(item['date']), style: _cellStyle)),
        ],
      );
    }).toList();
  }

  TextStyle get _cellStyle => TextStyle(
        fontSize: 12,
        color: AppColors.textPrimary,
      );
}
