import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../category/application/providers/category_providers.dart';
import '../../../category/domain/models/category_model.dart';
import '../../application/providers/design_providers.dart';
import '../../domain/models/design_model.dart';
import '../widgets/design_image_picker_widget.dart';

/// Add / Edit Design form page.
/// Pass a [DesignModel] via GoRouter `extra` for edit mode.
class DesignFormPage extends ConsumerStatefulWidget {
  const DesignFormPage({super.key, this.existingDesign});

  final DesignModel? existingDesign;

  bool get isEditMode => existingDesign != null;

  @override
  ConsumerState<DesignFormPage> createState() => _DesignFormPageState();
}

class _DesignFormPageState extends ConsumerState<DesignFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _thumbnailController;

  late FocusNode _nameFocusNode;
  late FocusNode _priceFocusNode;
  late FocusNode _descFocusNode;

  String? _selectedCategoryId;
  List<String> _imageUrls = [];
  List<String> _selectedColors = [];
  List<String> _selectedSizes = [];

  bool _isSaving = false;
  bool _hasChanges = false;

  final List<String> _standardSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'Free Size',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();

    final d = widget.existingDesign;

    _nameController = TextEditingController(text: d?.name ?? '');
    _priceController = TextEditingController(
      text: d?.price != null ? d!.price.toStringAsFixed(0) : '',
    );
    _descController = TextEditingController(text: d?.description ?? '');
    _thumbnailController = TextEditingController(text: d?.thumbnailUrl ?? '');

    _nameFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
    _descFocusNode = FocusNode();

    if (d != null) {
      _selectedCategoryId = d.categoryId;
      _imageUrls = List.from(d.imageUrls);
      if (d.thumbnailUrl != null &&
          d.thumbnailUrl!.isNotEmpty &&
          !_imageUrls.contains(d.thumbnailUrl)) {
        _imageUrls.insert(0, d.thumbnailUrl!);
      }
      _selectedColors = List.from(d.colors);
      _selectedSizes = List.from(d.sizes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _thumbnailController.dispose();

    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    _descFocusNode.dispose();

    super.dispose();
  }


  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Discard Unsaved Product?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Unsaved product details will be discarded.',
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

  void _showColorPickerDialog() {
    Color pickerColor = const Color(0xFFD4AF37);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pick a Color',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
              displayThumbColor: true,
              labelTypes: const [],
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2.0),
                topRight: Radius.circular(2.0),
              ),
              hexInputBar: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'CANCEL',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final hex =
                    '#${pickerColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                if (!_selectedColors.contains(hex)) {
                  setState(() {
                    _selectedColors.add(hex);
                    _hasChanges = true;
                  });
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToCreateCategoryPage() async {
    final result = await context.push<dynamic>(AppRoutes.adminCategoryAdd);
    if (mounted) {
      ref.invalidate(categoryListProvider);
      if (result is String) {
        setState(() {
          _selectedCategoryId = result;
          _hasChanges = true;
        });
      }
    }
  }

  void _showCategoryPicker(List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          builder: (_, scrollController) {
            return SafeArea(
              top: false,
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Category',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${categories.length} categories available',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.surfaceBorder),
                  // List
                  Expanded(
                    child: categories.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    PhosphorIcons.folderOpen(
                                      PhosphorIconsStyle.regular,
                                    ),
                                    size: 40,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No active categories',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      _navigateToCreateCategoryPage();
                                    },
                                    icon: Icon(
                                      PhosphorIcons.plus(
                                        PhosphorIconsStyle.bold,
                                      ),
                                      size: 16,
                                    ),
                                    label: const Text('Add Category'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: categories.length + 1,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: AppColors.surfaceBorder,
                            ),
                            itemBuilder: (context, index) {
                              if (index == categories.length) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    child: Icon(
                                      PhosphorIcons.plus(
                                        PhosphorIconsStyle.bold,
                                      ),
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: Text(
                                    'Create New Category',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    _navigateToCreateCategoryPage();
                                  },
                                );
                              }

                              final cat = categories[index];
                              final isSelected = cat.id == _selectedCategoryId;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceBorder,
                                  child: Icon(
                                    PhosphorIcons.tag(
                                      isSelected
                                          ? PhosphorIconsStyle.fill
                                          : PhosphorIconsStyle.regular,
                                    ),
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                                title: Text(
                                  cat.name,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        PhosphorIcons.checkCircle(
                                          PhosphorIconsStyle.fill,
                                        ),
                                        color: AppColors.primary,
                                        size: 22,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = cat.id;
                                    _hasChanges = true;
                                  });
                                  Navigator.of(ctx).pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          widget.isEditMode ? 'Save Product Changes?' : 'Add New Product?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          widget.isEditMode
              ? 'Are you sure you want to save changes to "${_nameController.text.trim()}"?'
              : 'Are you sure you want to add "${_nameController.text.trim()}" to your product catalogue?',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.montserrat(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              widget.isEditMode ? 'SAVE' : 'ADD PRODUCT',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    const boutiqueId = 'boutique_01';

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    final name = _nameController.text.trim();
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');

    final DesignModel design;
    if (widget.isEditMode) {
      design = widget.existingDesign!.copyWith(
        name: name,
        slug: widget.existingDesign!.slug.isNotEmpty
            ? widget.existingDesign!.slug
            : slug,
        categoryId: _selectedCategoryId ?? widget.existingDesign!.categoryId,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        price: price,
        thumbnailUrl: _thumbnailController.text.trim().isEmpty
            ? null
            : _thumbnailController.text.trim(),
        imageUrls: _imageUrls,
        colors: _selectedColors,
        sizes: _selectedSizes,
        updatedAt: now,
      );
      await ref.read(designMutationProvider.notifier).update(design);
    } else {
      design = DesignModel(
        id: 'design_${now.millisecondsSinceEpoch}',
        boutiqueId: boutiqueId,
        categoryId: _selectedCategoryId ?? 'uncategorized',
        name: name,
        slug: slug,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        price: price,
        thumbnailUrl: _thumbnailController.text.trim().isEmpty
            ? null
            : _thumbnailController.text.trim(),
        imageUrls: _imageUrls,
        tags: const [],
        searchKeywords: const [],
        sortOrder: 0,
        isActive: true,
        colors: _selectedColors,
        sizes: _selectedSizes,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(designMutationProvider.notifier).create(design);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        widget.isEditMode ? 'Product updated' : 'Product created',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    final selectedCategory = categories.cast<CategoryModel?>().firstWhere(
          (c) => c?.id == _selectedCategoryId,
          orElse: () => null,
        );

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) context.pop();
              }
            },
          ),
          title: Text(
            widget.isEditMode ? 'Edit Product' : 'Add New Product',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Image Picker Gallery Section ────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GARMENT IMAGERY',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'First uploaded image will be the main thumbnail displayed in the product list.',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DesignImagePickerWidget(
                  boutiqueId: 'boutique_01',
                  designId: widget.existingDesign?.id ??
                      'temp_${DateTime.now().millisecondsSinceEpoch}',
                  thumbnailUrl: _thumbnailController.text.isNotEmpty
                      ? _thumbnailController.text
                      : null,
                  imageUrls: _imageUrls,
                  onThumbnailChanged: (thumb) {
                    setState(() {
                      _thumbnailController.text = thumb ?? '';
                      _hasChanges = true;
                    });
                  },
                  onImageUrlsChanged: (urls) {
                    setState(() {
                      _imageUrls = urls;
                      _hasChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // ── 2. Basic Information Form Fields ────────────────────────
                Text(
                  'PRODUCT DETAILS',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                // Product Title
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_priceFocusNode),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    hintText: 'e.g., Royal Silk Anarkali Suit',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Product name is required';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() => _hasChanges = true),
                ),
                const SizedBox(height: 14),

                // Price Field
                TextFormField(
                  controller: _priceController,
                  focusNode: _priceFocusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_descFocusNode),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price (₹) (Optional)',
                    hintText: 'e.g., 2499',
                  ),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      if (double.tryParse(v.trim()) == null) {
                        return 'Enter valid price';
                      }
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() => _hasChanges = true),
                ),
                const SizedBox(height: 14),

                // Category Selection Button
                GestureDetector(
                  onTap: () => _showCategoryPicker(categories),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      suffixIcon: Icon(
                        PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                    child: Text(
                      selectedCategory?.name ?? 'Select Category',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: selectedCategory != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontWeight: selectedCategory != null
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Full Description
                TextFormField(
                  controller: _descController,
                  focusNode: _descFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 4,
                  maxLength: 1000,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'Detailed description including fabric, occasion, care, embellishments, and lining.',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 10),

                // ── 3. Color Selection Palette ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COLOR PALETTE (OPTIONAL)',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showColorPickerDialog,
                      icon: Icon(
                        PhosphorIcons.palette(PhosphorIconsStyle.bold),
                        size: 16,
                      ),
                      label: Text(
                        '+ Add Color',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedColors.isEmpty)
                  Text(
                    'No colors selected yet. Tap "+ Add Color" to select swatches.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _selectedColors.map((hex) {
                      Color c = const Color(0xFFD4AF37);
                      try {
                        c = Color(
                          int.parse(
                            hex.replaceFirst('#', 'FF'),
                            radix: 16,
                          ),
                        );
                      } catch (_) {}

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColors.remove(hex);
                                  _hasChanges = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  PhosphorIcons.x(PhosphorIconsStyle.bold),
                                  size: 10,
                                  color: AppColors.surface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                // ── 4. Proper Size Options ─────────────────────────────
                Text(
                  'AVAILABLE SIZES',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _standardSizes.map((size) {
                    final isSelected = _selectedSizes.contains(size);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSizes.remove(size);
                          } else {
                            _selectedSizes.add(size);
                          }
                          _hasChanges = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Icon(
                                PhosphorIcons.check(PhosphorIconsStyle.bold),
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              size,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // ── 5. Action Button ──────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isEditMode ? 'Save Changes' : 'Create Product',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
