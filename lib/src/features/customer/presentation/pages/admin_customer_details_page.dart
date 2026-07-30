import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/admin_app_bar.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/models/customer_model.dart';
import '../../../stitching/application/providers/stitching_providers.dart';
import '../../../stitching/domain/models/stitching_order_model.dart';
import '../../../stitching/presentation/pages/admin_stitching_order_details_page.dart';

/// Admin Customer Details Page — shows identity, contact details, stitching requests, and system metadata.
class AdminCustomerDetailsPage extends ConsumerWidget {
  const AdminCustomerDetailsPage({super.key, required this.customer});
  final CustomerModel customer;

  String get _initials {
    final parts = customer.displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customer.displayName
        .substring(0, customer.displayName.length.clamp(1, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerKey = customer.firebaseUid ?? customer.id;
    final ordersAsync = ref.watch(customerOrderListProvider(customerKey));
    final allAdminOrders = ref.watch(adminOrderListProvider).valueOrNull ?? [];

    // Combine orders matching customer ID or Firebase UID
    final customerOrders =
        ordersAsync.valueOrNull ??
        allAdminOrders
            .where(
              (o) =>
                  o.customerId == customer.id ||
                  (customer.firebaseUid != null &&
                      o.customerId == customer.firebaseUid),
            )
            .toList();

    final activeOrdersCount = customerOrders
        .where((o) => o.status != StitchingOrderStatus.completed)
        .length;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminCustomerList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AdminAppBar(
          title: 'Customer Profile',
          onBackTap: () => context.popOrGo(AppRoutes.adminCustomerList),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 4,
          icon: PhosphorIcon(PhosphorIcons.plus(), size: 20),
          label: Text(
            'New Request',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          onPressed: () => context.push(
            AppRoutes.adminStitchingOrderAdd,
            extra: customer,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Identity Header Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.surfaceLight,
                            backgroundImage: customer.photoUrl != null
                                ? NetworkImage(customer.photoUrl!)
                                : null,
                            child: customer.photoUrl == null
                                ? Text(
                                    _initials,
                                    style: GoogleFonts.montserrat(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            customer.displayName,
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Contact Details Section
                    _infoCard('Contact Details', [
                      _infoRow(
                        'Email Address',
                        customer.email ?? 'Not provided',
                      ),
                      _infoRow(
                        'Phone Number',
                        customer.phone ?? 'Not provided',
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // ── STITCHING REQUESTS SECTION ─────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.scissors(),
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Stitching Requests (${customerOrders.length})',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Quick Summary Stats Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: AppRadius.borderMd,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statItem(
                                  'Total Orders',
                                  '${customerOrders.length}',
                                  AppColors.primary,
                                ),
                                _statItem(
                                  'In Progress',
                                  '$activeOrdersCount',
                                  AppColors.warning,
                                ),
                                _statItem(
                                  'Completed',
                                  '${customerOrders.where((o) => o.status == StitchingOrderStatus.completed).length}',
                                  AppColors.success,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Orders List
                          if (customerOrders.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Column(
                                  children: [
                                    PhosphorIcon(
                                      PhosphorIcons.tShirt(),
                                      size: 28,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'No stitching requests for this customer yet.',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: customerOrders.length,
                              separatorBuilder: (_, _) => const Divider(
                                color: AppColors.surfaceBorder,
                                height: 12,
                              ),
                              itemBuilder: (context, index) {
                                final order = customerOrders[index];
                                return InkWell(
                                  onTap: () =>
                                      AdminStitchingOrderDetailsPage.showAsBottomSheet(
                                    context,
                                    order: order,
                                  ),
                                  borderRadius: AppRadius.borderMd,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      order.displayRequestName,
                                                      style: GoogleFonts.montserrat(
                                                        color: AppColors.textPrimary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  StitchingStatusChip(
                                                    label: order.status.adminLabel,
                                                    color: stitchingStatusColor(
                                                      order.status.name,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                order.orderNumber,
                                                style: GoogleFonts.montserrat(
                                                  color: AppColors.textMuted,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PhosphorIcon(
                                          PhosphorIcons.caretRight(),
                                          color: AppColors.textMuted,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
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
