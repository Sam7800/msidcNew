import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _buildDateField(label: 'Date'),
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
            child: _buildDateField(label: 'Likely Date of Completion'),
          ),
        ],
        _buildCheckboxOption(
          label: 'Submitted',
          value: _dprStatus == 'submitted',
          onChanged: (val) => setState(() => _dprStatus = 'submitted'),
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
            child: _buildDateField(label: 'Likely Date of Completion'),
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
            child: _buildTablePlaceholder(
              rows: 5,
              columns: 3,
              title: 'Broad Item wise Break-up of Amounts',
            ),
          ),
        ],
      ],
    ));

    addSection('4. Schedules', _buildStatusCheckboxes(
      status: _schedulesStatus,
      onChanged: (value) => setState(() => _schedulesStatus = value),
    ));

    addSection('5. Drawings', _buildStatusCheckboxes(
      status: _drawingsStatus,
      onChanged: (value) => setState(() => _drawingsStatus = value),
    ));

    addSection('6. Bid Documents (NIT/RFP/Schedules/Drawings Volume)', _buildStatusCheckboxes(
      status: _bidDocumentsStatus,
      onChanged: (value) => setState(() => _bidDocumentsStatus = value),
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
          }),
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
          }),
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
          }),
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
            _buildDateField(label: 'Likely Date of Submission'),
          ],
          const SizedBox(height: 12),
          _buildTextField(label: 'Status'),
        ],
        if (_tsStatus == 'accorded') ...[
          _buildTextField(label: 'Amount (Rs. Crore/Lakhs)'),
          const SizedBox(height: 12),
          _buildTextField(label: 'TS No.'),
          const SizedBox(height: 12),
          _buildDateField(label: 'Date'),
          const SizedBox(height: 12),
          _buildTablePlaceholder(
            rows: 8,
            columns: 3,
            title: 'Detailed Scope',
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
          _buildDateField(label: 'Likely Date of Issue'),
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
            _buildTablePlaceholder(
              rows: 4,
              columns: 4,
              title: 'Broad Items with Amounts and EMD',
              headers: const ['Item', 'Amount', 'EMD', 'Notes'],
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
        _buildDateField(label: 'Date'),
        const SizedBox(height: 12),
        _buildTextField(label: 'No. of Bidders Participated'),
        const SizedBox(height: 12),
        _buildTextField(label: '# of Written Applications Submitted'),
      ],
    ));

    // 13. CSD (Common Set of Deviations)
    addSection('13. CSD (Common Set of Deviations)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioOption(
          label: 'Queries Reply in Progress',
          value: _csdStatus == 'queries_in_progress',
          onChanged: (val) =>
              setState(() => _csdStatus = 'queries_in_progress'),
        ),
        _buildRadioOption(
          label: 'Replies Submitted for Approval',
          value: _csdStatus == 'replies_submitted',
          onChanged: (val) =>
              setState(() => _csdStatus = 'replies_submitted'),
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
            child: _buildDateField(label: 'Date'),
          ),
        ],
      ],
    ));

    // 14. Bid Submission
    addSection('14. Bid Submission', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(label: 'Date'),
        const SizedBox(height: 12),
        _buildTextField(label: '# of Bidders Tendered'),
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
            child: _buildDateField(label: 'Likely Date of Completion'),
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
            child: _buildTextField(label: '# of Bidders Qualified'),
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
        _buildDateField(label: 'Date'),
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
        _buildTextField(label: '% Above/Below'),
      ],
    ));

    // 17. Bid Acceptance
    addSection('17. Bid Acceptance', _buildBidAcceptanceRadios());

    // 18. LOA (Letter of Acceptance)
    addSection('18. LOA (Letter of Acceptance)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _loaStatus,
          options: const {'issued': 'Issued', 'not_issued': 'Not Issued'},
          onChanged: (value) => setState(() => _loaStatus = value!),
        ),
        if (_loaStatus == 'not_issued') ...[
          const SizedBox(height: 12),
          _buildTextField(label: 'Reasons'),
        ],
      ],
    ));

    // 19. PBG (Performance Bank Guarantee)
    addSection('19. PBG (Performance Bank Guarantee)', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioGroup(
          value: _pbgStatus,
          options: const {
            'not_submitted': 'Not Submitted',
            'submitted': 'Submitted'
          },
          onChanged: (value) => setState(() => _pbgStatus = value!),
        ),
        if (_pbgStatus == 'submitted') ...[
          const SizedBox(height: 12),
          _buildDateField(label: 'Date'),
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
          _buildTextField(label: 'Reasons'),
        ],
        if (_workOrderStatus == 'issued') ...[
          _buildDateField(label: 'Date'),
          const SizedBox(height: 12),
          _buildTextField(label: 'Amount'),
          const SizedBox(height: 12),
          _buildTextField(label: '% Above/Below'),
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
    addSection('22. Appointed Date', _buildDateField(label: 'Date'));

    // 23. Tender Period
    addSection('23. Tender Period', _buildTextField(label: '# of Months'));

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
            _buildTablePlaceholder(
              rows: 3,
              columns: 4,
              title: 'Proposal Details',
            ),
          ],
          if (_cosStatus == 'submitted') ...[
            _buildDateField(label: 'Date'),
          ],
          if (_cosStatus == 'approved') ...[
            _buildTablePlaceholder(
              rows: 3,
              columns: 7,
              title: 'Approved Proposal Details',
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
          _buildTextField(label: '# of Draft Paras'),
          const SizedBox(height: 12),
          _buildTablePlaceholder(
            rows: 3,
            columns: 4,
            title: 'Details of Paras',
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Responsible Person for Replies'),
          const SizedBox(height: 12),
          _buildTablePlaceholder(
            rows: 3,
            columns: 4,
            title: 'Replies Submitted (# and Dates)',
          ),
          const SizedBox(height: 12),
          _buildTablePlaceholder(
            rows: 3,
            columns: 4,
            title: 'Paras Closed',
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
              Expanded(child: _buildTextField(label: '# of LAQs')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: '# of LCQs')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(label: '# of Lakshvwdhi')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: '# of Others')),
            ],
          ),
          const SizedBox(height: 12),
          _buildTablePlaceholder(
            rows: 3,
            columns: 4,
            title: 'Details of Questions',
          ),
          const SizedBox(height: 12),
          _buildTextField(label: 'Responsible Person for Replies'),
          const SizedBox(height: 12),
          _buildTablePlaceholder(
            rows: 3,
            columns: 4,
            title: 'Replies Submitted (# and Dates)',
          ),
          const SizedBox(height: 12),
          _buildTablePlaceholder(
            rows: 3,
            columns: 4,
            title: 'Promises Given by Hon Minister/s',
          ),
          const SizedBox(height: 12),
          _buildTablePlaceholder(
            rows: 3,
            columns: 5,
            title: 'Promises Compliance',
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
          _buildTextField(label: '# of Findings'),
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
          _buildRadioGroup(
            value: _revAaProgressStatus,
            options: const {
              'in_progress': 'In Progress',
              'submitted': 'Submitted',
              'approved': 'Approved',
              'board_approval': 'Board Approval',
              'accorded': 'Revised AA Accorded'
            },
            onChanged: (value) =>
                setState(() => _revAaProgressStatus = value!),
          ),
          if (_revAaProgressStatus == 'accorded') ...[
            const SizedBox(height: 12),
            _buildTextField(label: 'Revised AA No.'),
            const SizedBox(height: 12),
            _buildDateField(label: 'Date'),
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
          _buildDateField(label: 'Date'),
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
  }) {
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

  Widget _buildDateField({required String label}) {
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
            // TODO: Handle selected date
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

  Widget _buildStatusCheckboxes({
    required String status,
    required ValueChanged<String> onChanged,
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
            child: _buildDateField(label: 'Likely Date of Completion'),
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
      String status, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioOption(
          label: 'Proposal Not Started',
          value: status == 'not_started',
          onChanged: (val) => onChanged('not_started'),
        ),
        _buildRadioOption(
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
            child: _buildDateField(label: 'Date'),
          ),
        ],
        const SizedBox(height: 12),
        _buildTextField(label: 'Status'),
      ],
    );
  }

  Widget _buildBidAcceptanceRadios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioOption(
          label: 'In Progress',
          value: _bidAcceptanceStatus == 'in_progress',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'in_progress'),
        ),
        _buildRadioOption(
          label: 'Submitted',
          value: _bidAcceptanceStatus == 'submitted',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'submitted'),
        ),
        _buildRadioOption(
          label: 'Approved',
          value: _bidAcceptanceStatus == 'approved',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'approved'),
        ),
        _buildRadioOption(
          label: 'Board Approval',
          value: _bidAcceptanceStatus == 'board_approval',
          onChanged: (val) => setState(() => _bidAcceptanceStatus = 'board_approval'),
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
    final options = {
      'not_started': 'Proposal Not Started',
      'under_consideration': 'Proposal Under Consideration',
      'submitted': 'Proposal Submitted',
      'approved': 'EOT Approved',
      'with_escalation': 'With Escalation',
      'without_escalation': 'Without Escalation',
      'by_freezing_indices': 'By Freezing Indices',
      'without_ld': 'Without LD',
      'with_ld': 'With LD',
      'compensation_payable': 'Compensation Payable',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.entries.map((entry) {
          return _buildCheckboxOption(
            label: entry.value,
            value: _eotOptions.contains(entry.key),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _eotOptions.add(entry.key);
                } else {
                  _eotOptions.remove(entry.key);
                }
              });
            },
          );
        }),
        if (_eotOptions.contains('under_consideration')) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildTextField(label: 'Period (Months)'),
          ),
        ],
        if (_eotOptions.contains('submitted')) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDateField(label: 'Date'),
          ),
        ],
        if (_eotOptions.contains('approved')) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildTextField(label: 'Period (Months)'),
          ),
        ],
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