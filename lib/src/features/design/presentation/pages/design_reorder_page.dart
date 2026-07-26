import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/data/repositories/category_firestore_repository.dart';
import '../../../category/domain/models/category_model.dart';
import '../../domain/models/design_model.dart';
import '../controllers/design_controller.dart';

/// Page for drag-and-drop reordering of designs within KC-Admin.
class DesignReorderPage extends StatefulWidget {
  const DesignReorderPage({super.key});

  @override
  State<DesignReorderPage> createState() => _DesignReorderPageState();
}

class _DesignReorderPageState extends State<DesignReorderPage> {
  final CategoryFirestoreRepository _categoryRepository = CategoryFirestoreRepository();
  late DesignController _controller;
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  List<DesignModel> _reorderableList = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final boutiqueId =
        BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? '';
    _controller = DesignController(
      boutiqueId: boutiqueId,
      activeCategoryIds: const [],
    );
    _controller.addListener(_onControllerUpdate);

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

  void _onControllerUpdate() {
    if (mounted && _reorderableList.isEmpty && !_controller.isLoading) {
      _filterList();
    }
  }

  void _filterList() {
    setState(() {
      final all = _controller.allDesigns;
      if (_selectedCategoryId == null) {
        _reorderableList = List.from(all);
      } else {
        _reorderableList = all
            .where((d) => d.categoryId == _selectedCategoryId)
            .toList();
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _reorderableList.removeAt(oldIndex);
      _reorderableList.insert(newIndex, item);
      _hasChanges = true;
    });
  }

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
          'Reordered sequence will not be saved.',
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

  Future<void> _save() async {
    final router = GoRouter.of(context);
    _controller.reorderDesigns(_reorderableList);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Design order updated (in-memory).'),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    router.go(AppRoutes.adminDesignList);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
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
          title: const Text(
            'Reorder Designs',
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
            onPressed: () async {
              final router = GoRouter.of(context);
              final canLeave = await _onWillPop();
              if (canLeave) router.go(AppRoutes.adminDesignList);
            },
          ),
        ),
        body: SafeArea(
          child: _controller.isLoading
              ? const Center(child: AppLoadingIndicator(size: 32))
              : Column(
                  children: [
                    // Category Filter Header
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedCategoryId,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceLight,
                            hint: const Text(
                              'All Categories',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'All Categories',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ..._categories.map(
                                (c) => DropdownMenuItem<String?>(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              _selectedCategoryId = v;
                              _filterList();
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _reorderableList.isEmpty
                          ? const Center(
                              child: Text(
                                'No designs found to reorder.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _reorderableList.length,
                              onReorder: _onReorder,
                              proxyDecorator: (child, _, _) => Material(
                                color: Colors.transparent,
                                child: child,
                              ),
                              itemBuilder: (context, index) {
                                final design = _reorderableList[index];
                                return Container(
                                  key: ValueKey(design.id),
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppRadius.borderMd,
                                    border: Border.all(
                                      color: AppColors.surfaceBorder,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(
                                        Icons.drag_handle_rounded,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    title: Text(
                                      design.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Sort Order: $index (was #${design.sortOrder})',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Cancel',
                              variant: AppButtonVariant.secondary,
                              onPressed: () async {
                                final router = GoRouter.of(context);
                                final canLeave = await _onWillPop();
                                if (canLeave) {
                                  router.go(AppRoutes.adminDesignList);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              text: 'Save Order',
                              onPressed: _hasChanges ? _save : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
