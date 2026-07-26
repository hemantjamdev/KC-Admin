import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../customer/data/repositories/customer_repository_impl.dart';
import '../../../customer/domain/models/customer_model.dart';
import '../../domain/models/stitching_order_model.dart';
import '../controllers/stitching_order_controller.dart';
import '../widgets/order_status_update_sheet.dart';

/// Admin Stitching Order List page.
class AdminStitchingOrderListPage extends StatefulWidget {
  const AdminStitchingOrderListPage({super.key});

  @override
  State<AdminStitchingOrderListPage> createState() =>
      _AdminStitchingOrderListPageState();
}

class _AdminStitchingOrderListPageState
    extends State<AdminStitchingOrderListPage> {
  late StitchingOrderController _controller;
  final TextEditingController _searchController = TextEditingController();
  final CustomerRepositoryImpl _customerRepo = CustomerRepositoryImpl();

  Map<String, CustomerModel> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _loadCustomersCache();
  }

  Future<void> _loadCustomersCache() async {
    try {
      final customers = await _customerRepo.getCustomersForAdmin();
      if (!mounted) return;
      setState(() {
        _customerCache = {for (var c in customers) c.id: c};
      });
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    final branchId = scope.selectedBranch?.id;

    _controller = StitchingOrderController(
      boutiqueId: boutiqueId,
      branchId: branchId,
    );
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openStatusSheet(StitchingOrderModel order) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderStatusUpdateSheet(
        order: order,
        controller: _controller,
        updatedBy: 'admin',
      ),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated for ${order.orderNumber}.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(StitchingOrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Delete Order?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Delete order "${order.orderNumber}"?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.orderNumber} deleted.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = BoutiqueSelectionScope.of(context);
    final boutique = scope.selectedBoutique;
    final branch = scope.selectedBranch;
    final orders = _controller.visibleOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Stitching Orders',
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
          onPressed: () => context.go(AppRoutes.adminHome),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.go(AppRoutes.adminStitchingOrderAdd),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          boutique?.name ?? '—',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (branch != null)
                        Text(
                          branch.name,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '${orders.length} orders',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Search Input
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Search by order number or design name…',
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _controller.searchOrders('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.borderMd,
                        borderSide: BorderSide(color: AppColors.surfaceBorder),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppRadius.borderMd,
                        borderSide: BorderSide(color: AppColors.surfaceBorder),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: AppRadius.borderMd,
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (q) => _controller.searchOrders(q),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _statusFilterChip(null, 'All Statuses'),
                        const SizedBox(width: AppSpacing.xs),
                        ...StitchingOrderStatus.values.map(
                          (status) => Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.xs,
                            ),
                            child: _statusFilterChip(status, status.adminLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: AppLoadingIndicator(size: 32))
                  : orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xxl + AppSpacing.xl,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final order = orders[i];
                        final customer = _customerCache[order.customerId];
                        final customerName =
                            customer?.displayName ??
                            'Customer #${order.customerId.substring(0, order.customerId.length.clamp(0, 6))}';

                        return _OrderCard(
                          order: order,
                          customerName: customerName,
                          onTapDetails: () => context.go(
                            AppRoutes.adminStitchingOrderDetails,
                            extra: order,
                          ),
                          onEdit: () => context.go(
                            AppRoutes.adminStitchingOrderEdit,
                            extra: order,
                          ),
                          onChangeStatus: () => _openStatusSheet(order),
                          onDelete: () => _confirmDelete(order),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusFilterChip(StitchingOrderStatus? status, String label) {
    final selected = _controller.selectedStatusFilter == status;
    return GestureDetector(
      onTap: () => _controller.filterByStatus(status),
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

  Widget _buildEmptyState() {
    final hasFilter =
        _searchController.text.isNotEmpty ||
        _controller.selectedStatusFilter != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter
                  ? Icons.search_off_rounded
                  : Icons.content_paste_off_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilter
                  ? 'No stitching orders match the selected filters.'
                  : 'No stitching orders are available for this branch.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.customerName,
    required this.onTapDetails,
    required this.onEdit,
    required this.onChangeStatus,
    required this.onDelete,
  });

  final StitchingOrderModel order;
  final String customerName;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onChangeStatus;
  final VoidCallback onDelete;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Not set';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryDesign = order.designReferences.isNotEmpty
        ? order.designReferences.first.designName
        : 'No design attached';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ListTile(
        onTap: onTapDetails,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                order.orderNumber,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _StatusBadge(status: order.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              customerName,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$primaryDesign${order.designReferences.length > 1 ? ' (+${order.designReferences.length - 1} more)' : ''}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  color: AppColors.textHint,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ready: ${_formatDate(order.expectedReadyAt)}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.surfaceLight,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'View Details',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  Icon(
                    Icons.published_with_changes_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Change Status',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Edit Order',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Delete Order',
                    style: TextStyle(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (val) {
            switch (val) {
              case 'details':
                onTapDetails();
              case 'status':
                onChangeStatus();
              case 'edit':
                onEdit();
              case 'delete':
                onDelete();
            }
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final StitchingOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      StitchingOrderStatus.received => AppColors.textMuted,
      StitchingOrderStatus.measurements => AppColors.primary,
      StitchingOrderStatus.cutting => AppColors.warning,
      StitchingOrderStatus.stitching => AppColors.warning,
      StitchingOrderStatus.qualityCheck => AppColors.primaryLight,
      StitchingOrderStatus.ready => AppColors.success,
      StitchingOrderStatus.completed => AppColors.success,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        status.adminLabel,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
