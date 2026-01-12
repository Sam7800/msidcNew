import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'logger_service.dart';

/// File Storage Service - Manages file storage on device filesystem
class FileStorageService {
  static final FileStorageService instance = FileStorageService._init();
  final LoggerService _logger = LoggerService.instance;

  FileStorageService._init();

  /// Get base directory for attachments
  Future<Directory> getAttachmentsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final attachmentsDir =
        Directory(path.join(appDocDir.path, 'msidc_attachments'));
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
      await _logger.info('FileStorage',
          'Created attachments directory: ${attachmentsDir.path}');
    }
    return attachmentsDir;
  }

  /// Get directory for a specific project
  Future<Directory> getProjectDirectory(int projectId) async {
    final baseDir = await getAttachmentsDirectory();
    final projectDir =
        Directory(path.join(baseDir.path, 'project_$projectId'));
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }
    return projectDir;
  }

  /// Get directory for a specific work entry
  Future<Directory> getWorkEntryDirectory(
      int projectId, int workEntryId) async {
    final projectDir = await getProjectDirectory(projectId);
    final workEntryDir =
        Directory(path.join(projectDir.path, 'work_entry_$workEntryId'));
    if (!await workEntryDir.exists()) {
      await workEntryDir.create(recursive: true);
    }
    return workEntryDir;
  }

  /// Save file for a subsection
  /// Returns the saved file path
  Future<String> saveAttachment({
    required int projectId,
    required int workEntryId,
    required String category,
    required String subsectionName,
    required File sourceFile,
    required String fileType,
  }) async {
    try {
      await _logger.info('FileStorage',
          'Saving attachment for $category/$subsectionName');

      // Get work entry directory
      final workEntryDir =
          await getWorkEntryDirectory(projectId, workEntryId);

      // Generate safe file name
      final sanitizedSubsection =
          subsectionName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final extension =
          fileType.toLowerCase() == 'jpeg' ? 'jpg' : fileType.toLowerCase();
      final fileName = '${category}_$sanitizedSubsection.$extension';

      // Destination path
      final destinationPath = path.join(workEntryDir.path, fileName);

      // Copy file to destination
      final destinationFile = await sourceFile.copy(destinationPath);
      await _logger.info('FileStorage', 'File saved to: $destinationPath');

      return destinationFile.path;
    } catch (e) {
      await _logger.error('FileStorage', 'Failed to save attachment', e);
      throw Exception('Failed to save attachment: $e');
    }
  }

  /// Delete file from filesystem
  Future<bool> deleteAttachment(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        await _logger.info('FileStorage', 'Deleted file: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      await _logger.error('FileStorage', 'Failed to delete file', e);
      return false;
    }
  }

  /// Delete all files for a work entry
  Future<void> deleteWorkEntryFiles(int projectId, int workEntryId) async {
    try {
      final workEntryDir =
          await getWorkEntryDirectory(projectId, workEntryId);
      if (await workEntryDir.exists()) {
        await workEntryDir.delete(recursive: true);
        await _logger.info(
            'FileStorage', 'Deleted work entry directory');
      }
    } catch (e) {
      await _logger.error(
          'FileStorage', 'Failed to delete work entry files', e);
    }
  }

  /// Delete all files for a project
  Future<void> deleteProjectFiles(int projectId) async {
    try {
      final projectDir = await getProjectDirectory(projectId);
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
        await _logger.info('FileStorage', 'Deleted project directory');
      }
    } catch (e) {
      await _logger.error(
          'FileStorage', 'Failed to delete project files', e);
    }
  }

  /// Get total storage used by attachments (in bytes)
  Future<int> getTotalStorageUsed() async {
    try {
      final baseDir = await getAttachmentsDirectory();
      int totalSize = 0;

      await for (var entity
          in baseDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      await _logger.error('FileStorage', 'Failed to calculate storage', e);
      return 0;
    }
  }

  /// Clean up orphaned files (files without database records)
  Future<int> cleanupOrphanedFiles(List<String> validFilePaths) async {
    try {
      final baseDir = await getAttachmentsDirectory();
      int deletedCount = 0;

      await for (var entity
          in baseDir.list(recursive: true, followLinks: false)) {
        if (entity is File && !validFilePaths.contains(entity.path)) {
          await entity.delete();
          deletedCount++;
        }
      }

      await _logger.info(
          'FileStorage', 'Cleaned up $deletedCount orphaned files');
      return deletedCount;
    } catch (e) {
      await _logger.error(
          'FileStorage', 'Failed to cleanup orphaned files', e);
      return 0;
    }
  }

  /// Format bytes to human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
