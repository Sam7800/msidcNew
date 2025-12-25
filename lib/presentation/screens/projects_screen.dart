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
  bool _isSearching = false;

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

  void _handleSearch(String query) {
    if (query.isEmpty) {
      if (widget.category.id != null) {
        ref
            .read(projectProvider.notifier)
            .loadProjectsByCategoryId(widget.category.id!);
      }
    } else {
      ref.read(projectProvider.notifier).searchProjects(query);
    }
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
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  border: InputBorder.none,
                ),
                onChanged: _handleSearch,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Projects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Project',
            onPressed: _handleCreateProject,
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  if (widget.category.id != null) {
                    ref
                        .read(projectProvider.notifier)
                        .loadProjectsByCategoryId(widget.category.id!);
                  }
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: Constants.tooltipRefresh,
            onPressed: () {
              if (widget.category.id != null) {
                ref
                    .read(projectProvider.notifier)
                    .loadProjectsByCategoryId(widget.category.id!);
              }
            },
          ),
        ],
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
              : projectState.projects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 80,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No projects found',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isSearching
                                ? 'Try a different search term'
                                : 'No projects in this category yet',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textDisabled,
                                    ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header with count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          color: AppColors.surfaceVariant,
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder,
                                color: categoryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${projectState.projects.length} Projects',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Projects Grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1.4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: projectState.projects.length,
                            itemBuilder: (context, index) {
                              final project = projectState.projects[index];
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
          border: Border(
            left: BorderSide(
              color: widget.categoryColor,
              width: _isHovered ? 4 : 3,
            ),
            top: BorderSide(color: AppColors.border, width: 1),
            right: BorderSide(color: AppColors.border, width: 1),
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.categoryColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Serial Number Badge - Minimal design
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#${widget.project.srNo}',
                      style: TextStyle(
                        color: widget.categoryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Project Name
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.project.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // View Details Button - Cleaner design
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onTap,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: widget.categoryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: widget.categoryColor,
                          ),
                        ],
                      ),
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
