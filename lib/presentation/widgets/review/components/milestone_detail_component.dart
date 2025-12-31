import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Milestone detail component showing targets, achievements, and progress
class MilestoneDetailComponent extends BaseReviewComponent {
  const MilestoneDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Use standardized field names (automatically mapped from ms1_*, ms2_*, etc.)
    final description = data['description'];
    final targetAmount = data['target_amount'];
    final achievementAmount = data['achievement_amount'];

    // Calculate progress percentage
    double progressPercent = 0;
    if (ComponentStatusUtils.hasValue(targetAmount) &&
        ComponentStatusUtils.hasValue(achievementAmount)) {
      final target = double.tryParse(targetAmount.toString()) ?? 0;
      final achievement = double.tryParse(achievementAmount.toString()) ?? 0;
      if (target > 0) {
        progressPercent = (achievement / target) * 100;
        if (progressPercent > 100) progressPercent = 100;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description - always show with placeholder
        buildSectionHeader('Description'),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            ComponentStatusUtils.hasValue(description)
                ? description.toString()
                : 'No description provided',
            style: TextStyle(
              fontSize: 13,
              color: ComponentStatusUtils.hasValue(description)
                  ? AppColors.textPrimary
                  : AppColors.textSecondary.withOpacity(0.6),
              fontStyle: ComponentStatusUtils.hasValue(description)
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
        ),

        buildDivider(),

        // Period - NEW
        buildFieldRow('period', label: 'Period', placeholder: 'Not specified'),

        buildDivider(),

        // Target Information - always show
        buildSectionHeader('Target'),
        buildFieldRow('target_date', label: 'Target Date', placeholder: 'Not set'),
        buildFieldRow('target_amount', label: 'Target Amount', placeholder: '₹ 0'),
        buildFieldRow('physical_target', label: 'Physical Target (%)', placeholder: '0%'), // NEW

        buildDivider(),

        // Achievement Information - always show
        buildSectionHeader('Achievement'),
        buildFieldRow('achievement_date', label: 'Achievement Date', placeholder: 'Not achieved yet'),
        buildFieldRow('achievement_amount', label: 'Achievement Amount', placeholder: '₹ 0'),
        buildFieldRow('physical_achieved', label: 'Physical Achieved (%)', placeholder: '0%'), // NEW

        // Progress bar - always show
        const SizedBox(height: 16),
        buildProgressBar(progressPercent),

        buildDivider(),

        // Responsibility - always show
        buildSectionHeader('Responsibility'),
        buildFieldRow('person_responsible', label: 'Person Responsible', placeholder: 'Not assigned'),
        buildFieldRow('post_held', label: 'Post Held', placeholder: 'Not specified'),
        buildFieldRow('pending_with', label: 'Pending With', placeholder: 'Not specified'),

        buildDivider(),

        // LD - always show
        buildFieldRow('ld_imposed', label: 'LD Imposed', placeholder: 'Not Applicable'),

        // Remarks - always show with placeholder
        const SizedBox(height: 12),
        buildSectionHeader('Remarks'),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            ComponentStatusUtils.hasValue(data['remarks'])
                ? data['remarks'].toString()
                : 'No remarks',
            style: TextStyle(
              fontSize: 13,
              color: ComponentStatusUtils.hasValue(data['remarks'])
                  ? AppColors.textSecondary
                  : AppColors.textSecondary.withOpacity(0.6),
              fontStyle: ComponentStatusUtils.hasValue(data['remarks'])
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
