import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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
  final Set<int> _expandedProjects = {}; // Track expanded project IDs
  List<Map<String, dynamic>>? _cachedCriticalItems; // Cache critical items
  List<int>? _cachedProjectIds; // Cache project IDs to detect changes
  final Map<String, bool> _toggledOffItems = {}; // Track items toggled off (key = "projectId_category_subsectionName")
  final Set<String> _selectedItemsForShare = {}; // Track items selected for sharing (key = "projectId_category_subsectionName")
  bool _isSelectionMode = false; // Whether we're in selection mode
  bool _isTableView = true; // Whether we're in table view mode - default to true

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
        title: Row(
          children: [
            Column(
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
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase().trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search critical items...',
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
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
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                ),
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
                    if (_isTableView) {
                      // In table view, show PDF options
                      _showPDFOptions();
                    } else {
                      // In list view, enable selection mode for email
                      setState(() {
                        _isSelectionMode = true;
                      });
                    }
                  },
                  icon: Icon(_isTableView ? Icons.picture_as_pdf : Icons.share),
                  tooltip: _isTableView ? 'Export as PDF' : 'Share critical items',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                // View Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.view_list,
                        size: 16,
                        color: !_isTableView ? AppColors.primary : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: _isTableView,
                        onChanged: (value) {
                          setState(() {
                            _isTableView = value;
                          });
                        },
                        activeThumbColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.table_chart,
                        size: 16,
                        color: _isTableView ? AppColors.primary : AppColors.textTertiary,
                      ),
                    ],
                  ),
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
      body: _buildCriticalItemsList(projectState),
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
    // If table view is enabled, show table
    if (_isTableView) {
      return _buildTableView(criticalItems);
    }

    // Otherwise, show list view
    // Apply search filter
    final filtered = criticalItems.where((item) {
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

  Widget _buildTableView(List<Map<String, dynamic>> criticalItems) {
    // Apply search filter
    final filtered = criticalItems.where((item) {
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

    // Determine columns based on context
    final bool showCategoryColumn = widget.projectId == null;
    final bool showProjectColumn = true;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 20,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.primary.withOpacity(0.05),
              ),
              headingRowHeight: 40,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 48,
              columnSpacing: 16,
              horizontalMargin: 10,
              border: TableBorder.all(
                color: AppColors.textSecondary,
                width: 1.5,
              ),
              dividerThickness: 1.5,
              columns: [
                // Category column - Project Category (only if not viewing a specific project)
                if (showCategoryColumn)
                  DataColumn(
                    label: Text(
                      'Category',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                // Project column
                if (showProjectColumn)
                  DataColumn(
                    label: Text(
                      'Project',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                // Activity column
                DataColumn(
                  label: Text(
                    'Activity',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Person Responsible column
                DataColumn(
                  label: Text(
                    'Person Responsible',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Pending With Whom column
                DataColumn(
                  label: Text(
                    'Pending With Whom',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
              rows: filtered.map((item) {
              final category = item['category'] as String; // DPR/Work/PMS
              final subsectionName = item['subsection_name'] as String;
              final projectName = item['project_name'] as String;
              final projectCategoryName = item['project_category_name'] as String? ?? 'Unknown';
              final projectCategoryColor = item['project_category_color'] as String?;
              final personResponsible = item['person_responsible'] as String? ?? '-';
              final pendingWith = item['pending_with'] as String? ?? '-';
              final projectId = item['project_id'] as int;

              // Project category color
              Color? categoryColor;
              if (projectCategoryColor != null) {
                try {
                  categoryColor = Color(int.parse(projectCategoryColor.replaceFirst('#', '0xFF')));
                } catch (e) {
                  categoryColor = null;
                }
              }

              final itemKey = '${projectId}_${category}_$subsectionName';
              final isToggledOff = _toggledOffItems[itemKey] ?? false;

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (isToggledOff) {
                      return AppColors.background.withOpacity(0.5);
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return AppColors.primary.withOpacity(0.05);
                    }
                    return null;
                  },
                ),
                cells: [
                  // Category cell - Project Category
                  if (showCategoryColumn)
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (categoryColor ?? AppColors.primary).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          projectCategoryName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: categoryColor ?? AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  // Project cell
                  if (showProjectColumn)
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Text(
                          projectName,
                          style: TextStyle(
                            fontSize: 13,
                            color: isToggledOff
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            decoration: isToggledOff
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  // Activity cell
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        subsectionName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isToggledOff
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: isToggledOff
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    onTap: () async {
                      // Navigate to detail screen
                      final projectState = ref.read(projectProvider);
                      final project = projectState.projects.firstWhere(
                        (p) => p.id == projectId,
                        orElse: () => throw Exception('Project not found'),
                      );

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
                        setState(() {
                          _cachedCriticalItems = null;
                          _cachedProjectIds = null;
                          _toggledOffItems.clear();
                        });
                      }
                    },
                  ),
                  // Person Responsible cell
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        personResponsible,
                        style: TextStyle(
                          fontSize: 13,
                          color: isToggledOff
                              ? AppColors.textTertiary
                              : AppColors.textSecondary,
                          decoration: isToggledOff
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  // Pending With Whom cell
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        pendingWith,
                        style: TextStyle(
                          fontSize: 13,
                          color: isToggledOff
                              ? AppColors.textTertiary
                              : AppColors.textSecondary,
                          decoration: isToggledOff
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            ),
          ),
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

      // Add project name, category, person responsible, and pending_with to each item
      for (var item in items) {
        String? personResponsible;
        String? pendingWith;

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

          // Find the pending_with field (usually ends with _pending_with)
          final pendingWithFieldKey = fields.firstWhere(
            (field) => field.endsWith('_pending_with'),
            orElse: () => '',
          );

          final sectionData = category == 'DPR'
              ? workEntry.dprSection
              : category == 'Work'
                  ? workEntry.workSection
                  : workEntry.pmsSection;

          if (personFieldKey.isNotEmpty) {
            personResponsible = sectionData[personFieldKey]?.toString();
          }

          if (pendingWithFieldKey.isNotEmpty) {
            pendingWith = sectionData[pendingWithFieldKey]?.toString();
          }
        }

        allCriticalItems.add({
          ...item,
          'project_name': project.name,
          'project_category_name': project.categoryName ?? 'Unknown',
          'project_category_color': project.categoryColor,
          'person_responsible': personResponsible,
          'pending_with': pendingWith,
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

  Future<pw.Document> _generatePDF(List<Map<String, dynamic>> items) async {
    final pdf = pw.Document();

    // Determine columns based on context
    final bool showCategoryColumn = widget.projectId == null;

    // Get title based on context
    final String title = widget.projectId != null
        ? 'Critical Items - Single Project'
        : widget.categoryId == null
            ? 'Critical Items - All Projects'
            : 'Critical Items - Category Projects';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'MSIDC Project Management System',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Generated on: ${DateTime.now().toString().split('.')[0]}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            // Table
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey400,
                width: 1,
              ),
              columnWidths: showCategoryColumn
                  ? {
                      0: const pw.FlexColumnWidth(1.5),
                      1: const pw.FlexColumnWidth(2.5),
                      2: const pw.FlexColumnWidth(3),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FlexColumnWidth(2),
                    }
                  : {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(3.5),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                    },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    if (showCategoryColumn)
                      _buildPDFHeaderCell('Category'),
                    _buildPDFHeaderCell('Project'),
                    _buildPDFHeaderCell('Activity'),
                    _buildPDFHeaderCell('Person Responsible'),
                    _buildPDFHeaderCell('Pending With Whom'),
                  ],
                ),
                // Data Rows
                ...items.map((item) {
                  final projectCategoryName = item['project_category_name'] as String? ?? 'Unknown';
                  final projectName = item['project_name'] as String;
                  final subsectionName = item['subsection_name'] as String;
                  final personResponsible = item['person_responsible'] as String? ?? '-';
                  final pendingWith = item['pending_with'] as String? ?? '-';

                  return pw.TableRow(
                    children: [
                      if (showCategoryColumn)
                        _buildPDFDataCell(projectCategoryName),
                      _buildPDFDataCell(projectName),
                      _buildPDFDataCell(subsectionName),
                      _buildPDFDataCell(personResponsible),
                      _buildPDFDataCell(pendingWith),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 24),
            // Footer
            pw.Text(
              'Total Critical Items: ${items.length}',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPDFHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildPDFDataCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 9,
        ),
      ),
    );
  }

  void _showPDFOptions() {
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
                  Icons.picture_as_pdf,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Export as PDF',
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
            children: [
              const Text(
                'Choose an option to export the critical items table',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Share/Print PDF Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _sharePDF();
                  },
                  icon: const Icon(Icons.share, size: 20),
                  label: const Text(
                    'Share/Print PDF',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Download PDF Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _downloadPDF();
                  },
                  icon: const Icon(Icons.download, size: 20),
                  label: const Text(
                    'Download PDF',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sharePDF() async {
    try {
      // Get filtered items
      final items = _getFilteredItems();

      if (items.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No items to export'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Generate PDF
      final pdf = await _generatePDF(items);

      // Share/Print PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPDF() async {
    try {
      // Get filtered items
      final items = _getFilteredItems();

      if (items.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No items to export'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Generate PDF
      final pdf = await _generatePDF(items);

      // Get downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().toString().replaceAll(':', '-').split('.')[0];
      final filename = 'Critical_Items_$timestamp.pdf';
      final file = File('${directory.path}/$filename');

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to Downloads: $filename'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                // Open the file using the default PDF viewer
                final Uri fileUri = Uri.file(file.path);
                if (await canLaunchUrl(fileUri)) {
                  await launchUrl(fileUri);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_cachedCriticalItems == null) return [];

    return _cachedCriticalItems!.where((item) {
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
