import 'package:sqflite/sqflite.dart';
import '../../../data/models/work_data.dart';
import '../database_helper.dart';

/// Work Repository - Data access layer for work data
class WorkRepository {
  final DatabaseHelper _dbHelper;

  WorkRepository(this._dbHelper);

  /// Get work data by project ID
  Future<WorkData?> getWorkByProjectId(int projectId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'work_data',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
      if (maps.isEmpty) return null;
      return WorkData.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to load work data: $e');
    }
  }

  /// Insert work data
  Future<int> insertWork(WorkData work) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        'work_data',
        work.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert work data: $e');
    }
  }

  /// Insert multiple work records (for CSV import)
  Future<void> insertMultipleWork(List<WorkData> workList) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (final work in workList) {
        batch.insert(
          'work_data',
          work.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to insert work data: $e');
    }
  }

  /// Update work data
  Future<int> updateWork(WorkData work) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'work_data',
        work.toMap(),
        where: 'project_id = ?',
        whereArgs: [work.projectId],
      );
    } catch (e) {
      throw Exception('Failed to update work data: $e');
    }
  }

  /// Delete work data by project ID
  Future<int> deleteWork(int projectId) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'work_data',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
    } catch (e) {
      throw Exception('Failed to delete work data: $e');
    }
  }

  /// Get all work data
  Future<List<WorkData>> getAllWork() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('work_data');
      return maps.map((map) => WorkData.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load all work data: $e');
    }
  }
}
