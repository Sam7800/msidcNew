import 'package:flutter/material.dart';
import '../../../domain/models/review_component_config.dart';
import 'components/simple_detail_component.dart';
import 'components/milestone_detail_component.dart';
import 'components/expenditure_detail_component.dart';
import 'components/aa_detail_component.dart';
import 'components/dpr_detail_component.dart';
import 'components/ts_detail_component.dart';
import 'components/work_order_detail_component.dart';

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

      // Technical Sanction (2 states with table)
      case ReviewComponentType.ts:
        return TSDetailComponent(config: config, data: data);

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

      // All other components use simple field-value display
      default:
        return SimpleDetailComponent(config: config, data: data);
    }
  }
}
