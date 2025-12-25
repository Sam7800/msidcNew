import 'dart:io';
import 'package:excel/excel.dart';

/// Debug service to inspect Excel file structure
class ExcelDebugService {
  /// Inspect an Excel file and print its structure
  static Future<void> inspectExcelFile(String filePath) async {
    try {
      print('\n=== EXCEL FILE INSPECTION ===');
      print('File: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        print('ERROR: File does not exist!');
        return;
      }

      final bytes = await file.readAsBytes();
      print('File size: ${bytes.length} bytes');

      final excel = Excel.decodeBytes(bytes);
      print('Total sheets: ${excel.tables.keys.length}');
      print('');

      for (var sheetName in excel.tables.keys) {
        final sheet = excel.tables[sheetName];
        if (sheet == null) continue;

        print('--- Sheet: "$sheetName" ---');
        print('Total rows: ${sheet.rows.length}');

        if (sheet.rows.isNotEmpty) {
          print('Header row (first row):');
          final headerRow = sheet.rows[0];
          for (var i = 0; i < headerRow.length && i < 10; i++) {
            final cell = headerRow[i];
            if (cell?.value != null) {
              print('  Column $i: ${cell!.value}');
            }
          }

          if (sheet.rows.length > 1) {
            print('Sample data row (second row):');
            final dataRow = sheet.rows[1];
            for (var i = 0; i < dataRow.length && i < 10; i++) {
              final cell = dataRow[i];
              if (cell?.value != null) {
                print('  Column $i: ${cell!.value} (${cell.value.runtimeType})');
              }
            }
          }
        }
        print('');
      }

      print('=== END INSPECTION ===\n');
    } catch (e, stackTrace) {
      print('ERROR inspecting file: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
