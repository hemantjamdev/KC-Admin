import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/stitching_order_model.dart';
import '../controllers/stitching_order_controller.dart';

/// Modal bottom sheet allowing status update with optional note and progression warnings.
class OrderStatusUpdateSheet extends StatefulWidget {
  const OrderStatusUpdateSheet({
    super.key,
    required this.order,
    required this.controller,
    required this.updatedBy,
  });

  final StitchingOrderModel order;
  final StitchingOrderController controller;
  final String updatedBy;

  @override
  State<OrderStatusUpdateSheet> createState() => _OrderStatusUpdateSheetState();
}

class _OrderStatusUpdateSheetState extends State<OrderStatusUpdateSheet> {
  final _noteController = TextEditingController();
  late StitchingOrderStatus _selectedStatus;
  bool _isSubmitting = false;

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

    setState(() => _isSubmitting = true);

    await widget.controller.updateOrderStatus(
      orderId: widget.order.id,
      newStatus: _selectedStatus,
      note: _noteController.text,
      updatedBy: widget.updatedBy,
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final warning = _progressionWarning;

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
                  Text(
                    'Update Status — ${widget.order.orderNumber}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                  final isCurrent = status == widget.order.status;
                  final isSelected = status == _selectedStatus;
                  return ChoiceChip(
                    label: Text(status.adminLabel),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceLight,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.background
                          : (isCurrent
                                ? AppColors.primary
                                : AppColors.textMuted),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) {
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
                isLoading: _isSubmitting,
                onPressed:
                    _selectedStatus == widget.order.status || _isSubmitting
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
