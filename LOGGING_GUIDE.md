# MSIDC Logging Guide

This document explains the comprehensive logging system implemented in the MSIDC application.

## Log File Locations

All application logs are stored in the following directory:

**macOS**: `/Users/YOUR_USERNAME/Library/Containers/com.example.msidc/Data/Documents/msidc_logs/`

The logs directory contains three types of log files:

1. **app_YYYY-MM-DD.log** - General application logs
2. **database_YYYY-MM-DD.log** - Database operation logs
3. **errors_YYYY-MM-DD.log** - Error logs only

## How to Access Logs

### Method 1: Via Terminal
```bash
# Navigate to logs directory
cd ~/Library/Containers/com.example.msidc/Data/Documents/msidc_logs/

# View all log files
ls -la

# View the latest app log
tail -f app_$(date +%Y-%m-%d).log

# View the latest database log
tail -f database_$(date +%Y-%m-% d).log

# View the latest error log
tail -f errors_$(date +%Y-%m-%d).log

# View recent logs (last 100 lines)
tail -n 100 app_$(date +%Y-%m-%d).log
```

### Method 2: Via Finder
1. Open Finder
2. Press `Cmd + Shift + G` (Go to Folder)
3. Paste: `~/Library/Containers/com.example.msidc/Data/Documents/msidc_logs/`
4. Press Enter
5. You'll see all log files organized by date

## Log File Format

Each log entry follows this format:
```
[TIMESTAMP] [LEVEL] [TAG] Message
```

**Example**:
```
[2025-12-26 00:01:48.247] [INFO] [SplashScreen] Initializing database
[2025-12-26 00:01:48.398] [DB:INIT] Database opened successfully at version 2
[2025-12-26 00:01:50.414] [ERROR] [DatabaseHelper] Failed to insert record
```

## Log Levels

The logging system supports five levels:

1. **DEBUG** (Cyan) - Detailed debugging information
2. **INFO** (Green) - General informational messages
3. **WARNING** (Yellow) - Warning messages
4. **ERROR** (Red) - Error messages with stack traces
5. **CRITICAL** (Magenta) - Critical errors that may cause application failure

## Database Logging

Database operations are logged separately with detailed information:

```
DB: [TIMESTAMP] [DB:OPERATION] Message
```

**Operations include**:
- **INIT** - Database initialization
- **CONFIGURE** - Database configuration
- **CREATE** - Table creation
- **MIGRATION** - Schema migrations
- **GET** - Database retrieval
- **CLOSE** - Database shutdown
- **DELETE** - Database deletion

**Example Database Logs**:
```
DB: [2025-12-26 00:01:48.247] [DB:INIT] Starting database initialization for: msidc.db
DB: [2025-12-26 00:01:48.264] [DB:INIT] Database path: /path/to/msidc.db
DB: [2025-12-26 00:01:48.391] [DB:CONFIGURE] Foreign key constraints enabled
DB: [2025-12-26 00:01:48.397] [DB:INIT] Database opened successfully at version 2
DB: [2025-12-26 00:01:48.398] [DB:CREATE] Creating categories table
```

## Log File Management

### Automatic Rotation

Log files are automatically rotated when they exceed 5MB in size. The old file is renamed with a timestamp:

```
app_2025-12-26.log.20251226_143022
```

### Manual Log Cleanup

To clear all logs programmatically, the `LoggerService` provides a `clearLogs()` method. However, manual deletion is also possible:

```bash
# Delete all logs
rm -rf ~/Library/Containers/com.example.msidc/Data/Documents/msidc_logs/*

# Delete logs older than 7 days
find ~/Library/Containers/com.example.msidc/Data/Documents/msidc_logs/ -name "*.log*" -mtime +7 -delete
```

## Exporting Logs

The logging system provides a method to export all logs as a combined file:

```dart
final exportedFile = await LoggerService.instance.exportLogs();
print('Logs exported to: ${exportedFile?.path}');
```

This creates a file named `msidc_logs_export_YYYYMMDD_HHMMSS.txt` in the application documents directory.

## Reading Logs Programmatically

```dart
import 'package:msidc/core/services/logger_service.dart';

final logger = LoggerService.instance;

// Get recent logs (last 100 lines)
final recentLogs = await logger.getRecentLogs(100);
print(recentLogs);

// Get recent database logs
final recentDbLogs = await logger.getRecentDatabaseLogs(100);
print(recentDbLogs);

// Get recent error logs
final recentErrors = await logger.getRecentErrorLogs(100);
print(recentErrors);

// Get all log files
final logFiles = await logger.getLogFiles();
for (final file in logFiles) {
  print('Log file: ${file.path}');
  final content = await logger.readLogFile(file);
  print(content);
}
```

## Troubleshooting with Logs

### Database Issues

If you encounter database errors, check the database log:

```bash
tail -n 200 database_$(date +%Y-%m-%d).log
```

Look for error messages containing:
- `Failed to initialize database`
- `Migration error`
- `Failed to create table`

### Application Crashes

Check the error log for stack traces:

```bash
tail -n 500 errors_$(date +%Y-%m-%d).log
```

### Performance Issues

Monitor the app log for slow operations:

```bash
grep -i "slow\|timeout\|delay" app_$(date +%Y-%m-%d).log
```

## Log Output While Running

When running the app via `flutter run`, logs are also output to the console in real-time with color coding:

```bash
flutter run -d macos
```

You'll see:
- Green text for INFO messages
- Yellow text for WARNING messages
- Red text for ERROR messages
- Cyan text for DEBUG messages
- Magenta text for CRITICAL messages

## Sharing Logs for Support

When reporting issues, you can share your logs:

1. **Export all logs**:
   ```dart
   final exportFile = await LoggerService.instance.exportLogs();
   ```

2. **Or manually copy the log directory**:
   ```bash
   cp -r ~/Library/Containers/com.example.msidc/Data/Documents/msidc_logs/ ~/Desktop/msidc_logs_backup/
   ```

3. **Compress the logs**:
   ```bash
   cd ~/Desktop
   zip -r msidc_logs.zip msidc_logs_backup/
   ```

## Best Practices

1. **Check logs regularly** during development to catch issues early
2. **Monitor database logs** after schema changes or migrations
3. **Export logs before clearing** them if you need to keep historical records
4. **Set up log rotation** on production to prevent disk space issues
5. **Use appropriate log levels** - don't log sensitive data at DEBUG level in production

## Privacy Considerations

The logging system does NOT log:
- User passwords
- API keys or tokens
- Personal identifiable information (PII)

If you need to share logs, review them first to ensure no sensitive data is included.

## Support

For issues related to logging or if you need help interpreting logs:
1. Check this guide first
2. Review the error logs for stack traces
3. Export and share logs when reporting issues
