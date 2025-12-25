/// DPR (Detailed Project Report) Data Model
///
/// 19 milestone date fields for project planning and execution
class DPRData {
  final int? id;
  final int projectId;
  final String? broadScope;
  final DateTime? bidDocDpr;
  final DateTime? invite;
  final DateTime? prebid;
  final DateTime? csd;
  final DateTime? bidSubmit;
  final DateTime? workOrder;
  final DateTime? inceptionReport;
  final DateTime? survey;
  final DateTime? alignmentLayout;
  final DateTime? draftDpr;
  final DateTime? drawings;
  final DateTime? boq;
  final DateTime? envClearance;
  final DateTime? cashFlow;
  final DateTime? laProposal;
  final DateTime? utilityShifting;
  final DateTime? finalDpr;
  final DateTime? bidDocWork;
  final DateTime createdAt;
  final DateTime updatedAt;

  DPRData({
    this.id,
    required this.projectId,
    this.broadScope,
    this.bidDocDpr,
    this.invite,
    this.prebid,
    this.csd,
    this.bidSubmit,
    this.workOrder,
    this.inceptionReport,
    this.survey,
    this.alignmentLayout,
    this.draftDpr,
    this.drawings,
    this.boq,
    this.envClearance,
    this.cashFlow,
    this.laProposal,
    this.utilityShifting,
    this.finalDpr,
    this.bidDocWork,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create DPRData from database map
  factory DPRData.fromMap(Map<String, dynamic> map) {
    return DPRData(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      broadScope: map['broad_scope'] as String?,
      bidDocDpr: _parseDate(map['bid_doc_dpr']),
      invite: _parseDate(map['invite']),
      prebid: _parseDate(map['prebid']),
      csd: _parseDate(map['csd']),
      bidSubmit: _parseDate(map['bid_submit']),
      workOrder: _parseDate(map['work_order']),
      inceptionReport: _parseDate(map['inception_report']),
      survey: _parseDate(map['survey']),
      alignmentLayout: _parseDate(map['alignment_layout']),
      draftDpr: _parseDate(map['draft_dpr']),
      drawings: _parseDate(map['drawings']),
      boq: _parseDate(map['boq']),
      envClearance: _parseDate(map['env_clearance']),
      cashFlow: _parseDate(map['cash_flow']),
      laProposal: _parseDate(map['la_proposal']),
      utilityShifting: _parseDate(map['utility_shifting']),
      finalDpr: _parseDate(map['final_dpr']),
      bidDocWork: _parseDate(map['bid_doc_work']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create DPRData from CSV row
  factory DPRData.fromCSV(int projectId, List<String> row) {
    // Row structure: Sr. No., Name, Broad Scope, Bid Doc DPR, Invite, Prebid, CSD, ...
    return DPRData(
      projectId: projectId,
      broadScope: row.length > 2 && row[2].isNotEmpty ? row[2] : null,
      bidDocDpr: row.length > 3 ? _parseDate(row[3]) : null,
      invite: row.length > 4 ? _parseDate(row[4]) : null,
      prebid: row.length > 5 ? _parseDate(row[5]) : null,
      csd: row.length > 6 ? _parseDate(row[6]) : null,
      bidSubmit: row.length > 7 ? _parseDate(row[7]) : null,
      workOrder: row.length > 8 ? _parseDate(row[8]) : null,
      inceptionReport: row.length > 9 ? _parseDate(row[9]) : null,
      survey: row.length > 10 ? _parseDate(row[10]) : null,
      alignmentLayout: row.length > 11 ? _parseDate(row[11]) : null,
      draftDpr: row.length > 12 ? _parseDate(row[12]) : null,
      drawings: row.length > 13 ? _parseDate(row[13]) : null,
      boq: row.length > 14 ? _parseDate(row[14]) : null,
      envClearance: row.length > 15 ? _parseDate(row[15]) : null,
      cashFlow: row.length > 16 ? _parseDate(row[16]) : null,
      laProposal: row.length > 17 ? _parseDate(row[17]) : null,
      utilityShifting: row.length > 18 ? _parseDate(row[18]) : null,
      finalDpr: row.length > 19 ? _parseDate(row[19]) : null,
      bidDocWork: row.length > 20 ? _parseDate(row[20]) : null,
    );
  }

  /// Convert DPRData to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'broad_scope': broadScope,
      'bid_doc_dpr': _formatDate(bidDocDpr),
      'invite': _formatDate(invite),
      'prebid': _formatDate(prebid),
      'csd': _formatDate(csd),
      'bid_submit': _formatDate(bidSubmit),
      'work_order': _formatDate(workOrder),
      'inception_report': _formatDate(inceptionReport),
      'survey': _formatDate(survey),
      'alignment_layout': _formatDate(alignmentLayout),
      'draft_dpr': _formatDate(draftDpr),
      'drawings': _formatDate(drawings),
      'boq': _formatDate(boq),
      'env_clearance': _formatDate(envClearance),
      'cash_flow': _formatDate(cashFlow),
      'la_proposal': _formatDate(laProposal),
      'utility_shifting': _formatDate(utilityShifting),
      'final_dpr': _formatDate(finalDpr),
      'bid_doc_work': _formatDate(bidDocWork),
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
      // Try ISO format first
      return DateTime.parse(str);
    } catch (_) {
      // Try DD/MM/YYYY
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

      // Try DD.MM.YY
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
    int totalFields = 19;
    int completedFields = 0;

    if (bidDocDpr != null) completedFields++;
    if (invite != null) completedFields++;
    if (prebid != null) completedFields++;
    if (csd != null) completedFields++;
    if (bidSubmit != null) completedFields++;
    if (workOrder != null) completedFields++;
    if (inceptionReport != null) completedFields++;
    if (survey != null) completedFields++;
    if (alignmentLayout != null) completedFields++;
    if (draftDpr != null) completedFields++;
    if (drawings != null) completedFields++;
    if (boq != null) completedFields++;
    if (envClearance != null) completedFields++;
    if (cashFlow != null) completedFields++;
    if (laProposal != null) completedFields++;
    if (utilityShifting != null) completedFields++;
    if (finalDpr != null) completedFields++;
    if (bidDocWork != null) completedFields++;
    if (broadScope != null && broadScope!.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  /// Copy with updated fields
  DPRData copyWith({
    int? id,
    int? projectId,
    String? broadScope,
    DateTime? bidDocDpr,
    DateTime? invite,
    DateTime? prebid,
    DateTime? csd,
    DateTime? bidSubmit,
    DateTime? workOrder,
    DateTime? inceptionReport,
    DateTime? survey,
    DateTime? alignmentLayout,
    DateTime? draftDpr,
    DateTime? drawings,
    DateTime? boq,
    DateTime? envClearance,
    DateTime? cashFlow,
    DateTime? laProposal,
    DateTime? utilityShifting,
    DateTime? finalDpr,
    DateTime? bidDocWork,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DPRData(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      broadScope: broadScope ?? this.broadScope,
      bidDocDpr: bidDocDpr ?? this.bidDocDpr,
      invite: invite ?? this.invite,
      prebid: prebid ?? this.prebid,
      csd: csd ?? this.csd,
      bidSubmit: bidSubmit ?? this.bidSubmit,
      workOrder: workOrder ?? this.workOrder,
      inceptionReport: inceptionReport ?? this.inceptionReport,
      survey: survey ?? this.survey,
      alignmentLayout: alignmentLayout ?? this.alignmentLayout,
      draftDpr: draftDpr ?? this.draftDpr,
      drawings: drawings ?? this.drawings,
      boq: boq ?? this.boq,
      envClearance: envClearance ?? this.envClearance,
      cashFlow: cashFlow ?? this.cashFlow,
      laProposal: laProposal ?? this.laProposal,
      utilityShifting: utilityShifting ?? this.utilityShifting,
      finalDpr: finalDpr ?? this.finalDpr,
      bidDocWork: bidDocWork ?? this.bidDocWork,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
