import 'package:flutter/material.dart';
import '../../../../domain/models/review_component_config.dart';
import '../base_review_component.dart';

/// Simple detail component for displaying field-value pairs
///
/// Used for most basic components that just show a list of fields
class SimpleDetailComponent extends BaseReviewComponent {
  const SimpleDetailComponent({
    super.key,
    required super.config,
    required super.data,
  });

  @override
  Widget buildContent(BuildContext context) {
    // Get all visible fields based on current state
    final currentState = getCurrentState(config, data);
    final visibleFields = getVisibleFields(config, currentState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visibleFields.map((fieldKey) => buildFieldRow(fieldKey)),
      ],
    );
  }
}
