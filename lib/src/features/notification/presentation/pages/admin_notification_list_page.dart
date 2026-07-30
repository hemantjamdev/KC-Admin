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

  NotificationStatus? _selectedStatus;

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
            'New Notification',
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
              // Search Input Field & Filter Chips
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  children: [
                    TextField(
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
                    const SizedBox(height: 10),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _filterChip(null, 'All Broadcasts'),
                          const SizedBox(width: 6),
                          _filterChip(NotificationStatus.published, 'Published'),
                          const SizedBox(width: 6),
                          _filterChip(NotificationStatus.scheduled, 'Scheduled'),
                          const SizedBox(width: 6),
                          _filterChip(NotificationStatus.draft, 'Drafts'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Notifications List
              Expanded(
                child: Builder(
                  builder: (context) {
                    final paginatedState = ref.watch(paginatedNotificationsProvider);
                    var notifications = paginatedState.items;

                    if (_selectedStatus != null) {
                      notifications = notifications
                          .where((n) => n.status == _selectedStatus)
                          .toList();
                    }

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
                                  height: MediaQuery.of(context).size.height * 0.45,
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

  Widget _filterChip(NotificationStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = status),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: GoogleFonts.montserrat(
        color: isSelected ? Colors.white : AppColors.textMuted,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
        ),
      ),
      showCheckmark: false,
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
    return DateFormat('d MMM yyyy, h:mm a').format(dt);
  }

  (IconData, Color) _getTypeTheme(NotificationType type) {
    return switch (type) {
      NotificationType.general => (
          PhosphorIcons.bell(PhosphorIconsStyle.bold),
          AppColors.primary,
        ),
      NotificationType.stitchingUpdate => (
          PhosphorIcons.scissors(PhosphorIconsStyle.bold),
          const Color(0xFF10B981),
        ),
      NotificationType.designUpdate => (
          PhosphorIcons.sparkle(PhosphorIconsStyle.bold),
          const Color(0xFF2563EB),
        ),
      NotificationType.boutiqueAnnouncement => (
          PhosphorIcons.megaphone(PhosphorIconsStyle.bold),
          const Color(0xFFD97706),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (typeIcon, typeColor) = _getTypeTheme(notification.type);
    final isPublished = notification.status == NotificationStatus.published;
    final isScheduled = notification.status == NotificationStatus.scheduled;
    final statusColor = isPublished
        ? const Color(0xFF10B981)
        : isScheduled
        ? const Color(0xFFD97706)
        : const Color(0xFF6B7280);

    return InkWell(
      onTap: onTapDetails,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type Icon + Title + Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      typeIcon,
                      size: 20,
                      color: typeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
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
                      const SizedBox(height: 2),
                      Text(
                        notification.type.label,
                        style: GoogleFonts.montserrat(
                          color: typeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Notification Message Body Excerpt
            Text(
              notification.body,
              style: GoogleFonts.montserrat(
                color: AppColors.textMuted,
                fontSize: 12.5,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.surfaceBorder, height: 1),
            const SizedBox(height: 8),

            // Bottom Bar: Target Audience, Timestamp & Quick Actions
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.usersThree(),
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  notification.audienceType.label,
                  style: GoogleFonts.montserrat(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(notification.publishedAt ?? notification.createdAt),
                  style: GoogleFonts.montserrat(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                // Action Icon Buttons
                InkWell(
                  onTap: onPreview,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: PhosphorIcon(
                      PhosphorIcons.deviceMobile(),
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (notification.status == NotificationStatus.draft) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: PhosphorIcon(
                        PhosphorIcons.pencilSimple(),
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: PhosphorIcon(
                        PhosphorIcons.trash(),
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
