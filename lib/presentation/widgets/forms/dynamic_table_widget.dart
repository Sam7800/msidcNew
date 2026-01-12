import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Dynamic table widget that allows adding and removing rows
/// Similar to Jira/Monday.com tables
class DynamicTableWidget extends StatefulWidget {
  final String title;
  final List<String> columnHeaders;
  final int initialRows;

  const DynamicTableWidget({
    super.key,
    required this.title,
    required this.columnHeaders,
    this.initialRows = 1,
  });

  @override
  State<DynamicTableWidget> createState() => _DynamicTableWidgetState();
}

class _DynamicTableWidgetState extends State<DynamicTableWidget> {
  List<Map<int, TextEditingController>> rows = [];

  @override
  void initState() {
    super.initState();
    // Initialize with the specified number of rows
    for (int i = 0; i < widget.initialRows; i++) {
      _addRow();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var row in rows) {
      for (var controller in row.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addRow() {
    final Map<int, TextEditingController> newRow = {};
    for (int i = 0; i < widget.columnHeaders.length; i++) {
      newRow[i] = TextEditingController();
    }
    setState(() {
      rows.add(newRow);
    });
  }

  void _removeRow(int index) {
    // Dispose controllers for this row
    for (var controller in rows[index].values) {
      controller.dispose();
    }
    setState(() {
      rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Add Row Button
              IconButton(
                onPressed: _addRow,
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                tooltip: 'Add Row',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Column headers
                ...widget.columnHeaders.map((header) => Expanded(
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )),
                // Action column header
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Table Rows
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: rows.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No rows added. Click + to add a row.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rows.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                    itemBuilder: (context, rowIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // Data cells
                            ...List.generate(
                              widget.columnHeaders.length,
                              (colIndex) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: TextField(
                                    controller: rows[rowIndex][colIndex],
                                    decoration: InputDecoration(
                                      hintText: widget.columnHeaders[colIndex],
                                      hintStyle: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textTertiary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      isDense: true,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Delete button
                            IconButton(
                              onPressed: rows.length > 1
                                  ? () => _removeRow(rowIndex)
                                  : null,
                              icon: Icon(
                                Icons.delete_outline,
                                color: rows.length > 1
                                    ? AppColors.error
                                    : AppColors.textDisabled,
                                size: 20,
                              ),
                              tooltip: 'Remove Row',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
