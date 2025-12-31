import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Bid Acceptance Detail Component
///
/// Five states: Not Started, Under Review, Approved, Rejected, Pending Approval
class BidAcceptanceDetailComponent extends BaseReviewComponent {
  const BidAcceptanceDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['bid_acceptance_status']?.toString().toLowerCase() ?? 'not started';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        buildStatusChip(data['bid_acceptance_status']?.toString() ?? 'Not Started'),
        const SizedBox(height: 16),

        // Content based on status
        if (status.contains('not') || status.contains('start')) ...[
          _buildNotStartedView(),
        ] else if (status.contains('review')) ...[
          _buildUnderReviewView(),
        ] else if (status.contains('pend')) ...[
          _buildPendingApprovalView(),
        ] else if (status.contains('approv')) ...[
          _buildApprovedView(),
        ] else if (status.contains('reject')) ...[
          _buildRejectedView(),
        ],
      ],
    );
  }

  Widget _buildNotStartedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.pending_actions,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Bid acceptance process not yet started',
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

  Widget _buildUnderReviewView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldRow('bid_acceptance_l1_bidder', label: 'L1 Bidder'),
        buildFieldRow('bid_acceptance_l1_amount', label: 'L1 Amount'),

        if (ComponentStatusUtils.hasValue(data['bid_acceptance_remarks']))
          buildFieldRow('bid_acceptance_remarks', label: 'Remarks'),

        buildDivider(),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.rate_review, size: 16, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Under review',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingApprovalView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldRow('bid_acceptance_l1_bidder', label: 'L1 Bidder'),
        buildFieldRow('bid_acceptance_l1_amount', label: 'L1 Amount'),
        buildFieldRow('bid_acceptance_submitted_date', label: 'Submitted for Approval'),

        if (ComponentStatusUtils.hasValue(data['bid_acceptance_remarks']))
          buildFieldRow('bid_acceptance_remarks', label: 'Remarks'),

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
                  'Pending approval',
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
      ],
    );
  }

  Widget _buildApprovedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Approval Details'),
        buildFieldRow('bid_acceptance_approved_date', label: 'Approved Date'),
        buildFieldRow('bid_acceptance_l1_bidder', label: 'L1 Bidder'),
        buildFieldRow('bid_acceptance_l1_amount', label: 'L1 Amount'),

        if (ComponentStatusUtils.hasValue(data['bid_acceptance_remarks'])) ...[
          buildDivider(),
          buildFieldRow('bid_acceptance_remarks', label: 'Remarks'),
        ],
      ],
    );
  }

  Widget _buildRejectedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Rejection Details'),
        buildFieldRow('bid_acceptance_rejected_date', label: 'Rejected Date'),

        if (ComponentStatusUtils.hasValue(data['bid_acceptance_rejection_reasons'])) ...[
          buildDivider(),
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
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['bid_acceptance_rejection_reasons'].toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
