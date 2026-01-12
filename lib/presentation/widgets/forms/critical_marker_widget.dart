import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Widget to mark items as critical
/// Shows a bell icon that can be toggled
class CriticalMarkerWidget extends StatefulWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const CriticalMarkerWidget({
    super.key,
    required this.label,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<CriticalMarkerWidget> createState() => _CriticalMarkerWidgetState();
}

class _CriticalMarkerWidgetState extends State<CriticalMarkerWidget> {
  late bool _isCritical;

  @override
  void initState() {
    super.initState();
    _isCritical = widget.initialValue;
  }

  void _toggleCritical() {
    setState(() {
      _isCritical = !_isCritical;
    });
    widget.onChanged?.call(_isCritical);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: _isCritical ? 'Marked as Critical' : 'Mark as Critical',
          child: InkWell(
            onTap: _toggleCritical,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isCritical
                    ? AppColors.error.withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isCritical ? AppColors.error : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Icon(
                _isCritical ? Icons.notifications_active : Icons.notifications_outlined,
                color: _isCritical ? AppColors.error : AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
