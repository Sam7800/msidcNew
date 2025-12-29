import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// AA (Administrative Approval) Detail Component
///
/// Two states: Awaited or Accorded
class AADetailComponent extends BaseReviewComponent {
  const AADetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['aa_status']?.toString().toLowerCase() ?? '';
    final isAccorded = status.contains('accord');

    if (isAccorded) {
      return _buildAccordedView();
    } else {
      return _buildAwaitedView();
    }
  }

  Widget _buildAwaitedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Awaited'),
        const SizedBox(height: 12),

        buildFieldRow('proposed_amount', label: 'Proposed Amount'),
        buildFieldRow('proposal_date', label: 'Date of Proposal'),
        buildFieldRow('pending_with', label: 'Pending With'),

        if (!ComponentStatusUtils.hasValue(data['proposed_amount']) &&
            !ComponentStatusUtils.hasValue(data['proposal_date']) &&
            !ComponentStatusUtils.hasValue(data['pending_with'])) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              'AA awaiting approval - details pending',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccordedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Accorded'),
        const SizedBox(height: 12),

        buildFieldRow('aa_amount', label: 'Amount'),
        buildFieldRow('aa_number', label: 'AA No.'),
        buildFieldRow('aa_sanctioned_date', label: 'Date'),

        buildDivider(),

        buildSectionHeader('Broad Scope'),
        const SizedBox(height: 8),

        if (ComponentStatusUtils.hasValue(data['broad_scope_aa'])) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              data['broad_scope_aa'].toString(),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ] else ...[
          Text(
            'No scope details available',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
