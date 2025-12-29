import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// TS (Technical Sanction) Detail Component
///
/// Two states: Awaited or Accorded (with 8x3 table)
class TSDetailComponent extends BaseReviewComponent {
  const TSDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['ts_status']?.toString().toLowerCase() ?? '';
    final isAccorded = status.contains('accord') || status.contains('issued');

    if (isAccorded) {
      return _buildAccordedView();
    } else {
      return _buildAwaitedView();
    }
  }

  Widget _buildAwaitedView() {
    final subStatus = data['ts_sub_status']?.toString().toLowerCase() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Awaited'),
        const SizedBox(height: 12),

        if (subStatus.contains('not') || subStatus.contains('start')) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TS preparation not yet started',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (subStatus.contains('progress')) ...[
          buildFieldRow('likely_submission_date', label: 'Likely Date of Submission'),
          buildFieldRow('ts_status_remarks', label: 'Status'),
        ] else ...[
          buildFieldRow('ts_status_remarks', label: 'Status'),
        ],
      ],
    );
  }

  Widget _buildAccordedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Accorded'),
        const SizedBox(height: 12),

        buildFieldRow('ts_sanctioned_cost', label: 'Amount'),
        buildFieldRow('ts_number', label: 'TS No.'),
        buildFieldRow('ts_accorded_date', label: 'Date'),

        buildDivider(),

        buildSectionHeader('Detailed Scope'),
        const SizedBox(height: 12),

        _buildDetailedScopeTable(),
      ],
    );
  }

  Widget _buildDetailedScopeTable() {
    // Get table data from ts_items field
    final items = data['ts_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No detailed scope data available',
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
            DataColumn(
              label: Text(
                'Sr. No.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Item Description',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Sanctioned Amount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Remarks',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          rows: _buildTableRows(items),
        ),
      ),
    );
  }

  List<DataRow> _buildTableRows(dynamic items) {
    if (items is! List) return [];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return DataRow(
        cells: [
          DataCell(
            Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          DataCell(
            Text(
              item['description']?.toString() ?? '',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          DataCell(
            Text(
              ComponentStatusUtils.formatCurrency(item['amount']),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          DataCell(
            Text(
              item['remarks']?.toString() ?? '-',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
