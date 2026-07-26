import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/data/repositories/category_firestore_repository.dart';
import '../../../category/domain/models/category_model.dart';
import '../../../design/presentation/controllers/design_controller.dart';
import '../../domain/models/section_model.dart';

/// Design picker page for selecting multiple eligible designs to include in a manual section.
class SectionDesignPickerPage extends StatefulWidget {
  const SectionDesignPickerPage({
    super.key,
    required this.section,
    required this.currentlySelectedDesignIds,
  });

  final SectionModel section;
  final List<String> currentlySelectedDesignIds;

  @override
  State<SectionDesignPickerPage> createState() =>
      _SectionDesignPickerPageState();
}

class _SectionDesignPickerPageState extends State<SectionDesignPickerPage> {
  final CategoryFirestoreRepository _categoryRepository = CategoryFirestoreRepository();
  late DesignController _designController;
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  final List<String> _selectedIds = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.currentlySelectedDesignIds);

    final boutiqueId =
        BoutiqueSelectionScope.of(context).selectedBoutique?.id ?? '';
    _designController = DesignController(
      boutiqueId: boutiqueId,
      activeCategoryIds: const [],
    );
    _designController.addListener(_onControllerUpdate);

    _initData(boutiqueId);
  }

  Future<void> _initData(String boutiqueId) async {
    try {
      final list = await _categoryRepository.watchCategories(boutiqueId).first;
      if (!mounted) return;
      setState(() {
        _categories = list.where((c) => c.isActive).toList();
      });
    } catch (_) {}
    if (!mounted) return;
    _designController.loadDesigns();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _designController.removeListener(_onControllerUpdate);
    _designController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _categoryChip(String? id, String label) {
    final selected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = id;
          _designController.filterByCategory(id);
        });
      },
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
    // Only show active designs
    final availableDesigns = _designController.allDesigns.where((d) {
      if (!d.isActive) return false;
      if (widget.section.branchId != null) {
        final avail = _designController.getAvailabilityForBranchDesign(
          widget.section.branchId!,
          d.id,
        );
        if (avail == null) return false;
      }
      return true;
    }).toList();

    final filtered = availableDesigns.where((d) {
      if (_selectedCategoryId != null && d.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        final inName = d.name.toLowerCase().contains(q);
        final inTags = d.tags.any((t) => t.toLowerCase().contains(q));
        if (!inName && !inTags) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Select Designs',
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
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text(
                '${_selectedIds.length} selected',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _designController.isLoading
            ? const Center(child: AppLoadingIndicator(size: 32))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search eligible designs…',
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
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
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        _categoryChip(null, 'All'),
                        ..._categories.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: _categoryChip(c.id, c.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No eligible designs found.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.xs),
                            itemBuilder: (context, i) {
                              final d = filtered[i];
                              final isSelected = _selectedIds.contains(d.id);
                              return Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : AppColors.surface,
                                  borderRadius: AppRadius.borderMd,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceBorder,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  checkColor: AppColors.background,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedIds.add(d.id);
                                      } else {
                                        _selectedIds.remove(d.id);
                                      }
                                    });
                                  },
                                  title: Text(
                                    d.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    d.slug,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  secondary: ClipRRect(
                                    borderRadius: AppRadius.borderSm,
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: d.thumbnailUrl != null
                                          ? Image.network(
                                              d.thumbnailUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: AppColors.surfaceLight,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppButton(
                      text: 'Confirm Selection (${_selectedIds.length})',
                      onPressed: () => context.pop(_selectedIds),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
