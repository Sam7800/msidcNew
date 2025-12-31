import 'package:flutter/material.dart';
import '../../../domain/models/review_component_config.dart';
import 'components/simple_detail_component.dart';
import 'components/milestone_detail_component.dart';
import 'components/expenditure_detail_component.dart';
import 'components/aa_detail_component.dart';
import 'components/dpr_detail_component.dart';
import 'components/ts_detail_component.dart';
import 'components/work_order_detail_component.dart';
import 'components/boq_detail_component.dart';
import 'components/schedules_detail_component.dart';
import 'components/drawings_detail_component.dart';
import 'components/bid_documents_detail_component.dart';
import 'components/nit_detail_component.dart';
import 'components/env_clearance_detail_component.dart';
import 'components/land_acquisition_detail_component.dart';
import 'components/utility_shifting_detail_component.dart';
import 'components/prebid_detail_component.dart';
import 'components/csd_detail_component.dart';
import 'components/bid_submission_detail_component.dart';
import 'components/tech_evaluation_detail_component.dart';
import 'components/financial_bid_detail_component.dart';
import 'components/bid_acceptance_detail_component.dart';
import 'components/loa_detail_component.dart';
import 'components/pbg_detail_component.dart';
import 'components/ld_detail_component.dart';
import 'components/eot_detail_component.dart';
import 'components/cos_detail_component.dart';
import 'components/audit_para_detail_component.dart';
import 'components/laq_detail_component.dart';
import 'components/technical_audit_detail_component.dart';
import 'components/rev_aa_detail_component.dart';
import 'components/supplementary_agreement_detail_component.dart';

/// Factory class for creating component-specific detail views
///
/// Maps ReviewComponentType to appropriate widget implementation.
class ComponentDetailViewFactory {
  /// Create the appropriate detail view widget for a component
  ///
  /// [config] - Component configuration
  /// [data] - Extracted component data
  ///
  /// Returns a Widget rendering the component's expanded content
  static Widget create({
    required ReviewComponentConfig config,
    required Map<String, dynamic> data,
  }) {
    switch (config.type) {
      // Administrative Approval (2 states with conditional fields)
      case ReviewComponentType.aa:
        return AADetailComponent(config: config, data: data);

      // DPR (4 states)
      case ReviewComponentType.dpr:
        return DPRDetailComponent(config: config, data: data);

      // BOQ (Bill of Quantities with table)
      case ReviewComponentType.boq:
        return BOQDetailComponent(config: config, data: data);

      // Schedules (4 states)
      case ReviewComponentType.schedules:
        return SchedulesDetailComponent(config: config, data: data);

      // Drawings (4 states)
      case ReviewComponentType.drawings:
        return DrawingsDetailComponent(config: config, data: data);

      // Bid Documents (4 states)
      case ReviewComponentType.bidDocuments:
        return BidDocumentsDetailComponent(config: config, data: data);

      // Environmental Clearance (conditional)
      case ReviewComponentType.envClearance:
        return ENVClearanceDetailComponent(config: config, data: data);

      // Land Acquisition (conditional)
      case ReviewComponentType.landAcquisition:
        return LandAcquisitionDetailComponent(config: config, data: data);

      // Utility Shifting (conditional)
      case ReviewComponentType.utilityShifting:
        return UtilityShiftingDetailComponent(config: config, data: data);

      // CSD (4 states)
      case ReviewComponentType.csd:
        return CSDDetailComponent(config: config, data: data);

      // Bid Submission
      case ReviewComponentType.bidSubmission:
        return BidSubmissionDetailComponent(config: config, data: data);

      // Technical Evaluation (3 states)
      case ReviewComponentType.techEvaluation:
        return TechEvaluationDetailComponent(config: config, data: data);

      // Financial Bid (L1/H1 details)
      case ReviewComponentType.financialBid:
        return FinancialBidDetailComponent(config: config, data: data);

      // Bid Acceptance (5 states)
      case ReviewComponentType.bidAcceptance:
        return BidAcceptanceDetailComponent(config: config, data: data);

      // LOA (Letter of Acceptance)
      case ReviewComponentType.loa:
        return LOADetailComponent(config: config, data: data);

      // PBG (Performance Bank Guarantee)
      case ReviewComponentType.pbg:
        return PBGDetailComponent(config: config, data: data);

      // Technical Sanction (2 states with table)
      case ReviewComponentType.ts:
        return TSDetailComponent(config: config, data: data);

      // NIT (2 states with tables)
      case ReviewComponentType.nit:
        return NITDetailComponent(config: config, data: data);

      // Pre-bid (meeting details)
      case ReviewComponentType.prebid:
        return PrebidDetailComponent(config: config, data: data);

      // Work Order (2 states with detailed info)
      case ReviewComponentType.workOrder:
        return WorkOrderDetailComponent(config: config, data: data);

      // Milestones (specialized component with progress tracking)
      case ReviewComponentType.milestone1:
      case ReviewComponentType.milestone2:
      case ReviewComponentType.milestone3:
      case ReviewComponentType.milestone4:
      case ReviewComponentType.milestone5:
        return MilestoneDetailComponent(config: config, data: data);

      // Expenditure (specialized component with budget tracking)
      case ReviewComponentType.expenditure:
        return ExpenditureDetailComponent(config: config, data: data);

      // Liquidated Damages (conditional)
      case ReviewComponentType.ld:
        return LDDetailComponent(config: config, data: data);

      // Extension of Time (conditional complex)
      case ReviewComponentType.eot:
        return EOTDetailComponent(config: config, data: data);

      // Change of Scope (conditional with tables)
      case ReviewComponentType.cos:
        return COSDetailComponent(config: config, data: data);

      // Audit Para (conditional with tables)
      case ReviewComponentType.auditPara:
        return AuditParaDetailComponent(config: config, data: data);

      // LAQ (conditional with tables)
      case ReviewComponentType.laq:
        return LAQDetailComponent(config: config, data: data);

      // Technical Audit (conditional)
      case ReviewComponentType.technicalAudit:
        return TechnicalAuditDetailComponent(config: config, data: data);

      // Revised AA (conditional)
      case ReviewComponentType.revAA:
        return RevAADetailComponent(config: config, data: data);

      // Supplementary Agreement (conditional)
      case ReviewComponentType.supplementaryAgreement:
        return SupplementaryAgreementDetailComponent(config: config, data: data);

      // All other components use simple field-value display
      // (Agreement Amount, Appointed Date, Tender Period)
      default:
        return SimpleDetailComponent(config: config, data: data);
    }
  }
}
