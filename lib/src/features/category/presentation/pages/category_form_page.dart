import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../domain/models/category_model.dart';
import '../controllers/category_controller.dart';

/// Add / Edit Category form page.
/// Pass a [CategoryModel] via GoRouter `extra` for edit mode.
class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key, this.existingCategory});

  final CategoryModel? existingCategory;

  bool get isEditMode => existingCategory != null;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _sortOrderController = TextEditingController();

  bool _isActive = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _slugEditedManually = false;

  late CategoryController _controller;

  @override
  void initState() {
    super.initState();
    final boutiqueId =
        BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? '';
    _controller = CategoryController(boutiqueId: boutiqueId);
    _controller.loadCategories();

    if (widget.isEditMode) {
      final cat = widget.existingCategory!;
      _nameController.text = cat.name;
      _slugController.text = cat.slug;
      _descriptionController.text = cat.description ?? '';
      _imageUrlController.text = cat.imageUrl ?? '';
      _sortOrderController.text = cat.sortOrder.toString();
      _isActive = cat.isActive;
      _slugEditedManually = true;
    } else {
      _sortOrderController.text = '0';
    }

    _nameController.addListener(_onNameChanged);
    _nameController.addListener(_markDirty);
    _slugController.addListener(_markDirty);
    _descriptionController.addListener(_markDirty);
    _imageUrlController.addListener(_markDirty);
    _sortOrderController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  void _onNameChanged() {
    if (!_slugEditedManually) {
      final generated = _generateSlug(_nameController.text);
      _slugController.text = generated;
      _slugController.selection = TextSelection.fromPosition(
        TextPosition(offset: _slugController.text.length),
      );
    }
  }

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
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
          'You have unsaved changes. Leaving will discard them.',
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

  String? _validateSlug(String? value) {
    if (value == null || value.isEmpty) return 'Slug is required.';
    final slugRegex = RegExp(r'^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$');
    if (!slugRegex.hasMatch(value)) {
      return 'Slug: lowercase letters, numbers, and hyphens only. '
          'Cannot start or end with a hyphen.';
    }

    return null;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final boutiqueId =
        BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? '';
    final now = DateTime.now();

    final CategoryModel category;
    if (widget.isEditMode) {
      category = widget.existingCategory!.copyWith(
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
        updatedAt: now,
        clearDescription: _descriptionController.text.trim().isEmpty,
        clearImageUrl: _imageUrlController.text.trim().isEmpty,
      );
      _controller.updateCategory(category);
    } else {
      category = CategoryModel(
        id: 'cat_${now.millisecondsSinceEpoch}',
        boutiqueId: boutiqueId,
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
        createdAt: now,
        updatedAt: now,
      );
      _controller.addCategory(category);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditMode
              ? '"${category.name}" updated.'
              : '"${category.name}" created.',
        ),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    context.go(AppRoutes.adminCategoryList);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _sortOrderController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final canLeave = await _onWillPop();
        if (canLeave) router.go(AppRoutes.adminCategoryList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'Edit Category' : 'Add Category',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              final router = GoRouter.of(context);
              final canLeave = await _onWillPop();
              if (canLeave) router.go(AppRoutes.adminCategoryList);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      _FormField(
                        label: 'Name *',
                        child: TextFormField(
                          controller: _nameController,
                          style: _fieldTextStyle,
                          cursorColor: AppColors.primary,
                          decoration: _inputDecoration('e.g. Bridal Wear'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required.';
                            }
                            if (v.trim().length < 2) {
                              return 'Name must be at least 2 characters.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Slug
                      _FormField(
                        label: 'Slug *',
                        child: TextFormField(
                          controller: _slugController,
                          style: _fieldTextStyle.copyWith(
                            fontFamily: 'monospace',
                          ),
                          cursorColor: AppColors.primary,
                          decoration: _inputDecoration('e.g. bridal-wear'),
                          onChanged: (_) {
                            _slugEditedManually = true;
                            _markDirty();
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z0-9-]'),
                            ),
                          ],
                          validator: _validateSlug,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Description
                      _FormField(
                        label: 'Description',
                        child: TextFormField(
                          controller: _descriptionController,
                          style: _fieldTextStyle,
                          cursorColor: AppColors.primary,
                          decoration: _inputDecoration(
                            'Optional category description',
                          ),
                          maxLines: 3,
                          minLines: 2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Image URL
                      _FormField(
                        label: 'Image URL',
                        child: TextFormField(
                          controller: _imageUrlController,
                          style: _fieldTextStyle,
                          cursorColor: AppColors.primary,
                          decoration: _inputDecoration('https://…'),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Sort Order
                      _FormField(
                        label: 'Sort Order *',
                        child: TextFormField(
                          controller: _sortOrderController,
                          style: _fieldTextStyle,
                          cursorColor: AppColors.primary,
                          decoration: _inputDecoration('0'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            final parsed = int.tryParse(v ?? '');
                            if (parsed == null) return 'Must be a number.';
                            if (parsed < 0) return 'Must be zero or greater.';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Active toggle
                      Container(
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
                                    'Inactive categories are hidden in the customer app.',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
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
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Save button
                      _isSaving
                          ? const Center(child: AppLoadingIndicator(size: 36))
                          : AppButton(
                              text: widget.isEditMode
                                  ? 'Save Changes'
                                  : 'Create Category',
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

  static const TextStyle _fieldTextStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
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
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
}
