import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// LD (Liquidated Damages) Detail Component
///
/// Two states: Not Applicable or Applicable with detailed breakdown
class LDDetailComponent extends BaseReviewComponent {
  const LDDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Use standardized field name 'status' (automatically mapped from 'ld_status')
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
              'Liquidated Damages Not Applicable',
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
        buildSectionHeader('Status: Applicable'),
        const SizedBox(height: 12),

        // Use standardized field names (automatically mapped from pms_ld_final_*)
        buildFieldRow('rate', label: 'Amount Imposed / Per Week', placeholder: 'Not specified'),
        buildFieldRow('recovery', label: 'Amount Recovered', placeholder: '₹ 0'),
        buildFieldRow('amount_deposited', label: 'Amount Deposited in Account', placeholder: '₹ 0'), // NEW
        buildFieldRow('amount_released', label: 'Amount Released After Achievement of Progress', placeholder: '₹ 0'), // NEW

        buildDivider(),

        buildSectionHeader('Final Amount Recovered from Contractor'),
        buildFieldRow('ms1_recovery', label: 'Milestone I', placeholder: '₹ 0'),
        buildFieldRow('ms2_recovery', label: 'Milestone II', placeholder: '₹ 0'),
        buildFieldRow('ms3_recovery', label: 'Milestone III', placeholder: '₹ 0'),
        buildFieldRow('ms4_recovery', label: 'Milestone IV', placeholder: '₹ 0'),
        buildFieldRow('ms5_recovery', label: 'Milestone V (Final)', placeholder: '₹ 0'),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('person_responsible', label: 'Person Responsible', placeholder: 'Not assigned'),
        buildFieldRow('post_held', label: 'Post Held', placeholder: 'Not specified'),
        buildFieldRow('pending_with', label: 'Pending With', placeholder: 'Not specified'),
      ],
    );
  }
}
