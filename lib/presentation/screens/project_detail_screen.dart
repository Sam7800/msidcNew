import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../data/models/project.dart';
import '../widgets/module_tabs/dpr_tab.dart';
import '../widgets/module_tabs/work_tab.dart';
import '../widgets/module_tabs/monitoring_tab.dart';
import '../widgets/module_tabs/work_entry_tab.dart';

/// Project Detail Screen - Shows 4 module tabs for selected project
///
/// Navigation: Categories → Projects → Details (HERE) → Module Forms
class ProjectDetailScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        ? Color(int.parse('0xFF${widget.project.categoryColor!.replaceAll('#', '')}'))
        : const Color(0xFF0061FF); // Default blue

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor.withOpacity(0.3), categoryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: categoryColor,
                indicatorWeight: 2,
                labelColor: categoryColor,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.document_scanner, size: 20),
                    text: 'DPR',
                  ),
                  Tab(
                    icon: Icon(Icons.work, size: 20),
                    text: 'Work',
                  ),
                  Tab(
                    icon: Icon(Icons.analytics, size: 20),
                    text: 'Monitoring',
                  ),
                  Tab(
                    icon: Icon(Icons.edit_document, size: 20),
                    text: 'Work Entry',
                  ),
                ],
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.project.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '#${widget.project.srNo} • ${widget.project.categoryName ?? 'Unknown'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: categoryColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Project Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                left: BorderSide(color: categoryColor, width: 4),
                bottom: const BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Serial Number Badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '#${widget.project.srNo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Project Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.category,
                            label: widget.project.categoryName ?? 'Unknown',
                            color: categoryColor,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.location_on,
                            label: widget.project.location,
                            color: AppColors.info,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.project.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(widget.project.status),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.project.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DPRTab(projectId: widget.project.id!),
                WorkTab(projectId: widget.project.id!),
                MonitoringTab(projectId: widget.project.id!),
                WorkEntryTab(projectId: widget.project.id!),
              ],
            ),
          ),
        ],
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

/// Info Chip Widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
