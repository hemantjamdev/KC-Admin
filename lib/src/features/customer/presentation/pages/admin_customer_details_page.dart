import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/admin_app_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/models/customer_model.dart';
import '../../../stitching/application/providers/stitching_providers.dart';
import '../../../stitching/domain/models/stitching_order_model.dart';
import '../../../stitching/presentation/pages/admin_stitching_order_details_page.dart';
import '../../../notification/application/providers/notification_providers.dart';
import '../../../notification/domain/models/notification_model.dart';

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
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            icon: PhosphorIcon(
                              PhosphorIcons.bellRinging(),
                              size: 16,
                            ),
                            label: Text(
                              'Send Stitching Reminder',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                            onPressed: () => _showSendReminderSheet(context, customer),
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

  void _showSendReminderSheet(BuildContext context, CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CustomerReminderBottomSheet(customer: customer),
    );
  }
}

// ── Customer Reminder Bottom Sheet ──────────────────────────────────────────

class _CustomerReminderBottomSheet extends ConsumerStatefulWidget {
  const _CustomerReminderBottomSheet({required this.customer});
  final CustomerModel customer;

  @override
  ConsumerState<_CustomerReminderBottomSheet> createState() =>
      __CustomerReminderBottomSheetState();
}

class __CustomerReminderBottomSheetState
    extends ConsumerState<_CustomerReminderBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: 'Stitching Order Reminder',
    );
    _bodyController = TextEditingController(
      text:
          'Hello ${widget.customer.displayName}, this is a gentle reminder regarding your stitching request at Kapada Creation. Please check your order status in the app or contact our boutique for details.',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendReminder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: Text(
          'Send Stitching Reminder?',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Send this stitching reminder notification to ${widget.customer.displayName} now?',
          style: GoogleFonts.montserrat(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Send',
              style: GoogleFonts.montserrat(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);

    try {
      final targetUid =
          (widget.customer.firebaseUid != null &&
                  widget.customer.firebaseUid!.isNotEmpty)
              ? widget.customer.firebaseUid!
              : widget.customer.id;

      final customerIds = <String>{targetUid, widget.customer.id}.toList();

      final now = DateTime.now();
      final notification = NotificationModel(
        id: const Uuid().v4(),
        boutiqueId: 'boutique_01',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        type: NotificationType.stitchingUpdate,
        audienceType: NotificationAudienceType.selectedCustomers,
        customerIds: customerIds,
        status: NotificationStatus.published,
        publishedAt: now,
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
        updatedBy: 'admin',
      );

      await ref
          .read(adminNotificationMutationProvider.notifier)
          .create(notification);

      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(
        context,
        'Stitching reminder sent to ${widget.customer.displayName}.',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      AppToast.show(
        context,
        'Failed to send reminder: $e',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: PhosphorIcon(
                      PhosphorIcons.bellRinging(),
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send Stitching Reminder',
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'To: ${widget.customer.displayName}',
                          style: GoogleFonts.montserrat(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Notification Title *',
                style: GoogleFonts.montserrat(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.montserrat(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 14),
              Text(
                'Reminder Message *',
                style: GoogleFonts.montserrat(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bodyController,
                maxLines: 3,
                style: GoogleFonts.montserrat(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.all(14),
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Message is required'
                    : null,
              ),
              const SizedBox(height: 24),
              _isSending
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      text: 'Send Reminder Notification',
                      icon: PhosphorIcons.paperPlaneRight(),
                      onPressed: _sendReminder,
                    ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
