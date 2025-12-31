import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Utility Shifting Detail Component
///
/// Two main states: Not Applicable or Applicable (with sub-states)
class UtilityShiftingDetailComponent extends BaseReviewComponent {
  const UtilityShiftingDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['utility_status']?.toString().toLowerCase() ?? '';
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
              'Utility Shifting Not Applicable',
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
        buildSectionHeader('Utility Shifting Status'),
        buildFieldRow('proposal_submitted_date', label: 'Proposal Submitted: Date', placeholder: 'Not submitted'),
        buildFieldRow('status_description', label: 'Status', placeholder: 'Pending'),
      ],
    );
  }
}
