import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_full_screen_image_dialog.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/stitch_divider.dart';
import '../../../category/application/providers/category_providers.dart';
import '../../../category/domain/models/category_model.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../design/domain/models/design_model.dart';

/// Admin Products Page — rich, appealing list-view catalogue of all boutique products.
/// Features:
/// - Prominent large image cards (no grid layout)
/// - Likes and Favorites count badges
/// - Category pill filter bar & search bar
/// - Swipe left to Delete (with confirmation dialog)
/// - Swipe right to Toggle In-Stock / Out-of-Stock (with confirmation dialog)
/// - Tap to Edit / View Product Details
class AdminProductsPage extends ConsumerStatefulWidget {
  const AdminProductsPage({super.key});

  @override
  ConsumerState<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends ConsumerState<AdminProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _isRowView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(DesignModel design) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Product?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${design.name}"? This action cannot be undone.',
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
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'DELETE',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(designMutationProvider.notifier).delete(design.id);
      if (mounted) {
        AppToast.show(context, '"${design.name}" deleted from catalogue.');
      }
    }
  }

  Future<void> _confirmToggleStock(DesignModel design) async {
    final isCurrentlyActive = design.isActive;
    final actionName = isCurrentlyActive ? 'Out of Stock' : 'In Stock';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mark $actionName?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to mark "${design.name}" as $actionName?',
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
              'CONFIRM',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(designMutationProvider.notifier).toggleStatus(design.id);
      if (mounted) {
        AppToast.show(
          context,
          '"${design.name}" is now marked as $actionName.',
        );
      }
    }
  }

  void _showProductDetails(BuildContext context, DesignModel design) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ProductDetailsSheet(design: design),
    );
  }

  @override
  Widget build(BuildContext context) {
    final designsAsync = ref.watch(designListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final designs = designsAsync.valueOrNull ?? [];
    final categories = categoriesAsync.valueOrNull ?? [];
    final isLoading = designsAsync.isLoading;

    final filteredDesigns = designs.where((d) {
      // Category filter
      if (_selectedCategoryId != null && d.categoryId != _selectedCategoryId) {
        return false;
      }
      // Search query filter
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase().trim();
      final nameMatch = d.name.toLowerCase().contains(q);
      final descMatch = (d.description ?? '').toLowerCase().contains(q);
      final colorMatch = d.colors.any((c) => c.toLowerCase().contains(q));
      final sizeMatch = d.sizes.any((s) => s.toLowerCase().contains(q));
      return nameMatch || descMatch || colorMatch || sizeMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(designListProvider);
            await ref.read(designListProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header (Title & Add Button) ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Products Catalogue',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Swipe cards for quick actions or tap to edit',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search Field ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search products by name or details...',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                      prefixIcon: Icon(
                        PhosphorIcons.magnifyingGlass(
                          PhosphorIconsStyle.bold,
                        ),
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                PhosphorIcons.x(PhosphorIconsStyle.bold),
                                color: AppColors.textMuted,
                                size: 16,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.surfaceBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.surfaceBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Category Filter Pills ──────────────────────────────────
              if (categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _selectedCategoryId == null;
                          return ChoiceChip(
                            selected: isSelected,
                            label: const Text('All Products'),
                            selectedColor: AppColors.primary,
                            labelStyle: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceBorder,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                            },
                          );
                        }

                        final cat = categories[index - 1];
                        final isSelected = _selectedCategoryId == cat.id;

                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(cat.name),
                          selectedColor: AppColors.primary,
                          labelStyle: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceBorder,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedCategoryId = isSelected ? null : cat.id;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── View Toggle Bar (List Row vs Large Banner Card) ────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredDesigns.length} ${filteredDesigns.length == 1 ? 'Product' : 'Products'}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Container(
                        height: 34,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            // List Row View Button
                            GestureDetector(
                              onTap: () {
                                if (!_isRowView) {
                                  setState(() => _isRowView = true);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _isRowView
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      PhosphorIcons.rows(PhosphorIconsStyle.bold),
                                      size: 14,
                                      color: _isRowView
                                          ? Colors.white
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Compact',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _isRowView
                                            ? Colors.white
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            // Large Banner View Button
                            GestureDetector(
                              onTap: () {
                                if (_isRowView) {
                                  setState(() => _isRowView = false);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isRowView
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      PhosphorIcons.cards(
                                        PhosphorIconsStyle.bold,
                                      ),
                                      size: 14,
                                      color: !_isRowView
                                          ? Colors.white
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Large',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: !_isRowView
                                            ? Colors.white
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Product List Content ───────────────────────────────────
              if (isLoading)
                const SliverFillRemaining(
                  child: AppLoadingState(type: AppLoadingType.list),
                )
              else if (designsAsync.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorState(
                    message: 'Failed to load products catalogue.',
                    onRetry: () => ref.invalidate(designListProvider),
                  ),
                )
              else if (filteredDesigns.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: PhosphorIcons.tShirt(),
                    title: _searchQuery.isNotEmpty ||
                            _selectedCategoryId != null
                        ? 'No Matching Products'
                        : 'No Products in Catalogue',
                    message: _searchQuery.isNotEmpty
                        ? 'No product matches your search filter.'
                        : 'Tap "+ Add Product" to add your first product.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList.separated(
                    itemCount: filteredDesigns.length,
                    separatorBuilder: (context, index) => SizedBox(
                      height: _isRowView ? 12 : 18,
                    ),
                    itemBuilder: (context, index) {
                      final design = filteredDesigns[index];
                      final category = categories
                          .cast<CategoryModel?>()
                          .firstWhere(
                            (c) => c?.id == design.categoryId,
                            orElse: () => null,
                          );

                      return _DismissibleProductCard(
                        key: ValueKey('product_${design.id}'),
                        design: design,
                        categoryName: category?.name ?? 'Catalogue',
                        isRowView: _isRowView,
                        onTap: () => _showProductDetails(context, design),
                        onEditTap: () => context.push(
                          AppRoutes.adminDesignEdit,
                          extra: design,
                        ),
                        onLongPress: () => _showProductDetails(context, design),
                        onDeleteConfirmed: () => _confirmDelete(design),
                        onStockToggleConfirmed: () =>
                            _confirmToggleStock(design),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dismissible Product Hero Card ──────────────────────────────────────────────

class _DismissibleProductCard extends StatelessWidget {
  const _DismissibleProductCard({
    super.key,
    required this.design,
    required this.categoryName,
    required this.isRowView,
    required this.onTap,
    required this.onEditTap,
    required this.onLongPress,
    required this.onDeleteConfirmed,
    required this.onStockToggleConfirmed,
  });

  final DesignModel design;
  final String categoryName;
  final bool isRowView;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onLongPress;
  final VoidCallback onDeleteConfirmed;
  final VoidCallback onStockToggleConfirmed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe Left -> Delete
          onDeleteConfirmed();
          return false; // Handled via confirmation dialog
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe Right -> Toggle Stock
          onStockToggleConfirmed();
          return false; // Handled via confirmation dialog
        }
        return false;
      },
      // Swipe Right background (Toggle Stock / Availability)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 28),
        decoration: BoxDecoration(
          color: design.isActive ? AppColors.warning : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              design.isActive
                  ? PhosphorIcons.archive(PhosphorIconsStyle.bold)
                  : PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              design.isActive ? 'Mark Out of Stock' : 'Mark In Stock',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      // Swipe Left background (Delete)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete Product',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              PhosphorIcons.trash(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
      child: isRowView
          ? _ProductRowCard(
              design: design,
              categoryName: categoryName,
              onTap: onTap,
              onEditTap: onEditTap,
              onLongPress: onLongPress,
            )
          : _ProductLargeBannerCard(
              design: design,
              categoryName: categoryName,
              onTap: onTap,
              onEditTap: onEditTap,
              onLongPress: onLongPress,
            ),
    );
  }
}

// ── Compact Row Product Card Component ─────────────────────────────────────────

class _ProductRowCard extends StatelessWidget {
  const _ProductRowCard({
    required this.design,
    required this.categoryName,
    required this.onTap,
    required this.onEditTap,
    required this.onLongPress,
  });

  final DesignModel design;
  final String categoryName;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty ||
        design.imageUrls.isNotEmpty;
    final imageUrl = hasImage
        ? (design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty
              ? design.thumbnailUrl!
              : design.imageUrls.first)
        : null;

    final priceText = design.price > 0
        ? '₹${design.price.toStringAsFixed(0)}'
        : 'Custom Quote';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left: Image Thumbnail (~115px wide) ─────────────────────
              Stack(
                children: [
                  Container(
                    width: 115,
                    height: double.infinity,
                    constraints: const BoxConstraints(minHeight: 130),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(15),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                  // Stock Status Badge (Top Left of image)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: design.isActive
                            ? const Color(0xFF2E7D32)
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        design.isActive ? 'IN STOCK' : 'OUT',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Right: All Details Column ──────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category & Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categoryName.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                priceText,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),

                          // Product Title
                          Text(
                            design.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          if (design.description != null &&
                              design.description!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              design.description!,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          // Colors summary if available
                          if (design.colors.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Wrap(
                                  spacing: 4,
                                  children: design.colors.take(4).map((hex) {
                                    Color c = const Color(0xFFD4AF37);
                                    try {
                                      c = Color(
                                        int.parse(
                                          hex.replaceFirst('#', 'FF'),
                                          radix: 16,
                                        ),
                                      );
                                    } catch (_) {}
                                    return Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surfaceBorder,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (design.sizes.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      design.sizes.join(' · '),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Social Engagement Footer (Likes & Favorites)
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.heart(PhosphorIconsStyle.fill),
                            size: 14,
                            color: const Color(0xFFE53935),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${design.likeCount}',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            PhosphorIcons.bookmarkSimple(
                              PhosphorIconsStyle.fill,
                            ),
                            size: 14,
                            color: const Color(0xFFFFA000),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${design.favoriteCount}',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onEditTap,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                PhosphorIcons.pencilSimple(
                                  PhosphorIconsStyle.bold,
                                ),
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surfaceBorder,
      child: Center(
        child: Icon(
          PhosphorIcons.tShirt(PhosphorIconsStyle.regular),
          color: AppColors.textMuted,
          size: 28,
        ),
      ),
    );
  }
}

// ── Large Banner Product Card Component ────────────────────────────────────────

class _ProductLargeBannerCard extends StatelessWidget {
  const _ProductLargeBannerCard({
    required this.design,
    required this.categoryName,
    required this.onTap,
    required this.onEditTap,
    required this.onLongPress,
  });

  final DesignModel design;
  final String categoryName;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty ||
        design.imageUrls.isNotEmpty;
    final imageUrl = hasImage
        ? (design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty
              ? design.thumbnailUrl!
              : design.imageUrls.first)
        : null;

    final priceText = design.price > 0
        ? '₹${design.price.toStringAsFixed(0)}'
        : 'Custom Quote';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Banner (180px height)
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _bannerPlaceholder(),
                        )
                      : _bannerPlaceholder(),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Stock Status Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: design.isActive
                          ? const Color(0xFF2E7D32)
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      design.isActive ? 'IN STOCK' : 'OUT OF STOCK',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Price Badge
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      priceText,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    design.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (design.description != null &&
                      design.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      design.description!,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const StitchDivider(margin: EdgeInsets.symmetric(vertical: 8)),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        size: 14,
                        color: const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${design.likeCount} likes',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(
                        PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill),
                        size: 14,
                        color: const Color(0xFFFFA000),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${design.favoriteCount} saved',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onEditTap,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerPlaceholder() {
    return Container(
      color: AppColors.surfaceBorder,
      child: Center(
        child: Icon(
          PhosphorIcons.tShirt(PhosphorIconsStyle.regular),
          color: AppColors.textMuted,
          size: 36,
        ),
      ),
    );
  }
}

// ── Product Details Modal Sheet ───────────────────────────────────────────────

class _ProductDetailsSheet extends ConsumerStatefulWidget {
  const _ProductDetailsSheet({required this.design});

  final DesignModel design;

  @override
  ConsumerState<_ProductDetailsSheet> createState() =>
      _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends ConsumerState<_ProductDetailsSheet> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.design.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final design = widget.design;

    final hasImage =
        design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty ||
        design.imageUrls.isNotEmpty;
    final imageUrl = hasImage
        ? (design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty
              ? design.thumbnailUrl!
              : design.imageUrls.first)
        : null;

    final formattedDate = DateFormat('dd MMM yyyy').format(design.createdAt);

    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Image Preview Banner
                  GestureDetector(
                    onTap: () {
                      final urls = design.imageUrls.isNotEmpty
                          ? design.imageUrls
                          : (imageUrl != null ? [imageUrl] : <String>[]);
                      if (urls.isNotEmpty) {
                        AppFullScreenImageDialog.show(context, imageUrls: urls);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceBorder,
                        ),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) =>
                                    _sheetFallback(),
                              )
                            : _sheetFallback(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              design.name,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Added on $formattedDate',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          design.price > 0
                              ? '₹${design.price.toStringAsFixed(0)}'
                              : 'Quote',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const StitchDivider(margin: EdgeInsets.symmetric(vertical: 12)),

                  // Stock Status Toggle Switch Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isActive
                                  ? PhosphorIcons.checkCircle(
                                      PhosphorIconsStyle.fill,
                                    )
                                  : PhosphorIcons.archive(
                                      PhosphorIconsStyle.fill,
                                    ),
                              color: _isActive
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.warning,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isActive
                                      ? 'Product In Stock'
                                      : 'Product Out of Stock',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isActive
                                      ? 'Visible in active catalogue'
                                      : 'Hidden from active customer list',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) async {
                            setState(() => _isActive = val);
                            await ref
                                .read(designMutationProvider.notifier)
                                .toggleStatus(design.id);
                            if (context.mounted) {
                              AppToast.show(
                                context,
                                val
                                    ? 'Marked as In Stock'
                                    : 'Marked as Out of Stock',
                                type: ToastType.info,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const StitchDivider(margin: EdgeInsets.symmetric(vertical: 12)),

                  // Likes & Favs Stats
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        size: 18,
                        color: const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${design.likeCount} Likes',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill),
                        size: 18,
                        color: const Color(0xFFFFA000),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${design.favoriteCount} Saved',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const StitchDivider(margin: EdgeInsets.symmetric(vertical: 12)),

                  if (design.description != null &&
                      design.description!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      design.description!,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action Buttons (Edit & Delete)
                  Row(
                    children: [
                      // Delete Product Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text(
                                  'Delete Product?',
                                  style: GoogleFonts.playfairDisplay(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete "${design.name}"? This action cannot be undone.',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogCtx).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(dialogCtx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).pop();
                              await ref
                                  .read(designMutationProvider.notifier)
                                  .delete(design.id);
                              if (context.mounted) {
                                AppToast.show(
                                  context,
                                  'Product "${design.name}" deleted',
                                  icon: PhosphorIcons.trash(),
                                  type: ToastType.info,
                                );
                              }
                            }
                          },
                          icon: Icon(
                            PhosphorIcons.trash(PhosphorIconsStyle.bold),
                            size: 18,
                            color: AppColors.error,
                          ),
                          label: Text(
                            'Delete',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Edit Details Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            context.push(
                              AppRoutes.adminDesignEdit,
                              extra: design,
                            );
                          },
                          icon: Icon(
                            PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Edit Product',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sheetFallback() {
    return Container(
      color: AppColors.surfaceBorder,
      child: Center(
        child: Icon(
          PhosphorIcons.tShirt(PhosphorIconsStyle.regular),
          color: AppColors.textMuted,
          size: 40,
        ),
      ),
    );
  }
}
