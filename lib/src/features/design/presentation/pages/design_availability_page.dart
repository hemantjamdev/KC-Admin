import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/design_availability_model.dart';
import '../../domain/models/design_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/design_providers.dart';

/// Manage branch-level availability for a design in KC-Admin.
/// Pass [DesignModel] via GoRouter `extra`.
class DesignAvailabilityPage extends ConsumerStatefulWidget {
  const DesignAvailabilityPage({super.key, required this.design});
  final DesignModel design;

  @override
  ConsumerState<DesignAvailabilityPage> createState() =>
      _DesignAvailabilityPageState();
}

class _DesignAvailabilityPageState
    extends ConsumerState<DesignAvailabilityPage> {
  final List<dynamic> _branches = [];
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _allowDiscardPop = false;
  // branchId → mutable availability state
  final Map<String, _BranchAvailState> _state = {};

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    const boutiqueId = 'boutique_01';
    _initData(boutiqueId);
  }

  Future<void> _initData(String boutiqueId) async {}

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Discard Changes?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Availability changes will not be saved.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Discard',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _save() async {
    // Validate all rows
    for (final branch in _branches) {
      final s = _state[branch.id]!;
      if (s.availableFrom != null &&
          s.availableUntil != null &&
          !s.availableUntil!.isAfter(s.availableFrom!)) {
        AppToast.show(
          context,
          '${branch.name}: Available Until must be after Available From.',
          type: ToastType.warning,
        );
        return;
      }
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    const boutiqueId = 'boutique_01';
    final now = DateTime.now();

    for (final branch in _branches) {
      final s = _state[branch.id]!;
      final record = DesignAvailabilityModel(
        id: DesignAvailabilityModel.buildId(branch.id, widget.design.id),
        boutiqueId: boutiqueId,
        branchId: branch.id,
        designId: widget.design.id,
        status: s.status,
        displayOrder: int.tryParse(s.displayOrderText) ?? 0,
        availableFrom: s.availableFrom,
        availableUntil: s.availableUntil,
        createdAt: s.createdAt ?? now,
        updatedAt: now,
      );
      await ref.read(designRepositoryProvider).saveDesignAvailability(record);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    AppToast.show(
      context,
      'Availability updated successfully.',
      type: ToastType.success,
    );
    context.popOrGoWithResult(true, AppRoutes.adminDesignList);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges || _allowDiscardPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canLeave = await _onWillPop();
        if (canLeave && context.mounted) {
          setState(() => _allowDiscardPop = true);
          context.popOrGo(AppRoutes.adminDesignList);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Availability',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              if (!_hasChanges) {
                context.popOrGo(AppRoutes.adminDesignList);
                return;
              }
              final canLeave = await _onWillPop();
              if (canLeave && context.mounted) {
                setState(() => _allowDiscardPop = true);
                context.popOrGo(AppRoutes.adminDesignList);
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.design.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Kapada Creation Studio',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_branches.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            'No active branches found.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._branches.map(
                        (branch) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _BranchAvailCard(
                            branch: branch,
                            state: _state[branch.id]!,
                            onChanged: _markDirty,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_isSaving)
                      const Center(child: AppLoadingIndicator(size: 36))
                    else
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Cancel',
                              variant: AppButtonVariant.secondary,
                              onPressed: () async {
                                final router = GoRouter.of(context);
                                final canLeave = await _onWillPop();
                                if (canLeave) {
                                  router.go(AppRoutes.adminDesignList);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              text: 'Save',
                              onPressed: _hasChanges ? _save : null,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mutable state holder for one branch row
// ---------------------------------------------------------------------------

class _BranchAvailState {
  _BranchAvailState({
    required this.status,
    required this.displayOrderText,
    required this.availableFrom,
    required this.availableUntil,
    required this.createdAt,
    required this.displayOrderController,
  });

  AvailabilityStatus status;
  String displayOrderText;
  DateTime? availableFrom;
  DateTime? availableUntil;
  DateTime? createdAt;
  final TextEditingController displayOrderController;
}

// ---------------------------------------------------------------------------
// Branch availability card widget
// ---------------------------------------------------------------------------

class _BranchAvailCard extends StatefulWidget {
  const _BranchAvailCard({
    required this.branch,
    required this.state,
    required this.onChanged,
  });
  final dynamic branch;
  final _BranchAvailState state;
  final VoidCallback onChanged;

  @override
  State<_BranchAvailCard> createState() => _BranchAvailCardState();
}

class _BranchAvailCardState extends State<_BranchAvailCard> {
  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surfaceLight,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        widget.state.availableFrom = picked;
      } else {
        widget.state.availableUntil = picked;
      }
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.branch.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.branch.city,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: AppSpacing.md),
          // Status selection
          Wrap(
            spacing: AppSpacing.sm,
            children: AvailabilityStatus.values.map((status) {
              final selected = s.status == status;
              return GestureDetector(
                onTap: () {
                  setState(() => s.status = status);
                  widget.onChanged();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? _statusColor(status)
                        : AppColors.surfaceLight,
                    borderRadius: AppRadius.borderPill,
                    border: Border.all(
                      color: selected
                          ? _statusColor(status)
                          : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      color: selected
                          ? AppColors.background
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          // Display order
          Row(
            children: [
              const Text(
                'Display Order:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: s.displayOrderController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  cursorColor: AppColors.primary,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.borderSm,
                      borderSide: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.borderSm,
                      borderSide: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.borderSm,
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (v) {
                    s.displayOrderText = v;
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Available From
          _DateRow(
            label: 'Available From',
            date: s.availableFrom,
            onTap: () => _pickDate(isFrom: true),
            onClear: s.availableFrom == null
                ? null
                : () {
                    setState(() => s.availableFrom = null);
                    widget.onChanged();
                  },
          ),
          const SizedBox(height: AppSpacing.sm),
          // Available Until
          _DateRow(
            label: 'Available Until',
            date: s.availableUntil,
            onTap: () => _pickDate(isFrom: false),
            onClear: s.availableUntil == null
                ? null
                : () {
                    setState(() => s.availableUntil = null);
                    widget.onChanged();
                  },
          ),
        ],
      ),
    );
  }

  Color _statusColor(AvailabilityStatus status) => switch (status) {
    AvailabilityStatus.available => AppColors.success,
    AvailabilityStatus.unavailable => AppColors.warning,
    AvailabilityStatus.hidden => AppColors.error,
  };
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final formatted = date != null
        ? '${date!.day}/${date!.month}/${date!.year}'
        : 'Not set';
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Text(
              formatted,
              style: TextStyle(
                color: date != null
                    ? AppColors.textPrimary
                    : AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (onClear != null) ...[
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.clear_rounded,
              color: AppColors.textMuted,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }
}
