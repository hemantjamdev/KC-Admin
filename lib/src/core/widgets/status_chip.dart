import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Reusable stitching order status chip for admin screens.
class StitchingStatusChip extends StatelessWidget {
  const StitchingStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Maps a stitching status string to its display color.
Color stitchingStatusColor(String status) {
  final s = status.toLowerCase().trim();
  if (s == 'requested' || s == 'received' || s == 'pending') {
    return AppColors.warning;
  } else if (s == 'accepted' ||
      s == 'stitching' ||
      s == 'measurements' ||
      s == 'cutting' ||
      s == 'qualitycheck' ||
      s == 'quality_check' ||
      s == 'in_progress') {
    return AppColors.primary;
  } else if (s == 'completed' || s == 'ready' || s == 'delivered') {
    return AppColors.success;
  } else if (s == 'cancelled' || s == 'rejected') {
    return AppColors.error;
  }
  return AppColors.primary;
}
