import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'critical_marker_widget.dart';
import 'dynamic_table_widget.dart';

/// Work Entry Form Widget - Main form container
class WorkEntryFormWidget extends StatefulWidget {
  const WorkEntryFormWidget({super.key});

  @override
  State<WorkEntryFormWidget> createState() => _WorkEntryFormWidgetState();
}

class _WorkEntryFormWidgetState extends State<WorkEntryFormWidget> {
  // Search functionality
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Text field controllers Map - tracks all text inputs
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String> _initialTextValues = {};

  // Form state variables
  String _aaStatus = 'awaited'; // awaited, accorded
  String _dprStatus = 'not_started'; // not_started, in_progress, submitted, approved
  String _boqStatus = 'not_started';
  String _schedulesStatus = 'not_started';
  String _drawingsStatus = 'not_started';
  String _bidDocumentsStatus = 'not_started';
  String _envApplicability = 'not_applicable'; // not_applicable, applicable
  String _envProposalStatus = 'not_started'; // not_started, under_preparation, submitted
  String _laApplicability = 'not_applicable';
  String _laProposalStatus = 'not_started';
  String _utilityShiftingApplicability = 'not_applicable';
  String _utilityShiftingProposalStatus = 'not_started';
  String _tsStatus = 'awaited'; // awaited, accorded
  String _tsAwaitedStatus = 'not_started'; // not_started, in_progress
  String _nitStatus = 'not_issued'; // not_issued, issued
  String _nitIssuedInputMethod = 'manual'; // manual, photo
  String _csdStatus = 'queries_in_progress'; // queries_in_progress, replies_submitted, replies_approved, csd_uploaded
  String _technicalEvaluationStatus = 'in_progress'; // in_progress, completed, results_published, financial_bid_informed
  String _financialBidOfferType = 'l1'; // l1, h1
  String _bidAcceptanceStatus = 'in_progress'; // in_progress, submitted, approved, board_approval, accepted
  String _loaStatus = 'not_issued'; // not_issued, issued
  String _pbgStatus = 'not_submitted'; // not_submitted, submitted
  String _workOrderStatus = 'not_issued'; // not_issued, issued
  String _ldApplicability = 'not_applicable'; // not_applicable, applicable
  String _eotApplicability = 'not_applicable'; // not_applicable, applicable
  String _cosApplicability = 'not_applicable'; // not_applicable, applicable
  String _cosStatus = 'not_started'; // not_started, under_consideration, submitted, approved
  String _auditParaApplicability = 'not_applicable'; // not_applicable, applicable
  String _laqApplicability = 'not_applicable'; // not_applicable, applicable
  String _technicalAuditStatus = 'not_done'; // not_done, carried_out
  String _revAaStatus = 'not_required'; // not_required, necessary
  String _revAaProgressStatus = 'in_progress'; // in_progress, submitted, approved, board_approval, accorded
  String _supplementaryAgreementApplicability = 'not_applicable'; // not_applicable, applicable

  // Checkbox states for EOT
  Set<String> _eotOptions = {};

  // EMD verification for Bid Submission
  bool _emdVerificationDone = false;

  // Critical markers state
  Map<String, bool> _criticalMarkers = {
    'dpr_submitted': false,
    'schedules_submitted': false,
    'drawings_submitted': false,
    'bid_documents_submitted': false,
    'env_under_preparation': false,
    'la_under_preparation': false,
    'utility_under_preparation': false,
    'utility_submitted_date': false,
    'ts_in_progress_date': false,
    'nit_likely_date': false,
    'csd_queries_in_progress': false,
    'csd_replies_submitted': false,
    'tech_eval_in_progress': false,
    'bid_accept_in_progress': false,
    'bid_accept_submitted': false,
    'bid_accept_board_approval': false,
    'loa_issued': false,
    'loa_not_issued': false,
    'pbg_not_submitted': false,
    'work_order_not_issued': false,
    'eot_submitted_date': false,
    'cos_under_consideration': false,
    'cos_submitted_date': false,
    'audit_para_replies_submitted': false,
    'laq_details_questions': false,
    'rev_aa_submitted': false,
  };

  // Initial state tracking for change detection
  late Map<String, dynamic> _initialState;

  @override
  void initState() {
    super.initState();
    _captureInitialState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Dispose all text field controllers
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Gets or creates a TextEditingController for a given field
  TextEditingController _getController(String fieldKey) {
    if (!_textControllers.containsKey(fieldKey)) {
      _textControllers[fieldKey] = TextEditingController();
      // Add listener to trigger setState when text changes
      _textControllers[fieldKey]!.addListener(() {
        setState(() {}); // Trigger rebuild to show/hide submit button
      });
    }
    return _textControllers[fieldKey]!;
  }

  /// Captures the initial state of all form fields
  void _captureInitialState() {
    _initialState = {
      'aaStatus': _aaStatus,
      'dprStatus': _dprStatus,
      'boqStatus': _boqStatus,
      'schedulesStatus': _schedulesStatus,
      'drawingsStatus': _drawingsStatus,
      'bidDocumentsStatus': _bidDocumentsStatus,
      'envApplicability': _envApplicability,
      'envProposalStatus': _envProposalStatus,
      'laApplicability': _laApplicability,
      'laProposalStatus': _laProposalStatus,
      'utilityShiftingApplicability': _utilityShiftingApplicability,
      'utilityShiftingProposalStatus': _utilityShiftingProposalStatus,
      'tsStatus': _tsStatus,
      'tsAwaitedStatus': _tsAwaitedStatus,
      'nitStatus': _nitStatus,
      'nitIssuedInputMethod': _nitIssuedInputMethod,
      'csdStatus': _csdStatus,
      'technicalEvaluationStatus': _technicalEvaluationStatus,
      'financialBidOfferType': _financialBidOfferType,
      'bidAcceptanceStatus': _bidAcceptanceStatus,
      'loaStatus': _loaStatus,
      'pbgStatus': _pbgStatus,
      'workOrderStatus': _workOrderStatus,
      'ldApplicability': _ldApplicability,
      'eotApplicability': _eotApplicability,
      'cosApplicability': _cosApplicability,
      'cosStatus': _cosStatus,
      'auditParaApplicability': _auditParaApplicability,
      'laqApplicability': _laqApplicability,
      'technicalAuditStatus': _technicalAuditStatus,
      'revAaStatus': _revAaStatus,
      'revAaProgressStatus': _revAaProgressStatus,
      'supplementaryAgreementApplicability': _supplementaryAgreementApplicability,
      'eotOptions': Set<String>.from(_eotOptions),
      'emdVerificationDone': _emdVerificationDone,
    };

    // Capture initial text field values
    _initialTextValues.clear();
    for (var entry in _textControllers.entries) {
      _initialTextValues[entry.key] = entry.value.text;
    }
  }

  /// Checks if any form field has been modified from its initial value
  bool _hasChanges() {
    // Check radio buttons, checkboxes, and dropdowns
    if (_aaStatus != _initialState['aaStatus'] ||
        _dprStatus != _initialState['dprStatus'] ||
        _boqStatus != _initialState['boqStatus'] ||
        _schedulesStatus != _initialState['schedulesStatus'] ||
        _drawingsStatus != _initialState['drawingsStatus'] ||
        _bidDocumentsStatus != _initialState['bidDocumentsStatus'] ||
        _envApplicability != _initialState['envApplicability'] ||
        _envProposalStatus != _initialState['envProposalStatus'] ||
        _laApplicability != _initialState['laApplicability'] ||
        _laProposalStatus != _initialState['laProposalStatus'] ||
        _utilityShiftingApplicability != _initialState['utilityShiftingApplicability'] ||
        _utilityShiftingProposalStatus != _initialState['utilityShiftingProposalStatus'] ||
        _tsStatus != _initialState['tsStatus'] ||
        _tsAwaitedStatus != _initialState['tsAwaitedStatus'] ||
        _nitStatus != _initialState['nitStatus'] ||
        _nitIssuedInputMethod != _initialState['nitIssuedInputMethod'] ||
        _csdStatus != _initialState['csdStatus'] ||
        _technicalEvaluationStatus != _initialState['technicalEvaluationStatus'] ||
        _financialBidOfferType != _initialState['financialBidOfferType'] ||
        _bidAcceptanceStatus != _initialState['bidAcceptanceStatus'] ||
        _loaStatus != _initialState['loaStatus'] ||
        _pbgStatus != _initialState['pbgStatus'] ||
        _workOrderStatus != _initialState['workOrderStatus'] ||
        _ldApplicability != _initialState['ldApplicability'] ||
        _eotApplicability != _initialState['eotApplicability'] ||
        _cosApplicability != _initialState['cosApplicability'] ||
        _cosStatus != _initialState['cosStatus'] ||
        _auditParaApplicability != _initialState['auditParaApplicability'] ||
        _laqApplicability != _initialState['laqApplicability'] ||
        _technicalAuditStatus != _initialState['technicalAuditStatus'] ||
        _revAaStatus != _initialState['revAaStatus'] ||
        _revAaProgressStatus != _initialState['revAaProgressStatus'] ||
        _supplementaryAgreementApplicability != _initialState['supplementaryAgreementApplicability'] ||
        !_setsEqual(_eotOptions, _initialState['eotOptions']) ||
        _emdVerificationDone != _initialState['emdVerificationDone']) {
      return true;
    }

    // Check text field changes
    for (var entry in _textControllers.entries) {
      final initialValue = _initialTextValues[entry.key] ?? '';
      final currentValue = entry.value.text;
      if (initialValue != currentValue) {
        return true;
      }
    }

    return false;
  }

  /// Helper method to compare two sets for equality
  bool _setsEqual(Set<String> set1, Set<String> set2) {
    if (set1.length != set2.length) return false;
    return set1.containsAll(set2);
  }

  /// Gets a list of all changes made to the form
  List<Map<String, String>> _getChanges() {
    final changes = <Map<String, String>>[];

    if (_aaStatus != _initialState['aaStatus']) {
      changes.add({
        'field': 'AA Status',
        'from': _formatFieldValue(_initialState['aaStatus']),
        'to': _formatFieldValue(_aaStatus),
      });
    }

    if (_dprStatus != _initialState['dprStatus']) {
      changes.add({
        'field': 'DPR Status',
        'from': _formatFieldValue(_initialState['dprStatus']),
        'to': _formatFieldValue(_dprStatus),
      });
    }

    if (_boqStatus != _initialState['boqStatus']) {
      changes.add({
        'field': 'BOQ Status',
        'from': _formatFieldValue(_initialState['boqStatus']),
        'to': _formatFieldValue(_boqStatus),
      });
    }

    if (_schedulesStatus != _initialState['schedulesStatus']) {
      changes.add({
        'field': 'Schedules Status',
        'from': _formatFieldValue(_initialState['schedulesStatus']),
        'to': _formatFieldValue(_schedulesStatus),
      });
    }

    if (_drawingsStatus != _initialState['drawingsStatus']) {
      changes.add({
        'field': 'Drawings Status',
        'from': _formatFieldValue(_initialState['drawingsStatus']),
        'to': _formatFieldValue(_drawingsStatus),
      });
    }

    if (_bidDocumentsStatus != _initialState['bidDocumentsStatus']) {
      changes.add({
        'field': 'Bid Documents Status',
        'from': _formatFieldValue(_initialState['bidDocumentsStatus']),
        'to': _formatFieldValue(_bidDocumentsStatus),
      });
    }

    if (_envApplicability != _initialState['envApplicability']) {
      changes.add({
        'field': 'ENV Applicability',
        'from': _formatFieldValue(_initialState['envApplicability']),
        'to': _formatFieldValue(_envApplicability),
      });
    }

    if (_envProposalStatus != _initialState['envProposalStatus']) {
      changes.add({
        'field': 'ENV Proposal Status',
        'from': _formatFieldValue(_initialState['envProposalStatus']),
        'to': _formatFieldValue(_envProposalStatus),
      });
    }

    if (_laApplicability != _initialState['laApplicability']) {
      changes.add({
        'field': 'LA Applicability',
        'from': _formatFieldValue(_initialState['laApplicability']),
        'to': _formatFieldValue(_laApplicability),
      });
    }

    if (_laProposalStatus != _initialState['laProposalStatus']) {
      changes.add({
        'field': 'LA Proposal Status',
        'from': _formatFieldValue(_initialState['laProposalStatus']),
        'to': _formatFieldValue(_laProposalStatus),
      });
    }

    if (_utilityShiftingApplicability != _initialState['utilityShiftingApplicability']) {
      changes.add({
        'field': 'Utility Shifting Applicability',
        'from': _formatFieldValue(_initialState['utilityShiftingApplicability']),
        'to': _formatFieldValue(_utilityShiftingApplicability),
      });
    }

    if (_utilityShiftingProposalStatus != _initialState['utilityShiftingProposalStatus']) {
      changes.add({
        'field': 'Utility Shifting Proposal Status',
        'from': _formatFieldValue(_initialState['utilityShiftingProposalStatus']),
        'to': _formatFieldValue(_utilityShiftingProposalStatus),
      });
    }

    if (_tsStatus != _initialState['tsStatus']) {
      changes.add({
        'field': 'TS Status',
        'from': _formatFieldValue(_initialState['tsStatus']),
        'to': _formatFieldValue(_tsStatus),
      });
    }

    if (_tsAwaitedStatus != _initialState['tsAwaitedStatus']) {
      changes.add({
        'field': 'TS Awaited Status',
        'from': _formatFieldValue(_initialState['tsAwaitedStatus']),
        'to': _formatFieldValue(_tsAwaitedStatus),
      });
    }

    if (_nitStatus != _initialState['nitStatus']) {
      changes.add({
        'field': 'NIT Status',
        'from': _formatFieldValue(_initialState['nitStatus']),
        'to': _formatFieldValue(_nitStatus),
      });
    }

    if (_nitIssuedInputMethod != _initialState['nitIssuedInputMethod']) {
      changes.add({
        'field': 'NIT Input Method',
        'from': _formatFieldValue(_initialState['nitIssuedInputMethod']),
        'to': _formatFieldValue(_nitIssuedInputMethod),
      });
    }

    if (_csdStatus != _initialState['csdStatus']) {
      changes.add({
        'field': 'CSD Status',
        'from': _formatFieldValue(_initialState['csdStatus']),
        'to': _formatFieldValue(_csdStatus),
      });
    }

    if (_technicalEvaluationStatus != _initialState['technicalEvaluationStatus']) {
      changes.add({
        'field': 'Technical Evaluation Status',
        'from': _formatFieldValue(_initialState['technicalEvaluationStatus']),
        'to': _formatFieldValue(_technicalEvaluationStatus),
      });
    }

    if (_financialBidOfferType != _initialState['financialBidOfferType']) {
      changes.add({
        'field': 'Financial Bid Offer Type',
        'from': _formatFieldValue(_initialState['financialBidOfferType']),
        'to': _formatFieldValue(_financialBidOfferType),
      });
    }

    if (_bidAcceptanceStatus != _initialState['bidAcceptanceStatus']) {
      changes.add({
        'field': 'Bid Acceptance Status',
        'from': _formatFieldValue(_initialState['bidAcceptanceStatus']),
        'to': _formatFieldValue(_bidAcceptanceStatus),
      });
    }

    if (_loaStatus != _initialState['loaStatus']) {
      changes.add({
        'field': 'LOA Status',
        'from': _formatFieldValue(_initialState['loaStatus']),
        'to': _formatFieldValue(_loaStatus),
      });
    }

    if (_pbgStatus != _initialState['pbgStatus']) {
      changes.add({
        'field': 'PBG Status',
        'from': _formatFieldValue(_initialState['pbgStatus']),
        'to': _formatFieldValue(_pbgStatus),
      });
    }

    if (_workOrderStatus != _initialState['workOrderStatus']) {
      changes.add({
        'field': 'Work Order Status',
        'from': _formatFieldValue(_initialState['workOrderStatus']),
        'to': _formatFieldValue(_workOrderStatus),
      });
    }

    if (_ldApplicability != _initialState['ldApplicability']) {
      changes.add({
        'field': 'LD Applicability',
        'from': _formatFieldValue(_initialState['ldApplicability']),
        'to': _formatFieldValue(_ldApplicability),
      });
    }

    if (_eotApplicability != _initialState['eotApplicability']) {
      changes.add({
        'field': 'EOT Applicability',
        'from': _formatFieldValue(_initialState['eotApplicability']),
        'to': _formatFieldValue(_eotApplicability),
      });
    }

    if (_cosApplicability != _initialState['cosApplicability']) {
      changes.add({
        'field': 'COS Applicability',
        'from': _formatFieldValue(_initialState['cosApplicability']),
        'to': _formatFieldValue(_cosApplicability),
      });
    }

    if (_cosStatus != _initialState['cosStatus']) {
      changes.add({
        'field': 'COS Status',
        'from': _formatFieldValue(_initialState['cosStatus']),
        'to': _formatFieldValue(_cosStatus),
      });
    }

    if (_auditParaApplicability != _initialState['auditParaApplicability']) {
      changes.add({
        'field': 'Audit Para Applicability',
        'from': _formatFieldValue(_initialState['auditParaApplicability']),
        'to': _formatFieldValue(_auditParaApplicability),
      });
    }

    if (_laqApplicability != _initialState['laqApplicability']) {
      changes.add({
        'field': 'LAQ Applicability',
        'from': _formatFieldValue(_initialState['laqApplicability']),
        'to': _formatFieldValue(_laqApplicability),
      });
    }

    if (_technicalAuditStatus != _initialState['technicalAuditStatus']) {
      changes.add({
        'field': 'Technical Audit Status',
        'from': _formatFieldValue(_initialState['technicalAuditStatus']),
        'to': _formatFieldValue(_technicalAuditStatus),
      });
    }

    if (_revAaStatus != _initialState['revAaStatus']) {
      changes.add({
        'field': 'Rev AA Status',
        'from': _formatFieldValue(_initialState['revAaStatus']),
        'to': _formatFieldValue(_revAaStatus),
      });
    }

    if (_revAaProgressStatus != _initialState['revAaProgressStatus']) {
      changes.add({
        'field': 'Rev AA Progress Status',
        'from': _formatFieldValue(_initialState['revAaProgressStatus']),
        'to': _formatFieldValue(_revAaProgressStatus),
      });
    }

    if (_supplementaryAgreementApplicability != _initialState['supplementaryAgreementApplicability']) {
      changes.add({
        'field': 'Supplementary Agreement Applicability',
        'from': _formatFieldValue(_initialState['supplementaryAgreementApplicability']),
        'to': _formatFieldValue(_supplementaryAgreementApplicability),
      });
    }

    if (!_setsEqual(_eotOptions, _initialState['eotOptions'])) {
      changes.add({
        'field': 'EOT Options',
        'from': _initialState['eotOptions'].isEmpty
            ? 'None'
            : _initialState['eotOptions'].join(', '),
        'to': _eotOptions.isEmpty ? 'None' : _eotOptions.join(', '),
      });
    }

    if (_emdVerificationDone != _initialState['emdVerificationDone']) {
      changes.add({
        'field': 'EMD Verification Done',
        'from': _initialState['emdVerificationDone'] ? 'Yes' : 'No',
        'to': _emdVerificationDone ? 'Yes' : 'No',
      });
    }

    // Check text field changes
    for (var entry in _textControllers.entries) {
      final initialValue = _initialTextValues[entry.key] ?? '';
      final currentValue = entry.value.text;
      if (initialValue != currentValue) {
        changes.add({
          'field': entry.key,
          'from': initialValue.isEmpty ? '(Empty)' : initialValue,
          'to': currentValue.isEmpty ? '(Empty)' : currentValue,
        });
      }
    }

    return changes;
  }

  /// Formats field values for display
  String _formatFieldValue(dynamic value) {
    if (value is String) {
      return value.replaceAll('_', ' ').split(' ').map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
    }
    return value.toString();
  }

  /// Groups changes by their section
  Map<String, List<Map<String, String>>> _groupChangesBySection(
      List<Map<String, String>> changes) {
    final grouped = <String, List<Map<String, String>>>{};

    for (var change in changes) {
      final field = change['field']!;
      String section = 'Other';

      // Determine section based on field name
      if (field.contains('AA ')) {
        section = 'AA (Administrative Approval)';
      } else if (field.contains('DPR ')) {
        section = 'DPR (Detailed Project Report)';
      } else if (field.contains('BOQ ')) {
        section = 'BOQ (Bill of Quantities)';
      } else if (field.contains('Schedules ')) {
        section = 'Schedules';
      } else if (field.contains('Drawings ')) {
        section = 'Drawings';
      } else if (field.contains('Bid Documents ')) {
        section = 'Bid Documents';
      } else if (field.contains('ENV ')) {
        section = 'ENV (Environmental Clearance)';
      } else if (field.contains('LA ')) {
        section = 'LA (Land Acquisition)';
      } else if (field.contains('Utility Shifting ')) {
        section = 'Utility Shifting Details';
      } else if (field.contains('TS ')) {
        section = 'TS (Technical Sanction)';
      } else if (field.contains('NIT ')) {
        section = 'NIT (Notice Inviting Tender)';
      } else if (field.contains('CSD ')) {
        section = 'CSD (Common Set of Deviations)';
      } else if (field.contains('Technical Evaluation ')) {
        section = 'Technical Evaluation';
      } else if (field.contains('Financial Bid ')) {
        section = 'Financial Bid';
      } else if (field.contains('Bid Acceptance ')) {
        section = 'Bid Acceptance';
      } else if (field.contains('LOA ')) {
        section = 'LOA (Letter of Acceptance)';
      } else if (field.contains('PBG ')) {
        section = 'PBG (Performance Bank Guarantee)';
      } else if (field.contains('Work Order ')) {
        section = 'Work Order';
      } else if (field.contains('LD ')) {
        section = 'LD (Liquidated Damages)';
      } else if (field.contains('EOT ')) {
        section = 'EOT (Extension of Time)';
      } else if (field.contains('COS ')) {
        section = 'COS (Change of Scope)';
      } else if (field.contains('Audit Para ')) {
        section = 'Audit Para';
      } else if (field.contains('LAQ ')) {
        section = 'LAQ (Legislative Questions)';
      } else if (field.contains('Technical Audit ')) {
        section = 'Technical Audit';
      } else if (field.contains('Rev AA ')) {
        section = 'Rev AA (Revised Administrative Approval)';
      } else if (field.contains('Supplementary Agreement ')) {
        section = 'Supplementary Agreement';
      } else if (field.contains('EMD ')) {
        section = 'Bid Submission';
      }

      if (!grouped.containsKey(section)) {
        grouped[section] = [];
      }
      grouped[section]!.add(change);
    }

    return grouped;
  }

  /// Shows the confirmation dialog with all changes
  void _showChangesDialog() {
    final changes = _getChanges();
    final groupedChanges = _groupChangesBySection(changes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Confirm Changes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have made ${changes.length} change${changes.length > 1 ? 's' : ''} to the form:',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: groupedChanges.entries.map((sectionEntry) {
                      final section = sectionEntry.key;
                      final sectionChanges = sectionEntry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section container
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section header
                                Text(
                                  section,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Changes in this section
                                ...sectionChanges.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final change = entry.value;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (index > 0) ...[
                                        const SizedBox(height: 12),
                                        const Divider(
                                          color: AppColors.border,
                                          thickness: 1,
                                          height: 1,
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      Text(
                                        change['field']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'From:',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textTertiary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  change['from']!,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.error,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward,
                                            size: 16,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'To:',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textTertiary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  change['to']!,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.success,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitChanges();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  /// Handles the submission of changes
  void _submitChanges() {
    // TODO: Implement actual submission logic
    // For now, just update the initial state to the current state
    _captureInitialState();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes submitted successfully!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {}); // Refresh to hide submit button
  }

  bool _matchesSearch(String title) {
    if (_searchQuery.isEmpty) return true;
    return title.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  List<Widget> _buildFilteredSections() {
    final List<Widget> sections = [];

    // Helper to add a section with proper spacing
    void addSection(String title, Widget child) {
      if (_matchesSearch(title)) {
        if (sections.isNotEmpty) {
          sections.add(const SizedBox(height: 24));
        }
        sections.add(_buildSection(title: title, child: child));
      }
    }

    // Add all sections
    addSection('1. AA (Administrative Approval)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _aaStatus,
          options: const {'awaited': 'Awaited', 'accorded': 'Accorded'},
          onChanged: (value) => setState(() => _aaStatus = value!),
        ),
        const SizedBox(height: 16),
        if (_aaStatus == 'awaited') ...[
          _buildTextField(label: 'Proposed Amount (Rs. Crore/Lakhs)'),
          const SizedBox(height: 12),
          _buildDateField(label: 'Date of Proposal'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Pending with whom'),
        ],
        if (_aaStatus == 'accorded') ...[
          _buildTextField(label: 'Amount (Rs. Crore/Lakhs)'),
          const SizedBox(height: 12),
          _buildTextField(label: 'AA No.'),
          const SizedBox(height: 12),
          _buildDateField(label: 'Date', fieldKey: 'AA - Date'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Broad Scope', maxLines: 3),
        ],
      ],
    ));

    addSection('2. DPR (Detailed Project Report)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          label: 'Not Started',
          value: _dprStatus == 'not_started',
          onChanged: (val) => setState(() => _dprStatus = 'not_started'),
        ),
        _buildCheckboxOption(
          label: 'In Progress',
          value: _dprStatus == 'in_progress',
          onChanged: (val) => setState(() => _dprStatus = 'in_progress'),
        ),
        if (_dprStatus == 'in_progress') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(
              label: 'Likely Date of Completion',
              fieldKey: 'DPR - Likely Date of Completion',
            ),
          ),
        ],
        _buildCheckboxOptionWithCritical(
          label: 'Submitted',
          value: _dprStatus == 'submitted',
          onChanged: (val) => setState(() => _dprStatus = 'submitted'),
          criticalKey: 'dpr_submitted',
        ),
        _buildCheckboxOption(
          label: 'Approved',
          value: _dprStatus == 'approved',
          onChanged: (val) => setState(() => _dprStatus = 'approved'),
        ),
      ],
    ));

    addSection('3. BOQ (Bill of Quantities)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          label: 'Not Started',
          value: _boqStatus == 'not_started',
          onChanged: (val) => setState(() => _boqStatus = 'not_started'),
        ),
        _buildCheckboxOption(
          label: 'In Progress',
          value: _boqStatus == 'in_progress',
          onChanged: (val) => setState(() => _boqStatus = 'in_progress'),
        ),
        if (_boqStatus == 'in_progress') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(
              label: 'Likely Date of Completion',
              fieldKey: 'BOQ - Likely Date of Completion',
            ),
          ),
        ],
        _buildCheckboxOption(
          label: 'Completed',
          value: _boqStatus == 'completed',
          onChanged: (val) => setState(() => _boqStatus = 'completed'),
        ),
        if (_boqStatus == 'completed') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: DynamicTableWidget(
              title: 'Broad Item wise Break-up of Amounts',
              columnHeaders: const ['Item', 'Description', 'Amount (Rs.)'],
              initialRows: 1,
            ),
          ),
        ],
      ],
    ));

    addSection('4. Schedules', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          label: 'Not Started',
          value: _schedulesStatus == 'not_started',
          onChanged: (val) => setState(() => _schedulesStatus = 'not_started'),
        ),
        _buildCheckboxOption(
          label: 'In Progress',
          value: _schedulesStatus == 'in_progress',
          onChanged: (val) => setState(() => _schedulesStatus = 'in_progress'),
        ),
        if (_schedulesStatus == 'in_progress') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(
              label: 'Likely Date of Completion',
              fieldKey: 'Schedules - Likely Date of Completion',
            ),
          ),
        ],
        _buildCheckboxOptionWithCritical(
          label: 'Submitted',
          value: _schedulesStatus == 'submitted',
          onChanged: (val) => setState(() => _schedulesStatus = 'submitted'),
          criticalKey: 'schedules_submitted',
        ),
        _buildCheckboxOption(
          label: 'Approved',
          value: _schedulesStatus == 'approved',
          onChanged: (val) => setState(() => _schedulesStatus = 'approved'),
        ),
      ],
    ));

    addSection('5. Drawings', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          label: 'Not Started',
          value: _drawingsStatus == 'not_started',
          onChanged: (val) => setState(() => _drawingsStatus = 'not_started'),
        ),
        _buildCheckboxOption(
          label: 'In Progress',
          value: _drawingsStatus == 'in_progress',
          onChanged: (val) => setState(() => _drawingsStatus = 'in_progress'),
        ),
        if (_drawingsStatus == 'in_progress') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(
              label: 'Likely Date of Completion',
              fieldKey: 'Drawings - Likely Date of Completion',
            ),
          ),
        ],
        _buildCheckboxOptionWithCritical(
          label: 'Submitted',
          value: _drawingsStatus == 'submitted',
          onChanged: (val) => setState(() => _drawingsStatus = 'submitted'),
          criticalKey: 'drawings_submitted',
        ),
        _buildCheckboxOption(
          label: 'Approved',
          value: _drawingsStatus == 'approved',
          onChanged: (val) => setState(() => _drawingsStatus = 'approved'),
        ),
      ],
    ));

    addSection('6. Bid Documents (NIT/RFP/Schedules/Drawings Volume)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          label: 'Not Started',
          value: _bidDocumentsStatus == 'not_started',
          onChanged: (val) => setState(() => _bidDocumentsStatus = 'not_started'),
        ),
        _buildCheckboxOption(
          label: 'In Progress',
          value: _bidDocumentsStatus == 'in_progress',
          onChanged: (val) => setState(() => _bidDocumentsStatus = 'in_progress'),
        ),
        if (_bidDocumentsStatus == 'in_progress') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(
              label: 'Likely Date of Completion',
              fieldKey: 'Bid Documents - Likely Date of Completion',
            ),
          ),
        ],
        _buildCheckboxOptionWithCritical(
          label: 'Submitted',
          value: _bidDocumentsStatus == 'submitted',
          onChanged: (val) => setState(() => _bidDocumentsStatus = 'submitted'),
          criticalKey: 'bid_documents_submitted',
        ),
        _buildCheckboxOption(
          label: 'Approved',
          value: _bidDocumentsStatus == 'approved',
          onChanged: (val) => setState(() => _bidDocumentsStatus = 'approved'),
        ),
      ],
    ));

    // 7. ENV (Environmental Clearance)
    addSection('7. ENV (Environmental Clearance)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _envApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) => setState(() => _envApplicability = value!),
        ),
        if (_envApplicability == 'applicable') ...[
          const SizedBox(height: 16),
          _buildApplicableProposalFields(_envProposalStatus, (value) {
            setState(() => _envProposalStatus = value);
          }, section: 'ENV', underPrepCriticalKey: 'env_under_preparation'),
        ],
      ],
    ));

    // 8. LA (Land Acquisition)
    addSection('8. LA (Land Acquisition)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _laApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) => setState(() => _laApplicability = value!),
        ),
        if (_laApplicability == 'applicable') ...[
          const SizedBox(height: 16),
          _buildApplicableProposalFields(_laProposalStatus, (value) {
            setState(() => _laProposalStatus = value);
          }, section: 'LA', underPrepCriticalKey: 'la_under_preparation'),
        ],
      ],
    ));

    // 9. Utility Shifting Details
    addSection('9. Utility Shifting Details', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _utilityShiftingApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) =>
              setState(() => _utilityShiftingApplicability = value!),
        ),
        if (_utilityShiftingApplicability == 'applicable') ...[
          const SizedBox(height: 16),
          _buildApplicableProposalFields(_utilityShiftingProposalStatus,
              (value) {
            setState(() => _utilityShiftingProposalStatus = value);
          }, section: 'Utility Shifting', underPrepCriticalKey: 'utility_under_preparation', submittedDateCriticalKey: 'utility_submitted_date'),
        ],
      ],
    ));

    // 10. TS (Technical Sanction)
    addSection('10. TS (Technical Sanction)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _tsStatus,
          options: const {'awaited': 'Awaited', 'accorded': 'Accorded'},
          onChanged: (value) => setState(() => _tsStatus = value!),
        ),
        const SizedBox(height: 16),
        if (_tsStatus == 'awaited') ...[
          _buildRadioGroup(
            value: _tsAwaitedStatus,
            options: const {
              'not_started': 'Not Started',
              'in_progress': 'In Progress'
            },
            onChanged: (value) => setState(() => _tsAwaitedStatus = value!),
          ),
          if (_tsAwaitedStatus == 'in_progress') ...[
            const SizedBox(height: 12),
            _buildDateFieldWithCritical(
              label: 'Likely Date of Submission',
              criticalKey: 'ts_in_progress_date',
            ),
          ],
          const SizedBox(height: 12),
          _buildTextField(label: 'Status'),
        ],
        if (_tsStatus == 'accorded') ...[
          _buildTextField(label: 'Amount (Rs. Crore/Lakhs)'),
          const SizedBox(height: 12),
          _buildTextField(label: 'TS No.'),
          const SizedBox(height: 12),
          _buildDateField(label: 'Date', fieldKey: 'TS - Date'),
          const SizedBox(height: 12),
          DynamicTableWidget(
            title: 'Detailed Scope',
            columnHeaders: const ['Item', 'Description', 'Amount (Rs.)'],
            initialRows: 1,
          ),
        ],
      ],
    ));

    // 11. NIT (Notice Inviting Tender)
    addSection('11. NIT (Notice Inviting Tender)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _nitStatus,
          options: const {
            'not_issued': 'Not Issued',
            'issued': 'Issued'
          },
          onChanged: (value) => setState(() => _nitStatus = value!),
        ),
        const SizedBox(height: 16),
        if (_nitStatus == 'not_issued') ...[
          _buildDateFieldWithCritical(
            label: 'Likely Date of Issue',
            criticalKey: 'nit_likely_date',
          ),
        ],
        if (_nitStatus == 'issued') ...[
          _buildRadioGroup(
            value: _nitIssuedInputMethod,
            options: const {
              'manual': 'Enter Details Manually',
              'photo': 'Upload Photo'
            },
            onChanged: (value) =>
                setState(() => _nitIssuedInputMethod = value!),
          ),
          const SizedBox(height: 16),
          if (_nitIssuedInputMethod == 'photo') ...[
            _buildPhotoUploadButton(),
          ] else ...[
            _buildDateField(label: 'Date of Issue'),
            const SizedBox(height: 12),
            _buildTextField(label: 'Amount (Rs. in Lakhs)'),
            const SizedBox(height: 12),
            DynamicTableWidget(
              title: 'Broad Items with Amounts and EMD',
              columnHeaders: const ['Item', 'Amount (Rs.)', 'EMD Amount', 'Notes'],
              initialRows: 1,
            ),
            const SizedBox(height: 16),
            Text(
              'Details',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDateField(label: 'Date of Pre-Bid'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Date of Submission'),
          ],
        ],
      ],
    ));

    // 12. Pre-bid
    addSection('12. Pre-bid', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(label: 'Date', fieldKey: 'Pre-bid - Date'),
        const SizedBox(height: 12),
        _buildTextField(label: 'Number of Bidders Participated'),
        const SizedBox(height: 12),
        _buildTextField(label: 'Number of Written Applications Submitted'),
      ],
    ));

    // 13. CSD (Common Set of Deviations)
    addSection('13. CSD (Common Set of Deviations)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioOptionWithCritical(
          label: 'Queries Reply in Progress',
          value: _csdStatus == 'queries_in_progress',
          onChanged: (val) =>
              setState(() => _csdStatus = 'queries_in_progress'),
          criticalKey: 'csd_queries_in_progress',
        ),
        _buildRadioOptionWithCritical(
          label: 'Replies Submitted for Approval',
          value: _csdStatus == 'replies_submitted',
          onChanged: (val) =>
              setState(() => _csdStatus = 'replies_submitted'),
          criticalKey: 'csd_replies_submitted',
        ),
        _buildRadioOption(
          label: 'Replies Approved',
          value: _csdStatus == 'replies_approved',
          onChanged: (val) => setState(() => _csdStatus = 'replies_approved'),
        ),
        _buildRadioOption(
          label: 'CSD Uploaded',
          value: _csdStatus == 'csd_uploaded',
          onChanged: (val) => setState(() => _csdStatus = 'csd_uploaded'),
        ),
        if (_csdStatus == 'csd_uploaded') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(label: 'Date', fieldKey: 'CSD - Date'),
          ),
        ],
      ],
    ));

    // 14. Bid Submission
    addSection('14. Bid Submission', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(label: 'Date', fieldKey: 'Bid Submission - Date'),
        const SizedBox(height: 12),
        _buildTextField(label: 'Number of Bidders Tendered'),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _emdVerificationDone,
              onChanged: (value) =>
                  setState(() => _emdVerificationDone = value!),
            ),
            const Text(
              'EMD Verification Done',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    ));

    // 15. Technical Evaluation
    addSection('15. Technical Evaluation', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          label: 'In Progress',
          value: _technicalEvaluationStatus == 'in_progress',
          onChanged: (val) =>
              setState(() => _technicalEvaluationStatus = 'in_progress'),
        ),
        if (_technicalEvaluationStatus == 'in_progress') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateFieldWithCritical(
              label: 'Likely Date of Completion',
              fieldKey: 'Technical Evaluation - Likely Date of Completion',
              criticalKey: 'tech_eval_in_progress',
            ),
          ),
        ],
        _buildCheckboxOption(
          label: 'Completed',
          value: _technicalEvaluationStatus == 'completed',
          onChanged: (val) =>
              setState(() => _technicalEvaluationStatus = 'completed'),
        ),
        if (_technicalEvaluationStatus == 'completed') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildTextField(label: 'Number of Bidders Qualified'),
          ),
        ],
        _buildCheckboxOption(
          label: 'Qualified Bidders Results Published',
          value: _technicalEvaluationStatus == 'results_published',
          onChanged: (val) => setState(
              () => _technicalEvaluationStatus = 'results_published'),
        ),
        _buildCheckboxOption(
          label: 'Date of Financial Bid Opening Informed',
          value: _technicalEvaluationStatus == 'financial_bid_informed',
          onChanged: (val) => setState(
              () => _technicalEvaluationStatus = 'financial_bid_informed'),
        ),
      ],
    ));

    // 16. Financial Bid
    addSection('16. Financial Bid', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(label: 'Date', fieldKey: 'Financial Bid - Date'),
        const SizedBox(height: 12),
        _buildTextField(
            label:
                '# of Qualified Bidders Participated (must be ≤ qualified count)'),
        const SizedBox(height: 16),
        Text(
          'Bids Opened',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildRadioGroup(
          value: _financialBidOfferType,
          options: const {'l1': 'L1 Offer', 'h1': 'H1 Offer'},
          onChanged: (value) =>
              setState(() => _financialBidOfferType = value!),
        ),
        const SizedBox(height: 12),
        _buildTextField(label: 'Offer Amount (Rs. Lakhs/Cr)'),
        const SizedBox(height: 12),
        _buildTextField(label: 'Percentage (%)'),
        const SizedBox(height: 12),
        _buildRadioGroup(
          value: 'above',
          options: const {'above': 'Above', 'below': 'Below'},
          onChanged: (value) {},
        ),
      ],
    ));

    // 17. Bid Acceptance
    addSection('17. Bid Acceptance', _buildBidAcceptanceRadios());

    // 18. LOA (Letter of Acceptance)
    addSection('18. LOA (Letter of Acceptance)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRadioGroup(
                value: _loaStatus,
                options: const {'issued': 'Issued', 'not_issued': 'Not Issued'},
                onChanged: (value) => setState(() => _loaStatus = value!),
              ),
            ),
            if (_loaStatus == 'issued')
              Tooltip(
                message: _criticalMarkers['loa_issued']! ? 'Marked as Critical' : 'Mark as Critical',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _criticalMarkers['loa_issued'] = !_criticalMarkers['loa_issued']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _criticalMarkers['loa_issued']!
                          ? AppColors.error.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _criticalMarkers['loa_issued']! ? AppColors.error : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _criticalMarkers['loa_issued']! ? Icons.notifications_active : Icons.notifications_outlined,
                      color: _criticalMarkers['loa_issued']! ? AppColors.error : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            if (_loaStatus == 'not_issued')
              Tooltip(
                message: _criticalMarkers['loa_not_issued']! ? 'Marked as Critical' : 'Mark as Critical',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _criticalMarkers['loa_not_issued'] = !_criticalMarkers['loa_not_issued']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _criticalMarkers['loa_not_issued']!
                          ? AppColors.error.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _criticalMarkers['loa_not_issued']! ? AppColors.error : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _criticalMarkers['loa_not_issued']! ? Icons.notifications_active : Icons.notifications_outlined,
                      color: _criticalMarkers['loa_not_issued']! ? AppColors.error : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (_loaStatus == 'not_issued') ...[
          const SizedBox(height: 12),
          _buildTextField(label: 'Reasons', fieldKey: 'LOA - Reasons'),
        ],
      ],
    ));

    // 19. PBG (Performance Bank Guarantee)
    addSection('19. PBG (Performance Bank Guarantee)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRadioGroup(
                value: _pbgStatus,
                options: const {
                  'not_submitted': 'Not Submitted',
                  'submitted': 'Submitted'
                },
                onChanged: (value) => setState(() => _pbgStatus = value!),
              ),
            ),
            if (_pbgStatus == 'not_submitted')
              Tooltip(
                message: _criticalMarkers['pbg_not_submitted']! ? 'Marked as Critical' : 'Mark as Critical',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _criticalMarkers['pbg_not_submitted'] = !_criticalMarkers['pbg_not_submitted']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _criticalMarkers['pbg_not_submitted']!
                          ? AppColors.error.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _criticalMarkers['pbg_not_submitted']! ? AppColors.error : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _criticalMarkers['pbg_not_submitted']! ? Icons.notifications_active : Icons.notifications_outlined,
                      color: _criticalMarkers['pbg_not_submitted']! ? AppColors.error : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (_pbgStatus == 'submitted') ...[
          const SizedBox(height: 12),
          _buildDateField(label: 'Date', fieldKey: 'PBG - Date'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Amount'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Period'),
        ],
      ],
    ));

    // 20. Work Order
    addSection('20. Work Order', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(label: 'Name of Contractor'),
        const SizedBox(height: 16),
        _buildRadioGroup(
          value: _workOrderStatus,
          options: const {
            'not_issued': 'Not Issued',
            'issued': 'Issued'
          },
          onChanged: (value) => setState(() => _workOrderStatus = value!),
        ),
        const SizedBox(height: 12),
        if (_workOrderStatus == 'not_issued') ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(label: 'Reasons', fieldKey: 'Work Order - Reasons'),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _criticalMarkers['work_order_not_issued']! ? 'Marked as Critical' : 'Mark as Critical',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _criticalMarkers['work_order_not_issued'] = !_criticalMarkers['work_order_not_issued']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _criticalMarkers['work_order_not_issued']!
                          ? AppColors.error.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _criticalMarkers['work_order_not_issued']! ? AppColors.error : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _criticalMarkers['work_order_not_issued']! ? Icons.notifications_active : Icons.notifications_outlined,
                      color: _criticalMarkers['work_order_not_issued']! ? AppColors.error : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (_workOrderStatus == 'issued') ...[
          _buildDateField(label: 'Date', fieldKey: 'Work Order - Date'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Amount'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Percentage (%)'),
          const SizedBox(height: 12),
          _buildRadioGroup(
            value: 'above',
            options: const {'above': 'Above', 'below': 'Below'},
            onChanged: (value) {},
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Tender Period'),
          const SizedBox(height: 12),
          _buildTextField(label: 'WO No.'),
        ],
      ],
    ));

    // 21. Agreement Amount
    addSection('21. Agreement Amount', _buildTextField(label: 'Amount (Rs. Lakhs)'));

    // 22. Appointed Date
    addSection('22. Appointed Date', _buildDateField(label: 'Date', fieldKey: 'Appointed Date - Date'));

    // 23. Tender Period
    addSection('23. Tender Period', _buildTextField(label: 'Number of Months'));

    // 24. Milestones (MS-I to MS-V)
    addSection('24. Milestones (MS-I to MS-V)', Column(
      children: List.generate(5, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 16),
            Text(
              'MS-${['I', 'II', 'III', 'IV', 'V'][index]}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(label: 'Period'),
            const SizedBox(height: 8),
            _buildTextField(label: 'Physical Target (%)'),
            const SizedBox(height: 8),
            _buildTextField(label: 'Financial Target (Amount in Rs.)'),
            const SizedBox(height: 8),
            _buildTextField(label: 'Physical Target Achieved (%)'),
            const SizedBox(height: 8),
            _buildTextField(label: 'Financial Target Achieved (Amount +/-)'),
          ],
        );
      }),
    ));

    // 25. LD (Liquidated Damages)
    addSection('25. LD (Liquidated Damages)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _ldApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) => setState(() => _ldApplicability = value!),
        ),
        if (_ldApplicability == 'applicable') ...[
          const SizedBox(height: 12),
          _buildTextField(label: 'Amount Imposed per Week'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Amount Recovered'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Amount Deposited in Account'),
          const SizedBox(height: 12),
          _buildTextField(
              label: 'Amount Released After Achievement of Progress'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Final Amount Recovered from Contractor'),
        ],
      ],
    ));

    // 26. EOT (Extension of Time)
    addSection('26. EOT (Extension of Time)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _eotApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) => setState(() => _eotApplicability = value!),
        ),
        if (_eotApplicability == 'applicable') ...[
          const SizedBox(height: 16),
          _buildEOTCheckboxes(),
        ],
      ],
    ));

    // 27. COS (Change of Scope)
    addSection('27. COS (Change of Scope)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _cosApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) => setState(() => _cosApplicability = value!),
        ),
        if (_cosApplicability == 'applicable') ...[
          const SizedBox(height: 16),
          _buildRadioGroup(
            value: _cosStatus,
            options: const {
              'not_started': 'Proposal Not Started',
              'under_consideration': 'Proposal Under Consideration',
              'submitted': 'Proposal Submitted',
              'approved': 'Proposal Approved'
            },
            onChanged: (value) => setState(() => _cosStatus = value!),
          ),
          const SizedBox(height: 12),
          if (_cosStatus == 'under_consideration') ...[
            Row(
              children: [
                Expanded(
                  child: DynamicTableWidget(
                    title: 'Proposal Under Consideration',
                    columnHeaders: const ['Sr No', 'Item Description', 'Amount (Rs.)', 'Remarks'],
                    initialRows: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: _criticalMarkers['cos_under_consideration']! ? 'Marked as Critical' : 'Mark as Critical',
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _criticalMarkers['cos_under_consideration'] = !_criticalMarkers['cos_under_consideration']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _criticalMarkers['cos_under_consideration']!
                            ? AppColors.error.withValues(alpha: 0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _criticalMarkers['cos_under_consideration']! ? AppColors.error : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _criticalMarkers['cos_under_consideration']! ? Icons.notifications_active : Icons.notifications_outlined,
                        color: _criticalMarkers['cos_under_consideration']! ? AppColors.error : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_cosStatus == 'submitted') ...[
            _buildDateFieldWithCritical(
              label: 'Date',
              fieldKey: 'COS - Date',
              criticalKey: 'cos_submitted_date',
            ),
          ],
          if (_cosStatus == 'approved') ...[
            DynamicTableWidget(
              title: 'Approved Proposal Details',
              columnHeaders: const ['Sr No', 'Item', 'Quantity', 'Rate', 'Amount', 'Status', 'Remarks'],
              initialRows: 1,
            ),
          ],
        ],
      ],
    ));

    // 28. Expenditure (Cumulative)
    addSection('28. Expenditure (Cumulative)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(label: 'Amount'),
        const SizedBox(height: 8),
        Text(
          '(% of Agreement Amount - calculated dynamically)',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ));

    // 29. Audit Para
    addSection('29. Audit Para', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _auditParaApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) =>
              setState(() => _auditParaApplicability = value!),
        ),
        if (_auditParaApplicability == 'applicable') ...[
          const SizedBox(height: 16),
          _buildTextField(label: 'Number of Draft Paras'),
          const SizedBox(height: 12),
          DynamicTableWidget(
            title: 'Details of Paras',
            columnHeaders: const ['Sr No', 'Para Short Description', 'Date of Issue', 'Remarks'],
            initialRows: 1,
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Responsible Person for Replies'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DynamicTableWidget(
                  title: 'Replies Submitted (Number and Dates)',
                  columnHeaders: const ['Sr No', 'Reply Description', 'Date', 'Remarks'],
                  initialRows: 1,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _criticalMarkers['audit_para_replies_submitted']! ? 'Marked as Critical' : 'Mark as Critical',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _criticalMarkers['audit_para_replies_submitted'] = !_criticalMarkers['audit_para_replies_submitted']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _criticalMarkers['audit_para_replies_submitted']!
                          ? AppColors.error.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _criticalMarkers['audit_para_replies_submitted']! ? AppColors.error : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _criticalMarkers['audit_para_replies_submitted']! ? Icons.notifications_active : Icons.notifications_outlined,
                      color: _criticalMarkers['audit_para_replies_submitted']! ? AppColors.error : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DynamicTableWidget(
            title: 'Paras Closed',
            columnHeaders: const ['Sr No', 'Para Description', 'Closure Date', 'Remarks'],
            initialRows: 1,
          ),
        ],
      ],
    ));

    // 30. LAQ (Legislative Questions)
    addSection('30. LAQ (Legislative Questions)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _laqApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) => setState(() => _laqApplicability = value!),
        ),
        if (_laqApplicability == 'applicable') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Number of LAQs')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: 'Number of LCQs')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Number of Lakshvwdhi')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: 'Number of Others')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DynamicTableWidget(
                  title: 'Details of Questions',
                  columnHeaders: const ['Sr No', 'LAQ/LCQ Number', 'Date of Question', 'Remarks'],
                  initialRows: 1,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _criticalMarkers['laq_details_questions']! ? 'Marked as Critical' : 'Mark as Critical',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _criticalMarkers['laq_details_questions'] = !_criticalMarkers['laq_details_questions']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _criticalMarkers['laq_details_questions']!
                          ? AppColors.error.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _criticalMarkers['laq_details_questions']! ? AppColors.error : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _criticalMarkers['laq_details_questions']! ? Icons.notifications_active : Icons.notifications_outlined,
                      color: _criticalMarkers['laq_details_questions']! ? AppColors.error : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Responsible Person for Replies'),
          const SizedBox(height: 12),
          DynamicTableWidget(
            title: 'Replies Submitted (Number and Dates)',
            columnHeaders: const ['Sr No', 'Reply Description', 'Date', 'Remarks'],
            initialRows: 1,
          ),
          const SizedBox(height: 12),
          DynamicTableWidget(
            title: 'Promises Given by Hon Minister/s',
            columnHeaders: const ['Sr No', 'Promise Description', 'Date', 'Remarks'],
            initialRows: 1,
          ),
          const SizedBox(height: 12),
          DynamicTableWidget(
            title: 'Promises Compliance',
            columnHeaders: const ['Sr No', 'Promise', 'Status', 'Date', 'Action Taken'],
            initialRows: 1,
          ),
        ],
      ],
    ));

    // 31. Technical Audit
    addSection('31. Technical Audit', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _technicalAuditStatus,
          options: const {
            'not_done': 'Not Done',
            'carried_out': 'Carried Out'
          },
          onChanged: (value) =>
              setState(() => _technicalAuditStatus = value!),
        ),
        if (_technicalAuditStatus == 'carried_out') ...[
          const SizedBox(height: 16),
          _buildTextField(label: 'Number of Findings'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Details of Findings', maxLines: 3),
          const SizedBox(height: 12),
          _buildTextField(label: 'Responsible EE'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Compliance Submitted (# and Dates)'),
        ],
      ],
    ));

    // 32. Rev AA (Revised Administrative Approval)
    addSection('32. Rev AA (Revised Administrative Approval)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _revAaStatus,
          options: const {
            'not_required': 'Not Required',
            'necessary': 'Necessary'
          },
          onChanged: (value) => setState(() => _revAaStatus = value!),
        ),
        if (_revAaStatus == 'necessary') ...[
          const SizedBox(height: 16),
          _buildTextField(label: 'Reasons', maxLines: 3),
          const SizedBox(height: 12),
          _buildTextField(label: 'Amount Proposed (Rs. Crore/Lakhs)'),
          const SizedBox(height: 16),
          Text(
            'Status',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildRadioOption(
            label: 'In Progress',
            value: _revAaProgressStatus == 'in_progress',
            onChanged: (val) => setState(() => _revAaProgressStatus = 'in_progress'),
          ),
          _buildRadioOptionWithCritical(
            label: 'Submitted',
            value: _revAaProgressStatus == 'submitted',
            onChanged: (val) => setState(() => _revAaProgressStatus = 'submitted'),
            criticalKey: 'rev_aa_submitted',
          ),
          _buildRadioOption(
            label: 'Approved',
            value: _revAaProgressStatus == 'approved',
            onChanged: (val) => setState(() => _revAaProgressStatus = 'approved'),
          ),
          _buildRadioOption(
            label: 'Board Approval',
            value: _revAaProgressStatus == 'board_approval',
            onChanged: (val) => setState(() => _revAaProgressStatus = 'board_approval'),
          ),
          _buildRadioOption(
            label: 'Revised AA Accorded',
            value: _revAaProgressStatus == 'accorded',
            onChanged: (val) => setState(() => _revAaProgressStatus = 'accorded'),
          ),
          if (_revAaProgressStatus == 'accorded') ...[
            const SizedBox(height: 12),
            _buildTextField(label: 'Revised AA No.'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Date', fieldKey: 'Rev AA - Date'),
            const SizedBox(height: 12),
            _buildPhotoUploadButton(label: 'RAA Table of Recap Sheet'),
          ],
        ],
      ],
    ));

    // 33. Supplementary Agreement
    addSection('33. Supplementary Agreement', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _supplementaryAgreementApplicability,
          options: const {
            'not_applicable': 'Not Applicable',
            'applicable': 'Applicable'
          },
          onChanged: (value) => setState(
              () => _supplementaryAgreementApplicability = value!),
        ),
        if (_supplementaryAgreementApplicability == 'applicable') ...[
          const SizedBox(height: 16),
          _buildTextField(label: 'Necessity', maxLines: 3),
          const SizedBox(height: 12),
          _buildTextField(label: 'Amount (Rs. Lakhs)'),
          const SizedBox(height: 12),
          _buildDateField(label: 'Date', fieldKey: 'Supplementary Agreement - Date'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Scope of Work', maxLines: 3),
          const SizedBox(height: 12),
          _buildTextField(label: 'Period (Months)'),
        ],
      ],
    ));

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final hasChanges = _hasChanges();
    final changesCount = hasChanges ? _getChanges().length : 0;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Header with title and search
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                // Title - compact
                Text(
                  'Work Entry Form',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(width: 24),
                // Search bar - larger
                Expanded(
                  child: Container(
                    height: 40,
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search sections...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                // Submit button - only visible when there are changes
                if (hasChanges) ...[
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _showChangesDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$changesCount',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Submit'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Form sections - scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildFilteredSections(),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Helper Widgets

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? fieldKey,
  }) {
    // Get or create controller for this field
    // Use fieldKey if provided, otherwise use label
    final controllerKey = fieldKey ?? label;
    final controller = _getController(controllerKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.surface,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, String? fieldKey}) {
    // Get or create controller for this field
    // Use fieldKey if provided, otherwise use label
    final controllerKey = fieldKey ?? label;
    final controller = _getController(controllerKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.surface,
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = '${date.day}/${date.month}/${date.year}';
            }
          },
        ),
      ],
    );
  }

  Widget _buildRadioGroup({
    required String value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: options.entries.map((entry) {
        return InkWell(
          onTap: () => onChanged(entry.key),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: entry.key,
                  groupValue: value,
                  onChanged: onChanged,
                ),
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: value ? true : false,
              onChanged: onChanged,
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOptionWithCritical({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String criticalKey,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: _criticalMarkers[criticalKey]! ? 'Marked as Critical' : 'Mark as Critical',
              child: InkWell(
                onTap: () {
                  setState(() {
                    _criticalMarkers[criticalKey] = !_criticalMarkers[criticalKey]!;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _criticalMarkers[criticalKey]!
                        ? AppColors.error.withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _criticalMarkers[criticalKey]! ? AppColors.error : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _criticalMarkers[criticalKey]! ? Icons.notifications_active : Icons.notifications_outlined,
                    color: _criticalMarkers[criticalKey]! ? AppColors.error : AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOptionWithCritical({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String criticalKey,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: value ? true : false,
              onChanged: onChanged,
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: _criticalMarkers[criticalKey]! ? 'Marked as Critical' : 'Mark as Critical',
              child: InkWell(
                onTap: () {
                  setState(() {
                    _criticalMarkers[criticalKey] = !_criticalMarkers[criticalKey]!;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _criticalMarkers[criticalKey]!
                        ? AppColors.error.withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _criticalMarkers[criticalKey]! ? AppColors.error : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _criticalMarkers[criticalKey]! ? Icons.notifications_active : Icons.notifications_outlined,
                    color: _criticalMarkers[criticalKey]! ? AppColors.error : AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFieldWithCritical({
    required String label,
    String? fieldKey,
    required String criticalKey,
  }) {
    final controllerKey = fieldKey ?? label;
    final controller = _getController(controllerKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Tooltip(
              message: _criticalMarkers[criticalKey]! ? 'Marked as Critical' : 'Mark as Critical',
              child: InkWell(
                onTap: () {
                  setState(() {
                    _criticalMarkers[criticalKey] = !_criticalMarkers[criticalKey]!;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _criticalMarkers[criticalKey]!
                        ? AppColors.error.withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _criticalMarkers[criticalKey]! ? AppColors.error : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _criticalMarkers[criticalKey]! ? Icons.notifications_active : Icons.notifications_outlined,
                    color: _criticalMarkers[criticalKey]! ? AppColors.error : AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.surface,
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = '${date.day}/${date.month}/${date.year}';
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatusCheckboxes({
    required String status,
    required ValueChanged<String> onChanged,
    String section = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          label: 'Not Started',
          value: status == 'not_started',
          onChanged: (val) => onChanged('not_started'),
        ),
        _buildCheckboxOption(
          label: 'In Progress',
          value: status == 'in_progress',
          onChanged: (val) => onChanged('in_progress'),
        ),
        if (status == 'in_progress') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(
              label: 'Likely Date of Completion',
              fieldKey: section.isNotEmpty
                ? '$section - Likely Date of Completion'
                : 'Likely Date of Completion',
            ),
          ),
        ],
        _buildCheckboxOption(
          label: 'Submitted',
          value: status == 'submitted',
          onChanged: (val) => onChanged('submitted'),
        ),
        _buildCheckboxOption(
          label: 'Approved',
          value: status == 'approved',
          onChanged: (val) => onChanged('approved'),
        ),
      ],
    );
  }

  Widget _buildApplicableProposalFields(
      String status, ValueChanged<String> onChanged, {String section = '', String? underPrepCriticalKey, String? submittedDateCriticalKey}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioOption(
          label: 'Proposal Not Started',
          value: status == 'not_started',
          onChanged: (val) => onChanged('not_started'),
        ),
        underPrepCriticalKey != null
            ? _buildRadioOptionWithCritical(
                label: 'Proposal Under Preparation',
                value: status == 'under_preparation',
                onChanged: (val) => onChanged('under_preparation'),
                criticalKey: underPrepCriticalKey,
              )
            : _buildRadioOption(
                label: 'Proposal Under Preparation',
                value: status == 'under_preparation',
                onChanged: (val) => onChanged('under_preparation'),
              ),
        _buildRadioOption(
          label: 'Proposal Submitted',
          value: status == 'submitted',
          onChanged: (val) => onChanged('submitted'),
        ),
        if (status == 'submitted') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: submittedDateCriticalKey != null
                ? _buildDateFieldWithCritical(
                    label: 'Date',
                    fieldKey: section.isNotEmpty ? '$section - Date' : 'Date',
                    criticalKey: submittedDateCriticalKey,
                  )
                : _buildDateField(
                    label: 'Date',
                    fieldKey: section.isNotEmpty ? '$section - Date' : 'Date',
                  ),
          ),
        ],
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Status',
          fieldKey: section.isNotEmpty ? '$section - Status' : 'Status',
        ),
      ],
    );
  }

  Widget _buildBidAcceptanceRadios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioOptionWithCritical(
          label: 'In Progress',
          value: _bidAcceptanceStatus == 'in_progress',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'in_progress'),
          criticalKey: 'bid_accept_in_progress',
        ),
        _buildRadioOptionWithCritical(
          label: 'Submitted',
          value: _bidAcceptanceStatus == 'submitted',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'submitted'),
          criticalKey: 'bid_accept_submitted',
        ),
        _buildRadioOption(
          label: 'Approved',
          value: _bidAcceptanceStatus == 'approved',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'approved'),
        ),
        _buildRadioOptionWithCritical(
          label: 'Board Approval',
          value: _bidAcceptanceStatus == 'board_approval',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'board_approval'),
          criticalKey: 'bid_accept_board_approval',
        ),
        _buildRadioOption(
          label: 'Accepted',
          value: _bidAcceptanceStatus == 'accepted',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'accepted'),
        ),
      ],
    );
  }

  Widget _buildEOTCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          label: 'Proposal Not Started',
          value: _eotOptions.contains('not_started'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('not_started');
              } else {
                _eotOptions.remove('not_started');
              }
            });
          },
        ),
        _buildCheckboxOption(
          label: 'Proposal Under Consideration',
          value: _eotOptions.contains('under_consideration'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('under_consideration');
              } else {
                _eotOptions.remove('under_consideration');
              }
            });
          },
        ),
        if (_eotOptions.contains('under_consideration')) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildTextField(label: 'Period (Months)'),
          ),
        ],
        _buildCheckboxOptionWithCritical(
          label: 'Proposal Submitted',
          value: _eotOptions.contains('submitted'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('submitted');
              } else {
                _eotOptions.remove('submitted');
              }
            });
          },
          criticalKey: 'eot_submitted_date',
        ),
        if (_eotOptions.contains('submitted')) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(label: 'Date', fieldKey: 'EOT - Date'),
          ),
        ],
        _buildCheckboxOption(
          label: 'EOT Approved',
          value: _eotOptions.contains('approved'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('approved');
              } else {
                _eotOptions.remove('approved');
              }
            });
          },
        ),
        if (_eotOptions.contains('approved')) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildTextField(label: 'Period (Months)'),
          ),
        ],
        _buildCheckboxOption(
          label: 'With Escalation',
          value: _eotOptions.contains('with_escalation'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('with_escalation');
              } else {
                _eotOptions.remove('with_escalation');
              }
            });
          },
        ),
        _buildCheckboxOption(
          label: 'Without Escalation',
          value: _eotOptions.contains('without_escalation'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('without_escalation');
              } else {
                _eotOptions.remove('without_escalation');
              }
            });
          },
        ),
        _buildCheckboxOption(
          label: 'By Freezing Indices',
          value: _eotOptions.contains('by_freezing_indices'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('by_freezing_indices');
              } else {
                _eotOptions.remove('by_freezing_indices');
              }
            });
          },
        ),
        _buildCheckboxOption(
          label: 'Without LD',
          value: _eotOptions.contains('without_ld'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('without_ld');
              } else {
                _eotOptions.remove('without_ld');
              }
            });
          },
        ),
        _buildCheckboxOption(
          label: 'With LD',
          value: _eotOptions.contains('with_ld'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('with_ld');
              } else {
                _eotOptions.remove('with_ld');
              }
            });
          },
        ),
        _buildCheckboxOption(
          label: 'Compensation Payable',
          value: _eotOptions.contains('compensation_payable'),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _eotOptions.add('compensation_payable');
              } else {
                _eotOptions.remove('compensation_payable');
              }
            });
          },
        ),
        if (_eotOptions.contains('compensation_payable')) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRadioGroup(
                  value: 'yes',
                  options: const {'yes': 'Yes', 'no': 'No'},
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                _buildTextField(label: 'Amount of Compensation Claimed'),
                const SizedBox(height: 12),
                _buildTextField(label: 'Compensation Admitted - Amount'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTablePlaceholder({
    required int rows,
    required int columns,
    required String title,
    List<String>? headers,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Table ($rows × $columns)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (headers != null) ...[
            const SizedBox(height: 8),
            Text(
              'Columns: ${headers.join(', ')}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open table editor
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Table'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadButton({String label = 'Upload Photo'}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Handle photo upload
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Choose File'),
          ),
        ],
      ),
    );
  }
}