import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../data/models/project.dart';
import '../../data/models/category.dart';
import '../providers/project_provider.dart';
import '../widgets/dialogs/create_project_dialog.dart';
import 'project_detail_screen.dart';

/// Projects Screen - Shows projects within a selected category
///
/// Navigation: Categories → Projects (HERE) → Details
class ProjectsScreen extends ConsumerStatefulWidget {
  final Category category;

  const ProjectsScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load projects for this category
    Future.microtask(() {
      if (widget.category.id != null) {
        ref
            .read(projectProvider.notifier)
            .loadProjectsByCategoryId(widget.category.id!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateProject() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateProjectDialog(
        preselectedCategory: widget.category,
      ),
    );

    if (result == true && mounted) {
      // Refresh projects
      if (widget.category.id != null) {
        ref
            .read(projectProvider.notifier)
            .loadProjectsByCategoryId(widget.category.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final categoryColor = widget.category.getColor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Category icon - small, functional
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: categoryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.category.getIcon(),
                size: 18,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: 12),
            // Category name - left aligned
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Projects',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: categoryColor,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Properly sized action icons (24px)
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            tooltip: 'Create Project',
            onPressed: _handleCreateProject,
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            tooltip: Constants.tooltipRefresh,
            onPressed: () {
              if (widget.category.id != null) {
                ref
                    .read(projectProvider.notifier)
                    .loadProjectsByCategoryId(widget.category.id!);
              }
            },
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [categoryColor.withOpacity(0.3), categoryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: projectState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : projectState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        projectState.error!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.category.id != null) {
                            ref
                                .read(projectProvider.notifier)
                                .loadProjectsByCategoryId(widget.category.id!);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Compact header with search - Claude.com style
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Row(
                        children: [
                          // Title and count - compact
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Projects',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${projectState.projects.where((p) => _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery)).length} projects in this category',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Search bar - integrated
                          SizedBox(
                            width: 320,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.toLowerCase();
                                  });
                                },
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search projects...',
                                  hintStyle: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 18,
                                            color: AppColors.textSecondary,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Projects Grid
                    Expanded(
                      child: projectState.projects.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No projects found',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No projects in this category yet',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : Builder(
                              builder: (context) {
                                // Filter projects based on search
                                final filteredProjects = projectState.projects
                                    .where((p) =>
                                        _searchQuery.isEmpty ||
                                        p.name.toLowerCase().contains(_searchQuery))
                                    .toList();

                                // Show empty state if search has no results
                                if (filteredProjects.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: AppColors.textTertiary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No projects found',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Try a different search term',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.textTertiary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5, // Same as categories
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: filteredProjects.length,
                                  itemBuilder: (context, index) {
                                    final project = filteredProjects[index];
                                    return _ProjectCard(
                                      project: project,
                                      categoryColor: categoryColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProjectDetailScreen(
                                              project: project,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

/// Project Card Widget
class _ProjectCard extends StatefulWidget {
  final Project project;
  final Color categoryColor;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          // All borders in category color - same as category card
          border: Border.all(
            color: widget.categoryColor,
            width: _isHovered ? 2 : 1.5,
          ),
          // Shadow always present - same as category card
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.categoryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.categoryColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16), // Same as category card
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Serial Number Badge - exactly like category card icon
                  Container(
                    width: 56, // Same as category icon
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '#${widget.project.srNo}',
                        style: TextStyle(
                          color: widget.categoryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18, // Larger, more visible
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12), // Same spacing as category

                  // Project Name - same styling as category name
                  Text(
                    widget.project.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Same as category name
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Action badge - similar to category project count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: widget.categoryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
