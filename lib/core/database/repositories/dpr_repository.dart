import 'package:sqflite/sqflite.dart';
import '../../../data/models/dpr_data.dart';
import '../database_helper.dart';

/// DPR Repository - Data access layer for DPR data
class DPRRepository {
  final DatabaseHelper _dbHelper;

  DPRRepository(this._dbHelper);

  /// Get DPR data by project ID
  Future<DPRData?> getDPRByProjectId(int projectId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'dpr_data',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
      if (maps.isEmpty) return null;
      return DPRData.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to load DPR data: $e');
    }
  }

  /// Insert DPR data
  Future<int> insertDPR(DPRData dpr) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        'dpr_data',
        dpr.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert DPR data: $e');
    }
  }

  /// Insert multiple DPR records (for CSV import)
  Future<void> insertMultipleDPR(List<DPRData> dprList) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (final dpr in dprList) {
        batch.insert(
          'dpr_data',
          dpr.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to insert DPR data: $e');
    }
  }

  /// Update DPR data
  Future<int> updateDPR(DPRData dpr) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'dpr_data',
        dpr.toMap(),
        where: 'project_id = ?',
        whereArgs: [dpr.projectId],
      );
    } catch (e) {
      throw Exception('Failed to update DPR data: $e');
    }
  }

  /// Delete DPR data by project ID
  Future<int> deleteDPR(int projectId) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'dpr_data',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
    } catch (e) {
      throw Exception('Failed to delete DPR data: $e');
    }
  }

  /// Get all DPR data
  Future<List<DPRData>> getAllDPR() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('dpr_data');
      return maps.map((map) => DPRData.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load all DPR data: $e');
    }
  }

  /// Get DPR completion statistics
  Future<Map<String, dynamic>> getDPRStatistics() async {
    try {
      final allDPR = await getAllDPR();
      if (allDPR.isEmpty) {
        return {
          'total': 0,
          'averageCompletion': 0.0,
          'completed': 0,
          'inProgress': 0,
          'notStarted': 0,
        };
      }

      final completions = allDPR.map((dpr) => dpr.getCompletionPercentage()).toList();
      final averageCompletion = completions.reduce((a, b) => a + b) / completions.length;
      final completed = completions.where((c) => c >= 100).length;
      final inProgress = completions.where((c) => c > 0 && c < 100).length;
      final notStarted = completions.where((c) => c == 0).length;

      return {
        'total': allDPR.length,
        'averageCompletion': averageCompletion,
        'completed': completed,
        'inProgress': inProgress,
        'notStarted': notStarted,
      };
    } catch (e) {
      throw Exception('Failed to get DPR statistics: $e');
    }
  }
}
