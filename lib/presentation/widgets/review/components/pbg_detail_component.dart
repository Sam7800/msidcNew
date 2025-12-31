import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// PBG (Performance Bank Guarantee) Detail Component
///
/// Two states: Not Submitted or Submitted with details
class PBGDetailComponent extends BaseReviewComponent {
  const PBGDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['pbg_status']?.toString().toLowerCase() ?? '';
    final isSubmitted = status.contains('submit') && !status.contains('not');

    if (isSubmitted) {
      return _buildSubmittedView();
    } else {
      return _buildNotSubmittedView();
    }
  }

  Widget _buildNotSubmittedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Not Submitted'),
        const SizedBox(height: 12),

        if (ComponentStatusUtils.hasValue(data['pbg_expected_date'])) ...[
          buildFieldRow('pbg_expected_date', label: 'Expected Submission Date'),

          if (ComponentStatusUtils.hasValue(data['pbg_remarks'])) ...[
            buildDivider(),
            buildFieldRow('pbg_remarks', label: 'Remarks'),
          ],
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
                    'PBG not yet submitted',
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

  Widget _buildSubmittedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('PBG Details'),
        buildFieldRow('pbg_submitted_date', label: 'Submitted Date'),
        buildFieldRow('pbg_number', label: 'PBG No.'),
        buildFieldRow('pbg_amount', label: 'Amount'),
        buildFieldRow('pbg_bank_name', label: 'Bank Name'),

        buildDivider(),

        buildSectionHeader('Validity'),
        buildFieldRow('pbg_issue_date', label: 'Issue Date'),
        buildFieldRow('pbg_valid_until', label: 'Valid Until'),

        if (ComponentStatusUtils.hasValue(data['pbg_remarks'])) ...[
          buildDivider(),
          buildFieldRow('pbg_remarks', label: 'Remarks'),
        ],
      ],
    );
  }
}
