import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../design/presentation/controllers/design_controller.dart';
import '../../domain/models/section_model.dart';
import '../controllers/section_controller.dart';

/// Admin Section List page — list, search, filter, and manage curated sections.
class AdminSectionListPage extends StatefulWidget {
  const AdminSectionListPage({super.key});

  @override
  State<AdminSectionListPage> createState() => _AdminSectionListPageState();
}

class _AdminSectionListPageState extends State<AdminSectionListPage> {
  late SectionController _sectionController;
  late DesignController _designController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? '';
    final branchId = scope.selectedBranch?.id ?? '';

    _designController = DesignController(
      boutiqueId: boutiqueId,
      activeCategoryIds: const [],
    );
    _designController.loadDesigns();

    _sectionController = SectionController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      designController: _designController,
    );
    _sectionController.addListener(_onUpdate);
    _sectionController.loadSections();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sectionController.removeListener(_onUpdate);
    _sectionController.dispose();
    _designController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmToggleStatus(SectionModel section) async {
    if (!section.isActive) {
      _sectionController.toggleSectionStatus(section.id);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Deactivate Section?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '"${section.title}" will be hidden from KC-App customers.',
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
    if (confirmed == true) _sectionController.toggleSectionStatus(section.id);
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
      _sectionController.deleteSection(section.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${section.title}" deleted.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAutomaticPreview(SectionModel section) {
    final branchId = BoutiqueSelectionScope.of(context).selectedBranch?.id;
    final resolved = _sectionController.getDesignsForSection(section, branchId);
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
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: resolved.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
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
    final scope = BoutiqueSelectionScope.of(context);
    final boutique = scope.selectedBoutique;
    final branch = scope.selectedBranch;
    final visible = _sectionController.visibleSections;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sections',
          style: TextStyle(
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
          onPressed: () => context.go(AppRoutes.adminHome),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: AppColors.primary),
            tooltip: 'Reorder',
            onPressed: () => context.go(AppRoutes.adminSectionReorder),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Section',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.go(AppRoutes.adminSectionAdd),
      ),
      body: SafeArea(
        child: _sectionController.isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLoadingIndicator(size: 32),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Loading sections...',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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
                            Expanded(
                              child: Text(
                                boutique?.name ?? '—',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (branch != null)
                              Text(
                                branch.name,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              '${_sectionController.allSections.length} sections',
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
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _sectionController.searchSections('');
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
                            _sectionController.searchSections(v);
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
                                _sectionController.selectedTypeFilter,
                                'All Types',
                                (v) => _sectionController.filterByType(v),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _filterChip<SectionType?>(
                                SectionType.manual,
                                _sectionController.selectedTypeFilter,
                                'Manual',
                                (v) => _sectionController.filterByType(v),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _filterChip<SectionType?>(
                                SectionType.newArrivals,
                                _sectionController.selectedTypeFilter,
                                'New Arrivals',
                                (v) => _sectionController.filterByType(v),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _filterChip<SectionType?>(
                                SectionType.recommended,
                                _sectionController.selectedTypeFilter,
                                'Recommended',
                                (v) => _sectionController.filterByType(v),
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
                              final resolvedCount = _sectionController
                                  .getDesignsForSection(section, branch?.id)
                                  .length;
                              return _SectionRow(
                                section: section,
                                itemCount: resolvedCount,
                                onEdit: () => context.go(
                                  AppRoutes.adminSectionEdit,
                                  extra: section,
                                ),
                                onManageItems: () => context.go(
                                  AppRoutes.adminSectionItemManagement,
                                  extra: section,
                                ),
                                onPreview: () => _showAutomaticPreview(section),
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
    );
  }

  Widget _emptyState() {
    final hasFilter =
        _searchController.text.isNotEmpty ||
        _sectionController.selectedTypeFilter != null ||
        _sectionController.statusFilter != SectionStatusFilter.all;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter ? Icons.search_off_rounded : Icons.view_day_outlined,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilter
                  ? 'No sections match the selected filters.'
                  : 'No sections have been created for this boutique.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Edit Section',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    if (section.type == SectionType.manual)
                      const PopupMenuItem(
                        value: 'items',
                        child: Row(
                          children: [
                            Icon(
                              Icons.playlist_add_check_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Manage Items',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'preview',
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
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
                          Icon(
                            section.isActive
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
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
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
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
