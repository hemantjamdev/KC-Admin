import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/data/repositories/category_firestore_repository.dart';
import '../../../category/domain/models/category_model.dart';
import '../../domain/models/design_model.dart';
import '../controllers/design_controller.dart';
import '../widgets/design_image_picker_widget.dart';

/// Add / Edit Design form page.
/// Pass a [DesignModel] via GoRouter `extra` for edit mode.
class DesignFormPage extends StatefulWidget {
  const DesignFormPage({super.key, this.existingDesign});
  final DesignModel? existingDesign;
  bool get isEditMode => existingDesign != null;

  @override
  State<DesignFormPage> createState() => _DesignFormPageState();
}

class _DesignFormPageState extends State<DesignFormPage> {
  final _categoryRepository = CategoryFirestoreRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');
  final _tagInputController = TextEditingController();
  final _keywordInputController = TextEditingController();
  final _galleryUrlController = TextEditingController();

  bool _isActive = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _slugEditedManually = false;

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  List<String> _imageUrls = [];
  List<String> _tags = [];
  List<String> _keywords = [];

  late DesignController _controller;

  @override
  void initState() {
    super.initState();
    final boutiqueId =
        BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? '';
    
    _controller = DesignController(
      boutiqueId: boutiqueId,
      activeCategoryIds: const [],
    );
    _controller.loadDesigns();
    
    _loadCategories(boutiqueId);

    if (widget.isEditMode) {
      final d = widget.existingDesign!;
      _nameController.text = d.name;
      _slugController.text = d.slug;
      _shortDescController.text = d.shortDescription ?? '';
      _descController.text = d.description ?? '';
      _thumbnailController.text = d.thumbnailUrl ?? '';
      _sortOrderController.text = d.sortOrder.toString();
      _isActive = d.isActive;
      _selectedCategoryId = d.categoryId;
      _imageUrls = List.of(d.imageUrls);
      _tags = List.of(d.tags);
      _keywords = List.of(d.searchKeywords);
      _slugEditedManually = true;
    } else {
      _sortOrderController.text = '0';
    }

    _nameController.addListener(_onNameChanged);
    _nameController.addListener(_markDirty);
    _slugController.addListener(_markDirty);
    _shortDescController.addListener(_markDirty);
    _descController.addListener(_markDirty);
    _thumbnailController.addListener(_markDirty);
    _sortOrderController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  void _onNameChanged() {
    if (!_slugEditedManually) {
      _slugController.text = _generateSlug(_nameController.text);
    }
  }

  String _generateSlug(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

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

  Future<void> _loadCategories(String boutiqueId) async {
    final categories = await _categoryRepository.watchCategories(boutiqueId).first;
    if (!mounted) return;
    setState(() {
      _categories = categories.where((c) => c.isActive).toList();
    });
  }

  String? _validateSlug(String? value) {
    if (value == null || value.isEmpty) return 'Slug is required.';
    final ok = RegExp(r'^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$');
    if (!ok.hasMatch(value)) {
      return 'Lowercase letters, numbers, hyphens only. Cannot start/end with hyphen.';
    }
    final existing = _controller.allDesigns;
    final conflict = existing.any(
      (d) =>
          d.slug == value &&
          (widget.isEditMode ? d.id != widget.existingDesign!.id : true),
    );
    if (conflict) return 'A design with this slug already exists.';
    return null;
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _hasChanges = true;
    });
    _tagInputController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _hasChanges = true;
    });
  }

  void _addKeyword(String value) {
    final kw = value.trim().toLowerCase();
    if (kw.isEmpty || _keywords.contains(kw)) return;
    setState(() {
      _keywords.add(kw);
      _hasChanges = true;
    });
    _keywordInputController.clear();
  }

  void _removeKeyword(String kw) {
    setState(() {
      _keywords.remove(kw);
      _hasChanges = true;
    });
  }

  void _addGalleryUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL cannot be blank.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }
    if (_imageUrls.contains(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This URL is already in the gallery.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }
    setState(() {
      _imageUrls.add(url);
      _hasChanges = true;
    });
    _galleryUrlController.clear();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final boutiqueId =
        BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? '';
    final now = DateTime.now();
    final router = GoRouter.of(context);

    final DesignModel design;
    if (widget.isEditMode) {
      design = widget.existingDesign!.copyWith(
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        categoryId: _selectedCategoryId!,
        shortDescription: _shortDescController.text.trim().isEmpty
            ? null
            : _shortDescController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        thumbnailUrl: _thumbnailController.text.trim().isEmpty
            ? null
            : _thumbnailController.text.trim(),
        imageUrls: _imageUrls,
        tags: _tags,
        searchKeywords: _keywords,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
        updatedAt: now,
        clearShortDescription: _shortDescController.text.trim().isEmpty,
        clearDescription: _descController.text.trim().isEmpty,
        clearThumbnailUrl: _thumbnailController.text.trim().isEmpty,
      );
      _controller.updateDesign(design);
    } else {
      design = DesignModel(
        id: 'design_${now.millisecondsSinceEpoch}',
        boutiqueId: boutiqueId,
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        shortDescription: _shortDescController.text.trim().isEmpty
            ? null
            : _shortDescController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        thumbnailUrl: _thumbnailController.text.trim().isEmpty
            ? null
            : _thumbnailController.text.trim(),
        imageUrls: _imageUrls,
        tags: _tags,
        searchKeywords: _keywords,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        isActive: _isActive,
        createdAt: now,
        updatedAt: now,
      );
      _controller.addDesign(design);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditMode
              ? '"${design.name}" updated.'
              : '"${design.name}" created.',
        ),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    router.go(AppRoutes.adminDesignList);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _thumbnailController.dispose();
    _sortOrderController.dispose();
    _tagInputController.dispose();
    _keywordInputController.dispose();
    _galleryUrlController.dispose();
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
        if (canLeave) router.go(AppRoutes.adminDesignList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'Edit Design' : 'Add Design',
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
              if (canLeave) router.go(AppRoutes.adminDesignList);
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
                        'Name *',
                        TextFormField(
                          controller: _nameController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('e.g. Royal Crimson Bridal Lehenga'),
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
                      _field(
                        'Slug *',
                        TextFormField(
                          controller: _slugController,
                          style: _fieldStyle.copyWith(fontFamily: 'monospace'),
                          cursorColor: AppColors.primary,
                          decoration: _dec('e.g. royal-crimson-bridal-lehenga'),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z0-9-]'),
                            ),
                          ],
                          onChanged: (_) {
                            _slugEditedManually = true;
                            _markDirty();
                          },
                          validator: _validateSlug,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Category dropdown
                      _field('Category *', _buildCategoryDropdown()),
                      const SizedBox(height: AppSpacing.md),
                      _field(
                        'Short Description',
                        TextFormField(
                          controller: _shortDescController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('Brief one-line description'),
                          maxLength: 140,
                          maxLines: 2,
                          minLines: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _field(
                        'Full Description',
                        TextFormField(
                          controller: _descController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('Detailed product description'),
                          maxLength: 1000,
                          maxLines: 5,
                          minLines: 3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _field(
                        'Thumbnail URL',
                        TextFormField(
                          controller: _thumbnailController,
                          style: _fieldStyle,
                          cursorColor: AppColors.primary,
                          decoration: _dec('https://…'),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      if (_thumbnailController.text.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: ClipRRect(
                            borderRadius: AppRadius.borderMd,
                            child: Image.network(
                              _thumbnailController.text.trim(),
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 80,
                                color: AppColors.surfaceLight,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      // Gallery URLs
                      _gallerySection(),
                      const SizedBox(height: AppSpacing.md),
                      // Tags
                      _tagsSection(),
                      const SizedBox(height: AppSpacing.md),
                      // Search keywords
                      _keywordsSection(),
                      const SizedBox(height: AppSpacing.md),
                      _field(
                        'Sort Order *',
                        TextFormField(
                          controller: _sortOrderController,
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
                      // Active toggle
                      _activeToggle(),
                      const SizedBox(height: AppSpacing.xl),
                      _isSaving
                          ? const Center(child: AppLoadingIndicator(size: 36))
                          : AppButton(
                              text: widget.isEditMode
                                  ? 'Save Changes'
                                  : 'Create Design',
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

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryId,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Select category',
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ),
          dropdownColor: AppColors.surfaceLight,
          borderRadius: AppRadius.borderMd,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          icon: const Icon(
            Icons.expand_more_rounded,
            color: AppColors.textMuted,
          ),
          items: _categories
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    c.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _selectedCategoryId = v;
            _hasChanges = true;
          }),
        ),
      ),
    );
  }

  Widget _gallerySection() {
    final boutiqueId = BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? 'default';
    final designId = widget.existingDesign?.id ?? 'new_design';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DesignImagePickerWidget(
          boutiqueId: boutiqueId,
          designId: designId,
          thumbnailUrl: _thumbnailController.text.isNotEmpty ? _thumbnailController.text : null,
          imageUrls: _imageUrls,
          onThumbnailChanged: (newThumb) {
            setState(() {
              _thumbnailController.text = newThumb ?? '';
              _hasChanges = true;
            });
          },
          onImageUrlsChanged: (newUrls) {
            setState(() {
              _imageUrls = newUrls;
              _hasChanges = true;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Or enter Image URL manually (development fallback):',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _galleryUrlController,
                style: _fieldStyle,
                cursorColor: AppColors.primary,
                decoration: _dec(
                  'https://… image URL',
                ).copyWith(hintText: 'Add image URL'),
                keyboardType: TextInputType.url,
                onSubmitted: _addGalleryUrl,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(
                Icons.add_circle_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: () => _addGalleryUrl(_galleryUrlController.text),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: _tags
                .map(
                  (t) => Chip(
                    label: Text(
                      t,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: AppColors.surfaceLight,
                    deleteIconColor: AppColors.textMuted,
                    onDeleted: () => _removeTag(t),
                    side: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagInputController,
                style: _fieldStyle,
                cursorColor: AppColors.primary,
                decoration: _dec('Add tag (e.g. bridal)'),
                onSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(
                Icons.add_circle_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: () => _addTag(_tagInputController.text),
            ),
          ],
        ),
      ],
    );
  }

  Widget _keywordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Keywords',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (_keywords.isNotEmpty)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: _keywords
                .map(
                  (kw) => Chip(
                    label: Text(
                      kw,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: AppColors.surface,
                    deleteIconColor: AppColors.textMuted,
                    onDeleted: () => _removeKeyword(kw),
                    side: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _keywordInputController,
                style: _fieldStyle,
                cursorColor: AppColors.primary,
                decoration: _dec('Add keyword (e.g. bridal lehenga)'),
                onSubmitted: _addKeyword,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(
                Icons.add_circle_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: () => _addKeyword(_keywordInputController.text),
            ),
          ],
        ),
      ],
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
                'Inactive designs are hidden in KC-App.',
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

  Widget _field(String label, Widget child) => Column(
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
