import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/admin_app_bar.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/stitch_divider.dart';
import '../../../customer/data/repositories/customer_repository_impl.dart';
import '../../../customer/domain/models/customer_model.dart';
import '../../application/providers/stitching_providers.dart';
import '../../domain/models/stitching_order_model.dart';
import 'admin_stitching_order_details_page.dart';

/// Admin Stitching Order List page — executive sliver dashboard layout with sticky pinned search/filter.
class AdminStitchingOrderListPage extends ConsumerStatefulWidget {
  const AdminStitchingOrderListPage({super.key});

  @override
  ConsumerState<AdminStitchingOrderListPage> createState() =>
      _AdminStitchingOrderListPageState();
}

class _AdminStitchingOrderListPageState
    extends ConsumerState<AdminStitchingOrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CustomerRepositoryImpl _customerRepo = CustomerRepositoryImpl();

  Map<String, CustomerModel> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _loadCustomersCache();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedStitchingOrdersProvider.notifier).fetchNextPage();
    }
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
  Widget build(BuildContext context) {
    final paginatedState = ref.watch(paginatedStitchingOrdersProvider);
    final countsAsync = ref.watch(stitchingStatusCountsProvider);
    final filter = ref.watch(orderFilterProvider);
    final orders = paginatedState.items;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AdminAppBar(
          title: 'Stitching Requests',
          onBackTap: () => context.popOrGo(AppRoutes.adminHome),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 4,
          icon: PhosphorIcon(PhosphorIcons.userPlus(), size: 20),
          label: Text(
            'Create Request',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          onPressed: () => context.push(AppRoutes.adminStitchingOrderAdd),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(stitchingStatusCountsProvider);
              await ref
                  .read(paginatedStitchingOrdersProvider.notifier)
                  .refresh();
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // 1. Executive Stitching Summary Card (Scrollable)
                countsAsync.when(
                  data: (counts) => SliverToBoxAdapter(
                    child: _buildKpiHeaderFromCounts(counts),
                  ),
                  loading: () =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                  error: (err, stack) =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),

                // 2. Sticky Pinned Search Bar & Filter Chips Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverHeaderDelegate(
                    height: 104,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            style: GoogleFonts.montserrat(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            cursorColor: AppColors.primary,
                            decoration: InputDecoration(
                              hintText:
                                  'Search by order #, customer or garment…',
                              hintStyle: GoogleFonts.montserrat(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                              prefixIcon: PhosphorIcon(
                                PhosphorIcons.magnifyingGlass(),
                                color: AppColors.textMuted,
                                size: 16,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: PhosphorIcon(
                                        PhosphorIcons.x(),
                                        color: AppColors.textMuted,
                                        size: 14,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref
                                            .read(orderFilterProvider.notifier)
                                            .search('');
                                        ref
                                            .read(
                                              paginatedStitchingOrdersProvider
                                                  .notifier,
                                            )
                                            .fetchInitial(
                                              status: filter.statusFilter,
                                              query: '',
                                            );
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.surfaceBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.surfaceBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (q) {
                              ref.read(orderFilterProvider.notifier).search(q);
                              ref
                                  .read(
                                    paginatedStitchingOrdersProvider.notifier,
                                  )
                                  .fetchInitial(
                                    status: filter.statusFilter,
                                    query: q,
                                  );
                            },
                          ),
                          const SizedBox(height: 8),
                          // Status Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _statusFilterChip(null, 'All Requests', filter),
                                const SizedBox(width: 6),
                                _statusFilterChip(
                                  StitchingOrderStatus.requested,
                                  'Requested',
                                  filter,
                                ),
                                const SizedBox(width: 6),
                                _statusFilterChip(
                                  StitchingOrderStatus.accepted,
                                  'Accepted',
                                  filter,
                                ),
                                const SizedBox(width: 6),
                                _statusFilterChip(
                                  StitchingOrderStatus.completed,
                                  'Completed',
                                  filter,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Orders List (SliverList with Infinite Scroll Loader)
                if (paginatedState.isLoading && paginatedState.items.isEmpty)
                  const SliverToBoxAdapter(
                    child: AppLoadingState(type: AppLoadingType.list),
                  )
                else if (paginatedState.errorMessage != null &&
                    paginatedState.items.isEmpty)
                  SliverToBoxAdapter(
                    child: AppErrorState(
                      message: 'Failed to load stitching orders.',
                      onRetry: () => ref
                          .read(paginatedStitchingOrdersProvider.notifier)
                          .refresh(),
                    ),
                  )
                else if (orders.isEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: _buildEmptyState(filter),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 88),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == orders.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }

                          final order = orders[index];
                          final customer = _customerCache[order.customerId];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OrderCardTile(
                              order: order,
                              customer: customer,
                              onTapDetails: () =>
                                  AdminStitchingOrderDetailsPage.showAsBottomSheet(
                                context,
                                order: order,
                              ),
                            ),
                          );
                        },
                        childCount: orders.length +
                            (paginatedState.isLoadingMore ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

String _formatCompactNumber(int number) {
  if (number < 1000) return '$number';
  if (number < 1000000) {
    final double k = number / 1000.0;
    return k % 1 == 0 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
  }
  final double m = number / 1000000.0;
  return m % 1 == 0 ? '${m.toInt()}m' : '${m.toStringAsFixed(1)}m';
}

  Widget _buildKpiHeaderFromCounts(
    ({int total, int requested, int accepted, int completed}) counts,
  ) {
    return _buildSummaryHeader(
      total: counts.total,
      requested: counts.requested,
      accepted: counts.accepted,
      completed: counts.completed,
    );
  }

  Widget _buildSummaryHeader({
    required int total,
    required int requested,
    required int accepted,
    required int completed,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD54F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'STITCHING SUMMARY',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFFFD54F),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _selectStatusFilter(null),
                child: Text(
                  '${_formatCompactNumber(total)} Total',
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _selectStatusFilter(null),
            child: Text(
              '${_formatCompactNumber(total)} Active Requests',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Clean 3-Metric Row (Interactive Taps)
          Row(
            children: [
              Expanded(
                child: _kpiStatColumn(
                  'Requested',
                  _formatCompactNumber(requested),
                  () => _selectStatusFilter(StitchingOrderStatus.requested),
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _kpiStatColumn(
                  'Accepted',
                  _formatCompactNumber(accepted),
                  () => _selectStatusFilter(StitchingOrderStatus.accepted),
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _kpiStatColumn(
                  'Completed',
                  _formatCompactNumber(completed),
                  () => _selectStatusFilter(StitchingOrderStatus.completed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectStatusFilter(StitchingOrderStatus? status) {
    ref.read(orderFilterProvider.notifier).filterByStatus(status);
    ref.read(paginatedStitchingOrdersProvider.notifier).fetchInitial(
      status: status,
      query: _searchController.text,
    );
  }

  Widget _kpiStatColumn(String label, String count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusFilterChip(
    StitchingOrderStatus? status,
    String label,
    OrderFilterState filter,
  ) {
    final selected = filter.statusFilter == status;
    return GestureDetector(
      onTap: () => _selectStatusFilter(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: selected ? AppColors.background : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(OrderFilterState filter) {
    final hasFilter =
        _searchController.text.isNotEmpty || filter.statusFilter != null;

    return AppEmptyState(
      icon: hasFilter
          ? PhosphorIcons.magnifyingGlass()
          : PhosphorIcons.scissors(),
      title: hasFilter ? 'No Matching Requests' : 'No Stitching Requests Yet',
      message: hasFilter
          ? 'No stitching requests match your search or selected status.'
          : 'Customer stitching requests submitted in the app will appear here.',
    );
  }
}

// ── Pinned Header Delegate for Search Bar & Filters ──────────────────────────

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

// ── Stitching Request Card Tile ────────────────────────────────────────────────

class _OrderCardTile extends StatelessWidget {
  const _OrderCardTile({
    required this.order,
    this.customer,
    required this.onTapDetails,
  });

  final StitchingOrderModel order;
  final CustomerModel? customer;
  final VoidCallback onTapDetails;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('d MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = order.status == StitchingOrderStatus.completed;
    final isAccepted = order.status == StitchingOrderStatus.accepted;

    final statusColor = isCompleted
        ? const Color(0xFF2E7D32)
        : isAccepted
            ? const Color(0xFF1565C0)
            : const Color(0xFFE65100);

    final statusLabel = order.status.adminLabel;

    final garmentTitle = order.displayRequestName;
    final categoryName = order.displayCategoryName;

    // Resolve Customer Name, Phone, and Email
    final rawName = customer?.displayName;
    final customerName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : (order.customerName != null && order.customerName!.isNotEmpty
            ? order.customerName!
            : 'Customer #${order.customerId.substring(0, order.customerId.length.clamp(0, 6))}');

    final customerPhone = (customer?.phone != null && customer!.phone!.isNotEmpty)
        ? customer!.phone!
        : (order.customerPhone != null && order.customerPhone!.isNotEmpty
            ? order.customerPhone!
            : null);

    final customerEmail = (customer?.email != null && customer!.email!.isNotEmpty)
        ? customer!.email!
        : (order.customerEmail != null && order.customerEmail!.isNotEmpty
            ? order.customerEmail!
            : null);

    final firstChar =
        customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C';

    return GestureDetector(
      onTap: onTapDetails,
      child: DashedStitchContainer(
        borderColor: statusColor.withValues(alpha: 0.45),
        minThickness: 0.8,
        maxThickness: 1.4,
        dashWidth: 6.5,
        dashGap: 4.0,
        inset: 4.5,
        borderRadius: 18.0,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP SECTION: Customer Avatar + Name + Garment + Date ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  backgroundImage: (customer?.photoUrl != null &&
                          customer!.photoUrl!.isNotEmpty)
                      ? NetworkImage(customer!.photoUrl!)
                      : null,
                  child: (customer?.photoUrl == null ||
                          customer!.photoUrl!.isEmpty)
                      ? Text(
                          firstChar,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              garmentTitle,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              categoryName,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── MIDDLE SECTION: Contact Info + Pickup Date Priority ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.phone(PhosphorIconsStyle.fill),
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            customerPhone ?? 'No phone provided',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: customerPhone != null
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.envelopeSimple(
                              PhosphorIconsStyle.fill,
                            ),
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customerEmail ?? 'No email provided',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: customerEmail != null
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (order.expectedReadyAt != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'PICKUP DATE',
                          style: GoogleFonts.montserrat(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: AppColors.warning,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          DateFormat('d MMM').format(order.expectedReadyAt!),
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // ── BOTTOM SECTION: Order Number Badge + Status Indicator Chip ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    '#${order.orderNumber}',
                    style: GoogleFonts.montserrat(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
