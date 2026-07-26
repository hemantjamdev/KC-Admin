import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../../customer/data/repositories/customer_repository_impl.dart';
import '../../../customer/domain/models/customer_model.dart';

import '../../domain/models/stitching_order_model.dart';
import '../controllers/stitching_order_controller.dart';
import '../widgets/order_status_update_sheet.dart';
import '../widgets/stitching_order_timeline.dart';

/// Admin Stitching Order Details Page — shows complete order information, design references, measurements, notes, and timeline.
class AdminStitchingOrderDetailsPage extends StatefulWidget {
  const AdminStitchingOrderDetailsPage({super.key, required this.order});
  final StitchingOrderModel order;

  @override
  State<AdminStitchingOrderDetailsPage> createState() =>
      _AdminStitchingOrderDetailsPageState();
}

class _AdminStitchingOrderDetailsPageState
    extends State<AdminStitchingOrderDetailsPage> {
  late StitchingOrderModel _order;
  late StitchingOrderController _controller;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    _controller = StitchingOrderController(
      boutiqueId: scope.selectedBoutique?.id ?? 'boutique_01',
      branchId: scope.selectedBranch?.id,
    );
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    final fresh = _controller.getOrderById(_order.id);
    if (fresh != null && mounted) {
      setState(() => _order = fresh);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openStatusSheet() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderStatusUpdateSheet(
        order: _order,
        controller: _controller,
        updatedBy: 'admin',
      ),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated for ${_order.orderNumber}.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Not set';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final history = _controller.getHistoryForOrder(_order.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _order.orderNumber,
          style: const TextStyle(
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
          onPressed: () => context.go(AppRoutes.adminStitchingOrderList),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
            tooltip: 'Edit Order',
            onPressed: () =>
                context.go(AppRoutes.adminStitchingOrderEdit, extra: _order),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
            ),
            icon: const Icon(Icons.published_with_changes_rounded),
            label: const Text(
              'Change Order Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _openStatusSheet,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Header Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CURRENT STATUS',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _order.status.adminLabel,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'EXPECTED READY',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(_order.expectedReadyAt),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Customer Details
                  _infoCard('Customer Details', [
                    _infoRow('Name', _customer?.displayName ?? 'Loading...'),
                    _infoRow('Email', _customer?.email ?? 'N/A'),
                    _infoRow('Phone', _customer?.phone ?? 'N/A'),
                  ]),

                  const SizedBox(height: AppSpacing.md),

                  // Design References
                  _infoCard(
                    'Design References (${_order.designReferences.length})',
                    _order.designReferences.map((d) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                '${d.designName} (Qty: ${d.quantity})',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Measurements
                  if (_order.measurementSummary != null &&
                      !_order.measurementSummary!.isEmpty) ...[
                    _infoCard('Body & Garment Measurements', [
                      _infoRow('Unit', _order.measurementSummary!.unit),
                      if (_order.measurementSummary!.chest != null)
                        _infoRow(
                          'Chest',
                          '${_order.measurementSummary!.chest} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.waist != null)
                        _infoRow(
                          'Waist',
                          '${_order.measurementSummary!.waist} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.hip != null)
                        _infoRow(
                          'Hip',
                          '${_order.measurementSummary!.hip} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.shoulder != null)
                        _infoRow(
                          'Shoulder',
                          '${_order.measurementSummary!.shoulder} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.sleeveLength != null)
                        _infoRow(
                          'Sleeve',
                          '${_order.measurementSummary!.sleeveLength} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.garmentLength != null)
                        _infoRow(
                          'Garment Length',
                          '${_order.measurementSummary!.garmentLength} ${_order.measurementSummary!.unit}',
                        ),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Notes
                  if (_order.notes != null && _order.notes!.isNotEmpty) ...[
                    _infoCard('Notes', [
                      Text(
                        _order.notes!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Timeline Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timeline History',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
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
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
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
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
