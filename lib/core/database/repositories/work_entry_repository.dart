import 'package:sqflite/sqflite.dart';
import '../../../data/models/work_entry_data.dart';
import '../database_helper.dart';
import '../../services/logger_service.dart';

/// Work Entry Repository - Data access layer for work entry data (84 fields)
class WorkEntryRepository {
  final DatabaseHelper _dbHelper;
  final LoggerService _logger = LoggerService.instance;

  WorkEntryRepository(this._dbHelper);

  /// Get work entry by project ID (final data only)
  Future<WorkEntryData?> getWorkEntryByProjectId(int projectId) async {
    try {
      await _logger.info('WorkEntryRepo', 'Loading FINAL work entry for project $projectId');
      final db = await _dbHelper.database;
      final maps = await db.query(
        'work_entry',
        where: 'project_id = ? AND is_draft = 0',
        whereArgs: [projectId],
        orderBy: 'updated_at DESC',
        limit: 1,
      );
      if (maps.isEmpty) {
        await _logger.warning('WorkEntryRepo', 'No FINAL work entry found for project $projectId');
        return null;
      }
      await _logger.info('WorkEntryRepo', 'Found FINAL work entry for project $projectId');
      return WorkEntryData.fromMap(maps.first);
    } catch (e) {
      await _logger.error('WorkEntryRepo', 'Failed to load work entry', e);
      throw Exception('Failed to load work entry: $e');
    }
  }

  /// Get work entry by project ID - prioritizes draft, falls back to final
  Future<WorkEntryData?> getWorkEntryOrDraftByProjectId(int projectId) async {
    try {
      await _logger.info('WorkEntryRepo', 'Loading work entry (draft or final) for project $projectId');

      // Try to get draft first
      final draft = await getDraftByProjectId(projectId);
      if (draft != null) {
        await _logger.info('WorkEntryRepo', 'Found DRAFT work entry for project $projectId');
        return draft;
      }

      // Fall back to final data
      await _logger.info('WorkEntryRepo', 'No draft found, trying final data');
      final finalData = await getWorkEntryByProjectId(projectId);
      if (finalData != null) {
        await _logger.info('WorkEntryRepo', 'Found FINAL work entry for project $projectId');
        return finalData;
      }

      await _logger.warning('WorkEntryRepo', 'No work entry data found for project $projectId');
      return null;
    } catch (e) {
      await _logger.error('WorkEntryRepo', 'Failed to load work entry or draft', e);
      throw Exception('Failed to load work entry or draft: $e');
    }
  }

  /// Get draft work entry by project ID
  Future<WorkEntryData?> getDraftByProjectId(int projectId) async {
    try {
      await _logger.info('WorkEntryRepo', 'Loading DRAFT work entry for project $projectId');
      final db = await _dbHelper.database;
      final maps = await db.query(
        'work_entry',
        where: 'project_id = ? AND is_draft = 1',
        whereArgs: [projectId],
        orderBy: 'updated_at DESC',
        limit: 1,
      );
      if (maps.isEmpty) {
        await _logger.warning('WorkEntryRepo', 'No DRAFT found for project $projectId');
        return null;
      }
      final data = WorkEntryData.fromMap(maps.first);
      await _logger.info('WorkEntryRepo', 'Found DRAFT (ID: ${data.id}) with DPR: ${data.dprSection.length} fields, Work: ${data.workSection.length} fields, PMS: ${data.pmsSection.length} fields');
      return data;
    } catch (e) {
      await _logger.error('WorkEntryRepo', 'Failed to load draft work entry', e);
      throw Exception('Failed to load draft work entry: $e');
    }
  }

  /// Insert work entry
  Future<int> insertWorkEntry(WorkEntryData workEntry) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        'work_entry',
        workEntry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert work entry: $e');
    }
  }

  /// Update work entry
  Future<int> updateWorkEntry(WorkEntryData workEntry) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'work_entry',
        workEntry.toMap(),
        where: 'id = ?',
        whereArgs: [workEntry.id],
      );
    } catch (e) {
      throw Exception('Failed to update work entry: $e');
    }
  }

  /// Save draft
  Future<int> saveDraft(WorkEntryData workEntry) async {
    try {
      await _logger.info('WorkEntryRepo', 'Saving draft for project ${workEntry.projectId}');
      await _logger.info('WorkEntryRepo', 'Draft data - DPR fields: ${workEntry.dprSection.length}, Work fields: ${workEntry.workSection.length}, PMS fields: ${workEntry.pmsSection.length}');

      final draft = workEntry.copyWith(isDraft: true);
      final db = await _dbHelper.database;

      // Delete existing draft for this project
      final deletedCount = await db.delete(
        'work_entry',
        where: 'project_id = ? AND is_draft = 1',
        whereArgs: [workEntry.projectId],
      );
      await _logger.info('WorkEntryRepo', 'Deleted $deletedCount existing drafts');

      // Insert new draft
      final id = await db.insert(
        'work_entry',
        draft.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _logger.info('WorkEntryRepo', 'Draft saved successfully with ID: $id');
      return id;
    } catch (e) {
      await _logger.error('WorkEntryRepo', 'Failed to save draft', e);
      throw Exception('Failed to save draft: $e');
    }
  }

  /// Publish draft (convert to final)
  Future<int> publishDraft(int projectId) async {
    try {
      final db = await _dbHelper.database;

      // Get draft
      final draft = await getDraftByProjectId(projectId);
      if (draft == null) {
        throw Exception('No draft found');
      }

      // Delete existing final version
      await db.delete(
        'work_entry',
        where: 'project_id = ? AND is_draft = 0',
        whereArgs: [projectId],
      );

      // Convert draft to final
      final publishedEntry = draft.copyWith(isDraft: false);
      await db.insert(
        'work_entry',
        publishedEntry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Delete draft
      return await db.delete(
        'work_entry',
        where: 'id = ?',
        whereArgs: [draft.id],
      );
    } catch (e) {
      throw Exception('Failed to publish draft: $e');
    }
  }

  /// Delete work entry
  Future<int> deleteWorkEntry(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'work_entry',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete work entry: $e');
    }
  }

  /// Delete all work entries for a project
  Future<int> deleteAllByProjectId(int projectId) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'work_entry',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
    } catch (e) {
      throw Exception('Failed to delete work entries: $e');
    }
  }

  /// Get all work entries
  Future<List<WorkEntryData>> getAllWorkEntries() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'work_entry',
        where: 'is_draft = 0',
      );
      return maps.map((map) => WorkEntryData.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load all work entries: $e');
    }
  }

  /// Get completion statistics
  Future<Map<String, dynamic>> getCompletionStatistics() async {
    try {
      final allEntries = await getAllWorkEntries();
      if (allEntries.isEmpty) {
        return {
          'total': 0,
          'averageCompletion': 0.0,
          'dprCompletion': 0.0,
          'workCompletion': 0.0,
          'pmsCompletion': 0.0,
        };
      }

      final completions = allEntries.map((e) => e.getCompletionPercentage()).toList();
      final dprCompletions = allEntries.map((e) => e.getSectionCompletion('dpr')).toList();
      final workCompletions = allEntries.map((e) => e.getSectionCompletion('work')).toList();
      final pmsCompletions = allEntries.map((e) => e.getSectionCompletion('pms')).toList();

      return {
        'total': allEntries.length,
        'averageCompletion': completions.reduce((a, b) => a + b) / completions.length,
        'dprCompletion': dprCompletions.reduce((a, b) => a + b) / dprCompletions.length,
        'workCompletion': workCompletions.reduce((a, b) => a + b) / workCompletions.length,
        'pmsCompletion': pmsCompletions.reduce((a, b) => a + b) / pmsCompletions.length,
      };
    } catch (e) {
      throw Exception('Failed to get completion statistics: $e');
    }
  }
}
