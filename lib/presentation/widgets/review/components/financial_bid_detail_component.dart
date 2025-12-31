import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Financial Bid Detail Component
///
/// Shows date and L1/H1 offer details
class FinancialBidDetailComponent extends BaseReviewComponent {
  const FinancialBidDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final status = data['financial_bid_status']?.toString().toLowerCase() ?? '';
    final isOpened = status.contains('open') || status.contains('complet');

    if (!isOpened) {
      return _buildNotOpenedView();
    } else {
      return _buildOpenedView();
    }
  }

  Widget _buildNotOpenedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Status: Not Opened'),
        const SizedBox(height: 12),

        if (ComponentStatusUtils.hasValue(data['financial_bid_scheduled_date'])) ...[
          buildFieldRow('financial_bid_scheduled_date', label: 'Scheduled Date'),

          if (ComponentStatusUtils.hasValue(data['financial_bid_remarks'])) ...[
            buildDivider(),
            buildFieldRow('financial_bid_remarks', label: 'Remarks'),
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
                    'Financial bid opening date not yet scheduled',
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

  Widget _buildOpenedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Financial Bid Details'),
        buildFieldRow('date', label: 'Date', placeholder: 'Not set'),
        buildFieldRow('qualified_count', label: '# of Qualified Bidders Participated', placeholder: '0'), // NEW

        buildDivider(),

        buildSectionHeader('Bids Opened'),
        buildFieldRow('bid', label: 'L1/H1 Offer', placeholder: 'Not determined'),
        buildFieldRow('amount', label: 'Offer Amount (Rs. Lakhs/Cr)', placeholder: '₹ 0'),
        buildFieldRow('variance', label: '% Above/Below', placeholder: '0%'),

        if (ComponentStatusUtils.hasValue(data['financial_bid_remarks'])) ...[
          buildDivider(),
          buildFieldRow('financial_bid_remarks', label: 'Remarks'),
        ],
      ],
    );
  }
}
