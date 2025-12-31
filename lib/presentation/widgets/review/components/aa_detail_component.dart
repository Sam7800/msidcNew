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
    // Use standardized field name 'status' (automatically mapped from 'aa_status')
    final status = data['status']?.toString().toLowerCase() ?? '';
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

        buildFieldRow('proposed_amount', label: 'Proposed Amount', placeholder: '₹ 0'),
        buildFieldRow('proposal_date', label: 'Date of Proposal', placeholder: 'Not set'),
        buildFieldRow('pending_with', label: 'Pending With', placeholder: 'Not specified'),
      ],
    );
  }

  Widget _buildAccordedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Accorded'),
        const SizedBox(height: 12),

        // Use standardized field name 'amount' (mapped from 'aa_amount')
        buildFieldRow('amount', label: 'Amount', placeholder: '₹ 0'),
        buildFieldRow('number', label: 'AA No.', placeholder: 'Not assigned'), // NEW
        buildFieldRow('date', label: 'AA Date', placeholder: 'Not set'), // NEW

        buildDivider(),

        // Use standardized field name 'broad_scope' (mapped from 'broad_scope_aa')
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
            ComponentStatusUtils.hasValue(data['broad_scope'])
                ? data['broad_scope'].toString()
                : 'No broad scope description provided',
            style: TextStyle(
              fontSize: 13,
              color: ComponentStatusUtils.hasValue(data['broad_scope'])
                  ? AppColors.textPrimary
                  : AppColors.textSecondary.withOpacity(0.6),
              fontStyle: ComponentStatusUtils.hasValue(data['broad_scope'])
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
        ),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        // Use standardized field names (mapped from aa_person_responsible, etc.)
        buildFieldRow('person_responsible', label: 'Person Responsible', placeholder: 'Not assigned'),
        buildFieldRow('post_held', label: 'Post Held', placeholder: 'Not specified'),
        buildFieldRow('pending_with', label: 'Pending With', placeholder: 'Not specified'),
      ],
    );
  }
}
