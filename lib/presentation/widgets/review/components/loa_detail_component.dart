import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// LOA (Letter of Acceptance) Detail Component
///
/// Two states: Not Issued or Issued with details
class LOADetailComponent extends BaseReviewComponent {
  const LOADetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['loa_status']?.toString().toLowerCase() ?? '';
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

        if (ComponentStatusUtils.hasValue(data['loa_not_issued_reasons'])) ...[
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
                    data['loa_not_issued_reasons'].toString(),
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
                    'LOA not yet issued',
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
        buildSectionHeader('LOA Details'),
        buildFieldRow('loa_issue_date', label: 'Date Issued'),
        buildFieldRow('loa_number', label: 'LOA No.'),
        buildFieldRow('loa_contractor_name', label: 'Contractor Name'),
        buildFieldRow('loa_amount', label: 'Amount'),

        if (ComponentStatusUtils.hasValue(data['loa_validity_period'])) ...[
          buildDivider(),
          buildFieldRow('loa_validity_period', label: 'Validity Period'),
          buildFieldRow('loa_valid_until', label: 'Valid Until'),
        ],

        if (ComponentStatusUtils.hasValue(data['loa_remarks'])) ...[
          buildDivider(),
          buildFieldRow('loa_remarks', label: 'Remarks'),
        ],
      ],
    );
  }
}
