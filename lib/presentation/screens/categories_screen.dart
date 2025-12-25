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
  @override
  void initState() {
    super.initState();
    // Load project counts when screen loads
    Future.microtask(() {
      ref.read(projectProvider.notifier).loadAllProjects();
    });
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.primaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 160,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  Constants.appName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.engineering,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.create_new_folder),
                  tooltip: 'Create Category',
                  onPressed: _handleCreateCategory,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Generate Sample Data',
                  onPressed: _handleGenerateSampleData,
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  tooltip: 'Import from Excel',
                  onPressed: _handleImport,
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export to Excel',
                  onPressed: _handleExport,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: Constants.tooltipRefresh,
                  onPressed: () {
                    ref.read(projectProvider.notifier).loadAllProjects();
                    ref.refresh(projectCountByCategoryProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: Constants.tooltipLogout,
                  onPressed: _handleLogout,
                ),
              ],
            ),

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Categories',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a category to view projects',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories Grid
            categoriesWithCountsAsync.when(
              data: (categoriesWithCounts) {
                final categories = categoriesWithCounts.keys.toList();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
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
      ),
    );
  }
}

/// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final Category category;
  final int projectCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.projectCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = category.getColor();

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [categoryColor, categoryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.getIcon(),
                  size: 32,
                  color: categoryColor,
                ),
              ),

              const SizedBox(height: 12),

              // Category Name (centered, up to 2 lines)
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Project Count Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$projectCount',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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
    );
  }
}
