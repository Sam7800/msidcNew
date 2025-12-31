import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Technical Audit Detail Component
///
/// Two states: Not Done or Carried Out with findings
class TechnicalAuditDetailComponent extends BaseReviewComponent {
  const TechnicalAuditDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['technical_audit_status']?.toString().toLowerCase() ?? '';
    final isDone = status.contains('carri') || status.contains('done') || status.contains('complet');

    if (!isDone) {
      return _buildNotDoneView();
    } else {
      return _buildDoneView();
    }
  }

  Widget _buildNotDoneView() {
    return Center(
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
              'Technical Audit Not Done',
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

  Widget _buildDoneView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Audit Details'),
        buildFieldRow('report', label: 'Audit Report', placeholder: 'Not available'),
        buildFieldRow('action', label: 'Action Taken', placeholder: 'No action'),
        buildFieldRow('no_action', label: 'No Action Required', placeholder: 'Not specified'),

        buildDivider(),

        buildSectionHeader('Findings'),
        buildFieldRow('compliance_count', label: '# of Findings', placeholder: '0'),

        buildDivider(),

        buildSectionHeader('Responsibility'),
        buildFieldRow('responsible_ee', label: 'Responsible EE', placeholder: 'Not assigned'),

        buildDivider(),

        buildSectionHeader('Compliance Submitted'),
        buildFieldRow('compliance_count', label: '# of Compliances Submitted', placeholder: '0'),
        buildFieldRow('compliance_dates', label: 'Compliance Dates', placeholder: 'No dates recorded'),
      ],
    );
  }
}
