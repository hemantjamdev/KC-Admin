import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/notification_providers.dart';

/// Clean Admin Notification Details Page — displays notification details,
/// and shows a Publish button if the status is Draft.
class AdminNotificationDetailsPage extends ConsumerStatefulWidget {
  const AdminNotificationDetailsPage({super.key, required this.notification});
  final NotificationModel notification;

  @override
  ConsumerState<AdminNotificationDetailsPage> createState() =>
      _AdminNotificationDetailsPageState();
}

class _AdminNotificationDetailsPageState
    extends ConsumerState<AdminNotificationDetailsPage> {
  late NotificationModel _notification;

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  Future<void> _publishNow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Publish Notification?',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Publish "${_notification.title}" into the customer app immediately?',
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
              'Publish',
              style: GoogleFonts.montserrat(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(adminNotificationMutationProvider.notifier)
          .publish(_notification.id);
      if (!mounted) return;
      AppToast.show(
        context,
        'Notification "${_notification.title}" published!',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDraft = _notification.status == NotificationStatus.draft;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Notification Details',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.popOrGo(AppRoutes.adminNotificationList),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _notification.title,
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _statusBadge(_notification.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _notification.body,
                      style: GoogleFonts.montserrat(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Details Information Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DETAILS',
                      style: GoogleFonts.montserrat(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _infoRow('Type', _notification.type.label),
                    _infoRow(
                      'Target Audience',
                      _notification.audienceType.label,
                    ),
                    _infoRow(
                      'Created At',
                      _formatDate(_notification.createdAt),
                    ),
                    if (_notification.publishedAt != null)
                      _infoRow(
                        'Published At',
                        _formatDate(_notification.publishedAt),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Publish Button if Draft
              if (isDraft)
                AppButton(
                  text: 'Publish Notification',
                  icon: PhosphorIcons.paperPlaneRight(),
                  onPressed: _publishNow,
                ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                color: AppColors.textMuted,
                fontSize: 12,
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

  Widget _statusBadge(NotificationStatus status) {
    final isPublished = status == NotificationStatus.published;
    final color = isPublished
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE65100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.montserrat(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
