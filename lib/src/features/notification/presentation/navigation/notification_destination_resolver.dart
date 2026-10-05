import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
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

    switch (type) {
      case NotificationDestinationType.stitchingOrder:
        context.push(AppRoutes.adminStitchingOrderList);
        break;
      case NotificationDestinationType.customerProfile:
        if (entityId != null && entityId.isNotEmpty) {
          context.push(AppRoutes.adminCustomerDetails, extra: entityId);
        } else {
          context.push(AppRoutes.adminCustomerList);
        }
        break;
      case NotificationDestinationType.design:
        context.push(AppRoutes.adminProducts);
        break;
      default:
        AppToast.show(
          context,
          'Destination Link: ${type.label}${entityId != null ? ' (#$entityId)' : ''}',
          type: ToastType.info,
        );
        break;
    }
  }
}
