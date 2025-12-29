import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/work_entry_data.dart';
import '../../../domain/models/review_section.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/review_grid_layout.dart';
import '../../providers/review_providers.dart';
import '../../providers/repository_providers.dart';
import '../review/review_section_grid.dart';

/// Main Review Tab screen showing all 33 components in expandable card grid
///
/// This screen:
/// - Loads WorkEntryData (draft or final) for the project
/// - Shows section filter buttons (All, DPR, Work, PMS)
/// - Displays grid of expandable component cards
/// - Allows collapsing all expanded cards at once
/// - Shows empty state if no work entry data exists
class ReviewTab extends ConsumerStatefulWidget {
  final int projectId;

  const ReviewTab({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends ConsumerState<ReviewTab> {
  WorkEntryData? _workEntryData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkEntryData();
  }

  /// Load work entry data (prioritize draft, fallback to final)
  Future<void> _loadWorkEntryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(workEntryRepositoryProvider);
      final data =
          await repository.getWorkEntryOrDraftByProjectId(widget.projectId);

      setState(() {
        _workEntryData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load work entry data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWorkEntryData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_workEntryData == null) {
      return _buildEmptyState();
    }

    return ReviewSectionGrid(
      workEntryData: _workEntryData!,
    );
  }

  /// Build the header with section filters and collapse all button
  Widget _buildHeader() {
    final selectedSection = ref.watch(reviewSectionFilterProvider);
    final expandedCards = ref.watch(reviewExpandedCardsProvider);
    final hasExpandedCards = expandedCards.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Section filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ReviewSection.values.map((section) {
                  final isSelected = selectedSection == section;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            section.icon,
                            size: 16,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(section.label),
                        ],
                      ),
                      onSelected: (_) {
                        ref.read(reviewSectionFilterProvider.notifier).state =
                            section;
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.background,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Collapse all button (only show when cards are expanded)
          if (hasExpandedCards)
            ElevatedButton.icon(
              onPressed: () => collapseAllCards(ref),
              icon: const Icon(Icons.unfold_less, size: 18),
              label: const Text('Collapse All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  /// Build empty state when no work entry data exists
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Work Entry Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please fill out the Work Entry form first',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Switch to Work Entry tab (index 0)
              DefaultTabController.of(context).animateTo(0);
            },
            icon: const Icon(Icons.edit_document),
            label: const Text('Go to Work Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
