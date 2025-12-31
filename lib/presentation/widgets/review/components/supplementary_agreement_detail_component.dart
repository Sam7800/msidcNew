import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Supplementary Agreement Detail Component
///
/// Two states: Not Applicable or Applicable with agreement details
class SupplementaryAgreementDetailComponent extends BaseReviewComponent {
  const SupplementaryAgreementDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['suppl_agreement_status']?.toString().toLowerCase() ?? '';
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
              'Supplementary Agreement Not Applicable',
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
        buildSectionHeader('Supplementary Agreement Details'),
        buildFieldRow('date', label: 'Date', placeholder: 'Not set'),
        buildFieldRow('number', label: 'Agreement No.', placeholder: 'Not assigned'),
        buildFieldRow('amount', label: 'Amount (Rs. Lakhs)', placeholder: '₹ 0'),
        buildFieldRow('period', label: 'Period (Months)', placeholder: 'Not specified'), // NEW

        buildDivider(),

        if (ComponentStatusUtils.hasValue(data['suppl_agreement_scope'])) ...[
          buildDivider(),
          buildSectionHeader('Additional Scope'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              data['suppl_agreement_scope'].toString(),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],

        if (ComponentStatusUtils.hasValue(data['suppl_agreement_remarks'])) ...[
          buildDivider(),
          buildFieldRow('suppl_agreement_remarks', label: 'Remarks'),
        ],
      ],
    );
  }
}
