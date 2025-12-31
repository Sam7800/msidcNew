import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Pre-bid Detail Component
///
/// Shows date, number of bidders, and applications
class PrebidDetailComponent extends BaseReviewComponent {
  const PrebidDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['prebid_status']?.toString().toLowerCase() ?? '';
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

        if (ComponentStatusUtils.hasValue(data['prebid_scheduled_date'])) ...[
          buildFieldRow('prebid_scheduled_date', label: 'Scheduled Date'),

          if (ComponentStatusUtils.hasValue(data['prebid_remarks'])) ...[
            buildDivider(),
            buildFieldRow('prebid_remarks', label: 'Remarks'),
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
                    'Pre-bid meeting not yet scheduled',
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
        buildSectionHeader('Pre-bid Meeting Details'),
        buildFieldRow('date', label: 'Date', placeholder: 'Not set'),
        buildFieldRow('number_of_bidders', label: 'No. of Bidders Participated', placeholder: '0'),
        buildFieldRow('written_applications', label: '# of Written Applications Submitted', placeholder: '0'), // NEW

        if (ComponentStatusUtils.hasValue(data['queries_raised'])) ...[
          buildDivider(),
          buildFieldRow('queries_raised', label: 'Queries Raised'),
        ],

        if (ComponentStatusUtils.hasValue(data['prebid_remarks'])) ...[
          buildDivider(),
          buildFieldRow('prebid_remarks', label: 'Remarks'),
        ],
      ],
    );
  }
}
