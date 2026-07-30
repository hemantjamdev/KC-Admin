import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/widgets/admin_app_bar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/slide_to_action_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../customer/data/repositories/customer_repository_impl.dart';
import '../../../customer/domain/models/customer_model.dart';

import '../../application/providers/stitching_providers.dart';
import '../../domain/models/stitching_order_model.dart';
import '../../domain/models/stitching_status_mutation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/stitching_order_timeline.dart';

/// Admin Stitching Order Details Page & Modal Bottom Sheet — presents order details, customer info, measurements, notes, unboxed timeline, and slide actions.
class AdminStitchingOrderDetailsPage extends ConsumerStatefulWidget {
  const AdminStitchingOrderDetailsPage({
    super.key,
    required this.order,
    this.isBottomSheet = false,
  });

  final StitchingOrderModel order;
  final bool isBottomSheet;

  /// Displays the stitching order details as a bottom sheet modal.
  static Future<void> showAsBottomSheet(
    BuildContext context, {
    required StitchingOrderModel order,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminStitchingOrderDetailsPage(
        order: order,
        isBottomSheet: true,
      ),
    );
  }

  @override
  ConsumerState<AdminStitchingOrderDetailsPage> createState() =>
      _AdminStitchingOrderDetailsPageState();
}

class _AdminStitchingOrderDetailsPageState
    extends ConsumerState<AdminStitchingOrderDetailsPage> {
  late StitchingOrderModel _order;
  final CustomerRepositoryImpl _customerRepo = CustomerRepositoryImpl();

  CustomerModel? _customer;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      final c = await _customerRepo.getCustomerById(_order.customerId);
      if (!mounted) return;
      setState(() => _customer = c);
    } catch (_) {}
  }

  Future<void> _handleStatusTransition(StitchingOrderStatus targetStatus) async {
    final success = await ref
        .read(stitchingStatusMutationProvider.notifier)
        .updateStatus(
          order: _order,
          newStatus: targetStatus,
          updatedBy: 'admin',
        );

    if (success && mounted) {
      final now = DateTime.now();
      setState(() {
        _order = _order.copyWith(
          status: targetStatus,
          completedAt: targetStatus == StitchingOrderStatus.completed ? now : _order.completedAt,
          updatedAt: now,
        );
      });

      final label = targetStatus == StitchingOrderStatus.accepted
          ? 'Order Accepted'
          : 'Order Marked Completed';

      AppToast.show(
        context,
        '$label for ${_order.orderNumber}.',
        type: ToastType.success,
      );
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  Widget _buildBottomBar() {
    final isMutating = ref
        .watch(stitchingStatusMutationProvider)
        .requests[_order.id]
        ?.status == MutationStatus.loading;

    if (_order.status == StitchingOrderStatus.completed) {
      final completedDate = _order.completedAt ?? _order.updatedAt;
      final formatted =
          '${completedDate.day} ${_monthName(completedDate.month)} ${completedDate.year} at ${completedDate.hour.toString().padLeft(2, '0')}:${completedDate.minute.toString().padLeft(2, '0')}';

      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: SafeArea(
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Completed on $formatted',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final (label, targetStatus, sliderColor, trackColor, textColor, iconColor, icon) =
        switch (_order.status) {
      StitchingOrderStatus.requested => (
          'Slide to Accept Request',
          StitchingOrderStatus.accepted,
          Colors.white,
          const Color(0xFF1B4D3E),
          Colors.white,
          const Color(0xFF1B4D3E),
          PhosphorIcons.handshake(PhosphorIconsStyle.bold),
        ),
      StitchingOrderStatus.accepted => (
          'Slide to Mark Completed',
          StitchingOrderStatus.completed,
          const Color(0xFF10B981),
          const Color(0xFF0F382C),
          Colors.white,
          Colors.white,
          PhosphorIcons.check(PhosphorIconsStyle.bold),
        ),
      StitchingOrderStatus.completed => (
          '',
          StitchingOrderStatus.completed,
          AppColors.primary,
          AppColors.surface,
          AppColors.textPrimary,
          Colors.white,
          PhosphorIcons.check(),
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        child: SlideToActionButton(
          label: label,
          sliderColor: sliderColor,
          backgroundColor: trackColor,
          textColor: textColor,
          iconColor: iconColor,
          borderColor: Colors.white.withValues(alpha: 0.15),
          icon: icon,
          isLoading: isMutating,
          onSlideComplete: () => _handleStatusTransition(targetStatus),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbHistoryAsync = ref.watch(stitchingOrderHistoryProvider(_order.id));
    final realHistory = dbHistoryAsync.valueOrNull ?? [];

    final history = realHistory.isNotEmpty
        ? realHistory
        : <StitchingOrderHistoryModel>[
            StitchingOrderHistoryModel(
              id: 'hist_init_${_order.id}',
              stitchingOrderId: _order.id,
              boutiqueId: _order.boutiqueId,
              branchId: _order.branchId,
              customerId: _order.customerId,
              status: StitchingOrderStatus.requested,
              note: 'Order request submitted',
              changedAt: _order.createdAt,
              changedBy: _order.createdBy ?? 'Customer',
            ),
            if (_order.status == StitchingOrderStatus.accepted ||
                _order.status == StitchingOrderStatus.completed)
              StitchingOrderHistoryModel(
                id: 'hist_acc_${_order.id}',
                stitchingOrderId: _order.id,
                boutiqueId: _order.boutiqueId,
                branchId: _order.branchId,
                customerId: _order.customerId,
                status: StitchingOrderStatus.accepted,
                note: 'Order accepted by Admin',
                changedAt: _order.updatedAt,
                changedBy: _order.updatedBy ?? 'Admin',
              ),
            if (_order.status == StitchingOrderStatus.completed)
              StitchingOrderHistoryModel(
                id: 'hist_comp_${_order.id}',
                stitchingOrderId: _order.id,
                boutiqueId: _order.boutiqueId,
                branchId: _order.branchId,
                customerId: _order.customerId,
                status: StitchingOrderStatus.completed,
                note: 'Stitching work completed',
                changedAt: _order.completedAt ?? _order.updatedAt,
                changedBy: _order.updatedBy ?? 'Admin',
              ),
          ];

    final mainContent = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Highlighted Pickup Date Banner (If specified)
              if (_order.expectedReadyAt != null) ...[
                _buildPickupDateTile(_order.expectedReadyAt!),
                const SizedBox(height: AppSpacing.md),
              ],

              // Request Details Card
              _sectionCard(
                title: 'Request Information',
                icon: PhosphorIcons.scissors(),
                children: [
                  _infoRow('Request Name', _order.displayRequestName),
                  _infoRow('Category', _order.displayCategoryName),
                  _infoRow('Status', _order.status.adminLabel),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Customer Details Card
              _sectionCard(
                title: 'Customer Details',
                icon: PhosphorIcons.user(),
                children: [
                  _infoRow('Name', _customer?.displayName ?? _order.customerName ?? 'Customer'),
                  _infoRow('Email', _customer?.email ?? _order.customerEmail ?? 'Not provided'),
                  _infoRow('Phone', _customer?.phone ?? _order.customerPhone ?? 'Not provided'),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Design References Card (Only rendered if attached)
              if (_order.designReferences.isNotEmpty) ...[
                _sectionCard(
                  title: 'Design References (${_order.designReferences.length})',
                  icon: PhosphorIcons.tShirt(),
                  children: _order.designReferences.map((d) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: PhosphorIcon(
                                PhosphorIcons.scissors(),
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.designName,
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  d.isCustom ? 'Custom Design' : 'Catalogue Design',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Qty: ${d.quantity}',
                              style: GoogleFonts.montserrat(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Measurements Card
              if (_order.measurementSummary != null && !_order.measurementSummary!.isEmpty) ...[
                _sectionCard(
                  title: 'Body & Garment Measurements (${_order.measurementSummary!.unit})',
                  icon: PhosphorIcons.ruler(),
                  children: [
                    if (_order.measurementSummary!.chest != null)
                      _infoRow('Chest', '${_order.measurementSummary!.chest} ${_order.measurementSummary!.unit}'),
                    if (_order.measurementSummary!.waist != null)
                      _infoRow('Waist', '${_order.measurementSummary!.waist} ${_order.measurementSummary!.unit}'),
                    if (_order.measurementSummary!.hip != null)
                      _infoRow('Hip', '${_order.measurementSummary!.hip} ${_order.measurementSummary!.unit}'),
                    if (_order.measurementSummary!.shoulder != null)
                      _infoRow('Shoulder', '${_order.measurementSummary!.shoulder} ${_order.measurementSummary!.unit}'),
                    if (_order.measurementSummary!.sleeveLength != null)
                      _infoRow('Sleeve Length', '${_order.measurementSummary!.sleeveLength} ${_order.measurementSummary!.unit}'),
                    if (_order.measurementSummary!.garmentLength != null)
                      _infoRow('Garment Length', '${_order.measurementSummary!.garmentLength} ${_order.measurementSummary!.unit}'),
                    if (_order.measurementSummary!.inseam != null)
                      _infoRow('Inseam', '${_order.measurementSummary!.inseam} ${_order.measurementSummary!.unit}'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Notes Card
              if (_order.notes != null && _order.notes!.isNotEmpty) ...[
                _sectionCard(
                  title: 'Notes',
                  icon: PhosphorIcons.notePencil(),
                  children: [
                    Text(
                      _order.notes!,
                      style: GoogleFonts.montserrat(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Timeline History (No outer background card/container)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.clockCounterClockwise(),
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Timeline History',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    StitchingOrderTimeline(
                      history: history,
                      isCustomerView: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );

    if (widget.isBottomSheet) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Bottom sheet drag pill & modal header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Details',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _order.orderNumber,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: PhosphorIcon(
                          PhosphorIcons.x(),
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            Expanded(child: mainContent),
            // Fixed Bottom Bar
            _buildBottomBar(),
          ],
        ),
      );
    }

    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminStitchingOrderList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AdminAppBar(
          title: 'Request Details',
          subtitle: _order.orderNumber,
          onBackTap: () => context.popOrGo(AppRoutes.adminStitchingOrderList),
        ),
        bottomNavigationBar: _buildBottomBar(),
        body: SafeArea(child: mainContent),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDateTile(DateTime pickupDate) {
    final delayText = _getPickupDelayText(pickupDate);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PhosphorIcon(
              PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
              size: 24,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCHEDULED PICKUP DATE',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEE, d MMM yyyy').format(pickupDate),
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              delayText,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPickupDelayText(DateTime pickupDate) {
    final diff = pickupDate.difference(DateTime.now()).inDays + 1;
    if (diff <= 0) return 'Due Today';
    if (diff <= 3) return 'Urgent ($diff days left)';
    return '$diff days left';
  }
}
