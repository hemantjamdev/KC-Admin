import 'package:flutter/material.dart';
import '../../../../core/widgets/app_toast.dart';
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

    AppToast.show(
      context,
      'Destination Link: ${type.label}${entityId != null ? ' (#$entityId)' : ''}',
      type: ToastType.info,
    );
  }
}
