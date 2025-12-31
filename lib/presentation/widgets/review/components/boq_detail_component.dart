import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// BOQ (Bill of Quantities) Detail Component
///
/// Shows completed status with item-wise breakdown table (5x3)
class BOQDetailComponent extends BaseReviewComponent {
  const BOQDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['status']?.toString().toLowerCase() ?? '';
    final isInProgress = status.contains('progress') || status.contains('ongoing');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use standardized field names (automatically mapped from boq_status, boq_amount)
        buildSectionHeader('Status'),
        buildStatusChip(data['status']?.toString() ?? 'Pending'),
        const SizedBox(height: 12),

        // Show Likely Date of Completion for In Progress state
        if (isInProgress) ...[
          buildFieldRow('likely_completion', label: 'Likely Date of Completion', placeholder: 'Not set'),
          buildDivider(),
        ],

        buildFieldRow('amount', label: 'Total Amount'),

        buildDivider(),

        buildSectionHeader('Broad Item-wise Break-up of Amounts'),
        const SizedBox(height: 12),
        _buildBOQTable(),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('person_responsible', label: 'Person Responsible'),
        buildFieldRow('post_held', label: 'Post Held'),
        buildFieldRow('pending_with', label: 'Pending With'),
      ],
    );
  }

  Widget _buildBOQTable() {
    // Get table data from boq_items field
    final items = data['boq_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No BOQ items available',
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
                'Broad Item Description',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount (₹)',
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
        ],
      );
    }).toList();
  }
}
