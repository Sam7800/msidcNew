import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Bid Submission Detail Component
///
/// Shows date, number of bidders, and EMD verification
class BidSubmissionDetailComponent extends BaseReviewComponent {
  const BidSubmissionDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['bid_submission_status']?.toString().toLowerCase() ?? '';
    final isCompleted = status.contains('complet') || status.contains('done');

    if (!isCompleted) {
      return _buildNotCompletedView();
    } else {
      return _buildCompletedView();
    }
  }

  Widget _buildNotCompletedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Not Completed'),
        const SizedBox(height: 12),

        if (ComponentStatusUtils.hasValue(data['bid_submission_scheduled_date'])) ...[
          buildFieldRow('bid_submission_scheduled_date', label: 'Scheduled Date'),

          if (ComponentStatusUtils.hasValue(data['bid_submission_remarks'])) ...[
            buildDivider(),
            buildFieldRow('bid_submission_remarks', label: 'Remarks'),
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
                    'Bid submission date not yet scheduled',
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

  Widget _buildCompletedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Bid Submission Details'),
        buildFieldRow('bid_submission_date', label: 'Date'),
        buildFieldRow('bid_submission_number_of_bidders', label: 'Number of Bidders'),

        buildDivider(),

        buildSectionHeader('EMD Verification'),
        buildFieldRow('bid_submission_emd_verified', label: 'EMD Verified'),
        buildFieldRow('bid_submission_emd_total_amount', label: 'Total EMD Amount'),

        if (ComponentStatusUtils.hasValue(data['bid_submission_remarks'])) ...[
          buildDivider(),
          buildFieldRow('bid_submission_remarks', label: 'Remarks'),
        ],
      ],
    );
  }
}
