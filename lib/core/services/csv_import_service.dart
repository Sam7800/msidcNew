import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../database/database_helper.dart';

/// CSV Import Service - Handles MSIDC CSV file format
class CsvImportService {
  final DatabaseHelper _dbHelper;

  CsvImportService(this._dbHelper);

  /// Import all data from CSV files
  Future<Map<String, dynamic>> importFromCsv() async {
    try {
      print('\n=== CSV IMPORT STARTED ===');

      // Pick multiple CSV files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: 'Select CSV files to import (DPR, Work, PMS)',
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        print('No files selected');
        return {'success': false, 'message': 'No files selected'};
      }

      int projectCount = 0;
      int dprFieldsCount = 0;
      int workFieldsCount = 0;
      int monitoringFieldsCount = 0;

      // Process each selected file
      for (var platformFile in result.files) {
        final filePath = platformFile.path;
        if (filePath == null) continue;

        print('\n--- Processing: ${platformFile.name} ---');

        final file = File(filePath);
        final csvString = await file.readAsString();
        final csvData = const CsvToListConverter().convert(csvString);

        if (csvData.length < 5) {
          print('File too short, skipping');
          continue;
        }

        final fileName = platformFile.name.toLowerCase();

        if (fileName.contains('dpr')) {
          final counts = await _importDprData(csvData);
          projectCount += counts['projects']!;
          dprFieldsCount += counts['fields']!;
        } else if (fileName.contains('work') && !fileName.contains('entry')) {
          final counts = await _importWorkData(csvData);
          workFieldsCount += counts['fields']!;
        } else if (fileName.contains('pms')) {
          final counts = await _importPmsData(csvData);
          monitoringFieldsCount += counts['fields']!;
        }
      }

      print('\n=== IMPORT COMPLETE ===');
      print('Projects created/updated: $projectCount');
      print('DPR records: $dprFieldsCount');
      print('Work records: $workFieldsCount');
      print('Monitoring records: $monitoringFieldsCount');

      return {
        'success': true,
        'message': 'Import successful',
        'projects': projectCount,
        'dpr': dprFieldsCount,
        'work': workFieldsCount,
        'monitoring': monitoringFieldsCount,
      };
    } catch (e, stackTrace) {
      print('\n!!! IMPORT ERROR !!!');
      print('Error: $e');
      print('Stack: $stackTrace');
      return {
        'success': false,
        'message': 'Import failed: ${e.toString()}',
      };
    }
  }

  /// Helper: Get category ID by name
  Future<int?> _getCategoryIdByName(String categoryName) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'categories',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [categoryName.trim()],
    );
    return result.isEmpty ? null : result.first['id'] as int;
  }

  /// Import DPR data - includes projects and DPR milestones
  Future<Map<String, int>> _importDprData(List<List<dynamic>> csvData) async {
    final db = await _dbHelper.database;
    int projectCount = 0;
    int dprCount = 0;
    String currentCategory = 'Other Projects';

    print('DPR file has ${csvData.length} rows');

    // Start from row 4 (skip headers)
    for (var i = 4; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.isEmpty || row.length < 2) continue;

      final firstCol = row[0].toString().trim();
      if (firstCol.isEmpty) continue;

      // Check if this is a category header (like "A", "B", "C")
      if (firstCol.length == 1 && RegExp(r'[A-Z]').hasMatch(firstCol)) {
        currentCategory = row[1].toString().trim();
        print('  Category: $currentCategory');
        continue;
      }

      // Try to parse as project number
      final srNo = int.tryParse(firstCol);
      if (srNo == null) continue;

      final projectName = row.length > 1 ? row[1].toString().trim() : 'Project $srNo';
      if (projectName.isEmpty) continue;

      // Get category ID
      final categoryId = await _getCategoryIdByName(currentCategory);
      if (categoryId == null) {
        print('  Warning: Category "$currentCategory" not found, skipping project $srNo');
        continue;
      }

      print('  [$srNo] $projectName → $currentCategory (ID: $categoryId)');

      // Create or update project
      final existing = await db.query('projects', where: 'sr_no = ?', whereArgs: [srNo]);

      final broadScope = row.length > 2 ? row[2].toString().trim() : null;

      final projectData = {
        'sr_no': srNo,
        'name': projectName,
        'category_id': categoryId,
        'broad_scope': broadScope.isEmpty ? null : broadScope,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      int projectId;
      if (existing.isEmpty) {
        projectId = await db.insert('projects', projectData);
        projectCount++;
      } else {
        projectId = existing[0]['id'] as int;
        await db.update('projects', projectData, where: 'id = ?', whereArgs: [projectId]);
      }

      // Create DPR data
      final dprData = {
        'project_id': projectId,
        'broad_scope': broadScope,
        'bid_doc_dpr': row.length > 3 ? _parseDate(row[3]) : null,
        'invite': row.length > 4 ? _parseDate(row[4]) : null,
        'prebid': row.length > 5 ? _parseDate(row[5]) : null,
        'csd': row.length > 6 ? _parseDate(row[6]) : null,
        'bid_submit': row.length > 7 ? _parseDate(row[7]) : null,
        'work_order': row.length > 8 ? _parseDate(row[8]) : null,
        'inception_report': row.length > 9 ? _parseDate(row[9]) : null,
        'survey': row.length > 10 ? _parseDate(row[10]) : null,
        'alignment_layout': row.length > 11 ? _parseDate(row[11]) : null,
        'draft_dpr': row.length > 12 ? _parseDate(row[12]) : null,
        'drawings': row.length > 13 ? _parseDate(row[13]) : null,
        'boq': row.length > 14 ? _parseDate(row[14]) : null,
        'env_clearance': row.length > 15 ? _parseDate(row[15]) : null,
        'cash_flow': row.length > 16 ? _parseDate(row[16]) : null,
        'la_proposal': row.length > 17 ? _parseDate(row[17]) : null,
        'utility_shifting': row.length > 18 ? _parseDate(row[18]) : null,
        'final_dpr': row.length > 19 ? _parseDate(row[19]) : null,
        'bid_doc_work': row.length > 20 ? _parseDate(row[20]) : null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final existingDpr = await db.query('dpr_data', where: 'project_id = ?', whereArgs: [projectId]);
      if (existingDpr.isEmpty) {
        await db.insert('dpr_data', dprData);
      } else {
        await db.update('dpr_data', dprData, where: 'project_id = ?', whereArgs: [projectId]);
      }
      dprCount++;
    }

    return {'projects': projectCount, 'fields': dprCount};
  }

  /// Import Work data
  Future<Map<String, int>> _importWorkData(List<List<dynamic>> csvData) async {
    final db = await _dbHelper.database;
    int workCount = 0;

    print('Work file has ${csvData.length} rows');

    // Start from row 4
    for (var i = 4; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.isEmpty || row.length < 2) continue;

      final firstCol = row[0].toString().trim();
      if (firstCol.isEmpty) continue;

      // Skip category headers
      if (firstCol.length == 1 && RegExp(r'[A-Z]').hasMatch(firstCol)) continue;

      final srNo = int.tryParse(firstCol);
      if (srNo == null) continue;

      // Find project
      final projects = await db.query('projects', where: 'sr_no = ?', whereArgs: [srNo]);
      if (projects.isEmpty) {
        print('  Warning: Project #$srNo not found for Work data');
        continue;
      }

      final projectId = projects[0]['id'] as int;
      print('  Work data for project #$srNo');

      final workData = {
        'project_id': projectId,
        'aa': row.length > 2 ? _parseDate(row[2]) : null,
        'dpr': row.length > 3 ? _parseDate(row[3]) : null,
        'ts': row.length > 4 ? _parseDate(row[4]) : null,
        'bid_doc': row.length > 5 ? _parseDate(row[5]) : null,
        'bid_invite': row.length > 6 ? _parseDate(row[6]) : null,
        'prebid': row.length > 7 ? _parseDate(row[7]) : null,
        'csd': row.length > 8 ? _parseDate(row[8]) : null,
        'bid_submit': row.length > 9 ? _parseDate(row[9]) : null,
        'fin_bid': row.length > 10 ? _parseDate(row[10]) : null,
        'loi': row.length > 11 ? _parseDate(row[11]) : null,
        'loa': row.length > 12 ? _parseDate(row[12]) : null,
        'pbg': row.length > 13 ? _parseDate(row[13]) : null,
        'agreement': row.length > 14 ? _parseDate(row[14]) : null,
        'work_order': row.length > 15 ? _parseDate(row[15]) : null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final existingWork = await db.query('work_data', where: 'project_id = ?', whereArgs: [projectId]);
      if (existingWork.isEmpty) {
        await db.insert('work_data', workData);
      } else {
        await db.update('work_data', workData, where: 'project_id = ?', whereArgs: [projectId]);
      }
      workCount++;
    }

    return {'projects': 0, 'fields': workCount};
  }

  /// Import PMS/Monitoring data
  Future<Map<String, int>> _importPmsData(List<List<dynamic>> csvData) async {
    final db = await _dbHelper.database;
    int monitoringCount = 0;

    print('PMS file has ${csvData.length} rows');

    // Start from row 4 (after sub-headers)
    for (var i = 4; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.isEmpty || row.length < 2) continue;

      final firstCol = row[0].toString().trim();
      if (firstCol.isEmpty) continue;

      // Skip category headers
      if (firstCol.length == 1 && RegExp(r'[A-Z]').hasMatch(firstCol)) continue;

      final srNo = int.tryParse(firstCol);
      if (srNo == null) continue;

      // Find project
      final projects = await db.query('projects', where: 'sr_no = ?', whereArgs: [srNo]);
      if (projects.isEmpty) {
        print('  Warning: Project #$srNo not found for PMS data');
        continue;
      }

      final projectId = projects[0]['id'] as int;
      print('  PMS data for project #$srNo');

      final monitoringData = {
        'project_id': projectId,
        'agreement_amount': row.length > 2 ? _parseDecimal(row[2]) : null,
        'appointed_date': row.length > 3 ? _parseDate(row[3]) : null,
        'tender_period': row.length > 4 ? _parseInt(row[4]) : null,
        'first_milestone': row.length > 5 ? row[5].toString() : null,
        'second_milestone': row.length > 6 ? row[6].toString() : null,
        'third_milestone': row.length > 7 ? row[7].toString() : null,
        'fourth_milestone': row.length > 8 ? row[8].toString() : null,
        'fifth_milestone': row.length > 9 ? row[9].toString() : null,
        'ld': row.length > 10 ? _parseDecimal(row[10]) : null,
        'cos': row.length > 11 ? _parseDecimal(row[11]) : null,
        'eot': row.length > 12 ? _parseInt(row[12]) : null,
        'cum_exp': row.length > 13 ? _parseDecimal(row[13]) : null,
        'final_bill': row.length > 14 ? _parseDecimal(row[14]) : null,
        'audit_para': row.length > 15 ? row[15].toString() : null,
        'replies': row.length > 16 ? row[16].toString() : null,
        'laq_lcq': row.length > 17 ? row[17].toString() : null,
        'tech_audit': row.length > 18 ? row[18].toString() : null,
        'rev_aa': row.length > 19 ? row[19].toString() : null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final existingMonitoring = await db.query('monitoring_data', where: 'project_id = ?', whereArgs: [projectId]);
      if (existingMonitoring.isEmpty) {
        await db.insert('monitoring_data', monitoringData);
      } else {
        await db.update('monitoring_data', monitoringData, where: 'project_id = ?', whereArgs: [projectId]);
      }
      monitoringCount++;
    }

    return {'projects': 0, 'fields': monitoringCount};
  }

  /// Parse date from various formats
  String? _parseDate(dynamic value) {
    if (value == null) return null;

    final str = value.toString().trim();
    if (str.isEmpty || str == '--') return null;

    try {
      // Handle various date formats: MM/DD/YYYY, DD.MM.YYYY, etc.
      final parts = str.split(RegExp(r'[/\.\-]'));
      if (parts.length >= 3) {
        // Assume MM/DD/YYYY or DD/MM/YYYY format
        int month = int.parse(parts[0]);
        int day = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        // Handle 2-digit years
        if (year < 100) year += 2000;

        // Swap if month > 12 (probably day/month format)
        if (month > 12) {
          final temp = month;
          month = day;
          day = temp;
        }

        return DateTime(year, month, day).toIso8601String();
      }
    } catch (e) {
      print('    Warning: Could not parse date "$str": $e');
    }

    return null;
  }

  /// Parse integer value
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty || str == '--') return null;
    return int.tryParse(str);
  }

  /// Parse decimal value
  double? _parseDecimal(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty || str == '--') return null;
    return double.tryParse(str);
  }
}
