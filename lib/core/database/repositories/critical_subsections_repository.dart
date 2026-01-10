import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../services/logger_service.dart';

/// Critical Subsections Repository - Data access layer for critical subsections tracking
class CriticalSubsectionsRepository {
  final DatabaseHelper _dbHelper;
  final LoggerService _logger = LoggerService.instance;

  CriticalSubsectionsRepository(this._dbHelper);

  /// Get all critical subsections for a project
  Future<List<Map<String, dynamic>>> getCriticalSubsectionsByProjectId(
      int projectId) async {
    try {
      await _logger.info('CriticalSubsectionsRepo',
          'Loading critical subsections for project $projectId');
      final db = await _dbHelper.database;
      final maps = await db.query(
        'critical_subsections',
        where: 'project_id = ?',
        whereArgs: [projectId],
        orderBy: 'category, subsection_name',
      );
      await _logger.info('CriticalSubsectionsRepo',
          'Found ${maps.length} critical subsections for project $projectId');
      return maps;
    } catch (e) {
      await _logger.error(
          'CriticalSubsectionsRepo', 'Failed to load critical subsections', e);
      throw Exception('Failed to load critical subsections: $e');
    }
  }

  /// Get critical subsections by project and category
  Future<List<Map<String, dynamic>>>
      getCriticalSubsectionsByProjectAndCategory(
          int projectId, String category) async {
    try {
      await _logger.info('CriticalSubsectionsRepo',
          'Loading critical subsections for project $projectId, category $category');
      final db = await _dbHelper.database;
      final maps = await db.query(
        'critical_subsections',
        where: 'project_id = ? AND category = ?',
        whereArgs: [projectId, category],
        orderBy: 'subsection_name',
      );
      await _logger.info('CriticalSubsectionsRepo',
          'Found ${maps.length} critical subsections');
      return maps;
    } catch (e) {
      await _logger.error('CriticalSubsectionsRepo',
          'Failed to load critical subsections by category', e);
      throw Exception('Failed to load critical subsections by category: $e');
    }
  }

  /// Check if a subsection is marked as critical
  Future<bool> isCritical(
      int projectId, String category, String subsectionName) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'critical_subsections',
        where: 'project_id = ? AND category = ? AND subsection_name = ?',
        whereArgs: [projectId, category, subsectionName],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      await _logger.error(
          'CriticalSubsectionsRepo', 'Failed to check critical status', e);
      return false;
    }
  }

  /// Mark a subsection as critical
  Future<int> markAsCritical(
      int projectId, String category, String subsectionName) async {
    try {
      await _logger.info('CriticalSubsectionsRepo',
          'Marking subsection as critical: $subsectionName (project: $projectId, category: $category)');
      final db = await _dbHelper.database;
      final id = await db.insert(
        'critical_subsections',
        {
          'project_id': projectId,
          'category': category,
          'subsection_name': subsectionName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _logger.info('CriticalSubsectionsRepo',
          'Successfully marked subsection as critical (ID: $id)');
      return id;
    } catch (e) {
      await _logger.error('CriticalSubsectionsRepo',
          'Failed to mark subsection as critical', e);
      throw Exception('Failed to mark subsection as critical: $e');
    }
  }

  /// Remove critical marker from a subsection
  Future<int> removeCritical(
      int projectId, String category, String subsectionName) async {
    try {
      await _logger.info('CriticalSubsectionsRepo',
          'Removing critical marker from subsection: $subsectionName (project: $projectId, category: $category)');
      final db = await _dbHelper.database;
      final count = await db.delete(
        'critical_subsections',
        where: 'project_id = ? AND category = ? AND subsection_name = ?',
        whereArgs: [projectId, category, subsectionName],
      );
      await _logger.info('CriticalSubsectionsRepo',
          'Successfully removed critical marker ($count rows deleted)');
      return count;
    } catch (e) {
      await _logger.error('CriticalSubsectionsRepo',
          'Failed to remove critical marker', e);
      throw Exception('Failed to remove critical marker: $e');
    }
  }

  /// Toggle critical status for a subsection
  Future<bool> toggleCritical(
      int projectId, String category, String subsectionName) async {
    try {
      final isCriticalNow =
          await isCritical(projectId, category, subsectionName);
      if (isCriticalNow) {
        await removeCritical(projectId, category, subsectionName);
        return false; // Now not critical
      } else {
        await markAsCritical(projectId, category, subsectionName);
        return true; // Now critical
      }
    } catch (e) {
      await _logger.error(
          'CriticalSubsectionsRepo', 'Failed to toggle critical status', e);
      throw Exception('Failed to toggle critical status: $e');
    }
  }

  /// Delete all critical subsections for a project
  Future<int> deleteAllForProject(int projectId) async {
    try {
      await _logger.info('CriticalSubsectionsRepo',
          'Deleting all critical subsections for project $projectId');
      final db = await _dbHelper.database;
      final count = await db.delete(
        'critical_subsections',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
      await _logger.info('CriticalSubsectionsRepo',
          'Deleted $count critical subsections for project $projectId');
      return count;
    } catch (e) {
      await _logger.error('CriticalSubsectionsRepo',
          'Failed to delete critical subsections for project', e);
      throw Exception('Failed to delete critical subsections for project: $e');
    }
  }

  /// Get count of critical subsections for a project
  Future<int> getCriticalCount(int projectId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM critical_subsections WHERE project_id = ?',
        [projectId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      await _logger.error('CriticalSubsectionsRepo',
          'Failed to get critical count', e);
      return 0;
    }
  }

  /// Get count of critical subsections by category
  Future<Map<String, int>> getCriticalCountByCategory(int projectId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT category, COUNT(*) as count FROM critical_subsections WHERE project_id = ? GROUP BY category',
        [projectId],
      );
      return {
        for (var row in result) row['category'] as String: row['count'] as int
      };
    } catch (e) {
      await _logger.error('CriticalSubsectionsRepo',
          'Failed to get critical count by category', e);
      return {};
    }
  }
}
