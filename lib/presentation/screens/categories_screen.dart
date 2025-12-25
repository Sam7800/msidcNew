import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../data/models/project.dart';
import '../../data/models/category.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../providers/category_provider.dart';
import '../../core/services/excel_service.dart';
import '../../core/services/csv_import_service.dart';
import '../../core/services/sample_data_service.dart';
import '../../core/services/excel_debug_service.dart';
import '../../core/database/database_helper.dart';
import '../widgets/dialogs/create_category_dialog.dart';
import 'projects_screen.dart';
import 'login_screen.dart';

/// Categories Screen - Main screen showing 5 project categories
///
/// Navigation: Login → Categories (HERE) → Projects → Details
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load project counts when screen loads
    Future.microtask(() {
      ref.read(projectProvider.notifier).loadAllProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importing data from Excel...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Ask user to choose import type
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog first

      final importType = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Import Type'),
          content: const Text('What type of file would you like to import?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'csv'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('CSV Files (Recommended)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'excel'),
              child: const Text('Excel File'),
            ),
          ],
        ),
      );

      if (importType == null) return;

      // Show loading again
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importing data...'),
                ],
              ),
            ),
          ),
        ),
      );

      print('\n\n>>> User clicked Import button - Type: $importType <<<');

      final Map<String, dynamic> result;
      if (importType == 'csv') {
        final csvService = CsvImportService(DatabaseHelper.instance);
        result = await csvService.importFromCsv();
      } else {
        final excelService = ExcelService(DatabaseHelper.instance);
        result = await excelService.importFromExcel();
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        // Refresh data
        ref.read(projectProvider.notifier).loadAllProjects();
        ref.refresh(projectCountByCategoryProvider);

        // Show success message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 12),
                Text('Import Successful'),
              ],
            ),
            content: Text(
              'Imported:\n'
              '• ${result['projects'] ?? 0} Projects\n'
              '• ${result['dpr'] ?? 0} DPR records\n'
              '• ${result['work'] ?? 0} Work records\n'
              '• ${result['monitoring'] ?? 0} Monitoring records',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Import failed - check if it's a custom format error
        final isCustomFormatError = result['errorType'] == 'CUSTOM_FORMAT';

        // Show error dialog with helpful actions
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: isCustomFormatError ? AppColors.warning : AppColors.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCustomFormatError ? 'Import Format Issue' : 'Import Failed',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result['message'] ?? 'Unknown error',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  if (result['instructions'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        result['instructions'],
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (isCustomFormatError)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Automatically trigger CSV import
                    _handleCsvImport();
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import CSV Instead'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if still open
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                SizedBox(width: 12),
                Text('Error'),
              ],
            ),
            content: Text('Import failed: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Handle CSV import as fallback when Excel import fails
  Future<void> _handleCsvImport() async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importing from CSV files...'),
                  SizedBox(height: 8),
                  Text(
                    'Select all CSV files (DPR, Work, PMS)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Execute CSV import
      final csvService = CsvImportService(DatabaseHelper.instance);
      final result = await csvService.importFromCsv();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show result
      if (result['success'] == true) {
        // Refresh data
        ref.read(projectProvider.notifier).loadAllProjects();
        ref.refresh(projectCountByCategoryProvider);

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                SizedBox(width: 12),
                Text('CSV Import Successful'),
              ],
            ),
            content: Text(
              'Successfully imported:\n\n'
              '✓ ${result['projects'] ?? 0} Projects\n'
              '✓ ${result['dpr'] ?? 0} DPR records\n'
              '✓ ${result['work'] ?? 0} Work records\n'
              '✓ ${result['monitoring'] ?? 0} Monitoring records',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      } else {
        // Show error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                SizedBox(width: 12),
                Text('CSV Import Failed'),
              ],
            ),
            content: Text(result['message'] ?? 'Unknown error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                SizedBox(width: 12),
                Text('Error'),
              ],
            ),
            content: Text('CSV import failed: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _handleExport() async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Exporting data to Excel...'),
                ],
              ),
            ),
          ),
        ),
      );

      final excelService = ExcelService(DatabaseHelper.instance);
      final result = await excelService.exportToExcel();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        // Show success message with file path
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 12),
                Text('Export Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data exported successfully!'),
                const SizedBox(height: 12),
                Text(
                  'File saved to:\n${result['path']}',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                SizedBox(width: 12),
                Text('Export Failed'),
              ],
            ),
            content: Text(result['message'] ?? 'Unknown error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if still open
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                SizedBox(width: 12),
                Text('Error'),
              ],
            ),
            content: Text('Export failed: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _handleGenerateSampleData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Sample Data'),
        content: const Text(
          'This will create 34 sample projects across all 5 categories.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (!mounted) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating sample data...'),
                ],
              ),
            ),
          ),
        ),
      );

      final sampleService = SampleDataService(DatabaseHelper.instance);
      final result = await sampleService.generateSampleData();

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        // Refresh data
        ref.read(projectProvider.notifier).loadAllProjects();
        ref.refresh(projectCountByCategoryProvider);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 12),
                Text('Success'),
              ],
            ),
            content: Text('Generated ${result['projects']} sample projects!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                SizedBox(width: 12),
                Text('Error'),
              ],
            ),
            content: Text(result['message'] ?? 'Unknown error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                SizedBox(width: 12),
                Text('Error'),
              ],
            ),
            content: Text('Failed to generate sample data: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(Constants.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  Future<void> _handleCreateCategory() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateCategoryDialog(),
    );

    if (result == true && mounted) {
      // Refresh categories
      ref.invalidate(categoriesWithCountsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesWithCountsAsync = ref.watch(categoriesWithCountsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        automaticallyImplyLeading: false, // No back button on main screen
        title: Row(
          children: [
            // App icon - functional, not decorative
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.engineering,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            // App name - left aligned, desktop style
            Text(
              Constants.appName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Properly sized action icons (24px)
          IconButton(
            icon: const Icon(Icons.create_new_folder, size: 24),
            tooltip: 'Create Category',
            onPressed: _handleCreateCategory,
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            tooltip: 'Generate Sample Data',
            onPressed: _handleGenerateSampleData,
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, size: 24),
            tooltip: 'Import from Excel',
            onPressed: _handleImport,
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 24),
            tooltip: 'Export to Excel',
            onPressed: _handleExport,
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            tooltip: Constants.tooltipRefresh,
            onPressed: () {
              ref.read(projectProvider.notifier).loadAllProjects();
              ref.refresh(projectCountByCategoryProvider);
            },
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 24),
            tooltip: Constants.tooltipLogout,
            onPressed: _handleLogout,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8), // Right padding
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
      ),
      body: CustomScrollView(
        slivers: [

          // Compact header with search - Claude.com style
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  // Title and subtitle - compact, left-aligned
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Browse and manage project categories',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Search bar - integrated into header row
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
                          hintText: 'Search categories...',
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
          ),

          // Categories Grid
          categoriesWithCountsAsync.when(
            data: (categoriesWithCounts) {
              // Filter categories based on search query
              final allCategories = categoriesWithCounts.keys.toList();
              final categories = _searchQuery.isEmpty
                  ? allCategories
                  : allCategories
                      .where((cat) => cat.name.toLowerCase().contains(_searchQuery))
                      .toList();

              // Show empty state if no categories match search
              if (categories.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
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
                          'No categories found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // Increased from 4 to make cards smaller
                    childAspectRatio: 1.1, // Slightly taller than wide for better proportions
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      final count = categoriesWithCounts[category] ?? 0;
                      return _CategoryCard(
                        category: category,
                        projectCount: count,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectsScreen(
                                category: category,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
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
                      'Error: $error',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}


/// Category Card Widget - Modern, minimal design
class _CategoryCard extends StatefulWidget {
  final Category category;
  final int projectCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.projectCount,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.category.getColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: categoryColor, // Always use category color
            width: _isHovered ? 2 : 1.5, // Thicker on hover
          ),
          // Subtle shadow with category color
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.08),
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
              padding: const EdgeInsets.all(16), // Reduced from 20
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with subtle colored background
                  Container(
                    width: 56, // Reduced from 64
                    height: 56, // Reduced from 64
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.category.getIcon(),
                      size: 28, // Reduced from 32
                      color: categoryColor,
                    ),
                  ),

                  const SizedBox(height: 12), // Reduced from 16

                  // Category Name
                  Text(
                    widget.category.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Reduced from 15
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Project Count Badge - Minimal design
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, // Reduced from 12
                      vertical: 5, // Reduced from 6
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 12, // Reduced from 14
                          color: categoryColor,
                        ),
                        const SizedBox(width: 4), // Reduced from 6
                        Text(
                          '${widget.projectCount}',
                          style: TextStyle(
                            fontSize: 12, // Reduced from 13
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
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
