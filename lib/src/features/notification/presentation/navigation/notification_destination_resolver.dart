import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/notification_model.dart';

/// Navigation resolver for notification destinations in KC-Admin.
abstract class NotificationDestinationResolver {
  static void navigateToDestination(
    BuildContext context,
    NotificationModel notification, {
    required String? authenticatedCustomerId,
  }) {
    final type =
        notification.relatedEntityType ?? NotificationDestinationType.none;
    final entityId = notification.relatedEntityId;

    if (type == NotificationDestinationType.none) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Destination Link: ${type.label}${entityId != null ? ' (#$entityId)' : ''}',
        ),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
