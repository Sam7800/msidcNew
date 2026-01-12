import 'dart:io';

/// Work Entry Attachment Model
///
/// Represents a file attachment (photo or PDF) linked to a subsection
/// One file per subsection allowed
class WorkEntryAttachment {
  final int? id;
  final int workEntryId;
  final int projectId;
  final String category; // DPR, Work, or PMS
  final String subsectionName;

  // File metadata
  final String fileName;
  final String filePath; // Absolute path on device filesystem
  final String fileType; // JPEG, PNG, PDF
  final int fileSizeBytes;
  final String mimeType;

  // Tracking
  final String uploadedBy;
  final DateTime uploadedAt;

  WorkEntryAttachment({
    this.id,
    required this.workEntryId,
    required this.projectId,
    required this.category,
    required this.subsectionName,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSizeBytes,
    required this.mimeType,
    this.uploadedBy = 'admin',
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  /// Create from database map
  factory WorkEntryAttachment.fromMap(Map<String, dynamic> map) {
    return WorkEntryAttachment(
      id: map['id'] as int?,
      workEntryId: map['work_entry_id'] as int,
      projectId: map['project_id'] as int,
      category: map['category'] as String,
      subsectionName: map['subsection_name'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      fileSizeBytes: map['file_size_bytes'] as int,
      mimeType: map['mime_type'] as String,
      uploadedBy: map['uploaded_by'] as String? ?? 'admin',
      uploadedAt: DateTime.parse(map['uploaded_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'work_entry_id': workEntryId,
      'project_id': projectId,
      'category': category,
      'subsection_name': subsectionName,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'mime_type': mimeType,
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  /// Get file extension from fileName
  String get fileExtension {
    return fileName.split('.').last.toUpperCase();
  }

  /// Check if file exists on filesystem
  Future<bool> fileExists() async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Get human-readable file size
  String get fileSizeReadable {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Validate file type
  static bool isValidFileType(String fileType) {
    return ['JPEG', 'PNG', 'PDF'].contains(fileType.toUpperCase());
  }

  /// Get MIME type from file extension
  static String getMimeType(String fileExtension) {
    switch (fileExtension.toUpperCase()) {
      case 'JPEG':
      case 'JPG':
        return 'image/jpeg';
      case 'PNG':
        return 'image/png';
      case 'PDF':
        return 'application/pdf';
      default:
        throw ArgumentError('Unsupported file type: $fileExtension');
    }
  }

  /// Copy with updated fields
  WorkEntryAttachment copyWith({
    int? id,
    int? workEntryId,
    int? projectId,
    String? category,
    String? subsectionName,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSizeBytes,
    String? mimeType,
    String? uploadedBy,
    DateTime? uploadedAt,
  }) {
    return WorkEntryAttachment(
      id: id ?? this.id,
      workEntryId: workEntryId ?? this.workEntryId,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      subsectionName: subsectionName ?? this.subsectionName,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  String toString() {
    return 'WorkEntryAttachment(id: $id, workEntryId: $workEntryId, subsection: $category/$subsectionName, fileName: $fileName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkEntryAttachment &&
        other.id == id &&
        other.workEntryId == workEntryId &&
        other.projectId == projectId &&
        other.category == category &&
        other.subsectionName == subsectionName &&
        other.fileName == fileName &&
        other.filePath == filePath &&
        other.fileType == fileType &&
        other.fileSizeBytes == fileSizeBytes &&
        other.mimeType == mimeType &&
        other.uploadedBy == uploadedBy &&
        other.uploadedAt == uploadedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      workEntryId,
      projectId,
      category,
      subsectionName,
      fileName,
      filePath,
      fileType,
      fileSizeBytes,
      mimeType,
      uploadedBy,
      uploadedAt,
    );
  }
}
