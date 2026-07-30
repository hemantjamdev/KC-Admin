import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../design/domain/models/design_model.dart';
import '../../domain/models/category_model.dart';

/// Screen displaying products assigned to a specific category.
/// Allows removing products from the category with a confirmation dialog.
class AdminCategoryProductsPage extends ConsumerWidget {
  const AdminCategoryProductsPage({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  Future<void> _confirmRemoveProduct(
    BuildContext context,
    WidgetRef ref,
    DesignModel product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Remove Product?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${product.name}" from category "${category.name}"?',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Remove',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final updatedProduct = product.copyWith(
        categoryId: '',
        updatedAt: DateTime.now(),
      );
      await ref.read(designMutationProvider.notifier).update(updatedProduct);

      if (!context.mounted) return;
      AppToast.show(
        context,
        '"${product.name}" removed from "${category.name}".',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(designListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: GoogleFonts.playfairDisplay(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              category.isSystem ? 'System Category' : 'Custom Category',
              style: GoogleFonts.montserrat(
                color: AppColors.textMuted,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.popOrGo(AppRoutes.adminCategoryList),
        ),
      ),
      body: SafeArea(
        child: designsAsync.when(
          loading: () => const AppLoadingState(type: AppLoadingType.list),
          error: (err, stack) => AppErrorState(
            message: 'Failed to load products for ${category.name}.',
            onRetry: () => ref.invalidate(designListProvider),
          ),
          data: (allDesigns) {
            // Filter designs matching category ID or category slug
            final categoryProducts = allDesigns.where((d) {
              return d.categoryId == category.id ||
                  d.categoryId.toLowerCase() == category.slug.toLowerCase();
            }).toList();

            if (categoryProducts.isEmpty) {
              return AppEmptyState(
                title: 'No Products in ${category.name}',
                message: 'No products are currently assigned to this category.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: categoryProducts.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = categoryProducts[index];
                final image = product.thumbnailUrl ??
                    (product.imageUrls.isNotEmpty ? product.imageUrls.first : null);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Product Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image != null && image.isNotEmpty
                            ? Image.network(
                                image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: Icon(
                                    PhosphorIcons.tShirt(),
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  PhosphorIcons.tShirt(),
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            if (product.sizes.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Sizes: ${product.sizes.join(", ")}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Remove Action Button
                      IconButton(
                        onPressed: () => _confirmRemoveProduct(
                          context,
                          ref,
                          product,
                        ),
                        icon: PhosphorIcon(
                          PhosphorIcons.trash(PhosphorIconsStyle.bold),
                          color: AppColors.error,
                          size: 20,
                        ),
                        tooltip: 'Remove from Category',
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
