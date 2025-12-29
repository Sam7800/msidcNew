import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// DPR (Detailed Project Report) Detail Component
///
/// Four states: Not Started, In Progress, Submitted, Approved
class DPRDetailComponent extends BaseReviewComponent {
  const DPRDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['dpr_status']?.toString().toLowerCase() ?? 'not started';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        buildStatusChip(data['dpr_status']?.toString() ?? 'Not Started'),
        const SizedBox(height: 16),

        // Content based on status
        if (status.contains('not') || status.contains('start')) ...[
          _buildNotStartedView(),
        ] else if (status.contains('progress')) ...[
          _buildInProgressView(),
        ] else if (status.contains('submit')) ...[
          _buildSubmittedView(),
        ] else if (status.contains('approv')) ...[
          _buildApprovedView(),
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
              'DPR preparation not yet started',
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
        buildFieldRow('likely_completion_date', label: 'Likely Date of Completion'),
        buildFieldRow('dpr_pa_name', label: 'Preparing Agency'),
        buildFieldRow('dpr_name', label: 'DPR Name'),
      ],
    );
  }

  Widget _buildSubmittedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldRow('dpr_submitted_date', label: 'Submitted Date'),
        buildFieldRow('dpr_pa_name', label: 'Preparing Agency'),
        buildFieldRow('dpr_name', label: 'DPR Name'),

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
                  'Awaiting approval',
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

  Widget _buildApprovedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Approval Details'),
        buildFieldRow('dpr_approved_date', label: 'Approved Date'),
        buildFieldRow('dpr_submitted_date', label: 'Submitted Date'),
        buildFieldRow('dpr_pa_name', label: 'Preparing Agency'),
        buildFieldRow('dpr_name', label: 'DPR Name'),

        if (ComponentStatusUtils.hasValue(data['broad_scope_dpr'])) ...[
          buildDivider(),
          buildSectionHeader('Broad Scope'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              data['broad_scope_dpr'].toString(),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
