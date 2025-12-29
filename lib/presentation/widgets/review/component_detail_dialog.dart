import 'package:flutter/material.dart';
import '../../../domain/models/review_component_config.dart';
import '../../../utils/component_status_utils.dart';
import '../../../theme/app_colors.dart';
import 'component_detail_view_factory.dart';

/// Dialog popup showing component details
///
/// Displays when user clicks on a component button card
class ComponentDetailDialog extends StatelessWidget {
  final ReviewComponentConfig config;
  final Map<String, dynamic> data;

  const ComponentDetailDialog({
    super.key,
    required this.config,
    required this.data,
  });

  /// Show the dialog
  static Future<void> show(
    BuildContext context,
    ReviewComponentConfig config,
    Map<String, dynamic> data,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ComponentDetailDialog(
        config: config,
        data: data,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateField = config.stateField != null
        ? data[config.stateField]
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: config.primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, stateField),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ComponentDetailViewFactory.create(
                  config: config,
                  data: data,
                ),
              ),
            ),

            // Footer with close button
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic stateField) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config.primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        border: Border(
          bottom: BorderSide(
            color: config.primaryColor.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: config.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              config.icon,
              size: 28,
              color: config.primaryColor,
            ),
          ),

          const SizedBox(width: 16),

          // Title and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (stateField != null) ...[
                  const SizedBox(height: 8),
                  _buildStatusBadge(stateField.toString()),
                ],
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            iconSize: 24,
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColor = ComponentStatusUtils.getStatusColor(status);
    final formattedStatus = ComponentStatusUtils.formatStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedStatus,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
