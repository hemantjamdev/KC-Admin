import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../domain/models/notification_model.dart';
import '../controllers/notification_controller.dart';

/// Admin Notification Details Page — audit metadata and lifecycle management actions.
class AdminNotificationDetailsPage extends StatefulWidget {
  const AdminNotificationDetailsPage({super.key, required this.notification});
  final NotificationModel notification;

  @override
  State<AdminNotificationDetailsPage> createState() =>
      _AdminNotificationDetailsPageState();
}

class _AdminNotificationDetailsPageState
    extends State<AdminNotificationDetailsPage> {
  late NotificationModel _notification;
  late NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    _controller = NotificationController(
      boutiqueId: scope.selectedBoutique?.id ?? 'boutique_01',
      branchId: scope.selectedBranch?.id,
    );
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    final fresh = _controller.getNotificationById(_notification.id);
    if (fresh != null && mounted) {
      setState(() => _notification = fresh);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _publishNow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Publish Notification?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Publish "${_notification.title}" into the customer app immediately?',
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
              'Publish',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _controller.publishNotification(_notification.id, 'admin');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification published to customer app.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cancelSchedule() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Cancel Scheduled Notification?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This scheduled notification will be cancelled and will not publish to customers.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Keep Scheduled',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Cancel Schedule',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _controller.cancelScheduledNotification(_notification.id, 'admin');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scheduled notification cancelled.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _archive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Archive Notification?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Archiving removes this notification from active customer lists while retaining audit records.',
          style: TextStyle(color: AppColors.textMuted),
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
              'Archive',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _controller.archiveNotification(_notification.id, 'admin');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification archived.'),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notification Details',
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
          onPressed: () => context.go(AppRoutes.adminNotificationList),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview_rounded, color: AppColors.primary),
            tooltip: 'Preview In-App',
            onPressed: () => context.push(
              AppRoutes.adminNotificationPreview,
              extra: _notification,
            ),
          ),
          if (_notification.status == NotificationStatus.draft)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              tooltip: 'Edit Draft',
              onPressed: () => context.go(
                AppRoutes.adminNotificationEdit,
                extra: _notification,
              ),
            ),
        ],
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
                  // Title & Status Header Card
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _notification.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _statusBadge(_notification.status),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _notification.body,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Metadata Card
                  _infoCard('Audience & Scope', [
                    _infoRow('Type', _notification.type.label),
                    _infoRow(
                      'Target Audience',
                      _notification.audienceType.label,
                    ),
                    _infoRow('Boutique', boutique?.name ?? 'Main Boutique'),
                    if (_notification.branchId != null)
                      _infoRow('Branch ID', _notification.branchId!),
                    if (_notification.customerIds.isNotEmpty)
                      _infoRow(
                        'Target Customers',
                        '${_notification.customerIds.length} customer(s)',
                      ),
                  ]),

                  const SizedBox(height: AppSpacing.md),

                  // Destination & Timestamps
                  _infoCard('Destination & Timestamps', [
                    _infoRow(
                      'Destination Type',
                      _notification.relatedEntityType?.label ??
                          'No Destination',
                    ),
                    if (_notification.relatedEntityId != null)
                      _infoRow('Entity ID', _notification.relatedEntityId!),
                    _infoRow(
                      'Created At',
                      _formatDate(_notification.createdAt),
                    ),
                    _infoRow(
                      'Updated At',
                      _formatDate(_notification.updatedAt),
                    ),
                    if (_notification.scheduledAt != null)
                      _infoRow(
                        'Scheduled At',
                        _formatDate(_notification.scheduledAt),
                      ),
                    if (_notification.publishedAt != null)
                      _infoRow(
                        'Published At',
                        _formatDate(_notification.publishedAt),
                      ),
                    if (_notification.expiresAt != null)
                      _infoRow(
                        'Expires At',
                        _formatDate(_notification.expiresAt),
                      ),
                  ]),

                  const SizedBox(height: AppSpacing.xl),

                  // Lifecycle Action Buttons
                  if (_notification.status == NotificationStatus.draft) ...[
                    AppButton(
                      text: 'Publish Immediately',
                      icon: Icons.send_rounded,
                      onPressed: _publishNow,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      text: 'Edit Draft',
                      icon: Icons.edit_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.go(
                        AppRoutes.adminNotificationEdit,
                        extra: _notification,
                      ),
                    ),
                  ] else if (_notification.status ==
                      NotificationStatus.scheduled) ...[
                    AppButton(
                      text: 'Cancel Scheduled Notification',
                      icon: Icons.cancel_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: _cancelSchedule,
                    ),
                  ] else if (_notification.status ==
                      NotificationStatus.published) ...[
                    AppButton(
                      text: 'Archive Notification',
                      icon: Icons.archive_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: _archive,
                    ),
                  ],

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
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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

  Widget _statusBadge(NotificationStatus status) {
    final color = switch (status) {
      NotificationStatus.draft => AppColors.textMuted,
      NotificationStatus.scheduled => AppColors.warning,
      NotificationStatus.published => AppColors.success,
      NotificationStatus.cancelled => AppColors.error,
      NotificationStatus.archived => AppColors.surfaceBorder,
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
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
