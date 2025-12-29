import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/review_component_config.dart';
import '../../../utils/component_status_utils.dart';
import '../../../theme/app_colors.dart';
import 'component_detail_dialog.dart';

/// Compact button card for Review components
///
/// Features:
/// - Compact button showing short form abbreviation (e.g., "AA", "DPR")
/// - Hover behavior: Shows tooltip with full name and status
/// - Click behavior: Opens popup dialog with full details
class ReviewCardBase extends ConsumerStatefulWidget {
  final ReviewComponentConfig config;
  final Map<String, dynamic> data;

  const ReviewCardBase({
    super.key,
    required this.config,
    required this.data,
  });

  @override
  ConsumerState<ReviewCardBase> createState() => _ReviewCardBaseState();
}

class _ReviewCardBaseState extends ConsumerState<ReviewCardBase> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final stateField = widget.config.stateField != null
        ? widget.data[widget.config.stateField]
        : null;

    final statusColor = stateField != null
        ? ComponentStatusUtils.getStatusColor(stateField.toString())
        : null;

    final formattedStatus = stateField != null
        ? ComponentStatusUtils.formatStatus(stateField.toString())
        : null;

    // Build tooltip message
    final tooltipMessage = formattedStatus != null
        ? '${widget.config.title}\n$formattedStatus'
        : widget.config.title;

    // Get background color based on component type
    final backgroundColor = widget.config.primaryColor.withOpacity(0.1);
    final textColor = widget.config.primaryColor;

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 300),
      preferBelow: false,
      textStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            ComponentDetailDialog.show(
              context,
              widget.config,
              widget.data,
            );
          },
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(
                minWidth: 80,
              ),
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.config.primaryColor.withOpacity(0.15)
                    : backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isHovered
                      ? widget.config.primaryColor.withOpacity(0.4)
                      : widget.config.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.config.primaryColor.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Short form abbreviation
                  Text(
                    widget.config.id.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Status indicator dot
                  if (statusColor != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
