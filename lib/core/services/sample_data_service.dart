import '../database/database_helper.dart';
import '../../data/models/project.dart';

/// Service to generate sample data for testing
class SampleDataService {
  final DatabaseHelper _dbHelper;

  SampleDataService(this._dbHelper);

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

  /// Generate sample projects for all 5 categories
  Future<Map<String, dynamic>> generateSampleData() async {
    try {
      final db = await _dbHelper.database;
      int projectCount = 0;

      // Sample projects for each category
      final sampleProjects = [
        // Nashik Kumbhmela (1-8)
        {'srNo': 1, 'name': 'Dwarka Circle Development', 'category': 'Nashik Kumbhmela'},
        {'srNo': 2, 'name': 'Darshan Path Construction', 'category': 'Nashik Kumbhmela'},
        {'srNo': 3, 'name': 'Ghat Development Project', 'category': 'Nashik Kumbhmela'},
        {'srNo': 4, 'name': 'Ring Road UDD', 'category': 'Nashik Kumbhmela'},
        {'srNo': 5, 'name': 'Ring Road NHAI', 'category': 'Nashik Kumbhmela'},
        {'srNo': 6, 'name': 'Nashik Airport Expansion', 'category': 'Nashik Kumbhmela'},
        {'srNo': 7, 'name': 'Mining Corridor Development', 'category': 'Nashik Kumbhmela'},
        {'srNo': 8, 'name': 'Trimbak DP Road', 'category': 'Nashik Kumbhmela'},

        // HAM Projects (9-10)
        {'srNo': 9, 'name': 'HAM-2 Road Furniture', 'category': 'HAM Projects'},
        {'srNo': 10, 'name': 'HAM-3 10,000 Km Road Network', 'category': 'HAM Projects'},

        // Nagpur Works (11-24)
        {'srNo': 11, 'name': 'Nagpur Central Jail', 'category': 'Nagpur Works'},
        {'srNo': 12, 'name': 'Nagpur Vidhan Bhavan', 'category': 'Nagpur Works'},
        {'srNo': 13, 'name': 'PKV Stage I', 'category': 'Nagpur Works'},
        {'srNo': 14, 'name': 'PKV Stage II', 'category': 'Nagpur Works'},
        {'srNo': 15, 'name': 'Social Justice Works', 'category': 'Nagpur Works'},
        {'srNo': 16, 'name': 'CSN Surgical Building', 'category': 'Nagpur Works'},
        {'srNo': 17, 'name': 'Collector Office Complex', 'category': 'Nagpur Works'},
        {'srNo': 18, 'name': 'Ganesh Peth Market', 'category': 'Nagpur Works'},
        {'srNo': 19, 'name': 'MOR Bhavan', 'category': 'Nagpur Works'},
        {'srNo': 20, 'name': 'Market Site Development 1', 'category': 'Nagpur Works'},
        {'srNo': 21, 'name': 'Market Site Development 2', 'category': 'Nagpur Works'},
        {'srNo': 22, 'name': 'IMS Ajani', 'category': 'Nagpur Works'},
        {'srNo': 23, 'name': 'Kamal Chowk', 'category': 'Nagpur Works'},
        {'srNo': 24, 'name': 'MIHAN Development', 'category': 'Nagpur Works'},

        // NHAI Projects (25-28)
        {'srNo': 25, 'name': 'Pune Shirur Elevated Road', 'category': 'NHAI Projects'},
        {'srNo': 26, 'name': 'Talegaon Chakan Shikrapur Road', 'category': 'NHAI Projects'},
        {'srNo': 27, 'name': 'Hadapsar Yawat Road', 'category': 'NHAI Projects'},
        {'srNo': 28, 'name': 'Kalamboli Fly-over', 'category': 'NHAI Projects'},

        // Other Projects (29-34)
        {'srNo': 29, 'name': 'Dharashiv Medical College', 'category': 'Other Projects'},
        {'srNo': 30, 'name': 'Police Housing Complex', 'category': 'Other Projects'},
        {'srNo': 31, 'name': 'Savali Vihir Development', 'category': 'Other Projects'},
        {'srNo': 32, 'name': 'Akola Infrastructure', 'category': 'Other Projects'},
        {'srNo': 33, 'name': 'FCI Godown Construction', 'category': 'Other Projects'},
        {'srNo': 34, 'name': 'Cultural Department Complex', 'category': 'Other Projects'},
      ];

      // Insert sample projects
      for (var projectData in sampleProjects) {
        try {
          // Get category ID
          final categoryId = await _getCategoryIdByName(projectData['category'] as String);
          if (categoryId == null) {
            print('Warning: Category "${projectData['category']}" not found, skipping project ${projectData['srNo']}');
            continue;
          }

          await db.insert('projects', {
            'sr_no': projectData['srNo'],
            'name': projectData['name'],
            'category_id': categoryId,
            'broad_scope': 'Infrastructure development project for ${projectData['name']}',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          projectCount++;
        } catch (e) {
          print('Error inserting project ${projectData['srNo']}: $e');
        }
      }

      return {
        'success': true,
        'message': 'Sample data generated successfully',
        'projects': projectCount,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to generate sample data: ${e.toString()}',
      };
    }
  }

  /// Clear all data from database
  Future<void> clearAllData() async {
    try {
      final db = await _dbHelper.database;
      await db.delete('projects');
      await db.delete('dpr_data');
      await db.delete('work_data');
      await db.delete('monitoring_data');
      await db.delete('work_entry');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
