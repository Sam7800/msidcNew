import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// EOT (Extension of Time) Detail Component
///
/// Two states: Not Applicable or Applicable with 12 sub-fields
class EOTDetailComponent extends BaseReviewComponent {
  const EOTDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Use standardized field name 'status' (automatically mapped from 'eot_status')
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
              'Extension of Time Not Applicable',
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
        buildSectionHeader('EOT Proposal'),
        buildFieldRow('proposal_submitted_date', label: 'Proposal Submitted Date', placeholder: 'Not submitted'),
        buildFieldRow('period', label: 'EOT Approved Period (Months)', placeholder: 'Not approved'),

        buildDivider(),

        buildSectionHeader('Escalation Terms'),
        buildFieldRow('with_escalation', label: 'With Escalation', placeholder: 'Not specified'),
        buildFieldRow('without_escalation', label: 'Without Escalation', placeholder: 'Not specified'),
        buildFieldRow('by_freezing_indices', label: 'By Freezing Indices', placeholder: 'Not specified'),

        buildDivider(),

        buildSectionHeader('Liquidated Damages'),
        buildFieldRow('without_ld', label: 'Without LD', placeholder: 'Not specified'),
        buildFieldRow('with_ld', label: 'With LD', placeholder: 'Not specified'),

        buildDivider(),

        buildSectionHeader('Compensation'),
        buildFieldRow('compensation_payable', label: 'Compensation Payable', placeholder: 'Not specified'),
        buildFieldRow('compensation_claimed_amount', label: 'Amount of Compensation Claimed', placeholder: '₹ 0'),
        buildFieldRow('compensation_admitted_amount', label: 'Compensation Admitted Amount', placeholder: '₹ 0'),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('person_responsible', label: 'Person Responsible', placeholder: 'Not assigned'),
        buildFieldRow('post_held', label: 'Post Held', placeholder: 'Not specified'),
        buildFieldRow('pending_with', label: 'Pending With', placeholder: 'Not specified'),
      ],
    );
  }
}
