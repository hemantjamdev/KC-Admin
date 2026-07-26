import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/data/repositories/category_firestore_repository.dart';
import '../../domain/models/category_model.dart';
import '../controllers/category_controller.dart';

/// Reorder categories page — drag to rearrange sortOrder.
class CategoryReorderPage extends StatefulWidget {
  const CategoryReorderPage({super.key});

  @override
  State<CategoryReorderPage> createState() => _CategoryReorderPageState();
}

class _CategoryReorderPageState extends State<CategoryReorderPage> {
  final CategoryFirestoreRepository _repository = CategoryFirestoreRepository();
  late CategoryController _controller;
  List<CategoryModel> _orderedCategories = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final boutiqueId =
        BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? '';
    _controller = CategoryController(boutiqueId: boutiqueId);

    _initData(boutiqueId);
  }

  Future<void> _initData(String boutiqueId) async {
    final list = await _repository.watchCategories(boutiqueId).first;
    if (!mounted) return;
    setState(() {
      _orderedCategories = List.of(list);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Discard Reorder?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Your reorder changes have not been saved.',
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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _orderedCategories.removeAt(oldIndex);
      _orderedCategories.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  void _save() {
    _controller.reorderCategories(_orderedCategories);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category order saved (mock session).'),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    context.go(AppRoutes.adminCategoryList);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final canLeave = await _onWillPop();
        if (canLeave) router.go(AppRoutes.adminCategoryList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Reorder Categories',
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
              if (canLeave) router.go(AppRoutes.adminCategoryList);
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.textMuted,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Drag handles to reorder. Save applies sequential sort values (0, 1, 2…).',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _orderedCategories.length,
                  onReorder: _onReorder,
                  proxyDecorator: (child, index, animation) {
                    return Material(color: AppColors.transparent, child: child);
                  },
                  itemBuilder: (context, index) {
                    final category = _orderedCategories[index];
                    return _ReorderRow(
                      key: ValueKey(category.id),
                      index: index,
                      category: category,
                    );
                  },
                ),
              ),

              // Bottom action buttons
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
                            router.go(AppRoutes.adminCategoryList);
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

class _ReorderRow extends StatelessWidget {
  const _ReorderRow({super.key, required this.index, required this.category});

  final int index;
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Icon(
                Icons.drag_handle_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.accentGlow,
                borderRadius: AppRadius.borderSm,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.slug,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: category.isActive
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: AppRadius.borderPill,
              ),
              child: Text(
                category.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: category.isActive
                      ? AppColors.success
                      : AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
