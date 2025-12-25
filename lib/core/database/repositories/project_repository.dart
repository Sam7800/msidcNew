import 'package:sqflite/sqflite.dart';
import '../../../data/models/project.dart';
import '../database_helper.dart';

/// Project Repository - Data access layer for projects
class ProjectRepository {
  final DatabaseHelper _dbHelper;

  ProjectRepository(this._dbHelper);

  /// Get all projects with category information
  Future<List<Project>> getAllProjects() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.rawQuery('''
        SELECT
          p.*,
          c.name AS category_name,
          c.color_hex AS category_color,
          c.icon_name AS category_icon
        FROM projects p
        LEFT JOIN categories c ON p.category_id = c.id
        ORDER BY p.sr_no ASC
      ''');
      return maps.map((map) => Project.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  /// Get projects by category ID with category information
  Future<List<Project>> getProjectsByCategoryId(int categoryId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.rawQuery('''
        SELECT
          p.*,
          c.name AS category_name,
          c.color_hex AS category_color,
          c.icon_name AS category_icon
        FROM projects p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.category_id = ?
        ORDER BY p.sr_no ASC
      ''', [categoryId]);
      return maps.map((map) => Project.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load projects by category: $e');
    }
  }

  /// Get project by ID with category information
  Future<Project?> getProjectById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.rawQuery('''
        SELECT
          p.*,
          c.name AS category_name,
          c.color_hex AS category_color,
          c.icon_name AS category_icon
        FROM projects p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.id = ?
      ''', [id]);
      if (maps.isEmpty) return null;
      return Project.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to load project: $e');
    }
  }

  /// Get project by serial number with category information
  Future<Project?> getProjectBySrNo(int srNo) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.rawQuery('''
        SELECT
          p.*,
          c.name AS category_name,
          c.color_hex AS category_color,
          c.icon_name AS category_icon
        FROM projects p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.sr_no = ?
      ''', [srNo]);
      if (maps.isEmpty) return null;
      return Project.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to load project by serial number: $e');
    }
  }

  /// Insert project
  Future<int> insertProject(Project project) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        'projects',
        project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert project: $e');
    }
  }

  /// Insert multiple projects (for CSV import)
  Future<void> insertProjects(List<Project> projects) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (final project in projects) {
        batch.insert(
          'projects',
          project.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to insert projects: $e');
    }
  }

  /// Update project
  Future<int> updateProject(Project project) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'projects',
        project.toMap(),
        where: 'id = ?',
        whereArgs: [project.id],
      );
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  /// Delete project
  Future<int> deleteProject(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'projects',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Get project count by category (returns category name -> count map)
  Future<Map<String, int>> getProjectCountByCategory() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT c.name AS category_name, COUNT(p.id) as count
        FROM categories c
        LEFT JOIN projects p ON c.id = p.category_id
        WHERE c.is_active = 1
        GROUP BY c.id, c.name
        ORDER BY c.display_order ASC
      ''');

      final counts = <String, int>{};
      for (final row in result) {
        counts[row['category_name'] as String] = row['count'] as int;
      }
      return counts;
    } catch (e) {
      throw Exception('Failed to get project counts: $e');
    }
  }

  /// Search projects by name with category information
  Future<List<Project>> searchProjects(String query) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.rawQuery('''
        SELECT
          p.*,
          c.name AS category_name,
          c.color_hex AS category_color,
          c.icon_name AS category_icon
        FROM projects p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.name LIKE ?
        ORDER BY p.sr_no ASC
      ''', ['%$query%']);
      return maps.map((map) => Project.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to search projects: $e');
    }
  }

  /// Check if projects table is empty
  Future<bool> isEmpty() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM projects');
      final count = Sqflite.firstIntValue(result) ?? 0;
      return count == 0;
    } catch (e) {
      throw Exception('Failed to check if projects empty: $e');
    }
  }

  /// Get total project count
  Future<int> getProjectCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM projects');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get project count: $e');
    }
  }
}
