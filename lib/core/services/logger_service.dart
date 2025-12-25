import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// LogLevel - Defines severity levels for logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// LoggerService - Comprehensive logging service for the application
///
/// Features:
/// - Multiple log levels (debug, info, warning, error, critical)
/// - Console and file logging
/// - Automatic log file rotation
/// - Structured log format with timestamps
/// - Separate logs for database, UI, and general operations
class LoggerService {
  static final LoggerService instance = LoggerService._init();

  LoggerService._init();

  File? _logFile;
  File? _dbLogFile;
  File? _errorLogFile;
  bool _initialized = false;
  final int _maxLogFileSize = 5 * 1024 * 1024; // 5MB

  /// Initialize the logger service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory logsDir = Directory(join(appDir.path, 'msidc_logs'));

      // Create logs directory if it doesn't exist
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // Initialize log files
      final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _logFile = File(join(logsDir.path, 'app_$dateStr.log'));
      _dbLogFile = File(join(logsDir.path, 'database_$dateStr.log'));
      _errorLogFile = File(join(logsDir.path, 'errors_$dateStr.log'));

      _initialized = true;

      // Log initialization
      await info('LoggerService', 'Logger initialized successfully');
      await info('LoggerService', 'Log directory: ${logsDir.path}');
      await info('LoggerService', 'App log: ${_logFile?.path}');
      await info('LoggerService', 'Database log: ${_dbLogFile?.path}');
      await info('LoggerService', 'Error log: ${_errorLogFile?.path}');
    } catch (e, stackTrace) {
      print('LoggerService: Failed to initialize: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Get the logs directory path
  Future<String?> getLogsDirectory() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      return join(appDir.path, 'msidc_logs');
    } catch (e) {
      return null;
    }
  }

  /// Log a debug message
  Future<void> debug(String tag, String message) async {
    await _log(LogLevel.debug, tag, message);
  }

  /// Log an info message
  Future<void> info(String tag, String message) async {
    await _log(LogLevel.info, tag, message);
  }

  /// Log a warning message
  Future<void> warning(String tag, String message) async {
    await _log(LogLevel.warning, tag, message);
  }

  /// Log an error message
  Future<void> error(String tag, String message, [dynamic error, StackTrace? stackTrace]) async {
    String fullMessage = message;
    if (error != null) {
      fullMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      fullMessage += '\nStack trace:\n$stackTrace';
    }
    await _log(LogLevel.error, tag, fullMessage);
  }

  /// Log a critical error message
  Future<void> critical(String tag, String message, [dynamic error, StackTrace? stackTrace]) async {
    String fullMessage = message;
    if (error != null) {
      fullMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      fullMessage += '\nStack trace:\n$stackTrace';
    }
    await _log(LogLevel.critical, tag, fullMessage);
  }

  /// Log database operations
  Future<void> database(String operation, String message, {dynamic error, StackTrace? stackTrace}) async {
    if (!_initialized) await initialize();

    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    String logMessage = '[$timestamp] [DB:$operation] $message';

    if (error != null) {
      logMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      logMessage += '\nStack trace:\n$stackTrace';
    }

    // Console output
    print('DB: $logMessage');

    // File output
    try {
      if (_dbLogFile != null) {
        await _rotateLogFileIfNeeded(_dbLogFile!);
        await _dbLogFile!.writeAsString('$logMessage\n', mode: FileMode.append, flush: true);
      }
    } catch (e) {
      print('LoggerService: Failed to write to database log: $e');
    }
  }

  /// Main logging method
  Future<void> _log(LogLevel level, String tag, String message) async {
    if (!_initialized) await initialize();

    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final String levelStr = level.toString().split('.').last.toUpperCase();
    final String logMessage = '[$timestamp] [$levelStr] [$tag] $message';

    // Console output with color coding (for terminal)
    String consoleMessage = logMessage;
    switch (level) {
      case LogLevel.debug:
        consoleMessage = '\x1B[36m$logMessage\x1B[0m'; // Cyan
        break;
      case LogLevel.info:
        consoleMessage = '\x1B[32m$logMessage\x1B[0m'; // Green
        break;
      case LogLevel.warning:
        consoleMessage = '\x1B[33m$logMessage\x1B[0m'; // Yellow
        break;
      case LogLevel.error:
        consoleMessage = '\x1B[31m$logMessage\x1B[0m'; // Red
        break;
      case LogLevel.critical:
        consoleMessage = '\x1B[35m$logMessage\x1B[0m'; // Magenta
        break;
    }
    print(consoleMessage);

    // File output
    try {
      if (_logFile != null) {
        await _rotateLogFileIfNeeded(_logFile!);
        await _logFile!.writeAsString('$logMessage\n', mode: FileMode.append, flush: true);
      }

      // Also write errors to error log
      if ((level == LogLevel.error || level == LogLevel.critical) && _errorLogFile != null) {
        await _rotateLogFileIfNeeded(_errorLogFile!);
        await _errorLogFile!.writeAsString('$logMessage\n', mode: FileMode.append, flush: true);
      }
    } catch (e) {
      print('LoggerService: Failed to write to log file: $e');
    }
  }

  /// Rotate log file if it exceeds maximum size
  Future<void> _rotateLogFileIfNeeded(File logFile) async {
    try {
      if (await logFile.exists()) {
        final int fileSize = await logFile.length();
        if (fileSize > _maxLogFileSize) {
          // Rotate by renaming with timestamp
          final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final String rotatedPath = '${logFile.path}.$timestamp';
          await logFile.rename(rotatedPath);

          // Create new log file
          await logFile.create();

          await info('LoggerService', 'Rotated log file: $rotatedPath');
        }
      }
    } catch (e) {
      print('LoggerService: Failed to rotate log file: $e');
    }
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory logsDir = Directory(join(appDir.path, 'msidc_logs'));

      if (await logsDir.exists()) {
        await logsDir.delete(recursive: true);
        await logsDir.create(recursive: true);

        // Reinitialize log files
        _initialized = false;
        await initialize();

        await info('LoggerService', 'All logs cleared');
      }
    } catch (e) {
      print('LoggerService: Failed to clear logs: $e');
    }
  }

  /// Get all log files
  Future<List<File>> getLogFiles() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory logsDir = Directory(join(appDir.path, 'msidc_logs'));

      if (await logsDir.exists()) {
        return logsDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.log'))
            .toList();
      }
    } catch (e) {
      await error('LoggerService', 'Failed to get log files', e);
    }
    return [];
  }

  /// Read log file content
  Future<String> readLogFile(File logFile) async {
    try {
      if (await logFile.exists()) {
        return await logFile.readAsString();
      }
    } catch (e) {
      await error('LoggerService', 'Failed to read log file: ${logFile.path}', e);
    }
    return '';
  }

  /// Get recent logs (last n lines)
  Future<String> getRecentLogs(int lineCount) async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        final List<String> lines = await _logFile!.readAsLines();
        final int startIndex = lines.length > lineCount ? lines.length - lineCount : 0;
        return lines.sublist(startIndex).join('\n');
      }
    } catch (e) {
      print('LoggerService: Failed to get recent logs: $e');
    }
    return '';
  }

  /// Get recent database logs (last n lines)
  Future<String> getRecentDatabaseLogs(int lineCount) async {
    try {
      if (_dbLogFile != null && await _dbLogFile!.exists()) {
        final List<String> lines = await _dbLogFile!.readAsLines();
        final int startIndex = lines.length > lineCount ? lines.length - lineCount : 0;
        return lines.sublist(startIndex).join('\n');
      }
    } catch (e) {
      print('LoggerService: Failed to get recent database logs: $e');
    }
    return '';
  }

  /// Get recent error logs (last n lines)
  Future<String> getRecentErrorLogs(int lineCount) async {
    try {
      if (_errorLogFile != null && await _errorLogFile!.exists()) {
        final List<String> lines = await _errorLogFile!.readAsLines();
        final int startIndex = lines.length > lineCount ? lines.length - lineCount : 0;
        return lines.sublist(startIndex).join('\n');
      }
    } catch (e) {
      print('LoggerService: Failed to get recent error logs: $e');
    }
    return '';
  }

  /// Export logs as a combined file
  Future<File?> exportLogs() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final File exportFile = File(join(appDir.path, 'msidc_logs_export_$timestamp.txt'));

      final StringBuffer content = StringBuffer();
      content.writeln('MSIDC Logs Export - $timestamp');
      content.writeln('=' * 80);
      content.writeln();

      // Add app logs
      if (_logFile != null && await _logFile!.exists()) {
        content.writeln('APPLICATION LOGS:');
        content.writeln('-' * 80);
        content.writeln(await _logFile!.readAsString());
        content.writeln();
      }

      // Add database logs
      if (_dbLogFile != null && await _dbLogFile!.exists()) {
        content.writeln('DATABASE LOGS:');
        content.writeln('-' * 80);
        content.writeln(await _dbLogFile!.readAsString());
        content.writeln();
      }

      // Add error logs
      if (_errorLogFile != null && await _errorLogFile!.exists()) {
        content.writeln('ERROR LOGS:');
        content.writeln('-' * 80);
        content.writeln(await _errorLogFile!.readAsString());
        content.writeln();
      }

      await exportFile.writeAsString(content.toString());
      await info('LoggerService', 'Logs exported to: ${exportFile.path}');

      return exportFile;
    } catch (e) {
      await error('LoggerService', 'Failed to export logs', e);
      return null;
    }
  }
}
