import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/stitch_divider.dart';
import '../../../auth/application/providers/admin_profile_providers.dart';
import '../../../home/application/providers/home_providers.dart';
import '../../../notification/application/providers/notification_providers.dart';
import '../../../stitching/application/providers/stitching_providers.dart';
import '../../../stitching/presentation/pages/admin_stitching_order_details_page.dart';

import '../../../../core/widgets/network_listener_wrapper.dart';

/// Kapada Creation Admin — Bespoke Stitching Dashboard.
class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(adminDisplayNameProvider);
    final photoUrl = ref.watch(adminPhotoUrlProvider);
    final requestedCount = ref.watch(requestedOnlyCountProvider);
    final acceptedCount = ref.watch(acceptedOnlyCountProvider);
    final completedCount = ref.watch(completedOnlyCountProvider);
    final activityItems = ref.watch(recentActivityFeedProvider);
    final ordersAsync = ref.watch(adminOrderListProvider);

    return NetworkListenerWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(adminOrderListProvider);
              await ref.read(adminOrderListProvider.future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── 1. Pinned Atelier Header ───────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _AtelierHeaderSliverDelegate(
                    adminName: displayName,
                    photoUrl: photoUrl,
                    onAvatarTap: () => context.go(AppRoutes.adminProfile),
                    ref: ref,
                  ),
                ),

                // ── 2. Dynamic Stitching Requests Banner ─────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: _StitchingHeroCard(
                      requestedCount: requestedCount,
                      acceptedCount: acceptedCount,
                      completedCount: completedCount,
                      isLoading: ordersAsync.isLoading,
                    ),
                  ),
                ),

                // ── 3. 3-Stage Workflow Pipeline ──────────────────
                SliverToBoxAdapter(
                  child: _StitchingStageWorkflow(
                    requestedCount: requestedCount,
                    acceptedCount: acceptedCount,
                    completedCount: completedCount,
                    onStageTap: () =>
                        context.push(AppRoutes.adminStitchingOrderList),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: StitchDivider(
                      icon: PhosphorIcons.scissors(),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),

                // ── 4. Recent Multi-Event Activity Feed ───────────────────
                SliverToBoxAdapter(
                  child: _RecentActivitySection(
                    activityItems: activityItems,
                    isLoading: ordersAsync.isLoading,
                    hasError: ordersAsync.hasError,
                    onViewAll: () => context.push(AppRoutes.adminActivityList),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 36)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 1. Pinned Atelier Header Delegate ──────────────────────────────────────

class _AtelierHeaderSliverDelegate extends SliverPersistentHeaderDelegate {
  _AtelierHeaderSliverDelegate({
    required this.adminName,
    this.photoUrl,
    required this.onAvatarTap,
    required this.ref,
  });

  final String adminName;
  final String? photoUrl;
  final VoidCallback onAvatarTap;
  final WidgetRef ref;

  @override
  double get minExtent => 72.0;

  @override
  double get maxExtent => 130.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final timeGreeting = ref.watch(greetingProvider);
    final rawName = adminName.trim().isNotEmpty ? adminName.trim() : 'Admin';
    final firstName = rawName.split(' ').first;
    final formattedName = firstName.isNotEmpty
        ? '${firstName[0].toUpperCase()}${firstName.substring(1)}'
        : 'Admin';
    final unreadCount = ref.watch(adminUnreadNotificationCountProvider);

    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final isPinned = shrinkOffset > 10;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: isPinned
            ? Border(
                bottom: BorderSide(
                  color: AppColors.surfaceBorder.withValues(alpha: progress),
                ),
              )
            : null,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04 * progress),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Welcome back" label – fades out on scroll
                  if (progress < 0.5)
                    Opacity(
                      opacity: (1.0 - progress * 2.0).clamp(0.0, 1.0),
                      child: Text(
                        'Welcome back',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (progress < 0.5) const SizedBox(height: 2),
                  // Greeting line – original size 22, shrinks to 18 when pinned
                  Text(
                    progress < 0.7 ? '$timeGreeting,' : '$timeGreeting, $formattedName',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22 - (4 * progress),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Name on its own line – fades out when fully collapsed
                  if (progress < 0.7) ...[
                    const SizedBox(height: 2),
                    Opacity(
                      opacity: progress < 0.5 ? 1.0 : (1.0 - ((progress - 0.5) / 0.2)).clamp(0.0, 1.0),
                      child: Text(
                        formattedName,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24 - (4 * progress),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Notification Bell Action
            GestureDetector(
              onTap: () => context.push(AppRoutes.adminNotificationList),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.bell(),
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onAvatarTap,
              onLongPress: () {
                if (photoUrl != null && photoUrl!.isNotEmpty) {
                  _showFullScreenImageDialog(context, photoUrl!, rawName);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? Text(
                          formattedName.isNotEmpty
                              ? formattedName[0].toUpperCase()
                              : 'A',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AtelierHeaderSliverDelegate oldDelegate) {
    return oldDelegate.adminName != adminName || oldDelegate.photoUrl != photoUrl;
  }
}

/// Helper to format large counts compactly (e.g., 1k, 10k, 100k, 1m).
String _formatCompactNumber(int number) {
  if (number < 1000) return '$number';
  if (number < 1000000) {
    final double k = number / 1000.0;
    return k % 1 == 0 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
  }
  final double m = number / 1000000.0;
  return m % 1 == 0 ? '${m.toInt()}m' : '${m.toStringAsFixed(1)}m';
}

// ── 2. Stitching Dynamic Hero Card ──────────────────────────────────────────

class _StitchingHeroCard extends StatelessWidget {
  const _StitchingHeroCard({
    required this.requestedCount,
    required this.acceptedCount,
    required this.completedCount,
    required this.isLoading,
  });

  final int requestedCount;
  final int acceptedCount;
  final int completedCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const goldAccent = Color(0xFFD4AF37);
    final activeCount = requestedCount + acceptedCount;
    final formattedActive = _formatCompactNumber(activeCount);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3625), Color(0xFF1B593F), Color(0xFF123D2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3625).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: Transform.rotate(
                angle: -0.4,
                child: PhosphorIcon(
                  PhosphorIcons.scissors(),
                  size: 210,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE STITCHING REQUESTS',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: goldAccent,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  _HeroSkeleton()
                else ...[
                  Text(
                    activeCount == 0
                        ? 'No active stitching requests'
                        : '$formattedActive Active Stitching ${activeCount == 1 ? 'Request' : 'Requests'}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.background,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                          icon: PhosphorIcons.clock(),
                          value: _formatCompactNumber(requestedCount),
                          label: 'Requested',
                          color: goldAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatPill(
                          icon: PhosphorIcons.handshake(),
                          value: _formatCompactNumber(acceptedCount),
                          label: 'Accepted',
                          color: const Color(0xFF29B6F6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatPill(
                          icon: PhosphorIcons.checkCircle(),
                          value: _formatCompactNumber(completedCount),
                          label: 'Completed',
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.background,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: GoogleFonts.montserrat(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 24,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 24,
          width: 140,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}

// ── 3. 2-Stage Workflow Pipeline ──────────────────────────────────────────────

class _StitchingStageWorkflow extends StatelessWidget {
  const _StitchingStageWorkflow({
    required this.requestedCount,
    required this.acceptedCount,
    required this.completedCount,
    required this.onStageTap,
  });

  final int requestedCount;
  final int acceptedCount;
  final int completedCount;
  final VoidCallback onStageTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3-STAGE STITCHING WORKFLOW',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: onStageTap,
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PhosphorIcon(
                      PhosphorIcons.caretRight(),
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _WorkflowStageCard(
                  title: 'Requested',
                  subtitle: 'User requested',
                  count: requestedCount,
                  icon: PhosphorIcons.clock(),
                  accentColor: const Color(0xFFD97706),
                  onTap: onStageTap,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _WorkflowStageCard(
                  title: 'Accepted',
                  subtitle: 'Accepted by admin',
                  count: acceptedCount,
                  icon: PhosphorIcons.handshake(),
                  accentColor: const Color(0xFF0284C7),
                  isFeatured: true,
                  onTap: onStageTap,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _WorkflowStageCard(
                  title: 'Completed',
                  subtitle: 'Work finished',
                  count: completedCount,
                  icon: PhosphorIcons.checkCircle(),
                  accentColor: const Color(0xFF2E7D32),
                  onTap: onStageTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.sparkle(),
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Flow: User creates request ➔ Admin accepts ➔ Admin marks completed.',
                    style: GoogleFonts.montserrat(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowStageCard extends StatelessWidget {
  const _WorkflowStageCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.isFeatured = false,
  });

  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final borderColor = count > 0
        ? accentColor
        : accentColor.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: DashedStitchContainer(
        borderColor: borderColor,
        backgroundColor: AppColors.surface,
        borderRadius: 18.0,
        dashWidth: 7.0,
        dashGap: 4.0,
        strokeWidth: 2.0,
        inset: 5.0,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: isFeatured ? 24 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: accentColor),
                ),
                Text(
                  _formatCompactNumber(count),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    style: GoogleFonts.montserrat(
                      fontSize: 9.5,
                      color: AppColors.textMuted,
                    ),
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

// ── 4. Recent Stitching Requests Feed ──────────────────────────────────────────

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({
    required this.activityItems,
    required this.isLoading,
    required this.hasError,
    required this.onViewAll,
  });

  final List<AdminActivityItem> activityItems;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT ACTIVITY',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            ..._skeletonItems()
          else if (hasError)
            _ErrorCard()
          else if (activityItems.isEmpty)
            AppEmptyState(
              icon: PhosphorIcons.clockCounterClockwise(),
              title: 'No recent activity yet',
              message:
                  'Stitching requests, favorites, and catalogue updates will appear here.',
              compact: true,
            )
          else
            ...activityItems
                .take(6)
                .map((item) => _ActivityItemTile(item: item)),
        ],
      ),
    );
  }

  List<Widget> _skeletonItems() => List.generate(
    3,
    (_) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceBorder.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}

class _ActivityItemTile extends StatelessWidget {
  const _ActivityItemTile({required this.item});

  final AdminActivityItem item;

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(item.timestamp);

    return GestureDetector(
      onTap: () {
        if (item.associatedOrder != null) {
          AdminStitchingOrderDetailsPage.showAsBottomSheet(
            context,
            order: item.associatedOrder!,
          );
        } else if (item.category == AdminActivityCategory.newDesign ||
            item.category == AdminActivityCategory.favorite) {
          context.go(AppRoutes.adminProducts);
        } else if (item.category == AdminActivityCategory.notification) {
          context.push(AppRoutes.adminNotificationList);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left accent stripe indicator matching category color
                  Container(
                    width: 4.5,
                    color: item.color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Row(
                        children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(item.icon, size: 20, color: item.color),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  timeAgo,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      PhosphorIcon(
                        PhosphorIcons.caretRight(),
                        size: 14,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM').format(dt);
  }
}

class _ErrorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          PhosphorIcon(
            PhosphorIcons.warningCircle(),
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Unable to connect to activity feed database. Pull down to refresh.',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showFullScreenImageDialog(
  BuildContext context,
  String imageUrl,
  String title,
) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.88),
    builder: (dialogCtx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(dialogCtx),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(32),
                    color: AppColors.surface,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: GoogleFonts.montserrat(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
