import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/repositories/boutique_firestore_repository.dart';
import '../../domain/models/boutique_model.dart';
import '../controllers/boutique_selection_controller.dart';

/// Admin Boutique Selection Page for Slice 2.
class AdminBoutiqueSelectionPage extends StatefulWidget {
  const AdminBoutiqueSelectionPage({super.key});

  @override
  State<AdminBoutiqueSelectionPage> createState() =>
      _AdminBoutiqueSelectionPageState();
}

class _AdminBoutiqueSelectionPageState
    extends State<AdminBoutiqueSelectionPage> {
  final _repository = BoutiqueFirestoreRepository();
  bool _isLoading = true;
  List<BoutiqueModel> _activeBoutiques = [];

  @override
  void initState() {
    super.initState();
    _loadBoutiques();
  }

  Future<void> _loadBoutiques() async {
    final list = await _repository.getBoutiques();
    if (!mounted) return;

    setState(() {
      _activeBoutiques = list.where((b) => b.isActive).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = BoutiqueSelectionScope.of(context);
    final selectedBoutique = controller.selectedBoutique;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Select Boutique',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
            tooltip: 'Logout',
            onPressed: () {
              controller.clearAll();
              context.go(AppRoutes.login);
            },
          ),
        ],
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
                      'Loading boutiques...',
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
                        // Header info banner
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  'Select an active boutique to view and manage its assigned operational branches.',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Boutique Cards List
                        if (_activeBoutiques.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderLg,
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.textMuted,
                                  size: 36,
                                ),
                                SizedBox(height: AppSpacing.md),
                                Text(
                                  'No active boutiques available.',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _activeBoutiques.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final boutique = _activeBoutiques[index];
                              final isSelected =
                                  selectedBoutique?.id == boutique.id;

                              return _BoutiqueCard(
                                boutique: boutique,
                                isSelected: isSelected,
                                onTap: () =>
                                    controller.selectBoutique(boutique),
                              );
                            },
                          ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Continue Button
                        AppButton(
                          text: 'Continue to Branches',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: selectedBoutique == null
                              ? null
                              : () => context.go(AppRoutes.adminSelectBranch),
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

class _BoutiqueCard extends StatelessWidget {
  const _BoutiqueCard({
    required this.boutique,
    required this.isSelected,
    required this.onTap,
  });

  final BoutiqueModel boutique;
  final bool isSelected;
  final VoidCallback onTap;

  String get _initials {
    final parts = boutique.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return boutique.name.substring(0, 2).toUpperCase();
  }

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
              children: [
                // Logo or Fallback Initials Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceBorder,
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.background
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boutique.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs - 2),
                      Text(
                        boutique.subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Selection Radio/Indicator
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
