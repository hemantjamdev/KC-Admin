import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/stitching_order_model.dart';

/// Reusable timeline widget showing status progression history with clean vertical connectors.
class StitchingOrderTimeline extends StatelessWidget {
  const StitchingOrderTimeline({
    super.key,
    required this.history,
    this.isCustomerView = false,
  });

  final List<StitchingOrderHistoryModel> history;
  final bool isCustomerView;

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          'No timeline history recorded yet.',
          style: GoogleFonts.montserrat(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final isLast = index == history.length - 1;
        final statusLabel = isCustomerView
            ? item.status.customerLabel
            : item.status.adminLabel;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicator Column with auto-expanding line
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLast ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isLast
                            ? PhosphorIcon(
                                PhosphorIcons.check(PhosphorIconsStyle.bold),
                                size: 13,
                                color: Colors.white,
                              )
                            : Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Content (Clean - No container)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            statusLabel,
                            style: GoogleFonts.montserrat(
                              color: isLast
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _formatDateTime(item.changedAt),
                            style: GoogleFonts.montserrat(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.note!,
                          style: GoogleFonts.montserrat(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (!isCustomerView && item.changedBy != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Updated by: ${item.changedBy}',
                          style: GoogleFonts.montserrat(
                            color: AppColors.textHint,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
