import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// CSD (Common Set of Deviations) Detail Component
///
/// Four states:
/// 1. Queries reply in progress
/// 2. Replies submitted for approval
/// 3. Replies approved
/// 4. CSD uploaded - Date
class CSDDetailComponent extends BaseReviewComponent {
  const CSDDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Use standardized field name 'status' (automatically mapped from 'csd_status')
    final status = data['status']?.toString().toLowerCase() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        buildStatusChip(data['status']?.toString() ?? 'Not Started'),
        const SizedBox(height: 16),

        // Content based on status progression
        if (status.contains('queries') || status.contains('reply') && status.contains('progress')) ...[
          _buildQueriesInProgressView(),
        ] else if (status.contains('submit') && !status.contains('approv')) ...[
          _buildRepliesSubmittedView(),
        ] else if (status.contains('approv') || status.contains('approved')) ...[
          _buildRepliesApprovedView(),
        ] else if (status.contains('upload') || status.contains('completed')) ...[
          _buildCSDUploadedView(),
        ] else ...[
          _buildNotStartedView(),
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
              'CSD not yet started',
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

  Widget _buildQueriesInProgressView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.warning.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Queries reply in progress',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesSubmittedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.send_outlined,
              size: 48,
              color: AppColors.info.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Replies submitted for approval',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesApprovedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.success.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Replies approved',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCSDUploadedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('CSD Uploaded'),
        buildFieldRow('date', label: 'Date', placeholder: 'Not set'),
      ],
    );
  }
}
