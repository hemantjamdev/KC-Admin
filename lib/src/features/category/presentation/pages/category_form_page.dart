import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/category_providers.dart';

/// Redesigned Add / Edit Category Form.
/// Minimalist form focusing strictly on Name, Description, and Active status.
class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({super.key, this.existingCategory});

  final CategoryModel? existingCategory;

  bool get isEditMode => existingCategory != null;

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _descFocusNode = FocusNode();

  bool _isActive = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _allowDiscardPop = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode) {
      final cat = widget.existingCategory!;
      _nameController.text = cat.name;
      _descriptionController.text = cat.description ?? '';
      _isActive = cat.isActive;
    }

    _nameController.addListener(_markDirty);
    _descriptionController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _descFocusNode.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  String _generateSlug(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return slug.isEmpty ? 'cat-${DateTime.now().millisecondsSinceEpoch}' : slug;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Discard Changes?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'You have unsaved changes. Leaving will discard them.',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep Editing',
              style: GoogleFonts.montserrat(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Discard',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.existingCategory?.isSystem == true) {
      setState(() => _isSaving = true);
      await ref
          .read(categoryMutationProvider.notifier)
          .setActive(widget.existingCategory!.id, _isActive);
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        '"${widget.existingCategory!.name}" status updated.',
        type: ToastType.success,
      );
      context.popOrGoWithResult(true, AppRoutes.adminCategoryList);
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    const boutiqueId = 'boutique_01';
    final now = DateTime.now();
    final nameTrimmed = _nameController.text.trim();
    final descTrimmed = _descriptionController.text.trim();

    final CategoryModel category;
    if (widget.isEditMode) {
      category = widget.existingCategory!.copyWith(
        name: nameTrimmed,
        slug: _generateSlug(nameTrimmed),
        description: descTrimmed.isEmpty ? null : descTrimmed,
        isActive: _isActive,
        updatedAt: now,
        clearDescription: descTrimmed.isEmpty,
      );
      await ref.read(categoryMutationProvider.notifier).update(category);
    } else {
      category = CategoryModel(
        id: 'cat_${now.millisecondsSinceEpoch}',
        boutiqueId: boutiqueId,
        name: nameTrimmed,
        slug: _generateSlug(nameTrimmed),
        description: descTrimmed.isEmpty ? null : descTrimmed,
        sortOrder: 10,
        isActive: _isActive,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(categoryMutationProvider.notifier).create(category);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    AppToast.show(
      context,
      widget.isEditMode
          ? '"${category.name}" updated.'
          : '"${category.name}" created.',
      type: ToastType.success,
    );

    if (!mounted) return;
    context.popOrGoWithResult(true, AppRoutes.adminCategoryList);
  }

  @override
  Widget build(BuildContext context) {
    final isSystem = widget.existingCategory?.isSystem == true;

    return PopScope(
      canPop: !_hasChanges || _allowDiscardPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canLeave = await _onWillPop();
        if (canLeave && context.mounted) {
          setState(() => _allowDiscardPop = true);
          context.popOrGo(AppRoutes.adminCategoryList);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            widget.isEditMode ? 'Edit Category' : 'Add Category',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              final canLeave = await _onWillPop();
              if (canLeave && context.mounted) {
                setState(() => _allowDiscardPop = true);
                context.popOrGo(AppRoutes.adminCategoryList);
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSystem) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.lockKey(PhosphorIconsStyle.bold),
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This is a core system category (New Arrivals, Seasonal, Festive) and cannot be edited or deleted.',
                              style: GoogleFonts.montserrat(
                                fontSize: 12.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Category Name
                  Text(
                    'CATEGORY NAME',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    enabled: !isSystem,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Designer Sarees, Bridal Wear',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Category name is required.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Description (Optional)
                  Text(
                    'DESCRIPTION (OPTIONAL)',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    focusNode: _descFocusNode,
                    enabled: !isSystem,
                    maxLines: 3,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Brief summary of what this category contains...',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 13.5,
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Active Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Status',
                              style: GoogleFonts.montserrat(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isActive
                                  ? 'Visible to customers in KC-App'
                                  : 'Hidden from customer app views',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _isActive,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _isActive = val;
                              _markDirty();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Action Button
                  AppButton(
                    text: widget.isEditMode ? 'Save Category' : 'Create Category',
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
