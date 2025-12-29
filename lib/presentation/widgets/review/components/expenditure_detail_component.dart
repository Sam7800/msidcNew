import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../../../../utils/component_status_utils.dart';
import '../../../../theme/app_colors.dart';
import '../base_review_component.dart';

/// Expenditure detail component showing spending vs agreement amount
class ExpenditureDetailComponent extends BaseReviewComponent {
  const ExpenditureDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    final agreementAmount = data['agreement_amount'];
    final expenditureTillDate = data['expenditure_till_date'];
    final expenditurePercentage = data['expenditure_percentage'];

    // Calculate percentage if not provided
    double percentSpent = 0;
    if (expenditurePercentage != null) {
      percentSpent = double.tryParse(expenditurePercentage.toString()) ?? 0;
    } else if (agreementAmount != null && expenditureTillDate != null) {
      final agreement = double.tryParse(agreementAmount.toString()) ?? 0;
      final spent = double.tryParse(expenditureTillDate.toString()) ?? 0;
      if (agreement > 0) {
        percentSpent = (spent / agreement) * 100;
      }
    }

    // Calculate remaining amount
    double remaining = 0;
    if (agreementAmount != null && expenditureTillDate != null) {
      final agreement = double.tryParse(agreementAmount.toString()) ?? 0;
      final spent = double.tryParse(expenditureTillDate.toString()) ?? 0;
      remaining = agreement - spent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Agreement Amount
        buildSectionHeader('Budget'),
        buildFieldRow('agreement_amount', label: 'Agreement Amount'),
        buildDivider(),

        // Expenditure
        buildSectionHeader('Expenditure'),
        buildFieldRow('expenditure_till_date', label: 'Spent Till Date'),

        // Remaining amount
        if (remaining > 0) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Remaining',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Text(
                    ComponentStatusUtils.formatCurrency(remaining),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],

        buildDivider(),

        // Progress bar
        buildSectionHeader('Progress'),
        const SizedBox(height: 8),
        buildProgressBar(percentSpent),

        // Status message
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: percentSpent > 90
                ? AppColors.warning.withOpacity(0.1)
                : AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: percentSpent > 90
                  ? AppColors.warning.withOpacity(0.3)
                  : AppColors.success.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                percentSpent > 90 ? Icons.warning_amber : Icons.check_circle,
                size: 16,
                color: percentSpent > 90 ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  percentSpent > 90
                      ? 'Nearing budget limit - ${percentSpent.toStringAsFixed(1)}% spent'
                      : '${percentSpent.toStringAsFixed(1)}% of budget utilized',
                  style: TextStyle(
                    fontSize: 12,
                    color: percentSpent > 90 ? AppColors.warning : AppColors.success,
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
}
