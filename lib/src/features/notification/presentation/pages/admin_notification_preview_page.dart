import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../domain/models/notification_model.dart';

/// Admin Notification Preview Page — renders in-app notification card as seen by customer in KC-App.
class AdminNotificationPreviewPage extends StatelessWidget {
  const AdminNotificationPreviewPage({super.key, required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.adminNotificationList);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Customer In-App Preview',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.info(),
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Expanded(
                            child: Text(
                              'This shows how the in-app notification card will look inside KC-App for eligible customers.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    const Text(
                      'UNREAD CARD STATE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildPreviewCard(isRead: false),

                    const SizedBox(height: AppSpacing.xl),

                    const Text(
                      'READ CARD STATE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildPreviewCard(isRead: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard({required bool isRead}) {
    final icon = switch (notification.type) {
      NotificationType.general => PhosphorIcons.bell(),
      NotificationType.stitchingUpdate => PhosphorIcons.scissors(),
      NotificationType.designUpdate => PhosphorIcons.tShirt(),
      NotificationType.boutiqueAnnouncement => PhosphorIcons.megaphone(),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isRead
              ? AppColors.surfaceBorder
              : AppColors.primary.withValues(alpha: 0.4),
          width: isRead ? 1.0 : 1.5,
        ),
        boxShadow: isRead
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: isRead
                  ? AppColors.surfaceLight
                  : AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(
              icon,
              size: 20,
              color: isRead ? AppColors.textMuted : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: isRead
                              ? FontWeight.w600
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Just now',
                      style: TextStyle(color: AppColors.textHint, fontSize: 11),
                    ),
                    if (notification.relatedEntityType != null &&
                        notification.relatedEntityType !=
                            NotificationDestinationType.none)
                      Text(
                        notification.relatedEntityType!.label,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
