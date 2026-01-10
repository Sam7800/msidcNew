import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../providers/repository_providers.dart';
import '../providers/project_provider.dart';

/// Critical Subsections Screen
///
/// Shows all subsections marked as critical across projects
/// Accessible from:
/// 1. Categories Screen - Shows critical items for ALL projects
/// 2. Projects Screen - Shows critical items for projects in a specific category
class CriticalSubsectionsScreen extends ConsumerStatefulWidget {
  final int? categoryId; // null = all projects, set = specific category

  const CriticalSubsectionsScreen({
    super.key,
    this.categoryId,
  });

  @override
  ConsumerState<CriticalSubsectionsScreen> createState() =>
      _CriticalSubsectionsScreenState();
}

class _CriticalSubsectionsScreenState
    extends ConsumerState<CriticalSubsectionsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All'; // All, DPR, Work, PMS

  @override
  void initState() {
    super.initState();
    // Load projects based on categoryId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId == null) {
        // Load ALL projects when accessing from dashboard
        ref.read(projectProvider.notifier).loadAllProjects();
      } else {
        // Load category-specific projects when accessing from category
        ref.read(projectProvider.notifier).loadProjectsByCategoryId(widget.categoryId!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Critical Subsections',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.categoryId == null
                  ? 'All Projects'
                  : 'Category Projects',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase().trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search critical items...',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Category Filter Chips
                Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('DPR'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Work'),
                    const SizedBox(width: 8),
                    _buildFilterChip('PMS'),
                  ],
                ),
              ],
            ),
          ),
          // Critical Items List
          Expanded(
            child: _buildCriticalItemsList(projectState),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalItemsList(ProjectState projectState) {
    // Show loading indicator
    if (projectState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message
    if (projectState.error != null) {
      return Center(
        child: Text('Error: ${projectState.error}'),
      );
    }

    // Filter projects by category if specified
    final filteredProjects = widget.categoryId != null
        ? projectState.projects
            .where((p) => p.categoryId == widget.categoryId)
            .toList()
        : projectState.projects;

    if (filteredProjects.isEmpty) {
      return _buildEmptyState('No projects found');
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadCriticalSubsections(
          filteredProjects.map((p) => p.id!).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No critical subsections marked yet');
        }

        final criticalItems = snapshot.data!;

        // Apply filters
        final filtered = criticalItems.where((item) {
          // Category filter
          if (_selectedCategory != 'All' &&
              item['category'] != _selectedCategory) {
            return false;
          }

          // Search filter
          if (_searchQuery.isNotEmpty) {
            final projectName =
                item['project_name']?.toString().toLowerCase() ?? '';
            final subsectionName =
                item['subsection_name']?.toString().toLowerCase() ?? '';
            final category = item['category']?.toString().toLowerCase() ?? '';

            return projectName.contains(_searchQuery) ||
                subsectionName.contains(_searchQuery) ||
                category.contains(_searchQuery);
          }

          return true;
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState('No matching critical items found');
        }

        // Group by project
        final groupedByProject = <int, List<Map<String, dynamic>>>{};
        for (var item in filtered) {
          final projectId = item['project_id'] as int;
          groupedByProject.putIfAbsent(projectId, () => []);
          groupedByProject[projectId]!.add(item);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedByProject.length,
          itemBuilder: (context, index) {
            final projectId = groupedByProject.keys.elementAt(index);
            final projectItems = groupedByProject[projectId]!;
            final projectName = projectItems.first['project_name'];

            return _buildProjectGroup(projectName, projectItems);
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectGroup(
      String projectName, List<Map<String, dynamic>> items) {
    // Get project category from first item (all items in group have same project)
    final projectCategoryName = items.first['project_category_name'] as String?;
    final projectCategoryColor = items.first['project_category_color'] as String?;

    // Parse category color if available
    Color? categoryColor;
    if (projectCategoryColor != null) {
      try {
        categoryColor = Color(int.parse(projectCategoryColor.replaceFirst('#', '0xFF')));
      } catch (e) {
        categoryColor = null;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            projectName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (projectCategoryName != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor?.withOpacity(0.1) ??
                                        AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    projectCategoryName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: categoryColor ?? AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length} Critical',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Critical Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildCriticalTile(items[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalTile(Map<String, dynamic> item) {
    final category = item['category'] as String;
    final subsectionName = item['subsection_name'] as String;
    final createdAt = item['created_at'] as String;

    // Parse date
    DateTime? createdDate;
    try {
      createdDate = DateTime.parse(createdAt);
    } catch (e) {
      // Ignore parsing errors
    }

    // Category color
    Color categoryColor;
    switch (category) {
      case 'DPR':
        categoryColor = const Color(0xFF3B82F6); // Blue
        break;
      case 'Work':
        categoryColor = const Color(0xFF10B981); // Green
        break;
      case 'PMS':
        categoryColor = const Color(0xFF8B5CF6); // Purple
        break;
      default:
        categoryColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Critical Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subsectionName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    if (createdDate != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(createdDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Arrow Icon
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mark subsections as critical in Work Entry',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadCriticalSubsections(
      List<int> projectIds) async {
    if (projectIds.isEmpty) return [];

    final criticalRepo = ref.read(criticalSubsectionsRepositoryProvider);
    final projectState = ref.read(projectProvider);

    final List<Map<String, dynamic>> allCriticalItems = [];

    for (var projectId in projectIds) {
      final items =
          await criticalRepo.getCriticalSubsectionsByProjectId(projectId);

      // Get project details (name and category)
      final projects = projectState.projects;
      final project = projects.firstWhere(
        (p) => p.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );

      // Add project name and category to each item
      for (var item in items) {
        allCriticalItems.add({
          ...item,
          'project_name': project.name,
          'project_category_name': project.categoryName ?? 'Unknown',
          'project_category_color': project.categoryColor,
        });
      }
    }

    return allCriticalItems;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
