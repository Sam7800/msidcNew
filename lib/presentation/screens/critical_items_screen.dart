import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../providers/mock_data.dart';

/// Critical Items Screen - Shows all critical subsections
class CriticalItemsScreen extends StatefulWidget {
  final int? categoryId;
  final int? projectId;

  const CriticalItemsScreen({
    super.key,
    this.categoryId,
    this.projectId,
  });

  @override
  State<CriticalItemsScreen> createState() => _CriticalItemsScreenState();
}

class _CriticalItemsScreenState extends State<CriticalItemsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isTableView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getSubtitle() {
    if (widget.projectId != null) {
      return 'Single Project';
    } else if (widget.categoryId == null) {
      return 'All Projects';
    } else {
      return 'Category Projects';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get critical items based on context
    List<Map<String, dynamic>> criticalItems;
    if (widget.projectId != null) {
      criticalItems = MockData.getCriticalItemsByProject(widget.projectId);
    } else if (widget.categoryId != null) {
      criticalItems = MockData.getCriticalItemsByCategory(widget.categoryId);
    } else {
      criticalItems = MockData.criticalItems;
    }

    // Filter by search query
    final filtered = _searchQuery.isEmpty
        ? criticalItems
        : criticalItems.where((item) {
            final projectName =
                item['project_name']?.toString().toLowerCase() ?? '';
            final subsectionName =
                item['subsection_name']?.toString().toLowerCase() ?? '';
            final category = item['category']?.toString().toLowerCase() ?? '';
            return projectName.contains(_searchQuery) ||
                subsectionName.contains(_searchQuery) ||
                category.contains(_searchQuery);
          }).toList();

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
                  'Critical Activities',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getSubtitle(),
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
                    hintText: 'Search critical activities...',
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: AppColors.textSecondary),
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
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
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
        actions: [
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
                  color: !_isTableView
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Switch(
                  value: _isTableView,
                  onChanged: (value) {
                    setState(() {
                      _isTableView = value;
                    });
                  },
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.table_chart,
                  size: 16,
                  color: _isTableView
                      ? AppColors.primary
                      : AppColors.textTertiary,
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
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No critical subsections marked yet'
                        : 'No matching critical activities found',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _isTableView
              ? _buildTableView(filtered)
              : _buildListView(filtered),
    );
  }

  Widget _buildTableView(List<Map<String, dynamic>> items) {
    final bool showCategoryColumn = widget.projectId == null;

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
                if (showCategoryColumn)
                  const DataColumn(
                    label: Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                const DataColumn(
                  label: Text(
                    'Project',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Person Responsible',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Pending With Whom',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
              rows: items.map((item) {
                final projectCategoryName =
                    item['project_category_name'] as String? ?? 'Unknown';
                final projectName = item['project_name'] as String;
                final subsectionName = item['subsection_name'] as String;
                final personResponsible =
                    item['person_responsible'] as String? ?? '-';
                final pendingWith = item['pending_with'] as String? ?? '-';

                return DataRow(
                  cells: [
                    if (showCategoryColumn)
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            projectCategoryName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Text(
                          projectName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          subsectionName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          personResponsible,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          pendingWith,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
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

  Widget _buildListView(List<Map<String, dynamic>> items) {
    // Group by project
    final groupedByProject = <int, List<Map<String, dynamic>>>{};
    for (var item in items) {
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
        final projectCategoryColor =
            projectItems.first['project_category_color'] as String?;

        Color? categoryColor;
        if (projectCategoryColor != null) {
          try {
            categoryColor = Color(int.parse(
                projectCategoryColor.replaceFirst('#', '0xFF')));
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        projectName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${projectItems.length} Critical',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Critical Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: projectItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = projectItems[index];
                  final category = item['category'] as String;
                  final subsectionName = item['subsection_name'] as String;
                  final personResponsible =
                      item['person_responsible'] as String?;

                  Color categoryColor;
                  switch (category) {
                    case 'DPR':
                      categoryColor = const Color(0xFF3B82F6);
                      break;
                    case 'Work':
                      categoryColor = const Color(0xFF10B981);
                      break;
                    case 'PMS':
                      categoryColor = const Color(0xFF8B5CF6);
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
                            if (personResponsible != null &&
                                personResponsible.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(
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
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
