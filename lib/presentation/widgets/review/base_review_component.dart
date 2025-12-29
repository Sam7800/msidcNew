import 'package:flutter/material.dart';
import '../../../domain/models/review_component_config.dart';
import '../../../utils/component_status_utils.dart';
import '../../../utils/review_component_mapper.dart';
import '../../../theme/app_colors.dart';

/// Base abstract class for all Review component detail views
///
/// Each component-specific widget (AAComponent, DPRComponent, etc.)
/// extends this class and implements buildContent() to render
/// their specific layout.
///
/// Provides common UI building blocks:
/// - Field rows for key-value pairs
/// - Section headers
/// - Data tables
/// - Empty state handling
abstract class BaseReviewComponent extends StatelessWidget {
  final ReviewComponentConfig config;
  final Map<String, dynamic> data;

  const BaseReviewComponent({
    super.key,
    required this.config,
    required this.data,
  });

  /// Implement this method in subclasses to build component-specific content
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    // Check if component has any data
    if (!ReviewComponentMapper.hasData(data)) {
      return _buildEmptyState();
    }

    return buildContent(context);
  }

  /// Build empty state when no data is available
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
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

  // ============================================================
  // Common UI building blocks for subclasses
  // ============================================================

  /// Build a field row (label: value)
  Widget buildFieldRow(String fieldKey, {String? label, bool showIfNull = false}) {
    final value = data[fieldKey];

    // Skip if null and not explicitly showing null values
    if (!showIfNull && !ComponentStatusUtils.hasValue(value)) {
      return const SizedBox.shrink();
    }

    final fieldLabel = label ?? ReviewComponentMapper.getFieldLabel(fieldKey);
    final formattedValue =
        ComponentStatusUtils.formatFieldValue(fieldKey, value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              fieldLabel,
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
              formattedValue,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a section header
  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: config.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a divider
  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: AppColors.divider,
      ),
    );
  }

  /// Build a data table from JSON array
  ///
  /// [fieldKey] - The field containing JSON array data
  /// [columns] - List of column headers
  /// [rowBuilder] - Function to build each row from item data
  Widget buildDataTable(
    String fieldKey,
    List<String> columns,
    List<DataRow> Function(List<dynamic> items) rowBuilder,
  ) {
    final tableData = data[fieldKey];

    if (tableData == null) {
      return _buildTableEmptyState();
    }

    List<dynamic> items;
    if (tableData is String) {
      // Parse JSON string if needed
      // TODO: Add JSON parsing when table data is stored as JSON
      items = [];
    } else if (tableData is List) {
      items = tableData;
    } else {
      return _buildTableEmptyState();
    }

    if (items.isEmpty) {
      return _buildTableEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          config.primaryColor.withOpacity(0.1),
        ),
        columns: columns
            .map((col) => DataColumn(
                  label: Text(
                    col,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ))
            .toList(),
        rows: rowBuilder(items),
      ),
    );
  }

  /// Build empty state for tables
  Widget _buildTableEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'No table data available',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Build a status chip
  Widget buildStatusChip(String? status) {
    if (status == null || status.isEmpty) {
      return const SizedBox.shrink();
    }

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
      child: Text(
        formattedStatus,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  /// Build a progress bar
  Widget buildProgressBar(double percent) {
    final color = ComponentStatusUtils.getCompletionColor(percent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// Get the current state of the component
  String? getCurrentState(ReviewComponentConfig config, Map<String, dynamic> data) {
    return ReviewComponentMapper.getCurrentState(config, data);
  }

  /// Get visible fields for the current state
  List<String> getVisibleFields(ReviewComponentConfig config, String? currentState) {
    return ReviewComponentMapper.getVisibleFields(config, currentState);
  }
}
