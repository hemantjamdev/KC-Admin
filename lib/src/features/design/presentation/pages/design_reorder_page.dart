import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../category/application/providers/category_providers.dart';
import '../../../category/domain/models/category_model.dart';
import '../../domain/models/design_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/design_providers.dart';

/// Page for drag-and-drop reordering of designs within KC-Admin.
class DesignReorderPage extends ConsumerStatefulWidget {
  const DesignReorderPage({super.key});

  @override
  ConsumerState<DesignReorderPage> createState() => _DesignReorderPageState();
}

class _DesignReorderPageState extends ConsumerState<DesignReorderPage> {
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  List<DesignModel> _reorderableList = [];
  bool _hasChanges = false;
  bool _allowDiscardPop = false;

  @override
  void initState() {
    super.initState();
    const boutiqueId = 'boutique_01';
    _initData(boutiqueId);
  }

  Future<void> _initData(String boutiqueId) async {
    try {
      _categories = await ref.read(categoryRepositoryProvider).watchCategories(boutiqueId).first;
    } catch (_) {
      _categories = [];
    }
    if (!mounted) return;
    // Populate from provider once data loads
    final designs = ref.read(designListProvider).valueOrNull ?? [];
    setState(() {
      _reorderableList = List.from(designs);
    });
  }

  void _filterList() {
    setState(() {
      final all = ref.read(designListProvider).valueOrNull ?? [];
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
    await ref.read(designMutationProvider.notifier).reorder(_reorderableList);
    if (!mounted) return;
    AppToast.show(
      context,
      'Design order updated successfully.',
      type: ToastType.success,
    );
    context.popOrGoWithResult(true, AppRoutes.adminDesignList);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges || _allowDiscardPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canLeave = await _onWillPop();
        if (canLeave && context.mounted) {
          setState(() => _allowDiscardPop = true);
          context.popOrGo(AppRoutes.adminDesignList);
        }
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
            icon: PhosphorIcon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              if (!_hasChanges) {
                context.popOrGo(AppRoutes.adminDesignList);
                return;
              }
              final canLeave = await _onWillPop();
              if (canLeave && context.mounted) {
                setState(() => _allowDiscardPop = true);
                context.popOrGo(AppRoutes.adminDesignList);
              }
            },
          ),
        ),
        body: SafeArea(
          child: ref.watch(designListProvider).isLoading
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
