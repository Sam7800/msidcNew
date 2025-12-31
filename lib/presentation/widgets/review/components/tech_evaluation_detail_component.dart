import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Technical Evaluation Detail Component
///
/// Three states: Not Started, In Progress, Completed
class TechEvaluationDetailComponent extends BaseReviewComponent {
  const TechEvaluationDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['tech_eval_status']?.toString().toLowerCase() ?? 'not started';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        buildStatusChip(data['tech_eval_status']?.toString() ?? 'Not Started'),
        const SizedBox(height: 16),

        // Content based on status
        if (status.contains('not') || status.contains('start')) ...[
          _buildNotStartedView(),
        ] else if (status.contains('progress')) ...[
          _buildInProgressView(),
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
              'Technical evaluation not yet started',
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
        buildFieldRow('tech_eval_likely_completion', label: 'Likely Date of Completion', placeholder: 'Not set'), // NEW

        buildDivider(),

        buildFieldRow('tech_eval_qualified', label: 'Qualified Bidders'),
        buildFieldRow('tech_eval_person_responsible', label: 'Person Responsible'),
        buildFieldRow('tech_eval_post_held', label: 'Post Held'),
        buildFieldRow('tech_eval_pending_with', label: 'Pending With'),
      ],
    );
  }

  Widget _buildCompletedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Evaluation Results'),
        buildFieldRow('tech_eval_qualified', label: '# of Bidders Qualified', placeholder: '0'),
        buildFieldRow('tech_eval_results_published_date', label: 'Qualified Bidders Results Published', placeholder: 'Not published'), // NEW
        buildFieldRow('tech_eval_fin_bid_opening_informed', label: 'Date of Financial Bid Opening Informed', placeholder: 'Not informed'), // NEW

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('tech_eval_person_responsible', label: 'Person Responsible'),
        buildFieldRow('tech_eval_post_held', label: 'Post Held'),
        buildFieldRow('tech_eval_pending_with', label: 'Pending With'),
      ],
    );
  }
}
