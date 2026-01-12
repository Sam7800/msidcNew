import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../../data/models/work_entry_attachment.dart';
import '../database_helper.dart';
import '../../services/logger_service.dart';

/// Work Entry Attachment Repository - Data access layer for file attachments
class WorkEntryAttachmentRepository {
  final DatabaseHelper _dbHelper;
  final LoggerService _logger = LoggerService.instance;

  WorkEntryAttachmentRepository(this._dbHelper);

  /// Get all attachments for a work entry
  Future<List<WorkEntryAttachment>> getAttachmentsByWorkEntryId(
      int workEntryId) async {
    try {
      await _logger.info('AttachmentRepo',
          'Loading attachments for work entry $workEntryId');
      final db = await _dbHelper.database;
      final maps = await db.query(
        'work_entry_attachments',
        where: 'work_entry_id = ?',
        whereArgs: [workEntryId],
        orderBy: 'category, subsection_name',
      );
      final attachments =
          maps.map((map) => WorkEntryAttachment.fromMap(map)).toList();
      await _logger.info(
          'AttachmentRepo', 'Found ${attachments.length} attachments');
      return attachments;
    } catch (e) {
      await _logger.error('AttachmentRepo', 'Failed to load attachments', e);
      throw Exception('Failed to load attachments: $e');
    }
  }

  /// Get all attachments for a project
  Future<List<WorkEntryAttachment>> getAttachmentsByProjectId(
      int projectId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'work_entry_attachments',
        where: 'project_id = ?',
        whereArgs: [projectId],
        orderBy: 'uploaded_at DESC',
      );
      return maps.map((map) => WorkEntryAttachment.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load project attachments: $e');
    }
  }

  /// Get attachment for a specific subsection
  Future<WorkEntryAttachment?> getAttachmentForSubsection(
    int workEntryId,
    String category,
    String subsectionName,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'work_entry_attachments',
        where: 'work_entry_id = ? AND category = ? AND subsection_name = ?',
        whereArgs: [workEntryId, category, subsectionName],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return WorkEntryAttachment.fromMap(maps.first);
    } catch (e) {
      await _logger.error(
          'AttachmentRepo', 'Failed to load subsection attachment', e);
      return null;
    }
  }

  /// Insert attachment (enforces one file per subsection via UNIQUE constraint)
  Future<int> insertAttachment(WorkEntryAttachment attachment) async {
    try {
      await _logger.info('AttachmentRepo',
          'Inserting attachment: ${attachment.fileName} for ${attachment.category}/${attachment.subsectionName}');
      final db = await _dbHelper.database;
      final id = await db.insert(
        'work_entry_attachments',
        attachment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace existing file
      );
      await _logger.info('AttachmentRepo', 'Attachment saved with ID: $id');
      return id;
    } catch (e) {
      await _logger.error('AttachmentRepo', 'Failed to insert attachment', e);
      throw Exception('Failed to insert attachment: $e');
    }
  }

  /// Update attachment metadata
  Future<int> updateAttachment(WorkEntryAttachment attachment) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'work_entry_attachments',
        attachment.toMap(),
        where: 'id = ?',
        whereArgs: [attachment.id],
      );
    } catch (e) {
      throw Exception('Failed to update attachment: $e');
    }
  }

  /// Delete attachment (and optionally delete file from filesystem)
  Future<bool> deleteAttachment(int attachmentId,
      {bool deleteFile = true}) async {
    try {
      await _logger.info(
          'AttachmentRepo', 'Deleting attachment ID: $attachmentId');
      final db = await _dbHelper.database;

      // Get attachment to retrieve file path
      if (deleteFile) {
        final maps = await db.query(
          'work_entry_attachments',
          where: 'id = ?',
          whereArgs: [attachmentId],
          limit: 1,
        );
        if (maps.isNotEmpty) {
          final attachment = WorkEntryAttachment.fromMap(maps.first);
          final file = File(attachment.filePath);
          if (await file.exists()) {
            await file.delete();
            await _logger.info(
                'AttachmentRepo', 'Deleted file: ${attachment.filePath}');
          }
        }
      }

      // Delete database record
      final count = await db.delete(
        'work_entry_attachments',
        where: 'id = ?',
        whereArgs: [attachmentId],
      );
      await _logger.info('AttachmentRepo', 'Attachment deleted ($count rows)');
      return count > 0;
    } catch (e) {
      await _logger.error('AttachmentRepo', 'Failed to delete attachment', e);
      throw Exception('Failed to delete attachment: $e');
    }
  }

  /// Delete all attachments for a work entry
  Future<int> deleteAllForWorkEntry(int workEntryId,
      {bool deleteFiles = true}) async {
    try {
      final db = await _dbHelper.database;

      // Get all attachments to delete files
      if (deleteFiles) {
        final attachments = await getAttachmentsByWorkEntryId(workEntryId);
        for (var attachment in attachments) {
          final file = File(attachment.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      // Delete all database records
      return await db.delete(
        'work_entry_attachments',
        where: 'work_entry_id = ?',
        whereArgs: [workEntryId],
      );
    } catch (e) {
      throw Exception('Failed to delete work entry attachments: $e');
    }
  }

  /// Get attachment count for a work entry
  Future<int> getAttachmentCount(int workEntryId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM work_entry_attachments WHERE work_entry_id = ?',
        [workEntryId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get attachment counts by category
  Future<Map<String, int>> getAttachmentCountByCategory(
      int workEntryId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT category, COUNT(*) as count FROM work_entry_attachments WHERE work_entry_id = ? GROUP BY category',
        [workEntryId],
      );
      return {
        for (var row in result) row['category'] as String: row['count'] as int
      };
    } catch (e) {
      return {};
    }
  }

  /// Validate file before upload
  static Future<String?> validateFile(File file, String fileType) async {
    // Check if file exists
    if (!await file.exists()) {
      return 'File does not exist';
    }

    // Check file type
    if (!WorkEntryAttachment.isValidFileType(fileType)) {
      return 'Invalid file type. Only JPEG, PNG, and PDF are allowed';
    }

    // Check file size (max 10 MB)
    final fileSize = await file.length();
    const maxSize = 10 * 1024 * 1024; // 10 MB
    if (fileSize > maxSize) {
      return 'File size exceeds 10 MB limit';
    }

    // Check file extension matches type
    final extension = file.path.split('.').last.toUpperCase();
    if (fileType == 'JPEG' && !['JPG', 'JPEG'].contains(extension)) {
      return 'File extension does not match file type';
    }
    if (fileType == 'PNG' && extension != 'PNG') {
      return 'File extension does not match file type';
    }
    if (fileType == 'PDF' && extension != 'PDF') {
      return 'File extension does not match file type';
    }

    return null; // Valid
  }
}
