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
    // Extract milestone-specific data based on config.id
    final msPrefix = config.id.toLowerCase().replaceAll('-', '');

    final description = data['${msPrefix}_description'];
    final targetDate = data['${msPrefix}_target_date'];
    final targetAmount = data['${msPrefix}_target_amount'];
    final achievementDate = data['${msPrefix}_achievement_date'];
    final achievementAmount = data['${msPrefix}_achievement_amount'];
    final ldImposed = data['${msPrefix}_ld_imposed'];
    final remarks = data['${msPrefix}_remarks'];

    // Calculate progress percentage
    double progressPercent = 0;
    if (targetAmount != null && achievementAmount != null) {
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
        // Description
        if (ComponentStatusUtils.hasValue(description)) ...[
          buildSectionHeader('Description'),
          Text(
            description.toString(),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          buildDivider(),
        ],

        // Target Information
        buildSectionHeader('Target'),
        buildFieldRow('${msPrefix}_target_date', label: 'Target Date'),
        buildFieldRow('${msPrefix}_target_amount', label: 'Target Amount'),
        buildDivider(),

        // Achievement Information
        buildSectionHeader('Achievement'),
        buildFieldRow('${msPrefix}_achievement_date', label: 'Achievement Date'),
        buildFieldRow('${msPrefix}_achievement_amount', label: 'Achievement Amount'),

        // Progress bar
        if (targetAmount != null && achievementAmount != null) ...[
          const SizedBox(height: 16),
          buildProgressBar(progressPercent),
        ],

        buildDivider(),

        // LD and Remarks
        buildFieldRow('${msPrefix}_ld_imposed', label: 'LD Imposed'),
        if (ComponentStatusUtils.hasValue(remarks)) ...[
          const SizedBox(height: 12),
          buildSectionHeader('Remarks'),
          Text(
            remarks.toString(),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
