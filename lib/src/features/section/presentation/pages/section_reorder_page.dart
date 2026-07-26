import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../design/presentation/controllers/design_controller.dart';
import '../../domain/models/section_model.dart';
import '../controllers/section_controller.dart';

/// Page for drag-and-drop reordering of curated sections within KC-Admin.
class SectionReorderPage extends StatefulWidget {
  const SectionReorderPage({super.key});

  @override
  State<SectionReorderPage> createState() => _SectionReorderPageState();
}

class _SectionReorderPageState extends State<SectionReorderPage> {
  late SectionController _sectionController;
  late DesignController _designController;
  List<SectionModel> _reorderableList = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? '';
    final branchId = scope.selectedBranch?.id;

    _designController = DesignController(
      boutiqueId: boutiqueId,
      activeCategoryIds: const [],
    );
    _sectionController = SectionController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      designController: _designController,
    );
    _sectionController.addListener(_onControllerUpdate);
    _sectionController.loadSections();
  }

  void _onControllerUpdate() {
    if (mounted && _reorderableList.isEmpty && !_sectionController.isLoading) {
      setState(() {
        _reorderableList = List.from(_sectionController.allSections);
      });
    }
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
    _sectionController.reorderSections(_reorderableList);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Section order updated.'),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    router.go(AppRoutes.adminSectionList);
  }

  @override
  void dispose() {
    _sectionController.removeListener(_onControllerUpdate);
    _sectionController.dispose();
    _designController.dispose();
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
        if (canLeave) router.go(AppRoutes.adminSectionList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Reorder Sections',
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
              if (canLeave) router.go(AppRoutes.adminSectionList);
            },
          ),
        ),
        body: SafeArea(
          child: _sectionController.isLoading
              ? const Center(child: AppLoadingIndicator(size: 32))
              : Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Drag handles to change the display sequence of home sections.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _reorderableList.isEmpty
                          ? const Center(
                              child: Text(
                                'No sections found to reorder.',
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
                                final section = _reorderableList[index];
                                return Container(
                                  key: ValueKey(section.id),
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
                                      section.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${section.type.label} • Sort Order: $index',
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
                                  router.go(AppRoutes.adminSectionList);
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
