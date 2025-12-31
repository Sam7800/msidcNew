import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// NIT (Notice Inviting Tender) Detail Component
///
/// Two states: Not Issued or Issued with detailed tables
class NITDetailComponent extends BaseReviewComponent {
  const NITDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['nit_status']?.toString().toLowerCase() ?? '';
    final isIssued = status.contains('issued') && !status.contains('not');

    if (isIssued) {
      return _buildIssuedView();
    } else {
      return _buildNotIssuedView();
    }
  }

  Widget _buildNotIssuedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Not Issued'),
        const SizedBox(height: 12),

        if (ComponentStatusUtils.hasValue(data['nit_not_issued_reasons'])) ...[
          Text(
            'Reasons:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['nit_not_issued_reasons'].toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.pending,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NIT not yet issued',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIssuedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('NIT Details'),
        buildFieldRow('nit_issue_date', label: 'Date'),
        buildFieldRow('nit_amount', label: 'Amount'),

        buildDivider(),

        buildSectionHeader('Broad Items Breakdown'),
        const SizedBox(height: 12),
        _buildBroadItemsTable(),

        buildDivider(),

        buildSectionHeader('Additional Details'),
        buildFieldRow('nit_prebid_date', label: 'Date of Pre-Bid'),
        buildFieldRow('nit_submission_date', label: 'Date of Submission'),

        const SizedBox(height: 12),
        Text(
          'EMD Amounts:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildEMDTable(),
      ],
    );
  }

  Widget _buildBroadItemsTable() {
    final items = data['nit_broad_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No broad items data available',
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
                'Amount (₹)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          rows: _buildBroadItemsRows(items),
        ),
      ),
    );
  }

  Widget _buildEMDTable() {
    final items = data['nit_emd_items'];

    if (items == null || (items is List && items.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No EMD data available',
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
                'Category',
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
          rows: _buildEMDRows(items),
        ),
      ),
    );
  }

  List<DataRow> _buildBroadItemsRows(dynamic items) {
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

  List<DataRow> _buildEMDRows(dynamic items) {
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
              item['category']?.toString() ?? '',
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
