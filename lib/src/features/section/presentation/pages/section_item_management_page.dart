import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/section_model.dart';
import '../../application/providers/section_providers.dart';
import '../../../design/application/providers/design_providers.dart';
import 'section_design_picker_page.dart';

/// Page for managing items inside a manual section (add, remove, reorder).
class SectionItemManagementPage extends ConsumerStatefulWidget {
  const SectionItemManagementPage({super.key, required this.section});
  final SectionModel section;

  @override
  ConsumerState<SectionItemManagementPage> createState() =>
      _SectionItemManagementPageState();
}

class _SectionItemManagementPageState
    extends ConsumerState<SectionItemManagementPage> {
  List<String> _selectedDesignIds = [];
  bool _hasChanges = false;
  bool _isSaving = false;
  bool _allowDiscardPop = false;

  @override
  void initState() {
    super.initState();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final id = _selectedDesignIds.removeAt(oldIndex);
      _selectedDesignIds.insert(newIndex, id);
      _hasChanges = true;
    });
  }

  void _removeItem(String designId) {
    setState(() {
      _selectedDesignIds.remove(designId);
      _hasChanges = true;
    });
  }

  Future<void> _openDesignPicker() async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => SectionDesignPickerPage(
          section: widget.section,
          currentlySelectedDesignIds: _selectedDesignIds,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDesignIds = result;
        _hasChanges = true;
      });
    }
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
          'Item order and selection changes will be lost.',
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
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await ref
        .read(sectionRepositoryProvider)
        .saveSectionItems(widget.section.id, _selectedDesignIds);

    if (!mounted) return;
    setState(() => _isSaving = false);
    AppToast.show(
      context,
      'Section items updated successfully.',
      type: ToastType.success,
    );
    context.popOrGoWithResult(true, AppRoutes.adminSectionList);
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
          context.popOrGo(AppRoutes.adminSectionList);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Items: ${widget.section.title}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
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
                context.popOrGo(AppRoutes.adminSectionList);
                return;
              }
              final canLeave = await _onWillPop();
              if (canLeave && context.mounted) {
                setState(() => _allowDiscardPop = true);
                context.popOrGo(AppRoutes.adminSectionList);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
              ),
              tooltip: 'Add Designs',
              onPressed: _openDesignPicker,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Drag handles to reorder designs in this section.',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Designs'),
                      onPressed: _openDesignPicker,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedDesignIds.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.playlist_add_rounded,
                                color: AppColors.textMuted,
                                size: 48,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Text(
                                'No designs have been added to this section.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppButton(
                                text: 'Add Designs',
                                onPressed: _openDesignPicker,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _selectedDesignIds.length,
                        onReorder: _onReorder,
                        proxyDecorator: (child, _, _) =>
                            Material(color: Colors.transparent, child: child),
                        itemBuilder: (context, index) {
                          final dId = _selectedDesignIds[index];
                          final designs =
                              ref.watch(designListProvider).valueOrNull ?? [];
                          final design = designs
                              .where((d) => d.id == dId)
                              .firstOrNull;
                          return Container(
                            key: ValueKey(dId),
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
                                design?.name ?? 'Design $dId',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Pos #${index + 1}',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                onPressed: () => _removeItem(dId),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _isSaving
                    ? const Center(child: AppLoadingIndicator(size: 32))
                    : Row(
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
                              text: 'Save Items',
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
