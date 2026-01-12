import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/models/project.dart';

/// Work Entry Form Widget - UI Only version (no database)
/// Contains all 33 sections matching the original MSIDC UI
class WorkEntryFormWidget extends StatefulWidget {
  final Project project;

  const WorkEntryFormWidget({
    super.key,
    required this.project,
  });

  @override
  State<WorkEntryFormWidget> createState() => _WorkEntryFormWidgetState();
}

class _WorkEntryFormWidgetState extends State<WorkEntryFormWidget> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Form state variables (simplified - no database)
  String _aaStatus = 'awaited';
  String _dprStatus = 'not_started';
  String _boqStatus = 'not_started';
  String _schedulesStatus = 'not_started';
  String _drawingsStatus = 'not_started';
  String _bidDocumentsStatus = 'not_started';
  String _envApplicability = 'not_applicable';
  String _envProposalStatus = 'not_started';
  String _laApplicability = 'not_applicable';
  String _laProposalStatus = 'not_started';
  String _utilityShiftingApplicability = 'not_applicable';
  String _utilityShiftingProposalStatus = 'not_started';
  String _tsStatus = 'awaited';
  String _tsAwaitedStatus = 'not_started';
  String _nitStatus = 'not_issued';
  String _csdStatus = 'queries_in_progress';
  String _technicalEvaluationStatus = 'in_progress';
  String _financialBidOfferType = 'l1';
  String _bidAcceptanceStatus = 'in_progress';
  String _loaStatus = 'not_issued';
  String _pbgStatus = 'not_submitted';
  String _workOrderStatus = 'not_issued';
  String _ldApplicability = 'not_applicable';
  String _eotApplicability = 'not_applicable';
  String _cosApplicability = 'not_applicable';
  String _cosStatus = 'not_started';
  String _auditParaApplicability = 'not_applicable';
  String _laqApplicability = 'not_applicable';
  String _technicalAuditStatus = 'not_done';
  String _revAaStatus = 'not_required';
  String _revAaProgressStatus = 'in_progress';
  String _supplementaryAgreementApplicability = 'not_applicable';

  // Text controllers for various fields
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String key) {
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController();
    }
    return _textControllers[key]!;
  }

  bool _matchesSearch(String text) {
    if (_searchQuery.isEmpty) return true;
    return text.toLowerCase().contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Header with title and search
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                Text(
                  'Work Entry Form',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(width: 24),
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

  List<Widget> _buildFilteredSections() {
    final List<Widget> sections = [];

    void addSection(String title, Widget child) {
      if (_matchesSearch(title)) {
        if (sections.isNotEmpty) {
          sections.add(const SizedBox(height: 24));
        }
        sections.add(_buildSection(title: title, child: child));
      }
    }

    // Section 1: AA
    addSection(
      '1. AA (Administrative Approval)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _aaStatus,
            options: const {'awaited': 'Awaited', 'accorded': 'Accorded'},
            onChanged: (value) => setState(() => _aaStatus = value!),
          ),
          const SizedBox(height: 16),
          if (_aaStatus == 'awaited') ...[
            _buildTextField(
                label: 'Proposed Amount (Rs. Crore/Lakhs)', key: 'aa_proposed_amount'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Date of Proposal', key: 'aa_date_of_proposal'),
          ],
          if (_aaStatus == 'accorded') ...[
            _buildTextField(label: 'Amount (Rs. Crore/Lakhs)', key: 'aa_amount'),
            const SizedBox(height: 12),
            _buildTextField(label: 'AA No.', key: 'aa_no'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Date', key: 'aa_date'),
            const SizedBox(height: 12),
            _buildTextField(label: 'Broad Scope', maxLines: 3, key: 'aa_broad_scope'),
          ],
        ],
      ),
    );

    // Section 2: DPR
    addSection(
      '2. DPR (Detailed Project Report)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioOption(
            label: 'Not Started',
            value: _dprStatus == 'not_started',
            onChanged: () => setState(() => _dprStatus = 'not_started'),
          ),
          _buildRadioOption(
            label: 'In Progress',
            value: _dprStatus == 'in_progress',
            onChanged: () => setState(() => _dprStatus = 'in_progress'),
          ),
          if (_dprStatus == 'in_progress') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: _buildDateField(
                  label: 'Likely Date of Completion', key: 'dpr_likely_date'),
            ),
          ],
          _buildRadioOption(
            label: 'Submitted',
            value: _dprStatus == 'submitted',
            onChanged: () => setState(() => _dprStatus = 'submitted'),
          ),
          _buildRadioOption(
            label: 'Approved',
            value: _dprStatus == 'approved',
            onChanged: () => setState(() => _dprStatus = 'approved'),
          ),
        ],
      ),
    );

    // Section 3: BOQ
    addSection(
      '3. BOQ (Bill of Quantities)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioOption(
            label: 'Not Started',
            value: _boqStatus == 'not_started',
            onChanged: () => setState(() => _boqStatus = 'not_started'),
          ),
          _buildRadioOption(
            label: 'In Progress',
            value: _boqStatus == 'in_progress',
            onChanged: () => setState(() => _boqStatus = 'in_progress'),
          ),
          if (_boqStatus == 'in_progress') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: _buildDateField(
                  label: 'Likely Date of Completion', key: 'boq_likely_date'),
            ),
          ],
          _buildRadioOption(
            label: 'Completed',
            value: _boqStatus == 'completed',
            onChanged: () => setState(() => _boqStatus = 'completed'),
          ),
        ],
      ),
    );

    // Section 4: Schedules
    addSection(
      '4. Schedules',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioOption(
            label: 'Not Started',
            value: _schedulesStatus == 'not_started',
            onChanged: () => setState(() => _schedulesStatus = 'not_started'),
          ),
          _buildRadioOption(
            label: 'In Progress',
            value: _schedulesStatus == 'in_progress',
            onChanged: () => setState(() => _schedulesStatus = 'in_progress'),
          ),
          if (_schedulesStatus == 'in_progress') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: _buildDateField(
                  label: 'Likely Date of Completion', key: 'schedules_likely_date'),
            ),
          ],
          _buildRadioOption(
            label: 'Submitted',
            value: _schedulesStatus == 'submitted',
            onChanged: () => setState(() => _schedulesStatus = 'submitted'),
          ),
          _buildRadioOption(
            label: 'Approved',
            value: _schedulesStatus == 'approved',
            onChanged: () => setState(() => _schedulesStatus = 'approved'),
          ),
        ],
      ),
    );

    // Section 5: Drawings
    addSection(
      '5. Drawings',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioOption(
            label: 'Not Started',
            value: _drawingsStatus == 'not_started',
            onChanged: () => setState(() => _drawingsStatus = 'not_started'),
          ),
          _buildRadioOption(
            label: 'In Progress',
            value: _drawingsStatus == 'in_progress',
            onChanged: () => setState(() => _drawingsStatus = 'in_progress'),
          ),
          if (_drawingsStatus == 'in_progress') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: _buildDateField(
                  label: 'Likely Date of Completion', key: 'drawings_likely_date'),
            ),
          ],
          _buildRadioOption(
            label: 'Submitted',
            value: _drawingsStatus == 'submitted',
            onChanged: () => setState(() => _drawingsStatus = 'submitted'),
          ),
          _buildRadioOption(
            label: 'Approved',
            value: _drawingsStatus == 'approved',
            onChanged: () => setState(() => _drawingsStatus = 'approved'),
          ),
        ],
      ),
    );

    // Section 6: Bid Documents
    addSection(
      '6. Bid Documents (NIT/RFP/Schedules/Drawings Volume)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioOption(
            label: 'Not Started',
            value: _bidDocumentsStatus == 'not_started',
            onChanged: () => setState(() => _bidDocumentsStatus = 'not_started'),
          ),
          _buildRadioOption(
            label: 'In Progress',
            value: _bidDocumentsStatus == 'in_progress',
            onChanged: () => setState(() => _bidDocumentsStatus = 'in_progress'),
          ),
          if (_bidDocumentsStatus == 'in_progress') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: _buildDateField(
                  label: 'Likely Date of Completion', key: 'bid_docs_likely_date'),
            ),
          ],
          _buildRadioOption(
            label: 'Submitted',
            value: _bidDocumentsStatus == 'submitted',
            onChanged: () => setState(() => _bidDocumentsStatus = 'submitted'),
          ),
          _buildRadioOption(
            label: 'Approved',
            value: _bidDocumentsStatus == 'approved',
            onChanged: () => setState(() => _bidDocumentsStatus = 'approved'),
          ),
        ],
      ),
    );

    // Section 7: ENV
    addSection(
      '7. ENV (Environmental Clearance)',
      Column(
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
            _buildRadioOption(
              label: 'Not Started',
              value: _envProposalStatus == 'not_started',
              onChanged: () => setState(() => _envProposalStatus = 'not_started'),
            ),
            _buildRadioOption(
              label: 'Under Preparation',
              value: _envProposalStatus == 'under_preparation',
              onChanged: () =>
                  setState(() => _envProposalStatus = 'under_preparation'),
            ),
            _buildRadioOption(
              label: 'Submitted',
              value: _envProposalStatus == 'submitted',
              onChanged: () => setState(() => _envProposalStatus = 'submitted'),
            ),
          ],
        ],
      ),
    );

    // Section 8: LA
    addSection(
      '8. LA (Land Acquisition)',
      Column(
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
            _buildRadioOption(
              label: 'Not Started',
              value: _laProposalStatus == 'not_started',
              onChanged: () => setState(() => _laProposalStatus = 'not_started'),
            ),
            _buildRadioOption(
              label: 'Under Preparation',
              value: _laProposalStatus == 'under_preparation',
              onChanged: () =>
                  setState(() => _laProposalStatus = 'under_preparation'),
            ),
            _buildRadioOption(
              label: 'Submitted',
              value: _laProposalStatus == 'submitted',
              onChanged: () => setState(() => _laProposalStatus = 'submitted'),
            ),
          ],
        ],
      ),
    );

    // Section 9: Utility Shifting
    addSection(
      '9. Utility Shifting Details',
      Column(
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
            _buildRadioOption(
              label: 'Not Started',
              value: _utilityShiftingProposalStatus == 'not_started',
              onChanged: () =>
                  setState(() => _utilityShiftingProposalStatus = 'not_started'),
            ),
            _buildRadioOption(
              label: 'Under Preparation',
              value: _utilityShiftingProposalStatus == 'under_preparation',
              onChanged: () => setState(
                  () => _utilityShiftingProposalStatus = 'under_preparation'),
            ),
            _buildRadioOption(
              label: 'Submitted',
              value: _utilityShiftingProposalStatus == 'submitted',
              onChanged: () =>
                  setState(() => _utilityShiftingProposalStatus = 'submitted'),
            ),
          ],
        ],
      ),
    );

    // Section 10: TS
    addSection(
      '10. TS (Technical Sanction)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _tsStatus,
            options: const {'awaited': 'Awaited', 'accorded': 'Accorded'},
            onChanged: (value) => setState(() => _tsStatus = value!),
          ),
          const SizedBox(height: 16),
          if (_tsStatus == 'awaited') ...[
            _buildRadioOption(
              label: 'Not Started',
              value: _tsAwaitedStatus == 'not_started',
              onChanged: () => setState(() => _tsAwaitedStatus = 'not_started'),
            ),
            _buildRadioOption(
              label: 'In Progress',
              value: _tsAwaitedStatus == 'in_progress',
              onChanged: () => setState(() => _tsAwaitedStatus = 'in_progress'),
            ),
            if (_tsAwaitedStatus == 'in_progress') ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: _buildDateField(
                    label: 'Likely Date of Completion', key: 'ts_likely_date'),
              ),
            ],
          ],
          if (_tsStatus == 'accorded') ...[
            _buildTextField(label: 'TS No.', key: 'ts_no'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Date', key: 'ts_date'),
          ],
        ],
      ),
    );

    // Sections 11-33 (Simplified placeholders maintaining UI structure)
    _addSimplifiedSections(addSection);

    return sections;
  }

  void _addSimplifiedSections(
      void Function(String, Widget) addSection) {
    // Section 11: NIT
    addSection(
      '11. NIT (Notice Inviting Tender)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _nitStatus,
            options: const {'not_issued': 'Not Issued', 'issued': 'Issued'},
            onChanged: (value) => setState(() => _nitStatus = value!),
          ),
          if (_nitStatus == 'issued') ...[
            const SizedBox(height: 16),
            _buildTextField(label: 'NIT No.', key: 'nit_no'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Issue Date', key: 'nit_issue_date'),
          ],
        ],
      ),
    );

    // Section 12: Pre-bid
    addSection(
      '12. Pre-bid',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(label: 'No. of Participants', key: 'prebid_participants'),
          const SizedBox(height: 12),
          _buildDateField(label: 'Date', key: 'prebid_date'),
        ],
      ),
    );

    // Section 13: CSD
    addSection(
      '13. CSD (Common Set of Deviations)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _csdStatus,
            options: const {
              'queries_in_progress': 'Queries in Progress',
              'replies_submitted': 'Replies Submitted',
              'replies_approved': 'Replies Approved',
              'csd_uploaded': 'CSD Uploaded'
            },
            onChanged: (value) => setState(() => _csdStatus = value!),
          ),
        ],
      ),
    );

    // Section 14: Bid Submission
    addSection(
      '14. Bid Submission',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(label: 'No. of Bids Received', key: 'bids_received'),
          const SizedBox(height: 12),
          _buildDateField(label: 'Submission Date', key: 'bid_submission_date'),
        ],
      ),
    );

    // Section 15: Technical Evaluation
    addSection(
      '15. Technical Evaluation)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _technicalEvaluationStatus,
            options: const {
              'in_progress': 'In Progress',
              'completed': 'Completed',
              'results_published': 'Results Published',
              'financial_bid_informed': 'Financial Bid Informed'
            },
            onChanged: (value) =>
                setState(() => _technicalEvaluationStatus = value!),
          ),
        ],
      ),
    );

    // Section 16: Financial Bid
    addSection(
      '16. Financial Bid',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _financialBidOfferType,
            options: const {'l1': 'L1 (Lowest)', 'h1': 'H1 (Highest)'},
            onChanged: (value) => setState(() => _financialBidOfferType = value!),
          ),
          const SizedBox(height: 16),
          _buildTextField(
              label: 'Contractor Name', key: 'financial_bid_contractor'),
          const SizedBox(height: 12),
          _buildTextField(
              label: 'Quoted Amount (Rs. Crore)', key: 'financial_bid_amount'),
        ],
      ),
    );

    // Section 17: Bid Acceptance
    addSection(
      '17. Bid Acceptance',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _bidAcceptanceStatus,
            options: const {
              'in_progress': 'In Progress',
              'submitted': 'Submitted',
              'approved': 'Approved',
              'board_approval': 'Board Approval',
              'accepted': 'Accepted'
            },
            onChanged: (value) => setState(() => _bidAcceptanceStatus = value!),
          ),
        ],
      ),
    );

    // Section 18: LOA
    addSection(
      '18. LOA (Letter of Acceptance)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _loaStatus,
            options: const {'not_issued': 'Not Issued', 'issued': 'Issued'},
            onChanged: (value) => setState(() => _loaStatus = value!),
          ),
          if (_loaStatus == 'issued') ...[
            const SizedBox(height: 16),
            _buildTextField(label: 'LOA No.', key: 'loa_no'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Issue Date', key: 'loa_issue_date'),
          ],
        ],
      ),
    );

    // Section 19: PBG
    addSection(
      '19. PBG (Performance Bank Guarantee)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _pbgStatus,
            options: const {'not_submitted': 'Not Submitted', 'submitted': 'Submitted'},
            onChanged: (value) => setState(() => _pbgStatus = value!),
          ),
          if (_pbgStatus == 'submitted') ...[
            const SizedBox(height: 16),
            _buildTextField(label: 'PBG Amount (Rs.)', key: 'pbg_amount'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Submission Date', key: 'pbg_date'),
          ],
        ],
      ),
    );

    // Section 20: Work Order
    addSection(
      '20. Work Order',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _workOrderStatus,
            options: const {'not_issued': 'Not Issued', 'issued': 'Issued'},
            onChanged: (value) => setState(() => _workOrderStatus = value!),
          ),
          if (_workOrderStatus == 'issued') ...[
            const SizedBox(height: 16),
            _buildTextField(label: 'Work Order No.', key: 'wo_no'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Issue Date', key: 'wo_issue_date'),
          ],
        ],
      ),
    );

    // Section 21-25: Contract Details
    addSection(
      '21. Agreement Amount',
      _buildTextField(
          label: 'Amount (Rs. Crore)', key: 'agreement_amount'),
    );

    addSection(
      '22. Appointed Date',
      _buildDateField(label: 'Date', key: 'appointed_date'),
    );

    addSection(
      '23. Tender Period',
      Column(
        children: [
          _buildTextField(
              label: 'Period (Months)', keyboardType: TextInputType.number, key: 'tender_period'),
          const SizedBox(height: 12),
          _buildDateField(label: 'Completion Date', key: 'completion_date'),
        ],
      ),
    );

    addSection(
      '24. Milestones (MS-I to MS-V)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Milestone ${index + 1}',
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
                      child: _buildTextField(
                          label: 'Description', key: 'ms${index + 1}_desc'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                          label: 'Target Date', key: 'ms${index + 1}_date'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );

    // Section 25: LD
    addSection(
      '25. LD (Liquidated Damages)',
      Column(
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
            const SizedBox(height: 16),
            _buildTextField(label: 'LD Amount (Rs.)', key: 'ld_amount'),
          ],
        ],
      ),
    );

    // Section 26: EOT
    addSection(
      '26. EOT (Extension of Time)',
      Column(
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
            _buildTextField(
                label: 'Extended Period (Days)',
                keyboardType: TextInputType.number,
                key: 'eot_days'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Approval Date', key: 'eot_approval_date'),
          ],
        ],
      ),
    );

    // Section 27: COS
    addSection(
      '27. COS (Change of Scope)',
      Column(
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
                'not_started': 'Not Started',
                'under_consideration': 'Under Consideration',
                'submitted': 'Submitted',
                'approved': 'Approved'
              },
              onChanged: (value) => setState(() => _cosStatus = value!),
            ),
          ],
        ],
      ),
    );

    // Section 28: Expenditure
    addSection(
      '28. Expenditure (Cumulative)',
      _buildTextField(
          label: 'Total Expenditure (Rs. Crore)', key: 'expenditure'),
    );

    // Section 29: Audit Para
    addSection(
      '29. Audit Para',
      Column(
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
            _buildTextField(
                label: 'Para Details', maxLines: 3, key: 'audit_para_details'),
          ],
        ],
      ),
    );

    // Section 30: LAQ
    addSection(
      '30. LAQ (Legislative Questions)',
      Column(
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
            _buildTextField(
                label: 'Question Details', maxLines: 3, key: 'laq_details'),
          ],
        ],
      ),
    );

    // Section 31: Technical Audit
    addSection(
      '31. Technical Audit',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _technicalAuditStatus,
            options: const {'not_done': 'Not Done', 'carried_out': 'Carried Out'},
            onChanged: (value) =>
                setState(() => _technicalAuditStatus = value!),
          ),
          if (_technicalAuditStatus == 'carried_out') ...[
            const SizedBox(height: 16),
            _buildDateField(label: 'Audit Date', key: 'tech_audit_date'),
          ],
        ],
      ),
    );

    // Section 32: Rev AA
    addSection(
      '32. Rev AA (Revised Administrative Approval)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _revAaStatus,
            options: const {'not_required': 'Not Required', 'necessary': 'Necessary'},
            onChanged: (value) => setState(() => _revAaStatus = value!),
          ),
          if (_revAaStatus == 'necessary') ...[
            const SizedBox(height: 16),
            _buildRadioGroup(
              value: _revAaProgressStatus,
              options: const {
                'in_progress': 'In Progress',
                'submitted': 'Submitted',
                'approved': 'Approved',
                'board_approval': 'Board Approval',
                'accorded': 'Accorded'
              },
              onChanged: (value) =>
                  setState(() => _revAaProgressStatus = value!),
            ),
          ],
        ],
      ),
    );

    // Section 33: Supplementary Agreement
    addSection(
      '33. Supplementary Agreement',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadioGroup(
            value: _supplementaryAgreementApplicability,
            options: const {
              'not_applicable': 'Not Applicable',
              'applicable': 'Applicable'
            },
            onChanged: (value) =>
                setState(() => _supplementaryAgreementApplicability = value!),
          ),
          if (_supplementaryAgreementApplicability == 'applicable') ...[
            const SizedBox(height: 16),
            _buildTextField(
                label: 'Agreement Details', maxLines: 3, key: 'supp_agreement_details'),
          ],
        ],
      ),
    );
  }

  // UI Builder Methods

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
    required String key,
  }) {
    final controller = _getController(key);

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

  Widget _buildDateField({required String label, required String key}) {
    final controller = _getController(key);

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
      spacing: 24,
      runSpacing: 12,
      children: options.entries.map((entry) {
        return InkWell(
          onTap: () => onChanged(entry.key),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: entry.key,
                  groupValue: value,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 4),
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
    required VoidCallback onChanged,
  }) {
    return InkWell(
      onTap: onChanged,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: value ? true : false,
              onChanged: (_) => onChanged(),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
