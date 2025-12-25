import 'dart:io';
import 'package:excel/excel.dart';

void main() async {
  final filePath = '/Users/shubham/Desktop/Copy of MSIDC-PMS.xlsx';
  
  print('Reading file: $filePath');
  final file = File(filePath);
  final bytes = await file.readAsBytes();
  final excel = Excel.decodeBytes(bytes);
  
  print('\nFound ${excel.tables.keys.length} sheets:');
  for (var sheetName in excel.tables.keys) {
    final sheet = excel.tables[sheetName];
    print('\nSheet: "$sheetName" - ${sheet?.rows.length ?? 0} rows');
    
    if (sheet != null && sheet.rows.isNotEmpty) {
      print('  First row (headers):');
      final headers = sheet.rows[0];
      for (var i = 0; i < headers.length && i < 15; i++) {
        if (headers[i]?.value != null) {
          print('    [$i] ${headers[i]!.value}');
        }
      }
    }
  }
}
