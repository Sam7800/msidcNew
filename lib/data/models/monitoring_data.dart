/// Monitoring Data Model (PMS - Project Monitoring System)
///
/// 19 financial and monitoring fields for project tracking
class MonitoringData {
  final int? id;
  final int projectId;
  final double? agmntAmount; // Agreement Amount in Rs. Crore
  final DateTime? appointedDate;
  final int? tenderPeriod; // in Months

  // Milestones (Date + Amount)
  final DateTime? firstMilestoneDate;
  final double? firstMilestoneAmount;
  final DateTime? secondMilestoneDate;
  final double? secondMilestoneAmount;
  final DateTime? thirdMilestoneDate;
  final double? thirdMilestoneAmount;
  final DateTime? fourthMilestoneDate;
  final double? fourthMilestoneAmount;
  final DateTime? fifthMilestoneDate;
  final double? fifthMilestoneAmount;

  // Penalties & Changes
  final double? ld; // Liquidated Damages in Rs
  final double? cos; // Change of Scope in Rs. Crore
  final int? eot; // Extension of Time in Months

  // Expenditure & Completion
  final double? cumExp; // Cumulative Expenditure in Rs. Crore
  final double? finalBill; // Final Bill in Rs. Crore

  // Audit & Compliance
  final String? auditPara;
  final String? replies;
  final String? laqLcq; // Legislative Questions
  final String? techAudit;
  final String? revAa; // Revised Administrative Approval

  final DateTime createdAt;
  final DateTime updatedAt;

  MonitoringData({
    this.id,
    required this.projectId,
    this.agmntAmount,
    this.appointedDate,
    this.tenderPeriod,
    this.firstMilestoneDate,
    this.firstMilestoneAmount,
    this.secondMilestoneDate,
    this.secondMilestoneAmount,
    this.thirdMilestoneDate,
    this.thirdMilestoneAmount,
    this.fourthMilestoneDate,
    this.fourthMilestoneAmount,
    this.fifthMilestoneDate,
    this.fifthMilestoneAmount,
    this.ld,
    this.cos,
    this.eot,
    this.cumExp,
    this.finalBill,
    this.auditPara,
    this.replies,
    this.laqLcq,
    this.techAudit,
    this.revAa,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create MonitoringData from database map
  factory MonitoringData.fromMap(Map<String, dynamic> map) {
    return MonitoringData(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      agmntAmount: map['agmnt_amount'] as double?,
      appointedDate: _parseDate(map['appointed_date']),
      tenderPeriod: map['tender_period'] as int?,
      firstMilestoneDate: _parseDate(map['first_milestone_date']),
      firstMilestoneAmount: map['first_milestone_amount'] as double?,
      secondMilestoneDate: _parseDate(map['second_milestone_date']),
      secondMilestoneAmount: map['second_milestone_amount'] as double?,
      thirdMilestoneDate: _parseDate(map['third_milestone_date']),
      thirdMilestoneAmount: map['third_milestone_amount'] as double?,
      fourthMilestoneDate: _parseDate(map['fourth_milestone_date']),
      fourthMilestoneAmount: map['fourth_milestone_amount'] as double?,
      fifthMilestoneDate: _parseDate(map['fifth_milestone_date']),
      fifthMilestoneAmount: map['fifth_milestone_amount'] as double?,
      ld: map['ld'] as double?,
      cos: map['cos'] as double?,
      eot: map['eot'] as int?,
      cumExp: map['cum_exp'] as double?,
      finalBill: map['final_bill'] as double?,
      auditPara: map['audit_para'] as String?,
      replies: map['replies'] as String?,
      laqLcq: map['laq_lcq'] as String?,
      techAudit: map['tech_audit'] as String?,
      revAa: map['rev_aa'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create MonitoringData from CSV row
  factory MonitoringData.fromCSV(int projectId, List<String> row) {
    // Row structure: Sr. No., Name, Agmnt Amount, Appointed Date, Tender Period, ...
    return MonitoringData(
      projectId: projectId,
      agmntAmount: row.length > 2 ? _parseDouble(row[2]) : null,
      appointedDate: row.length > 3 ? _parseDate(row[3]) : null,
      tenderPeriod: row.length > 4 ? _parseInt(row[4]) : null,
      firstMilestoneDate: row.length > 5 ? _parseMilestoneDate(row[5]) : null,
      firstMilestoneAmount:
          row.length > 5 ? _parseMilestoneAmount(row[5]) : null,
      secondMilestoneDate: row.length > 6 ? _parseMilestoneDate(row[6]) : null,
      secondMilestoneAmount:
          row.length > 6 ? _parseMilestoneAmount(row[6]) : null,
      thirdMilestoneDate: row.length > 7 ? _parseMilestoneDate(row[7]) : null,
      thirdMilestoneAmount:
          row.length > 7 ? _parseMilestoneAmount(row[7]) : null,
      fourthMilestoneDate: row.length > 8 ? _parseMilestoneDate(row[8]) : null,
      fourthMilestoneAmount:
          row.length > 8 ? _parseMilestoneAmount(row[8]) : null,
      fifthMilestoneDate: row.length > 9 ? _parseMilestoneDate(row[9]) : null,
      fifthMilestoneAmount:
          row.length > 9 ? _parseMilestoneAmount(row[9]) : null,
      ld: row.length > 10 ? _parseDouble(row[10]) : null,
      cos: row.length > 11 ? _parseDouble(row[11]) : null,
      eot: row.length > 12 ? _parseInt(row[12]) : null,
      cumExp: row.length > 13 ? _parseDouble(row[13]) : null,
      finalBill: row.length > 14 ? _parseDouble(row[14]) : null,
      auditPara: row.length > 15 && row[15].isNotEmpty ? row[15] : null,
      replies: row.length > 16 && row[16].isNotEmpty ? row[16] : null,
      laqLcq: row.length > 17 && row[17].isNotEmpty ? row[17] : null,
      techAudit: row.length > 18 && row[18].isNotEmpty ? row[18] : null,
      revAa: row.length > 19 && row[19].isNotEmpty ? row[19] : null,
    );
  }

  /// Convert MonitoringData to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'agmnt_amount': agmntAmount,
      'appointed_date': _formatDate(appointedDate),
      'tender_period': tenderPeriod,
      'first_milestone_date': _formatDate(firstMilestoneDate),
      'first_milestone_amount': firstMilestoneAmount,
      'second_milestone_date': _formatDate(secondMilestoneDate),
      'second_milestone_amount': secondMilestoneAmount,
      'third_milestone_date': _formatDate(thirdMilestoneDate),
      'third_milestone_amount': thirdMilestoneAmount,
      'fourth_milestone_date': _formatDate(fourthMilestoneDate),
      'fourth_milestone_amount': fourthMilestoneAmount,
      'fifth_milestone_date': _formatDate(fifthMilestoneDate),
      'fifth_milestone_amount': fifthMilestoneAmount,
      'ld': ld,
      'cos': cos,
      'eot': eot,
      'cum_exp': cumExp,
      'final_bill': finalBill,
      'audit_para': auditPara,
      'replies': replies,
      'laq_lcq': laqLcq,
      'tech_audit': techAudit,
      'rev_aa': revAa,
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

  /// Parse milestone date from "Date + Amount" format
  static DateTime? _parseMilestoneDate(String? value) {
    if (value == null || value.isEmpty) return null;

    // Format: "Date + Amount" or just "Date"
    final parts = value.split('+');
    if (parts.isNotEmpty) {
      return _parseDate(parts[0].trim());
    }
    return null;
  }

  /// Parse milestone amount from "Date + Amount" format
  static double? _parseMilestoneAmount(String? value) {
    if (value == null || value.isEmpty) return null;

    // Format: "Date + Amount"
    final parts = value.split('+');
    if (parts.length > 1) {
      return _parseDouble(parts[1].trim());
    }
    return null;
  }

  /// Parse integer
  static int? _parseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  /// Parse double
  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  /// Format date to ISO string
  static String? _formatDate(DateTime? date) {
    return date?.toIso8601String();
  }

  /// Calculate financial completion percentage
  double getFinancialCompletion() {
    if (agmntAmount == null || agmntAmount == 0) return 0;

    final totalSpent = cumExp ?? 0;
    return (totalSpent / agmntAmount!) * 100;
  }

  /// Calculate milestone completion
  int getMilestonesCompleted() {
    int completed = 0;
    if (firstMilestoneDate != null) completed++;
    if (secondMilestoneDate != null) completed++;
    if (thirdMilestoneDate != null) completed++;
    if (fourthMilestoneDate != null) completed++;
    if (fifthMilestoneDate != null) completed++;
    return completed;
  }

  /// Get total milestone amount
  double getTotalMilestoneAmount() {
    double total = 0;
    if (firstMilestoneAmount != null) total += firstMilestoneAmount!;
    if (secondMilestoneAmount != null) total += secondMilestoneAmount!;
    if (thirdMilestoneAmount != null) total += thirdMilestoneAmount!;
    if (fourthMilestoneAmount != null) total += fourthMilestoneAmount!;
    if (fifthMilestoneAmount != null) total += fifthMilestoneAmount!;
    return total;
  }

  /// Copy with updated fields
  MonitoringData copyWith({
    int? id,
    int? projectId,
    double? agmntAmount,
    DateTime? appointedDate,
    int? tenderPeriod,
    DateTime? firstMilestoneDate,
    double? firstMilestoneAmount,
    DateTime? secondMilestoneDate,
    double? secondMilestoneAmount,
    DateTime? thirdMilestoneDate,
    double? thirdMilestoneAmount,
    DateTime? fourthMilestoneDate,
    double? fourthMilestoneAmount,
    DateTime? fifthMilestoneDate,
    double? fifthMilestoneAmount,
    double? ld,
    double? cos,
    int? eot,
    double? cumExp,
    double? finalBill,
    String? auditPara,
    String? replies,
    String? laqLcq,
    String? techAudit,
    String? revAa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonitoringData(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      agmntAmount: agmntAmount ?? this.agmntAmount,
      appointedDate: appointedDate ?? this.appointedDate,
      tenderPeriod: tenderPeriod ?? this.tenderPeriod,
      firstMilestoneDate: firstMilestoneDate ?? this.firstMilestoneDate,
      firstMilestoneAmount: firstMilestoneAmount ?? this.firstMilestoneAmount,
      secondMilestoneDate: secondMilestoneDate ?? this.secondMilestoneDate,
      secondMilestoneAmount: secondMilestoneAmount ?? this.secondMilestoneAmount,
      thirdMilestoneDate: thirdMilestoneDate ?? this.thirdMilestoneDate,
      thirdMilestoneAmount: thirdMilestoneAmount ?? this.thirdMilestoneAmount,
      fourthMilestoneDate: fourthMilestoneDate ?? this.fourthMilestoneDate,
      fourthMilestoneAmount: fourthMilestoneAmount ?? this.fourthMilestoneAmount,
      fifthMilestoneDate: fifthMilestoneDate ?? this.fifthMilestoneDate,
      fifthMilestoneAmount: fifthMilestoneAmount ?? this.fifthMilestoneAmount,
      ld: ld ?? this.ld,
      cos: cos ?? this.cos,
      eot: eot ?? this.eot,
      cumExp: cumExp ?? this.cumExp,
      finalBill: finalBill ?? this.finalBill,
      auditPara: auditPara ?? this.auditPara,
      replies: replies ?? this.replies,
      laqLcq: laqLcq ?? this.laqLcq,
      techAudit: techAudit ?? this.techAudit,
      revAa: revAa ?? this.revAa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
