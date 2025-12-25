import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category.dart';
import '../../providers/category_provider.dart';
import '../../../theme/app_colors.dart';

/// Dialog for creating a new category
class CreateCategoryDialog extends ConsumerStatefulWidget {
  const CreateCategoryDialog({super.key});

  @override
  ConsumerState<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends ConsumerState<CreateCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedColor = '#0061FF'; // Default blue
  String _selectedIcon = 'folder'; // Default icon
  bool _isSubmitting = false;

  // Color palette with vibrant, modern colors
  final List<Map<String, String>> _colorOptions = [
    {'name': 'Blue', 'hex': '#0061FF'},
    {'name': 'Green', 'hex': '#00E676'},
    {'name': 'Red', 'hex': '#FF1744'},
    {'name': 'Orange', 'hex': '#FF9100'},
    {'name': 'Purple', 'hex': '#9C27B0'},
    {'name': 'Teal', 'hex': '#00BFA5'},
    {'name': 'Pink', 'hex': '#F50057'},
    {'name': 'Indigo', 'hex': '#3D5AFE'},
    {'name': 'Cyan', 'hex': '#00E5FF'},
    {'name': 'Lime', 'hex': '#C6FF00'},
    {'name': 'Amber', 'hex': '#FFC400'},
    {'name': 'Deep Purple', 'hex': '#651FFF'},
  ];

  // Icon options
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'folder', 'icon': Icons.folder},
    {'name': 'festival', 'icon': Icons.festival},
    {'name': 'handshake', 'icon': Icons.handshake},
    {'name': 'apartment', 'icon': Icons.apartment},
    {'name': 'route', 'icon': Icons.route},
    {'name': 'business', 'icon': Icons.business},
    {'name': 'engineering', 'icon': Icons.engineering},
    {'name': 'construction', 'icon': Icons.construction},
    {'name': 'account_balance', 'icon': Icons.account_balance},
    {'name': 'location_city', 'icon': Icons.location_city},
    {'name': 'domain', 'icon': Icons.domain},
    {'name': 'corporate_fare', 'icon': Icons.corporate_fare},
    {'name': 'factory', 'icon': Icons.factory},
    {'name': 'store', 'icon': Icons.store},
    {'name': 'workspaces', 'icon': Icons.workspaces},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final category = Category(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        colorHex: _selectedColor,
        iconName: _selectedIcon,
        displayOrder: 999, // Will be adjusted by user later if needed
      );

      final success = await ref.read(categoryProvider.notifier).addCategory(category);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${category.name}" created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final error = ref.read(categoryProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to create category'),
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

  Color _parseColor(String hex) {
    final hexColor = hex.replaceAll('#', '');
    return Color(int.parse('0xFF$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
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
                    _parseColor(_selectedColor),
                    _parseColor(_selectedColor).withOpacity(0.7),
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
                      _iconOptions.firstWhere(
                        (opt) => opt['name'] == _selectedIcon,
                        orElse: () => _iconOptions[0],
                      )['icon'] as IconData,
                      color: _parseColor(_selectedColor),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Create New Category',
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
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name *',
                          hintText: 'Enter category name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a category name';
                          }
                          if (value.trim().length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter category description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 24),

                      // Color picker
                      const Text(
                        'Color',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _colorOptions.map((color) {
                          final isSelected = _selectedColor == color['hex'];
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedColor = color['hex']!);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _parseColor(color['hex']!),
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.black,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: _parseColor(color['hex']!).withOpacity(0.4),
                                    blurRadius: isSelected ? 8 : 4,
                                    spreadRadius: isSelected ? 2 : 0,
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Icon picker
                      const Text(
                        'Icon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _iconOptions.map((iconOption) {
                          final isSelected = _selectedIcon == iconOption['name'];
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedIcon = iconOption['name'] as String);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _parseColor(_selectedColor).withOpacity(0.2)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(
                                        color: _parseColor(_selectedColor),
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Icon(
                                iconOption['icon'] as IconData,
                                color: isSelected
                                    ? _parseColor(_selectedColor)
                                    : Colors.grey[600],
                                size: 24,
                              ),
                            ),
                          );
                        }).toList(),
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
                      backgroundColor: _parseColor(_selectedColor),
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
                        : const Text('Create Category'),
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
