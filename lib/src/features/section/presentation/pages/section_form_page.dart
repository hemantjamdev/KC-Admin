import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/section_model.dart';
import '../../application/providers/section_providers.dart';

/// Form page for Adding or Editing a Curated Section in KC-Admin.
class SectionFormPage extends ConsumerStatefulWidget {
  const SectionFormPage({super.key, this.existingSection});
  final SectionModel? existingSection;
  bool get isEditMode => existingSection != null;

  @override
  ConsumerState<SectionFormPage> createState() => _SectionFormPageState();
}

class _SectionFormPageState extends ConsumerState<SectionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');

  final _titleFocusNode = FocusNode();
  final _subtitleFocusNode = FocusNode();
  final _sortFocusNode = FocusNode();

  SectionType _type = SectionType.manual;

  bool _isActive = true;
  DateTime? _startAt;
  DateTime? _endAt;

  bool _isSaving = false;
  bool _hasChanges = false;
  bool _allowDiscardPop = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode) {
      final s = widget.existingSection!;
      _titleController.text = s.title;
      _subtitleController.text = s.subtitle ?? '';
      _sortOrderController.text = s.sortOrder.toString();
      _type = s.type;
      _isActive = s.isActive;
      _startAt = s.startAt;
      _endAt = s.endAt;
    } else {
      _sortOrderController.text = '0';
    }

    _titleController.addListener(_markDirty);
    _subtitleController.addListener(_markDirty);
    _sortOrderController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _subtitleFocusNode.dispose();
    _sortFocusNode.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

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
          'Unsaved changes will be lost.',
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

  Future<void> _pickDate({required bool isStart}) async {
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
      if (isStart) {
        _startAt = picked;
      } else {
        _endAt = picked;
      }
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_startAt != null && _endAt != null && !_endAt!.isAfter(_startAt!)) {
      AppToast.show(
        context,
        'End date must be later than start date.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    const boutiqueId = 'boutique_01';
    final now = DateTime.now();

    final SectionModel section;
    if (widget.isEditMode) {
      section = widget.existingSection!.copyWith(
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim().isEmpty
            ? null
            : _subtitleController.text.trim(),
        type: _type,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
        startAt: _startAt,
        endAt: _endAt,
        updatedAt: now,
        clearSubtitle: _subtitleController.text.trim().isEmpty,
        clearStartAt: _startAt == null,
        clearEndAt: _endAt == null,
      );
      await ref.read(sectionMutationProvider.notifier).update(section);
    } else {
      section = SectionModel(
        id: 'section_${now.millisecondsSinceEpoch}',
        boutiqueId: boutiqueId,
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim().isEmpty
            ? null
            : _subtitleController.text.trim(),
        type: _type,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
        startAt: _startAt,
        endAt: _endAt,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(sectionMutationProvider.notifier).create(section);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    AppToast.show(
      context,
      widget.isEditMode
          ? '"${section.title}" updated.'
          : '"${section.title}" created.',
      type: ToastType.success,
    );
    context.popOrGoWithResult(true, AppRoutes.adminSectionList);
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
          context.popOrGo(AppRoutes.adminSectionList);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'Edit Section' : 'Add Section',
            style: const TextStyle(
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
                context.popOrGo(AppRoutes.adminSectionList);
                return;
              }
              final canLeave = await _onWillPop();
              if (canLeave && context.mounted) {
                setState(() => _allowDiscardPop = true);
                context.popOrGo(AppRoutes.adminSectionList);
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field(
                        'Title *',
                        TextFormField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(
                            context,
                          ).requestFocus(_subtitleFocusNode),
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('e.g. Featured Bridal Looks'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Title is required.';
                            }
                            if (v.trim().length < 2) {
                              return 'Title must be at least 2 characters.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _field(
                        'Subtitle',
                        TextFormField(
                          controller: _subtitleController,
                          focusNode: _subtitleFocusNode,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(
                            context,
                          ).requestFocus(_sortFocusNode),
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec(
                            'e.g. Handpicked couture lehengas...',
                          ),
                          maxLength: 120,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _field('Section Type *', _buildTypeDropdown()),
                      const SizedBox(height: AppSpacing.md),
                      _field(
                        'Sort Order *',
                        TextFormField(
                          controller: _sortOrderController,
                          focusNode: _sortFocusNode,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).unfocus(),
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('0'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null) return 'Must be a number.';
                            if (n < 0) return 'Must be 0 or greater.';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Scheduling Section
                      _schedulingSection(),
                      const SizedBox(height: AppSpacing.md),
                      // Active toggle
                      _activeToggle(),
                      const SizedBox(height: AppSpacing.xl),
                      _isSaving
                          ? const Center(child: AppLoadingIndicator(size: 36))
                          : AppButton(
                              text: widget.isEditMode
                                  ? 'Save Changes'
                                  : 'Create Section',
                              onPressed: _save,
                            ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SectionType>(
          value: _type,
          dropdownColor: AppColors.surfaceLight,
          borderRadius: AppRadius.borderMd,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          items: SectionType.values
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(
                    t.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _type = v;
                _hasChanges = true;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _schedulingSection() {
    final startLabel = _startAt != null
        ? '${_startAt!.day}/${_startAt!.month}/${_startAt!.year}'
        : 'Not set';
    final endLabel = _endAt != null
        ? '${_endAt!.day}/${_endAt!.month}/${_endAt!.year}'
        : 'Not set';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheduling (Optional)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'Start Date:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
              GestureDetector(
                onTap: () => _pickDate(isStart: true),
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
                    startLabel,
                    style: TextStyle(
                      color: _startAt != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (_startAt != null) ...[
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () => setState(() {
                    _startAt = null;
                    _hasChanges = true;
                  }),
                  child: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'End Date:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
              GestureDetector(
                onTap: () => _pickDate(isStart: false),
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
                    endLabel,
                    style: TextStyle(
                      color: _endAt != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (_endAt != null) ...[
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () => setState(() {
                    _endAt = null;
                    _hasChanges = true;
                  }),
                  child: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeToggle() => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.borderMd,
      border: Border.all(color: AppColors.surfaceBorder),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Inactive sections are hidden in KC-App.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: _isActive,
          onChanged: (v) => setState(() => _isActive = v),
          activeThumbColor: AppColors.primary,
          inactiveTrackColor: AppColors.surfaceBorder,
        ),
      ],
    ),
  );

  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }

  static const TextStyle _fieldStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    border: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.surfaceBorder),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.surfaceBorder),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
  );
}
