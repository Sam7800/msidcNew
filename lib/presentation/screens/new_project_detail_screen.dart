import 'package:flutter/material.dart';
import '../../data/models/project.dart';
import '../../theme/app_colors.dart';
import '../widgets/forms/work_entry_form_widget.dart';
import '../widgets/module_tabs/review_tab.dart';

/// New Project Detail Screen - Redesigned UI with Tabs
///
/// Navigation: Categories → Projects → Project Details (HERE)
///
/// Tabs:
/// - Work Entry: Form for entering work entry data
/// - Review: Review dashboard showing all components in grid
class NewProjectDetailScreen extends StatefulWidget {
  final Project project;

  const NewProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<NewProjectDetailScreen> createState() => _NewProjectDetailScreenState();
}

class _NewProjectDetailScreenState extends State<NewProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parse category color from hex string
    final categoryColor = widget.project.categoryColor != null
        ? Color(int.parse(
            '0xFF${widget.project.categoryColor!.replaceAll('#', '')}'))
        : const Color(0xFF0061FF); // Default blue

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Compact Professional Header
          _buildCompactHeader(categoryColor),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                WorkEntryFormWidget(projectId: widget.project.id!),
                ReviewTab(projectId: widget.project.id!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact, professional header inspired by Claude Code / VS Code
  Widget _buildCompactHeader(Color categoryColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: Back button, Project info, Status
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    color: AppColors.textPrimary,
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),

                  const SizedBox(width: 4),

                  // SR Number chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '#${widget.project.srNo}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: categoryColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Project name
                  Expanded(
                    child: Text(
                      widget.project.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Status badge (compact)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.project.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(widget.project.status)
                            .withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.project.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.project.status,
                          style: TextStyle(
                            color: _getStatusColor(widget.project.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Bottom row: Tabs
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab(
                    icon: Icons.edit_note,
                    label: 'Work Entry',
                    isSelected: _tabController.index == 0,
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildTab(
                    icon: Icons.grid_view,
                    label: 'Review',
                    isSelected: _tabController.index == 1,
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() {});
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual tab button
  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.textPrimary.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border(
                    bottom: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'in progress':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'on hold':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in progress':
        return Icons.pending;
      case 'pending':
        return Icons.schedule;
      case 'on hold':
        return Icons.pause_circle;
      default:
        return Icons.info;
    }
  }
}
