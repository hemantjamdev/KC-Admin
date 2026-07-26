import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/repositories/branch_firestore_repository.dart';
import '../../domain/models/branch_model.dart';
import '../controllers/boutique_selection_controller.dart';

/// Admin Branch Selection Page for Slice 2.
class AdminBranchSelectionPage extends StatefulWidget {
  const AdminBranchSelectionPage({super.key});

  @override
  State<AdminBranchSelectionPage> createState() =>
      _AdminBranchSelectionPageState();
}

class _AdminBranchSelectionPageState extends State<AdminBranchSelectionPage> {
  final _branchRepository = BranchFirestoreRepository();
  bool _isLoading = true;
  List<BranchModel> _activeBranches = [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    if (!mounted) return;

    final controller = BoutiqueSelectionScope.of(context);
    final selectedBoutique = controller.selectedBoutique;

    if (selectedBoutique != null) {
      final branches = await _branchRepository.getBranchesForBoutique(
        selectedBoutique.id,
      );
      _activeBranches = branches.where((b) => b.isActive).toList();
    } else {
      _activeBranches = [];
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = BoutiqueSelectionScope.of(context);
    final selectedBoutique = controller.selectedBoutique;
    final selectedBranch = controller.selectedBranch;

    // Safety fallback if no boutique is selected in state
    if (selectedBoutique == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Select Branch')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No boutique selected.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Select Boutique',
                isFullWidth: false,
                onPressed: () => context.go(AppRoutes.adminSelectBoutique),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Select Branch',
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
          onPressed: () => context.go(AppRoutes.adminSelectBoutique),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLoadingIndicator(size: 32),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Loading branches...',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected Boutique Banner
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  AppSpacing.xs + 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.accentGlow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.store_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SELECTED BOUTIQUE',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      selectedBoutique.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.adminSelectBoutique),
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Empty State if no active branches exist
                        if (_activeBranches.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderLg,
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.location_off_rounded,
                                  color: AppColors.textMuted,
                                  size: 40,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Text(
                                  'No active branches are available for this boutique.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AppButton(
                                  text: 'Choose another boutique',
                                  variant: AppButtonVariant.secondary,
                                  onPressed: () =>
                                      context.go(AppRoutes.adminSelectBoutique),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _activeBranches.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final branch = _activeBranches[index];
                              final isSelected =
                                  selectedBranch?.id == branch.id;

                              return _BranchCard(
                                branch: branch,
                                isSelected: isSelected,
                                onTap: () => controller.selectBranch(branch),
                              );
                            },
                          ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Continue Button
                        if (_activeBranches.isNotEmpty)
                          AppButton(
                            text: 'Enter Admin Dashboard',
                            icon: Icons.check_circle_outline_rounded,
                            onPressed: selectedBranch == null
                                ? null
                                : () => context.go(AppRoutes.adminHome),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.isSelected,
    required this.onTap,
  });

  final BranchModel branch;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceLight : AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderLg,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceBorder,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: isSelected
                        ? AppColors.background
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs - 2),
                      Text(
                        '${branch.address}, ${branch.city}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
