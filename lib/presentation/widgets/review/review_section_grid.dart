import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/work_entry_data.dart';
import '../../../domain/models/review_component_config.dart';
import '../../../domain/models/review_section.dart';
import '../../../utils/review_component_mapper.dart';
import '../../../utils/review_grid_layout.dart';
import '../../../theme/app_colors.dart';
import '../../providers/review_providers.dart';
import 'review_card_base.dart';

/// Grid displaying filtered Review component cards
///
/// This widget:
/// - Gets components filtered by selected section
/// - Extracts data for each component from WorkEntryData
/// - Renders responsive grid of ReviewCard widgets
/// - Handles empty state when no components match filter
class ReviewSectionGrid extends ConsumerWidget {
  final WorkEntryData workEntryData;

  const ReviewSectionGrid({
    super.key,
    required this.workEntryData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get all components (no section filtering)
    final components = ReviewComponentMapper.getAllComponents();

    if (components.isEmpty) {
      return _buildEmptyState(context, 'Review');
    }

    // Group components by section
    final dprComponents = components.where((c) => c.section == ReviewSection.dpr).toList();
    final workComponents = components.where((c) => c.section == ReviewSection.work).toList();
    final pmsComponents = components.where((c) => c.section == ReviewSection.pms).toList();

    return Column(
      children: [
        // Status Legend
        _buildStatusLegend(),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DPR Section
                if (dprComponents.isNotEmpty) ...[
                  _buildSectionCard(
                    context: context,
                    title: 'DPR Section',
                    icon: Icons.description,
                    color: const Color(0xFF3B82F6),
                    components: dprComponents,
                  ),
                  const SizedBox(height: 24),
                ],

                // Work Section
                if (workComponents.isNotEmpty) ...[
                  _buildSectionCard(
                    context: context,
                    title: 'Work Section',
                    icon: Icons.work,
                    color: const Color(0xFF8B5CF6),
                    components: workComponents,
                  ),
                  const SizedBox(height: 24),
                ],

                // PMS Section
                if (pmsComponents.isNotEmpty) ...[
                  _buildSectionCard(
                    context: context,
                    title: 'PMS Section',
                    icon: Icons.analytics,
                    color: const Color(0xFF10B981),
                    components: pmsComponents,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build status legend showing color coding
  Widget _buildStatusLegend() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Compact title
          Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'Status:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),

          // Compact legend items
          _buildCompactLegendItem('Completed', AppColors.success),
          const SizedBox(width: 16),
          _buildCompactLegendItem('In Progress', AppColors.warning),
          const SizedBox(width: 16),
          _buildCompactLegendItem('Critical', AppColors.error),
          const SizedBox(width: 16),
          _buildCompactLegendItem('Not Started', AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildCompactLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Build modern section card with gradient header
  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<ReviewComponentConfig> components,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: color.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${components.length} component${components.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Component Cards
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: components.map((config) {
                final componentData =
                    ReviewComponentMapper.extractComponentData(config, workEntryData);
                return ReviewCardBase(config: config, data: componentData);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ],
    );
  }

  /// Build empty state when no components match the filter
  Widget _buildEmptyState(BuildContext context, String sectionName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No components in $sectionName section',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
