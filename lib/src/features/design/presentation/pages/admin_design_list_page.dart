import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/data/repositories/category_firestore_repository.dart';
import '../../../category/domain/models/category_model.dart';
import '../../domain/models/design_availability_model.dart';
import '../../domain/models/design_model.dart';
import '../controllers/design_controller.dart';

/// Admin Design List page — shows, searches, and provides CRUD entry points.
class AdminDesignListPage extends StatefulWidget {
  const AdminDesignListPage({super.key});

  @override
  State<AdminDesignListPage> createState() => _AdminDesignListPageState();
}

class _AdminDesignListPageState extends State<AdminDesignListPage> {
  late DesignController _controller;
  final CategoryFirestoreRepository _categoryRepository = CategoryFirestoreRepository();
  final TextEditingController _searchController = TextEditingController();
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  DesignStatusFilter _statusFilter = DesignStatusFilter.all;
  AvailabilityFilter _availabilityFilter = AvailabilityFilter.all;

  @override
  void initState() {
    super.initState();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? '';

    _controller = DesignController(
      boutiqueId: boutiqueId,
      activeCategoryIds: [],
    );
    _controller.addListener(_onUpdate);

    _initData(boutiqueId);
  }

  Future<void> _initData(String boutiqueId) async {
    try {
      _categories = await _categoryRepository.watchCategories(boutiqueId).first;
    } catch (_) {
      _categories = [];
    }
    if (!mounted) return;
    _controller.loadDesigns();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    _searchController.dispose();
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
      _controller.toggleDesignStatus(design.id);
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
    if (confirmed == true) _controller.toggleDesignStatus(design.id);
  }

  Future<void> _confirmDelete(DesignModel design) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Delete Design?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This removes "${design.name}" from in-memory mock data. '
          'Related availability records will also be removed.',
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
      _controller.deleteDesign(design.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${design.name}" deleted from mock data.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
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
    final visible = _controller.visibleDesigns;

    return Scaffold(
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
            onPressed: () => context.go(AppRoutes.adminDesignReorder),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => context.go(AppRoutes.adminDesignAdd),
      ),
      body: SafeArea(
        child: _controller.isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLoadingIndicator(size: 32),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Loading designs...',
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
                              '${_controller.totalCount} designs',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
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
                                      _controller.searchDesigns('');
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
                            _controller.searchDesigns(v);
                            setState(() {});
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
                                _statusFilter,
                                'All',
                                (v) {
                                  setState(() => _statusFilter = v);
                                  _controller.filterByStatus(v);
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _filterChip(
                                DesignStatusFilter.active,
                                _statusFilter,
                                'Active',
                                (v) {
                                  setState(() => _statusFilter = v);
                                  _controller.filterByStatus(v);
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _filterChip(
                                DesignStatusFilter.inactive,
                                _statusFilter,
                                'Inactive',
                                (v) {
                                  setState(() => _statusFilter = v);
                                  _controller.filterByStatus(v);
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
                                _selectedCategoryId,
                                'All Categories',
                                (v) {
                                  setState(() => _selectedCategoryId = v);
                                  _controller.filterByCategory(v);
                                },
                              ),
                              ..._categories.map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.sm,
                                  ),
                                  child: _filterChip<String?>(
                                    c.id,
                                    _selectedCategoryId,
                                    c.name,
                                    (v) {
                                      setState(() => _selectedCategoryId = v);
                                      _controller.filterByCategory(v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (branch != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          // Availability filter
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _filterChip(
                                  AvailabilityFilter.all,
                                  _availabilityFilter,
                                  'Any Availability',
                                  (v) {
                                    setState(() => _availabilityFilter = v);
                                    _controller.filterByAvailability(
                                      v,
                                      branchId: branch.id,
                                    );
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _filterChip(
                                  AvailabilityFilter.available,
                                  _availabilityFilter,
                                  'Available',
                                  (v) {
                                    setState(() => _availabilityFilter = v);
                                    _controller.filterByAvailability(
                                      v,
                                      branchId: branch.id,
                                    );
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _filterChip(
                                  AvailabilityFilter.unavailable,
                                  _availabilityFilter,
                                  'Unavailable',
                                  (v) {
                                    setState(() => _availabilityFilter = v);
                                    _controller.filterByAvailability(
                                      v,
                                      branchId: branch.id,
                                    );
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _filterChip(
                                  AvailabilityFilter.hidden,
                                  _availabilityFilter,
                                  'Hidden',
                                  (v) {
                                    setState(() => _availabilityFilter = v);
                                    _controller.filterByAvailability(
                                      v,
                                      branchId: branch.id,
                                    );
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _filterChip(
                                  AvailabilityFilter.notConfigured,
                                  _availabilityFilter,
                                  'Not Configured',
                                  (v) {
                                    setState(() => _availabilityFilter = v);
                                    _controller.filterByAvailability(
                                      v,
                                      branchId: branch.id,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? _emptyState()
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
                            itemBuilder: (context, i) {
                              final design = visible[i];
                              final branchId = branch?.id;
                              final avail = branchId != null
                                  ? _controller.getAvailabilityForBranchDesign(
                                      branchId,
                                      design.id,
                                    )
                                  : null;
                              return _DesignRow(
                                design: design,
                                categoryName: _categoryName(design.categoryId),
                                availability: avail,
                                onEdit: () => context.go(
                                  AppRoutes.adminDesignEdit,
                                  extra: design,
                                ),
                                onAvailability: () => context.go(
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
                ],
              ),
      ),
    );
  }

  Widget _emptyState() {
    final hasSearch =
        _searchController.text.isNotEmpty ||
        _selectedCategoryId != null ||
        _statusFilter != DesignStatusFilter.all ||
        _availabilityFilter != AvailabilityFilter.all;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.style_outlined,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasSearch
                  ? 'No designs match the selected filters.'
                  : 'No designs have been created for this boutique.',
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
            ClipRRect(
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
                        'Edit',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'availability',
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
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
                      Icon(
                        design.isActive
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
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
                      Text('Delete', style: TextStyle(color: AppColors.error)),
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
