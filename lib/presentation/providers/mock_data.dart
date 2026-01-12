import '../../data/models/category.dart';
import '../../data/models/project.dart';

/// Mock data provider - simulates database with dummy data
class MockData {
  // Mock categories
  static final List<Category> categories = [
    Category(
      id: 1,
      name: 'Nashik Kumbhmela',
      colorHex: '#3B82F6',
      iconName: 'festival',
    ),
    Category(
      id: 2,
      name: 'HAM Projects',
      colorHex: '#10B981',
      iconName: 'handshake',
    ),
    Category(
      id: 3,
      name: 'Nagpur Works',
      colorHex: '#EF4444',
      iconName: 'apartment',
    ),
    Category(
      id: 4,
      name: 'NHAI Projects',
      colorHex: '#F59E0B',
      iconName: 'route',
    ),
    Category(
      id: 5,
      name: 'Other Projects',
      colorHex: '#8B5CF6',
      iconName: 'business',
    ),
  ];

  // Mock projects
  static final List<Project> projects = [
    // Nashik Kumbhmela projects
    Project(
      id: 1,
      srNo: 1,
      name: 'Nashik Kumbhmela Infrastructure Development',
      categoryId: 1,
      broadScope: 'Development of infrastructure facilities for Kumbhmela event',
      status: 'In Progress',
      categoryName: 'Nashik Kumbhmela',
      categoryColor: '#3B82F6',
      categoryIcon: 'festival',
    ),
    Project(
      id: 2,
      srNo: 2,
      name: 'Nashik Water Supply Project',
      categoryId: 1,
      broadScope: 'Water supply infrastructure for Kumbhmela',
      status: 'In Progress',
      categoryName: 'Nashik Kumbhmela',
      categoryColor: '#3B82F6',
      categoryIcon: 'festival',
    ),
    Project(
      id: 3,
      srNo: 3,
      name: 'Nashik Road Network Expansion',
      categoryId: 1,
      broadScope: 'Road network development for event management',
      status: 'Completed',
      categoryName: 'Nashik Kumbhmela',
      categoryColor: '#3B82F6',
      categoryIcon: 'festival',
    ),

    // HAM Projects
    Project(
      id: 4,
      srNo: 9,
      name: 'HAM Highway Project - Phase 1',
      categoryId: 2,
      broadScope: 'Highway development under HAM model',
      status: 'In Progress',
      categoryName: 'HAM Projects',
      categoryColor: '#10B981',
      categoryIcon: 'handshake',
    ),
    Project(
      id: 5,
      srNo: 10,
      name: 'HAM Expressway Development',
      categoryId: 2,
      broadScope: 'Expressway construction under public-private partnership',
      status: 'In Progress',
      categoryName: 'HAM Projects',
      categoryColor: '#10B981',
      categoryIcon: 'handshake',
    ),

    // Nagpur Works
    Project(
      id: 6,
      srNo: 11,
      name: 'Nagpur Metro Rail Project',
      categoryId: 3,
      broadScope: 'Metro rail system development',
      status: 'In Progress',
      categoryName: 'Nagpur Works',
      categoryColor: '#EF4444',
      categoryIcon: 'apartment',
    ),
    Project(
      id: 7,
      srNo: 12,
      name: 'Nagpur Smart City Initiative',
      categoryId: 3,
      broadScope: 'Smart city infrastructure development',
      status: 'In Progress',
      categoryName: 'Nagpur Works',
      categoryColor: '#EF4444',
      categoryIcon: 'apartment',
    ),
    Project(
      id: 8,
      srNo: 13,
      name: 'Nagpur Ring Road Project',
      categoryId: 3,
      broadScope: 'Ring road construction around the city',
      status: 'Pending',
      categoryName: 'Nagpur Works',
      categoryColor: '#EF4444',
      categoryIcon: 'apartment',
    ),

    // NHAI Projects
    Project(
      id: 9,
      srNo: 25,
      name: 'NHAI Highway Corridor Development',
      categoryId: 4,
      broadScope: 'National highway corridor improvement',
      status: 'In Progress',
      categoryName: 'NHAI Projects',
      categoryColor: '#F59E0B',
      categoryIcon: 'route',
    ),
    Project(
      id: 10,
      srNo: 26,
      name: 'NHAI Bypass Road Construction',
      categoryId: 4,
      broadScope: 'Construction of bypass roads',
      status: 'In Progress',
      categoryName: 'NHAI Projects',
      categoryColor: '#F59E0B',
      categoryIcon: 'route',
    ),

    // Other Projects
    Project(
      id: 11,
      srNo: 29,
      name: 'Industrial Park Development',
      categoryId: 5,
      broadScope: 'Development of industrial infrastructure',
      status: 'In Progress',
      categoryName: 'Other Projects',
      categoryColor: '#8B5CF6',
      categoryIcon: 'business',
    ),
    Project(
      id: 12,
      srNo: 30,
      name: 'Tourism Infrastructure Project',
      categoryId: 5,
      broadScope: 'Tourism facility development',
      status: 'Pending',
      categoryName: 'Other Projects',
      categoryColor: '#8B5CF6',
      categoryIcon: 'business',
    ),
  ];

  // Mock critical items
  static final List<Map<String, dynamic>> criticalItems = [
    {
      'project_id': 1,
      'project_name': 'Nashik Kumbhmela Infrastructure Development',
      'project_category_name': 'Nashik Kumbhmela',
      'project_category_color': '#3B82F6',
      'category': 'DPR',
      'subsection_name': 'Land Acquisition Status',
      'person_responsible': 'CE Nashik',
      'pending_with': 'Collector Office',
      'created_at': '2024-01-15',
    },
    {
      'project_id': 1,
      'project_name': 'Nashik Kumbhmela Infrastructure Development',
      'project_category_name': 'Nashik Kumbhmela',
      'project_category_color': '#3B82F6',
      'category': 'Work',
      'subsection_name': 'Environmental Clearance',
      'person_responsible': 'Engineering',
      'pending_with': 'State Government',
      'created_at': '2024-01-10',
    },
    {
      'project_id': 4,
      'project_name': 'HAM Highway Project - Phase 1',
      'project_category_name': 'HAM Projects',
      'project_category_color': '#10B981',
      'category': 'PMS',
      'subsection_name': 'Tender Process Approval',
      'person_responsible': 'Tender',
      'pending_with': 'JMD',
      'created_at': '2024-01-12',
    },
    {
      'project_id': 6,
      'project_name': 'Nagpur Metro Rail Project',
      'project_category_name': 'Nagpur Works',
      'project_category_color': '#EF4444',
      'category': 'DPR',
      'subsection_name': 'Financial Approval',
      'person_responsible': 'Fin Adv',
      'pending_with': 'MD',
      'created_at': '2024-01-08',
    },
  ];

  /// Get projects by category ID
  static List<Project> getProjectsByCategory(int categoryId) {
    return projects.where((p) => p.categoryId == categoryId).toList();
  }

  /// Get project count by category
  static Map<Category, int> getCategoryProjectCounts() {
    Map<Category, int> counts = {};
    for (var category in categories) {
      counts[category] = projects.where((p) => p.categoryId == category.id).length;
    }
    return counts;
  }

  /// Get critical items by project ID
  static List<Map<String, dynamic>> getCriticalItemsByProject(int? projectId) {
    if (projectId == null) {
      return criticalItems;
    }
    return criticalItems.where((item) => item['project_id'] == projectId).toList();
  }

  /// Get critical items by category ID
  static List<Map<String, dynamic>> getCriticalItemsByCategory(int? categoryId) {
    if (categoryId == null) {
      return criticalItems;
    }
    final categoryProjects = projects.where((p) => p.categoryId == categoryId).map((p) => p.id).toList();
    return criticalItems.where((item) => categoryProjects.contains(item['project_id'])).toList();
  }
}
