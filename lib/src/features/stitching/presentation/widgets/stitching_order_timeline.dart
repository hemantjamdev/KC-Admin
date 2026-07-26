import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/stitching_order_model.dart';

/// Reusable timeline widget showing status progression history.
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
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Text(
          'No timeline history recorded yet.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicator column
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLast ? AppColors.primary : AppColors.surfaceLight,
                    border: Border.all(
                      color: isLast
                          ? AppColors.primary
                          : AppColors.surfaceBorder,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isLast ? Icons.check_rounded : Icons.circle_rounded,
                    size: isLast ? 14 : 8,
                    color: isLast ? AppColors.background : AppColors.textMuted,
                  ),
                ),
                if (index < history.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: AppColors.surfaceBorder,
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: isLast
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: isLast
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _formatDateTime(item.changedAt),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.note!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (!isCustomerView && item.changedBy != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Updated by: ${item.changedBy}',
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
