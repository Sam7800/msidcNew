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

class _ReviewCardBaseState extends ConsumerState<ReviewCardBase>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  bool _isCritical = false;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

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

    final isCritical = stateField != null
        ? ComponentStatusUtils.isCriticalStatus(stateField.toString())
        : false;

    // Start/stop animation based on critical status
    if (isCritical != _isCritical) {
      _isCritical = isCritical;
      if (isCritical) {
        _blinkController.repeat(reverse: true);
      } else {
        _blinkController.stop();
        _blinkController.value = 1.0;
      }
    }

    // Build tooltip message
    final tooltipMessage = formattedStatus != null
        ? '${widget.config.title}\n$formattedStatus'
        : widget.config.title;

    // Get background color based on status (default to grey if no status)
    final backgroundColor = statusColor != null
        ? statusColor.withOpacity(0.15)
        : AppColors.textSecondary.withOpacity(0.1);

    final borderColor = statusColor ?? AppColors.textSecondary;
    final textColor = statusColor ?? AppColors.textSecondary;

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
            child: AnimatedBuilder(
              animation: _blinkAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: const BoxConstraints(
                    minWidth: 80,
                  ),
                  decoration: BoxDecoration(
                    color: isCritical
                        ? AppColors.error.withOpacity(0.1 + (_blinkAnimation.value * 0.15))
                        : (_isHovered
                            ? (statusColor != null
                                ? statusColor.withOpacity(0.25)
                                : backgroundColor)
                            : backgroundColor),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCritical
                          ? AppColors.error.withOpacity(_blinkAnimation.value * 0.9)
                          : (_isHovered
                              ? borderColor.withOpacity(0.6)
                              : borderColor.withOpacity(0.3)),
                      width: isCritical ? 2.5 : 1.5,
                    ),
                    boxShadow: isCritical
                        ? [
                            BoxShadow(
                              color: AppColors.error.withOpacity(_blinkAnimation.value * 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : (_isHovered
                            ? [
                                BoxShadow(
                                  color: borderColor.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null),
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
                          color: isCritical
                              ? AppColors.error.withOpacity(_blinkAnimation.value)
                              : textColor,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Status indicator dot
                      if (statusColor != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: isCritical ? 6 : 5,
                          height: isCritical ? 6 : 5,
                          decoration: BoxDecoration(
                            color: isCritical
                                ? statusColor.withOpacity(_blinkAnimation.value)
                                : statusColor,
                            shape: BoxShape.circle,
                            boxShadow: isCritical
                                ? [
                                    BoxShadow(
                                      color: statusColor.withOpacity(_blinkAnimation.value * 0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
