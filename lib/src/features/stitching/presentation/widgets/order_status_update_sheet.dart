import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../application/providers/stitching_providers.dart';
import '../../domain/models/stitching_order_model.dart';
import '../../domain/models/stitching_status_mutation_state.dart';

/// Modal bottom sheet allowing status update with optional note and progression warnings.
class OrderStatusUpdateSheet extends ConsumerStatefulWidget {
  const OrderStatusUpdateSheet({
    super.key,
    required this.order,
    required this.updatedBy,
  });

  final StitchingOrderModel order;
  final String updatedBy;

  static Future<bool?> show(
    BuildContext context, {
    required StitchingOrderModel order,
    required String updatedBy,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) =>
          OrderStatusUpdateSheet(order: order, updatedBy: updatedBy),
    );
  }

  @override
  ConsumerState<OrderStatusUpdateSheet> createState() =>
      _OrderStatusUpdateSheetState();
}

class _OrderStatusUpdateSheetState
    extends ConsumerState<OrderStatusUpdateSheet> {
  final _noteController = TextEditingController();
  late StitchingOrderStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String? get _progressionWarning {
    if (_selectedStatus == widget.order.status) return null;
    final oldIdx = StitchingOrderStatus.values.indexOf(widget.order.status);
    final newIdx = StitchingOrderStatus.values.indexOf(_selectedStatus);

    if (newIdx > oldIdx + 1) {
      return 'You are skipping status stages in progression.';
    } else if (newIdx < oldIdx) {
      return 'You are moving status backwards.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_selectedStatus == widget.order.status) return;

    final success = await ref
        .read(stitchingStatusMutationProvider.notifier)
        .updateStatus(
          order: widget.order,
          newStatus: _selectedStatus,
          updatedBy: widget.updatedBy,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final warning = _progressionWarning;
    final rowState = ref
        .watch(stitchingStatusMutationProvider)
        .requests[widget.order.id];
    final isSubmitting = rowState?.status == MutationStatus.loading;
    final errorMessage = rowState?.errorMessage;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Update Status — ${widget.order.orderNumber}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              const Text(
                'Select New Status',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: StitchingOrderStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  final chipColor = switch (status) {
                    StitchingOrderStatus.requested => const Color(0xFFE65100),
                    StitchingOrderStatus.accepted => const Color(0xFF1565C0),
                    StitchingOrderStatus.completed => const Color(0xFF2E7D32),
                  };

                  return ChoiceChip(
                    label: Text(status.adminLabel),
                    selected: isSelected,
                    selectedColor: chipColor,
                    backgroundColor: AppColors.surfaceLight,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.background
                          : AppColors.textMuted,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: isSubmitting
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _selectedStatus = status);
                            }
                          },
                  );
                }).toList(),
              ),
              if (warning != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          warning,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Status Note (Optional)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _noteController,
                enabled: !isSubmitting,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                cursorColor: AppColors.primary,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Fabric cutting done by master tailor',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'Confirm Status Change',
                isLoading: isSubmitting,
                onPressed:
                    _selectedStatus == widget.order.status || isSubmitting
                    ? null
                    : _submit,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}
