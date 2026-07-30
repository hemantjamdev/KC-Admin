import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_full_screen_image_dialog.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../category/application/providers/category_providers.dart';
import '../../../category/domain/models/category_model.dart';
import '../../domain/models/design_availability_model.dart';
import '../../domain/models/design_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/design_providers.dart';

/// Admin Design List page — shows, searches, and provides CRUD entry points.
class AdminDesignListPage extends ConsumerStatefulWidget {
  const AdminDesignListPage({super.key});

  @override
  ConsumerState<AdminDesignListPage> createState() =>
      _AdminDesignListPageState();
}

class _AdminDesignListPageState extends ConsumerState<AdminDesignListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _initData('boutique_01');
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedDesignsProvider.notifier).fetchNextPage();
    }
  }

  Future<void> _initData(String boutiqueId) async {
    try {
      _categories = await ref.read(categoryRepositoryProvider).watchCategories(boutiqueId).first;
    } catch (_) {
      _categories = [];
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _categoryName(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return categoryId;
    }
  }

  Future<void> _confirmToggleStatus(DesignModel design) async {
    if (!design.isActive) {
      await ref.read(designMutationProvider.notifier).toggleStatus(design.id);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Deactivate Design?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '"${design.name}" will be hidden from KC-App customers.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Deactivate',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(designMutationProvider.notifier).toggleStatus(design.id);
    }
  }

  Future<void> _confirmDelete(DesignModel design) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Delete Product?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${design.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(designMutationProvider.notifier).delete(design.id);
      if (!mounted) return;
      AppToast.show(
        context,
        '"${design.name}" deleted successfully.',
        type: ToastType.success,
      );
    }
  }

  Widget _filterChip<T>(
    T value,
    T current,
    String label,
    void Function(T) onSelected,
  ) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
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
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Designs',
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
            onPressed: () => context.popOrGo(AppRoutes.adminHome),
          ),
          actions: [
            IconButton(
              icon: PhosphorIcon(PhosphorIcons.sortAscending(), color: AppColors.primary),
              tooltip: 'Reorder',
              onPressed: () => context.push(AppRoutes.adminDesignReorder),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          icon: PhosphorIcon(PhosphorIcons.plus()),
          label: const Text(
            'Add',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => context.push(AppRoutes.adminDesignAdd),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              final paginatedState = ref.watch(paginatedDesignsProvider);
              final visible = paginatedState.items;

              return Column(
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
                        Row(
                          children: [
                            Text(
                              '${visible.length} products',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Search field
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            hintText: 'Search designs…',
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
                                          .read(paginatedDesignsProvider.notifier)
                                          .fetchInitial(
                                            categoryId: ref
                                                .read(designFilterProvider)
                                                .selectedCategoryId,
                                            query: '',
                                          );
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
                          onChanged: (v) {
                            ref
                                .read(paginatedDesignsProvider.notifier)
                                .fetchInitial(
                                  categoryId: ref
                                      .read(designFilterProvider)
                                      .selectedCategoryId,
                                  query: v,
                                );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Status filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterChip(
                                DesignStatusFilter.all,
                                ref.watch(designFilterProvider).statusFilter,
                                'All',
                                (v) {
                                  ref
                                      .read(designFilterProvider.notifier)
                                      .filterByStatus(v);
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _filterChip(
                                DesignStatusFilter.active,
                                ref.watch(designFilterProvider).statusFilter,
                                'Active',
                                (v) {
                                  ref
                                      .read(designFilterProvider.notifier)
                                      .filterByStatus(v);
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _filterChip(
                                DesignStatusFilter.inactive,
                                ref.watch(designFilterProvider).statusFilter,
                                'Inactive',
                                (v) {
                                  ref
                                      .read(designFilterProvider.notifier)
                                      .filterByStatus(v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Category filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterChip<String?>(
                                null,
                                ref
                                    .watch(designFilterProvider)
                                    .selectedCategoryId,
                                'All Categories',
                                (v) {
                                  ref
                                      .read(designFilterProvider.notifier)
                                      .filterByCategory(v);
                                  ref
                                      .read(paginatedDesignsProvider.notifier)
                                      .fetchInitial(
                                        categoryId: v,
                                        query: _searchController.text,
                                      );
                                },
                              ),
                              ..._categories.map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.sm,
                                  ),
                                  child: _filterChip<String?>(
                                    c.id,
                                    ref
                                        .watch(designFilterProvider)
                                        .selectedCategoryId,
                                    c.name,
                                    (v) {
                                      ref
                                          .read(designFilterProvider.notifier)
                                          .filterByCategory(v);
                                      ref
                                          .read(paginatedDesignsProvider.notifier)
                                          .fetchInitial(
                                            categoryId: v,
                                            query: _searchController.text,
                                          );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        await ref
                            .read(paginatedDesignsProvider.notifier)
                            .refresh();
                      },
                      child: paginatedState.isLoading && visible.isEmpty
                          ? const AppLoadingState(type: AppLoadingType.list)
                          : paginatedState.errorMessage != null && visible.isEmpty
                          ? AppErrorState(
                              message: 'Failed to load designs list.',
                              onRetry: () => ref
                                  .read(paginatedDesignsProvider.notifier)
                                  .refresh(),
                            )
                          : visible.isEmpty
                          ? _emptyState()
                          : ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.xxl + AppSpacing.xl,
                              ),
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              itemCount: visible.length +
                                  (paginatedState.isLoadingMore ? 1 : 0),
                              separatorBuilder: (ctx, i) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, i) {
                                if (i == visible.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                }
                                final design = visible[i];
                                final DesignAvailabilityModel? avail = null;
                                return _DesignRow(
                                  design: design,
                                  categoryName: _categoryName(
                                    design.categoryId,
                                  ),
                                  availability: avail,
                                  onEdit: () => context.push(
                                    AppRoutes.adminDesignEdit,
                                    extra: design,
                                  ),
                                  onAvailability: () => context.push(
                                    AppRoutes.adminDesignAvailability,
                                    extra: design,
                                  ),
                                  onToggleStatus: () =>
                                      _confirmToggleStatus(design),
                                  onDelete: () => _confirmDelete(design),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final hasSearch =
        _searchController.text.isNotEmpty ||
        ref.watch(designFilterProvider).selectedCategoryId != null ||
        ref.watch(designFilterProvider).statusFilter !=
            DesignStatusFilter.all ||
        ref.watch(designFilterProvider).availabilityFilter !=
            AvailabilityFilter.all;
    return AppEmptyState(
      icon: hasSearch ? PhosphorIcons.magnifyingGlass() : PhosphorIcons.tShirt(),
      title: hasSearch ? 'No Matching Designs' : 'No Designs Found',
      message: hasSearch
          ? 'No designs match the selected search or filters.'
          : 'No design products have been created for this boutique yet.',
    );
  }
}

// ---------------------------------------------------------------------------
// Design Row Widget
// ---------------------------------------------------------------------------

class _DesignRow extends StatelessWidget {
  const _DesignRow({
    required this.design,
    required this.categoryName,
    required this.availability,
    required this.onEdit,
    required this.onAvailability,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final DesignModel design;
  final String categoryName;
  final DesignAvailabilityModel? availability;
  final VoidCallback onEdit;
  final VoidCallback onAvailability;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  String get _initials {
    final parts = design.name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : design.name
              .substring(0, design.name.length.clamp(1, 2))
              .toUpperCase();
  }

  Color get _availColor {
    if (availability == null) return AppColors.textMuted;
    return switch (availability!.status) {
      AvailabilityStatus.available => AppColors.success,
      AvailabilityStatus.unavailable => AppColors.warning,
      AvailabilityStatus.hidden => AppColors.error,
    };
  }

  String get _availLabel {
    if (availability == null) return 'Not set';
    return availability!.status.label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            // Thumbnail / Fallback
            GestureDetector(
              onTap: () {
                final urls = design.imageUrls.isNotEmpty
                    ? design.imageUrls
                    : (design.thumbnailUrl != null
                          ? [design.thumbnailUrl!]
                          : <String>[]);
                if (urls.isNotEmpty) {
                  AppFullScreenImageDialog.show(context, imageUrls: urls);
                }
              },
              child: ClipRRect(
                borderRadius: AppRadius.borderMd,
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: design.thumbnailUrl != null
                      ? Image.network(
                          design.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallback(),
                        )
                      : _fallback(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          design.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _Badge(
                        label: design.isActive ? 'Active' : 'Inactive',
                        color: design.isActive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          design.slug,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _Badge(label: _availLabel, color: _availColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '#${design.sortOrder}',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  value: 'availability',
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.sliders(),
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'Availability',
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
                        design.isActive
                            ? PhosphorIcons.eyeSlash()
                            : PhosphorIcons.eye(),
                        color: design.isActive
                            ? AppColors.warning
                            : AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        design.isActive ? 'Deactivate' : 'Activate',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
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
                      const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                  case 'availability':
                    onAvailability();
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
    );
  }

  Widget _fallback() => Container(
    color: AppColors.surfaceLight,
    child: Center(
      child: Text(
        _initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: AppRadius.borderPill,
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}
