/// Work Data Model
///
/// 15 major milestone date fields for work tracking
class WorkData {
  final int? id;
  final int projectId;
  final DateTime? aa; // Administrative Approval
  final DateTime? dpr;
  final DateTime? ts; // Technical Sanction
  final DateTime? bidDoc;
  final DateTime? bidInvite;
  final DateTime? prebid;
  final DateTime? csd;
  final DateTime? bidSubmit;
  final DateTime? finBid;
  final DateTime? loi; // Letter of Intent
  final DateTime? loa; // Letter of Acceptance
  final DateTime? pbg; // Performance Bank Guarantee
  final DateTime? agreement;
  final DateTime? workOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkData({
    this.id,
    required this.projectId,
    this.aa,
    this.dpr,
    this.ts,
    this.bidDoc,
    this.bidInvite,
    this.prebid,
    this.csd,
    this.bidSubmit,
    this.finBid,
    this.loi,
    this.loa,
    this.pbg,
    this.agreement,
    this.workOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create WorkData from database map
  factory WorkData.fromMap(Map<String, dynamic> map) {
    return WorkData(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      aa: _parseDate(map['aa']),
      dpr: _parseDate(map['dpr']),
      ts: _parseDate(map['ts']),
      bidDoc: _parseDate(map['bid_doc']),
      bidInvite: _parseDate(map['bid_invite']),
      prebid: _parseDate(map['prebid']),
      csd: _parseDate(map['csd']),
      bidSubmit: _parseDate(map['bid_submit']),
      finBid: _parseDate(map['fin_bid']),
      loi: _parseDate(map['loi']),
      loa: _parseDate(map['loa']),
      pbg: _parseDate(map['pbg']),
      agreement: _parseDate(map['agreement']),
      workOrder: _parseDate(map['work_order']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create WorkData from CSV row
  factory WorkData.fromCSV(int projectId, List<String> row) {
    // Row structure: Sr. No., Name, AA, DPR, TS, Bid Doc, ...
    return WorkData(
      projectId: projectId,
      aa: row.length > 2 ? _parseDate(row[2]) : null,
      dpr: row.length > 3 ? _parseDate(row[3]) : null,
      ts: row.length > 4 ? _parseDate(row[4]) : null,
      bidDoc: row.length > 5 ? _parseDate(row[5]) : null,
      bidInvite: row.length > 6 ? _parseDate(row[6]) : null,
      prebid: row.length > 7 ? _parseDate(row[7]) : null,
      csd: row.length > 8 ? _parseDate(row[8]) : null,
      bidSubmit: row.length > 9 ? _parseDate(row[9]) : null,
      finBid: row.length > 10 ? _parseDate(row[10]) : null,
      loi: row.length > 11 ? _parseDate(row[11]) : null,
      loa: row.length > 12 ? _parseDate(row[12]) : null,
      pbg: row.length > 13 ? _parseDate(row[13]) : null,
      agreement: row.length > 14 ? _parseDate(row[14]) : null,
      workOrder: row.length > 15 ? _parseDate(row[15]) : null,
    );
  }

  /// Convert WorkData to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'aa': _formatDate(aa),
      'dpr': _formatDate(dpr),
      'ts': _formatDate(ts),
      'bid_doc': _formatDate(bidDoc),
      'bid_invite': _formatDate(bidInvite),
      'prebid': _formatDate(prebid),
      'csd': _formatDate(csd),
      'bid_submit': _formatDate(bidSubmit),
      'fin_bid': _formatDate(finBid),
      'loi': _formatDate(loi),
      'loa': _formatDate(loa),
      'pbg': _formatDate(pbg),
      'agreement': _formatDate(agreement),
      'work_order': _formatDate(workOrder),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Parse date from various formats
  static DateTime? _parseDate(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) return null;

    if (value is DateTime) return value;

    final str = value.toString().trim();
    if (str.isEmpty) return null;

    try {
      return DateTime.parse(str);
    } catch (_) {
      final parts = str.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          final fullYear = year < 100 ? 2000 + year : year;
          return DateTime(fullYear, month, day);
        }
      }

      final dotParts = str.split('.');
      if (dotParts.length == 3) {
        final day = int.tryParse(dotParts[0]);
        final month = int.tryParse(dotParts[1]);
        final year = int.tryParse(dotParts[2]);
        if (day != null && month != null && year != null) {
          final fullYear = year < 100 ? 2000 + year : year;
          return DateTime(fullYear, month, day);
        }
      }
    }

    return null;
  }

  /// Format date to ISO string
  static String? _formatDate(DateTime? date) {
    return date?.toIso8601String();
  }

  /// Calculate completion percentage
  double getCompletionPercentage() {
    int totalFields = 15;
    int completedFields = 0;

    if (aa != null) completedFields++;
    if (dpr != null) completedFields++;
    if (ts != null) completedFields++;
    if (bidDoc != null) completedFields++;
    if (bidInvite != null) completedFields++;
    if (prebid != null) completedFields++;
    if (csd != null) completedFields++;
    if (bidSubmit != null) completedFields++;
    if (finBid != null) completedFields++;
    if (loi != null) completedFields++;
    if (loa != null) completedFields++;
    if (pbg != null) completedFields++;
    if (agreement != null) completedFields++;
    if (workOrder != null) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  /// Copy with updated fields
  WorkData copyWith({
    int? id,
    int? projectId,
    DateTime? aa,
    DateTime? dpr,
    DateTime? ts,
    DateTime? bidDoc,
    DateTime? bidInvite,
    DateTime? prebid,
    DateTime? csd,
    DateTime? bidSubmit,
    DateTime? finBid,
    DateTime? loi,
    DateTime? loa,
    DateTime? pbg,
    DateTime? agreement,
    DateTime? workOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkData(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      aa: aa ?? this.aa,
      dpr: dpr ?? this.dpr,
      ts: ts ?? this.ts,
      bidDoc: bidDoc ?? this.bidDoc,
      bidInvite: bidInvite ?? this.bidInvite,
      prebid: prebid ?? this.prebid,
      csd: csd ?? this.csd,
      bidSubmit: bidSubmit ?? this.bidSubmit,
      finBid: finBid ?? this.finBid,
      loi: loi ?? this.loi,
      loa: loa ?? this.loa,
      pbg: pbg ?? this.pbg,
      agreement: agreement ?? this.agreement,
      workOrder: workOrder ?? this.workOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
