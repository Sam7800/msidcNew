/// Project model - Core project information
///
/// Links to dynamic categories table for classification
class Project {
  final int? id;
  final int srNo;
  final String name;
  final int categoryId;
  final String? broadScope;
  final String location;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional fields populated via JOIN with categories table
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;

  Project({
    this.id,
    required this.srNo,
    required this.name,
    required this.categoryId,
    this.broadScope,
    this.location = 'Maharashtra',
    this.status = 'In Progress',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create Project from database map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      srNo: map['sr_no'] as int,
      name: map['name'] as String,
      categoryId: map['category_id'] as int,
      broadScope: map['broad_scope'] as String?,
      location: map['location'] as String? ?? 'Maharashtra',
      status: map['status'] as String? ?? 'In Progress',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      // Optional fields from JOIN with categories table
      categoryName: map['category_name'] as String?,
      categoryColor: map['category_color'] as String?,
      categoryIcon: map['category_icon'] as String?,
    );
  }

  /// Create Project from CSV row (requires categoryId)
  factory Project.fromCSV(List<String> row, int categoryId) {
    return Project(
      srNo: int.parse(row[0]),
      name: row[1],
      categoryId: categoryId,
      broadScope: row.length > 2 && row[2].isNotEmpty ? row[2] : null,
    );
  }

  /// Convert Project to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sr_no': srNo,
      'name': name,
      'category_id': categoryId,
      'broad_scope': broadScope,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Determine category ID based on serial number (for legacy CSV imports)
  /// Maps to the default categories created during database initialization
  static int determineCategoryIdFromSrNo(int srNo) {
    if (srNo >= 1 && srNo <= 8) {
      return 1; // Nashik Kumbhmela
    } else if (srNo >= 9 && srNo <= 10) {
      return 2; // HAM Projects
    } else if (srNo >= 11 && srNo <= 24) {
      return 3; // Nagpur Works
    } else if (srNo >= 25 && srNo <= 28) {
      return 4; // NHAI Projects
    } else {
      return 5; // Other Projects (default)
    }
  }

  /// Copy with updated fields
  Project copyWith({
    int? id,
    int? srNo,
    String? name,
    int? categoryId,
    String? broadScope,
    String? location,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? categoryColor,
    String? categoryIcon,
  }) {
    return Project(
      id: id ?? this.id,
      srNo: srNo ?? this.srNo,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      broadScope: broadScope ?? this.broadScope,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, srNo: $srNo, name: $name, categoryId: $categoryId, categoryName: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project &&
        other.id == id &&
        other.srNo == srNo &&
        other.name == name &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        srNo.hashCode ^
        name.hashCode ^
        categoryId.hashCode;
  }
}
