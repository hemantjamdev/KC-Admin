import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/admin_app_bar.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/notification_providers.dart';
import 'admin_notification_details_page.dart';

/// Clean & neat Admin Notification List Page — search, listing, and add button.
class AdminNotificationListPage extends ConsumerStatefulWidget {
  const AdminNotificationListPage({super.key});

  @override
  ConsumerState<AdminNotificationListPage> createState() =>
      _AdminNotificationListPageState();
}

class _AdminNotificationListPageState
    extends ConsumerState<AdminNotificationListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
      ref.read(paginatedNotificationsProvider.notifier).fetchNextPage();
    }
  }

  Future<void> _confirmDelete(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Notification?',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${notification.title}"?',
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
              'Delete',
              style: GoogleFonts.montserrat(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(adminNotificationMutationProvider.notifier)
          .delete(notification.id);
      if (!mounted) return;
      AppToast.show(
        context,
        'Notification "${notification.title}" deleted.',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminHome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AdminAppBar(
          title: 'Notifications',
          onBackTap: () => context.popOrGo(AppRoutes.adminHome),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 4,
          icon: PhosphorIcon(PhosphorIcons.plus(), size: 20),
          label: Text(
            'Create Notification',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          onPressed: () => context.push(AppRoutes.adminNotificationAdd),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input Field
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.montserrat(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Search notifications by title or message…',
                    hintStyle: GoogleFonts.montserrat(
                      color: AppColors.textHint,
                      fontSize: 13,
                    ),
                    prefixIcon: PhosphorIcon(
                      PhosphorIcons.magnifyingGlass(),
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: PhosphorIcon(
                              PhosphorIcons.x(),
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(paginatedNotificationsProvider.notifier)
                                  .fetchInitial(query: '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (q) => ref
                      .read(paginatedNotificationsProvider.notifier)
                      .fetchInitial(query: q),
                ),
              ),

              // Notifications List
              Expanded(
                child: Builder(
                  builder: (context) {
                    final paginatedState = ref.watch(paginatedNotificationsProvider);
                    final notifications = paginatedState.items;

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        await ref
                            .read(paginatedNotificationsProvider.notifier)
                            .refresh();
                      },
                      child: paginatedState.isLoading && notifications.isEmpty
                          ? const AppLoadingState(type: AppLoadingType.list)
                          : paginatedState.errorMessage != null && notifications.isEmpty
                          ? AppErrorState(
                              message: 'Failed to load notifications list.',
                              onRetry: () => ref
                                  .read(paginatedNotificationsProvider.notifier)
                                  .refresh(),
                            )
                          : notifications.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: _buildEmptyState(),
                                ),
                              ],
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 88),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: notifications.length +
                                  (paginatedState.isLoadingMore ? 1 : 0),
                              separatorBuilder: (ctx, i) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                if (i == notifications.length) {
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
                                final notif = notifications[i];
                                return _NotificationCard(
                                  notification: notif,
                                  onTapDetails: () =>
                                      AdminNotificationDetailsPage.showAsBottomSheet(
                                    context,
                                    notification: notif,
                                  ),
                                  onEdit: () => context.push(
                                    AppRoutes.adminNotificationEdit,
                                    extra: notif,
                                  ),
                                  onPreview: () => context.push(
                                    AppRoutes.adminNotificationPreview,
                                    extra: notif,
                                  ),
                                  onDelete: () => _confirmDelete(notif),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilter = _searchController.text.isNotEmpty;

    return AppEmptyState(
      icon: hasFilter
          ? PhosphorIcons.magnifyingGlass()
          : PhosphorIcons.bell(),
      title: hasFilter ? 'No Notifications Found' : 'No Notifications Yet',
      message: hasFilter
          ? 'No notifications match your search "$_searchQuery". Try searching with different keywords.'
          : 'Created announcements and customer notifications will appear here.',
    );
  }

  String get _searchQuery => _searchController.text;
}

// ── Notification Card ─────────────────────────────────────────────────────────

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
    return DateFormat('d MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isPublished = notification.status == NotificationStatus.published;
    final statusColor = isPublished
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE65100);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTapDetails,
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: PhosphorIcon(
              isPublished
                  ? PhosphorIcons.megaphone()
                  : PhosphorIcons.bell(),
              size: 22,
              color: statusColor,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notification.status.label,
                style: GoogleFonts.montserrat(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: GoogleFonts.montserrat(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${notification.audienceType.label} • ${_formatDate(notification.publishedAt ?? notification.createdAt)}',
                    style: GoogleFonts.montserrat(
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
          color: AppColors.surface,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          icon: PhosphorIcon(
            PhosphorIcons.dotsThreeVertical(),
            color: AppColors.textMuted,
            size: 20,
          ),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.eye(),
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'View Details',
                    style: GoogleFonts.montserrat(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'preview',
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.deviceMobile(),
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Preview In-App',
                    style: GoogleFonts.montserrat(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            if (notification.status == NotificationStatus.draft)
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.pencilSimple(),
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Edit Draft',
                      style: GoogleFonts.montserrat(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            if (notification.status == NotificationStatus.draft)
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.trash(),
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Delete Draft',
                      style: GoogleFonts.montserrat(color: AppColors.error),
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
