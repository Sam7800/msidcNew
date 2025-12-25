import 'package:sqflite/sqflite.dart';
import '../../../data/models/monitoring_data.dart';
import '../database_helper.dart';

/// Monitoring Repository - Data access layer for monitoring/PMS data
class MonitoringRepository {
  final DatabaseHelper _dbHelper;

  MonitoringRepository(this._dbHelper);

  /// Get monitoring data by project ID
  Future<MonitoringData?> getMonitoringByProjectId(int projectId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'monitoring_data',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
      if (maps.isEmpty) return null;
      return MonitoringData.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to load monitoring data: $e');
    }
  }

  /// Insert monitoring data
  Future<int> insertMonitoring(MonitoringData monitoring) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        'monitoring_data',
        monitoring.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert monitoring data: $e');
    }
  }

  /// Insert multiple monitoring records (for CSV import)
  Future<void> insertMultipleMonitoring(List<MonitoringData> monitoringList) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (final monitoring in monitoringList) {
        batch.insert(
          'monitoring_data',
          monitoring.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to insert monitoring data: $e');
    }
  }

  /// Update monitoring data
  Future<int> updateMonitoring(MonitoringData monitoring) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'monitoring_data',
        monitoring.toMap(),
        where: 'project_id = ?',
        whereArgs: [monitoring.projectId],
      );
    } catch (e) {
      throw Exception('Failed to update monitoring data: $e');
    }
  }

  /// Delete monitoring data by project ID
  Future<int> deleteMonitoring(int projectId) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'monitoring_data',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
    } catch (e) {
      throw Exception('Failed to delete monitoring data: $e');
    }
  }

  /// Get all monitoring data
  Future<List<MonitoringData>> getAllMonitoring() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('monitoring_data');
      return maps.map((map) => MonitoringData.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load all monitoring data: $e');
    }
  }

  /// Get financial summary across all projects
  Future<Map<String, dynamic>> getFinancialSummary() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT
          SUM(agmnt_amount) as total_agreement,
          SUM(cum_exp) as total_expenditure,
          SUM(final_bill) as total_final_bill,
          COUNT(*) as project_count
        FROM monitoring_data
      ''');

      if (result.isEmpty) {
        return {
          'totalAgreement': 0.0,
          'totalExpenditure': 0.0,
          'totalFinalBill': 0.0,
          'projectCount': 0,
        };
      }

      final row = result.first;
      return {
        'totalAgreement': row['total_agreement'] ?? 0.0,
        'totalExpenditure': row['total_expenditure'] ?? 0.0,
        'totalFinalBill': row['total_final_bill'] ?? 0.0,
        'projectCount': row['project_count'] ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get financial summary: $e');
    }
  }
}
