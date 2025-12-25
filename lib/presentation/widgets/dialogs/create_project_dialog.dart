import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project.dart';
import '../../../data/models/category.dart';
import '../../providers/project_provider.dart';
import '../../providers/category_provider.dart';
import '../../../theme/app_colors.dart';

/// Dialog for creating a new project
class CreateProjectDialog extends ConsumerStatefulWidget {
  final Category? preselectedCategory;

  const CreateProjectDialog({
    super.key,
    this.preselectedCategory,
  });

  @override
  ConsumerState<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _srNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _broadScopeController = TextEditingController();

  Category? _selectedCategory;
  bool _isSubmitting = false;
  bool _isCheckingSrNo = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory;
    // Load categories
    Future.microtask(() {
      ref.read(categoryProvider.notifier).loadAllCategories();
    });
  }

  @override
  void dispose() {
    _srNoController.dispose();
    _nameController.dispose();
    _broadScopeController.dispose();
    super.dispose();
  }

  Future<bool> _checkSrNoUnique(int srNo) async {
    setState(() => _isCheckingSrNo = true);
    try {
      final project = await ref
          .read(projectProvider.notifier)
          .getProjectById(srNo); // Using srNo as temp check
      return project == null;
    } finally {
      if (mounted) {
        setState(() => _isCheckingSrNo = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedCategory!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final project = Project(
        srNo: int.parse(_srNoController.text.trim()),
        name: _nameController.text.trim(),
        categoryId: _selectedCategory!.id!,
        broadScope: _broadScopeController.text.trim().isEmpty
            ? null
            : _broadScopeController.text.trim(),
      );

      final success = await ref.read(projectProvider.notifier).addProject(project);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final error = ref.read(projectProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to create project'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.categories;

    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _selectedCategory?.getColor() ?? AppColors.primary,
                    (_selectedCategory?.getColor() ?? AppColors.primary)
                        .withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _selectedCategory?.getIcon() ?? Icons.folder,
                      color: _selectedCategory?.getColor() ?? AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Create New Project',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SR No field
                      TextFormField(
                        controller: _srNoController,
                        decoration: InputDecoration(
                          labelText: 'Serial Number (SR No) *',
                          hintText: 'Enter unique serial number',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.numbers),
                          suffixIcon: _isCheckingSrNo
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a serial number';
                          }
                          final srNo = int.tryParse(value.trim());
                          if (srNo == null || srNo <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Project Name *',
                          hintText: 'Enter project name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a project name';
                          }
                          if (value.trim().length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Category dropdown
                      DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  category.getIcon(),
                                  color: category.getColor(),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (category) {
                          setState(() => _selectedCategory = category);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Broad Scope field
                      TextFormField(
                        controller: _broadScopeController,
                        decoration: const InputDecoration(
                          labelText: 'Broad Scope (Optional)',
                          hintText: 'Enter project scope description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory?.getColor() ?? AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Create Project'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
