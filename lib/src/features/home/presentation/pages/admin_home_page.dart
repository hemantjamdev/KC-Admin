import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../category/data/repositories/category_firestore_repository.dart';
import '../../../customer/data/repositories/customer_repository_impl.dart';
import '../../../design/data/repositories/design_firestore_repository.dart';
import '../../../stitching/data/repositories/stitching_order_firestore_repository.dart';

/// Operational Boutique Workspace Home Page for KC-Admin.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final DesignFirestoreRepository _designRepo = DesignFirestoreRepository();
  final CategoryFirestoreRepository _categoryRepo = CategoryFirestoreRepository();
  final CustomerRepositoryImpl _customerRepo = CustomerRepositoryImpl();
  final StitchingOrderFirestoreRepository _stitchingRepo = StitchingOrderFirestoreRepository();

  int _designCount = 0;
  int _categoryCount = 0;
  int _customerCount = 0;
  int _orderCount = 0;
  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final controller = BoutiqueSelectionScope.of(context);
    final boutiqueId = controller.selectedBoutique?.id ?? '';
    if (boutiqueId.isEmpty) return;

    try {
      final designs = await _designRepo.watchDesigns(boutiqueId).first;
      final categories = await _categoryRepo.watchCategories(boutiqueId).first;
      final customers = await _customerRepo.getCustomersForAdmin(boutiqueId: boutiqueId);
      final orders = await _stitchingRepo.watchAdminOrders(boutiqueId, null).first;

      if (mounted) {
        setState(() {
          _designCount = designs.length;
          _categoryCount = categories.length;
          _customerCount = customers.length;
          _orderCount = orders.length;
          _isLoadingCounts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCounts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = BoutiqueSelectionScope.of(context);
    final boutique = controller.selectedBoutique;
    final branch = controller.selectedBranch;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.brandGreen900,
        foregroundColor: AppColors.surfaceWhite,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Boutique Workspace',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.surfaceWhite),
            ),
            if (boutique != null)
              Text(
                '${boutique.name}${branch != null ? " • ${branch.name}" : ""}',
                style: const TextStyle(fontSize: 12, color: AppColors.brandGreen100),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.surfaceWhite),
            tooltip: 'Refresh Metrics',
            onPressed: _loadMetrics,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.surfaceWhite),
            tooltip: 'Logout',
            onPressed: () {
              controller.clearAll();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Context Banner
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: const BoxDecoration(
                            color: AppColors.brandGreen50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: AppColors.brandGreen800,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                boutique?.name ?? 'No Boutique Selected',
                                style: AppTypography.cardTitle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                branch?.name ?? 'All Branches Context',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            controller.clearAll();
                            context.go(AppRoutes.adminSelectBoutique);
                          },
                          child: const Text('Switch'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Quick Action Bar
                  const Text('QUICK ACTIONS', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: boutique == null
                              ? null
                              : () => context.push(AppRoutes.adminDesignAdd),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Design'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: boutique == null
                              ? null
                              : () => context.push(AppRoutes.adminNotificationAdd),
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Publish Alert'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Operational Summary Metrics
                  const Text('OPERATIONAL METRICS', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.6,
                    children: [
                      _MetricCard(
                        title: 'Active Designs',
                        count: _isLoadingCounts ? '...' : '$_designCount',
                        icon: Icons.style_rounded,
                        color: AppColors.brandGreen800,
                        onTap: () => context.go(AppRoutes.adminDesignList),
                      ),
                      _MetricCard(
                        title: 'Categories',
                        count: _isLoadingCounts ? '...' : '$_categoryCount',
                        icon: Icons.category_rounded,
                        color: AppColors.brandGreen700,
                        onTap: () => context.go(AppRoutes.adminCategoryList),
                      ),
                      _MetricCard(
                        title: 'Customers',
                        count: _isLoadingCounts ? '...' : '$_customerCount',
                        icon: Icons.people_alt_rounded,
                        color: AppColors.brandGreen600,
                        onTap: () => context.go(AppRoutes.adminCustomerList),
                      ),
                      _MetricCard(
                        title: 'Stitching Orders',
                        count: _isLoadingCounts ? '...' : '$_orderCount',
                        icon: Icons.content_cut_rounded,
                        color: AppColors.warning,
                        onTap: () => context.go(AppRoutes.adminStitchingOrderList),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Management Modules List
                  const Text('MANAGEMENT MODULES', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.sm),

                  _ModuleTile(
                    icon: Icons.view_day_rounded,
                    title: 'Curated Home Sections',
                    subtitle: 'Manage home discovery rails and design collections',
                    onTap: boutique == null ? null : () => context.go(AppRoutes.adminSectionList),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ModuleTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications & Broadcasts',
                    subtitle: 'Create, schedule, and view published announcements',
                    onTap: boutique == null ? null : () => context.go(AppRoutes.adminNotificationList),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 22, color: color),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.mutedText),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: AppTypography.pageTitle.copyWith(color: AppColors.charcoal),
                ),
                Text(title, style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.brandGreen50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.brandGreen800, size: 20),
        ),
        title: Text(title, style: AppTypography.cardTitle),
        subtitle: Text(subtitle, style: AppTypography.caption),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
      ),
    );
  }
}
