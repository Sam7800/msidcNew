import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';

/// Excel Import/Export Service
class ExcelService {
  final DatabaseHelper _dbHelper;

  ExcelService(this._dbHelper);

  /// Safely extract cell value, handling custom format errors
  dynamic _safeCellValue(Data? cell, {String context = ''}) {
    if (cell == null) return null;

    try {
      return cell.value;
    } catch (e) {
      print('Warning: Could not parse cell $context: $e');
      // Try to get string representation as fallback
      try {
        final strValue = cell.toString();
        return strValue.isNotEmpty ? strValue : null;
      } catch (e2) {
        print('Warning: Complete cell parse failure for $context');
        return null;
      }
    }
  }

  /// Import projects from Excel file
  Future<Map<String, dynamic>> importFromExcel() async {
    try {
      print('ExcelService: Starting file picker...');

      // Pick Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        dialogTitle: 'Select Excel file to import',
      );

      if (result == null || result.files.isEmpty) {
        print('ExcelService: No file selected');
        return {'success': false, 'message': 'No file selected'};
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        print('ExcelService: File path is null');
        return {'success': false, 'message': 'Could not access file'};
      }

      print('ExcelService: Selected file: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        print('ExcelService: File does not exist');
        return {'success': false, 'message': 'File does not exist'};
      }

      print('ExcelService: Reading file bytes...');
      final bytes = await file.readAsBytes();
      print('ExcelService: File size: ${bytes.length} bytes');

      // Wrap Excel decoding with specific error detection
      Excel? excel;
      try {
        print('ExcelService: Decoding Excel...');
        excel = Excel.decodeBytes(bytes);
        print('ExcelService: Found ${excel.tables.keys.length} sheets');
      } catch (e) {
        print('ExcelService: Excel decode error: $e');

        // Check if it's the custom numFmtId error
        if (e.toString().contains('custom numFmtId') ||
            e.toString().contains('numFmtId')) {
          return {
            'success': false,
            'message': 'Excel file has unsupported custom number formats',
            'errorType': 'CUSTOM_FORMAT',
            'instructions': 'This Excel file contains custom number formats that cannot be imported.\n\n'
                           'Please try one of these options:\n\n'
                           '1. Click "Import CSV Instead" below to import from CSV files\n'
                           '2. Open the Excel file in Google Sheets, then download as .xlsx\n'
                           '3. In Excel: File → Save As → Excel Workbook (.xlsx)',
          };
        }

        // Generic Excel error
        return {
          'success': false,
          'message': 'Failed to read Excel file: ${e.toString()}',
        };
      }

      int projectCount = 0;
      int dprCount = 0;
      int workCount = 0;
      int monitoringCount = 0;

      // Process each sheet
      for (var tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName];
        if (sheet == null) continue;

        final sheetName = tableName.toLowerCase();
        print('ExcelService: Processing sheet: $tableName (${sheet.rows.length} rows)');

        if (sheetName.contains('project')) {
          print('ExcelService: Importing projects from $tableName...');
          projectCount += await _importProjects(sheet);
          print('ExcelService: Imported $projectCount projects');
        } else if (sheetName.contains('dpr')) {
          print('ExcelService: Importing DPR data from $tableName...');
          dprCount += await _importDPR(sheet);
          print('ExcelService: Imported $dprCount DPR records');
        } else if (sheetName.contains('work')) {
          print('ExcelService: Importing work data from $tableName...');
          workCount += await _importWork(sheet);
          print('ExcelService: Imported $workCount work records');
        } else if (sheetName.contains('monitoring') || sheetName.contains('pms')) {
          print('ExcelService: Importing monitoring data from $tableName...');
          monitoringCount += await _importMonitoring(sheet);
          print('ExcelService: Imported $monitoringCount monitoring records');
        }
      }

      print('ExcelService: Import complete!');
      return {
        'success': true,
        'message': 'Import successful',
        'projects': projectCount,
        'dpr': dprCount,
        'work': workCount,
        'monitoring': monitoringCount,
      };
    } catch (e, stackTrace) {
      print('ExcelService: Import error: $e');
      print('ExcelService: Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Import failed: ${e.toString()}',
      };
    }
  }

  /// Export all data to Excel file
  Future<Map<String, dynamic>> exportToExcel() async {
    try {
      print('ExcelService: Starting export...');
      final excel = Excel.createExcel();

      // Export Projects
      await _exportProjects(excel);

      // Export DPR Data
      await _exportDPR(excel);

      // Export Work Data
      await _exportWork(excel);

      // Export Monitoring Data
      await _exportMonitoring(excel);

      // Remove default sheet
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filePath = '${directory.path}/MSIDC_Export_$timestamp.xlsx';

      print('ExcelService: Saving to $filePath');

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        print('ExcelService: Export successful!');
        return {
          'success': true,
          'message': 'Export successful',
          'path': filePath,
        };
      }

      return {
        'success': false,
        'message': 'Failed to generate Excel file',
      };
    } catch (e, stackTrace) {
      print('ExcelService: Export error: $e');
      print('ExcelService: Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Export failed: ${e.toString()}',
      };
    }
  }

  // Import methods
  Future<int> _importProjects(Sheet sheet) async {
    int count = 0;
    final db = await _dbHelper.database;

    // Skip header row (row 0)
    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      try {
        // Skip empty rows
        if (row.isEmpty) continue;

        final srNoCell = row[0];
        if (srNoCell?.value == null) continue;

        final srNo = int.tryParse(srNoCell!.value.toString()) ?? 0;
        if (srNo == 0) {
          print('Row $i: Invalid sr_no, skipping');
          continue;
        }

        final name = row.length > 1 && row[1]?.value != null
            ? row[1]!.value.toString()
            : 'Unnamed Project';
        final category = row.length > 2 && row[2]?.value != null
            ? row[2]!.value.toString()
            : 'Other Projects';
        final location = row.length > 3 && row[3]?.value != null
            ? row[3]!.value.toString()
            : 'Maharashtra';
        final status = row.length > 4 && row[4]?.value != null
            ? row[4]!.value.toString()
            : 'In Progress';
        final broadScope = row.length > 5 && row[5]?.value != null
            ? row[5]!.value.toString()
            : null;

        // Check if project already exists
        final existing = await db.query(
          'projects',
          where: 'sr_no = ?',
          whereArgs: [srNo],
        );

        final projectData = {
          'sr_no': srNo,
          'name': name,
          'category': category,
          'location': location,
          'status': status,
          'broad_scope': broadScope,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (existing.isEmpty) {
          await db.insert('projects', projectData);
          print('Inserted project #$srNo: $name');
        } else {
          await db.update(
            'projects',
            projectData,
            where: 'sr_no = ?',
            whereArgs: [srNo],
          );
          print('Updated project #$srNo: $name');
        }
        count++;
      } catch (e) {
        print('Error importing project row $i: $e');
      }
    }

    return count;
  }

  Future<int> _importDPR(Sheet sheet) async {
    int count = 0;
    final db = await _dbHelper.database;

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      try {
        if (row.isEmpty) continue;

        final projectIdCell = row[0];
        if (projectIdCell?.value == null) continue;

        final projectId = int.tryParse(projectIdCell!.value.toString()) ?? 0;
        if (projectId == 0) continue;

        // Check if DPR data already exists
        final existing = await db.query(
          'dpr_data',
          where: 'project_id = ?',
          whereArgs: [projectId],
        );

        final dprData = {
          'project_id': projectId,
          'broad_scope': row.length > 1 && row[1]?.value != null ? row[1]!.value.toString() : null,
          'bid_doc_dpr': row.length > 2 ? _parseExcelDate(row[2]?.value) : null,
          'invite': row.length > 3 ? _parseExcelDate(row[3]?.value) : null,
          'prebid': row.length > 4 ? _parseExcelDate(row[4]?.value) : null,
          'csd': row.length > 5 ? _parseExcelDate(row[5]?.value) : null,
          'bid_submit': row.length > 6 ? _parseExcelDate(row[6]?.value) : null,
          'work_order': row.length > 7 ? _parseExcelDate(row[7]?.value) : null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (existing.isEmpty) {
          await db.insert('dpr_data', dprData);
        } else {
          await db.update(
            'dpr_data',
            dprData,
            where: 'project_id = ?',
            whereArgs: [projectId],
          );
        }
        count++;
      } catch (e) {
        print('Error importing DPR row $i: $e');
      }
    }

    return count;
  }

  Future<int> _importWork(Sheet sheet) async {
    int count = 0;
    final db = await _dbHelper.database;

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      try {
        if (row.isEmpty) continue;

        final projectIdCell = row[0];
        if (projectIdCell?.value == null) continue;

        final projectId = int.tryParse(projectIdCell!.value.toString()) ?? 0;
        if (projectId == 0) continue;

        final existing = await db.query(
          'work_data',
          where: 'project_id = ?',
          whereArgs: [projectId],
        );

        final workData = {
          'project_id': projectId,
          'aa': row.length > 1 ? _parseExcelDate(row[1]?.value) : null,
          'dpr': row.length > 2 ? _parseExcelDate(row[2]?.value) : null,
          'ts': row.length > 3 ? _parseExcelDate(row[3]?.value) : null,
          'bid_doc': row.length > 4 ? _parseExcelDate(row[4]?.value) : null,
          'work_order': row.length > 5 ? _parseExcelDate(row[5]?.value) : null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (existing.isEmpty) {
          await db.insert('work_data', workData);
        } else {
          await db.update(
            'work_data',
            workData,
            where: 'project_id = ?',
            whereArgs: [projectId],
          );
        }
        count++;
      } catch (e) {
        print('Error importing Work row $i: $e');
      }
    }

    return count;
  }

  Future<int> _importMonitoring(Sheet sheet) async {
    int count = 0;
    final db = await _dbHelper.database;

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      try {
        if (row.isEmpty) continue;

        final projectIdCell = row[0];
        if (projectIdCell?.value == null) continue;

        final projectId = int.tryParse(projectIdCell!.value.toString()) ?? 0;
        if (projectId == 0) continue;

        final existing = await db.query(
          'monitoring_data',
          where: 'project_id = ?',
          whereArgs: [projectId],
        );

        final monitoringData = {
          'project_id': projectId,
          'agmnt_amount': row.length > 1 && row[1]?.value != null
              ? double.tryParse(row[1]!.value.toString())
              : null,
          'appointed_date': row.length > 2 ? _parseExcelDate(row[2]?.value) : null,
          'tender_period': row.length > 3 && row[3]?.value != null
              ? int.tryParse(row[3]!.value.toString())
              : null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (existing.isEmpty) {
          await db.insert('monitoring_data', monitoringData);
        } else {
          await db.update(
            'monitoring_data',
            monitoringData,
            where: 'project_id = ?',
            whereArgs: [projectId],
          );
        }
        count++;
      } catch (e) {
        print('Error importing Monitoring row $i: $e');
      }
    }

    return count;
  }

  // Export methods
  Future<void> _exportProjects(Excel excel) async {
    final sheet = excel['Projects'];
    final db = await _dbHelper.database;

    // Headers with bold style
    final headers = [
      'Sr. No',
      'Name',
      'Category',
      'Location',
      'Status',
      'Broad Scope',
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Data
    final projects = await db.query('projects', orderBy: 'sr_no ASC');
    for (var project in projects) {
      sheet.appendRow([
        IntCellValue(project['sr_no'] as int),
        TextCellValue(project['name'] as String),
        TextCellValue(project['category'] as String),
        TextCellValue(project['location'] as String? ?? 'Maharashtra'),
        TextCellValue(project['status'] as String? ?? 'In Progress'),
        TextCellValue(project['broad_scope'] as String? ?? ''),
      ]);
    }
  }

  Future<void> _exportDPR(Excel excel) async {
    final sheet = excel['DPR'];
    final db = await _dbHelper.database;

    // Headers
    sheet.appendRow([
      TextCellValue('Project ID'),
      TextCellValue('Bid Doc DPR'),
      TextCellValue('Invite'),
      TextCellValue('Pre-bid'),
      TextCellValue('CSD'),
      TextCellValue('Bid Submit'),
      TextCellValue('Work Order'),
    ]);

    // Data
    final data = await db.query('dpr_data', orderBy: 'project_id ASC');
    for (var row in data) {
      sheet.appendRow([
        IntCellValue(row['project_id'] as int),
        TextCellValue(_formatDate(row['bid_doc_dpr'] as String?)),
        TextCellValue(_formatDate(row['invite'] as String?)),
        TextCellValue(_formatDate(row['prebid'] as String?)),
        TextCellValue(_formatDate(row['csd'] as String?)),
        TextCellValue(_formatDate(row['bid_submit'] as String?)),
        TextCellValue(_formatDate(row['work_order'] as String?)),
      ]);
    }
  }

  Future<void> _exportWork(Excel excel) async {
    final sheet = excel['Work'];
    final db = await _dbHelper.database;

    // Headers
    sheet.appendRow([
      TextCellValue('Project ID'),
      TextCellValue('AA'),
      TextCellValue('DPR'),
      TextCellValue('TS'),
      TextCellValue('Work Order'),
    ]);

    // Data
    final data = await db.query('work_data', orderBy: 'project_id ASC');
    for (var row in data) {
      sheet.appendRow([
        IntCellValue(row['project_id'] as int),
        TextCellValue(_formatDate(row['aa'] as String?)),
        TextCellValue(_formatDate(row['dpr'] as String?)),
        TextCellValue(_formatDate(row['ts'] as String?)),
        TextCellValue(_formatDate(row['work_order'] as String?)),
      ]);
    }
  }

  Future<void> _exportMonitoring(Excel excel) async {
    final sheet = excel['Monitoring'];
    final db = await _dbHelper.database;

    // Headers
    sheet.appendRow([
      TextCellValue('Project ID'),
      TextCellValue('Agreement Amount'),
      TextCellValue('Appointed Date'),
      TextCellValue('Tender Period'),
    ]);

    // Data
    final data = await db.query('monitoring_data', orderBy: 'project_id ASC');
    for (var row in data) {
      sheet.appendRow([
        IntCellValue(row['project_id'] as int),
        DoubleCellValue(row['agmnt_amount'] as double? ?? 0.0),
        TextCellValue(_formatDate(row['appointed_date'] as String?)),
        IntCellValue(row['tender_period'] as int? ?? 0),
      ]);
    }
  }

  // Helper methods
  String? _parseExcelDate(dynamic value) {
    if (value == null) return null;

    try {
      // Handle DateCellValue from Excel package
      if (value is DateCellValue) {
        return value.year != null
            ? DateTime(value.year!, value.month!, value.day!).toIso8601String()
            : null;
      }
      // Handle DateTime objects
      else if (value is DateTime) {
        return value.toIso8601String();
      }
      // Handle string dates
      else if (value is String || value is TextCellValue) {
        final dateStr = value.toString();
        final date = DateTime.tryParse(dateStr);
        return date?.toIso8601String();
      }
    } catch (e) {
      print('Error parsing date: $value - $e');
    }

    return null;
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';

    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
