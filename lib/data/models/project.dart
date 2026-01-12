/// Project model
class Project {
  final int id;
  final int srNo;
  final String name;
  final int categoryId;
  final String? broadScope;
  final String status;
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;

  Project({
    required this.id,
    required this.srNo,
    required this.name,
    required this.categoryId,
    this.broadScope,
    this.status = 'In Progress',
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
  });

  /// Convert Project to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sr_no': srNo,
      'name': name,
      'category_id': categoryId,
      'broad_scope': broadScope,
      'status': status,
    };
  }

  /// Create Project from Map (database row)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int,
      srNo: map['sr_no'] as int,
      name: map['name'] as String,
      categoryId: map['category_id'] as int,
      broadScope: map['broad_scope'] as String?,
      status: map['status'] as String? ?? 'In Progress',
      categoryName: map['category_name'] as String?,
      categoryColor: map['category_color'] as String?,
      categoryIcon: map['category_icon'] as String?,
    );
  }
}
