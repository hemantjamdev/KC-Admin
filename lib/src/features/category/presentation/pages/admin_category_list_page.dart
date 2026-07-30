import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../application/providers/category_providers.dart';

/// Admin Category List Page — displays, searches, and provides CRUD entry points.
class AdminCategoryListPage extends ConsumerStatefulWidget {
  const AdminCategoryListPage({super.key});

  @override
  ConsumerState<AdminCategoryListPage> createState() =>
      _AdminCategoryListPageState();
}

class _AdminCategoryListPageState extends ConsumerState<AdminCategoryListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmToggleStatus(CategoryModel category) async {
    if (category.isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Deactivate Category?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Inactive categories are hidden from customers in the app. '
            '"${category.name}" will no longer appear in KC-App.',
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
                'Deactivate',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await ref
            .read(categoryMutationProvider.notifier)
            .setActive(category.id, !category.isActive);
      }
    } else {
      await ref
          .read(categoryMutationProvider.notifier)
          .setActive(category.id, !category.isActive);
    }
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Category?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action will remove the category.',
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
              'Delete',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(categoryMutationProvider.notifier)
          .setActive(category.id, false);
      if (!mounted) return;
      AppToast.show(
        context,
        '"${category.name}" deleted successfully.',
        type: ToastType.success,
      );
    }
  }

  Widget _buildFilterChip(CategoryStatusFilter filter, String label) {
    final selected = ref.watch(categoryFilterProvider).statusFilter == filter;
    return GestureDetector(
      onTap: () =>
          ref.read(categoryFilterProvider.notifier).filterByStatus(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: selected ? AppColors.background : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = ref.watch(filteredCategoryListProvider);
    final total = ref.watch(categoryListProvider).valueOrNull?.length ?? 0;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Category Manager',
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
            onPressed: () => context.popOrGo(AppRoutes.adminHome),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 4,
          highlightElevation: 6,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          icon: PhosphorIcon(
            PhosphorIcons.plus(PhosphorIconsStyle.bold),
            size: 18,
          ),
          label: Text(
            'Add Category',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          onPressed: () => context.push(AppRoutes.adminCategoryAdd),
        ),
        body: SafeArea(
          child: ref.watch(categoryListProvider).isLoading
              ? const AppLoadingState(type: AppLoadingType.list)
              : ref.watch(categoryListProvider).hasError
              ? AppErrorState(
                  message: 'Failed to load categories.',
                  onRetry: () => ref.invalidate(categoryListProvider),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category count header
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$total ${total == 1 ? 'category' : 'categories'}',
                              style: GoogleFonts.montserrat(
                                color: AppColors.textMuted,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Search field
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            cursorColor: AppColors.primary,
                            decoration: InputDecoration(
                              hintText: 'Search categories...',
                              hintStyle: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                              prefixIcon: PhosphorIcon(
                                PhosphorIcons.magnifyingGlass(),
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: PhosphorIcon(
                                        PhosphorIcons.x(),
                                        color: AppColors.textMuted,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref
                                            .read(
                                              categoryFilterProvider.notifier,
                                            )
                                            .search('');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: AppRadius.borderMd,
                                borderSide: BorderSide(
                                  color: AppColors.surfaceBorder,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: AppRadius.borderMd,
                                borderSide: BorderSide(
                                  color: AppColors.surfaceBorder,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: AppRadius.borderMd,
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              ref
                                  .read(categoryFilterProvider.notifier)
                                  .search(value);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Status filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  CategoryStatusFilter.all,
                                  'All',
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _buildFilterChip(
                                  CategoryStatusFilter.active,
                                  'Active',
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _buildFilterChip(
                                  CategoryStatusFilter.inactive,
                                  'Inactive',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),

                    Expanded(
                      child: visible.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.xxl + AppSpacing.xl,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                return _CategoryRow(
                                  category: visible[index],
                                  onEdit: () => context.push(
                                    AppRoutes.adminCategoryEdit,
                                    extra: visible[index],
                                  ),
                                  onToggleStatus: () =>
                                      _confirmToggleStatus(visible[index]),
                                  onDelete: () =>
                                      _confirmDelete(visible[index]),
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

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;
    return AppEmptyState(
      icon: hasSearch ? PhosphorIcons.magnifyingGlass() : PhosphorIcons.tag(),
      title: hasSearch ? 'No Matching Categories' : 'No Categories Found',
      message: hasSearch
          ? 'No categories match your search filters.'
          : 'No categories have been created for this boutique yet.',
    );
  }
}

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({
    required this.category,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  String get _initials {
    final parts = category.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return category.name
        .substring(0, category.name.length.clamp(1, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(designListProvider);
    final count = designsAsync.valueOrNull?.where((d) {
          return d.categoryId == category.id ||
              d.categoryId.toLowerCase() == category.slug.toLowerCase();
        }).length ??
        0;

    return InkWell(
      onTap: () => context.push(AppRoutes.adminCategoryProducts, extra: category),
      borderRadius: AppRadius.borderLg,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md - 2,
          ),
          child: Row(
            children: [
              // Avatar Icon / Initial
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.isSystem
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : (category.isActive
                          ? AppColors.accentGlow
                          : AppColors.surfaceBorder),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: category.isSystem
                          ? AppColors.primary
                          : (category.isActive
                              ? AppColors.primary
                              : AppColors.textMuted),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title on its own row to prevent text truncation
                    Text(
                      category.name,
                      style: GoogleFonts.montserrat(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Subtitle Meta Information Row
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.tShirt(PhosphorIconsStyle.regular),
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$count ${count == 1 ? "product" : "products"}',
                              style: GoogleFonts.montserrat(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (category.isSystem) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SYSTEM',
                              style: GoogleFonts.montserrat(
                                color: AppColors.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: category.isActive
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category.isActive ? 'Active' : 'Inactive',
                            style: GoogleFonts.montserrat(
                              color: category.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions menu
              PopupMenuButton<String>(
                color: AppColors.surfaceLight,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderLg,
                ),
                icon: PhosphorIcon(
                  PhosphorIcons.dotsThreeVertical(),
                  color: AppColors.textMuted,
                  size: 20,
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.eye(),
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Text(
                          'View Products',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  if (!category.isSystem)
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.pencilSimple(),
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text(
                            'Edit',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        PhosphorIcon(
                          category.isActive
                              ? PhosphorIcons.eyeSlash()
                              : PhosphorIcons.eye(),
                          color: category.isActive
                              ? AppColors.warning
                              : AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          category.isActive ? 'Deactivate' : 'Activate',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  if (!category.isSystem)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.trash(),
                            color: AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      context.push(
                        AppRoutes.adminCategoryProducts,
                        extra: category,
                      );
                    case 'edit':
                      onEdit();
                    case 'toggle':
                      onToggleStatus();
                    case 'delete':
                      onDelete();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
