import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Drawings Detail Component
///
/// Four states: Not Started, In Progress, Submitted, Completed
class DrawingsDetailComponent extends BaseReviewComponent {
  const DrawingsDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Use standardized field name 'status' (automatically mapped from 'drawings_volume_status')
    final status = data['status']?.toString().toLowerCase() ?? 'not started';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        buildStatusChip(data['status']?.toString() ?? 'Not Started'),
        const SizedBox(height: 16),

        // Content based on status
        if (status.contains('not') || status.contains('start')) ...[
          _buildNotStartedView(),
        ] else if (status.contains('progress')) ...[
          _buildInProgressView(),
        ] else if (status.contains('submit')) ...[
          _buildSubmittedView(),
        ] else if (status.contains('complet')) ...[
          _buildCompletedView(),
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
              'Drawings preparation not yet started',
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

  Widget _buildInProgressView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldRow('drawings_expected_completion', label: 'Expected Completion Date'),
        if (ComponentStatusUtils.hasValue(data['drawings_remarks']))
          buildFieldRow('drawings_remarks', label: 'Remarks'),
      ],
    );
  }

  Widget _buildSubmittedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldRow('drawings_submitted_date', label: 'Submitted Date'),

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
              Icon(Icons.schedule, size: 16, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Awaiting completion',
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

  Widget _buildCompletedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Completion Details'),
        buildFieldRow('drawings_completed_date', label: 'Completed Date'),
        buildFieldRow('drawings_submitted_date', label: 'Submitted Date'),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('person_responsible', label: 'Person Responsible'),
        buildFieldRow('post_held', label: 'Post Held'),
        buildFieldRow('pending_with', label: 'Pending With'),

        if (ComponentStatusUtils.hasValue(data['drawings_remarks'])) ...[
          buildDivider(),
          buildFieldRow('drawings_remarks', label: 'Remarks'),
        ],
      ],
    );
  }
}
