import 'package:flutter/material.dart';

import '../models/enrollment.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  static const _rejectedColor = Color(0xFFE0654D);
  static const _pendingColor = Color(0xFFD9A441);

  Color get _color {
    switch (status) {
      case EnrollmentStatus.approved:
      case EnrollmentStatus.active:
        return AppColors.mintDark;
      case EnrollmentStatus.rejected:
      case EnrollmentStatus.cancelled:
        return _rejectedColor;
      default:
        return _pendingColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
