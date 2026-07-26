import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../domain/models/notification_model.dart';
import '../controllers/notification_controller.dart';

/// Admin Notification List Page — manage drafts, scheduled, published, and archived notifications.
class AdminNotificationListPage extends StatefulWidget {
  const AdminNotificationListPage({super.key});

  @override
  State<AdminNotificationListPage> createState() =>
      _AdminNotificationListPageState();
}

class _AdminNotificationListPageState extends State<AdminNotificationListPage> {
  late NotificationController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    final branchId = scope.selectedBranch?.id;

    _controller = NotificationController(
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

  Future<void> _confirmDelete(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text(
          'Delete Draft?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Delete draft notification "${notification.title}"?',
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
      await _controller.deleteDraft(notification.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Draft "${notification.title}" deleted.'),
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
    final notifications = _controller.visibleNotificationsForAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
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
          'Create Notification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.go(AppRoutes.adminNotificationAdd),
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
                        '${notifications.length} items',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Search title or body text…',
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
                                _controller.searchNotifications('');
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
                    onChanged: (q) => _controller.searchNotifications(q),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Status & Type Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _statusFilterChip(null, 'All Statuses'),
                        const SizedBox(width: AppSpacing.xs),
                        ...NotificationStatus.values.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.xs,
                            ),
                            child: _statusFilterChip(s, s.label),
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
                  : notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xxl + AppSpacing.xl,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final notif = notifications[i];
                        return _NotificationCard(
                          notification: notif,
                          onTapDetails: () => context.go(
                            AppRoutes.adminNotificationDetails,
                            extra: notif,
                          ),
                          onEdit: () => context.go(
                            AppRoutes.adminNotificationEdit,
                            extra: notif,
                          ),
                          onPreview: () => context.go(
                            AppRoutes.adminNotificationPreview,
                            extra: notif,
                          ),
                          onDelete: () => _confirmDelete(notif),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusFilterChip(NotificationStatus? status, String label) {
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
                  : Icons.notifications_none_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilter
                  ? 'No notifications match the selected filters.'
                  : 'No notifications have been created for this boutique.',
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

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTapDetails,
    required this.onEdit,
    required this.onPreview,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                notification.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _StatusBadge(status: notification.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              notification.body,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _TypeBadge(type: notification.type),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${notification.audienceType.label} • ${_formatDate(notification.publishedAt ?? notification.createdAt)}',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
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
              value: 'preview',
              child: Row(
                children: [
                  Icon(
                    Icons.preview_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Preview In-App',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            if (notification.status == NotificationStatus.draft)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Edit Draft',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            if (notification.status == NotificationStatus.draft)
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
                      'Delete Draft',
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
              case 'preview':
                onPreview();
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
  final NotificationStatus status;

  @override
  Widget build(BuildContext context) {
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
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final NotificationType type;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xs + 2,
      vertical: 1,
    ),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: AppRadius.borderPill,
    ),
    child: Text(
      type.label,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
