import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Revised AA Detail Component
///
/// Two states: Not Required or Necessary with detailed status
class RevAADetailComponent extends BaseReviewComponent {
  const RevAADetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['rev_aa_status']?.toString().toLowerCase() ?? '';
    final isRequired = status.contains('necessary') || status.contains('required');

    if (!isRequired) {
      return _buildNotRequiredView();
    } else {
      return _buildRequiredView();
    }
  }

  Widget _buildNotRequiredView() {
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
              'Revised AA Not Required',
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

  Widget _buildRequiredView() {
    final subStatus = data['rev_aa_sub_status']?.toString().toLowerCase() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Necessary'),
        const SizedBox(height: 12),

        if (subStatus.contains('await') || subStatus.contains('pend')) ...[
          buildFieldRow('rev_aa_original_amount', label: 'Original AA Amount'),
          buildFieldRow('rev_aa_proposed_amount', label: 'Proposed Revised Amount'),
          buildFieldRow('rev_aa_increase_amount', label: 'Increase Amount'),
          buildFieldRow('rev_aa_submission_date', label: 'Submitted Date'),

          if (ComponentStatusUtils.hasValue(data['rev_aa_reasons'])) ...[
            buildDivider(),
            buildSectionHeader('Reasons for Revision'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                data['rev_aa_reasons'].toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],

          buildDivider(),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Awaiting approval',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (subStatus.contains('approv') || subStatus.contains('accord')) ...[
          buildSectionHeader('Approval Details'),
          buildFieldRow('rev_aa_approved_date', label: 'Approved Date'),
          buildFieldRow('rev_aa_original_amount', label: 'Original AA Amount'),
          buildFieldRow('rev_aa_approved_amount', label: 'Revised Approved Amount'),
          buildFieldRow('rev_aa_increase_amount', label: 'Increase Amount'),
          buildFieldRow('rev_aa_number', label: 'Revised AA No.'),

          if (ComponentStatusUtils.hasValue(data['rev_aa_reasons'])) ...[
            buildDivider(),
            buildSectionHeader('Reasons for Revision'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                data['rev_aa_reasons'].toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],

        if (ComponentStatusUtils.hasValue(data['rev_aa_remarks'])) ...[
          buildDivider(),
          buildFieldRow('rev_aa_remarks', label: 'Remarks'),
        ],
      ],
    );
  }
}
