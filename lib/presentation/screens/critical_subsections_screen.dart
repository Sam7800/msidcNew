import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../providers/repository_providers.dart';
import '../providers/project_provider.dart';
import 'subsection_detail_screen.dart';
import '../../data/models/project.dart';
import '../../data/models/subsection_field_mapping.dart';

/// Critical Subsections Screen
///
/// Shows all subsections marked as critical across projects
/// Accessible from:
/// 1. Categories Screen - Shows critical items for ALL projects
/// 2. Projects Screen - Shows critical items for projects in a specific category
/// 3. Project Header - Shows critical items for a specific project
class CriticalSubsectionsScreen extends ConsumerStatefulWidget {
  final int? categoryId; // null = all projects, set = specific category
  final int? projectId; // null = all projects in category, set = specific project

  const CriticalSubsectionsScreen({
    super.key,
    this.categoryId,
    this.projectId,
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
  final Set<int> _expandedProjects = {}; // Track expanded project IDs
  List<Map<String, dynamic>>? _cachedCriticalItems; // Cache critical items
  List<int>? _cachedProjectIds; // Cache project IDs to detect changes
  final Map<String, bool> _toggledOffItems = {}; // Track items toggled off (key = "projectId_category_subsectionName")
  final Set<String> _selectedItemsForShare = {}; // Track items selected for sharing (key = "projectId_category_subsectionName")
  bool _isSelectionMode = false; // Whether we're in selection mode

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
              'Critical Items',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.projectId != null
                  ? 'Single Project'
                  : widget.categoryId == null
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
        actions: _isSelectionMode
            ? [
                // Selection mode: Show cancel and share buttons
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedItemsForShare.clear();
                    });
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _selectedItemsForShare.isEmpty
                      ? null
                      : _showEmailComposer,
                  icon: const Icon(Icons.send, size: 18),
                  label: Text('Send (${_selectedItemsForShare.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.textTertiary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                  ),
                ),
                const SizedBox(width: 16),
              ]
            : [
                // Normal mode: Show remove critical and share buttons
                if (_toggledOffItems.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: _showRemoveCriticalConfirmation,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text('Submit (${_toggledOffItems.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = true;
                    });
                  },
                  icon: const Icon(Icons.share),
                  tooltip: 'Share critical items',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
              ],
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

    // Filter projects by category and/or project ID
    List<Project> filteredProjects;
    if (widget.projectId != null) {
      // Show only the specific project
      filteredProjects = projectState.projects
          .where((p) => p.id == widget.projectId)
          .toList();
    } else if (widget.categoryId != null) {
      // Show projects in specific category
      filteredProjects = projectState.projects
          .where((p) => p.categoryId == widget.categoryId)
          .toList();
    } else {
      // Show all projects
      filteredProjects = projectState.projects;
    }

    if (filteredProjects.isEmpty) {
      return _buildEmptyState('No projects found');
    }

    final currentProjectIds = filteredProjects.map((p) => p.id!).toList();

    // Check if we need to reload data
    final needsReload = _cachedCriticalItems == null ||
        _cachedProjectIds == null ||
        !_listEquals(_cachedProjectIds!, currentProjectIds);

    if (needsReload) {
      // Load new data
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadCriticalSubsections(currentProjectIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState('No critical subsections marked yet');
          }

          // Cache the data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _cachedCriticalItems = snapshot.data;
                _cachedProjectIds = currentProjectIds;
              });
            }
          });

          return _buildCriticalItemsContent(snapshot.data!);
        },
      );
    } else {
      // Use cached data
      return _buildCriticalItemsContent(_cachedCriticalItems!);
    }
  }

  Widget _buildCriticalItemsContent(List<Map<String, dynamic>> criticalItems) {
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

        return _buildProjectGroup(projectId, projectName, projectItems);
      },
    );
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        if (_selectedCategory != label) {
          setState(() {
            _selectedCategory = label;
            // No need to clear cache - filtering is done on cached data
          });
        }
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
      int projectId, String projectName, List<Map<String, dynamic>> items) {
    // Get project category from first item (all items in group have same project)
    final projectCategoryName = items.first['project_category_name'] as String?;
    final projectCategoryColor = items.first['project_category_color'] as String?;
    final isExpanded = _expandedProjects.contains(projectId);

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
          // Project Header - Tappable to expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedProjects.remove(projectId);
                } else {
                  _expandedProjects.add(projectId);
                }
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isExpanded ? Radius.zero : const Radius.circular(12),
                  bottomRight: isExpanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Project icon and name
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
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Critical Items - Only show when expanded
          if (isExpanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCriticalTile(projectId, items[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCriticalTile(int projectId, Map<String, dynamic> item) {
    final category = item['category'] as String;
    final subsectionName = item['subsection_name'] as String;
    final createdAt = item['created_at'] as String;
    final personResponsible = item['person_responsible'] as String?;
    final projectName = item['project_name'] as String;

    // Create unique key for this item
    final itemKey = '${projectId}_${category}_$subsectionName';
    final isToggledOff = _toggledOffItems[itemKey] ?? false;
    final isSelected = _selectedItemsForShare.contains(itemKey);

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

    return InkWell(
      onTap: () async {
        if (_isSelectionMode) {
          // In selection mode, toggle selection
          setState(() {
            if (isSelected) {
              _selectedItemsForShare.remove(itemKey);
            } else {
              _selectedItemsForShare.add(itemKey);
              // Store the full item data for email generation
              if (!_selectedItemsForShare.contains(itemKey)) {
                _selectedItemsForShare.add(itemKey);
              }
            }
          });
        } else {
          // Normal mode: Navigate to detail screen
          // Get the project object
          final projectState = ref.read(projectProvider);
          final project = projectState.projects.firstWhere(
            (p) => p.id == projectId,
            orElse: () => throw Exception('Project not found'),
          );

          // Navigate to Subsection Detail screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubsectionDetailScreen(
                project: project,
                category: category,
                subsectionName: subsectionName,
              ),
            ),
          );

          // Refresh if critical status changed (unflagged)
          if (result == false) {
            // result is false when subsection was unflagged
            setState(() {
              // Clear cache to force reload
              _cachedCriticalItems = null;
              _cachedProjectIds = null;
              _toggledOffItems.clear();
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isToggledOff
              ? AppColors.background.withOpacity(0.5)
              : isSelected
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isToggledOff
                    ? AppColors.border
                    : const Color(0xFFEF4444).withOpacity(0.3),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Checkbox in selection mode, switch in normal mode
            if (_isSelectionMode)
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedItemsForShare.add(itemKey);
                    } else {
                      _selectedItemsForShare.remove(itemKey);
                    }
                  });
                },
                activeColor: AppColors.primary,
              )
            else
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: !isToggledOff, // true = critical (on), false = not critical (off)
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        // Turned on - remove from toggled off list
                        _toggledOffItems.remove(itemKey);
                      } else {
                        // Turned off - add to toggled off list
                        _toggledOffItems[itemKey] = true;
                      }
                    });
                  },
                  activeColor: const Color(0xFFEF4444),
                  activeTrackColor: const Color(0xFFEF4444).withOpacity(0.3),
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.border,
                ),
              ),
            const SizedBox(width: 8),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subsectionName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isToggledOff
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration:
                          isToggledOff ? TextDecoration.lineThrough : null,
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
                      if (personResponsible != null && personResponsible.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            personResponsible,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
    final workEntryRepo = ref.read(workEntryRepositoryProvider);

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

      // Load work entry data to get person responsible
      final workEntry = await workEntryRepo.getWorkEntryOrDraftByProjectId(projectId);

      // Add project name, category, and person responsible to each item
      for (var item in items) {
        String? personResponsible;

        if (workEntry != null) {
          final category = item['category'] as String;
          final subsectionName = item['subsection_name'] as String;

          // Get the field list for this subsection
          final fields = SubsectionFieldMapping.getFieldsForSubsection(
            subsectionName,
            category,
          );

          // Find the person_responsible field (usually ends with _person_responsible)
          final personFieldKey = fields.firstWhere(
            (field) => field.endsWith('_person_responsible'),
            orElse: () => '',
          );

          if (personFieldKey.isNotEmpty) {
            final sectionData = category == 'DPR'
                ? workEntry.dprSection
                : category == 'Work'
                    ? workEntry.workSection
                    : workEntry.pmsSection;
            personResponsible = sectionData[personFieldKey]?.toString();
          }
        }

        allCriticalItems.add({
          ...item,
          'project_name': project.name,
          'project_category_name': project.categoryName ?? 'Unknown',
          'project_category_color': project.categoryColor,
          'person_responsible': personResponsible,
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

  void _showRemoveCriticalConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Remove Critical Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to remove the critical status from ${_toggledOffItems.length} subsection(s)?',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitRemoveCritical();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRemoveCritical() async {
    try {
      final criticalRepo = ref.read(criticalSubsectionsRepositoryProvider);

      // Process each toggled-off item
      for (var entry in _toggledOffItems.entries) {
        // Parse the key: projectId_category_subsectionName
        final parts = entry.key.split('_');
        if (parts.length >= 3) {
          final projectId = int.parse(parts[0]);
          final category = parts[1];
          final subsectionName = parts.sublist(2).join('_'); // Rejoin in case subsection name has underscores

          // Remove from database
          await criticalRepo.removeCritical(projectId, category, subsectionName);
        }
      }

      // Clear the toggled-off items
      setState(() {
        _toggledOffItems.clear();
        // Clear cache to force reload
        _cachedCriticalItems = null;
        _cachedProjectIds = null;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Critical status removed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showEmailComposer() {
    final toController = TextEditingController();
    final subjectController = TextEditingController(
      text: 'Critical Subsections Alert - ${_selectedItemsForShare.length} items',
    );
    final bodyController = TextEditingController();

    // Generate email body with selected items
    String generateEmailBody() {
      final buffer = StringBuffer();
      buffer.writeln('Critical Subsections Report\n');
      buffer.writeln('=' * 50);
      buffer.writeln('\n');

      // Group selected items by project
      final itemsByProject = <String, List<Map<String, dynamic>>>{};

      for (var selectedKey in _selectedItemsForShare) {
        // Find the item in cached data
        final item = _cachedCriticalItems?.firstWhere(
          (item) {
            final projectId = item['project_id'] as int;
            final category = item['category'] as String;
            final subsectionName = item['subsection_name'] as String;
            final itemKey = '${projectId}_${category}_$subsectionName';
            return itemKey == selectedKey;
          },
          orElse: () => {},
        );

        if (item != null && item.isNotEmpty) {
          final projectName = item['project_name'] as String? ?? 'Unknown Project';
          itemsByProject.putIfAbsent(projectName, () => []);
          itemsByProject[projectName]!.add(item);
        }
      }

      // Format items by project
      itemsByProject.forEach((projectName, items) {
        buffer.writeln('Project: $projectName');
        buffer.writeln('-' * 50);
        for (var item in items) {
          final subsectionName = item['subsection_name'] as String;
          final category = item['category'] as String;
          final personResponsible = item['person_responsible'] as String? ?? 'Not assigned';

          buffer.writeln('  • $subsectionName');
          buffer.writeln('    Category: $category');
          buffer.writeln('    Person Responsible: $personResponsible');
          buffer.writeln('');
        }
        buffer.writeln('');
      });

      buffer.writeln('Total Critical Items: ${_selectedItemsForShare.length}');
      buffer.writeln('\n');
      buffer.writeln('Generated by MSIDC Project Management System');

      return buffer.toString();
    }

    bodyController.text = generateEmailBody();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.email,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Compose Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // To field
                  const Text(
                    'To',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: toController,
                    decoration: InputDecoration(
                      hintText: 'recipient@example.com',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
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
                      contentPadding: const EdgeInsets.all(12),
                      prefixIcon: Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Subject field
                  const Text(
                    'Subject',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      hintText: 'Email subject',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
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
                      contentPadding: const EdgeInsets.all(12),
                      prefixIcon: Icon(Icons.subject, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Body field
                  const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bodyController,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText: 'Email body',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
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
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _sendEmail(
                  toController.text,
                  subjectController.text,
                  bodyController.text,
                );
              },
              icon: const Icon(Icons.send, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              label: const Text(
                'Send Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmail(String to, String subject, String body) async {
    if (to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a recipient email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: to,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    try {
      // Try to launch with external application mode for desktop
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        // Clear selection after sending
        setState(() {
          _isSelectionMode = false;
          _selectedItemsForShare.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email client opened successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // If launching failed, show copy to clipboard option
        if (mounted) {
          _showEmailCopyDialog(to, subject, body);
        }
      }
    } catch (e) {
      // On error, show copy to clipboard option
      if (mounted) {
        _showEmailCopyDialog(to, subject, body);
      }
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showEmailCopyDialog(String to, String subject, String body) {
    final emailContent = '''To: $to

Subject: $subject

$body''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Email Client Not Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unable to open your default email client. You can copy the email content below and paste it into your email application manually.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      emailContent,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: emailContent));

                // Clear selection after copying
                setState(() {
                  _isSelectionMode = false;
                  _selectedItemsForShare.clear();
                });

                Navigator.of(context).pop();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email content copied to clipboard'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              label: const Text(
                'Copy to Clipboard',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
