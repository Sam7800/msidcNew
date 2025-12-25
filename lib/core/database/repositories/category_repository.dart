import '../../../data/models/category.dart';
import '../database_helper.dart';

/// Repository for category CRUD operations
class CategoryRepository {
  final DatabaseHelper _dbHelper;

  CategoryRepository(this._dbHelper);

  /// Get all categories (optionally including inactive)
  Future<List<Category>> getAllCategories({bool includeInactive = false}) async {
    try {
      final db = await _dbHelper.database;
      final whereClause = includeInactive ? null : 'is_active = ?';
      final whereArgs = includeInactive ? null : [1];

      final maps = await db.query(
        'categories',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'display_order ASC, name ASC',
      );

      return maps.map((map) => Category.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return Category.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get category by ID: $e');
    }
  }

  /// Get category by name
  Future<Category?> getCategoryByName(String name) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'categories',
        where: 'name = ?',
        whereArgs: [name.trim()],
      );

      if (maps.isEmpty) return null;
      return Category.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get category by name: $e');
    }
  }

  /// Insert new category
  Future<int> insertCategory(Category category) async {
    try {
      final db = await _dbHelper.database;

      // Check for duplicate name
      final isUnique = await isCategoryNameUnique(category.name);
      if (!isUnique) {
        throw Exception('Category name "${category.name}" already exists');
      }

      return await db.insert('categories', category.toMap());
    } catch (e) {
      throw Exception('Failed to insert category: $e');
    }
  }

  /// Update existing category
  Future<int> updateCategory(Category category) async {
    try {
      if (category.id == null) {
        throw Exception('Cannot update category without ID');
      }

      final db = await _dbHelper.database;

      // Check for duplicate name (excluding current category)
      final isUnique = await isCategoryNameUnique(
        category.name,
        excludeId: category.id,
      );
      if (!isUnique) {
        throw Exception('Category name "${category.name}" already exists');
      }

      return await db.update(
        'categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Soft delete category (set is_active = 0)
  Future<int> deleteCategory(int id) async {
    try {
      final db = await _dbHelper.database;

      // Check if category has projects
      final projectCount = await getCategoryProjectCount(id);
      if (projectCount > 0) {
        throw Exception(
          'Cannot delete category with $projectCount project(s). '
          'Please reassign or delete projects first.',
        );
      }

      // Soft delete
      return await db.update(
        'categories',
        {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Hard delete category (permanent removal)
  Future<int> hardDeleteCategory(int id) async {
    try {
      final db = await _dbHelper.database;

      // Check if category has projects
      final projectCount = await getCategoryProjectCount(id);
      if (projectCount > 0) {
        throw Exception(
          'Cannot delete category with $projectCount project(s). '
          'Please reassign or delete projects first.',
        );
      }

      return await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to hard delete category: $e');
    }
  }

  /// Get count of projects in a category
  Future<int> getCategoryProjectCount(int categoryId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM projects WHERE category_id = ?',
        [categoryId],
      );

      return result.first['count'] as int;
    } catch (e) {
      // If column doesn't exist yet (pre-migration), return 0
      if (e.toString().contains('no such column')) {
        return 0;
      }
      throw Exception('Failed to get category project count: $e');
    }
  }

  /// Check if category name is unique
  Future<bool> isCategoryNameUnique(String name, {int? excludeId}) async {
    try {
      final db = await _dbHelper.database;

      String whereClause = 'LOWER(name) = LOWER(?)';
      List<dynamic> whereArgs = [name.trim()];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final maps = await db.query(
        'categories',
        where: whereClause,
        whereArgs: whereArgs,
      );

      return maps.isEmpty;
    } catch (e) {
      throw Exception('Failed to check category name uniqueness: $e');
    }
  }

  /// Get categories with project counts
  Future<Map<Category, int>> getCategoriesWithCounts() async {
    try {
      final db = await _dbHelper.database;
      final result = <Category, int>{};

      final maps = await db.rawQuery('''
        SELECT
          c.*,
          COUNT(p.id) as project_count
        FROM categories c
        LEFT JOIN projects p ON c.id = p.category_id
        WHERE c.is_active = 1
        GROUP BY c.id
        ORDER BY c.display_order ASC, c.name ASC
      ''');

      for (final map in maps) {
        final category = Category.fromMap(map);
        final count = map['project_count'] as int;
        result[category] = count;
      }

      return result;
    } catch (e) {
      // If projects table doesn't have category_id yet (pre-migration), return empty map
      if (e.toString().contains('no such column')) {
        final categories = await getAllCategories();
        return {for (var cat in categories) cat: 0};
      }
      throw Exception('Failed to get categories with counts: $e');
    }
  }

  /// Reorder categories
  Future<void> reorderCategories(List<Category> categories) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var i = 0; i < categories.length; i++) {
        final category = categories[i];
        if (category.id != null) {
          batch.update(
            'categories',
            {
              'display_order': i,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [category.id],
          );
        }
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to reorder categories: $e');
    }
  }
}
