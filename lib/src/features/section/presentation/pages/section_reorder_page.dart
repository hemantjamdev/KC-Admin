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

/// Page for drag-and-drop reordering of curated sections within KC-Admin.
class SectionReorderPage extends ConsumerStatefulWidget {
  const SectionReorderPage({super.key});

  @override
  ConsumerState<SectionReorderPage> createState() => _SectionReorderPageState();
}

class _SectionReorderPageState extends ConsumerState<SectionReorderPage> {
  List<SectionModel> _reorderableList = [];
  bool _hasChanges = false;
  bool _allowDiscardPop = false;

  @override
  void initState() {
    super.initState();
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
    await ref.read(sectionMutationProvider.notifier).reorder(_reorderableList);
    if (!mounted) return;
    AppToast.show(
      context,
      'Section order updated successfully.',
      type: ToastType.success,
    );
    context.popOrGoWithResult(true, AppRoutes.adminSectionList);
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(sectionListProvider);
    if (sectionsAsync.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Reorder Sections')),
        body: const Center(child: AppLoadingIndicator(size: 32)),
      );
    }

    if (_reorderableList.isEmpty &&
        sectionsAsync.valueOrNull != null &&
        !_hasChanges) {
      _reorderableList = List.of(sectionsAsync.valueOrNull!);
    }

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
          title: const Text(
            'Reorder Sections',
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
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Drag handles to change the display sequence of home sections.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                        proxyDecorator: (child, _, _) =>
                            Material(color: Colors.transparent, child: child),
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
