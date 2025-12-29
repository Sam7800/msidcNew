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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DPR Section
          if (dprComponents.isNotEmpty) ...[
            _buildSectionHeader(context, 'DPR Section', Icons.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: dprComponents.map((config) {
                final componentData =
                    ReviewComponentMapper.extractComponentData(config, workEntryData);
                return ReviewCardBase(config: config, data: componentData);
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // Work Section
          if (workComponents.isNotEmpty) ...[
            _buildSectionHeader(context, 'Work Section', Icons.work),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: workComponents.map((config) {
                final componentData =
                    ReviewComponentMapper.extractComponentData(config, workEntryData);
                return ReviewCardBase(config: config, data: componentData);
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // PMS Section
          if (pmsComponents.isNotEmpty) ...[
            _buildSectionHeader(context, 'PMS Section', Icons.analytics),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: pmsComponents.map((config) {
                final componentData =
                    ReviewComponentMapper.extractComponentData(config, workEntryData);
                return ReviewCardBase(config: config, data: componentData);
              }).toList(),
            ),
          ],
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
