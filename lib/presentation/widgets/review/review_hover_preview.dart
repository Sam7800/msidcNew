import 'package:flutter/material.dart';
import '../../../domain/models/review_component_config.dart';
import '../../../utils/review_component_mapper.dart';
import '../../../utils/component_status_utils.dart';
import '../../../theme/app_colors.dart';

/// Hover preview tooltip showing key component information
///
/// Features:
/// - Shows 2-3 key fields from the component
/// - Status chip with color coding
/// - "Click to expand" hint
/// - Fixed width (280px)
/// - Positioned to right of card (or left if near edge)
class ReviewHoverPreview extends StatelessWidget {
  final ReviewComponentConfig config;
  final Map<String, dynamic> data;

  const ReviewHoverPreview({
    super.key,
    required this.config,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Get status field
    final stateField = config.stateField != null
        ? data[config.stateField]
        : null;

    final statusColor = stateField != null
        ? ComponentStatusUtils.getStatusColor(stateField.toString())
        : null;

    final formattedStatus = stateField != null
        ? ComponentStatusUtils.formatStatus(stateField.toString())
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: config.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full title
          Text(
            config.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          // Status (if available)
          if (statusColor != null && formattedStatus != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  formattedStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
