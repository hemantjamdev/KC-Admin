import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/section_model.dart';
import '../../../design/domain/models/design_model.dart';
import '../../application/providers/section_providers.dart';

/// Admin Section List page — list, search, filter, and manage curated sections.
class AdminSectionListPage extends ConsumerStatefulWidget {
  const AdminSectionListPage({super.key});

  @override
  ConsumerState<AdminSectionListPage> createState() =>
      _AdminSectionListPageState();
}

class _AdminSectionListPageState extends ConsumerState<AdminSectionListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmToggleStatus(SectionModel section) async {
    final updated = section.copyWith(
      isActive: !section.isActive,
      updatedAt: DateTime.now(),
    );
    await ref.read(sectionMutationProvider.notifier).update(updated);
  }

  Future<void> _confirmDelete(SectionModel section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Delete Section?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This removes "${section.title}". Associated section items will be removed, but design entries will remain intact.',
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
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(sectionMutationProvider.notifier).delete(section.id);
      if (!mounted) return;
      AppToast.show(
        context,
        '"${section.title}" deleted.',
        type: ToastType.success,
      );
    }
  }

  void _showAutomaticPreview(SectionModel section) {
    final resolved = <DesignModel>[];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              section.type == SectionType.newArrivals
                  ? 'Automatic Preview: Resolves newest eligible designs by creation date.'
                  : 'Automatic Preview: Resolves featured/popular tagged designs.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.md),
            if (resolved.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No eligible designs resolved currently.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: resolved.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (ctx, i) {
                    final d = resolved[i];
                    return Container(
                      width: 120,
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: AppRadius.borderSm,
                              child: d.thumbnailUrl != null
                                  ? Image.network(
                                      d.thumbnailUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(color: AppColors.surface),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            d.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
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
          borderRadius: AppRadius.borderPill,
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
    final visible = ref.watch(filteredSectionListProvider);
    final totalSections =
        ref.watch(sectionListProvider).valueOrNull?.length ?? 0;
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
            'Homepage Sections',
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
              onPressed: () => context.push(AppRoutes.adminSectionReorder),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          icon: PhosphorIcon(PhosphorIcons.plus()),
          label: const Text(
            'Add Section',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => context.push(AppRoutes.adminSectionAdd),
        ),
        body: SafeArea(
          child: ref.watch(sectionListProvider).isLoading
              ? const AppLoadingState(type: AppLoadingType.list)
              : ref.watch(sectionListProvider).hasError
              ? AppErrorState(
                  message: 'Failed to load sections list.',
                  onRetry: () => ref.invalidate(sectionListProvider),
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
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Kapada Creation Studio',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                '$totalSections sections',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Search Field
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            cursorColor: AppColors.primary,
                            decoration: InputDecoration(
                              hintText: 'Search sections…',
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
                                              sectionFilterProvider.notifier,
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
                            onChanged: (v) {
                              ref
                                  .read(sectionFilterProvider.notifier)
                                  .search(v);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _filterChip<SectionType?>(
                                  null,
                                  ref.watch(sectionFilterProvider).typeFilter,
                                  'All Types',
                                  (v) => ref
                                      .read(sectionFilterProvider.notifier)
                                      .filterByType(v),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _filterChip<SectionType?>(
                                  SectionType.manual,
                                  ref.watch(sectionFilterProvider).typeFilter,
                                  'Manual',
                                  (v) => ref
                                      .read(sectionFilterProvider.notifier)
                                      .filterByType(v),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _filterChip<SectionType?>(
                                  SectionType.newArrivals,
                                  ref.watch(sectionFilterProvider).typeFilter,
                                  'New Arrivals',
                                  (v) => ref
                                      .read(sectionFilterProvider.notifier)
                                      .filterByType(v),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _filterChip<SectionType?>(
                                  SectionType.recommended,
                                  ref.watch(sectionFilterProvider).typeFilter,
                                  'Recommended',
                                  (v) => ref
                                      .read(sectionFilterProvider.notifier)
                                      .filterByType(v),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ),
                    ),
                    Expanded(
                      child: visible.isEmpty
                          ? _emptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.sm,
                                AppSpacing.lg,
                                AppSpacing.xxl + AppSpacing.xl,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, i) {
                                final section = visible[i];
                                final resolvedCount = 0;
                                return _SectionRow(
                                  section: section,
                                  itemCount: resolvedCount,
                                  onEdit: () => context.push(
                                    AppRoutes.adminSectionEdit,
                                    extra: section,
                                  ),
                                  onManageItems: () => context.push(
                                    AppRoutes.adminSectionItemManagement,
                                    extra: section,
                                  ),
                                  onPreview: () =>
                                      _showAutomaticPreview(section),
                                  onToggleStatus: () =>
                                      _confirmToggleStatus(section),
                                  onDelete: () => _confirmDelete(section),
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

  Widget _emptyState() {
    final hasFilter =
        _searchController.text.isNotEmpty ||
        ref.watch(sectionFilterProvider).typeFilter != null;
    return AppEmptyState(
      icon: hasFilter ? PhosphorIcons.magnifyingGlass() : PhosphorIcons.squaresFour(),
      title: hasFilter ? 'No Matching Sections' : 'No Sections Found',
      message: hasFilter
          ? 'No sections match the selected search or filters.'
          : 'No home sections have been configured for this boutique yet.',
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.section,
    required this.itemCount,
    required this.onEdit,
    required this.onManageItems,
    required this.onPreview,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final SectionModel section;
  final int itemCount;
  final VoidCallback onEdit;
  final VoidCallback onManageItems;
  final VoidCallback onPreview;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  String _branchName(BuildContext context) {
    if (section.branchId == null) return 'Boutique-wide';
    return 'Branch (${section.branchId})';
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _Badge(
                  label: section.isActive ? 'Active' : 'Inactive',
                  color: section.isActive ? AppColors.success : AppColors.error,
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
                            'Edit Section',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    if (section.type == SectionType.manual)
                      PopupMenuItem(
                        value: 'items',
                        child: Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.listChecks(),
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Text(
                              'Manage Items',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      )
                    else
                      PopupMenuItem(
                        value: 'preview',
                        child: Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.eye(),
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Text(
                              'Preview Designs',
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
                            section.isActive
                                ? PhosphorIcons.eyeSlash()
                                : PhosphorIcons.eye(),
                            color: section.isActive
                                ? AppColors.warning
                                : AppColors.success,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            section.isActive ? 'Deactivate' : 'Activate',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
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
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (val) {
                    switch (val) {
                      case 'edit':
                        onEdit();
                      case 'items':
                        onManageItems();
                      case 'preview':
                        onPreview();
                      case 'toggle':
                        onToggleStatus();
                      case 'delete':
                        onDelete();
                    }
                  },
                ),
              ],
            ),
            if (section.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                section.subtitle!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _Badge(label: section.type.label, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                _Badge(label: _branchName(context), color: AppColors.textMuted),
                const Spacer(),
                Text(
                  '$itemCount items • #${section.sortOrder}',
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
    );
  }
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
